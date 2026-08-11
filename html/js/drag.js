// Allows every Tarot panel to be repositioned without interfering with its
// buttons and form controls. Offsets are clamped so the panel remains visible.
(function () {
    const INTERACTIVE_SELECTOR = '[data-no-drag], button, a, input, select, textarea, .slot';
    const VIEWPORT_MARGIN = 8;
    const initializedPanels = new WeakSet();

    function numberFromStyle(value) {
        const parsed = Number.parseFloat(value);
        return Number.isFinite(parsed) ? parsed : 0;
    }

    function clamp(value, minimum, maximum) {
        if (minimum > maximum) return 0;
        return Math.min(maximum, Math.max(minimum, value));
    }

    function isInteractive(target) {
        return target != null
            && typeof target.closest === 'function'
            && target.closest(INTERACTIVE_SELECTOR) != null;
    }

    function enablePanel(panel) {
        if (initializedPanels.has(panel)) return;
        initializedPanels.add(panel);

        let dragState = null;

        panel.addEventListener('pointerdown', (event) => {
            if (event.button !== 0 || isInteractive(event.target)) return;

            const startLeft = numberFromStyle(panel.style.left);
            const startTop = numberFromStyle(panel.style.top);
            const rect = panel.getBoundingClientRect();
            dragState = {
                pointerId: event.pointerId,
                startX: event.clientX,
                startY: event.clientY,
                startLeft,
                startTop,
                baseLeft: rect.left - startLeft,
                baseTop: rect.top - startTop,
                width: rect.width,
                height: rect.height,
            };

            panel.classList.add('is-dragging');
            panel.setPointerCapture(event.pointerId);
            event.preventDefault();
        });

        window.addEventListener('pointermove', (event) => {
            if (dragState == null || event.pointerId !== dragState.pointerId) return;

            const desiredLeft = dragState.startLeft + event.clientX - dragState.startX;
            const desiredTop = dragState.startTop + event.clientY - dragState.startY;
            const minimumLeft = VIEWPORT_MARGIN - dragState.baseLeft;
            const maximumLeft = window.innerWidth - VIEWPORT_MARGIN
                - dragState.baseLeft - dragState.width;
            const minimumTop = VIEWPORT_MARGIN - dragState.baseTop;
            const maximumTop = window.innerHeight - VIEWPORT_MARGIN
                - dragState.baseTop - dragState.height;

            panel.style.left = `${clamp(desiredLeft, minimumLeft, maximumLeft)}px`;
            panel.style.top = `${clamp(desiredTop, minimumTop, maximumTop)}px`;
        });

        function stopDragging(event) {
            if (dragState == null || event.pointerId !== dragState.pointerId) return;
            panel.classList.remove('is-dragging');
            if (typeof panel.hasPointerCapture !== 'function'
                || panel.hasPointerCapture(event.pointerId)) {
                panel.releasePointerCapture(event.pointerId);
            }
            dragState = null;
        }

        window.addEventListener('pointerup', stopDragging);
        window.addEventListener('pointercancel', stopDragging);

        // CEF can revoke NUI focus mid-drag without ever delivering pointerup/
        // pointercancel to this document -- window 'blur' still fires in that
        // case, so use it to drop the stuck drag immediately.
        window.addEventListener('blur', () => {
            if (dragState == null) return;
            panel.classList.remove('is-dragging');
            dragState = null;
        });
    }

    function init() {
        document.querySelectorAll('.panel').forEach(enablePanel);
    }

    // NUI focus can be revoked mid-drag (player presses a game key that closes
    // the UI while the mouse button is still down) -- CEF then stops
    // delivering pointer events to this document entirely, so pointerup/
    // pointercancel never fire and the panel is left stuck in .is-dragging
    // (which also blocks the mouse-leave transparency fade, since that rule
    // requires :not(.is-dragging)). Screen transitions are a safe point to
    // clear that stale state.
    function resetAll() {
        document.querySelectorAll('.panel.is-dragging').forEach((panel) => {
            panel.classList.remove('is-dragging');
        });
    }

    window.TarotDrag = { init, resetAll };
    init();
})();
