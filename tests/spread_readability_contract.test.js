const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const test = require('node:test');

const root = path.resolve(__dirname, '..');
const config = fs.readFileSync(path.join(root, 'config.lua'), 'utf8');
const app = fs.readFileSync(path.join(root, 'html', 'js', 'app.js'), 'utf8');
const css = fs.readFileSync(path.join(root, 'html', 'css', 'cards.css'), 'utf8');

test('spread layouts keep cards spaced and labels readable', () => {
    assert.match(config, /horseshoe_seven = \{[\s\S]*boardScale = 1\.0/);
    assert.match(config, /gypsy_twenty_one = \{[\s\S]*boardScale = 1\.0/);
    assert.match(config, /scale = 1\.0/);
    // Card size must follow the board, not the viewport, so a card can never
    // outgrow the gap between two slots.
    assert.match(css, /--slot-w: min\(calc\(var\(--board-w\)[\s\S]*var\(--board-h\)/);
    assert.match(css, /\.spread-board \.slot \{[\s\S]*width: var\(--slot-w\)/);
    assert.match(css, /\.spread-board \.slot-label \{[^}]*max-width: 150%/);
    assert.match(css, /\.spread-board\.compact \.slot-label \{[^}]*max-width: 100%/);
    assert.match(app, /--slot-label-rotation/);
    assert.match(css, /background: rgba\(8, 6, 20, 0\.82\)/);
    assert.match(css, /\.spread-board \.slot-number[\s\S]*rotate\(var\(--slot-label-rotation/);
    assert.match(css, /\.spread-board\.compact \.slot:hover \.slot-label/);
});
