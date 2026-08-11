-- Template for a custom inventory integration. Never auto-detected — pick it
-- explicitly with Config.Inventory = 'custom' and fill in the three exports.

RegisterTarotServerBridge('inventory', 'custom', {
    Detect = function()
        return false
    end,

    HasItem = function(src, item, amount)
        -- return exports['your-inventory']:HasItem(src, item, amount or 1)
        return true
    end,

    RemoveItem = function(src, item, amount)
        -- return exports['your-inventory']:RemoveItem(src, item, amount or 1)
        return true
    end,

    AddItem = function(src, item, amount)
        -- return exports['your-inventory']:AddItem(src, item, amount or 1)
        return true
    end,
})
