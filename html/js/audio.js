// Wrapped playback so a missing audio file (assets/audio/ ships empty by
// default) fails silently instead of throwing/logging to console.
(function () {
    const SOURCES = {
        shuffle: 'assets/audio/shuffle.ogg',
        draw: 'assets/audio/draw.ogg',
        flip: 'assets/audio/flip.ogg',
        complete: 'assets/audio/complete.ogg',
    };
    let enabled = true;
    let volume = 1;

    function configure(options) {
        if (options == null) return;
        enabled = options.enabled !== false;
        const nextVolume = Number(options.volume);
        volume = Number.isFinite(nextVolume) ? Math.max(0, Math.min(1, nextVolume)) : 1;
    }


    function play(name) {
        if (!enabled) return;
        const el = document.getElementById('audio-' + name);
        if (el == null) return;
        el.volume = volume;

        const src = SOURCES[name];
        if (src != null && el.getAttribute('src') !== src) {
            el.setAttribute('src', src);
        }

        try {
            const playPromise = el.play();
            if (playPromise != null && typeof playPromise.catch === 'function') {
                playPromise.catch(() => {}); // missing file / decode error -> stay silent
            }
        } catch (err) {
            // stay silent
        }
    }

    window.TarotAudio = { configure, play };
})();
