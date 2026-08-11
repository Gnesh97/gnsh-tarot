RegisterTarotClientBridge('notification', 'esx', {
    Detect = function()
        return GetResourceState(Config.ResourceNames.ESX) == 'started'
    end,

    Notify = function(message)
        TriggerEvent('esx:showNotification', message)
    end,
})
