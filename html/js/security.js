// Rendering + outbound-message guards. No innerHTML anywhere in this NUI —
// every text node is set via textContent so a hostile/malformed payload can
// never inject markup.
(function () {
    const ALLOWED_ACTIONS = ['acceptInvite', 'rejectInvite', 'selectSpread', 'shuffleDeck', 'startDeal', 'revealSlot', 'revealNext', 'revealAll', 'closeSession', 'requestSnapshot', 'selectPlayer', 'cancelPlayerSelection'];
    const MAX_SLOT_INDEX = 21;
    const MAX_CARD_ID = 77;

    function setText(el, text) {
        if (el == null) return;
        el.textContent = text == null ? '' : String(text);
    }

    function isKnownCardId(cardId) {
        return Number.isInteger(cardId) && cardId >= 0 && cardId <= MAX_CARD_ID;
    }

    function isValidSlotIndex(slot) {
        return Number.isInteger(slot) && slot >= 1 && slot <= MAX_SLOT_INDEX;
    }

    function isAllowedAction(action) {
        return ALLOWED_ACTIONS.indexOf(action) !== -1;
    }

    window.TarotSecurity = { setText, isKnownCardId, isValidSlotIndex, isAllowedAction };
})();
