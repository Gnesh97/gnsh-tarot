-- Reader gate driven by Config.AllowEveryoneToRead / Config.ReaderJobs, using
-- whichever framework bridge already supplied Bridge.GetJob. Admin check
-- always falls back to ace since job lists don't imply server-admin status.

RegisterTarotServerBridge('permissions', 'framework', {
    IsReaderAllowed = function(src)
        if Config.AllowEveryoneToRead then return true end
        if Bridge.GetJob == nil then return false end

        local job = Bridge.GetJob(src)
        if job == nil then return false end

        local minimumGrade = Config.ReaderJobs[job.name]
        return minimumGrade ~= nil and job.grade >= minimumGrade
    end,

    IsAdmin = function(src)
        return IsPlayerAceAllowed(src, Config.AdminAcePermission)
    end,
})
