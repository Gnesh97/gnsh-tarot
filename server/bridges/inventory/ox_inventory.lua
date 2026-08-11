RegisterTarotServerBridge('inventory', 'ox_inventory', {
    Detect = function()
        return GetResourceState(Config.ResourceNames.OxInventory) == 'started'
    end,

    HasItem = function(src, item, amount)
        local count = exports[Config.ResourceNames.OxInventory]:Search(src, 'count', item)
        return (count or 0) >= (amount or 1)
    end,

    RemoveItem = function(src, item, amount)
        return exports[Config.ResourceNames.OxInventory]:RemoveItem(src, item, amount or 1)
    end,

    AddItem = function(src, item, amount)
        return exports[Config.ResourceNames.OxInventory]:AddItem(src, item, amount or 1)
    end,
})
