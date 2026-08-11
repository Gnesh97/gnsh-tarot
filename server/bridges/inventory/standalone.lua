-- No real inventory backing: table item requirement should stay disabled
-- (Config.RequireTableItem = false) when this bridge is active. HasItem
-- always allows so a misconfigured server does not hard-lock the feature.

RegisterTarotServerBridge('inventory', 'standalone', {
    Detect = function()
        return false
    end,

    HasItem = function(src, item, amount)
        return true
    end,

    RemoveItem = function(src, item, amount)
        return true
    end,

    AddItem = function(src, item, amount)
        return true
    end,
})
