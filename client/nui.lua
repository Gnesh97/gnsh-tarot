-- All SendNUIMessage / RegisterNUICallback traffic. Every callback validates
-- its action against AllowedNuiActions and reaches cb() on every branch —
-- an un-called cb() hangs the NUI's fetch promise forever.

TarotNui = {}

local nuiOpen = false
local playerSelectionCallback = nil
-- Bumped whenever the UI is opened again. The closing screen's delayed Hide
-- carries the token it was scheduled with, so a reading started before the
-- delay expires is not torn down by the previous session's timer.
local uiGeneration = 0

local function setFocus(hasFocus)
    SetNuiFocus(hasFocus, hasFocus)
    nuiOpen = hasFocus
    if hasFocus then
        uiGeneration = uiGeneration + 1
    end
end

local function cardMeaning(card, orientation)
    if card == nil then return '' end

    local key = ('card_%s_%s'):format(card.key, orientation)
    local meaning = _L(key)
    return meaning == key and card.name or meaning
end

-- Card identity/meaning text is resolved here from shared/cards.lua + the
-- active locale (both loaded client-side as shared scripts) so the NUI never
-- needs its own copy of card data or translations.
local function resolveSlot(slot)
    if not slot.revealed then return { revealed = false } end
    local card = CardsById[slot.cardId]
    return {
        revealed = true,
        cardId = slot.cardId,
        name = card and card.name or '?',
        image = card and card.image or nil,
        orientation = slot.orientation,
        orientationLabel = _L('orientation_' .. slot.orientation),
        meaning = cardMeaning(card, slot.orientation),
    }
end

function TarotNui.ShowInvite(data)
    setFocus(true)
    SendNUIMessage({
        action = 'showInvite',
        data = {
            sessionId = data.sessionId,
            titleText = _L('invite_prompt_title'),
            bodyText = _L('invite_received', data.readerName),
            acceptText = _L('invite_accept'),
            rejectText = _L('invite_reject'),
        },
    })
end

-- Called from a bridge's OpenPlayerSelection(maxDistance, callback). Shows a
-- list of nearby connected players in the NUI; the eventual 'selectPlayer' or
-- 'cancelPlayerSelection' NUI callback invokes `callback` with a serverId or
-- nil. Only one selection can be pending at a time.
function TarotNui.ShowPlayerSelection(maxDistance, callback)
    playerSelectionCallback = callback

    local myPed = PlayerPedId()
    local myCoords = GetEntityCoords(myPed)
    local myServerId = GetPlayerServerId(PlayerId())

    local players = {}
    for _, playerId in ipairs(GetActivePlayers()) do
        local serverId = GetPlayerServerId(playerId)
        if serverId ~= myServerId then
            local ped = GetPlayerPed(playerId)
            local distance = #(myCoords - GetEntityCoords(ped))
            if distance <= maxDistance then
                players[#players + 1] = {
                    id = serverId,
                    name = GetPlayerName(playerId) or ('#' .. tostring(serverId)),
                    distance = math.floor(distance * 10) / 10,
                }
            end
        end
    end
    table.sort(players, function(a, b) return a.distance < b.distance end)

    setFocus(true)
    SendNUIMessage({
        action = 'openPlayerSelection',
        data = {
            titleText = _L('player_selection_title'),
            confirmText = _L('player_selection_confirm'),
            closeButtonText = _L('nui_close_reading'),
            emptyText = _L('player_selection_empty'),
            soloText = _L('player_selection_solo'),
            allowSolo = Config.AllowSoloReading == true,
            selfId = myServerId,
            players = players,
        },
    })
end

