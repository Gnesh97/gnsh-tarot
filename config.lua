Config = {}

-- =============================================================================
-- GENERAL
-- =============================================================================

Config.Locale = 'tr'          -- default locale, falls back to 'en' then raw key
Config.Debug = false          -- verbose console output (detection, sessions, rejections)

-- =============================================================================
-- SYSTEM DETECTION
-- Each of these accepts 'auto' or an explicit value. Manual values always win
-- over auto-detection. See shared/constants.lua for the full list of valid
-- explicit values per category.
-- =============================================================================

Config.Framework = 'auto'             -- 'auto' | 'qbx' | 'qb' | 'esx' | 'standalone'
Config.Inventory = 'auto'             -- 'auto' | 'ox_inventory' | 'qb-inventory' | 'esx' | 'standalone' | 'custom'
Config.TargetSystem = 'auto'          -- 'auto' | 'ox_target' | 'qb-target' | 'fallback'
Config.NotificationSystem = 'auto'    -- 'auto' | 'ox_lib' | 'qb' | 'esx' | 'native'
Config.MenuSystem = 'auto'            -- 'auto' | 'ox_lib' | 'qb' | 'native'
Config.SoundSystem = 'none'           -- 'none' | 'xsound'

Config.AllowStandaloneFallback = true   -- if no framework/inventory/target detected, keep running standalone
Config.EnableInteractionFallback = true -- enable 3D text + keybind when no target resource is present
Config.InteractionKey = 38              -- E key (see FiveM control IDs)

-- Resource names, in case a server renamed any of these resources.
Config.ResourceNames = {
    QBCore = 'qb-core',
    Qbox = 'qbx_core',
    ESX = 'es_extended',
    OxInventory = 'ox_inventory',
    QbInventory = 'qb-inventory',
    OxTarget = 'ox_target',
    QbTarget = 'qb-target',
    OxLib = 'ox_lib',
    XSound = 'xsound'
}

-- =============================================================================
-- TABLE ITEM / COMMAND
-- =============================================================================

Config.TableItem = 'tarot_table'
Config.RequireTableItem = true    -- if false, table can be placed without consuming/checking the item
Config.ConsumeTableItem = false   -- if true, the item is removed from inventory on successful placement

Config.EnableTableCommand = true
Config.TableCommand = 'tarotmasa'

-- =============================================================================
-- TABLE PROPS
-- =============================================================================

Config.TableModel = 'prop_tarot_table' -- single combined custom model, used when UseCompositeProps = false
Config.TableFallbackModel = 'h4_prop_h4_table_isl_01a' -- valid GTA prop used when custom model is not installed
Config.UseCompositeProps = false       -- if true, build the table from separate world props below

Config.CompositeProps = {
    table = {
        model = 'h4_prop_h4_table_isl_01a',
        offset = vector3(0.0, 0.0, 0.0)
    },
    crystal = {
        model = 'prop_crystal_ball',
        offset = vector3(0.0, 0.15, 0.85)
    },
    candleLeft = {
        model = 'prop_candle_01',
        offset = vector3(-0.35, 0.1, 0.82)
    },
    candleRight = {
        model = 'prop_candle_01',
        offset = vector3(0.35, 0.1, 0.82)
    }
}

Config.ModelLoadTimeoutMs = 5000
Config.TableSpawnDistance = 1.5 -- meters in front of player where the table prop spawns

-- =============================================================================
-- LIMITS AND DISTANCES
-- =============================================================================

Config.MaxTablesPerPlayer = 1
Config.TableLifetimeMinutes = 60
Config.TableInteractionDistance = 2.0
Config.TableRemovalDistance = 3.0
Config.CustomerSearchDistance = 4.0
Config.InviteDistance = 4.0
Config.SessionMaxDistance = 6.0

-- =============================================================================
-- PLAYER SELECTION
-- =============================================================================

Config.PlayerSelectionMode = 'list' -- 'nearest' or 'list'

-- =============================================================================
-- TIMEOUTS / COOLDOWNS
-- =============================================================================

