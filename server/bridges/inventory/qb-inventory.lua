local function core()
    return exports[Config.ResourceNames.QBCore]:GetCoreObject()
end

RegisterTarotServerBridge('inventory', 'qb-inventory', {
    Detect = function()
        return GetResourceState(Config.ResourceNames.QbInventory) == 'started'
            and GetResourceState(Config.ResourceNames.QBCore) == 'started'
    end,

    HasItem = function(src, item, amount)
        local player = core().Functions.GetPlayer(src)
        if player == nil then return false end
        local itemData = player.Functions.GetItemByName(item)
        return itemData ~= nil and itemData.amount >= (amount or 1)
    end,

    RemoveItem = function(src, item, amount)
        local player = core().Functions.GetPlayer(src)
        if player == nil then return false end
        return player.Functions.RemoveItem(item, amount or 1)
    end,

    AddItem = function(src, item, amount)
        local player = core().Functions.GetPlayer(src)
        if player == nil then return false end
        return player.Functions.AddItem(item, amount or 1)
    end,
})
