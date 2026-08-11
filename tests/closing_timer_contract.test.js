const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const test = require('node:test');

const root = path.resolve(__dirname, '..');
const nui = fs.readFileSync(path.join(root, 'client', 'nui.lua'), 'utf8');

// Starting a new reading on the same table within the closing screen's delay
// used to be torn down by the previous session's pending Hide.
test('delayed hide after the closing screen is generation guarded', () => {
    assert.match(nui, /uiGeneration = uiGeneration \+ 1/);
    assert.match(nui, /local generation = uiGeneration\s*\n\s*SetTimeout\(4000, function\(\)\s*\n\s*if generation ~= uiGeneration then return end/);
});
