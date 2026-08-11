-- Table placement/removal. Ground/surface validation and prop spawn happen
-- client-side (visual only); the server is still the one who assigns the
-- authoritative tableId and owns the registry (server/tables.lua).

TarotTables = {}

local placedEntities = {} -- tableId -> {entity, compositeEntities}
local remoteEntities = {} -- tableId -> {entity}; never deleted by this client
local pendingPlacement = false

local function loadModel(model)
    local hash = type(model) == 'string' and GetHashKey(model) or model
    if not IsModelValid(hash) then return nil end

    RequestModel(hash)
    local start = GetGameTimer()
    while not HasModelLoaded(hash) do
        Wait(0)
        if (GetGameTimer() - start) > Config.ModelLoadTimeoutMs then
            return nil
        end
    end
    return hash
end

local function findGroundZ(coords)
    local found, z = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z + 5.0, false)
    if found then return z end
    return coords.z
end

function TarotTables.BeginPlacement()
    if pendingPlacement then return end

    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        Bridge.Notify(_L('table_in_vehicle'))
        return
    end

    pendingPlacement = true

    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    local forward = GetEntityForwardVector(ped)
    local spawnDistance = Config.TableSpawnDistance or 1.5
    local frontCoords = vector3(coords.x + forward.x * spawnDistance, coords.y + forward.y * spawnDistance, coords.z)
    local groundZ = findGroundZ(frontCoords)

    local placeCoords = vector3(frontCoords.x, frontCoords.y, groundZ)
    TriggerServerEvent('tarot:server:placeTable', placeCoords, heading)
    pendingPlacement = false
end

RegisterNetEvent('tarot:client:beginPlacement', function()
    TarotTables.BeginPlacement()
end)

function TarotTables.GetEntity(tableId)
    local entry = placedEntities[tableId]
    if entry ~= nil then return entry.entity end
    local remoteEntry = remoteEntities[tableId]
    return remoteEntry and remoteEntry.entity or nil
end

function TarotTables.GetEntityByNetId(netId)
    if type(netId) ~= 'number' or netId <= 0 then return nil end
    local entity = NetworkGetEntityFromNetworkId(netId)
    return entity ~= 0 and DoesEntityExist(entity) and entity or nil
end

-- The interaction registry can briefly lag behind the table registration
-- event. Commands such as /tarotbasla still need to find the local owner's
-- table during that window, so discover it from the replicated state bag.
function TarotTables.GetNearestOwned(maxDistance)
    local playerId = GetPlayerServerId(PlayerId())
    local origin = GetEntityCoords(PlayerPedId())
    local limit = tonumber(maxDistance) or (Config.TableInteractionDistance + 0.01)
    local nearest = nil

    for tableId, entry in pairs(placedEntities) do
        if type(tableId) == 'string'
            and not tableId:find('__pending_', 1, true)
            and entry ~= nil
            and DoesEntityExist(entry.entity) then
            local owner = tonumber(Entity(entry.entity).state['tarot:owner'])
            -- placedEntities only contains tables created by this client. If
            -- the owner state bag has not arrived locally yet, the local
            -- placement itself is still a safe ownership signal.
            if owner == playerId or owner == nil then
                local distance = #(origin - GetEntityCoords(entry.entity))
                if distance <= limit and (nearest == nil or distance < nearest.distance) then
                    nearest = { tableId = tableId, entity = entry.entity, distance = distance }
                end
            end
        end
    end

    return nearest
end

RegisterNetEvent('tarot:client:spawnTable', function(data)
    local coords = data.coords
    local heading = data.heading

    local tableModel = Config.TableModel
    if Config.UseCompositeProps and Config.CompositeProps and Config.CompositeProps.table then
        tableModel = Config.CompositeProps.table.model
    end

    local mainHash = loadModel(tableModel)
    if mainHash == nil and type(Config.TableFallbackModel) == 'string' and Config.TableFallbackModel ~= tableModel then
        mainHash = loadModel(Config.TableFallbackModel)
    end
    if mainHash == nil then
        print(('[tarot] table spawn failed: model did not load (tried %s, fallback %s)'):format(tostring(tableModel), tostring(Config.TableFallbackModel)))
        Bridge.Notify(_L('table_bad_surface'))
        TriggerServerEvent('tarot:server:cancelTablePlacement')
        return
    end

    local entity = CreateObject(mainHash, coords.x, coords.y, coords.z, true, true, false)
    if entity == 0 or not DoesEntityExist(entity) then
        print(('[tarot] table spawn failed: CreateObject returned invalid entity for hash %s'):format(tostring(mainHash)))
        SetModelAsNoLongerNeeded(mainHash)
        TriggerServerEvent('tarot:server:cancelTablePlacement')
        Bridge.Notify(_L('table_bad_surface'))
        return
    end
    PlaceObjectOnGroundProperly(entity)
    SetEntityHeading(entity, heading)
    FreezeEntityPosition(entity, true)
    SetModelAsNoLongerNeeded(mainHash)

    local compositeEntities = {}
    if Config.UseCompositeProps then
        for key, propDef in pairs(Config.CompositeProps) do
            if key ~= 'table' then
            local hash = loadModel(propDef.model)
            if hash ~= nil then
                local offset = propDef.offset
                local propCoords = GetOffsetFromEntityInWorldCoords(entity, offset.x, offset.y, offset.z)
                local propEntity = CreateObject(hash, propCoords.x, propCoords.y, propCoords.z, true, true, false)
                SetEntityHeading(propEntity, heading + (offset.heading or 0.0))
                AttachEntityToEntity(propEntity, entity, 0, offset.x, offset.y, offset.z, 0.0, 0.0, offset.heading or 0.0, false, false, false, false, 2, true)
                FreezeEntityPosition(propEntity, true)
                SetModelAsNoLongerNeeded(hash)
               compositeEntities[key] = propEntity
            end
            end
        end
    end

    local compositeNetIds = {}
    for key, propEntity in pairs(compositeEntities) do
        compositeNetIds[key] = NetworkGetNetworkIdFromEntity(propEntity)
    end

    TriggerServerEvent('tarot:server:confirmTablePlaced', coords, heading, NetworkGetNetworkIdFromEntity(entity), compositeNetIds)

    -- Registry keyed on entity handle until the server hands back a tableId.
    placedEntities['__pending_' .. entity] = { entity = entity, compositeEntities = compositeEntities }
end)

