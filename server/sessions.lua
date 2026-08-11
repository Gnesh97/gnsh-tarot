-- Session state machine: invited -> accepted -> spread selection -> dealing -> reading ->
-- completed | cancelled. Sequence increments on every outbound change so
-- clients can detect gaps and request a snapshot (BuildSnapshot below).

Sessions = {}

local registry = {}
local playerSessions = {}

local allowedTransitions = {
    [SessionStates.INVITED] = {
        [SessionStates.ACCEPTED] = true,
        [SessionStates.CANCELLED] = true,
    },
    [SessionStates.ACCEPTED] = {
        [SessionStates.SPREAD_SELECTION] = true,
        [SessionStates.CANCELLED] = true,
    },
    [SessionStates.SPREAD_SELECTION] = {
        [SessionStates.SPREAD_SELECTED] = true,
        [SessionStates.CANCELLED] = true,
    },
    [SessionStates.SPREAD_SELECTED] = {
        [SessionStates.SHUFFLING] = true,
        [SessionStates.DEALING] = true,
        [SessionStates.CANCELLED] = true,
    },
    [SessionStates.SHUFFLING] = {
        [SessionStates.DEALING] = true,
        [SessionStates.CANCELLED] = true,
    },
    [SessionStates.DEALING] = {
        [SessionStates.READING] = true,
        [SessionStates.CANCELLED] = true,
    },
    [SessionStates.READING] = {
        [SessionStates.READING] = true,
        [SessionStates.COMPLETED] = true,
        [SessionStates.CANCELLED] = true,
    },
    [SessionStates.COMPLETED] = {
        [SessionStates.CANCELLED] = true,
    },
    [SessionStates.CANCELLED] = {},
}

function Sessions.Get(id)
    return registry[id]
end

function Sessions.GetForPlayer(src)
    local id = playerSessions[src]
    if id == nil then return nil end
    return registry[id]
end

function Sessions.IsPlayerBusy(src)
    return playerSessions[src] ~= nil
end

function Sessions.Create(readerSource, customerSource, tableId)
    local id = Utils.GenerateId('tarot')
    local session = {
        id = id,
        state = SessionStates.INVITED,
        readerSource = readerSource,
        customerSource = customerSource,
        tableId = tableId,
        spreadType = nil,
        cardCount = 0,
        revealMode = nil,
        deck = nil,
        sequence = 0,
        slots = {},
        createdAt = os.time(),
        lastActivity = os.time(),
        dealEndsAt = nil,
    }

    registry[id] = session
    playerSessions[readerSource] = id
    playerSessions[customerSource] = id

    return session
end

function Sessions.Touch(session)
    if session == nil then return end
    session.lastActivity = os.time()
end

function Sessions.BumpSequence(session)
    session.sequence = session.sequence + 1
    return session.sequence
end

function Sessions.SetState(session, newState)
    if session == nil or allowedTransitions[session.state] == nil then return false end
    if session.state ~= newState and not allowedTransitions[session.state][newState] then
        Utils.Debug('invalid session transition', session.id, session.state, newState)
        return false
    end
    session.state = newState
    Sessions.Touch(session)
    return true
end

function Sessions.SetSpread(session, spreadType)
    if session == nil or not AllowedSpreads[spreadType] or Config.Spreads[spreadType] == nil then
        return false
    end
    session.spreadType = spreadType
    local spread = Config.Spreads[spreadType]
    session.deck = Deck.Build()
    session.slots = {}

    local slotCount = 0
    for index, slot in ipairs(spread.slots or {}) do
        if spreadType ~= 'pentagram' or Config.PentagramIncludeCenter ~= false or index ~= 1 then
            slotCount = slotCount + 1
            session.slots[slotCount] = { id = slot.id or index, row = slot.row, revealed = false, cardId = nil, orientation = nil }
        end
    end
    if spread.cardCount ~= nil and spreadType ~= 'pentagram' then slotCount = math.min(slotCount, spread.cardCount) end
    session.cardCount = slotCount
    session.revealMode = spread.revealMode or 'sequential'
    return true
end

