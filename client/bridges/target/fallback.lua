-- No real target system: client/interaction.lua's own 3D-text + E-key loop
-- handles prompts when Bridge.TargetBridgeName == 'fallback', so these are
-- no-ops that exist only to satisfy the Bridge contract.

RegisterTarotClientBridge('target', 'fallback', {
    Detect = function()
        return true -- last resort in CLIENT_TARGET priority order
    end,

    AddTargetEntity = function(entity, options) end,
    RemoveTargetEntity = function(entity) end,
})
