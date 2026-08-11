const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const test = require('node:test');

const resourceRoot = path.resolve(__dirname, '..');
const cardsCss = fs.readFileSync(path.join(resourceRoot, 'html', 'css', 'cards.css'), 'utf8');

test('ten-card summary fits the viewport and remains scrollable', () => {
    assert.match(cardsCss, /\.summary-panel\s*\{[\s\S]*max-height:\s*calc\(100vh/);
    assert.match(cardsCss, /\.summary-panel\s*\{[\s\S]*overflow-y:\s*auto/);
    assert.match(cardsCss, /\.summary-panel \.slots\s*\{[\s\S]*grid-template-columns/);
});

test('fallback names remain readable on reversed cards', () => {
    assert.match(cardsCss, /\.card-art\.is-reversed \.card-name-fallback\s*\{[\s\S]*rotate\(180deg\)/);
});
