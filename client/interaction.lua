-- Target registration via Bridge.AddTargetEntity, plus a no-target fallback:
-- an adaptive-sleep loop drawing 3D text and reading Config.InteractionKey.
-- Sleep drops to 0 only while standing near a registered table.

TarotInteraction = {}

local registeredTables = {} -- tableId -> {entity = entity}
local function myServerId()
    return GetPlayerServerId(PlayerId())
end

local function isOwner(entity)
    return tonumber(Entity(entity).state['tarot:owner']) == myServerId()
end

local function isBusy(entity)
    return Entity(entity).state['tarot:busy'] == true
end

local function activeSession(tableId)
    local session = TarotSessions.Current()
    if session == nil or session.id == nil or session.tableId ~= tableId then return nil end
    return session
end

local function beginReadingFlow(tableId)
    Bridge.OpenPlayerSelection(Config.CustomerSearchDistance, function(targetServerId)
        if targetServerId == nil then return end
        TarotSessions.StartReading(tableId, targetServerId)
    end)
end

function TarotInteraction.StartReadingNearest()
    local myCoords = GetEntityCoords(PlayerPedId())
    local nearestId = nil
    local nearestDistance = Config.TableInteractionDistance + 0.01

    for tableId, entry in pairs(registeredTables) do
        if DoesEntityExist(entry.entity) and isOwner(entry.entity) then
            local distance = #(myCoords - GetEntityCoords(entry.entity))
            if distance <= nearestDistance then
                nearestId = tableId
                nearestDistance = distance
            end
        end
    end

    -- Use the authoritative local table registry as a fallback when the
    -- interaction target registration arrives a tick after table creation.
    if nearestId == nil and TarotTables.GetNearestOwned ~= nil then
        local discovered = TarotTables.GetNearestOwned(nearestDistance)
        if discovered ~= nil then
            nearestId = discovered.tableId
        end
    end

    if nearestId ~= nil then
        beginReadingFlow(nearestId)
        return
    end

    Bridge.Notify(_L('table_not_found'))
end

RegisterCommand('tarotbasla', function()
    TarotInteraction.StartReadingNearest()
end, false)

local function buildOptions(tableId, entity)
    return {
        {
            label = _L('target_start_reading'),
            icon = 'fa-solid fa-hand-sparkles',
            canInteract = function() return isOwner(entity) and not isBusy(entity) end,
            action = function() beginReadingFlow(tableId) end,
        },
        {
            label = _L('target_remove_table'),
            icon = 'fa-solid fa-box',
            canInteract = function() return not isBusy(entity) end,
            action = function() TarotTables.RequestRemoval(tableId) end,
        },
        {
            label = _L('target_toggle_ambient'),
            icon = 'fa-solid fa-music',
            canInteract = function() return isOwner(entity) end,
            action = function() TarotSound.ToggleAmbient(tableId, entity) end,
        },
        {
            label = _L('target_end_reading'),
            icon = 'fa-solid fa-xmark',
            canInteract = function()
                local session = TarotSessions.Current()
                return isOwner(entity)
                    and isBusy(entity)
                    and session ~= nil
                    and session.id ~= nil
                    and session.tableId == tableId
            end,
            action = function() TarotSessions.Close() end,
        },
        {
            label = _L('target_sit_at_table'),
            icon = 'fa-solid fa-chair',
            canInteract = function() return not isOwner(entity) and activeSession(tableId) ~= nil end,
            action = function() TarotSeating.SitAsCustomer(entity) end,
        },
        {
            label = _L('target_focus_reading'),
            icon = 'fa-solid fa-eye',
            canInteract = function()
                local session = activeSession(tableId)
                return not isOwner(entity) and session ~= nil and session.state ~= 'accepted'
            end,
            action = function() TarotNui.RenderSnapshot(activeSession(tableId)) end,
        },
        {
            label = _L('target_stand_up'),
            icon = 'fa-solid fa-person-walking',
            canInteract = function() return activeSession(tableId) ~= nil end,
            action = function() TarotSeating.StandUp() end,
        },

    }
end

function TarotInteraction.RegisterTable(tableId, entity)
    if registeredTables[tableId] ~= nil then
        if registeredTables[tableId].entity == entity then return end
        TarotInteraction.RemoveTable(tableId)
    end
    registeredTables[tableId] = { entity = entity }

    if Bridge.AddTargetEntity ~= nil then
        Bridge.AddTargetEntity(entity, buildOptions(tableId, entity))
    end
end

function TarotInteraction.RemoveTable(tableId)
    local entry = registeredTables[tableId]
    if entry == nil then return end

    if Bridge.RemoveTargetEntity ~= nil then
        Bridge.RemoveTargetEntity(entry.entity)
    end

    registeredTables[tableId] = nil
end

if Config.EnableInteractionFallback then
    CreateThread(function()
        while Bridge.TargetBridgeName == nil do
            Wait(0) -- bridges resolve on onClientResourceStart, right after this file's top level runs
        end
        if Bridge.TargetBridgeName ~= 'fallback' then return end

        while true do
            local sleep = 1000
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local nearestId, nearestEntity, nearestDistance = nil, nil, Config.TableInteractionDistance + 1.0

            for tableId, entry in pairs(registeredTables) do
                if DoesEntityExist(entry.entity) then
                    local distance = #(coords - GetEntityCoords(entry.entity))
                    if distance <= Config.TableInteractionDistance and distance < nearestDistance then
                        nearestId, nearestEntity, nearestDistance = tableId, entry.entity, distance
                    end
                end
            end

            if nearestEntity ~= nil then
                sleep = 0
                local options = buildOptions(nearestId, nearestEntity)
                local available = nil
                for _, option in ipairs(options) do
                    if option.canInteract() then
                        available = option
                        break
                    end
                end

                if available ~= nil then
                    local entCoords = GetEntityCoords(nearestEntity)
                    BeginTextCommandDisplayHelp('STRING')
                    AddTextComponentSubstringPlayerName(('[E] %s'):format(available.label))
                    EndTextCommandDisplayHelp(0, false, false, -1)

                    if IsControlJustReleased(0, Config.InteractionKey) then
                        available.action()
                    end
                end
            end

            Wait(sleep)
        end
    end)
end