function Sessions.RevealSlot(session, slotIndex)
    if session == nil or session.state ~= SessionStates.READING then
        return false
    end
    local drawn = Deck.DrawAt(session, slotIndex)
    if drawn == nil then return false end
    if session.slots[slotIndex] == nil or session.slots[slotIndex].revealed then return false end

    session.slots[slotIndex].revealed = true
    session.slots[slotIndex].cardId = drawn.cardId
    session.slots[slotIndex].orientation = drawn.orientation

    Sessions.Touch(session)
    return true
end

function Sessions.NextUnrevealedIndex(session)
    for i = 1, #session.slots do
        if not session.slots[i].revealed then
            return i
        end
    end
    return nil
end

function Sessions.IsSlotAllowed(session, slotIndex)
    if session == nil or session.slots[slotIndex] == nil or session.slots[slotIndex].revealed then return false end
    local spread = Config.Spreads[session.spreadType]
    local mode = Config.ForceSequentialReveal and 'sequential' or (spread and spread.revealMode or session.revealMode)
    if mode == 'free' then return true end

    local expected = Sessions.NextUnrevealedIndex(session)
    if mode ~= 'row_sequential' then return expected == slotIndex end

    local expectedRow = session.slots[expected] and session.slots[expected].row or nil
    return expectedRow == nil or session.slots[slotIndex].row == expectedRow
end

-- Snapshot sent to a given recipient: only revealed slot data, never the
-- deck or unrevealed cards, regardless of who asks.
function Sessions.BuildSnapshot(session)
    local slots = {}
    for i, slot in ipairs(session.slots) do
        slots[i] = {
            id = slot.id,
            revealed = slot.revealed,
            cardId = slot.revealed and slot.cardId or nil,
            orientation = slot.revealed and slot.orientation or nil,
        }
    end

    return {
        sessionId = session.id,
        tableId = session.tableId,
        tableNetId = Tables.Get(session.tableId) and Tables.Get(session.tableId).netId or nil,
        state = session.state,
        spreadType = session.spreadType,
        cardCount = session.cardCount,
        revealMode = session.revealMode,
        dealRemainingMs = session.dealEndsAt and math.max(0, (session.dealEndsAt - GetGameTimer())) or 0,
        sequence = session.sequence,
        readerSource = session.readerSource,
        customerSource = session.customerSource,
        slots = slots,
    }
end

function Sessions.Destroy(id)
    local session = registry[id]
    if session == nil then return end

    if playerSessions[session.readerSource] == id then
        playerSessions[session.readerSource] = nil
    end
    if playerSessions[session.customerSource] == id then
        playerSessions[session.customerSource] = nil
    end

    registry[id] = nil
end

function Sessions.All()
    return registry
end

-- Timeout sweeper: invite timeout, overall session timeout, distance check.
CreateThread(function()
    while true do
        Wait(2000)
        local now = os.time()

        for id, session in pairs(registry) do
            if not Tables.IsEntityValid(session.tableId) then
                TriggerEvent('tarot:server:internalTimeoutSession', id, 'table_missing')
            elseif session.state == SessionStates.INVITED and (now - session.createdAt) >= Config.InviteTimeoutSeconds then
                TriggerEvent('tarot:server:internalTimeoutSession', id, 'invite_expired')
            elseif session.state ~= SessionStates.INVITED and (now - session.lastActivity) >= Config.SessionTimeoutSeconds then
                TriggerEvent('tarot:server:internalTimeoutSession', id, 'session_timeout')
            elseif session.state ~= SessionStates.INVITED
                and session.state ~= SessionStates.COMPLETED
                and session.state ~= SessionStates.CANCELLED then
                local tableEntry = Tables.Get(session.tableId)
                if not Security.WithinDistance(session.readerSource, session.customerSource, Config.SessionMaxDistance)
                    or tableEntry == nil
                    or not Security.WithinEntityDistance(session.readerSource, tableEntry.entity, Config.SessionMaxDistance)
                    or not Security.WithinEntityDistance(session.customerSource, tableEntry.entity, Config.SessionMaxDistance) then
                    TriggerEvent('tarot:server:internalTimeoutSession', id, 'session_too_far')
                end
            end
        end
    end
end)
