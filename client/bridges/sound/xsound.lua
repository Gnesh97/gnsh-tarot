-- xSound ambient loop. If no URL is configured (Config.AmbientSoundUrl is
-- empty, the default since no audio ships with this resource) this stays
-- silent rather than erroring, matching the graceful-degradation rule.

RegisterTarotClientBridge('sound', 'xsound', {
    Detect = function()
        return GetResourceState(Config.ResourceNames.XSound) == 'started'
    end,

    StartAmbientSound = function(tableId, entity)
        if not Config.EnableAmbientSound then return end
        if Config.AmbientSoundUrl == nil or Config.AmbientSoundUrl == '' then return end

        local coords = GetEntityCoords(entity)
        local soundId = 'tarot_' .. tableId
        exports[Config.ResourceNames.XSound]:PlayUrlPos(soundId, Config.AmbientSoundUrl, Config.AmbientVolume, coords, true)
        exports[Config.ResourceNames.XSound]:Distance(soundId, Config.AmbientDistance)
    end,

    StopAmbientSound = function(tableId)
        exports[Config.ResourceNames.XSound]:Destroy('tarot_' .. tableId)
    end,
})
