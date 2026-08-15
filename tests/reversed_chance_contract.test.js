const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const test = require('node:test');

const root = path.resolve(__dirname, '..');
const configSource = fs.readFileSync(path.join(root, 'config.lua'), 'utf8');

test('reversed cards are configured at a twenty percent chance', () => {
    const match = configSource.match(/Config\.ReversedChance\s*=\s*(\d+)/);

    assert.notEqual(match, null);
    assert.equal(Number(match[1]), 20);
});