local function spreadPayload(spreadType)
    local spread = Config.Spreads[spreadType]
    if spread == nil then return nil end

    local slots = {}
    local labels = {}
    for index, slot in ipairs(spread.slots or {}) do
        slots[index] = {
            id = slot.id or index,
            label = slot.label or ('Kart ' .. tostring(slot.id or index)),
            description = slot.description or '',
            x = slot.x or 50,
            y = slot.y or 50,
            rotation = slot.rotation or 0,
            scale = slot.scale or 1,
            zIndex = slot.zIndex or 1,
            row = slot.row,
        }
        labels[index] = slots[index].label
    end

    local cardCount = #slots
    if spreadType == 'pentagram' and Config.PentagramIncludeCenter == false then
        table.remove(slots, 1)
        table.remove(labels, 1)
        cardCount = #slots
    end

    return {
        key = spreadType,
        name = spread.name or _L(spread.labelKey),
        label = _L(spread.labelKey) ~= spread.labelKey and _L(spread.labelKey) or spread.name or spreadType,
        shortDescription = spread.shortDescription or '',
        difficulty = spread.difficulty or '',
        estimatedDuration = spread.estimatedDuration or '',
        cardCount = cardCount,
        revealMode = spread.revealMode or 'sequential',
        boardScale = spread.boardScale or 1,
        compactMode = spread.compactMode == true,
        slots = slots,
        slotLabels = labels,
    }
end

