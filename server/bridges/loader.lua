-- Bridge selection. Runs first in server_scripts so RegisterTarotServerBridge
-- exists before framework/inventory/permissions files register into it. The
-- actual pick happens on this resource's own onResourceStart, which fires
-- after every script in the manifest has finished loading synchronously.
-- Manual Config value always wins over 'auto' probing.

TarotServerBridges = { framework = {}, inventory = {}, permissions = {} }
Bridge = {}

function RegisterTarotServerBridge(category, name, impl)
    TarotServerBridges[category] = TarotServerBridges[category] or {}
    TarotServerBridges[category][name] = impl
end

local function resolve(category, configValue, priorityList)
    if configValue ~= 'auto' then
        return TarotServerBridges[category][configValue], configValue
    end

    for _, name in ipairs(priorityList) do
        local impl = TarotServerBridges[category][name]
        if impl ~= nil and (impl.Detect == nil or impl.Detect()) then
            return impl, name
        end
    end

    return nil, nil
end

local function applyBridge(target, impl)
    if impl == nil then return end
    for fnName, fn in pairs(impl) do
        if fnName ~= 'Detect' then
            target[fnName] = fn
        end
    end
end

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    local frameworkImpl, frameworkName = resolve('framework', Config.Framework, BridgeCategories.SERVER_FRAMEWORK)
    if frameworkImpl == nil and Config.AllowStandaloneFallback then
        frameworkImpl, frameworkName = TarotServerBridges.framework.standalone, 'standalone'
    end
    applyBridge(Bridge, frameworkImpl)

    local inventoryImpl, inventoryName = resolve('inventory', Config.Inventory, BridgeCategories.SERVER_INVENTORY)
    if inventoryImpl == nil and Config.AllowStandaloneFallback then
        inventoryImpl = TarotServerBridges.inventory.standalone
        inventoryName = 'standalone'
    end
    applyBridge(Bridge, inventoryImpl)

    local permissionsCategory = 'framework'
    if Config.UseAcePermission then
        permissionsCategory = 'ace'
    elseif frameworkName == 'standalone' then
        permissionsCategory = 'standalone'
    end
    applyBridge(Bridge, TarotServerBridges.permissions[permissionsCategory])

    Utils.Debug(('bridges resolved: framework=%s inventory=%s permissions=%s'):format(tostring(frameworkName), tostring(inventoryName), permissionsCategory))
end)
