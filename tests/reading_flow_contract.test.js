const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const test = require('node:test');

const resourceRoot = path.resolve(__dirname, '..');
const appSource = fs.readFileSync(path.join(resourceRoot, 'html', 'js', 'app.js'), 'utf8');
const cardsSource = fs.readFileSync(path.join(resourceRoot, 'html', 'js', 'cards.js'), 'utf8');
const interactionSource = fs.readFileSync(path.join(resourceRoot, 'client', 'interaction.lua'), 'utf8');
const indexSource = fs.readFileSync(path.join(resourceRoot, 'html', 'index.html'), 'utf8');
const cardsCss = fs.readFileSync(path.join(resourceRoot, 'html', 'css', 'cards.css'), 'utf8');

test('spread load starts the reading board in the same NUI root', () => {
    const shuffleHandler = appSource.match(/on\('loadSpread',[\s\S]*?\n    \}\);/);

    assert.ok(shuffleHandler, 'showShuffle handler should exist');
    assert.doesNotMatch(shuffleHandler[0], /showScreen\('shuffle'\)/);
    assert.doesNotMatch(shuffleHandler[0], /setTimeout\(/);
    assert.match(shuffleHandler[0], /buildReadingScreen/);
    assert.match(shuffleHandler[0], /showScreen\('reading'\)/);
});

test('reading flow keeps the reveal button and advances card positions', () => {
    assert.match(appSource, /firstRevealButtonText/);
    assert.match(appSource, /revealedCount/);
    assert.match(appSource, /controlsEnabled/);
    assert.match(appSource, /buildBoard/);
    assert.match(appSource, /postNui\('revealNext'/);
    assert.match(cardsSource, /onComplete/);
    // Carousel rules stay scoped away from the spread board, which renders
    // into the same container and must keep its own sizing.
    assert.match(cardsCss, /\.reading-panel \.slots:not\(\.spread-board\) \.slot\[data-position="left"\]/);
    assert.match(cardsCss, /\.reading-panel \.slots:not\(\.spread-board\) \.slot\[data-position="center"\]/);
});

test('reader chooses a spread after the invitation is accepted', () => {
    assert.doesNotMatch(interactionSource, /selectedSpread/);
    assert.match(appSource, /openSpreadSelection/);
    assert.match(appSource, /postNui\('selectSpread'/);
});

test('the reading panel has one shared action area for reveal and close', () => {
    const readingPanel = indexSource.match(/<section id="screen-reading"[\s\S]*?<\/section>/);

    assert.ok(readingPanel, 'reading screen should exist');
    assert.match(readingPanel[0], /id="reading-spread-label"/);
    assert.match(readingPanel[0], /id="btn-reveal-next"/);
    assert.match(readingPanel[0], /id="btn-close-session"/);
});
