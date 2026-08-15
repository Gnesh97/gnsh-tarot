const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const test = require('node:test');

const root = path.resolve(__dirname, '..');
const deckSource = fs.readFileSync(path.join(root, 'server', 'deck.lua'), 'utf8');
const sessionsSource = fs.readFileSync(path.join(root, 'server', 'sessions.lua'), 'utf8');

test('the server builds a deck by shuffling card ids without replacing entries', () => {
    assert.match(deckSource, /local ids = \{\}/);
    assert.match(deckSource, /ids\[#ids \+ 1\] = card\.id/);
    assert.match(deckSource, /for i = #ids, 2, -1 do/);
    assert.match(deckSource, /ids\[i\], ids\[j\] = ids\[j\], ids\[i\]/);
    assert.match(deckSource, /deck\[i\] = \{ cardId = ids\[i\]/);
});

test('a reading rejects a card id that has already been revealed', () => {
    assert.match(sessionsSource, /session\.drawnCardIds = \{\}/);
    assert.match(sessionsSource, /local drawnCardIds = session\.drawnCardIds or \{\}/);
    assert.match(sessionsSource, /if drawnCardIds\[drawn\.cardId\] then return false end/);
    assert.match(sessionsSource, /drawnCardIds\[drawn\.cardId\] = true/);
});