function TarotNui.ShowSpreadSelection(session)
    setFocus(true)
    local spreads = {}
    for _, spreadType in ipairs(Config.SpreadOrder or {}) do
        if Config.Spreads[spreadType] ~= nil and Config.Spreads[spreadType].enabled ~= false then
            spreads[#spreads + 1] = spreadPayload(spreadType)
        end
    end
    SendNUIMessage({
        action = 'openSpreadSelection',
        data = {
            sessionId = session and session.id or nil,
            titleText = _L('spread_selection_title'),
            confirmText = _L('spread_selection_confirm'),
            closeButtonText = _L('nui_close_reading'),
            spreads = spreads,
            selectionSettings = {
                enabled = not Config.SpreadSelection or Config.SpreadSelection.enabled ~= false,
                showDifficulty = not Config.SpreadSelection or Config.SpreadSelection.showDifficulty ~= false,
                showEstimatedDuration = not Config.SpreadSelection or Config.SpreadSelection.showEstimatedDuration ~= false,
                showPreview = not Config.SpreadSelection or Config.SpreadSelection.showPreview ~= false,
                requireConfirmation = not Config.SpreadSelection or Config.SpreadSelection.requireConfirmation ~= false,
            },
            isReader = true,
        },
    })
end

function TarotNui.ShowSpreadWaiting(session)
    setFocus(true)
    SendNUIMessage({
        action = 'showSpreadWaiting',
        data = {
            sessionId = session and session.id or nil,
            text = _L('spread_selection_waiting'),
            closeButtonText = _L('nui_close_reading'),
            isReader = false,
        },
    })
end

function TarotNui.LoadSpread(session, deal, awaitDeal)
    setFocus(true)
    local spread = spreadPayload(session.spreadType)
    if spread == nil then return end
    SendNUIMessage({
        action = 'loadSpread',
        data = {
            sessionId = session.id,
            spreadKey = session.spreadType,
            spreadType = session.spreadType,
            spread = spread,
            state = session.state,
            isReader = TarotSessions.Current() ~= nil and TarotSessions.Current().isReader,
            enableCardSounds = Config.EnableCardSounds,
            cardSoundVolume = Config.CardSoundVolume,
            firstRevealButtonText = _L('nui_reveal_first_card'),
            revealButtonText = _L('nui_reveal_next_card'),
            revealAllButtonText = _L('nui_reveal_all'),
            allowRevealAll = Config.AllowRevealAll == true,
            closeButtonText = _L('nui_close_reading'),
            waitingText = _L('nui_waiting_for_reader'),
            yourTurnText = _L('nui_your_turn_reveal'),
            dealButtonText = _L('nui_deal_cards'),
            dealWaitingText = _L('nui_deal_waiting'),
            dealingText = _L('nui_dealing'),
            awaitDeal = awaitDeal == true,
            deal = deal,
        },
    })
end

function TarotNui.ShowShuffle(session)
    TarotNui.LoadSpread(session, { enabled = false }, true)
end

function TarotNui.DealSpread(session, deal)
    setFocus(true)
    -- Keep slots hidden (awaitDeal=true) here: the actual reveal happens in
    -- runDealAnimation once the 'dealSpread' NUI message's startDelay elapses.
    -- Passing false made cards flash at their final position for that gap.
    TarotNui.LoadSpread(session, deal, true)
    SendNUIMessage({
        action = 'dealSpread',
        data = {
            sessionId = session.id,
            spreadKey = session.spreadType,
            startDelay = deal and deal.startDelay or 0,
            perCardDelay = deal and deal.perCardDelay or Config.DealAnimation.perCardDelay,
            cardTravelDuration = deal and deal.cardTravelDuration or Config.DealAnimation.cardTravelDuration,
            finishDelay = deal and deal.finishDelay or Config.DealAnimation.finishDelay,
        },
    })
end

function TarotNui.RevealSlot(slot, cardId, orientation, animationDelay, slotId)
    local card = CardsById[cardId]
    local session = TarotSessions.Current()
    SendNUIMessage({
        action = 'revealSlot',
        data = {
            sessionId = session and session.id or nil,
            slot = slot,
            slotIndex = slot,
            slotId = slotId or slot,
            cardId = cardId,
            name = card and card.name or '?',
            image = card and card.image or nil,
            orientation = orientation,
            orientationLabel = _L('orientation_' .. orientation),
            meaning = cardMeaning(card, orientation),
            animationDelay = animationDelay,
        },
    })
end

function TarotNui.RenderSnapshot(session)
    setFocus(true)
    local slots = {}
    local spread = spreadPayload(session.spreadType)
    if spread == nil then return end
    for i, slot in ipairs(session.slots) do
        slots[i] = resolveSlot(slot)
    end
    SendNUIMessage({
        action = 'renderSnapshot',
        data = {
            sessionId = session.id,
            state = session.state,
            spreadType = session.spreadType,
            spreadLabel = spread.label,
            spread = spread,
            slotLabels = spread.slotLabels,
            slots = slots,
            isReader = TarotSessions.Current() ~= nil and TarotSessions.Current().isReader,
            enableCardSounds = Config.EnableCardSounds,
            cardSoundVolume = Config.CardSoundVolume,
            firstRevealButtonText = _L('nui_reveal_first_card'),
            revealButtonText = _L('nui_reveal_next_card'),
            revealAllButtonText = _L('nui_reveal_all'),
            allowRevealAll = Config.AllowRevealAll == true,
            closeButtonText = _L('nui_close_reading'),
            waitingText = _L('nui_waiting_for_reader'),
            yourTurnText = _L('nui_your_turn_reveal'),
        },
    })
end

function TarotNui.ShowSummary(session)
    local slots = {}
    local spread = spreadPayload(session.spreadType)
    if spread == nil then return end
    for i, slot in ipairs(session.slots) do
        slots[i] = resolveSlot(slot)
    end
    SendNUIMessage({
        action = 'showSummary',
        data = {
            sessionId = session.id,
            spreadType = session.spreadType,
            spreadLabel = spread.label,
            spread = spread,
            slotLabels = spread.slotLabels,
            slots = slots,
            titleText = _L('nui_summary_title'),
            closeButtonText = _L('nui_close_summary'),
        },
    })
end

function TarotNui.ShowClosing(reason)
    local text = _L(reason)
    if text == reason then
        text = _L('nui_closing_default')
    end
    local session = TarotSessions.Current()
    SendNUIMessage({
        action = 'showClosing',
        data = { sessionId = session and session.id or nil, text = text },
    })
    local generation = uiGeneration
    SetTimeout(4000, function()
        if generation ~= uiGeneration then return end
        TarotNui.Hide()
    end)
end

function TarotNui.Hide()
    setFocus(false)
    SendNUIMessage({ action = 'hide' })
end

function TarotNui.IsOpen()
    return nuiOpen
end

local function safeCallback(cb, ok)
    if type(cb) == 'function' then
        cb({ ok = ok == true })
    end
end

local function isCurrentSessionPayload(data)
    local session = TarotSessions.Current()
    return type(data) == 'table'
        and Utils.IsValidSessionId(data.sessionId)
        and session ~= nil
        and session.id == data.sessionId
end

RegisterNUICallback('selectPlayer', function(data, cb)
    local callback = playerSelectionCallback
    playerSelectionCallback = nil
    TarotNui.Hide()

    local playerId = type(data) == 'table' and tonumber(data.playerId) or nil
    safeCallback(cb, true)
    if callback == nil then return end
    if playerId == nil then return callback(nil) end

    local myServerId = GetPlayerServerId(PlayerId())
    if playerId == myServerId then
        if Config.AllowSoloReading == true then return callback(playerId) end
        return callback(nil)
    end
    for _, activeId in ipairs(GetActivePlayers()) do
        if GetPlayerServerId(activeId) == playerId then
            return callback(playerId)
        end
    end
    callback(nil)
end)

RegisterNUICallback('cancelPlayerSelection', function(data, cb)
    local callback = playerSelectionCallback
    playerSelectionCallback = nil
    TarotNui.Hide()
    safeCallback(cb, true)
    if callback ~= nil then callback(nil) end
end)

RegisterNUICallback('acceptInvite', function(data, cb)
    if type(data) ~= 'table' or not TarotSessions.IsPendingInvite(data.sessionId) then
        return safeCallback(cb, false)
    end
    TarotSessions.AcceptInvite()
    safeCallback(cb, true)
end)

RegisterNUICallback('rejectInvite', function(data, cb)
    if type(data) ~= 'table' or not TarotSessions.IsPendingInvite(data.sessionId) then
        return safeCallback(cb, false)
    end
    TarotSessions.RejectInvite()
    safeCallback(cb, true)
end)

RegisterNUICallback('selectSpread', function(data, cb)
    local session = TarotSessions.Current()
    local spreadType = type(data) == 'table' and (data.spreadKey or data.spreadType) or nil
    if session == nil or session.id == nil or not session.isReader
        or session.state ~= 'spread_selection'
        or not AllowedSpreads[spreadType] then
        return safeCallback(cb, false)
    end
    TriggerServerEvent('tarot:server:selectSpread', session.id, spreadType)
    safeCallback(cb, true)
end)

RegisterNUICallback('startDeal', function(data, cb)
    local session = TarotSessions.Current()
    if not AllowedNuiActions.startDeal or not isCurrentSessionPayload(data)
        or session == nil or not session.isReader or session.state ~= 'dealing' then
        return safeCallback(cb, false)
    end
    TriggerServerEvent('tarot:server:startDeal', session.id)
    safeCallback(cb, true)
end)

RegisterNUICallback('revealSlot', function(data, cb)
    if not AllowedNuiActions.revealSlot or not isCurrentSessionPayload(data) then
        return safeCallback(cb, false)
    end
    local slotId = tonumber(data.slotId or data.slot)
    if slotId == nil then return safeCallback(cb, false) end
    TarotSessions.RevealSlot(slotId)
    safeCallback(cb, true)
end)

RegisterNUICallback('revealNext', function(data, cb)
    if not AllowedNuiActions.revealNext or not isCurrentSessionPayload(data) then
        return safeCallback(cb, false)
    end
    TarotSessions.RevealNext()
    safeCallback(cb, true)
end)

RegisterNUICallback('revealAll', function(data, cb)
    if not AllowedNuiActions.revealAll or not isCurrentSessionPayload(data) then
        return safeCallback(cb, false)
    end
    TarotSessions.RevealAll()
    safeCallback(cb, true)
end)

RegisterNUICallback('closeSession', function(data, cb)
    if not isCurrentSessionPayload(data) then return safeCallback(cb, false) end
    -- Only the reader's close button ends the session for everyone. The
    -- customer's close button (on the invite/focus view) just dismisses
    -- their own NUI and keeps watching/participating in the reading.
    local session = TarotSessions.Current()
    if session ~= nil and session.isReader then
        TarotSessions.Close()
    end
    TarotNui.Hide()
    safeCallback(cb, true)
end)

RegisterNUICallback('requestSnapshot', function(data, cb)
    if not isCurrentSessionPayload(data) then return safeCallback(cb, false) end
    TarotSessions.RequestSnapshot()
    safeCallback(cb, true)
end)
