# Universal Tarot Reading System (FiveM)

Server-authoritative, framework-agnostic synchronized tarot card reading for
FiveM roleplay servers. A "falcı" (reader) and a "müşteri" (customer) see the
exact same cards flip in real time. There are **no mechanical effects** —
no health, stamina, stress, armor, speed, or economy changes. Every card is
pure RP flavor, and every card's identity, order, and orientation is decided
by the server, never the client.

## Requirements

- FiveM server with **OneSync** enabled (distance/routing-bucket checks in
  `server/security.lua` assume it; on servers without OneSync the bucket
  check becomes a no-op, which is safe but slightly less strict).
- Nothing else is a hard dependency. Framework, inventory, target, notification,
  and sound integrations are all optional and auto-detected.

## Install

1. Copy this folder into your server's `resources` directory as `tarot` (or
   any name you like).
2. Add `ensure tarot` to your `server.cfg`, after your framework and any
   inventory/target/ox_lib/xsound resources you use.
3. Drop in your own card art and sound (see **Assets** below) — the resource
   runs fine without them, just with plain name-only card faces and silence.
4. Register the table item if `Config.RequireTableItem = true` (default) —
   see **Item registration** below. Set it to `false` to skip this step
   entirely and let anyone use `/tarotmasa`.

### QBCore + qb-inventory + qb-target

Nothing to configure — `Config.Framework/Inventory/TargetSystem = 'auto'`
detects `qb-core`, `qb-inventory`, and `qb-target` automatically. Register
the item from `install/qb-item.lua`.

### QBCore + ox_inventory + ox_target

Same as above; `ox_inventory` and `ox_target` are checked before their qb
equivalents in the auto-detect order, so they win if both are present.
Register the item from `install/ox_inventory-item.lua`.

### Qbox (qbx_core)

Auto-detected ahead of plain QBCore (a Qbox server also starts `qb-core`
compatibility shims in some setups, so Qbox is checked first). No extra
config needed.

### ESX (es_extended)

Auto-detected. Register the item by running `install/esx-item.sql` against
your database.

### Standalone (no framework)

Set `Config.Framework = 'standalone'` (or leave `'auto'` with no framework
resource running and `Config.AllowStandaloneFallback = true`, the default).
Set `Config.RequireTableItem = false` unless you wire up
`server/bridges/inventory/custom.lua` to your own inventory.

### Custom inventory

Set `Config.Inventory = 'custom'` and fill in the three exports in
`server/bridges/inventory/custom.lua` (`HasItem`, `RemoveItem`, `AddItem`).

## Item registration

The table item is `tarot_table` by default (`Config.TableItem`). Registration
snippets live in `install/`:

- `install/qb-item.lua` — paste into `qb-core/shared/items.lua`
- `install/ox_inventory-item.lua` — paste into `ox_inventory/data/items.lua`
- `install/esx-item.sql` — run against your ESX database

If `Config.RequireTableItem = false`, skip this — anyone can run
`/tarotmasa` (or `Config.TableCommand`) to place a table.

## ACE permissions

Only relevant if `Config.UseAcePermission = true` or for the admin cleanup
command (`/tarotcleanup`), which always checks ACE:

```
add_ace group.admin tarot.admin allow
add_ace group.tarotreader tarot.reader allow
```

`Config.AdminAcePermission` / `Config.ReaderAcePermission` default to
`tarot.admin` / `tarot.reader`.

## Assets (bundled card art, optional sound)

`html/assets/cards/` and `html/assets/audio/` ship empty on purpose —
`shared/cards.lua` already declares the expected filenames
(`assets/cards/00-the-fool.webp` … `assets/cards/21-the-world.webp`), and
`html/js/audio.js` expects `assets/audio/{shuffle,draw,flip,complete}.ogg`. Drop
matching files in and they show up automatically:

