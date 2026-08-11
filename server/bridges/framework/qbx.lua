local function core()
    return exports[Config.ResourceNames.Qbox]
end

RegisterTarotServerBridge('framework', 'qbx', {
    Detect = function()
        return GetResourceState(Config.ResourceNames.Qbox) == 'started'
    end,

    GetPlayer = function(src)
        return core():GetPlayer(src)
    end,

    GetIdentifier = function(src)
        local player = core():GetPlayer(src)
        return player and player.PlayerData.citizenid or nil
    end,

    GetName = function(src)
        local player = core():GetPlayer(src)
        if player == nil then return GetPlayerName(src) end
        local info = player.PlayerData.charinfo
        return ('%s %s'):format(info.firstname, info.lastname)
    end,

    GetJob = function(src)
        local player = core():GetPlayer(src)
        if player == nil or player.PlayerData.job == nil then return nil end
        local job = player.PlayerData.job
        return {
            name = job.name,
            grade = tonumber(job.grade and (job.grade.level or job.grade)) or 0,
        }
    end,

    Notify = function(src, message)
        TriggerClientEvent('QBCore:Notify', src, message)
    end,
})
