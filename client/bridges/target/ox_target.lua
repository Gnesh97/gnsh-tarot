local registered = {}

RegisterTarotClientBridge('target', 'ox_target', {
    Detect = function()
        return GetResourceState(Config.ResourceNames.OxTarget) == 'started'
    end,

    AddTargetEntity = function(entity, options)
        local oxOptions = {}
        for i, option in ipairs(options) do
            oxOptions[i] = {
                name = ('tarot_option_%d'):format(i),
                icon = option.icon,
                label = option.label,
                distance = Config.TableInteractionDistance,
                canInteract = option.canInteract,
                onSelect = option.action,
            }
        end

        exports[Config.ResourceNames.OxTarget]:addLocalEntity(entity, oxOptions)
        registered[entity] = true
    end,

    RemoveTargetEntity = function(entity)
        if registered[entity] then
            exports[Config.ResourceNames.OxTarget]:removeLocalEntity(entity)
            registered[entity] = nil
        end
    end,
})
