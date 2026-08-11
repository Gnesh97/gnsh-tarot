const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const test = require('node:test');
const vm = require('node:vm');

const dragSource = fs.readFileSync(
    path.resolve(__dirname, '..', 'html', 'js', 'drag.js'),
    'utf8'
);

function createHarness(targetIsInteractive = false) {
    const panelListeners = {};
    const windowListeners = {};
    const classes = new Set();
    const panel = {
        style: { left: '', top: '' },
        classList: {
            add: (name) => classes.add(name),
            remove: (name) => classes.delete(name),
        },
        addEventListener: (name, handler) => { panelListeners[name] = handler; },
        setPointerCapture: () => {},
        releasePointerCapture: () => {},
        getBoundingClientRect: () => ({ left: 300, top: 200, right: 700, bottom: 500, width: 400, height: 300 }),
    };
    const target = {
        closest: () => targetIsInteractive ? {} : null,
    };
    const context = {
        window: {
            innerWidth: 1000,
            innerHeight: 800,
            addEventListener: (name, handler) => { windowListeners[name] = handler; },
        },
        document: {
            querySelectorAll: () => [panel],
        },
    };

    vm.runInNewContext(dragSource, context);
    context.window.TarotDrag.init();

    return { panel, panelListeners, windowListeners, target, classes };
}

test('dragging a panel with the primary mouse button updates its position', () => {
    const harness = createHarness();
    harness.panelListeners.pointerdown({
        button: 0,
        clientX: 400,
        clientY: 300,
        pointerId: 1,
        target: harness.target,
        preventDefault: () => {},
    });
    harness.windowListeners.pointermove({ clientX: 480, clientY: 350, pointerId: 1 });

    assert.equal(harness.panel.style.left, '80px');
    assert.equal(harness.panel.style.top, '50px');
    assert.equal(harness.classes.has('is-dragging'), true);
});

test('interactive controls do not start panel dragging', () => {
    const harness = createHarness(true);
    harness.panelListeners.pointerdown({
        button: 0,
        clientX: 400,
        clientY: 300,
        pointerId: 2,
        target: harness.target,
        preventDefault: () => {},
    });

    assert.equal(harness.classes.has('is-dragging'), false);
    assert.equal(harness.panel.style.left, '');
});

test('releasing the pointer stops further movement', () => {
    const harness = createHarness();
    harness.panelListeners.pointerdown({
        button: 0,
        clientX: 400,
        clientY: 300,
        pointerId: 3,
        target: harness.target,
        preventDefault: () => {},
    });
    harness.windowListeners.pointermove({ clientX: 420, clientY: 320, pointerId: 3 });
    harness.windowListeners.pointerup({ pointerId: 3 });
    harness.windowListeners.pointermove({ clientX: 500, clientY: 500, pointerId: 3 });

    assert.equal(harness.panel.style.left, '20px');
    assert.equal(harness.panel.style.top, '20px');
    assert.equal(harness.classes.has('is-dragging'), false);
});

test('dragging is clamped to the visible viewport', () => {
    const harness = createHarness();
    harness.panelListeners.pointerdown({
        button: 0,
        clientX: 400,
        clientY: 300,
        pointerId: 4,
        target: harness.target,
        preventDefault: () => {},
    });
    harness.windowListeners.pointermove({ clientX: -1000, clientY: -1000, pointerId: 4 });

    assert.equal(harness.panel.style.left, '-292px');
    assert.equal(harness.panel.style.top, '-192px');
});

test('secondary mouse buttons do not start dragging', () => {
    const harness = createHarness();
    harness.panelListeners.pointerdown({
        button: 2,
        clientX: 400,
        clientY: 300,
        pointerId: 5,
        target: harness.target,
        preventDefault: () => {},
    });

    assert.equal(harness.classes.has('is-dragging'), false);
    assert.equal(harness.panel.style.left, '');
});
