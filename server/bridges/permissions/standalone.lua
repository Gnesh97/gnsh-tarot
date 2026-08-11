RegisterTarotServerBridge('permissions', 'standalone', {
    IsReaderAllowed = function(src)
        return Config.AllowEveryoneToRead
    end,

    IsAdmin = function(src)
        return IsPlayerAceAllowed(src, Config.AdminAcePermission)
    end,
})
