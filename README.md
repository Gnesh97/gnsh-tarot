# Universal Tarot Reading System

## Synchronized Social RP for FiveM

Universal Tarot Reading System adds a complete, cinematic tarot-reading
experience to roleplay servers. A reader and a customer sit at a physical table,
choose a spread together and watch the same server-dealt cards reveal in real
time.

This resource is intentionally roleplay-first: tarot readings are presentation
and storytelling. They do not change health, stamina, stress, armor, speed,
economy or any other mechanical player stat.

> **Current version:** <code>1.0.0</code>
>
> **Default locale:** Turkish, with English fallback
> **Default card rules:** server-authoritative deck, 20% reversed chance and no
> duplicate card IDs within a spread

## Product highlights

| Capability | What it delivers |
|---|---|
| Synchronized readings | Reader and customer receive the same cards, order, orientation and meaning text. |
| Five ready-made spreads | Three-card, seven-card Horseshoe, Pentagram, Celtic Cross and 21-card layouts. |
| Physical social space | Place a table, invite a nearby player, sit with chairs and run the reading as a shared scene. |
| Server-authoritative deck | Card identity, order, orientation, reveal ownership and session state are decided server-side. |
| Cinematic presentation | Deal animation, shuffle/reveal flow, responsive board, card meanings, summary screen and optional audio. |
| Framework freedom | Qbox, QBCore, ESX and standalone bridges with optional inventory, target, notification and sound providers. |
| RP-safe design | No gameplay stat mutations; the resource stays focused on conversation, atmosphere and storytelling. |

## What the player experience looks like

~~~text
Place a tarot table
    ↓
Choose a nearby customer or start a solo reading
    ↓
Customer accepts the invitation
    ↓
Choose a spread and confirm it
    ↓
Cards are dealt to the shared board
    ↓
Reader reveals cards one by one
    ↓
Both players see the same card and meaning
    ↓
Summary, seating cleanup and table release
~~~

The session is shared, sequenced and recoverable. If a client detects a sequence
gap, it requests a server snapshot instead of guessing which card was revealed.

## Included spreads

| Spread | Cards | Typical duration | Style |
|---|---:|---:|---|
| Three Card | 3 | 3–5 min | Past, present and future. |
| Horseshoe | 7 | 7–10 min | A focused situation viewed from seven angles. |
| Pentagram | 6 | 6–9 min | Four elements plus spirit and the central question. |
| Celtic Cross | 10 | 10–15 min | A detailed situation-to-outcome reading. |
| 21-Card Spread | 21 | 15–25 min | Broad past, present and future exploration. |

Each spread is metadata-driven. Its slots, labels, descriptions, position,
rotation, scale, reveal mode, difficulty and estimated duration are configurable
in <code>Config.Spreads</code>.

Supported reveal modes include:

- <code>sequential</code> for one-card-at-a-time readings;
- <code>row_sequential</code> for structured multi-row boards;
- <code>free</code> when a server owner intentionally wants an alternative flow;
- <code>Config.ForceSequentialReveal = true</code> to enforce sequential reveals
  across all spreads.

## Card engine

The resource ships a full 78-card tarot deck with upright and reversed meaning
text in the locale files.

Default rules:

| Setting | Default | Purpose |
|---|---:|---|
| <code>Config.ServerAuthoritativeCards</code> | <code>true</code> | Keeps deck decisions on the server. |
| <code>Config.ReversedChance</code> | <code>20</code> | Percentage chance for a revealed card to be reversed. |
| <code>Config.PreventDuplicateCards</code> | <code>true</code> | Prevents the same card ID from appearing twice in one spread. |
| <code>Config.AllowRevealAll</code> | <code>false</code> | Keeps normal reader-led reveals as the default. |
| <code>Config.RevealAnimationDelay</code> | <code>300 ms</code> | Keeps both clients visually aligned after a reveal. |

The client never chooses hidden cards. It receives only the server-approved
reveal payload for the current session.

## Social seating and world props

- Configurable combined tarot table model or composite table, crystal and
  candle props.
- Reader and customer offsets, headings and rotation adjustments.
- Optional chair prop under each seated character.
- Proper seated animation while the reading progresses to the result.
- Configurable table lifetime, interaction radius, invite radius and session
  bounds.
- Cleanup of seating, props, focus, targets and sound on every close path.
- Optional ambient sound around the table through <code>xsound</code>.