- Missing card art → the NUI falls back to a styled name-only card face
  (`html/js/cards.js`'s `<img>` `onerror` handler), no console errors.
- Missing audio → playback is wrapped in a try/catch and silently no-ops.

The default custom table model is prop_tarot_table. If that model is not
installed, the client automatically falls back to prop_table_03. Set
Config.TableFallbackModel = false only when you want missing custom models
to fail visibly.

You are free to use any image/audio format the browser (CEF/Chromium)
supports — `.webp`/`.png`/`.jpg` for art, `.ogg`/`.mp3` for audio — just keep
the filenames matching `shared/cards.lua` and `html/js/audio.js`.

## Writing a custom bridge

Every integration point is a small table registered into a loader:

- **Server**: `RegisterTarotServerBridge(category, name, impl)` in
  `server/bridges/loader.lua`. Categories: `framework`, `inventory`,
  `permissions`. See any existing file in `server/bridges/*/*.lua` for the
  exact function names expected per category (documented in
  `shared/constants.lua`).
- **Client**: `RegisterTarotClientBridge(category, name, impl)` in
  `client/bridges/loader.lua`. Categories: `framework`, `target`,
  `notification`, `sound`.

Set the matching `Config.*` option to your bridge's registered name (instead
of `'auto'`) to select it. No core file ever calls a framework/inventory/
target export directly — everything routes through `Bridge.*`.

## Event flow

```
reader: /tarotmasa (or interact) -> places table -> server registers table
reader: target "Start a Tarot Reading" -> picks a nearby player
  -> tarot:server:startReading -> session created (state: invited)
customer: receives invite NUI -> accept -> tarot:server:acceptInvite
  -> reader sees spread selection; customer sees waiting NUI
reader: selects a metadata spread -> tarot:server:selectSpread
  -> server validates, builds deck, transitions shuffling -> dealing -> reading
  -> the same NUI board animates closed cards into their configured positions
reader: reveals slots one at a time -> tarot:server:revealSlot
  -> server validates (reader-only, mode, in range, not already revealed)
  -> broadcasts tarot:client:slotRevealed to both with sequence number
  -> NUI flips the card, shows meaning text
last slot revealed -> session state: completed -> summary screen for both
either side: close -> tarot:server:closeSession -> cleanup, table freed
```

Every client event carries a `sequence` number; if a client detects a gap it
calls `tarot:server:requestSessionSnapshot` to resync instead of guessing.

## Security notes

- The deck, card order, and orientation are generated and stored
  server-side only (`server/deck.lua`, `server/sessions.lua`). Clients only
  ever receive already-revealed card data.
- Every server event independently validates: source, cooldown, payload
  shape, session existence/state, reader-vs-customer role, and distance —
  no shared trust between checks.
- Table placement uses a short-lived server pending token. The confirm event
  rechecks player distance, network entity owner, expected model, duplicate
  network ID, table limit, and inventory before registering the table.
- Client-provided table/session IDs are checked against separate strict
  formats (table_<time>_<counter> and tarot_<time>_<counter>).
- Cleanup deletes registered network props server-side as well as removing
  client targets, ambient sound, seating animation, freeze state, and NUI
  focus.
- Reveal order is configured per spread (`sequential`, `row_sequential`, or
  `free`); `ForceSequentialReveal = true` can override every spread mode.
- Cleanup (`server/cleanup.lua`) is idempotent and runs from every teardown
  path: player drop, resource stop, timeout sweep, table expiry, and the
  admin `/tarotcleanup` command.

## Acceptance test checklist

1. Two clients: reader places a table, invites the customer, customer
   accepts, reader reveals slot 1 → both screens show the same card, same
   orientation, same meaning text.
2. Trigger a reveal for an already-revealed slot → rejected.
3. Customer tries to reveal a slot → rejected (reader-only).
4. A third, out-of-range player tries to interfere with the session
   (reveal/close) → rejected (not a session participant / too far).
5. Reader disconnects mid-session → customer's NUI closes, focus is
   released, props are removed.
6. `restart tarot` with a table placed → no orphan props, no stuck NUI
   focus, no lingering ambient sound.
7. Run with no target resource installed → the 3D-text + `[E]` fallback
   works. With `Config.SoundSystem = 'none'` (default) → no ambient-sound
   errors.
8. Switch `Config.Framework` through `qbx` / `qb` / `esx` / `standalone` →
   each boots clean; with `Config.Debug = true` the console reports which
   bridge was detected for framework/target/etc.
9. Send duplicate or malformed confirmTablePlaced / removeTable /
   requestSessionSnapshot payloads. They must be rejected without duplicate
   tables, hidden-card leakage, or unhandled errors.
10. Configure Config.AllowEveryoneToRead = false with job grades. Only
    configured jobs at or above their minimum grade can start readings.
