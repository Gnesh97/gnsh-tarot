const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const test = require('node:test');

const root = path.resolve(__dirname, '..');
const seating = fs.readFileSync(path.join(root, 'client', 'seating.lua'), 'utf8');

test('seated animation remains active until the session is closed', () => {
    const completedHandler = seating.match(
        /RegisterNetEvent\('tarot:client:sessionCompleted',[\s\S]*?\nend\)/,
    );
    const closedHandler = seating.match(
        /RegisterNetEvent\('tarot:client:sessionClosed',[\s\S]*?\nend\)/,
    );

    assert.equal(completedHandler, null, 'completion must not stand the character up');
    assert.ok(closedHandler, 'session close handler should exist');
    assert.match(closedHandler[0], /TarotSeating\.StandUp\(\)/);
});