The default configuration keeps player freezing disabled, so the server owner can
choose whether readings should feel relaxed or tightly staged.

## NUI and presentation

The bundled NUI provides:

- player selection and invitation screens;
- spread selection with card count, difficulty, duration and preview;
- dealing and shuffle transitions;
- responsive card board layouts;
- card flip, upright/reversed state and meaning text;
- summary screen for the completed reading;
- drag/resize-friendly presentation contracts for large spreads;
- local shuffle, draw, flip and completion sounds when assets are provided;
- Turkish and English locale strings.

Card art and audio are optional. When art is missing, the UI falls back to a
styled name-only card face. Missing sound files are safely ignored.

## Compatibility

| Area | Supported integrations |
|---|---|
| Framework | Qbox, QBCore, ESX, standalone |
| Inventory | ox_inventory, qb-inventory, ESX, standalone, custom bridge |
| Target | ox_target, qb-target, fallback 3D text + keybind |
| Notifications | ox_lib, QBCore, ESX, native |
| Sound | none by default, optional xsound |
| Locale | Turkish and English |
| Interaction | target resource or dependency-free fallback |

The loader supports automatic detection or explicit provider selection. No
framework, inventory, target, notification or sound resource is declared as a
hard dependency in <code>fxmanifest.lua</code>.

## Requirements

- FiveM server with Lua 5.4 support.
- OneSync is strongly recommended and should be enabled for the intended
  distance and routing-bucket validation model. On a server without OneSync,
  the bucket check becomes a no-op; other validation remains active.
- A configured inventory when <code>Config.RequireTableItem = true</code>.
- A registered <code>tarot_table</code> item, unless table-item requirements are
  intentionally disabled.
- Optional framework/target/UI providers only when their corresponding config
  values select them.

## Installation

1. Copy the resource to your server resources directory, for example:

   ~~~text
   resources/[standalone]/tarot
   ~~~

2. Add the resource after the framework and optional provider resources in
   <code>server.cfg</code>:

   ~~~cfg
   ensure tarot
   ~~~

3. Register the default table item <code>tarot_table</code> using the matching
   install snippet:
   - [install/qb-item.lua](install/qb-item.lua) for QBCore;
   - [install/ox_inventory-item.lua](install/ox_inventory-item.lua) for
     ox_inventory;
   - [install/esx-item.sql](install/esx-item.sql) for ESX.
4. Keep <code>Config.Framework</code>, <code>Config.Inventory</code> and
   <code>Config.TargetSystem</code> on <code>auto</code> for detection, or set
   explicit values for deterministic production behavior.
5. Add card art and optional audio only if you want custom visuals.
6. Restart the resource and run the acceptance checklist before inviting
   players to use it.

### Standalone setup

~~~lua
Config.Framework = 'standalone'
Config.AllowStandaloneFallback = true
Config.RequireTableItem = false
Config.TargetSystem = 'fallback'
~~~

With table-item requirements disabled, players can place a table through the
configured table command without an inventory bridge.

## Commands and interaction

| Command | Availability | Purpose |
|---|---|---|
| <code>/tarotmasa</code> | Configurable | Place a tarot table when <code>Config.EnableTableCommand = true</code>. |
| <code>/tarotbasla</code> | Player | Start a reading at the nearest owned table. |
| <code>/tarotcleanup</code> | Admin / console | Clear active sessions and registered tables. |

Target-enabled servers also receive contextual actions for starting a reading,
removing a table, sitting, standing, focusing the current reading, ending a
session and toggling ambient sound.

## Configuration essentials

### Integration

~~~lua
Config.Locale = 'tr'
Config.Framework = 'auto'
Config.Inventory = 'auto'
Config.TargetSystem = 'auto'
Config.NotificationSystem = 'auto'
Config.MenuSystem = 'auto'
Config.SoundSystem = 'none'
~~~

### Table and session

~~~lua
Config.TableItem = 'tarot_table'
Config.RequireTableItem = true
Config.ConsumeTableItem = false
Config.MaxTablesPerPlayer = 1
Config.TableLifetimeMinutes = 60
Config.TableInteractionDistance = 2.0
Config.CustomerSearchDistance = 4.0
Config.SessionMaxDistance = 6.0
Config.InviteTimeoutSeconds = 30
Config.SessionTimeoutSeconds = 600
~~~

