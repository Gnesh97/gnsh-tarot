RegisterTarotClientBridge('notification', 'native', {
    Detect = function()
        return true -- last resort in CLIENT_NOTIFICATION priority order
    end,

    Notify = function(message)
        BeginTextCommandThefeedPost('STRING')
        AddTextComponentSubstringPlayerName(message)
        EndTextCommandThefeedPostTicker(false, true)
    end,
})
