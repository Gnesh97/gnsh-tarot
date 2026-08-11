fx_version 'cerulean'
game 'gta5'

lua54 'yes'

author 'Universal Tarot Reading System'
description 'Server-authoritative, framework-agnostic synchronized tarot card reading system (RP flavor only, no mechanical effects)'
version '1.0.0'

-- Shared scripts are listed explicitly (not via wildcard) because load order
-- matters: constants before cards, cards before locale, locale table
-- registration before the locale accessor function.
shared_scripts {
    'config.lua',
    'shared/constants.lua',
    'shared/cards.lua',
    'shared/utils.lua',
    'locales/en.lua',
    'locales/tr.lua',
    'shared/locale.lua'
}

-- Bridge loaders must run before the bridge implementation files so the
-- registration table (TarotBridges) exists when each bridge file executes,
-- and must run before the core files so Bridge.* is populated when core
-- files define their top-level logic.
client_scripts {
    'client/bridges/loader.lua',
    'client/bridges/framework/*.lua',
    'client/bridges/target/*.lua',
    'client/bridges/notification/*.lua',
    'client/bridges/sound/*.lua',
    'client/main.lua',
    'client/tables.lua',
    'client/sessions.lua',
    'client/nui.lua',
    'client/animations.lua',
    'client/seating.lua',
    'client/interaction.lua',
    'client/sound.lua'
}

server_scripts {
    'server/bridges/loader.lua',
    'server/bridges/framework/*.lua',
    'server/bridges/inventory/*.lua',
    'server/bridges/permissions/*.lua',
    'server/security.lua',
    'server/cooldowns.lua',
    'server/deck.lua',
    'server/tables.lua',
    'server/sessions.lua',
    'server/cleanup.lua',
    'server/main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/*.css',
    'html/js/*.js',
    'html/assets/cards/*',
    'html/assets/audio/*',
    'html/assets/images/*',
    'html/assets/fonts/*'
}

-- No `dependency` entries on purpose: every framework / inventory / target /
-- notification / sound integration is optional and auto-detected or
-- manually selected in config.lua. See README.md for the OneSync note
-- (routing bucket checks in server/security.lua assume OneSync is enabled;
-- on servers without OneSync the bucket check is a no-op).
