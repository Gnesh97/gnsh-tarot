-- Add to ox_inventory/data/items.lua. Only needed if Config.Inventory
-- resolves to 'ox_inventory' and Config.RequireTableItem = true.

['tarot_table'] = {
    label = 'Tarot Masası',
    weight = 4000,
    stack = false,
    close = true,
    description = 'Katlanabilir bir tarot falı masası.',
    client = {
        image = 'tarot_table.png'
    }
},
