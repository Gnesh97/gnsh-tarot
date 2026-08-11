const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const test = require('node:test');

const resourceRoot = path.resolve(__dirname, '..');
const appSource = fs.readFileSync(path.join(resourceRoot, 'html', 'js', 'app.js'), 'utf8');
const cardsCss = fs.readFileSync(path.join(resourceRoot, 'html', 'css', 'cards.css'), 'utf8');

test('generic spread board renders metadata without carousel overlap', () => {
    assert.match(appSource, /buildBoard\(/);
    assert.match(appSource, /--slot-x/);
    assert.match(appSource, /--slot-y/);
    assert.match(cardsCss, /\.spread-board \.slot\s*\{/);
    assert.match(cardsCss, /\.spread-board \.card-meaning\s*\{[\s\S]*display:\s*none/);
});
