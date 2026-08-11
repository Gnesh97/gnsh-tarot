// Outbound POSTs to the Lua RegisterNUICallback handlers, and the inbound
// message dispatcher. Actions are whitelisted both directions.
(function () {
    function resourceName() {
        return typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'tarot';
    }

    function postNui(action, data) {
        if (!window.TarotSecurity.isAllowedAction(action)) return Promise.resolve(null);

        const payload = Object.assign({}, data || {});
        const sessionId = window.TarotState.getSessionId();
        if (sessionId != null && payload.sessionId == null) {
            payload.sessionId = sessionId;
        }

        return fetch(`https://${resourceName()}/${action}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify(payload),
        }).catch(() => null);
    }

    const handlers = {};

    function on(action, handler) {
        handlers[action] = handler;
    }

    window.addEventListener('message', (event) => {
        const message = event.data;
        if (message == null || typeof message.action !== 'string') return;

        const handler = handlers[message.action];
        if (typeof handler === 'function') {
            handler(message.data || {});
        }
    });

    window.TarotNui = { postNui, on };
})();
