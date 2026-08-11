-- Ambient sound toggle. No-ops cleanly when the sound bridge is 'none'
-- (Bridge.StartAmbientSound/StopAmbientSound are then empty functions).

TarotSound = {}

local activeTables = {}

function TarotSound.ToggleAmbient(tableId, entity)
    if entity == nil or not DoesEntityExist(entity) then return end
    if activeTables[tableId] then
        Bridge.StopAmbientSound(tableId)
        activeTables[tableId] = nil
    else
        Bridge.StartAmbientSound(tableId, entity)
        activeTables[tableId] = true
    end
end

function TarotSound.StopAll()
    for tableId in pairs(activeTables) do
        Bridge.StopAmbientSound(tableId)
    end
    activeTables = {}
end

RegisterNetEvent('tarot:client:tableRemoved', function(data)
    if activeTables[data.tableId] then
        Bridge.StopAmbientSound(data.tableId)
        activeTables[data.tableId] = nil
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    TarotSound.StopAll()
end)
