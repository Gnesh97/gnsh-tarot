RegisterTarotClientBridge('notification', 'qb', {
    Detect = function()
        return GetResourceState(Config.ResourceNames.QBCore) == 'started'
    end,

    Notify = function(message)
        TriggerEvent('QBCore:Notify', message)
    end,
})
