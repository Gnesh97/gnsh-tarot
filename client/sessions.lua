-- Client-side session mirror. Never trusts local card guesses — every field
-- here is set from a server payload. Sequence gaps trigger a snapshot re-sync.

TarotSessions = {}

local currentSession = nil -- {id, state, spreadType, sequence, slots, isReader}
local pendingInvite = nil
local snapshotPending = false

local function showSummaryAfterReveal(session)
    if session == nil or session.id == nil then return end
    local sessionId = session.id
    local delay = math.max((tonumber(Config.RevealAnimationDelay) or 0) + 750, tonumber(session.summaryDelay) or 0)
    SetTimeout(delay, function()
        if currentSession ~= nil and currentSession.id == sessionId and currentSession.state == 'completed' then
            TarotNui.ShowSummary(currentSession)
        end
    end)
end

local function validOrientation(orientation)
    return orientation == 'upright' or orientation == 'reversed'
end

local function validCard(cardId)
    return type(cardId) == 'number' and CardsById[cardId] ~= nil
end

local function slotIndexForId(spreadType, slotId)
    local spread = Config.Spreads[spreadType]
    if spread == nil or type(slotId) ~= 'number' then return nil end
    local outputIndex = 0
    for index, slot in ipairs(spread.slots or {}) do
        if spreadType ~= 'pentagram' or Config.PentagramIncludeCenter ~= false or index ~= 1 then
            outputIndex = outputIndex + 1
            if (slot.id or index) == slotId then return outputIndex end
        end
    end
    return nil
end

local function slotIdForIndex(spreadType, index)
    local spread = Config.Spreads[spreadType]
    if spread == nil or type(index) ~= 'number' then return nil end
    local outputIndex = 0
    for sourceIndex, slot in ipairs(spread.slots or {}) do
        if spreadType ~= 'pentagram' or Config.PentagramIncludeCenter ~= false or sourceIndex ~= 1 then
            outputIndex = outputIndex + 1
            if outputIndex == index then return slot.id or sourceIndex end
        end
    end
    return nil
end

local function getTableEntity(session)
    if session == nil then return nil end

    local localEntity = session.tableId and TarotTables.GetEntity(session.tableId)
    if localEntity ~= nil and DoesEntityExist(localEntity) then
        return localEntity
    end

    return session.tableNetId and TarotTables.GetEntityByNetId(session.tableNetId) or nil
end

local function seatForSession(session)
    if session == nil or not Config.Seating.enabled then return end

    CreateThread(function()
        local deadline = GetGameTimer() + Config.ModelLoadTimeoutMs
        local entity = getTableEntity(session)
        while entity == nil and GetGameTimer() < deadline do
            Wait(100)
            entity = getTableEntity(session)
        end

        if currentSession == nil or currentSession.id ~= session.id or entity == nil then return end
        if session.isReader then
            TarotSeating.SitAsReader(entity)
        else
            TarotSeating.SitAsCustomer(entity)
        end
    end)
end

local function resetSession()
    currentSession = nil
    snapshotPending = false
end

local function applySnapshot(snapshot)
    if type(snapshot) ~= 'table'
        or not Utils.IsValidSessionId(snapshot.sessionId)
        or currentSession == nil
        or currentSession.id ~= snapshot.sessionId
        or type(snapshot.sequence) ~= 'number'
        or snapshot.sequence < currentSession.sequence then return end
    if snapshot.spreadType ~= nil and Config.Spreads[snapshot.spreadType] == nil then return end
    if type(snapshot.slots) ~= 'table' then return end

    currentSession.state = snapshot.state or currentSession.state
    currentSession.spreadType = snapshot.spreadType or currentSession.spreadType
    currentSession.sequence = snapshot.sequence
    currentSession.tableId = snapshot.tableId or currentSession.tableId
    currentSession.tableNetId = snapshot.tableNetId or currentSession.tableNetId
    currentSession.slots = {}

    for index, slot in ipairs(snapshot.slots) do
        if type(slot) ~= 'table' then return end
        if slot.revealed and (not validCard(slot.cardId) or not validOrientation(slot.orientation)) then
            return
        end
        currentSession.slots[index] = {
            revealed = slot.revealed == true,
            cardId = slot.revealed and slot.cardId or nil,
            orientation = slot.revealed and slot.orientation or nil,
        }
    end

    snapshotPending = false
    if currentSession.state == 'spread_selection' then
        if currentSession.isReader then TarotNui.ShowSpreadSelection(currentSession) else TarotNui.ShowSpreadWaiting(currentSession) end
    elseif currentSession.state == 'completed' then
        showSummaryAfterReveal(currentSession)
    else
        TarotNui.RenderSnapshot(currentSession)
    end
end

RegisterNetEvent('tarot:client:receiveInvite', function(data)
    if type(data) ~= 'table' or not Utils.IsValidSessionId(data.sessionId)
        or type(data.tableId) ~= 'string' then return end
    pendingInvite = data
    TarotNui.ShowInvite(data)
end)

