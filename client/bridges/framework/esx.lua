RegisterTarotClientBridge('framework', 'esx', {
    Detect = function()
        return GetResourceState(Config.ResourceNames.ESX) == 'started'
    end,

    OpenPlayerSelection = function(maxDistance, callback)
        TarotBridgeUtils.SelectPlayer(maxDistance, callback)
    end,
})
