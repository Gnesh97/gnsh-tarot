const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const test = require('node:test');

const root = path.resolve(__dirname, '..');
const server = fs.readFileSync(path.join(root, 'server', 'main.lua'), 'utf8');
const sessions = fs.readFileSync(path.join(root, 'server', 'sessions.lua'), 'utf8');
const client = fs.readFileSync(path.join(root, 'client', 'sessions.lua'), 'utf8');

test('server reveal validates role, state, slot ownership and reveal mode', () => {
    assert.match(server, /Security\.IsSessionReader\(session, src\)/);
    assert.match(server, /session\.state ~= SessionStates\.READING/);
    assert.match(server, /Sessions\.IsSlotAllowed\(session, slotIndex\)/);
    assert.match(server, /slot\.revealed/);
});

test('snapshots expose revealed cards only and preserve spread metadata', () => {
    assert.match(sessions, /cardId = slot\.revealed and slot\.cardId or nil/);
    assert.match(sessions, /cardCount = session\.cardCount/);
    assert.match(sessions, /revealMode = session\.revealMode/);
    assert.match(sessions, /dealRemainingMs/);
});

test('client never invents cards and handles server slot IDs', () => {
    assert.match(client, /validCard\(data\.cardId\)/);
    assert.match(client, /slotIndexForId/);
    assert.match(client, /TriggerServerEvent\('tarot:server:revealSlot', currentSession\.id, slotId\)/);
});
