-- Table registry: ownership, per-player limit, lifetime expiry, state bags.
-- State bags carry only public non-secret metadata (id/owner/busy/session
-- state) — never card data, per architecture rule 1.

Tables = {}

local registry = {}
local ownerTableCount = {}

function Tables.Create(owner, coords, heading, entity, compositeEntities, netId)
    local id = Utils.GenerateId('table')
    registry[id] = {
        id = id,
        owner = owner,
        coords = coords,
        heading = heading,
        entity = entity,
        netId = netId or NetworkGetNetworkIdFromEntity(entity),
        compositeEntities = compositeEntities or {},
        busy = false,
        sessionId = nil,
        createdAt = os.time(),
    }

    ownerTableCount[owner] = (ownerTableCount[owner] or 0) + 1

    if DoesEntityExist(entity) then
        Entity(entity).state:set('tarot:id', id, true)
        Entity(entity).state:set('tarot:owner', owner, true)
        Entity(entity).state:set('tarot:busy', false, true)
        Entity(entity).state:set('tarot:sessionState', 'idle', true)
    end

    return registry[id]
end

function Tables.Get(id)
    return registry[id]
end

function Tables.CountForOwner(owner)
    return ownerTableCount[owner] or 0
end

function Tables.SetBusy(id, busy, sessionId)
    local tableEntry = registry[id]
    if tableEntry == nil then return end

    tableEntry.busy = busy
    tableEntry.sessionId = busy and sessionId or nil

    if DoesEntityExist(tableEntry.entity) then
        Entity(tableEntry.entity).state:set('tarot:busy', busy, true)
        Entity(tableEntry.entity).state:set('tarot:sessionState', busy and 'active' or 'idle', true)
    end
end

function Tables.IsEntityValid(id)
    local tableEntry = registry[id]
    return tableEntry ~= nil
        and tableEntry.entity ~= 0
        and DoesEntityExist(tableEntry.entity)
end

function Tables.Remove(id)
    local tableEntry = registry[id]
    if tableEntry == nil then return end

    ownerTableCount[tableEntry.owner] = math.max(0, (ownerTableCount[tableEntry.owner] or 1) - 1)
    registry[id] = nil
end

function Tables.All()
    return registry
end

function Tables.FindByOwner(owner)
    local owned = {}
    for id, tableEntry in pairs(registry) do
        if tableEntry.owner == owner then
            owned[#owned + 1] = tableEntry
        end
    end
    return owned
end

function Tables.FindByNetId(netId)
    for id, tableEntry in pairs(registry) do
        if tableEntry.netId == netId then
            return id
        end
    end
    return nil
end

-- Lifetime expiry sweep: runs at low frequency, expires idle unused tables.
CreateThread(function()
    while true do
        Wait(60000)
        local now = os.time()
        local expirySeconds = Config.TableLifetimeMinutes * 60

        for id, tableEntry in pairs(registry) do
            if not tableEntry.busy and (now - tableEntry.createdAt) >= expirySeconds then
                TriggerEvent('tarot:server:internalExpireTable', id)
            end
        end
    end
end)
