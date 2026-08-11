// Builds the slot DOM and drives the flip/reveal sequence. Card-ID and
// slot-index whitelisting happens here via TarotSecurity before anything is
// rendered.
(function () {
    const { setText, isKnownCardId, isValidSlotIndex } = window.TarotSecurity;

    function resourceName() {
        return typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'tarot';
    }

    function resolveCardImage(image) {
        if (typeof image !== 'string' || image.length === 0) return '';

        const normalized = image.replace(/^\/+/, '');
        if (/^(?:https?:|data:|blob:)/i.test(normalized)) return normalized;

        const resourcePath = normalized.indexOf('html/') === 0
            ? normalized
            : 'html/' + normalized;
        return 'https://cfx-nui-' + resourceName() + '/' + resourcePath;
    }

    function buildSlotFrame(cardId, image, name, orientation) {
        const frame = document.createElement('div');
        frame.className = 'card-slot-frame';

        const flipper = document.createElement('div');
        flipper.className = 'card-flipper';

        const back = document.createElement('div');
        back.className = 'card-face card-face-back';

        const front = document.createElement('div');
        front.className = 'card-face card-face-front';

        const art = document.createElement('div');
        art.className = 'card-art' + (orientation === 'reversed' ? ' is-reversed' : '');

        const img = document.createElement('img');
        img.alt = '';
        const fallback = document.createElement('div');
        fallback.className = 'card-name-fallback';
        setText(fallback, name || '');

        img.addEventListener('error', () => {
            art.classList.add('art-missing');
        });

        if (image) {
            img.src = resolveCardImage(image);
        } else {
            art.classList.add('art-missing');
        }

        art.appendChild(img);
        art.appendChild(fallback);
        front.appendChild(art);

        flipper.appendChild(back);
        flipper.appendChild(front);
        frame.appendChild(flipper);

        return { frame, flipper };
    }

    function buildSlot(index, labelText, metadata) {
        const wrapper = document.createElement('div');
        wrapper.className = 'slot';
        wrapper.dataset.slot = String(index);
        if (metadata && metadata.id != null) wrapper.dataset.slotId = String(metadata.id);
        if (metadata && metadata.row != null) wrapper.dataset.row = String(metadata.row);

        const number = document.createElement('div');
        number.className = 'slot-number';
        setText(number, `Kart ${metadata && metadata.id != null ? metadata.id : index}`);
        wrapper.appendChild(number);

        const label = document.createElement('div');
        label.className = 'slot-label';
        setText(label, labelText);
        wrapper.appendChild(label);

        const { frame } = buildSlotFrame(null, null, '', 'upright');
        wrapper.appendChild(frame);

        const orientationEl = document.createElement('div');
        orientationEl.className = 'card-orientation';
        wrapper.appendChild(orientationEl);

        const meaningEl = document.createElement('div');
        meaningEl.className = 'card-meaning';
        wrapper.appendChild(meaningEl);

        wrapper.addEventListener('click', (event) => {
            if (event.target.closest('button')) return;
            wrapper.dispatchEvent(new CustomEvent('tarot:slot-click', { bubbles: true }));
        });

        return wrapper;
    }

    // Single shared overlay: only one card can be hovered at a time, so
    // reusing one fixed element is simpler than templating a new one per card.
    function showZoom(slotData) {
        const overlay = document.getElementById('card-zoom-overlay');
        const frame = overlay && overlay.querySelector('.card-zoom-frame');
        const img = document.getElementById('card-zoom-image');
        const fallback = document.getElementById('card-zoom-fallback');
        const reversedBadge = document.getElementById('card-zoom-reversed-badge');
        const nameLabel = document.getElementById('card-zoom-name');
        if (overlay == null || frame == null || img == null || fallback == null) return;

        // Zoomed art always renders upright so it stays readable; the badge
        // is the only cue that the card was drawn reversed.
        const isReversed = slotData.orientation === 'reversed';
        if (reversedBadge != null) {
            setText(reversedBadge, slotData.orientationLabel || '');
            reversedBadge.hidden = !isReversed;
        }
        setText(fallback, slotData.name || '');
        if (nameLabel != null) setText(nameLabel, slotData.name || '');

        if (slotData.image) {
            frame.classList.remove('art-missing');
            img.onerror = () => frame.classList.add('art-missing');
            img.src = resolveCardImage(slotData.image);
        } else {
            frame.classList.add('art-missing');
            img.removeAttribute('src');
        }

        overlay.classList.add('is-active');
    }

    function hideZoom() {
        const overlay = document.getElementById('card-zoom-overlay');
        if (overlay != null) overlay.classList.remove('is-active');
    }

    function renderRevealed(wrapper, slotData, instant) {
        if (!isKnownCardId(slotData.cardId)) return;

        // Marks the wrapper itself (not just the inner flipper) so CSS can
        // scope hover effects -- like the zoom-on-hover -- to opened cards.
        wrapper.classList.add('is-revealed');
        wrapper.addEventListener('mouseenter', () => showZoom(slotData));
        wrapper.addEventListener('mouseleave', hideZoom);

        const oldFrame = wrapper.querySelector('.card-slot-frame');
        const { frame, flipper } = buildSlotFrame(slotData.cardId, slotData.image, slotData.name, slotData.orientation);
        if (oldFrame != null) {
            wrapper.replaceChild(frame, oldFrame);
        } else {
            wrapper.insertBefore(frame, wrapper.querySelector('.card-orientation'));
        }

        setText(wrapper.querySelector('.card-orientation'), slotData.orientationLabel || '');
        setText(wrapper.querySelector('.card-meaning'), slotData.meaning || '');

        if (instant) {
            // Snapshot/rebuild renders (spread load, resync, summary) show
            // already-open cards as already-open -- only a live reveal via
            // revealSlot() should play the flip.
            flipper.classList.add('no-flip-anim');
            flipper.classList.add('is-revealed');
            void flipper.offsetWidth;
            flipper.classList.remove('no-flip-anim');
            return;
        }

        // Delay the flip a frame so the browser registers the initial
        // (unrevealed) transform before transitioning to rotateY(180deg).
        requestAnimationFrame(() => {
            requestAnimationFrame(() => {
                flipper.classList.add('is-revealed');
            });
        });
    }

    function revealSlot(container, slot, slotData, animationDelay, onComplete) {
        if (!isValidSlotIndex(slot)) return;
        const wrapper = container.querySelector(`.slot[data-slot="${slot}"]`);
        if (wrapper == null) return;

        const delay = Number.isFinite(animationDelay) ? animationDelay : 0;
        window.TarotAudio.play('draw');
        setTimeout(() => {
            window.TarotAudio.play('flip');
            renderRevealed(wrapper, slotData);
            if (typeof onComplete === 'function') onComplete();
        }, delay);
    }

    window.TarotCards = { buildSlot, renderRevealed, revealSlot };
})();
