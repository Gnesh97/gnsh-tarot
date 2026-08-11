RegisterTarotServerBridge('permissions', 'ace', {
    IsReaderAllowed = function(src)
        if Config.AllowEveryoneToRead then return true end
        return IsPlayerAceAllowed(src, Config.ReaderAcePermission)
    end,

    IsAdmin = function(src)
        return IsPlayerAceAllowed(src, Config.AdminAcePermission)
    end,
})
