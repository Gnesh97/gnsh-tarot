const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const test = require('node:test');

const root = path.resolve(__dirname, '..');
const cardsCss = fs.readFileSync(path.join(root, 'html', 'css', 'cards.css'), 'utf8');

test('Celtic Cross staff keeps a measurable card column', () => {
    const staffRule = cardsCss.match(
        /\.spread-board\[data-spread="celtic_cross"\] \.slot\[data-slot-id="7"\],[\s\S]*?\n\}/,
    );
    const frameRule = cardsCss.match(
        /\.spread-board\[data-spread="celtic_cross"\] \.slot\[data-slot-id="7"\] \.card-slot-frame,[\s\S]*?\n\}/,
    );

    assert.ok(staffRule, 'Celtic Cross staff rule should exist');
    assert.match(staffRule[0], /grid-template-columns:\s*minmax\(0,\s*1fr\)\s+minmax\(90px,\s*160px\)/);
    assert.match(staffRule[0], /grid-template-rows:\s*auto auto auto auto/);
    assert.match(staffRule[0], /width:\s*calc\(var\(--slot-w\)\s*\+\s*170px\)/);

    assert.ok(frameRule, 'Celtic Cross staff frame rule should exist');
    assert.match(frameRule[0], /width:\s*100%/);
});