function TarotSessions.AcceptInvite()
    if pendingInvite == nil then return end
    currentSession = {
        id = pendingInvite.sessionId,
        state = 'accepted',
        tableId = pendingInvite.tableId,
        tableNetId = pendingInvite.tableNetId,
        spreadType = nil,
        sequence = 0,
        slots = {},
        isReader = false,
    }
    TriggerServerEvent('tarot:server:acceptInvite', pendingInvite.sessionId)
    pendingInvite = nil
end

function TarotSessions.RejectInvite()
    if pendingInvite == nil then return end
    TriggerServerEvent('tarot:server:rejectInvite', pendingInvite.sessionId)
    pendingInvite = nil
    TarotNui.Hide()
end

-- Called by client/tables.lua's target/interaction flow once a reader picks a
-- customer and spread from the selection menu.
function TarotSessions.StartReading(tableId, targetServerId)
    currentSession = {
        id = nil,
        state = 'invited',
        tableId = tableId,
        tableNetId = nil,
        spreadType = nil,
        sequence = 0,
        slots = {},
        isReader = true,
    }
    TriggerServerEvent('tarot:server:startReading', tableId, targetServerId)
end

RegisterNetEvent('tarot:client:sessionStarted', function(data)
    if type(data) ~= 'table'
        or not Utils.IsValidSessionId(data.sessionId)
        or currentSession == nil
        or (currentSession.id ~= nil and currentSession.id ~= data.sessionId) then return end
    if type(data.sequence) ~= 'number' then return end
    if currentSession.id ~= nil and data.sequence < currentSession.sequence then return end

    currentSession.id = data.sessionId
    currentSession.state = data.state or (data.spreadType and 'shuffling' or 'spread_selection')
    currentSession.tableId = data.tableId or currentSession.tableId
    currentSession.tableNetId = data.tableNetId or currentSession.tableNetId
    currentSession.spreadType = data.spreadType or currentSession.spreadType
    currentSession.sequence = data.sequence

    if currentSession.state == 'spread_selection' then
        if currentSession.isReader then TarotNui.ShowSpreadSelection(currentSession) else TarotNui.ShowSpreadWaiting(currentSession) end
    elseif currentSession.spreadType ~= nil then
        local slotCount = #Config.Spreads[currentSession.spreadType].slots
        if currentSession.spreadType == 'pentagram' and Config.PentagramIncludeCenter == false then slotCount = slotCount - 1 end
        currentSession.slots = {}
        for i = 1, slotCount do currentSession.slots[i] = { revealed = false } end
        TarotNui.ShowShuffle(currentSession)
    end
    seatForSession(currentSession)
end)

RegisterNetEvent('tarot:client:spreadSelection', function(data)
    if type(data) ~= 'table' or currentSession == nil or currentSession.id ~= data.sessionId then return end
    currentSession.state = 'spread_selection'
    currentSession.sequence = tonumber(data.sequence) or currentSession.sequence
    if currentSession.isReader then TarotNui.ShowSpreadSelection(currentSession) else TarotNui.ShowSpreadWaiting(currentSession) end
end)

RegisterNetEvent('tarot:client:spreadWaiting', function(data)
    if type(data) ~= 'table' or currentSession == nil or currentSession.id ~= data.sessionId then return end
    currentSession.state = 'spread_selection'
    TarotNui.ShowSpreadWaiting(currentSession)
end)

RegisterNetEvent('tarot:client:spreadLoaded', function(data)
    if type(data) ~= 'table' or currentSession == nil or currentSession.id ~= data.sessionId
        or Config.Spreads[data.spreadKey or data.spreadType] == nil then return end
    currentSession.state = data.state or 'dealing'
    currentSession.spreadType = data.spreadKey or data.spreadType
    currentSession.sequence = tonumber(data.sequence) or currentSession.sequence
    local count = #(Config.Spreads[currentSession.spreadType].slots or {})
    if currentSession.spreadType == 'pentagram' and Config.PentagramIncludeCenter == false then count = count - 1 end
    currentSession.slots = {}
    for i = 1, count do currentSession.slots[i] = { revealed = false } end
    TarotNui.LoadSpread(currentSession, { enabled = false }, data.awaitDeal ~= false)
end)

RegisterNetEvent('tarot:client:dealStarted', function(data)
    if type(data) ~= 'table' or currentSession == nil or currentSession.id ~= data.sessionId then return end
    currentSession.sequence = tonumber(data.sequence) or currentSession.sequence
    TarotNui.DealSpread(currentSession, data.deal)
end)

RegisterNetEvent('tarot:client:readingReady', function(data)
    if type(data) ~= 'table' or currentSession == nil or currentSession.id ~= data.sessionId then return end
    currentSession.state = 'reading'
    currentSession.sequence = tonumber(data.sequence) or currentSession.sequence
    TarotNui.RenderSnapshot(currentSession)
end)

