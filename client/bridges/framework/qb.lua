RegisterTarotClientBridge('framework', 'qb', {
    Detect = function()
        return GetResourceState(Config.ResourceNames.QBCore) == 'started'
    end,

    OpenPlayerSelection = function(maxDistance, callback)
        TarotBridgeUtils.SelectPlayer(maxDistance, callback)
    end,
})
