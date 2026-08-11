-- Idempotent cleanup used by every teardown path: drop, disconnect, timeout,
-- resource stop, admin command. Safe to call repeatedly / on already-gone ids.

Cleanup = {}

function Cleanup.Session(sessionId, reason)
    local session = Sessions.Get(sessionId)
    if session == nil then return end

    Sessions.SetState(session, SessionStates.CANCELLED)

    local payload = { sessionId = sessionId, reason = reason or 'closed' }
    if session.readerSource then
        TriggerClientEvent('tarot:client:sessionClosed', session.readerSource, payload)
    end
    if session.customerSource and session.customerSource ~= session.readerSource then
        TriggerClientEvent('tarot:client:sessionClosed', session.customerSource, payload)
    end

    if session.tableId then
        local tableEntry = Tables.Get(session.tableId)
        if tableEntry ~= nil then
            Tables.SetBusy(session.tableId, false, nil)
        end
    end

    Sessions.Destroy(sessionId)
end

function Cleanup.Table(tableId, reason)
    local tableEntry = Tables.Get(tableId)
    if tableEntry == nil then return end

    if tableEntry.sessionId then
        Cleanup.Session(tableEntry.sessionId, reason)
    end

    for _, owner in ipairs({ tableEntry.owner }) do
        TriggerClientEvent('tarot:client:tableRemoved', owner, { tableId = tableId, reason = reason or 'removed' })
    end
    TriggerClientEvent('tarot:client:tableRemovedBroadcast', -1, { tableId = tableId })

    if tableEntry.entity ~= 0 and DoesEntityExist(tableEntry.entity) then
        DeleteEntity(tableEntry.entity)
    end
    for _, propEntity in pairs(tableEntry.compositeEntities or {}) do
        if propEntity ~= 0 and DoesEntityExist(propEntity) then
            DeleteEntity(propEntity)
        end
    end

    Tables.Remove(tableId)
end

function Cleanup.PlayerDropped(src)
    local session = Sessions.GetForPlayer(src)
    if session ~= nil then
        Cleanup.Session(session.id, session.readerSource == src and 'session_reader_left' or 'session_customer_left')
    end

    for _, tableEntry in ipairs(Tables.FindByOwner(src)) do
        Cleanup.Table(tableEntry.id, 'owner_dropped')
    end

    Cooldowns.Clear(src)
end

AddEventHandler('playerDropped', function()
    Cleanup.PlayerDropped(source)
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    for id in pairs(Sessions.All()) do
        Cleanup.Session(id, 'resource_stopping')
    end
    for id in pairs(Tables.All()) do
        Cleanup.Table(id, 'resource_stopping')
    end
end)

AddEventHandler('tarot:server:internalExpireTable', function(tableId)
    Cleanup.Table(tableId, 'table_expired')
end)

AddEventHandler('tarot:server:internalTimeoutSession', function(sessionId, reason)
    Cleanup.Session(sessionId, reason)
end)
