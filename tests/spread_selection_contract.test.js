const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const test = require('node:test');

const root = path.resolve(__dirname, '..');
const app = fs.readFileSync(path.join(root, 'html', 'js', 'app.js'), 'utf8');
const index = fs.readFileSync(path.join(root, 'html', 'index.html'), 'utf8');
const state = fs.readFileSync(path.join(root, 'html', 'js', 'state.js'), 'utf8');
const server = fs.readFileSync(path.join(root, 'server', 'main.lua'), 'utf8');

test('single NUI contains selection, waiting, reading and summary screens', () => {
    ['screen-spread-selection', 'screen-spread-waiting', 'screen-reading', 'screen-summary'].forEach((id) => {
        assert.match(index, new RegExp(`id="${id}"`));
    });
    assert.match(state, /spread-selection/);
    assert.match(state, /spread-waiting/);
});

test('reader selection is posted from metadata and server validates it', () => {
    assert.match(app, /postNui\('selectSpread', \{ spreadKey: selectedSpreadKey \}\)/);
    assert.match(server, /RegisterNetEvent\('tarot:server:selectSpread'/);
    assert.match(server, /Security\.IsSessionReader\(session, src\)/);
    assert.match(server, /SessionStates\.SPREAD_SELECTION/);
    assert.match(server, /spread\.enabled == false/);
});

test('generic board supports placement metadata and card details', () => {
    assert.match(app, /definition\.x/);
    assert.match(app, /definition\.rotation/);
    assert.match(app, /openDetails/);
    assert.match(index, /id="card-details"/);
});

test('spread selection supports configurable metadata and a compact preview', () => {
    assert.match(app, /selectionSettings/);
    assert.match(app, /showPreview !== false/);
    assert.match(app, /spread-preview-slot/);
});
