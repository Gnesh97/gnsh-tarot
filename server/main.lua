-- Server event registration. Every handler runs the same guard pipeline:
-- cooldown -> payload validation -> session/table lookup -> state check ->
-- role check -> distance/bucket check -- before doing any work.

local function notify(src, key, ...)
    Bridge.Notify(src, _L(key, ...))
end

local pendingPlacements = {}

local function placementRejected(src, reason)
    pendingPlacements[src] = nil
    TriggerClientEvent('tarot:client:tablePlacementRejected', src, { reason = reason })
end

local function expectedTableModels()
    local models = {
        Config.TableModel,
        Config.TableFallbackModel,
    }

    if Config.UseCompositeProps and Config.CompositeProps and Config.CompositeProps.table then
        models[#models + 1] = Config.CompositeProps.table.model
    end

    return models
end

local function isExpectedTableModel(entity)
    local entityModel = GetEntityModel(entity)
    for _, model in ipairs(expectedTableModels()) do
        if type(model) == 'string' and entityModel == GetHashKey(model) then
            return true
        end
    end
    return false
end

local function sessionTableIsUsable(session)
    local tableEntry = session and Tables.Get(session.tableId)
    return tableEntry ~= nil and Tables.IsEntityValid(session.tableId)
end

local function sessionIsWithinBounds(session)
    if not sessionTableIsUsable(session)
        or not Security.SamePlayerBucket(session.readerSource, session.customerSource)
        or not Security.WithinDistance(session.readerSource, session.customerSource, Config.SessionMaxDistance) then
        return false
    end

    local tableEntry = Tables.Get(session.tableId)
    return Security.WithinEntityDistance(session.readerSource, tableEntry.entity, Config.SessionMaxDistance)
        and Security.WithinEntityDistance(session.customerSource, tableEntry.entity, Config.SessionMaxDistance)
end

RegisterNetEvent('tarot:server:placeTable', function(coords, heading)
    local src = source
    if not Security.ValidateSource(src) then return end
    if not Cooldowns.Check(src, 'placeTable') then return notify(src, 'action_too_fast') end
    if not Security.ValidateCoords(coords) or not Security.ValidateHeading(heading) then return end
    if not Security.WithinPlayerDistance(src, coords, Config.TablePlacementDistance) then
        return notify(src, 'table_too_far')
    end
    if pendingPlacements[src] ~= nil then return notify(src, 'table_placement_pending') end

    if Tables.CountForOwner(src) >= Config.MaxTablesPerPlayer then
        return notify(src, 'table_too_many')
    end

    if Config.RequireTableItem then
        if not Bridge.HasItem(src, Config.TableItem, 1) then
            return notify(src, 'table_no_item')
        end
    end

    pendingPlacements[src] = {
        coords = coords,
        heading = heading,
        createdAt = os.time(),
    }
    TriggerClientEvent('tarot:client:spawnTable', src, { coords = coords, heading = heading })
end)

RegisterNetEvent('tarot:server:confirmTablePlaced', function(coords, heading, netId, compositeNetIds)
    local src = source
    if not Security.ValidateSource(src) then return end
    if not Cooldowns.Check(src, 'confirmTablePlaced') then return notify(src, 'action_too_fast') end
    if not Security.ValidateCoords(coords) or not Security.ValidateHeading(heading) or type(netId) ~= 'number' then return end

    local pending = pendingPlacements[src]
    if pending == nil then return placementRejected(src, 'table_placement_invalid') end
    if (os.time() - pending.createdAt) >= Config.PendingPlacementTimeoutSeconds then
        return placementRejected(src, 'table_placement_expired')
    end
    if Utils.DistanceBetween(pending.coords, coords) > Config.TablePlacementDistance then
        return placementRejected(src, 'table_placement_invalid')
    end
    local headingDelta = math.abs(heading - pending.heading)
    if headingDelta > 180.0 then headingDelta = 360.0 - headingDelta end
    if headingDelta > Config.TableHeadingTolerance then
        return placementRejected(src, 'table_placement_invalid')
    end
    if Tables.CountForOwner(src) >= Config.MaxTablesPerPlayer then
        return placementRejected(src, 'table_too_many')
    end

    local entity = NetworkGetEntityFromNetworkId(netId)
    if entity == 0 or not DoesEntityExist(entity)
        or not Security.IsNetworkEntityOwnedBy(entity, src)
        or not isExpectedTableModel(entity)
        or not Security.WithinEntityDistance(src, entity, Config.TableEntityValidationDistance) then
        return placementRejected(src, 'table_placement_invalid')
    end
    if Utils.DistanceBetween(GetEntityCoords(entity), pending.coords) > Config.TableEntityValidationDistance then
        return placementRejected(src, 'table_placement_invalid')
    end
    if Tables.FindByNetId(netId) ~= nil then
        return placementRejected(src, 'table_placement_invalid')
    end

    local compositeEntities = {}
    if type(compositeNetIds) == 'table' then
        for key, id in pairs(compositeNetIds) do
            if type(key) ~= 'string' or #key > 32 or type(id) ~= 'number' then
                return placementRejected(src, 'table_placement_invalid')
            end
            if id ~= 0 then
                local ent = NetworkGetEntityFromNetworkId(id)
                if ent == 0 or not DoesEntityExist(ent)
                    or not Security.IsNetworkEntityOwnedBy(ent, src)
                    or Utils.DistanceBetween(GetEntityCoords(entity), GetEntityCoords(ent)) > Config.TableEntityValidationDistance then
                    return placementRejected(src, 'table_placement_invalid')
                end
                compositeEntities[key] = ent
            end
        end
    end

    pendingPlacements[src] = nil
    if Config.RequireTableItem and Config.ConsumeTableItem
        and not Bridge.RemoveItem(src, Config.TableItem, 1) then
        TriggerClientEvent('tarot:client:tablePlacementRejected', src, { reason = 'table_no_item' })
        return notify(src, 'table_no_item')
    end

    local tableEntry = Tables.Create(
        src,
        coords,
        heading,
        entity,
        compositeEntities,
        netId
    )
    notify(src, 'table_placed')
    TriggerClientEvent('tarot:client:tableRegisteredBroadcast', -1, { tableId = tableEntry.id, netId = tableEntry.netId })
    TriggerClientEvent('tarot:client:tableRegistered', src, { tableId = tableEntry.id })
end)

RegisterNetEvent('tarot:server:cancelTablePlacement', function()
    local src = source
    if not Security.ValidateSource(src) then return end
    pendingPlacements[src] = nil
end)

RegisterNetEvent('tarot:server:removeTable', function(tableId)
    local src = source
    if not Security.ValidateSource(src) then return end
    if not Utils.IsValidTableId(tableId) then return end
    if not Cooldowns.Check(src, 'removeTable') then return notify(src, 'action_too_fast') end

    local tableEntry = Tables.Get(tableId)
    if tableEntry == nil then return notify(src, 'table_not_found') end
    if not Security.WithinEntityDistance(src, tableEntry.entity, Config.TableRemovalDistance) then
        return notify(src, 'table_too_far')
    end
    if tableEntry.busy then return notify(src, 'table_busy') end

    Cleanup.Table(tableId, 'removed_by_owner')
end)

RegisterNetEvent('tarot:server:startReading', function(tableId, targetServerId)
    local src = source
    if not Security.ValidateSource(src) then return end
    if not Cooldowns.Check(src, 'startReading') then return notify(src, 'action_too_fast') end
    if not Utils.IsValidTableId(tableId) or type(targetServerId) ~= 'number' or targetServerId % 1 ~= 0 then return end

    local soloReading = Config.AllowSoloReading == true and targetServerId == src
    if targetServerId == src and not soloReading then return notify(src, 'invite_self') end
    if not soloReading and not Security.ValidateSource(targetServerId) then return notify(src, 'invite_no_target') end

    if not Bridge.IsReaderAllowed(src) then return notify(src, 'no_permission') end

    local tableEntry = Tables.Get(tableId)
    if tableEntry == nil then return notify(src, 'table_not_found') end
    if tableEntry.owner ~= src then return notify(src, 'table_not_owner') end
    if not Tables.IsEntityValid(tableId) then return notify(src, 'table_not_found') end
    if not Security.WithinEntityDistance(src, tableEntry.entity, Config.TableInteractionDistance) then
        return notify(src, 'table_too_far')
    end
    if tableEntry.busy then return notify(src, 'table_busy') end

    if Sessions.IsPlayerBusy(src) then return notify(src, 'invite_you_are_busy') end
    if not soloReading and Sessions.IsPlayerBusy(targetServerId) then return notify(src, 'invite_already_busy') end

    if not soloReading and not Security.SamePlayerBucket(src, targetServerId) then return notify(src, 'invite_too_far') end
    if not soloReading and not Security.WithinDistance(src, targetServerId, Config.InviteDistance) then return notify(src, 'invite_too_far') end

    local session = Sessions.Create(src, targetServerId, tableId)
    Tables.SetBusy(tableId, true, session.id)

    if soloReading then
        Sessions.SetState(session, SessionStates.ACCEPTED)
        Sessions.SetState(session, SessionStates.SPREAD_SELECTION)
        local sequence = Sessions.BumpSequence(session)
        TriggerClientEvent('tarot:client:sessionStarted', src, {
            sessionId = session.id,
            tableId = tableEntry.id,
            tableNetId = tableEntry.netId,
            state = SessionStates.SPREAD_SELECTION,
            sequence = sequence,
        })
        return
    end

    notify(src, 'invite_sent')
    TriggerClientEvent('tarot:client:receiveInvite', targetServerId, {
        sessionId = session.id,
        tableId = tableEntry.id,
        tableNetId = tableEntry.netId,
        readerName = Bridge.GetName(src),
    })
end)

RegisterNetEvent('tarot:server:acceptInvite', function(sessionId)
    local src = source
    if not Security.ValidateSource(src) then return end
    if not Utils.IsValidSessionId(sessionId) then return end
    if not Cooldowns.Check(src, 'acceptInvite') then return notify(src, 'action_too_fast') end

    local session = Sessions.Get(sessionId)
    if session == nil then return notify(src, 'session_not_found') end
    if not Security.IsSessionCustomer(session, src) then return end
    if session.state ~= SessionStates.INVITED then return notify(src, 'session_wrong_state') end
    if not sessionIsWithinBounds(session) then
        return Cleanup.Session(sessionId, 'session_too_far')
    end

    Sessions.SetState(session, SessionStates.ACCEPTED)
    Sessions.SetState(session, SessionStates.SPREAD_SELECTION)
    local seq = Sessions.BumpSequence(session)

    local startPayload = {
        sessionId = session.id,
        tableId = session.tableId,
        tableNetId = Tables.Get(session.tableId).netId,
        state = SessionStates.SPREAD_SELECTION,
        sequence = seq,
    }
    TriggerClientEvent('tarot:client:sessionStarted', session.readerSource, startPayload)
    TriggerClientEvent('tarot:client:sessionStarted', session.customerSource, startPayload)
end)

RegisterNetEvent('tarot:server:selectSpread', function(sessionId, spreadType)
    local src = source
    if not Security.ValidateSource(src) then return end
    if not Utils.IsValidSessionId(sessionId) or type(spreadType) ~= 'string' then return end
    if not Cooldowns.Check(src, 'selectSpread') then return notify(src, 'action_too_fast') end

    local session = Sessions.Get(sessionId)
    if session == nil then return notify(src, 'session_not_found') end
    if not Security.IsSessionReader(session, src) then return notify(src, 'session_not_your_turn') end
    if session.state ~= SessionStates.SPREAD_SELECTION then return notify(src, 'session_wrong_state') end
    local spread = Config.Spreads[spreadType]
    if not AllowedSpreads[spreadType] or spread == nil or spread.enabled == false then return notify(src, 'session_slot_invalid') end
    if not sessionIsWithinBounds(session) then return notify(src, 'session_too_far') end
    if (tonumber(spread.cardCount) or #(spread.slots or {})) > #Cards then return notify(src, 'generic_error') end
    if not Sessions.SetSpread(session, spreadType) then return notify(src, 'generic_error') end

    Sessions.SetState(session, SessionStates.SPREAD_SELECTED)
    Sessions.SetState(session, SessionStates.SHUFFLING)
    Sessions.SetState(session, SessionStates.DEALING)
    local sequence = Sessions.BumpSequence(session)
    -- The board opens empty; the reader triggers the deal itself through
    -- tarot:server:startDeal, so no deal timer is armed here.
    local payload = {
        sessionId = session.id,
        tableId = session.tableId,
        tableNetId = Tables.Get(session.tableId).netId,
        state = SessionStates.DEALING,
        spreadKey = spreadType,
        spreadType = spreadType,
        cardCount = session.cardCount,
        revealMode = session.revealMode,
        sequence = sequence,
        awaitDeal = true,
    }
    TriggerClientEvent('tarot:client:spreadLoaded', session.readerSource, payload)
    TriggerClientEvent('tarot:client:spreadLoaded', session.customerSource, payload)
end)

RegisterNetEvent('tarot:server:startDeal', function(sessionId)
    local src = source
    if not Security.ValidateSource(src) then return end
    if not Utils.IsValidSessionId(sessionId) then return end
    if not Cooldowns.Check(src, 'startDeal') then return notify(src, 'action_too_fast') end

    local session = Sessions.Get(sessionId)
    if session == nil then return notify(src, 'session_not_found') end
    if not Security.IsSessionReader(session, src) then return notify(src, 'session_not_your_turn') end
    if session.state ~= SessionStates.DEALING then return notify(src, 'session_wrong_state') end
    -- dealEndsAt is the in-flight marker: pressing deal twice must not re-run it.
    if session.dealEndsAt ~= nil then return end
    if not sessionIsWithinBounds(session) then return notify(src, 'session_too_far') end

    local spread = Config.Spreads[session.spreadType]
    if spread == nil then return notify(src, 'generic_error') end

    local animationEnabled = Config.DealAnimation.enabled ~= false
    local deal = {
        startDelay = animationEnabled and Config.DealAnimation.initialDelay or 0,
        perCardDelay = animationEnabled and (spread.dealDelay or Config.DealAnimation.perCardDelay) or 0,
        cardTravelDuration = animationEnabled and Config.DealAnimation.cardTravelDuration or 0,
        finishDelay = animationEnabled and Config.DealAnimation.finishDelay or 0,
    }
    local total = deal.startDelay + math.max(0, session.cardCount - 1) * deal.perCardDelay + deal.cardTravelDuration + deal.finishDelay
    session.dealEndsAt = GetGameTimer() + total

    local dealPayload = {
        sessionId = session.id,
        state = SessionStates.DEALING,
        spreadKey = session.spreadType,
        spreadType = session.spreadType,
        cardCount = session.cardCount,
        sequence = Sessions.BumpSequence(session),
        deal = deal,
    }
    TriggerClientEvent('tarot:client:dealStarted', session.readerSource, dealPayload)
    TriggerClientEvent('tarot:client:dealStarted', session.customerSource, dealPayload)

    CreateThread(function()
        Wait(total)
        local active = Sessions.Get(session.id)
        if active == nil or active.state ~= SessionStates.DEALING then return end
        active.dealEndsAt = nil
        Sessions.SetState(active, SessionStates.READING)
        local readySequence = Sessions.BumpSequence(active)
        local ready = { sessionId = active.id, state = SessionStates.READING, sequence = readySequence }
        TriggerClientEvent('tarot:client:readingReady', active.readerSource, ready)
        TriggerClientEvent('tarot:client:readingReady', active.customerSource, ready)
    end)
end)

RegisterNetEvent('tarot:server:rejectInvite', function(sessionId)
    local src = source
    if not Security.ValidateSource(src) then return end
    if not Utils.IsValidSessionId(sessionId) then return end
    if not Cooldowns.Check(src, 'rejectInvite') then return notify(src, 'action_too_fast') end

    local session = Sessions.Get(sessionId)
    if session == nil then return end
    if not Security.IsSessionCustomer(session, src) then return end
    if session.state ~= SessionStates.INVITED then return end

    notify(session.readerSource, 'invite_rejected')
    notify(src, 'invite_rejected_by_you')

    Cleanup.Session(sessionId, 'invite_rejected')
end)

RegisterNetEvent('tarot:server:revealSlot', function(sessionId, slotId)
    local src = source
    if not Security.ValidateSource(src) then return end
    if not Utils.IsValidSessionId(sessionId) then return end
    slotId = Utils.SafeNumber(slotId, 1, MaxSlotIndex)
    if slotId == nil then return end
    if not Cooldowns.Check(src, 'revealSlot') then return notify(src, 'action_too_fast') end

    local session = Sessions.Get(sessionId)
    if session == nil then return notify(src, 'session_not_found') end
    if not Security.IsSessionReader(session, src) then return notify(src, 'session_not_your_turn') end
    if session.state ~= SessionStates.READING then
        return notify(src, 'session_wrong_state')
    end

    if not sessionIsWithinBounds(session) then
        return notify(src, 'session_too_far')
    end

    local slotIndex = nil
    for index, slotData in ipairs(session.slots) do
        if slotData.id == slotId then
            slotIndex = index
            break
        end
    end
    if slotIndex == nil then return notify(src, 'session_slot_invalid') end
    local slot = session.slots[slotIndex]
    if slot == nil then return notify(src, 'session_slot_invalid') end
    if slot.revealed then return notify(src, 'session_slot_taken') end

    if not Sessions.IsSlotAllowed(session, slotIndex) then return notify(src, 'session_not_sequential') end

    if not Sessions.RevealSlot(session, slotIndex) then return notify(src, 'generic_error') end
    Sessions.SetState(session, SessionStates.READING)
    local seq = Sessions.BumpSequence(session)

    local revealedSlot = session.slots[slotIndex]
    local payload = {
        sessionId = session.id,
        sequence = seq,
        slot = slotId,
        slotId = slotId,
        slotIndex = slotIndex,
        cardId = revealedSlot.cardId,
        orientation = revealedSlot.orientation,
        animationDelay = Config.RevealAnimationDelay,
    }

    TriggerClientEvent('tarot:client:slotRevealed', session.readerSource, payload)
    TriggerClientEvent('tarot:client:slotRevealed', session.customerSource, payload)

    if Sessions.NextUnrevealedIndex(session) == nil then
        Sessions.SetState(session, SessionStates.COMPLETED)
        local completeSeq = Sessions.BumpSequence(session)
        local completePayload = { sessionId = session.id, sequence = completeSeq }
        TriggerClientEvent('tarot:client:sessionCompleted', session.readerSource, completePayload)
        TriggerClientEvent('tarot:client:sessionCompleted', session.customerSource, completePayload)
    end
end)

RegisterNetEvent('tarot:server:revealAll', function(sessionId)
    local src = source
    if not Security.ValidateSource(src) then return end
    if Config.AllowRevealAll ~= true then return end
    if not Utils.IsValidSessionId(sessionId) then return end
    if not Cooldowns.Check(src, 'revealAll') then return notify(src, 'action_too_fast') end
    local session = Sessions.Get(sessionId)
    if session == nil then return notify(src, 'session_not_found') end
    if not Security.IsSessionReader(session, src) then return notify(src, 'session_not_your_turn') end
    if session.state ~= SessionStates.READING then return notify(src, 'session_wrong_state') end
    if not sessionIsWithinBounds(session) then return notify(src, 'session_too_far') end

    local cards = {}
    local batchIndex = 0
    for index, slot in ipairs(session.slots) do
        if not slot.revealed and Sessions.RevealSlot(session, index) then
            batchIndex = batchIndex + 1
            cards[batchIndex] = {
                slotId = slot.id,
                slotIndex = index,
                cardId = slot.cardId,
                orientation = slot.orientation,
                batchIndex = batchIndex,
            }
        end
    end
    if batchIndex == 0 then return end
    Sessions.SetState(session, SessionStates.COMPLETED)
    local sequence = Sessions.BumpSequence(session)
    local payload = { sessionId = session.id, batchSequence = sequence, cards = cards }
    TriggerClientEvent('tarot:client:slotsRevealedBatch', session.readerSource, payload)
    TriggerClientEvent('tarot:client:slotsRevealedBatch', session.customerSource, payload)
    TriggerClientEvent('tarot:client:sessionCompleted', session.readerSource, { sessionId = session.id, sequence = sequence + 1 })
    TriggerClientEvent('tarot:client:sessionCompleted', session.customerSource, { sessionId = session.id, sequence = sequence + 1 })
    Sessions.BumpSequence(session)
end)

RegisterNetEvent('tarot:server:requestSessionSnapshot', function(sessionId)
    local src = source
    if not Security.ValidateSource(src) then return end
    if not Utils.IsValidSessionId(sessionId) then return end
    if not Cooldowns.Check(src, 'requestSessionSnapshot') then return notify(src, 'action_too_fast') end

    local session = Sessions.Get(sessionId)
    if session == nil then return notify(src, 'session_not_found') end
    if not Security.IsSessionReader(session, src) and not Security.IsSessionCustomer(session, src) then return end
    if not sessionIsWithinBounds(session) then return notify(src, 'session_too_far') end

    TriggerClientEvent('tarot:client:sessionSnapshot', src, Sessions.BuildSnapshot(session))
end)

RegisterNetEvent('tarot:server:closeSession', function(sessionId)
    local src = source
    if not Security.ValidateSource(src) then return end
    if not Utils.IsValidSessionId(sessionId) then return end
    if not Cooldowns.Check(src, 'closeSession') then return notify(src, 'action_too_fast') end

    local session = Sessions.Get(sessionId)
    if session == nil then return end
    if not Security.IsSessionReader(session, src) and not Security.IsSessionCustomer(session, src) then return end
    if not sessionIsWithinBounds(session) then return notify(src, 'session_too_far') end

    Cleanup.Session(sessionId, session.state == SessionStates.COMPLETED and 'session_completed' or 'session_cancelled')
end)

RegisterCommand('tarotcleanup', function(src)
    if src ~= 0 and not Bridge.IsAdmin(src) then return end

    for id in pairs(Sessions.All()) do
        Cleanup.Session(id, 'admin_cleanup')
    end
    for id in pairs(Tables.All()) do
        Cleanup.Table(id, 'admin_cleanup')
    end
end, true)

CreateThread(function()
    while true do
        Wait(2000)
        local now = os.time()
        for src, placement in pairs(pendingPlacements) do
            if now - placement.createdAt >= Config.PendingPlacementTimeoutSeconds then
                placementRejected(src, 'table_placement_expired')
            end
        end
    end
end)

AddEventHandler('playerDropped', function()
    pendingPlacements[source] = nil
end)
