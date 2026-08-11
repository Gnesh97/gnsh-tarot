local registered = {}

RegisterTarotClientBridge('target', 'qb-target', {
    Detect = function()
        return GetResourceState(Config.ResourceNames.QbTarget) == 'started'
    end,

    AddTargetEntity = function(entity, options)
        local qbOptions = {}
        for i, option in ipairs(options) do
            qbOptions[i] = {
                icon = option.icon,
                label = option.label,
                canInteract = option.canInteract,
                action = option.action,
            }
        end

        exports[Config.ResourceNames.QbTarget]:AddTargetEntity(entity, {
            options = qbOptions,
            distance = Config.TableInteractionDistance,
        })
        registered[entity] = true
    end,

    RemoveTargetEntity = function(entity)
        if registered[entity] then
            exports[Config.ResourceNames.QbTarget]:RemoveTargetEntity(entity)
            registered[entity] = nil
        end
    end,
})
