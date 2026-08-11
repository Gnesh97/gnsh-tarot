RegisterTarotServerBridge('framework', 'standalone', {
    Detect = function()
        return false -- only ever picked as explicit Config.Framework value or AllowStandaloneFallback
    end,

    GetPlayer = function(src)
        return nil
    end,

    GetIdentifier = function(src)
        return GetPlayerIdentifierByType(src, 'license') or tostring(src)
    end,

    GetName = function(src)
        return GetPlayerName(src)
    end,

    GetJob = function(src)
        return nil
    end,

    Notify = function(src, message)
        TriggerClientEvent('chat:addMessage', src, { args = { message } })
    end,
})
