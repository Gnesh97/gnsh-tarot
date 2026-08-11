const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const test = require('node:test');

const root = path.resolve(__dirname, '..');
const interaction = fs.readFileSync(path.join(root, 'client', 'interaction.lua'), 'utf8');
const tables = fs.readFileSync(path.join(root, 'client', 'tables.lua'), 'utf8');

test('/tarotbasla discovers an owned table when interaction registration lags', () => {
    assert.match(tables, /function TarotTables\.GetNearestOwned/);
    assert.match(tables, /tarot:owner/);
    assert.match(interaction, /TarotTables\.GetNearestOwned/);
    assert.match(interaction, /tonumber\(Entity\(entity\)\.state\['tarot:owner'\]\)/);
});
