-- Client bridge selection, mirrors server/bridges/loader.lua. Runs first in
-- client_scripts; actual pick happens on this resource's onClientResourceStart
-- so every bridge file below it has already registered by then.

TarotClientBridges = { framework = {}, target = {}, notification = {}, sound = {} }
Bridge = {}

function RegisterTarotClientBridge(category, name, impl)
    TarotClientBridges[category] = TarotClientBridges[category] or {}
    TarotClientBridges[category][name] = impl
end

-- Shared nearest-player picker used by every framework bridge's
-- OpenPlayerSelection, so the list-menu-vs-nearest-player tradeoff lives in
-- one place instead of being duplicated per framework.
TarotBridgeUtils = {}

function TarotBridgeUtils.NearestPlayer(maxDistance)
    local myPed = PlayerPedId()
    local myCoords = GetEntityCoords(myPed)
    local myServerId = GetPlayerServerId(PlayerId())

    local nearestId, nearestDistance = nil, maxDistance
    for _, playerId in ipairs(GetActivePlayers()) do
        local serverId = GetPlayerServerId(playerId)
        if serverId ~= myServerId then
            local ped = GetPlayerPed(playerId)
            local distance = #(myCoords - GetEntityCoords(ped))
            if distance <= nearestDistance then
                nearestId, nearestDistance = serverId, distance
            end
        end
    end

    return nearestId
end

-- Every framework bridge's OpenPlayerSelection delegates here so the
-- list-menu-vs-nearest-player tradeoff lives in one place. 'list' mode shows
-- the NUI player picker (see TarotNui.ShowPlayerSelection); it resolves
-- asynchronously, so this always calls back rather than returning.
function TarotBridgeUtils.SelectPlayer(maxDistance, callback)
    if Config.PlayerSelectionMode == 'list' then
        TarotNui.ShowPlayerSelection(maxDistance, callback)
        return
    end
    callback(TarotBridgeUtils.NearestPlayer(maxDistance))
end

local function resolve(category, configValue, priorityList)
    if configValue ~= 'auto' then
        return TarotClientBridges[category][configValue], configValue
    end

    for _, name in ipairs(priorityList) do
        local impl = TarotClientBridges[category][name]
        if impl ~= nil and (impl.Detect == nil or impl.Detect()) then
            return impl, name
        end
    end

    return nil, nil
end

local function applyBridge(target, impl)
    if impl == nil then return end
    for fnName, fn in pairs(impl) do
        if fnName ~= 'Detect' then
            target[fnName] = fn
        end
    end
end

AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    local frameworkImpl, frameworkName = resolve('framework', Config.Framework, BridgeCategories.CLIENT_FRAMEWORK)
    if frameworkImpl == nil and Config.AllowStandaloneFallback then
        frameworkImpl, frameworkName = TarotClientBridges.framework.standalone, 'standalone'
    end
    applyBridge(Bridge, frameworkImpl)

    local targetImpl, targetName = resolve('target', Config.TargetSystem, BridgeCategories.CLIENT_TARGET)
    if targetImpl == nil then
        targetImpl, targetName = TarotClientBridges.target.fallback, 'fallback'
    end
    applyBridge(Bridge, targetImpl)
    Bridge.TargetBridgeName = targetName

    local notificationImpl, notificationName = resolve('notification', Config.NotificationSystem, BridgeCategories.CLIENT_NOTIFICATION)
    if notificationImpl == nil then
        notificationImpl = TarotClientBridges.notification.native
        notificationName = 'native'
    end
    applyBridge(Bridge, notificationImpl)

    local soundImpl, soundName = resolve('sound', Config.SoundSystem, BridgeCategories.CLIENT_SOUND)
    if soundImpl == nil then
        soundImpl = TarotClientBridges.sound.none
        soundName = 'none'
    end
    applyBridge(Bridge, soundImpl)

    Utils.Debug(('client bridges resolved: framework=%s target=%s notification=%s sound=%s'):format(tostring(frameworkName), tostring(targetName), tostring(notificationName), tostring(soundName)))
end)
