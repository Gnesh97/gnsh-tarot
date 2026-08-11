RegisterTarotClientBridge('notification', 'ox_lib', {
    Detect = function()
        return GetResourceState(Config.ResourceNames.OxLib) == 'started'
    end,

    Notify = function(message)
        exports[Config.ResourceNames.OxLib]:notify({ description = message })
    end,
})
