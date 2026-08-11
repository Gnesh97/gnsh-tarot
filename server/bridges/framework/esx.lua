local function core()
    return exports[Config.ResourceNames.ESX]:getSharedObject()
end

RegisterTarotServerBridge('framework', 'esx', {
    Detect = function()
        return GetResourceState(Config.ResourceNames.ESX) == 'started'
    end,

    GetPlayer = function(src)
        return core().GetPlayerFromId(src)
    end,

    GetIdentifier = function(src)
        local player = core().GetPlayerFromId(src)
        return player and player.identifier or nil
    end,

    GetName = function(src)
        local player = core().GetPlayerFromId(src)
        if player == nil then return GetPlayerName(src) end
        return player.getName()
    end,

    GetJob = function(src)
        local player = core().GetPlayerFromId(src)
        if player == nil or player.job == nil then return nil end
        return {
            name = player.job.name,
            grade = tonumber(player.job.grade) or 0,
        }
    end,

    Notify = function(src, message)
        TriggerClientEvent('esx:showNotification', src, message)
    end,
})
