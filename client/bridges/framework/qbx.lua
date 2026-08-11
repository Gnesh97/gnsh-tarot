RegisterTarotClientBridge('framework', 'qbx', {
    Detect = function()
        return GetResourceState(Config.ResourceNames.Qbox) == 'started'
    end,

    OpenPlayerSelection = function(maxDistance, callback)
        TarotBridgeUtils.SelectPlayer(maxDistance, callback)
    end,
})