Config.InviteTimeoutSeconds = 30
Config.SessionTimeoutSeconds = 600
Config.ActionCooldownMilliseconds = 750
Config.PendingPlacementTimeoutSeconds = 15
Config.TablePlacementDistance = 5.0
Config.TableEntityValidationDistance = 8.0
Config.TableHeadingTolerance = 15.0

-- =============================================================================
-- CARD / DECK RULES
-- =============================================================================

Config.ReversedChance = 50             -- percent chance a revealed card is reversed
Config.PreventDuplicateCards = true    -- same card cannot appear twice in one spread
-- Reveal order is configured per spread via revealMode. Set ForceSequentialReveal
-- to true above to override all spread-specific modes.
Config.ServerAuthoritativeCards = true -- must remain true; kept as an explicit acknowledgement flag
Config.RevealAnimationDelay = 300      -- ms both clients wait after receiving a reveal before flipping
Config.ForceSequentialReveal = false
Config.AllowRevealAll = false
Config.PentagramIncludeCenter = true

Config.SpreadSelection = {
    enabled = true,
    showDifficulty = true,
    showEstimatedDuration = true,
    showPreview = true,
    requireConfirmation = true,
}

-- The board is dealt into the selected spread before the reader can reveal a card.
-- Keep these values server-visible so both clients share the same timing.
Config.DealAnimation = {
    enabled = true,
    initialDelay = 500,
    perCardDelay = 140,
    cardTravelDuration = 550,
    finishDelay = 400,
}

-- =============================================================================
-- SOUND
-- =============================================================================

Config.EnableCardSounds = true   -- local NUI sounds (shuffle/draw/flip/complete)
Config.CardSoundVolume = 0.35

Config.EnableAmbientSound = false -- 3D ambient sound around the table via xSound
Config.AmbientVolume = 0.04
Config.AmbientDistance = 12.0
Config.AmbientSoundUrl = '' -- URL or streamed path for xSound; empty = ambient toggle stays silent (no asset shipped by default)

-- =============================================================================
-- PERMISSIONS
-- =============================================================================

Config.AllowEveryoneToRead = true
Config.AllowSoloReading = true -- reader can run a reading without a second player (self-select button on the player picker)

-- Only used when AllowEveryoneToRead = false. Maps job name -> minimum grade.
Config.ReaderJobs = {
    -- fortune_teller = 0,
    -- mystic = 1
}

Config.UseAcePermission = false
Config.ReaderAcePermission = 'tarot.reader'
Config.AdminAcePermission = 'tarot.admin'

-- =============================================================================
-- SEATING
-- =============================================================================

Config.Seating = {
    enabled = true,

    -- Facing each other across the table.
    readerOffset = vector3(0.0, -0.75, 0.0),
    customerOffset = vector3(0.0, 0.75, 0.0),

    readerHeadingOffset = 0.0,
    customerHeadingOffset = 180.0,

    -- Fine rotation nudge for the CHARACTER only, on top of the headings
    -- above -- turns the seated pose in place to line up with the chair's
    -- own facing. Degrees, +/-. Restart and eyeball it.
    seatRotationAdjust = 30.0,

    -- A proper chair-seated idle (legs down, upright) instead of the old
    -- wall-tablet anim, which is a cross-legged floor/wall-lean pose that
    -- never lines up with an actual chair prop no matter the offset.
    animDict = 'anim@scripted@freemode_npc@fix_agy_ig1_franklin@',
    animName = 'typing_base_franklin',

    -- Chair prop spawned under each seated player, ground-snapped at the
    -- same table-relative offset as their seat.
    chairModel = 'prop_clown_chair',

    -- Extra table-relative x/y/z nudge for the CHAIR only, on top of
    -- readerOffset/customerOffset above (does not move the character).
    -- x = left/right, y = toward/away from table, z = up/down (ground-snap
    -- usually makes z a non-issue). Restart and eyeball it.
    chairPositionAdjust = vector3(0.2, 0.2, 0.0)
}

Config.FreezePlayersDuringReading = false -- default off: players are not locked in place

