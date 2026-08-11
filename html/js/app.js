// Generic, metadata-driven tarot UI. Every spread uses the same board and
// the same single NUI root; only the server-provided spread metadata changes.
(function () {
    const { showScreen, hideAll, setSessionId, matchesSession } = window.TarotState;
    const { on, postNui } = window.TarotNui;
    const { setText } = window.TarotSecurity;
    const { buildSlot, renderRevealed, revealSlot } = window.TarotCards;

    let readerState = {
        isReader: false,
        controlsEnabled: false,
        revealedCount: 0,
        slotCount: 0,
        spread: null,
        slots: [],
        closeButtonText: '',
        firstRevealButtonText: '',
        revealButtonText: '',
        revealAllButtonText: '',
        waitingText: '',
        yourTurnText: '',
    };
    let selectedSpreadKey = null;
    let selectedPlayerId = null;

    function clearChildren(el) {
        if (el == null) return;
        while (el.firstChild) el.removeChild(el.firstChild);
    }

    function slotDefs(data) {
        if (data && data.spread && Array.isArray(data.spread.slots)) return data.spread.slots;
        return (data && data.slotLabels || []).map((label, index) => ({ id: index + 1, label }));
    }

    function countRevealed(slots) {
        return (slots || []).reduce((count, slot) => count + (slot && slot.revealed ? 1 : 0), 0);
    }

    function getBoard(screenName) {
        return document.getElementById(screenName === 'summary' ? 'summary-slots' : 'reading-slots');
    }

    function openDetails(slotData, definition) {
        const panel = document.getElementById('card-details');
        if (panel == null || !slotData || !slotData.revealed) return;
        setText(document.getElementById('card-details-title'), slotData.name || '');
        setText(document.getElementById('card-details-orientation'), slotData.orientationLabel || '');
        setText(document.getElementById('card-details-position'), definition && definition.label || '');
        setText(document.getElementById('card-details-meaning'), slotData.meaning || '');
        setText(document.getElementById('card-details-description'), definition && definition.description || '');
        panel.hidden = false;
    }

    function buildBoard(container, data, mode) {
        clearChildren(container);
        const spread = data && data.spread || { slots: slotDefs(data), boardScale: 1 };
        const definitions = Array.isArray(spread.slots) ? spread.slots : [];
        const slots = Array.isArray(data && data.slots) ? data.slots : [];
        container.className = 'slots spread-board'
            + (spread.compactMode ? ' compact' : '')
            + (mode === 'reading' && data && data.awaitDeal === true ? ' awaiting-deal' : '');
        container.dataset.spread = spread.key || (data && data.spreadKey) || '';
        container.style.setProperty('--board-scale', String(spread.boardScale || 1));

        definitions.forEach((definition, index) => {
            const wrapper = buildSlot(index + 1, definition.label || `Kart ${index + 1}`, definition);
            wrapper.style.setProperty('--slot-x', `${Number(definition.x == null ? 50 : definition.x)}%`);
            wrapper.style.setProperty('--slot-y', `${Number(definition.y == null ? 50 : definition.y)}%`);
            const slotRotation = Number(definition.rotation == null ? 0 : definition.rotation);
            wrapper.style.setProperty('--slot-rotation', `${slotRotation}deg`);
            wrapper.style.setProperty('--slot-label-rotation', `${-slotRotation}deg`);
            wrapper.style.setProperty('--slot-label-offset-y', `${Number(definition.labelOffsetY || 0)}px`);
            wrapper.style.setProperty('--slot-scale', String(Number(definition.scale == null ? 1 : definition.scale)));
            wrapper.style.setProperty('--slot-index', String(index));
            wrapper.style.zIndex = String(Number(definition.zIndex == null ? 1 : definition.zIndex));
            wrapper.classList.toggle('summary-slot', mode === 'summary');
            wrapper.addEventListener('tarot:slot-click', () => {
                const slotData = slots[index];
                if (slotData && slotData.revealed) {
                    openDetails(slotData, definition);
                } else if (mode === 'reading' && readerState.isReader && readerState.controlsEnabled) {
                    // Every spread enforces sequential (or row-sequential) reveal
                    // server-side, so a click on any card other than the exact
                    // next one used to be silently rejected. revealNext always
                    // targets the right slot, same as the button.
                    postNui('revealNext', {});
                }
            });
            container.appendChild(wrapper);
            if (slots[index] && slots[index].revealed) renderRevealed(wrapper, slots[index], true);
        });
    }

    function updateReadingControls() {
        const revealBtn = document.getElementById('btn-reveal-next');
        const revealAllBtn = document.getElementById('btn-reveal-all');
        const dealBtn = document.getElementById('btn-deal-cards');
        const status = document.getElementById('reading-status');
        setText(document.getElementById('btn-close-session'), readerState.closeButtonText);
        setText(revealBtn, readerState.revealedCount === 0 ? readerState.firstRevealButtonText : readerState.revealButtonText);
        setText(revealAllBtn, readerState.revealAllButtonText);
        setText(dealBtn, readerState.dealButtonText);

        // Three exclusive phases: waiting for the deal, cards travelling, reading.
        const awaitingDeal = readerState.awaitDeal === true;
        dealBtn.hidden = !awaitingDeal || !readerState.isReader;
        const canReveal = !awaitingDeal && !readerState.isDealing;
        revealBtn.hidden = !canReveal || !readerState.isReader || !readerState.controlsEnabled || readerState.revealedCount >= readerState.slotCount;
        revealAllBtn.hidden = revealBtn.hidden || !readerState.allowRevealAll;

        if (awaitingDeal) {
            setText(status, readerState.isReader ? readerState.dealButtonText : readerState.dealWaitingText);
        } else if (readerState.isDealing) {
            setText(status, readerState.dealingText);
        } else {
            setText(status, readerState.isReader && readerState.controlsEnabled ? readerState.yourTurnText : readerState.waitingText);
        }
    }

    /* The deck is outside the board, so it cannot read --slot-w. Size it from a
       dealt card instead, scale included, so both match on every spread. */
    function syncDeckSize(board) {
        const deck = document.getElementById('deal-deck');
        const slot = board.querySelector('.slot');
        const frame = slot && slot.querySelector('.card-slot-frame');
        if (frame == null || frame.offsetWidth < 1) return;
        // offsetWidth is the untransformed size; apply the slot and board scales
        // by hand so a rotated slot does not report its bounding box instead.
        const scale = (Number(slot.style.getPropertyValue('--slot-scale')) || 1)
            * (Number(board.style.getPropertyValue('--board-scale')) || 1);
        deck.style.width = `${Math.round(frame.offsetWidth * scale)}px`;
        deck.style.height = `${Math.round(frame.offsetHeight * scale)}px`;
    }

    /* Cards fly in from the deck stack. The offset is measured per slot right
       before the animation runs, because slot positions depend on the board
       size, which depends on the viewport. */
    function runDealAnimation(board, perCardDelay, travelDuration) {
        const deck = document.getElementById('deal-deck');
        deck.hidden = false;
        syncDeckSize(board);
        const deckRect = deck.getBoundingClientRect();
        // is-dealing also holds opacity at 0, so it must land before
        // awaiting-deal is dropped -- otherwise there is a reflow-wide gap
        // with neither class present where slots flash at full opacity.
        board.classList.remove('is-dealing');
        void board.offsetWidth;
        board.style.setProperty('--deal-delay', `${perCardDelay}ms`);
        board.style.setProperty('--deal-travel', `${travelDuration}ms`);
        board.querySelectorAll('.slot').forEach((slot) => {
            const rect = slot.getBoundingClientRect();
            slot.style.setProperty('--deal-from-x', `${Math.round(deckRect.left + deckRect.width / 2 - (rect.left + rect.width / 2))}px`);
            slot.style.setProperty('--deal-from-y', `${Math.round(deckRect.top + deckRect.height / 2 - (rect.top + rect.height / 2))}px`);
        });
        board.classList.add('is-dealing');
        // Slots must become interactive again once they are on their way in.
        board.classList.remove('awaiting-deal');
    }

    function buildReadingScreen(data) {
        readerState = Object.assign({}, readerState, {
            isReader: !!data.isReader,
            controlsEnabled: data.state === 'reading' || data.controlsEnabled === true,
            revealedCount: countRevealed(data.slots),
            slotCount: slotDefs(data).length,
            spread: data.spread || readerState.spread,
            slots: data.slots || [],
            closeButtonText: data.closeButtonText || '',
            firstRevealButtonText: data.firstRevealButtonText || data.revealButtonText || '',
            revealButtonText: data.revealButtonText || '',
            revealAllButtonText: data.revealAllButtonText || '',
            allowRevealAll: data.allowRevealAll === true,
            waitingText: data.waitingText || '',
            yourTurnText: data.yourTurnText || '',
            dealButtonText: data.dealButtonText || readerState.dealButtonText || '',
            dealWaitingText: data.dealWaitingText || readerState.dealWaitingText || '',
            dealingText: data.dealingText || readerState.dealingText || '',
            awaitDeal: data.awaitDeal === true,
            isDealing: data.isDealing === true,
        });
        setText(document.getElementById('reading-spread-label'), data.spreadLabel || (data.spread && data.spread.label) || '');
        buildBoard(document.getElementById('reading-slots'), data, 'reading');
        updateReadingControls();
    }

    function buildPlayerOptions(data) {
        const container = document.getElementById('player-options');
        clearChildren(container);
        selectedPlayerId = null;
        document.getElementById('btn-confirm-player').disabled = true;

        const players = data.players || [];
        if (players.length === 0) {
            const empty = document.createElement('p');
            setText(empty, data.emptyText || '');
            container.appendChild(empty);
            return;
        }

        players.forEach((player) => {
            const option = document.createElement('button');
            option.type = 'button';
            option.className = 'spread-option';
            option.dataset.playerId = String(player.id);
            const title = document.createElement('strong');
            const meta = document.createElement('span');
            setText(title, player.name || `#${player.id}`);
            setText(meta, `${player.distance ?? '?'} m`);
            option.appendChild(title);
            option.appendChild(meta);
            option.addEventListener('click', () => {
                selectedPlayerId = player.id;
                container.querySelectorAll('.spread-option').forEach((el) => el.classList.toggle('is-selected', el === option));
                document.getElementById('btn-confirm-player').disabled = false;
            });
            container.appendChild(option);
        });
    }

    function buildSpreadOptions(data) {
        const container = document.getElementById('spread-options');
        clearChildren(container);
        selectedSpreadKey = null;
        const settings = data.selectionSettings || {};
        (data.spreads || []).forEach((spread) => {
            const option = document.createElement('button');
            option.type = 'button';
            option.className = 'spread-option';
            option.dataset.spreadKey = spread.key || '';
            const title = document.createElement('strong');
            const meta = document.createElement('span');
            const description = document.createElement('small');
            setText(title, spread.name || spread.label || spread.key || '');
            const metaParts = [`${spread.cardCount || 0} kart`];
            if (settings.showDifficulty !== false && spread.difficulty) metaParts.push(spread.difficulty);
            if (settings.showEstimatedDuration !== false && spread.estimatedDuration) metaParts.push(spread.estimatedDuration);
            setText(meta, metaParts.join(' · '));
            setText(description, spread.shortDescription || '');
            option.appendChild(title);
            option.appendChild(meta);
            option.appendChild(description);
            if (settings.showPreview !== false && Array.isArray(spread.slots)) {
                const preview = document.createElement('span');
                preview.className = 'spread-preview';
                spread.slots.forEach((slot) => {
                    const previewSlot = document.createElement('i');
                    previewSlot.className = 'spread-preview-slot';
                    previewSlot.style.left = `${Number(slot.x == null ? 50 : slot.x)}%`;
                    previewSlot.style.top = `${Number(slot.y == null ? 50 : slot.y)}%`;
                    previewSlot.style.transform = `translate(-50%, -50%) rotate(${Number(slot.rotation || 0)}deg)`;
                    previewSlot.style.zIndex = String(Number(slot.zIndex || 1));
                    preview.appendChild(previewSlot);
                });
                option.appendChild(preview);
            }
            option.addEventListener('click', () => {
                selectedSpreadKey = spread.key;
                container.querySelectorAll('.spread-option').forEach((el) => el.classList.toggle('is-selected', el === option));
                document.getElementById('btn-confirm-spread').disabled = !selectedSpreadKey;
                if (settings.requireConfirmation === false && selectedSpreadKey) {
                    postNui('selectSpread', { spreadKey: selectedSpreadKey });
                }
            });
            container.appendChild(option);
        });
    }

    on('openPlayerSelection', (data) => {
        setText(document.getElementById('player-selection-title'), data.titleText || '');
        setText(document.getElementById('btn-confirm-player'), data.confirmText || '');
        setText(document.getElementById('btn-cancel-player'), data.closeButtonText || '');
        const soloBtn = document.getElementById('btn-solo-player');
        setText(soloBtn, data.soloText || '');
        soloBtn.hidden = !data.allowSolo;
        soloBtn.dataset.selfId = data.selfId == null ? '' : String(data.selfId);
        buildPlayerOptions(data);
        showScreen('player-selection');
    });

    on('showInvite', (data) => {
        setSessionId(data.sessionId);
        setText(document.getElementById('invitation-title'), data.titleText);
        setText(document.getElementById('invitation-body'), data.bodyText);
        setText(document.getElementById('btn-accept-invite'), data.acceptText);
        setText(document.getElementById('btn-reject-invite'), data.rejectText);
        showScreen('invitation');
    });

    on('openSpreadSelection', (data) => {
        setSessionId(data.sessionId);
        setText(document.getElementById('spread-selection-title'), data.titleText || 'Dizilim Seçimi');
        setText(document.getElementById('btn-confirm-spread'), data.confirmText || 'Onayla');
        setText(document.getElementById('btn-cancel-spread'), data.closeButtonText || 'Kapat');
        buildSpreadOptions(data);
        showScreen('spread-selection');
    });

    on('showSpreadWaiting', (data) => {
        setSessionId(data.sessionId);
        setText(document.getElementById('spread-waiting-text'), data.text || 'Falcı dizilim seçiyor...');
        setText(document.getElementById('btn-close-waiting'), data.closeButtonText || 'Kapat');
        showScreen('spread-waiting');
    });

    on('showShuffle', (data) => {
        window.TarotAudio.configure({ enabled: data.enableCardSounds, volume: data.cardSoundVolume });
        setSessionId(data.sessionId);
        buildReadingScreen(data);
        showScreen('reading');
        window.TarotAudio.play('shuffle');
    });

    on('loadSpread', (data) => {
        window.TarotAudio.configure({ enabled: data.enableCardSounds, volume: data.cardSoundVolume });
        if (!matchesSession(data.sessionId)) setSessionId(data.sessionId);
        buildReadingScreen(Object.assign({}, data, { state: 'dealing', controlsEnabled: false, slots: data.slots || [] }));
        document.getElementById('deal-deck').hidden = data.awaitDeal !== true;
        showScreen('reading');
        syncDeckSize(document.getElementById('reading-slots'));
        window.TarotAudio.play('shuffle');
    });

    on('dealSpread', (data) => {
        if (!matchesSession(data.sessionId)) return;
        const board = document.getElementById('reading-slots');
        const perCardDelay = Number(data.perCardDelay || 0);
        const travel = Number(data.cardTravelDuration || 0);
        readerState = Object.assign({}, readerState, { awaitDeal: false, isDealing: true });
        updateReadingControls();
        setTimeout(() => {
            runDealAnimation(board, perCardDelay, travel);
            (board.querySelectorAll('.slot')).forEach((_, index) => {
                setTimeout(() => window.TarotAudio.play('draw'), index * perCardDelay);
            });
        }, Number(data.startDelay || 0));
    });

    on('readingReady', (data) => {
        if (!matchesSession(data.sessionId)) return;
        document.getElementById('deal-deck').hidden = true;
        readerState = Object.assign({}, readerState, { controlsEnabled: true, awaitDeal: false, isDealing: false });
        updateReadingControls();
    });

    on('revealSlot', (data) => {
        if (!matchesSession(data.sessionId)) return;
        const container = document.getElementById('reading-slots');
        const slot = Number(data.slotIndex || data.slot);
        if (!Number.isInteger(slot) || slot < 1 || slot > container.querySelectorAll('.slot').length) return;
        revealSlot(container, slot, data, data.animationDelay, () => {
            readerState = Object.assign({}, readerState, { revealedCount: readerState.revealedCount + 1 });
            readerState.slots = readerState.slots.map((item, index) => index + 1 === slot ? Object.assign({}, item, data, { revealed: true }) : item);
            updateReadingControls();
        });
    });

    on('slotsRevealedBatch', (data) => {
        if (!matchesSession(data.sessionId)) return;
        (data.cards || []).forEach((card, index) => {
            const delay = index * 120;
            setTimeout(() => {
                const container = document.getElementById('reading-slots');
                revealSlot(container, Number(card.slotIndex), card, 0, () => {
                    readerState = Object.assign({}, readerState, { revealedCount: readerState.revealedCount + 1 });
                    updateReadingControls();
                });
            }, delay);
        });
    });

    on('renderSnapshot', (data) => {
        if (!matchesSession(data.sessionId)) return;
        setSessionId(data.sessionId);
        if (data.state === 'spread_selection') {
            showScreen('spread-selection');
            return;
        }
        buildReadingScreen(data);
        showScreen(data.state === 'completed' ? 'summary' : 'reading');
    });

    on('showSummary', (data) => {
        if (!matchesSession(data.sessionId)) return;
        // Reuses the reading screen/panel in place instead of switching to
        // the separate summary section -- that hard cut (screen-reading
        // hidden, screen-summary shown a moment later) read as the panel
        // closing and a different one opening. Updating the same panel's
        // content keeps it visually continuous.
        setText(document.getElementById('reading-spread-label'), data.titleText || data.spreadLabel || 'Fal Sonucu');
        setText(document.getElementById('btn-close-session'), data.closeButtonText || 'Kapat');
        setText(document.getElementById('reading-status'), '');
        buildBoard(document.getElementById('reading-slots'), data, 'summary');
        document.getElementById('deal-deck').hidden = true;
        document.getElementById('btn-deal-cards').hidden = true;
        document.getElementById('btn-reveal-next').hidden = true;
        document.getElementById('btn-reveal-all').hidden = true;
        readerState = Object.assign({}, readerState, { controlsEnabled: false, awaitDeal: false, isDealing: false });
        showScreen('reading');
        window.TarotAudio.play('complete');
    });

    document.getElementById('btn-confirm-player').addEventListener('click', () => {
        if (selectedPlayerId != null) postNui('selectPlayer', { playerId: selectedPlayerId });
    });
    document.getElementById('btn-solo-player').addEventListener('click', (event) => {
        const selfId = Number(event.currentTarget.dataset.selfId);
        if (Number.isFinite(selfId)) postNui('selectPlayer', { playerId: selfId });
    });
    document.getElementById('btn-cancel-player').addEventListener('click', () => postNui('cancelPlayerSelection', {}));
    document.getElementById('btn-accept-invite').addEventListener('click', () => postNui('acceptInvite', {}));
    document.getElementById('btn-reject-invite').addEventListener('click', () => { postNui('rejectInvite', {}); hideAll(); });
    document.getElementById('btn-confirm-spread').addEventListener('click', () => {
        if (selectedSpreadKey) postNui('selectSpread', { spreadKey: selectedSpreadKey });
    });
    document.getElementById('btn-cancel-spread').addEventListener('click', () => postNui('closeSession', {}));
    document.getElementById('btn-close-waiting').addEventListener('click', () => postNui('closeSession', {}));
    document.getElementById('btn-deal-cards').addEventListener('click', () => {
        // Hide immediately so a double click cannot fire two deals.
        document.getElementById('btn-deal-cards').hidden = true;
        postNui('startDeal', {});
    });
    document.getElementById('btn-reveal-next').addEventListener('click', () => postNui('revealNext', {}));
    document.getElementById('btn-reveal-all').addEventListener('click', () => postNui('revealAll', {}));
    document.getElementById('btn-close-session').addEventListener('click', () => postNui('closeSession', {}));
    document.getElementById('btn-close-summary').addEventListener('click', () => postNui('closeSession', {}));
    document.getElementById('btn-close-details').addEventListener('click', () => {
        document.getElementById('card-details').hidden = true;
    });

    on('showClosing', (data) => {
        if (!matchesSession(data.sessionId)) return;
        setText(document.getElementById('closing-text'), data.text);
        showScreen('closing');
    });

    on('hide', () => {
        hideAll();
        setSessionId(null);
        selectedSpreadKey = null;
        document.getElementById('card-details').hidden = true;
    });

    hideAll();
})();
