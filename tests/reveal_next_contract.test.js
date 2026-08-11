const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const test = require('node:test');

const resourceRoot = path.resolve(__dirname, '..');

test('reveal-next NUI callback accepts a session-only payload', () => {
    const source = fs.readFileSync(path.join(resourceRoot, 'client', 'nui.lua'), 'utf8');
    const callback = source.match(/RegisterNUICallback\('revealNext',[\s\S]*?\nend\)/);

    assert.ok(callback, 'revealSlot callback should exist');
    assert.doesNotMatch(callback[0], /isValidSlot\(data\.slot\)/);
    assert.match(callback[0], /AllowedNuiActions\.revealNext/);
    assert.match(callback[0], /isCurrentSessionPayload\(data\)/);
    assert.match(callback[0], /TarotSessions\.RevealNext\(\)/);
});
