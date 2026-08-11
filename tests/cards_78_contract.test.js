const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const test = require('node:test');

const root = path.resolve(__dirname, '..');
const cardsSource = fs.readFileSync(path.join(root, 'shared', 'cards.lua'), 'utf8');
const securitySource = fs.readFileSync(path.join(root, 'html', 'js', 'security.js'), 'utf8');
const cardsJsSource = fs.readFileSync(path.join(root, 'html', 'js', 'cards.js'), 'utf8');
const cardDefinitions = [...cardsSource.matchAll(
    /\{ id = (\d+),\s+key = '([^']+)',\s+name = '([^']+)',\s+image = '([^']+)' \}/g,
)];

test('deck contains every card ID from 0 through 77', () => {
    assert.equal(cardDefinitions.length, 78);
    assert.deepEqual(
        cardDefinitions.map((match) => Number(match[1])),
        Array.from({ length: 78 }, (_, index) => index),
    );
});

test('every deck card points to an existing NUI image', () => {
    for (const match of cardDefinitions) {
        const imagePath = path.join(root, 'html', match[4]);
        assert.equal(fs.existsSync(imagePath), true, match[4]);
    }
});

test('NUI accepts all server-issued card IDs', () => {
    assert.match(securitySource, /const MAX_CARD_ID = 77/);
    assert.match(securitySource, /cardId <= MAX_CARD_ID/);
});

test('NUI resolves card art through the resource asset scope', () => {
    assert.equal(cardsJsSource.includes('function resolveCardImage(image)'), true);
    assert.match(cardsJsSource, /https:\/\/cfx-nui-/);
    assert.match(cardsJsSource, /'html\/' \+ normalized/);
});