### Reading permissions

~~~lua
Config.AllowEveryoneToRead = true
Config.AllowSoloReading = true
Config.UseAcePermission = false
Config.ReaderAcePermission = 'tarot.reader'
Config.AdminAcePermission = 'tarot.admin'
~~~

If <code>Config.AllowEveryoneToRead = false</code>, configure
<code>Config.ReaderJobs</code> with the jobs and minimum grades that can start
readings. The admin cleanup command always checks admin authorization.

### Seating

~~~lua
Config.Seating.enabled = true
Config.FreezePlayersDuringReading = false
~~~

Offsets, heading adjustments, chair model, animation and character rotation are
all available under <code>Config.Seating</code>.

## Asset pipeline

Optional card art is expected under <code>html/assets/cards/</code> using the
filenames declared by <code>shared/cards.lua</code>. The expected deck range is
<code>00-the-fool</code> through <code>21-the-world</code> plus the minor-arcana
files defined by the project.

Optional local sounds are expected under <code>html/assets/audio/</code>:

~~~text
shuffle.ogg
draw.ogg
flip.ogg
complete.ogg
~~~

Supported browser formats include WebP, PNG, JPG, OGG and MP3. Keep filenames
consistent with the shared card definitions and audio loader.

## Security model

The resource treats every client event as untrusted input.

- Deck creation and card orientation remain server-side.
- Server events independently validate source, payload shape, cooldown, session
  state, participant role and distance.
- Table placement uses a short-lived pending token before registration.
- Table confirmation rechecks distance, entity ownership, expected model, network
  ID, table limits and inventory state.
- Session and table identifiers use separate strict formats.
- Reader-only reveals cannot be requested by the customer or a third player.
- Sequence numbers and snapshot requests prevent client-side state guessing.
- Cleanup is idempotent across player drop, resource stop, timeout, table
  expiry and administrator cleanup.
- The resource produces RP flavor only; it does not mutate player mechanics.

## Custom bridge development

Every integration point is a small registered table:

- Server bridges use <code>RegisterTarotServerBridge</code> in
  <code>server/bridges/loader.lua</code>.
- Client bridges use <code>RegisterTarotClientBridge</code> in
  <code>client/bridges/loader.lua</code>.
- Categories include framework, inventory, permissions, target, notification
  and sound.
- Set the matching <code>Config.*</code> value to the registered bridge name.

Core gameplay files communicate through <code>Bridge.*</code>; framework and
vendor exports stay isolated inside adapter files.

## Acceptance checklist

Before a production launch, verify:

1. Two clients see the same card, orientation and meaning after a reveal.
2. A second reveal of the same slot is rejected.
3. A customer cannot reveal a card as the reader.
4. A third or out-of-range player cannot interfere with the session.
5. A reader disconnect closes the customer UI and removes session props.
6. A resource restart leaves no orphan table, stuck NUI focus or lingering sound.
7. The no-target fallback shows 3D text and accepts the configured interaction key.
8. Qbox, QBCore, ESX and standalone profiles boot with their selected bridges.
9. Malformed placement, removal and snapshot payloads are rejected cleanly.
10. Restricted reader jobs and ACE permissions enforce the intended access.
11. Large spreads, especially Celtic Cross and the 21-card board, remain readable.
12. All contract tests and live staging scenarios are recorded before release.

Run the available UI contract tests from the repository's JavaScript test
setup, then complete the live matrix in
[docs/STAGING_TEST_MATRIX.md](docs/STAGING_TEST_MATRIX.md).

## Project documentation

- [CHANGELOG.md](CHANGELOG.md) — release history and current changes
- [docs/RELEASE_CHECKLIST.md](docs/RELEASE_CHECKLIST.md) — release gate
- [docs/STAGING_TEST_MATRIX.md](docs/STAGING_TEST_MATRIX.md) — staging scenarios
- [docs/ROLLBACK.md](docs/ROLLBACK.md) — rollback procedure
- [docs/DEPLOYMENT_BACKUP.md](docs/DEPLOYMENT_BACKUP.md) — backup guidance
- [install/](install) — inventory item registration snippets

## Ownership and licensing

See [LICENSE](LICENSE) and review the license terms of any card art, fonts,
audio or third-party assets before commercial deployment. The resource's
default behavior is intentionally safe for RP: readings are immersive,
synchronized and non-mechanical.