RegisterNetEvent('tarot:client:slotRevealed', function(data)
    if type(data) ~= 'table'
        or currentSession == nil
        or currentSession.id ~= data.sessionId
        or type(data.sequence) ~= 'number'
        or type(data.slot) ~= 'number'
        or data.slot % 1 ~= 0
        or data.slot < 1
        or data.slot > MaxSlotIndex
        or not validCard(data.cardId)
        or not validOrientation(data.orientation) then return end

    if data.sequence <= currentSession.sequence then return end
    if data.sequence > currentSession.sequence + 1 then
        if not snapshotPending then
            snapshotPending = true
            TarotSessions.RequestSnapshot()
        end
        return
    end

    currentSession.sequence = data.sequence
    local slotIndex = data.slotIndex or slotIndexForId(currentSession.spreadType, data.slotId or data.slot) or data.slot
    if slotIndex < 1 or slotIndex > #currentSession.slots then return end
    currentSession.state = 'reading'
    currentSession.slots[slotIndex] = {
        revealed = true,
        cardId = data.cardId,
        orientation = data.orientation,
    }

    TarotNui.RevealSlot(slotIndex, data.cardId, data.orientation, data.animationDelay, data.slotId or slotIdForIndex(currentSession.spreadType, slotIndex))
end)

RegisterNetEvent('tarot:client:slotsRevealedBatch', function(data)
    if type(data) ~= 'table' or currentSession == nil or currentSession.id ~= data.sessionId
        or type(data.batchSequence) ~= 'number' or data.batchSequence < currentSession.sequence then return end
    currentSession.sequence = data.batchSequence
    currentSession.state = 'reading'
    currentSession.summaryDelay = (#(data.cards or {}) * 80) + (tonumber(Config.RevealAnimationDelay) or 0) + 750
    for _, card in ipairs(data.cards or {}) do
        local slotIndex = tonumber(card.slotIndex) or slotIndexForId(currentSession.spreadType, tonumber(card.slotId))
        if slotIndex ~= nil and validCard(card.cardId) and validOrientation(card.orientation) then
            currentSession.slots[slotIndex] = { revealed = true, cardId = card.cardId, orientation = card.orientation }
            TarotNui.RevealSlot(slotIndex, card.cardId, card.orientation, (tonumber(card.batchIndex) or 1) * 80, card.slotId)
        end
    end
end)

RegisterNetEvent('tarot:client:sessionSnapshot', function(snapshot)
    applySnapshot(snapshot)
end)

RegisterNetEvent('tarot:client:sessionCompleted', function(data)
    if type(data) ~= 'table' or currentSession == nil or currentSession.id ~= data.sessionId or type(data.sequence) ~= 'number' then return end
    if data.sequence <= currentSession.sequence then return end
    if data.sequence > currentSession.sequence + 1 then
        if not snapshotPending then
            snapshotPending = true
            TarotSessions.RequestSnapshot()
        end
        return
    end
    currentSession.sequence = data.sequence
    currentSession.state = 'completed'
    showSummaryAfterReveal(currentSession)
end)

RegisterNetEvent('tarot:client:sessionClosed', function(data)
    if type(data) ~= 'table' or not Utils.IsValidSessionId(data.sessionId) then return end
    if pendingInvite ~= nil and pendingInvite.sessionId == data.sessionId then
        pendingInvite = nil
        TarotNui.ShowClosing(data.reason)
    end
    if currentSession ~= nil and currentSession.id == data.sessionId then
        TarotNui.ShowClosing(data.reason)
        resetSession()
    end
end)

function TarotSessions.RevealNext()
    if currentSession == nil or currentSession.id == nil or not currentSession.isReader
        or currentSession.state ~= 'reading' then return end
    local nextIndex = nil
    for i, slot in ipairs(currentSession.slots) do
        if not slot.revealed then
            nextIndex = i
            break
        end
    end
    if nextIndex == nil then return end
    local slotId = slotIdForIndex(currentSession.spreadType, nextIndex)
    if slotId == nil then return end
    TriggerServerEvent('tarot:server:revealSlot', currentSession.id, slotId)
end

function TarotSessions.RevealSlot(slotId)
    if currentSession == nil or currentSession.id == nil or not currentSession.isReader
        or currentSession.state ~= 'reading' then return end
    local slotIndex = slotIndexForId(currentSession.spreadType, tonumber(slotId))
    if slotIndex == nil or currentSession.slots[slotIndex] == nil or currentSession.slots[slotIndex].revealed then return end
    TriggerServerEvent('tarot:server:revealSlot', currentSession.id, tonumber(slotId))
end

function TarotSessions.RevealAll()
    if currentSession == nil or currentSession.id == nil or not currentSession.isReader
        or currentSession.state ~= 'reading' or Config.AllowRevealAll ~= true then return end
    TriggerServerEvent('tarot:server:revealAll', currentSession.id)
end

function TarotSessions.RequestSnapshot()
    if currentSession == nil or currentSession.id == nil then return end
    TriggerServerEvent('tarot:server:requestSessionSnapshot', currentSession.id)
end

function TarotSessions.Close()
    if currentSession == nil or currentSession.id == nil then return end
    TriggerServerEvent('tarot:server:closeSession', currentSession.id)
end

function TarotSessions.Current()
    return currentSession
end

function TarotSessions.HasActiveSession()
    return currentSession ~= nil
end

function TarotSessions.IsPendingInvite(sessionId)
    return pendingInvite ~= nil and pendingInvite.sessionId == sessionId
end
