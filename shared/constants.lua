-- =============================================================================
-- SESSION STATES
-- =============================================================================

SessionStates = {
    INVITED = 'invited',
    ACCEPTED = 'accepted',
    SPREAD_SELECTION = 'spread_selection',
    SPREAD_SELECTED = 'spread_selected',
    SHUFFLING = 'shuffling',
    DEALING = 'dealing',
    READING = 'reading',
    COMPLETED = 'completed',
    CANCELLED = 'cancelled'
}

-- =============================================================================
-- ALLOWED SPREADS / NUI ACTIONS
-- =============================================================================

AllowedSpreads = {
    three_card = true,
    horseshoe_seven = true,
    pentagram = true,
    celtic_cross = true,
    gypsy_twenty_one = true,
}

AllowedNuiActions = {
    acceptInvite = true,
    rejectInvite = true,
    selectSpread = true,
    startDeal = true,
    revealSlot = true,
    revealNext = true,
    revealAll = true,
    closeSession = true,
    requestSnapshot = true,
    selectPlayer = true,
    cancelPlayerSelection = true
}

-- =============================================================================
-- BRIDGE CATEGORIES
-- Used by client/bridges/loader.lua and server/bridges/loader.lua to know
-- which registration buckets exist and in what auto-detect priority order
-- to probe them. Bridge implementation files call RegisterTarotBridge with
-- one of these category names.
-- =============================================================================

BridgeCategories = {
    CLIENT_FRAMEWORK = { 'qbx', 'qb', 'esx', 'standalone' },
    CLIENT_TARGET = { 'ox_target', 'qb-target', 'fallback' },
    CLIENT_NOTIFICATION = { 'ox_lib', 'qb', 'esx', 'native' },
    CLIENT_SOUND = { 'xsound', 'none' },

    SERVER_FRAMEWORK = { 'qbx', 'qb', 'esx', 'standalone' },
    SERVER_INVENTORY = { 'ox_inventory', 'qb-inventory', 'esx', 'standalone', 'custom' },
    SERVER_PERMISSIONS = { 'framework', 'ace', 'standalone' }
}

-- =============================================================================
-- BRIDGE CONTRACT
-- Every bridge implementation must expose exactly these functions under its
-- category. The loader copies whichever implementation is selected onto the
-- flat `Bridge` table, so core files only ever call Bridge.<Name>(...).
--
-- Server bridge functions:
--   Bridge.GetPlayer(source)                       -> framework player object or nil
--   Bridge.GetIdentifier(source)                    -> string identifier or nil
--   Bridge.GetName(source)                          -> string display name
--   Bridge.GetJob(source)                           -> { name = string, grade = number } or nil
--   Bridge.HasItem(source, itemName, amount)         -> boolean
--   Bridge.RemoveItem(source, itemName, amount)      -> boolean
--   Bridge.AddItem(source, itemName, amount)         -> boolean
--   Bridge.Notify(source, message, notifyType)       -> nil
--   Bridge.IsReaderAllowed(source)                   -> boolean
--   Bridge.IsAdmin(source)                           -> boolean
--
-- Client bridge functions:
--   Bridge.AddTargetEntity(entity, options)          -> nil
--   Bridge.RemoveTargetEntity(entity)                -> nil
--   Bridge.Notify(message, notifyType)                -> nil
--   Bridge.OpenPlayerSelection(players, callback)     -> nil
--   Bridge.StartAmbientSound(soundId, coords)         -> nil
--   Bridge.StopAmbientSound(soundId)                  -> nil
-- =============================================================================

-- =============================================================================
-- SESSION ID / EVENT PAYLOAD LIMITS
-- =============================================================================

SessionIdPattern = '^tarot_%d+_%d+$'
TableIdPattern = '^table_%d+_%d+$'
MaxSessionIdLength = 32
MaxTableIdLength = 32
MaxSlotIndex = 21