RegisterNetEvent('tarot:client:tableRegistered', function(data)
    if type(data) ~= 'table' or not Utils.IsValidTableId(data.tableId) then return end
    remoteEntities[data.tableId] = nil
    for key, pending in pairs(placedEntities) do
        if type(key) == 'string' and key:find('__pending_') and pending.tableId == nil then
            pending.tableId = data.tableId
            placedEntities[data.tableId] = pending
            placedEntities[key] = nil
            TarotInteraction.RegisterTable(data.tableId, pending.entity)
            return
        end
    end
end)

local function removeEntry(tableId)
    local entry = placedEntities[tableId]
    if entry == nil then return end

    TarotInteraction.RemoveTable(tableId)

    if DoesEntityExist(entry.entity) then
        DeleteEntity(entry.entity)
    end
    for _, propEntity in pairs(entry.compositeEntities or {}) do
        if DoesEntityExist(propEntity) then
            DeleteEntity(propEntity)
        end
    end

    placedEntities[tableId] = nil
end

local function removeRemoteEntry(tableId)
    local entry = remoteEntities[tableId]
    if entry == nil then return end
    TarotInteraction.RemoveTable(tableId)
    remoteEntities[tableId] = nil
end

RegisterNetEvent('tarot:client:tableRegisteredBroadcast', function(data)
    if type(data) ~= 'table' or not Utils.IsValidTableId(data.tableId) or type(data.netId) ~= 'number' then return end
    if placedEntities[data.tableId] ~= nil or remoteEntities[data.tableId] ~= nil then return end

    CreateThread(function()
        local deadline = GetGameTimer() + Config.ModelLoadTimeoutMs
        local entity = TarotTables.GetEntityByNetId(data.netId)
        while entity == nil and GetGameTimer() < deadline do
            Wait(100)
            entity = TarotTables.GetEntityByNetId(data.netId)
        end
        if entity == nil then
            print(('[tarot] table %s: could not resolve netId %s on this client (timed out) - table will not be interactable here'):format(tostring(data.tableId), tostring(data.netId)))
            return
        end
        if placedEntities[data.tableId] ~= nil or remoteEntities[data.tableId] ~= nil then return end
        remoteEntities[data.tableId] = { entity = entity }
        TarotInteraction.RegisterTable(data.tableId, entity)
        print(('[tarot] table %s registered locally via broadcast'):format(tostring(data.tableId)))
    end)
end)

RegisterNetEvent('tarot:client:tablePlacementRejected', function()
    for key, pending in pairs(placedEntities) do
        if type(key) == 'string' and key:find('__pending_') then
            if DoesEntityExist(pending.entity) then
                DeleteEntity(pending.entity)
            end
            for _, propEntity in pairs(pending.compositeEntities or {}) do
                if DoesEntityExist(propEntity) then
                    DeleteEntity(propEntity)
                end
            end
            placedEntities[key] = nil
        end
    end
end)

RegisterNetEvent('tarot:client:tableRemoved', function(data)
    removeEntry(data.tableId)
    removeRemoteEntry(data.tableId)
end)

RegisterNetEvent('tarot:client:tableRemovedBroadcast', function(data)
    removeEntry(data.tableId)
    removeRemoteEntry(data.tableId)
end)

function TarotTables.RequestRemoval(tableId)
    TriggerServerEvent('tarot:server:removeTable', tableId)
end

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    for tableId in pairs(placedEntities) do
        removeEntry(tableId)
    end
    for tableId in pairs(remoteEntities) do
        removeRemoteEntry(tableId)
    end
end)
