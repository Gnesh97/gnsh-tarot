local function core()
    return exports[Config.ResourceNames.QBCore]:GetCoreObject()
end

CreateThread(function()
    while GetResourceState(Config.ResourceNames.QBCore) ~= 'started' do
        Wait(500)
    end

    local qb = core()
    if qb.Functions.CreateUseableItem == nil then return end
    qb.Functions.CreateUseableItem(Config.TableItem, function(src)
        TriggerClientEvent('tarot:client:beginPlacement', src)
    end)
end)

RegisterTarotServerBridge('framework', 'qb', {
    Detect = function()
        return GetResourceState(Config.ResourceNames.QBCore) == 'started'
    end,

    GetPlayer = function(src)
        return core().Functions.GetPlayer(src)
    end,

    GetIdentifier = function(src)
        local player = core().Functions.GetPlayer(src)
        return player and player.PlayerData.citizenid or nil
    end,

    GetName = function(src)
        local player = core().Functions.GetPlayer(src)
        if player == nil then return GetPlayerName(src) end
        local info = player.PlayerData.charinfo
        return ('%s %s'):format(info.firstname, info.lastname)
    end,

    GetJob = function(src)
        local player = core().Functions.GetPlayer(src)
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
