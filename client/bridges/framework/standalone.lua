RegisterTarotClientBridge('framework', 'standalone', {
    Detect = function()
        return false -- only via explicit Config.Framework value or AllowStandaloneFallback
    end,

    OpenPlayerSelection = function(maxDistance, callback)
        TarotBridgeUtils.SelectPlayer(maxDistance, callback)
    end,
})
