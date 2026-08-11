// Screen visibility + a light sessionId guard. Sequence-gap handling already
// happens Lua-side (client/sessions.lua); this only ignores a message whose
// sessionId doesn't match the session currently on screen.
(function () {
    const SCREENS = ['player-selection', 'invitation', 'spread-selection', 'spread-waiting', 'shuffle', 'reading', 'summary', 'closing'];
    let currentSessionId = null;

    function showScreen(name) {
        document.body.classList.remove('hidden');
        SCREENS.forEach((screenName) => {
            const el = document.getElementById('screen-' + screenName);
            if (el == null) return;
            el.hidden = screenName !== name;
        });
        if (window.TarotDrag) window.TarotDrag.resetAll();
    }

    function hideAll() {
        document.body.classList.add('hidden');
        SCREENS.forEach((screenName) => {
            const el = document.getElementById('screen-' + screenName);
            if (el != null) el.hidden = true;
        });
        if (window.TarotDrag) window.TarotDrag.resetAll();
    }

    function setSessionId(id) {
        currentSessionId = id;
    }

    function getSessionId() {
        return currentSessionId;
    }

    function matchesSession(id) {
        return id == null || currentSessionId == null || id === currentSessionId;
    }

    window.TarotState = { showScreen, hideAll, setSessionId, getSessionId, matchesSession };
})();
