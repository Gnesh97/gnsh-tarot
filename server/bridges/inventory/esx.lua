local function core()
    return exports[Config.ResourceNames.ESX]:getSharedObject()
end

RegisterTarotServerBridge('inventory', 'esx', {
    Detect = function()
        return GetResourceState(Config.ResourceNames.ESX) == 'started'
    end,

    HasItem = function(src, item, amount)
        local player = core().GetPlayerFromId(src)
        if player == nil then return false end
        local itemData = player.getInventoryItem(item)
        return itemData ~= nil and itemData.count >= (amount or 1)
    end,

    RemoveItem = function(src, item, amount)
        local player = core().GetPlayerFromId(src)
        if player == nil then return false end
        player.removeInventoryItem(item, amount or 1)
        return true
    end,

    AddItem = function(src, item, amount)
        local player = core().GetPlayerFromId(src)
        if player == nil then return false end
        player.addInventoryItem(item, amount or 1)
        return true
    end,
})
