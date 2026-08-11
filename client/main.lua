-- Client entry point: debug banner once bridges resolve, and the optional
-- /tarotmasa command that starts table placement (client/tables.lua owns the
-- actual placement flow — this just triggers it).

AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    CreateThread(function()
        Wait(0) -- let bridges/loader.lua's own onClientResourceStart handler run first
        Utils.Debug('client ready, framework bridge functions:', Bridge.AddTargetEntity ~= nil, Bridge.Notify ~= nil)
    end)
end)

if Config.EnableTableCommand then
    RegisterCommand(Config.TableCommand, function()
        TarotTables.BeginPlacement()
    end, false)
end
