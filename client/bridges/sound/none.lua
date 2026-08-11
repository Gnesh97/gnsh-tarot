RegisterTarotClientBridge('sound', 'none', {
    Detect = function()
        return true -- last resort in CLIENT_SOUND priority order
    end,

    StartAmbientSound = function(tableId, entity) end,
    StopAmbientSound = function(tableId) end,
})