-- =============================================================================
-- SPREADS
-- Slot count and label keys per spread type. Label keys are resolved through
-- the locale system (locales/*.lua -> spread_slot_<key>).
-- =============================================================================

Config.Spreads = {
    three_card = {
        enabled = true,
        name = 'Temel Üç Kart Dizilimi',
        labelKey = 'spread_three_card',
        shortDescription = 'Geçmiş, şimdiki zaman ve geleceğe odaklanan hızlı açılım.',
        difficulty = 'Başlangıç',
        estimatedDuration = '3–5 dakika',
        cardCount = 3,
        revealMode = 'sequential',
        boardScale = 1.0,
        slots = {
            { id = 1, label = 'Geçmiş', description = 'Geçmişten gelen olayları ve etkileri temsil eder.', x = 20, y = 50, rotation = 0, scale = 0.95, zIndex = 1 },
            { id = 2, label = 'Şimdiki Zaman', description = 'Karakterin mevcut durumunu ve içinde bulunduğu enerjiyi temsil eder.', x = 50, y = 50, rotation = 0, scale = 0.95, zIndex = 1 },
            { id = 3, label = 'Gelecek', description = 'Mevcut yolun devam etmesi hâlinde oluşabilecek gelişmeleri temsil eder.', x = 80, y = 50, rotation = 0, scale = 0.95, zIndex = 1 },
        },
    },
    horseshoe_seven = {
        enabled = true,
        name = 'Yedi Kartlı At Nalı Dizilimi',
        labelKey = 'spread_horseshoe_seven',
        shortDescription = 'Bir durumu yedi farklı açıdan değerlendiren kapsamlı açılım.',
        difficulty = 'Orta',
        estimatedDuration = '7–10 dakika',
        cardCount = 7,
        revealMode = 'sequential',
        boardScale = 1.0,
        slots = {
            { id = 1, label = 'Geçmiş', description = 'Durumun geçmişteki temelini temsil eder.', x = 6, y = 24, rotation = -10, scale = 0.72, zIndex = 1 },
            { id = 2, label = 'Şimdiki Zaman', description = 'Mevcut koşulları ve aktif etkileri temsil eder.', x = 21, y = 40, rotation = -7, scale = 0.72, zIndex = 1 },
            { id = 3, label = 'Gizli Etkiler', description = 'Henüz fark edilmemiş veya görünmeyen etkileri temsil eder.', x = 35, y = 54, rotation = -4, scale = 0.72, zIndex = 1 },
            { id = 4, label = 'İlgili Kişi', description = 'Falın bakıldığı kişinin tutumunu ve mevcut konumunu temsil eder.', x = 50, y = 62, rotation = 0, scale = 0.72, zIndex = 1 },
            { id = 5, label = 'Diğerlerinin Tutumu', description = 'Çevredeki kişilerin yaklaşımını ve etkisini temsil eder.', x = 65, y = 54, rotation = 4, scale = 0.72, zIndex = 1 },
            { id = 6, label = 'Yapılması Gereken', description = 'Karakterin değerlendirebileceği yaklaşımı temsil eder.', x = 79, y = 40, rotation = 7, scale = 0.72, zIndex = 1 },
            { id = 7, label = 'Muhtemel Sonuç', description = 'Mevcut yol devam ederse ortaya çıkabilecek sonucu temsil eder.', x = 94, y = 24, rotation = 10, scale = 0.72, zIndex = 1 },
        },
    },
    pentagram = {
        enabled = true,
        name = 'Pentagram Dizilimi',
        labelKey = 'spread_pentagram',
        shortDescription = 'Dört temel element ve ruh üzerinden durumu değerlendiren açılım.',
        difficulty = 'Orta',
        estimatedDuration = '6–9 dakika',
        cardCount = 6,
        revealMode = 'sequential',
        boardScale = 1.0,
        slots = {
            { id = 1, label = 'Sorunun Özü', description = 'Açılımın merkezindeki ana durumu veya soruyu temsil eder.', x = 50, y = 60, rotation = 0, scale = 0.74, zIndex = 2, labelOffsetY = 6 },
            { id = 2, label = 'Ruh', description = 'Manevi yönü, sezgiyi ve bütünlüğü temsil eder.', x = 50, y = 18, rotation = 0, scale = 0.74, zIndex = 1 },
            { id = 3, label = 'Hava', description = 'Düşünceleri, iletişimi ve zihinsel etkileri temsil eder.', x = 19, y = 38, rotation = -6, scale = 0.74, zIndex = 1 },
            { id = 4, label = 'Ateş', description = 'İradeyi, tutkuyu ve harekete geçiren gücü temsil eder.', x = 81, y = 38, rotation = 6, scale = 0.74, zIndex = 1 },
            { id = 5, label = 'Toprak', description = 'Maddi koşulları, güvenliği ve pratik gerçekleri temsil eder.', x = 25, y = 78, rotation = -4, scale = 0.74, zIndex = 1 },
            { id = 6, label = 'Su', description = 'Duyguları, ilişkileri ve sezgisel akışı temsil eder.', x = 75, y = 78, rotation = 4, scale = 0.74, zIndex = 1 },
        },
    },
    celtic_cross = {
        enabled = true,
        name = 'Kelt Haçı Dizilimi',
        labelKey = 'spread_celtic_cross',
        shortDescription = 'Bir sorunu geçmişten sonuca kadar birçok açıdan inceleyen ayrıntılı açılım.',
        difficulty = 'İleri',
        estimatedDuration = '10–15 dakika',
        cardCount = 10,
        revealMode = 'sequential',
        -- Card size is capped by the four-row staff, so the whole board is
        -- scaled up instead; the layout leaves enough margin to absorb it.
        boardScale = 1.08,
        slots = {
            -- The four-card staff sets the size ceiling here: card height plus its
            -- label has to fit the gap between two staff rows.
            { id = 1, label = 'Mevcut Durum', description = 'Sorunun merkezindeki mevcut enerjiyi temsil eder.', x = 38, y = 50, rotation = 0, scale = 0.60, zIndex = 2 },
            -- Rotated 90deg: its label rides the rotated axis, so labelOffsetY
            -- pushes it clear of the card underneath instead of down the page.
            { id = 2, label = 'Engel / Meydan Okuma', description = 'Mevcut durumla kesişen engeli veya sınavı temsil eder.', x = 38, y = 50, rotation = 90, scale = 0.60, zIndex = 3, labelOffsetY = -40 },
            { id = 3, label = 'Temel / Bilinçaltı', description = 'Durumun altında yatan temel nedeni temsil eder.', x = 38, y = 86, rotation = 0, scale = 0.60, zIndex = 1 },
            { id = 4, label = 'Geçmiş', description = 'Mevcut durumu etkileyen yakın geçmişi temsil eder.', x = 20, y = 50, rotation = 0, scale = 0.60, zIndex = 1 },
            { id = 5, label = 'Bilinçli Amaç', description = 'Kişinin düşündüğü hedefi veya ulaşılabilecek ihtimali temsil eder.', x = 38, y = 14, rotation = 0, scale = 0.60, zIndex = 1 },
            { id = 6, label = 'Yakın Gelecek', description = 'Yakında ortaya çıkabilecek gelişmeyi temsil eder.', x = 56, y = 50, rotation = 0, scale = 0.60, zIndex = 1 },
            { id = 7, label = 'Kişinin Tutumu', description = 'Kişinin duruma karşı iç tutumunu temsil eder.', x = 78, y = 90, rotation = 0, scale = 0.60, zIndex = 1 },
            { id = 8, label = 'Çevre ve Dış Etkiler', description = 'Diğer kişileri ve çevresel koşulları temsil eder.', x = 78, y = 63.5, rotation = 0, scale = 0.60, zIndex = 1 },
            { id = 9, label = 'Umutlar ve Korkular', description = 'Kişinin beklentilerini ve endişelerini temsil eder.', x = 78, y = 37, rotation = 0, scale = 0.60, zIndex = 1 },
            { id = 10, label = 'Muhtemel Sonuç', description = 'Mevcut yolun devam etmesi hâlinde ortaya çıkabilecek sonucu temsil eder.', x = 78, y = 10.5, rotation = 0, scale = 0.60, zIndex = 1 },
        },
    },
    gypsy_twenty_one = {
        enabled = true,
        name = 'Çingene Dizilimi',
        labelKey = 'spread_gypsy_twenty_one',
        shortDescription = 'Geçmiş, şimdi ve geleceği 21 kartla ayrıntılı biçimde ele alan açılım.',
        difficulty = 'İleri',
        estimatedDuration = '15–25 dakika',
        cardCount = 21,
        revealMode = 'row_sequential',
        dealDelay = 65,
        compactMode = true,
        boardScale = 1.0,
        slots = {
            { id = 1, label = 'Geçmişin Başlangıcı', description = 'Geçmişteki başlangıç etkisini temsil eder.', x = 7, y = 17, row = 1, scale = 1.0 },
            { id = 2, label = 'Geçmişteki Dış Etki', description = 'Geçmişteki dış etkileri temsil eder.', x = 21, y = 17, row = 1, scale = 1.0 },
            { id = 3, label = 'Geçmişteki Önemli Kişi', description = 'Geçmişte etkili olan kişiyi temsil eder.', x = 35, y = 17, row = 1, scale = 1.0 },
            { id = 4, label = 'Geçmişteki Karar', description = 'Geçmişte alınan kararı temsil eder.', x = 49, y = 17, row = 1, scale = 1.0 },
            { id = 5, label = 'Geçmişteki Değişim', description = 'Geçmişteki değişimi temsil eder.', x = 63, y = 17, row = 1, scale = 1.0 },
            { id = 6, label = 'Geçmişten Kalan Engel', description = 'Geçmişten kalan engeli temsil eder.', x = 77, y = 17, row = 1, scale = 1.0 },
            { id = 7, label = 'Geçmişin Yansıması', description = 'Geçmişin bugüne yansımasını temsil eder.', x = 91, y = 17, row = 1, scale = 1.0 },
            { id = 8, label = 'Mevcut Düşünceler', description = 'Mevcut düşünceleri temsil eder.', x = 7, y = 50, row = 2, scale = 1.0 },
            { id = 9, label = 'Mevcut Duygular', description = 'Mevcut duyguları temsil eder.', x = 21, y = 50, row = 2, scale = 1.0 },
            { id = 10, label = 'Mevcut İlişkiler', description = 'Mevcut ilişkileri temsil eder.', x = 35, y = 50, row = 2, scale = 1.0 },
            { id = 11, label = 'Mevcut Engeller', description = 'Mevcut engelleri temsil eder.', x = 49, y = 50, row = 2, scale = 1.0 },
            { id = 12, label = 'Mevcut Fırsatlar', description = 'Mevcut fırsatları temsil eder.', x = 63, y = 50, row = 2, scale = 1.0 },
            { id = 13, label = 'Çevrenin Etkisi', description = 'Çevrenin etkisini temsil eder.', x = 77, y = 50, row = 2, scale = 1.0 },
            { id = 14, label = 'Şu Anki Yönelim', description = 'Şu anki yönelimi temsil eder.', x = 91, y = 50, row = 2, scale = 1.0 },
            { id = 15, label = 'Yaklaşan İlk Gelişme', description = 'Yaklaşan ilk gelişmeyi temsil eder.', x = 7, y = 83, row = 3, scale = 1.0 },
            { id = 16, label = 'Yakın Gelecekteki Etki', description = 'Yakın gelecekteki etkiyi temsil eder.', x = 21, y = 83, row = 3, scale = 1.0 },
            { id = 17, label = 'Olası Fırsat', description = 'Olası fırsatı temsil eder.', x = 35, y = 83, row = 3, scale = 1.0 },
            { id = 18, label = 'Olası Engel', description = 'Olası engeli temsil eder.', x = 49, y = 83, row = 3, scale = 1.0 },
            { id = 19, label = 'Değişecek Alan', description = 'Değişime uğrayacak alanı temsil eder.', x = 63, y = 83, row = 3, scale = 1.0 },
            { id = 20, label = 'Uzun Vadeli Yön', description = 'Uzun vadeli yönü temsil eder.', x = 77, y = 83, row = 3, scale = 1.0 },
            { id = 21, label = 'Muhtemel Sonuç', description = 'Muhtemel sonucu temsil eder.', x = 91, y = 83, row = 3, scale = 1.0 },
        },
    },
}

Config.SpreadOrder = {
    'three_card',
    'horseshoe_seven',
    'pentagram',
    'celtic_cross',
    'gypsy_twenty_one',
}
