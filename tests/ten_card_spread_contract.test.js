const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const test = require('node:test');

const resourceRoot = path.resolve(__dirname, '..');
const constants = fs.readFileSync(path.join(resourceRoot, 'shared', 'constants.lua'), 'utf8');
const config = fs.readFileSync(path.join(resourceRoot, 'config.lua'), 'utf8');
const security = fs.readFileSync(path.join(resourceRoot, 'html', 'js', 'security.js'), 'utf8');

test('the configured spread registry supports five layouts and 21 slots', () => {
    ['three_card', 'horseshoe_seven', 'pentagram', 'celtic_cross', 'gypsy_twenty_one'].forEach((key) => {
        assert.match(config, new RegExp(`${key}\\s*=\\s*\\{`));
        assert.match(constants, new RegExp(`${key}\\s*=\\s*true`));
    });
    assert.doesNotMatch(config, /single_card\s*=\s*\{/);
    assert.doesNotMatch(config, /ten_card\s*=\s*\{/);
    assert.match(config, /cardCount = 21/);
    assert.match(constants, /MaxSlotIndex\s*=\s*21/);
    assert.match(security, /const MAX_SLOT_INDEX = 21/);
});
