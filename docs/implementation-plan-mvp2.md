# Soul Protocol — MVP2 Implementation Plan (Plan 1 of 2: Presentation Layer)

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended)
> or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`)
> syntax for tracking.

**Goal:** Put a human at the controls of the existing MVP1 engine — render `GameState` as the portrait
UI from the wireframes and drive `RunController` through the combat / navigation / loot path with real
taps, so a person can play a Pilgrim Floor-3 run through the actual interface.

**Architecture:** The UI is a **human-driven replacement for `AIPlayerAgent`**. It binds to the exact
same run surface (`RunController.get_legal_actions()` / `submit_action()`), renders `GameState`, and
reacts to `SignalBus` for feedback. Presentation splits into two kinds of file: **view-models** —
`RefCounted`, Node-free, headless-testable classes that map `GameState` + content → plain display
dictionaries (this is the TDD'd logic) — and **thin view scenes** (`.tscn` + script) that render those
dictionaries and wire user input to `submit_action`. The single most important rule: **a view never
builds an action dictionary itself; it picks one from `get_legal_actions()` and submits it verbatim**,
so the gating authority (`CombatResolver`/`ActionInjector`, `LLD-ARCH-019`) stays canonical.

**Tech Stack:** Godot 4.6.x, GDScript, Godot `Control`/`Container` UI (anchors only, `LLD-PLATFORM-003`),
abstract input actions (`LLD-PLATFORM-002`), GdUnit4 v6.1.3 for view-model tests.

> **Commits:** the `git commit …` lines below are end-of-task **markers** showing the intended commit
> boundary and message. The repo owner runs commits themselves — an executing agent should stage/verify
> but leave the actual `git commit` to the user unless explicitly told otherwise.

---

## Scope of this plan (read first)

MVP2 (`SCOPE-002`) was split into **two plans** by decision on 2026-07-10:

- **This plan (Plan 1 — Presentation Layer):** the presentation foundation and every screen whose
  **engine already exists in MVP1** — room-select (NAVIGATION), combat (COMBAT) + omen overlay, and
  loot (LOOT_SELECTION), plus the inventory view and shared UI components. On completion a human can
  play the full MVP1 Pilgrim Floor-3 path — the same path `AIPlayerAgent` plays today — entirely through
  the UI.
- **Plan 2 — Non-combat events (separate follow-up document, not this one):** the Memory Fragment,
  Wandering Soul, Elite Gate, and Rest screens **plus the new engine work they require** —
  `TradeGenerator` (`LLD-ARCH-021`), the `ACCEPT_TRADE` / `DECLINE_TRADE` / `ACCEPT_OPTION_*` actions,
  the `NON_COMBAT_EVENT` phase orchestration in `RunController`, and floor generation of MF/WS/Rest
  beats. These screens are deferred here because they cannot function without that engine layer, which
  MVP1 explicitly deferred (`implementation-plan.md` MVP1 scoping notes).

### Decisions locked for this plan (do not re-litigate)

1. **Mobile-first portrait, web export first (target pivot, 2026-07-10).** The primary release target is
   **mobile**, shipped first as a **web export** (playable in a mobile browser); a native iOS/Android or
   desktop port is a potential **second target (TBD)**. The wireframes and `ui-` specs are already built on
   this basis — 390×844 portrait, 2× sprites, touch lists, slide-up sheets, tap-to-target (`UI-ART-002`).
   Build the **single portrait layout** only (bottom action bar + slide-up sheets); **touch is the primary
   input**, mouse/keyboard a dev-only fallback. Do **not** build a desktop-specific variant. **Reconciled**
   via OpenSpec change `pivot-platform-mobile-web-first` (applied 2026-07-10): `LLD-PLATFORM-001` now
   specifies the single portrait layout directly (the desktop right-panel variant is gone from the spec);
   `LLD-PLATFORM-005` is retitled "Web-First, Engine-Agnostic Development" — web export is no longer
   `[OPEN·MVP4]`, and it records that the engine needs no rewrite for a second-target port (see decision 4);
   `SCOPE-002` now reads "verified first in a mobile-sized web build". No further spec reconciliation is
   outstanding for this decision.
2. **TDD the logic, thin views.** View-models are TDD'd headlessly (GdUnit4). View `.tscn` scenes and
   their attached scripts are **manually verified by running the game** — do **not** add UI-`InputEvent`
   tests to the headless suite (`tests/README.md`: the suite runs `--ignoreHeadlessMode` precisely
   because input tests don't work windowless).
3. **Placeholder-and-flag open values.** Where a spec value is still `[OPEN·MVP2]`, use the documented
   guess below and flag it for playtest tuning — do not block on it:
   - **Rest heal amount** (`LLD-FLOOR-BEATS-006`/`HLD-RUN-006`): *N/A to this plan* (Rest screen is Plan 2).
   - **HP-for-item trade amounts** (`HLD-ITEMS-011`): *N/A to this plan* (trades are Plan 2).
   - **Per-enemy combat door symbols** (`UI-ROOM-002`, `[OPEN·MVP2]`): **no door-symbol art exists.** The
     user is running a dedicated door-symbols art session before execution. Until those assets land, the
     room-select view uses a **placeholder door glyph** for every combat door (see PU1). `ArtPaths`
     resolves a door symbol by `enemy_id` and falls back to the placeholder for any unmapped id, so
     dropping the real PNGs in later is a data-only change with no code edit.
4. **Persistence needs no new abstraction — verify web flush, don't rewrite.** `PersistenceService` is
   already the sole storage seam (`LLD-ARCH-007`); domain/application never touch `FileAccess` directly
   (grep-enforced in T1.4), so the core engine is storage-agnostic and cross-platform ports need no engine
   changes. Godot 4's Web export persists `user://` to the browser's **IndexedDB** (IDBFS), so the current
   `FileAccess`-on-`user://` code is expected to work on web, native iOS/Android, and desktop alike. The
   one web caveat is that the IndexedDB sync is **asynchronous** — saves must be flushed and confirmed to
   survive a page reload. This plan therefore adds a **small verification step** (not a backend rewrite):
   PU4.2 confirms a save/reload round-trip in the Web build. If flush turns out to need an explicit sync,
   that fix stays **inside `PersistenceService`** (branch on `OS.has_feature("web")`) with no engine
   rewrite. A full single-session Pilgrim run does not depend on persistence at all.

### Ground rules inherited from `implementation-plan.md` (still binding)

- **Four-layer rule (`LLD-ARCH-001`):** Presentation may depend on all layers; **nothing depends on
  Presentation.** View-models live in `src/presentation/` but stay `RefCounted`/Node-free so they are
  headless-testable. `ScreenManager` (Application) must **not** import Presentation types — it switches
  screens by **resource-path string** only (Main injects the phase→path map into it).
- **Headless purity (`LLD-ARCH-002`):** only Presentation-adjacent nodes read `GameConfig.HEADLESS`.
  Every view scene must no-op / free itself under headless so the T7.2 determinism gate keeps passing.
- **`@Spec` annotations (`CLAUDE.md`):** tag every class and method with the `UI-*` / `LLD-PLATFORM-*`
  requirement(s) it realises. View-models cite the `UI-*` requirement whose display rule they compute.
- **No content-by-name in the engine (`LLD-ARCH-005`):** the UI may map ids → asset paths in a
  **data-driven `ArtPaths` table**, but no gameplay branch keys off a specific vessel/item/enemy id.
- **Add/extend the GdUnit4 suite in the same task as the view-model it covers.**
- **On the `godot-gdscript-patterns` skill:** treat it as an optional Godot-4 scene-tree primer for the
  view/UI work only. Where it conflicts with this project's rules it loses — never use direct `FileAccess`
  (use `PersistenceService`, `LLD-ARCH-007`), never model gameplay as `Node` components or Node state
  machines (Domain is Node-free `Resource`s + `CombatResolver`/`RunController`), and there is no
  `_physics_process` loop. The existing code and `CLAUDE.md` are the authority.

### Target new directory layout (created incrementally by the tasks below)

```
src/presentation/
  game_session.gd            # owns the live RunController in-tree; the UI's run driver
  art_paths.gd               # data-driven id → asset-path + damage-type tint table
  display_text.gd            # status-keyword grammar + shared formatting (UI-GLOBAL-001)
  view_models/
    room_select_view_model.gd
    loot_view_model.gd
    combat_view_model.gd
    omen_overlay_view_model.gd
  screens/                   # thin view scenes (.tscn) + scripts
    main.tscn / main.gd
    room_select.tscn / room_select.gd
    loot.tscn / loot.gd
    combat.tscn / combat.gd
    omen_overlay.tscn / omen_overlay.gd
  components/                # reusable sub-scenes
    ghost_menu.tscn / ghost_menu.gd
    hp_bar.tscn / hp_bar.gd
    status_row.tscn / status_row.gd
    charge_dots.tscn / charge_dots.gd
    damage_type_icon.tscn / damage_type_icon.gd
tests/
  test_art_paths.gd  test_display_text.gd
  test_room_select_view_model.gd  test_loot_view_model.gd
  test_combat_view_model.gd  test_omen_overlay_view_model.gd
```

---

## Canonical facts the tasks depend on (verified against the code)

**Run surface** (`RunController`, `src/application/run_controller.gd`): `configure(rng, content, signal_bus)`,
`start_run(seed, vessel_id)`, `get_legal_actions() -> Array`, `submit_action(action: Dictionary)`,
`is_finished() -> bool`, public `game_state: GameState`. It is a **Node, not an autoload**, created per
run, and `queue_free()`s itself at `RUN_END` when inside the tree.

**Phases** (`GameState.RunPhase`): `NAVIGATION, COMBAT, LOOT_SELECTION, NON_COMBAT_EVENT,
FLOOR_TRANSITION, RUN_END`. `phase_changed(new_phase:int, old_phase:int)` fires on every transition.

**Action dictionary shapes** (selectors the views submit verbatim):

| Phase | Action `type` | Extra keys |
|---|---|---|
| NAVIGATION | `CHOOSE_DOOR` | `room_id: String` |
| LOOT_SELECTION | `CHOOSE_LOOT` | `item_id: String` |
| LOOT_SELECTION | `DECLINE_LOOT` | — |
| COMBAT | `USE_ABILITY` | `ability_id: String`, `target_id: String` (`""` = untargeted) |
| COMBAT | `USE_ITEM` | `slot_index: int`, `target_id: String` |
| COMBAT | `EVADE` | — |
| COMBAT | `END_TURN` | — |
| COMBAT | `CHOOSE_OMEN` | `card_index: int`, `side: String` |
| COMBAT | `READ_THE_ROAD_COMMIT` | `send_to_bottom: Array[int]` |
| COMBAT | `REPENT_DISCARD` | `slot_index: int` |

**Relevant `GameState` fields** (all verified): `vessel_state{hp,max_hp,vessel_id,ability_states,
active_statuses,is_evading,is_stunned}`, `inventory: Array[ItemInstance]{item_id,remaining_charges}` (3
slots, nulls = empty), `item_burden_score:int`, `bound_companion`/`temporary_companion:
CompanionState{companion_id}`, `navigation_state{doors_ahead: Array[DoorData]{room_id,room_type,
encounter_id}, loot_offers: Array[String], rooms_completed_this_floor:int, segment_room_counts:
Dictionary}`, `combat_state{enemies: Array[EnemyState]{enemy_id,instance_id,hp,max_hp,active_statuses,
current_intent}, current_cycle: OmenCycleState{ticks_remaining,drawn_cards: Array[Dictionary],
sides_assigned}, is_action_used,is_support_used,is_consumable_used,read_the_road_active,
pending_repent_slots: Array[int]}`, `floor_number:int`.

**`StatusInstance`**: `{status_id, remaining_ticks, magnitude, trigger, string_param}`. Vulnerable's
type lives in `string_param` (e.g. `"physical"`); a Type-Convert status likewise.

**Content provider** (`ContentRegistry` autoload, injected): `get_vessel(id) -> VesselData`,
`get_ability(id) -> AbilityData` (items are `AbilityData` too), `get_enemy(id) -> EnemyData`,
`get_companion(id) -> CompanionData`, `get_omen_card(id) -> OmenCardData`.

**Card content lives in the handler chain, not top-level fields (verified).** `AbilityData` exposes
`display_name: String`, `action_bucket: String` (`"attack"`/`"support"`/`"consumable"`),
`max_charges: int`, `score: int`, and `handlers: Array[HandlerConfig]`. There are **no** `damage` /
`damage_type` fields — a weapon's damage/type is read from its `deal_damage` handler's params:
`HandlerConfig{handler_id:"deal_damage", params:{base_damage:int, damage_type:String("physical"),
mode:String("single"|"all"|"arc"), arc_damage:int}}`. A consumable/support effect is read from its
`apply_status` / `cleanse_status` handler params. `OmenCardData` exposes `display_name, status_id,
status_magnitude, requires_tag, handlers`. The view-models extract display values by scanning
`handlers` for the relevant `handler_id` — **read the handler scripts in `src/domain/handlers/` in Task
PU0.2** to confirm each handler's param keys before writing the card assembly.

**Autoloads available** (`project.godot`): `GameConfig, RNGService, SignalBus, PersistenceService,
EventLog, ContentRegistry, ScreenManager` (+ others). `ScreenManager` currently no-ops its
`_on_phase_changed` under headless with a `# MVP2: switch...` TODO — PU0.4 fills that in.

---

# Phase PU0 — Presentation foundation

### Task PU0.1 — Project config: portrait viewport, web/mobile target, input actions, non-headless boot

**Files:**
- Modify: `project.godot` (`[display]`, `[rendering]`, `[input]`, main scene)
- Create: a Web export preset (`export_presets.cfg`, via the editor Export dialog)
- Create: `src/presentation/README.md`

- [ ] **Step 1: Set the portrait viewport + stretch.** In `project.godot` under `[display]` set the
  reference resolution and a scaling stretch so anchors do the work (`LLD-PLATFORM-003`). Portrait
  orientation is locked for mobile:

```ini
[display]

window/size/viewport_width=390
window/size/viewport_height=844
window/stretch/mode="canvas_items"
window/stretch/aspect="keep"
window/handheld/orientation="portrait"
```

- [ ] **Step 1b: Set the web/mobile rendering backend.** The Web export requires the **Compatibility**
  renderer (WebGL); mobile also runs best on it. In `project.godot`:

```ini
[rendering]

renderer/rendering_method="gl_compatibility"
renderer/rendering_method.mobile="gl_compatibility"
textures/canvas_textures/default_texture_filter=0   ; Nearest, project-wide (UI-ART-003 pixel art)
```

- [ ] **Step 1c: Add the Web export preset.** In the editor **Project → Export**, add a **Web** preset
  (installs the web export templates if prompted). This produces `export_presets.cfg`. This is the first
  release vehicle (decision 1); it lets PU4.2 verify the build in a browser at a mobile viewport.

- [ ] **Step 2: Declare abstract input actions (`LLD-PLATFORM-002`).** Add a `[input]` section mapping
  the named actions the UI uses. **Touch is the primary binding** (mobile target); mouse/keyboard are a
  dev-only fallback so the game is drivable in a desktop browser during development. Also enable
  `input_devices/pointing/emulate_touch_from_mouse=true` so mouse clicks exercise the touch path.
  Every interaction is a named action; game code never reads raw device events.

```ini
[input]

ui_primary={
"deadzone": 0.5,
"events": [ ] ; bind Left Mouse Button + touch in the editor Input Map; documented here so the action exists
}
ui_cancel={
"deadzone": 0.5,
"events": [ ] ; bind Escape + a right-click/back gesture
}
```

> Godot serialises `InputEvent`s verbosely; add the two actions in **Project Settings → Input Map** in
> the editor (LMB + touch for `ui_primary`, Esc for `ui_cancel`) rather than hand-writing the binary
> event blocks. The tap handling in the views uses `Control.gui_input` / `pressed` signals, which route
> through these actions.

- [ ] **Step 3: Point the main scene at the presentation root** (created in PU0.5). Leave
  `run/main_scene` unset until `main.tscn` exists; set it in PU0.5.

- [ ] **Step 4: Write `src/presentation/README.md`** recording the layer rule and the platform target
  (both now settled in the specs — no `[PENDING]` reconciliation remains; see `LLD-PLATFORM-001`/`-005`
  and `SCOPE-002`, updated by OpenSpec change `pivot-platform-mobile-web-first`, applied 2026-07-10):

```markdown
# src/presentation/ — the UI layer (MVP2)

Four-layer rule: this layer may depend on all others; nothing depends on it.
ScreenManager (Application) switches screens by RESOURCE-PATH STRING only — never import a screen type
into Application.

## Target: mobile-first portrait, web export first (LLD-PLATFORM-001, LLD-PLATFORM-005)
Primary release is MOBILE, shipped first as a WEB export; a native iOS/Android or desktop port is a
potential second target (TBD). Single portrait layout (390×844, touch-first) is the ONLY layout — there
is no separate desktop variant. The engine needs no rewrite for a second-target port: PersistenceService
(LLD-ARCH-007) and abstract input (LLD-PLATFORM-002) already isolate platform specifics from Domain/
Application.
```

- [ ] **Step 5: Verify the editor still imports and the headless suite is still green** (config change
  must not break the determinism gate).

Run:
```bash
"C:\Program Files\GoDot\Godot_v4.6.3-stable_win64_console.exe" --headless --import --path .
"C:\Program Files\GoDot\Godot_v4.6.3-stable_win64_console.exe" --headless --path . \
  -d --remote-debug tcp://127.0.0.1:0 -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
  --ignoreHeadlessMode -a res://tests
```
Expected: import exits 0; suite exits 0 (all existing tests green — no presentation code yet).

- [ ] **Step 6: Commit.**
```bash
git add project.godot src/presentation/README.md
git commit -m "chore(mvp2): portrait viewport, input actions, presentation README + PLATFORM-001 flag"
```

---

### Task PU0.2 — `ArtPaths`: data-driven id → asset-path + damage-type tint table

**Files:**
- Create: `src/presentation/art_paths.gd`
- Test: `tests/test_art_paths.gd`

First **read the schema files** to confirm the display fields the later view-models will need — this
task only needs the ids, but read them now so PU1–PU4 don't guess:
`src/domain/ability_data.gd`, `src/domain/enemy_data.gd`, `src/domain/omen_card_data.gd`,
`src/domain/vessel_data.gd`, `src/domain/companion_data.gd`.

- [ ] **Step 1: Write the failing test.** `ArtPaths` resolves the known asset ids (which all exist on
  disk under `assets/art/`, verified) and falls back to a placeholder for unmapped ids. It also exposes
  the four damage-type tints from `UI-GLOBAL-003`.

```gdscript
# tests/test_art_paths.gd
extends GdUnitTestSuite

func test_status_icon_resolves() -> void:
	assert_str(ArtPaths.status_icon("burning")).is_equal("res://assets/art/icons/status/icon_status_burning.png")

func test_damage_icon_resolves() -> void:
	assert_str(ArtPaths.damage_icon("fire")).is_equal("res://assets/art/icons/dmg/icon_dmg_fire.png")

func test_intent_icon_resolves() -> void:
	assert_str(ArtPaths.intent_icon("heavy_attack")).is_equal("res://assets/art/icons/intent/icon_intent_heavy_attack.png")

func test_item_category_icon_resolves() -> void:
	assert_str(ArtPaths.item_icon("weapon")).is_equal("res://assets/art/icons/item/icon_item_weapon.png")

func test_enemy_sprite_resolves() -> void:
	assert_str(ArtPaths.enemy_sprite("plague_rat")).is_equal("res://assets/art/characters/enemies/enemy_plague_rat.png")

func test_vessel_sprite_resolves() -> void:
	assert_str(ArtPaths.vessel_sprite("pilgrim")).is_equal("res://assets/art/characters/vessels/vessel_pilgrim.png")

# UI-ROOM-002: unmapped combat door symbol falls back to the placeholder, no crash.
func test_door_symbol_falls_back_to_placeholder() -> void:
	assert_str(ArtPaths.door_symbol("no_such_enemy")).is_equal(ArtPaths.DOOR_SYMBOL_PLACEHOLDER)

func test_damage_type_tint_physical_is_neutral_not_red() -> void:
	# UI-GLOBAL-003: Physical is neutral gray (~#2b333c), never red.
	assert_object(ArtPaths.damage_tint("physical")).is_equal(Color("2b333c"))
	assert_object(ArtPaths.damage_tint("fire")).is_equal(Color("cf3b2e"))
```

- [ ] **Step 2: Run to verify it fails.**
Run: `…GdUnitCmdTool.gd … -a res://tests/test_art_paths.gd`
Expected: FAIL — `ArtPaths` not found.

- [ ] **Step 3: Implement `ArtPaths`.**

```gdscript
# @Spec: UI-ART-007, UI-GLOBAL-003, UI-ROOM-002
#
# ArtPaths — the single data-driven table mapping content ids to on-disk asset paths
# and damage types to their UI-GLOBAL-003 tint. It is the ONLY place the UI knows a
# folder layout; view-models/views call these helpers instead of hardcoding paths.
# Static-only (no state); lives in Presentation. No gameplay branch keys off an id —
# unknown ids resolve to a placeholder, never a code path (LLD-ARCH-005).
class_name ArtPaths
extends RefCounted

const _STATUS := "res://assets/art/icons/status/icon_status_%s.png"
const _DMG := "res://assets/art/icons/dmg/icon_dmg_%s.png"
const _INTENT := "res://assets/art/icons/intent/icon_intent_%s.png"
const _ITEM := "res://assets/art/icons/item/icon_item_%s.png"
const _ENEMY := "res://assets/art/characters/enemies/enemy_%s.png"
const _VESSEL := "res://assets/art/characters/vessels/vessel_%s.png"
const _COMPANION := "res://assets/art/characters/companions/companion_%s.png"
const LOOT_PLACEHOLDER := "res://assets/art/ui/loot/loot_reward_placeholder.png"

# UI-ROOM-002: per-enemy combat door symbols are deferred to an art session; until the
# real assets land, every combat door resolves to this placeholder. Populate DOOR_SYMBOLS
# (enemy_id -> path) when the art arrives — a data-only change, no view edit.
const DOOR_SYMBOL_PLACEHOLDER := "res://assets/art/ui/loot/loot_reward_placeholder.png"
const DOOR_SYMBOLS: Dictionary = {}  # e.g. {"plague_rat": "res://assets/art/ui/doors/door_plague_rat.png"}

# UI-GLOBAL-003 tints. Physical is neutral gray so red belongs exclusively to Fire.
const _DMG_TINT := {
	"physical": "2b333c", "fire": "cf3b2e", "lightning": "c9a24a", "ice": "5b86b3",
}

# @Spec: UI-ART-004
static func status_icon(status_id: String) -> String: return _STATUS % status_id
static func damage_icon(damage_type: String) -> String: return _DMG % damage_type
static func intent_icon(intent_type: String) -> String: return _INTENT % intent_type
static func item_icon(category: String) -> String: return _ITEM % category
static func enemy_sprite(enemy_id: String) -> String: return _ENEMY % enemy_id
static func vessel_sprite(vessel_id: String) -> String: return _VESSEL % vessel_id
static func companion_sprite(companion_id: String) -> String: return _COMPANION % companion_id

# @Spec: UI-ROOM-002
static func door_symbol(enemy_id: String) -> String:
	return str(DOOR_SYMBOLS.get(enemy_id, DOOR_SYMBOL_PLACEHOLDER))

# @Spec: UI-GLOBAL-003
static func damage_tint(damage_type: String) -> Color:
	return Color(str(_DMG_TINT.get(damage_type, "2b333c")))
```

- [ ] **Step 4: Run to verify pass.** Expected: PASS (8 cases).
- [ ] **Step 5: Commit.**
```bash
git add src/presentation/art_paths.gd tests/test_art_paths.gd
git commit -m "feat(mvp2): ArtPaths data-driven asset/tint table (UI-ART-007, UI-GLOBAL-003)"
```

---

### Task PU0.3 — `DisplayText`: inline status-keyword grammar (UI-GLOBAL-001)

**Files:**
- Create: `src/presentation/display_text.gd`
- Test: `tests/test_display_text.gd`

`UI-GLOBAL-001` requires every status keyword in UI text to render as *icon + bold keyword*, with no
tooltip. `DisplayText` produces a **structured segment list** (not a raw string) so any view can render
it — a `RichTextLabel` BBCode string plus the ordered icon paths to splice in. Keeping it structured
(and testable) avoids each screen re-implementing the grammar.

- [ ] **Step 1: Write the failing test.**

```gdscript
# tests/test_display_text.gd
extends GdUnitTestSuite

# "Apply Poisoned" -> the keyword is bolded and carries its status icon path.
func test_effect_line_bolds_keyword_with_icon() -> void:
	var seg := DisplayText.effect_line("Apply", "Poisoned", "poisoned")
	assert_str(seg["bbcode"]).is_equal("Apply [b]Poisoned[/b]")
	assert_array(seg["icons"]).is_equal([ArtPaths.status_icon("poisoned")])

# UI-LOOT-006: self-target uses "Gain", enemy-target uses "Apply" — the verb is caller-chosen,
# DisplayText just formats whatever verb it is handed.
func test_gain_verb_passthrough() -> void:
	var seg := DisplayText.effect_line("Gain", "Fortified", "fortified")
	assert_str(seg["bbcode"]).is_equal("Gain [b]Fortified[/b]")

func test_no_keyword_produces_plain_text_no_icons() -> void:
	var seg := DisplayText.plain("Drains 1 charge per room")
	assert_str(seg["bbcode"]).is_equal("Drains 1 charge per room")
	assert_array(seg["icons"]).is_empty()
```

- [ ] **Step 2: Run to verify it fails.** Expected: FAIL — `DisplayText` not found.
- [ ] **Step 3: Implement.**

```gdscript
# @Spec: UI-GLOBAL-001
#
# DisplayText — shared formatting for status-keyword grammar. Returns a structured
# segment { "bbcode": String, "icons": Array[String] }: the bbcode string bolds each
# status keyword; `icons` lists the status-icon path for each keyword in order, for the
# view to render inline immediately before the bold word. No tooltip is ever attached
# (UI-GLOBAL-002). Static-only, headless-testable.
class_name DisplayText
extends RefCounted

# verb + bold status keyword preceded by its combat status icon (UI-GLOBAL-001).
static func effect_line(verb: String, keyword: String, status_id: String) -> Dictionary:
	return {"bbcode": "%s [b]%s[/b]" % [verb, keyword], "icons": [ArtPaths.status_icon(status_id)]}

static func plain(text: String) -> Dictionary:
	return {"bbcode": text, "icons": []}
```

- [ ] **Step 4: Run to verify pass.** Expected: PASS (3 cases).
- [ ] **Step 5: Commit.**
```bash
git add src/presentation/display_text.gd tests/test_display_text.gd
git commit -m "feat(mvp2): DisplayText status-keyword grammar (UI-GLOBAL-001)"
```

---

### Task PU0.4 — `GameSession` + `ScreenManager` scene-switching wiring

**Files:**
- Create: `src/presentation/game_session.gd`
- Modify: `src/application/screen_manager.gd`
- Test: `tests/test_screen_manager.gd` (extend existing)

`GameSession` (Presentation Node) owns the live `RunController` in-tree and exposes the run surface to
screens. `ScreenManager` (Application) gains a **path-string** phase→scene registry and a `screen_root`
mount point; on `phase_changed` (when not headless) it frees the old screen, instantiates the new
scene **by path**, and hands it the active run + content. Application never imports a Presentation type.

- [ ] **Step 1: Write the failing test (ScreenManager registry logic, headless-safe).** The scene
  *instantiation* is manually verified; the *registry + selection* logic is unit-tested with a fake.

```gdscript
# tests/test_screen_manager.gd  (add these; keep existing cases)
extends GdUnitTestSuite

const RunPhase := GameState.RunPhase

func test_registers_and_resolves_phase_scene_path() -> void:
	var sm = load("res://src/application/screen_manager.gd").new()
	sm.register_phase_scene(RunPhase.COMBAT, "res://src/presentation/screens/combat.tscn")
	assert_str(sm.scene_path_for_phase(RunPhase.COMBAT)).is_equal("res://src/presentation/screens/combat.tscn")

func test_unregistered_phase_returns_empty() -> void:
	var sm = load("res://src/application/screen_manager.gd").new()
	assert_str(sm.scene_path_for_phase(RunPhase.RUN_END)).is_equal("")
```

- [ ] **Step 2: Run to verify it fails.** Expected: FAIL — no `register_phase_scene` method.
- [ ] **Step 3: Extend `ScreenManager`.** Replace the MVP2 TODO with the real switch, keyed by a
  string registry Main populates. Keep the headless guard.

```gdscript
# add to src/application/screen_manager.gd

# Phase(int) -> scene resource path (String). Populated by Main at boot so Application
# holds only strings — it never imports a Presentation type (LLD-ARCH-001).
var _phase_scenes: Dictionary = {}
# Where instantiated screens are mounted, and a handle to the live run surface. Both set
# by the presentation Main before the first phase_changed.
var screen_root: Node = null
var active_run = null
var _current_screen: Node = null

# @Spec: LLD-ARCH-007
func register_phase_scene(phase: int, scene_path: String) -> void:
	_phase_scenes[phase] = scene_path

func scene_path_for_phase(phase: int) -> String:
	return str(_phase_scenes.get(phase, ""))
```

Then rewrite `_on_phase_changed`:

```gdscript
func _on_phase_changed(new_phase: int, _old_phase: int) -> void:
	current_phase = new_phase
	if GameConfig.HEADLESS:
		return  # headless: no scenes (LLD-ARCH-002)
	var path := scene_path_for_phase(new_phase)
	if path == "" or screen_root == null:
		return  # transitional phases (FLOOR_TRANSITION/RUN_END) have no screen
	if _current_screen != null:
		_current_screen.queue_free()
		_current_screen = null
	var scene: PackedScene = load(path)
	if scene == null:
		return
	_current_screen = scene.instantiate()
	screen_root.add_child(_current_screen)
	# Every screen implements bind(run, content) — duck-typed, no shared base type import.
	if _current_screen.has_method("bind"):
		_current_screen.bind(active_run, ContentRegistry)
```

- [ ] **Step 4: Implement `GameSession`.**

```gdscript
# @Spec: LLD-ARCH-016, LLD-ARCH-020
#
# GameSession — the presentation-side run driver. It is the human's replacement for
# AIPlayerAgent: it owns the live RunController (a Node child, in-tree so it can render),
# wires ScreenManager to switch screens on phase_changed, and starts the run. Screens
# read/submit through get_legal_actions()/submit_action() exactly as the AI does.
class_name GameSession
extends Node

@export var start_seed: int = 1
@export var start_vessel_id: String = "pilgrim"

var run: RunController

func begin(screen_root: Node) -> void:
	GameConfig.HEADLESS = false  # this is the played, on-screen run
	run = RunController.new()
	add_child(run)
	run.configure(RNGService, ContentRegistry, SignalBus)
	ScreenManager.screen_root = screen_root
	ScreenManager.active_run = run
	run.start_run(start_seed, start_vessel_id)  # fires the first phase_changed -> NAVIGATION
```

> **Headless note:** `GameConfig.HEADLESS` is a `const` in MVP1 (`game_config.gd`). Change it to a
> plain `var` (default `true`) in this task so the played run can flip it to `false`; the headless
> determinism gate still runs with the default `true`. This is a one-line change — verify the T7.2
> determinism test still passes after it (it reads, never writes, the flag).

- [ ] **Step 5: Run to verify the ScreenManager tests + full suite pass.**
Run the full suite (`-a res://tests`). Expected: PASS including the 2 new cases and the unchanged
determinism gate.
- [ ] **Step 6: Commit.**
```bash
git add src/presentation/game_session.gd src/application/screen_manager.gd \
        src/infrastructure/game_config.gd tests/test_screen_manager.gd
git commit -m "feat(mvp2): GameSession run driver + ScreenManager path-based scene switching"
```

---

### Task PU0.5 — `Main` root scene + boot; reusable components

**Files:**
- Create: `src/presentation/screens/main.tscn` + `main.gd`
- Create: components (PU0.6 covers their scripts/tests; this task creates `main` + registers phases)
- Modify: `project.godot` (`run/main_scene`)

*(Manually verified — no headless test; this is the scene wiring.)*

- [ ] **Step 1: Build `main.tscn`.** Node tree:

```
Main (Control, full-rect anchors)                [main.gd]
├── ScreenRoot (Control, full-rect)              # ScreenManager mounts screens here
└── GameSession (GameSession node)               # start_seed=1, start_vessel_id="pilgrim"
```

- [ ] **Step 2: Write `main.gd`.**

```gdscript
# @Spec: LLD-PLATFORM-001, LLD-ARCH-016
#
# Main — the MVP2 played-run root. Registers each phase's screen scene path with
# ScreenManager, then tells GameSession to begin() — which starts the RunController and
# drives the first phase_changed, mounting the room-select screen under ScreenRoot.
extends Control

const RunPhase := GameState.RunPhase

@onready var _screen_root: Control = $ScreenRoot
@onready var _session: GameSession = $GameSession

func _ready() -> void:
	ScreenManager.register_phase_scene(RunPhase.NAVIGATION, "res://src/presentation/screens/room_select.tscn")
	ScreenManager.register_phase_scene(RunPhase.COMBAT, "res://src/presentation/screens/combat.tscn")
	ScreenManager.register_phase_scene(RunPhase.LOOT_SELECTION, "res://src/presentation/screens/loot.tscn")
	# NON_COMBAT_EVENT is registered by Plan 2. FLOOR_TRANSITION/RUN_END have no screen in MVP2.
	_session.begin(_screen_root)
```

- [ ] **Step 3: Set `run/main_scene="res://src/presentation/screens/main.tscn"` in `project.godot`.**

- [ ] **Step 4: Manual verify (deferred until PU1 lands a real room_select scene).** For now register a
  temporary empty `Control` scene at the room_select path so boot doesn't error, OR land PU1 first then
  return to confirm boot shows the room-select screen. Document which you did in the commit body.

- [ ] **Step 5: Commit.**
```bash
git add src/presentation/screens/main.tscn src/presentation/screens/main.gd project.godot
git commit -m "feat(mvp2): Main root scene registers phase screens and boots the session"
```

---

### Task PU0.6 — Reusable components (HP bar, status row, charge dots, damage-type icon, ghost menu)

**Files (each a `.tscn` + `.gd` under `src/presentation/components/`):**
- Create: `hp_bar`, `status_row`, `charge_dots`, `damage_type_icon`, `ghost_menu`
- Test: `tests/test_status_row.gd`, `tests/test_charge_dots.gd` (the two with real logic)

Only the **layout logic** of `status_row` (overflow → "+N more", `UI-COMBAT-003`) and `charge_dots`
(spent-before-remaining ordering, `UI-COMBAT-009`) has correctness worth TDD'ing; extract that logic to
static functions so it is headless-testable, and keep the scene scripts thin wrappers over it.

- [ ] **Step 1: Write the failing tests.**

```gdscript
# tests/test_status_row.gd
extends GdUnitTestSuite
# UI-COMBAT-003: show as many icons as fit, then an overflow badge "+N more".
func test_overflow_splits_visible_and_badge() -> void:
	var r := StatusRow.layout(["burning","poisoned","chilled","shocked","exposed"], 3)
	assert_array(r["visible"]).is_equal(["burning","poisoned","chilled"])
	assert_int(r["overflow"]).is_equal(2)
func test_no_overflow_when_within_cap() -> void:
	var r := StatusRow.layout(["burning","poisoned"], 3)
	assert_array(r["visible"]).is_equal(["burning","poisoned"])
	assert_int(r["overflow"]).is_equal(0)
```

```gdscript
# tests/test_charge_dots.gd
extends GdUnitTestSuite
# UI-COMBAT-009: spent charges are a bare red X, placed BEFORE remaining dots (left=used).
func test_spent_before_remaining() -> void:
	var marks := ChargeDots.marks(1, 3)  # remaining=1, max=3 -> 2 spent, 1 remaining
	assert_array(marks).is_equal(["spent","spent","dot"])
func test_full_is_all_dots() -> void:
	assert_array(ChargeDots.marks(3, 3)).is_equal(["dot","dot","dot"])
func test_unlimited_is_empty_marks() -> void:
	assert_array(ChargeDots.marks(-1, -1)).is_empty()  # unlimited sentinel -> caller renders the word
```

- [ ] **Step 2: Run to verify they fail.** Expected: FAIL — `StatusRow` / `ChargeDots` not found.
- [ ] **Step 3: Implement the two logic scripts** (scene scripts, with the tested statics on the class).

```gdscript
# src/presentation/components/status_row.gd
# @Spec: UI-COMBAT-003
class_name StatusRow
extends HBoxContainer

# Split status ids into the visible prefix and an overflow count for the "+N more" badge.
static func layout(status_ids: Array, max_visible: int) -> Dictionary:
	if status_ids.size() <= max_visible:
		return {"visible": status_ids.duplicate(), "overflow": 0}
	return {"visible": status_ids.slice(0, max_visible), "overflow": status_ids.size() - max_visible}

# render() (thin, manual-verified): clears children, adds a TextureRect per visible id via
# ArtPaths.status_icon, appends a Label "+N more" when overflow>0. No tooltips (UI-GLOBAL-002).
func render(status_ids: Array, max_visible: int) -> void:
	pass  # implement against Godot nodes; verified by running the game
```

```gdscript
# src/presentation/components/charge_dots.gd
# @Spec: UI-COMBAT-009, UI-LOOT-004
class_name ChargeDots
extends HBoxContainer

const UNLIMITED := -1

# Marks left→right in depletion order: spent ("X") first, remaining ("dot") after.
static func marks(remaining: int, max_charges: int) -> Array:
	if remaining == UNLIMITED or max_charges == UNLIMITED:
		return []
	var out: Array = []
	for i in (max_charges - remaining):
		out.append("spent")
	for i in remaining:
		out.append("dot")
	return out

func render(remaining: int, max_charges: int) -> void:
	pass  # spent -> bare red "X" Label; dot -> small filled circle TextureRect. Manual-verified.
```

- [ ] **Step 4: Build the five component scenes** (thin, manual-verified). Trees:
  - `hp_bar.tscn`: `HPBar (ProgressBar)` — `set_hp(cur, max)` sets `max_value`/`value`; horizontal.
    `@Spec: UI-COMBAT-003`.
  - `status_row.tscn`: `StatusRow (HBoxContainer)` — script above.
  - `charge_dots.tscn`: `ChargeDots (HBoxContainer)` — script above.
  - `damage_type_icon.tscn`: `DamageTypeIcon (TextureRect)` — `set_type(t)` loads `ArtPaths.damage_icon(t)`
    and applies `ArtPaths.damage_tint(t)` as a background/`modulate` per `UI-GLOBAL-003` (shape + tint,
    redundant encoding). `@Spec: UI-GLOBAL-003`.
  - `ghost_menu.tscn`: `GhostMenu (Label "≡")` anchored top-right (top 3%, right 4%), `modulate.a=0.4`,
    non-interactive. `@Spec: UI-ROOM-006`. Reused verbatim by every screen.

- [ ] **Step 5: Run to verify the logic tests pass.** Expected: PASS (5 cases across the 2 files).
- [ ] **Step 6: Commit.**
```bash
git add src/presentation/components tests/test_status_row.gd tests/test_charge_dots.gd
git commit -m "feat(mvp2): reusable UI components + tested overflow/charge-dot layout logic"
```

---

# Phase PU1 — Room-select screen (NAVIGATION)

Simplest full screen; the NAVIGATION engine already exists. `ui-room-select-screen`.

### Task PU1.1 — `RoomSelectViewModel` (TDD)

**Files:**
- Create: `src/presentation/view_models/room_select_view_model.gd`
- Test: `tests/test_room_select_view_model.gd`

The view-model maps the two `DoorData` in `navigation_state.doors_ahead` + each door's legal
`CHOOSE_DOOR` action to display rows, computes the floor-progress segments (`UI-ROOM-008`), and resolves
each door's symbol (`UI-ROOM-002`, combat → per-enemy symbol via `ArtPaths.door_symbol`, MF/WS → fixed
symbol). It **pairs each door with its legal action** so the view submits verbatim.

- [ ] **Step 1: Write the failing test.** Build a `GameState` with two doors and a matching legal-action
  list; assert the door rows carry the right symbol path and the exact action dict.

```gdscript
# tests/test_room_select_view_model.gd
extends GdUnitTestSuite

func _door(room_id: String, room_type: String, enc: String) -> DoorData:
	var d := DoorData.new(); d.room_id = room_id; d.room_type = room_type; d.encounter_id = enc; return d

func _state_with_two_doors() -> GameState:
	var gs := GameState.new()
	gs.floor_number = 3
	gs.navigation_state = NavigationState.new()
	gs.navigation_state.rooms_completed_this_floor = 2
	gs.navigation_state.doors_ahead.assign([
		_door("r1", "combat", "plague_rat"),
		_door("r2", "combat", "skeleton"),
	])
	return gs

func test_two_door_rows_pair_symbol_with_legal_action() -> void:
	var gs := _state_with_two_doors()
	var legal := [
		{"type": "CHOOSE_DOOR", "room_id": "r1"},
		{"type": "CHOOSE_DOOR", "room_id": "r2"},
	]
	var vm := RoomSelectViewModel.new(gs, legal)
	var rows := vm.door_rows()
	assert_int(rows.size()).is_equal(2)
	assert_str(rows[0]["symbol"]).is_equal(ArtPaths.door_symbol("plague_rat"))
	assert_dict(rows[0]["action"]).is_equal({"type": "CHOOSE_DOOR", "room_id": "r1"})

# UI-ROOM-008: one segment per room; filled == rooms completed; exact real count (no obscuring).
func test_floor_progress_segments() -> void:
	var gs := _state_with_two_doors()
	gs.navigation_state.segment_room_counts = {"a": 5, "b": 4}  # 9 rooms total
	var vm := RoomSelectViewModel.new(gs, [])
	assert_int(vm.total_rooms()).is_equal(9)
	assert_int(vm.rooms_completed()).is_equal(2)

func test_vessel_sprite_path() -> void:
	var gs := _state_with_two_doors()
	gs.vessel_state = VesselState.new(); gs.vessel_state.vessel_id = "pilgrim"
	var vm := RoomSelectViewModel.new(gs, [])
	assert_str(vm.vessel_sprite()).is_equal(ArtPaths.vessel_sprite("pilgrim"))
```

- [ ] **Step 2: Run to verify it fails.** Expected: FAIL — `RoomSelectViewModel` not found.
- [ ] **Step 3: Implement.**

```gdscript
# @Spec: UI-ROOM-002, UI-ROOM-008, UI-ROOM-007
#
# RoomSelectViewModel — maps NAVIGATION GameState + the legal CHOOSE_DOOR actions to the
# room-select display. Pure/headless; the view renders these dictionaries and submits the
# paired action verbatim. A door's symbol identifies the SPECIFIC enemy for combat doors
# (UI-ROOM-002) and a fixed symbol for MF/WS doors.
class_name RoomSelectViewModel
extends RefCounted

const _MF_SYMBOL := ArtPaths.DOOR_SYMBOL_PLACEHOLDER  # fixed MF symbol (real asset in the art session)
const _WS_SYMBOL := ArtPaths.DOOR_SYMBOL_PLACEHOLDER  # fixed WS symbol (real asset in the art session)

var _gs: GameState
var _legal: Array

func _init(gs: GameState, legal_actions: Array) -> void:
	_gs = gs
	_legal = legal_actions

# One row per door: { "symbol": path, "action": the paired CHOOSE_DOOR dict }.
func door_rows() -> Array:
	var rows: Array = []
	for door in _gs.navigation_state.doors_ahead:
		var action := _action_for(door.room_id)
		if action.is_empty():
			continue
		rows.append({"symbol": _symbol_for(door), "action": action})
	return rows

func _action_for(room_id: String) -> Dictionary:
	for a in _legal:
		if str(a.get("type", "")) == "CHOOSE_DOOR" and str(a.get("room_id", "")) == room_id:
			return a
	return {}

func _symbol_for(door: DoorData) -> String:
	match door.room_type:
		"memory_fragment": return _MF_SYMBOL
		"wandering_soul": return _WS_SYMBOL
		_: return ArtPaths.door_symbol(door.encounter_id)  # combat/elite: per-enemy symbol

# @Spec: UI-ROOM-008
func total_rooms() -> int:
	var n := 0
	for count in _gs.navigation_state.segment_room_counts.values():
		n += int(count)
	return n

func rooms_completed() -> int:
	return _gs.navigation_state.rooms_completed_this_floor

# @Spec: UI-ROOM-007
func vessel_sprite() -> String:
	return ArtPaths.vessel_sprite(_gs.vessel_state.vessel_id) if _gs.vessel_state != null else ""
```

- [ ] **Step 4: Run to verify pass.** Expected: PASS (4 cases).
- [ ] **Step 5: Commit.**
```bash
git add src/presentation/view_models/room_select_view_model.gd tests/test_room_select_view_model.gd
git commit -m "feat(mvp2): RoomSelectViewModel (UI-ROOM-002/-007/-008)"
```

---

### Task PU1.2 — `room_select.tscn` view (manual-verified)

**Files:** Create `src/presentation/screens/room_select.tscn` + `room_select.gd`.

- [ ] **Step 1: Build the scene** per `UI-ROOM-005` composition order (top→bottom: ghost menu →
  heading → two doors side-by-side under the heading → vessel sprite near bottom → segmented
  floor-progress bar footer; ~2-line breathing gap above heading):

```
RoomSelect (Control, full-rect)                   [room_select.gd]
├── GhostMenu (instance of ghost_menu.tscn)       # top 3%, right 4% (UI-ROOM-006)
├── Heading (Label, anchored top, gap ≈2 lines above)
├── Doors (HBoxContainer, anchored under heading)  # UI-ROOM-004 side-by-side
│   ├── DoorButton0 (TextureButton)                # symbol only, NO caption (UI-ROOM-003)
│   └── DoorButton1 (TextureButton)
├── VesselSprite (TextureRect, anchored bottom, ~26% width, 1:1.2)  # UI-ROOM-007
└── ProgressBar (HBoxContainer of segments, footer) # UI-ROOM-008 one seg/room, no text
```

- [ ] **Step 2: Write `room_select.gd`.** `bind(run, content)` builds the view-model and renders; each
  door button submits its paired action.

```gdscript
# @Spec: UI-ROOM-001, UI-ROOM-003, UI-ROOM-004, UI-ROOM-005, UI-ROOM-008, LLD-ARCH-002
extends Control

var _run  # RunController
@onready var _doors: HBoxContainer = $Doors
@onready var _vessel: TextureRect = $VesselSprite
@onready var _progress: HBoxContainer = $ProgressBar

func bind(run, _content) -> void:
	_run = run
	if GameConfig.HEADLESS:
		queue_free()  # never render under headless (LLD-ARCH-002)
		return
	_render()

func _render() -> void:
	var vm := RoomSelectViewModel.new(_run.game_state, _run.get_legal_actions())
	# doors: symbol-only buttons (UI-ROOM-003), exactly two (UI-ROOM-001)
	var rows := vm.door_rows()
	var buttons := [$Doors/DoorButton0, $Doors/DoorButton1]
	for i in buttons.size():
		var btn: TextureButton = buttons[i]
		if i < rows.size():
			btn.texture_normal = load(rows[i]["symbol"])
			var action: Dictionary = rows[i]["action"]
			# submit the paired legal action verbatim
			if not btn.pressed.is_connected(_on_door):
				btn.pressed.connect(_on_door.bind(action))
			btn.visible = true
		else:
			btn.visible = false
	_vessel.texture = load(vm.vessel_sprite())
	_render_segments(vm.total_rooms(), vm.rooms_completed())

func _render_segments(total: int, filled: int) -> void:
	for c in _progress.get_children():
		c.queue_free()
	for i in total:
		var seg := ColorRect.new()
		seg.custom_minimum_size = Vector2(8, 6)
		seg.color = Color.WHITE if i < filled else Color(1, 1, 1, 0.25)
		_progress.add_child(seg)

func _on_door(action: Dictionary) -> void:
	_run.submit_action(action)  # RunController advances the phase; ScreenManager swaps the screen
```

- [ ] **Step 3: Manual verify.** Launch the game (`…win64_console.exe --path .`). Expected: room-select
  shows two symbol-only doors, the Pilgrim sprite near the bottom, and a segmented progress bar with the
  real room count. Tapping a door transitions to the combat screen (once PU3 lands) — until then, verify
  the door press logs a phase change to COMBAT (add a temporary `print` or watch `EventLog`).

- [ ] **Step 4: Commit.**
```bash
git add src/presentation/screens/room_select.tscn src/presentation/screens/room_select.gd
git commit -m "feat(mvp2): room-select screen view (ui-room-select-screen)"
```

---

# Phase PU2 — Loot screen (LOOT_SELECTION)

`ui-loot-screen`. Three-zone portrait layout; ternary choice via `CHOOSE_LOOT`/`DECLINE_LOOT`.

### Task PU2.1 — `LootViewModel` (TDD)

**Files:**
- Create: `src/presentation/view_models/loot_view_model.gd`
- Test: `tests/test_loot_view_model.gd`

Maps `navigation_state.loot_offers` (an `Array[String]` of item ids) + the legal `CHOOSE_LOOT`/
`DECLINE_LOOT` actions to: an inventory count strip (weapons/support/consumables held, `UI-LOOT-002`,
by reading each held item's `action_bucket` from content), and one card per offer with the correct
card kind (weapon/consumable/support, `UI-LOOT-004/-005/-006`) paired with its `CHOOSE_LOOT` action.
Card kind = `action_bucket` (`attack`→`weapon`, `support`→`support`, `consumable`→`consumable`);
weapon damage/type come from the `deal_damage` handler's `params` (`base_damage`, `damage_type`),
consumable/support effect from the `apply_status`/`cleanse_status` handler — **not** top-level fields
(see "Canonical facts"; read `src/domain/handlers/` in PU0.2 to confirm param keys).

- [ ] **Step 1: Write the failing test** using a fake content provider so it stays headless and
  content-agnostic.

```gdscript
# tests/test_loot_view_model.gd
extends GdUnitTestSuite

class FakeContent:
	var _by_id: Dictionary
	func _init(by_id: Dictionary) -> void: _by_id = by_id
	func get_ability(id: String): return _by_id.get(id)

# Damage/type live in a deal_damage HandlerConfig, never on AbilityData directly.
func _weapon(dmg: int, dtype: String) -> AbilityData:
	var a := AbilityData.new()
	a.action_bucket = "attack"
	a.display_name = "Test Weapon"
	var h := HandlerConfig.new()
	h.handler_id = "deal_damage"
	h.params = {"base_damage": dmg, "damage_type": dtype}
	a.handlers.assign([h])
	return a

func _support() -> AbilityData:
	var a := AbilityData.new()
	a.action_bucket = "support"
	a.display_name = "Test Charm"
	return a

func _gs_with_offers(offers: Array, inventory: Array) -> GameState:
	var gs := GameState.new()
	gs.navigation_state = NavigationState.new()
	gs.navigation_state.loot_offers.assign(offers)
	gs.inventory.assign(inventory)
	return gs

func test_count_strip_tallies_by_bucket() -> void:
	var content := FakeContent.new({
		"axe": _weapon(8, "physical"),
		"charm": _support(),
	})
	var w := ItemInstance.new(); w.item_id = "axe"
	var s := ItemInstance.new(); s.item_id = "charm"
	var gs := _gs_with_offers([], [w, s, null])
	var vm := LootViewModel.new(gs, [], content)
	var strip := vm.count_strip()
	assert_int(strip["weapons"]).is_equal(1)
	assert_int(strip["support"]).is_equal(1)
	assert_int(strip["consumables"]).is_equal(0)

func test_offer_card_pairs_with_choose_loot_action() -> void:
	var content := FakeContent.new({"axe": _weapon(8, "physical")})
	var gs := _gs_with_offers(["axe"], [null, null, null])
	var legal := [{"type": "CHOOSE_LOOT", "item_id": "axe"}, {"type": "DECLINE_LOOT"}]
	var vm := LootViewModel.new(gs, legal, content)
	var cards := vm.offer_cards()
	assert_int(cards.size()).is_equal(1)
	assert_str(cards[0]["kind"]).is_equal("weapon")
	assert_int(cards[0]["damage"]).is_equal(8)
	assert_str(cards[0]["damage_type"]).is_equal("physical")
	assert_dict(cards[0]["action"]).is_equal({"type": "CHOOSE_LOOT", "item_id": "axe"})

func test_decline_action_exposed() -> void:
	var gs := _gs_with_offers([], [])
	var vm := LootViewModel.new(gs, [{"type": "DECLINE_LOOT"}], FakeContent.new({}))
	assert_dict(vm.decline_action()).is_equal({"type": "DECLINE_LOOT"})
```

- [ ] **Step 2: Run to verify it fails.** Expected: FAIL — `LootViewModel` not found.
- [ ] **Step 3: Implement** (map `action_bucket` → card `kind`: `attack`→`weapon`, `support`→`support`,
  `consumable`→`consumable`). Keep card dicts holding only the raw values the view renders; the view
  applies `DisplayText`/`ArtPaths`. Cite `UI-LOOT-002/-004/-005/-006`. *(Full implementation mirrors the
  test's expected shape — each offer id → `content.get_ability(id)` → `{kind, name, damage, damage_type,
  hits, effect, target, action}`; count strip iterates non-null inventory and tallies by bucket.)*

- [ ] **Step 4: Run to verify pass.** Expected: PASS (3 cases).
- [ ] **Step 5: Commit.**
```bash
git add src/presentation/view_models/loot_view_model.gd tests/test_loot_view_model.gd
git commit -m "feat(mvp2): LootViewModel — count strip + typed offer cards (ui-loot-screen)"
```

---

### Task PU2.2 — `loot.tscn` view (manual-verified)

**Files:** Create `src/presentation/screens/loot.tscn` + `loot.gd`.

- [ ] **Step 1: Build the scene** per `UI-LOOT-001` zone order (count strip → static loot image
  `ArtPaths.LOOT_PLACEHOLDER` → stacked offer cards, durability above consumable → decline bar with a
  larger gap above it, `UI-LOOT-007`):

```
Loot (Control, full-rect)                          [loot.gd]
├── CountStrip (HBoxContainer, top)                # weapons / support / consumables badges (UI-LOOT-002)
├── LootImage (TextureRect, full width, height-capped)  # UI-LOOT-003
├── Cards (VBoxContainer)                          # UI-LOOT-001 stacked, durability first
│   ├── OfferCard0 (PanelContainer)
│   └── OfferCard1 (PanelContainer)
└── DeclineBar (Button "Leave both", lighter weight, larger top gap)  # UI-LOOT-007/-008
```

- [ ] **Step 2: Write `loot.gd`.** Render card kinds with the right layout (weapon = damage hero +
  `DamageTypeIcon` + `ChargeDots`, `UI-LOOT-004`; consumable = `DisplayText.effect_line` hero + target,
  `UI-LOOT-005`; support = effect leads + "Drains 1 charge per room" + `ChargeDots`, `UI-LOOT-006`).
  **Asymmetric commit (`UI-LOOT-008`):** card tap submits `CHOOSE_LOOT` immediately; "Leave both" opens
  a confirm step, then submits `DECLINE_LOOT`. No damage-type word anywhere (`UI-LOOT-004`), no status
  tooltips (`UI-GLOBAL-002`). Same `bind(run, content)` + headless-free-self pattern as `room_select.gd`.

- [ ] **Step 3: Manual verify.** Win a combat (once PU3 lands) or temporarily force `LOOT_SELECTION` to
  reach this screen. Expected: count strip reflects held items; two stacked cards with correct layouts;
  damage type shown by icon+tint only; tapping a card takes it immediately and advances; "Leave both"
  asks for confirmation before declining.

- [ ] **Step 4: Commit.**
```bash
git add src/presentation/screens/loot.tscn src/presentation/screens/loot.gd
git commit -m "feat(mvp2): loot screen view — ternary choice, asymmetric commit (ui-loot-screen)"
```

---

# Phase PU3 — Combat screen (COMBAT)

The largest screen. `ui-combat-screen` + `ui-omen-screen`. Split into a view-model, the static layout,
the action bar + selection sheet, target selection, the omen overlay, and event feedback.

### Task PU3.1 — `CombatViewModel`: formations, unit stacks, action buckets (TDD)

**Files:**
- Create: `src/presentation/view_models/combat_view_model.gd`
- Test: `tests/test_combat_view_model.gd`

The heaviest view-model. Responsibilities (each a tested method):
1. **Enemy formation positions** by count (`UI-COMBAT-001/-002`): 1 → centered at midpoint ≈27% height;
   2 → 28%/72% horizontal at midpoint; 3 → back-center ≈18% + front 20%/80% ≈36%, back slightly smaller.
   Return normalized `{x, y, scale}` per enemy.
2. **Per-enemy stack** (`UI-COMBAT-003`): intent icon path (`ArtPaths.intent_icon(current_intent)`),
   sprite, hp `{cur,max}`, status ids for the row. **Vessel stack** (`UI-COMBAT-004`): same minus intent.
3. **Top bar** (`UI-COMBAT-006`): omen countdown = `current_cycle.ticks_remaining`.
4. **Action-bucket contents** (`UI-COMBAT-009`): partition the legal combat actions into the three
   buckets — Action (Default Strike + weapons), Support (support items + vessel support ability),
   Consumable — each row `{label, icon, summary, charges:{remaining,max}|unlimited, requires_target,
   action}`. **Rows are built from `get_legal_actions()`**, so gating (stun, zero-charge, repent,
   omen-choice, read-the-road) is already reflected — the view never re-derives legality.

- [ ] **Step 1: Write the failing test** (formation math is the highest-value unit test; plus bucket
  partitioning).

```gdscript
# tests/test_combat_view_model.gd
extends GdUnitTestSuite

func _enemy(id: String, inst: String, hp: int) -> EnemyState:
	var e := EnemyState.new(); e.enemy_id = id; e.instance_id = inst; e.hp = hp; e.max_hp = hp; return e

func _combat_state(enemies: Array) -> GameState:
	var gs := GameState.new()
	gs.vessel_state = VesselState.new(); gs.vessel_state.hp = 20; gs.vessel_state.max_hp = 20
	gs.combat_state = CombatState.new()
	gs.combat_state.enemies.assign(enemies)
	gs.combat_state.current_cycle = OmenCycleState.new()
	gs.combat_state.current_cycle.ticks_remaining = 2
	return gs

# UI-COMBAT-001: single enemy centered at the enemy-area midpoint (~27% height).
func test_single_enemy_centered() -> void:
	var gs := _combat_state([_enemy("plague_rat", "plague_rat_0", 6)])
	var vm := CombatViewModel.new(gs, [], _FakeContent.new())
	var pos := vm.enemy_positions()
	assert_int(pos.size()).is_equal(1)
	assert_float(pos[0]["x"]).is_equal_approx(0.5, 0.001)
	assert_float(pos[0]["y"]).is_equal_approx(0.27, 0.01)

# UI-COMBAT-002: two-enemy uses its OWN 28%/72% spacing, not the triangle's 20%/80%.
func test_two_enemy_horizontal_spacing() -> void:
	var gs := _combat_state([_enemy("wolf", "wolf_0", 5), _enemy("wolf", "wolf_1", 5)])
	var vm := CombatViewModel.new(gs, [], _FakeContent.new())
	var pos := vm.enemy_positions()
	assert_float(pos[0]["x"]).is_equal_approx(0.28, 0.001)
	assert_float(pos[1]["x"]).is_equal_approx(0.72, 0.001)

# UI-COMBAT-001: three-enemy triangle — back-center higher and smaller, front pair 20%/80%.
func test_three_enemy_triangle() -> void:
	var gs := _combat_state([_enemy("a","a_0",5), _enemy("b","b_0",5), _enemy("c","c_0",5)])
	var vm := CombatViewModel.new(gs, [], _FakeContent.new())
	var pos := vm.enemy_positions()
	assert_float(pos[0]["x"]).is_equal_approx(0.5, 0.001)   # back-center
	assert_float(pos[0]["y"]).is_equal_approx(0.18, 0.01)
	assert_bool(pos[0]["scale"] < pos[1]["scale"]).is_true() # back reads smaller/further
	assert_float(pos[1]["x"]).is_equal_approx(0.20, 0.001)
	assert_float(pos[2]["x"]).is_equal_approx(0.80, 0.001)

func test_omen_countdown_from_cycle() -> void:
	var gs := _combat_state([_enemy("a","a_0",5)])
	var vm := CombatViewModel.new(gs, [], _FakeContent.new())
	assert_int(vm.omen_countdown()).is_equal(2)

# UI-COMBAT-009: buckets are partitioned from the legal actions (gating already applied upstream).
func test_action_bucket_partition_from_legal() -> void:
	var gs := _combat_state([_enemy("a","a_0",5)])
	var legal := [
		{"type": "USE_ABILITY", "ability_id": "default_strike", "target_id": "a_0"},
		{"type": "EVADE"},
		{"type": "END_TURN"},
	]
	var vm := CombatViewModel.new(gs, legal, _FakeContent.new_with_strike())
	var action_rows := vm.bucket_rows("action")
	# Default Strike appears in the Action bucket, paired with its USE_ABILITY action.
	assert_bool(action_rows.any(func(r): return r["action"]["ability_id"] == "default_strike")).is_true()
```

> Add a small `_FakeContent` inner class to the test exposing `get_ability`/`get_vessel`/`get_enemy`
> returning minimal `AbilityData`/`VesselData`/`EnemyData` so the view-model resolves buckets/summaries
> without the real registry. Model it on `test_loot_view_model.gd::FakeContent`.

- [ ] **Step 2: Run to verify it fails.** Expected: FAIL — `CombatViewModel` not found.
- [ ] **Step 3: Implement `CombatViewModel`** with the formation constants above, the stack builders, and
  bucket partitioning driven by each action's resolved `action_bucket` (Default Strike routed to Action;
  `USE_ITEM` slot → the item's bucket; vessel support ability → Support). Cite
  `UI-COMBAT-001..-006, -009`.

- [ ] **Step 4: Run to verify pass.** Expected: PASS (6 cases).
- [ ] **Step 5: Commit.**
```bash
git add src/presentation/view_models/combat_view_model.gd tests/test_combat_view_model.gd
git commit -m "feat(mvp2): CombatViewModel — formations, unit stacks, action buckets (ui-combat-screen)"
```

---

### Task PU3.2 — Combat static layout: formations, unit stacks, top bar (manual-verified)

**Files:** Create `src/presentation/screens/combat.tscn` + `combat.gd` (grows across PU3.2–PU3.5).

- [ ] **Step 1: Build the scene skeleton.**

```
Combat (Control, full-rect)                        [combat.gd]
├── GhostMenu (ghost_menu.tscn instance)           # UI-COMBAT-006 top-right placeholder
├── TopBar (Control, top)
│   └── OmenBadge (Label "Omen draw in: N")         # UI-COMBAT-006 top-left, number-only (UI-OMEN-011)
├── EnemyArea (Control, ~7%–47% height band)        # UI-COMBAT-002
│   └── (EnemyCells added at runtime, 26% width each) # UI-COMBAT-003
├── AllyRow (HBoxContainer, vessel + companions)    # UI-COMBAT-004/-005
│   ├── Vessel (unit stack: sprite/hp/status, no intent)
│   └── Companions (no hp/no status, flanking inward) # UI-COMBAT-005
├── ActionBar (Control, bottom)                     # PU3.3
└── OmenOverlay (CanvasLayer, hidden)               # PU3.4
```

- [ ] **Step 2: Write `combat.gd` render pass** for positions + stacks. `bind(run, content)` (headless
  → free self), build `CombatViewModel`, instantiate an `EnemyCell` per `enemy_positions()` entry using
  `set_anchors_preset`/anchor fractions from the normalized `{x,y,scale}` (anchors only, `LLD-PLATFORM-003`),
  each cell = `intent icon` (top) + sprite + `hp_bar` + `status_row` (`UI-COMBAT-003`); render the vessel
  stack (`UI-COMBAT-004`) and companion sprites (`UI-COMBAT-005`); set the omen badge to
  `vm.omen_countdown()`. Re-render on `SignalBus` combat signals (wired in PU3.5).

- [ ] **Step 3: Manual verify** with 1-, 2-, and 3-enemy encounters (seed the run to reach each, or a
  temporary debug spawn). Expected: enemies sit at the spec positions; back triangle unit is smaller;
  vessel has no intent; companions flank inward with no hp/status; omen badge shows the countdown.

- [ ] **Step 4: Commit.**
```bash
git add src/presentation/screens/combat.tscn src/presentation/screens/combat.gd
git commit -m "feat(mvp2): combat static layout — formations, unit stacks, top bar"
```

---

### Task PU3.3 — Action bar + selection sheet + target selection (manual-verified)

**Files:** Extend `combat.tscn` + `combat.gd`; add `src/presentation/components/selection_sheet.tscn` + `.gd`.

- [ ] **Step 1: Build the action bar** (`UI-COMBAT-007`): one `TextureButton` circle (Action) centered
  between two rectangles (Support left, Consumable right); circle bottom aligns with rectangle bottoms,
  35% of the circle protrudes above them (rectangle height = 65% of circle diameter). Use anchors/ratios,
  no fixed pixels.

- [ ] **Step 2: Build the selection sheet** (`UI-COMBAT-009/-010`): a bottom `PanelContainer` that slides
  up over a dimmed scene at a fixed height covering the vessel sprite; a `ScrollContainer` list that
  scrolls internally with a bottom fade gradient when overflowing (`UI-COMBAT-010`); a header "cancel".
  Each row: leading `item_icon`, name, one-line summary, and the charge readout — "unlimited" for Default
  Strike, else `ChargeDots` (spent red-X before remaining, `UI-COMBAT-009`).

- [ ] **Step 3: Wire bucket taps → sheet.** Tapping a bucket opens the sheet populated from
  `vm.bucket_rows(bucket)`. Tapping a row that needs no target submits its paired action immediately.
  **Target selection (`UI-COMBAT-011`):** a row that `requires_target` keeps the sheet open, marks the
  row committed (border/checkmark/prompt), and highlights every valid enemy (ring + "tap to target");
  tapping an enemy fills `target_id` on the paired action and submits. All submitted actions come from
  the view-model rows verbatim.

- [ ] **Step 4: Action-bar state transitions (`UI-COMBAT-008`).** After the Action bucket resolves, the
  Action circle relabels to "End Turn" (same circle, submits `END_TURN`); used Support/Consumable grey
  out. No auto-advance — ending the turn is always an explicit tap. Drive greying from
  `combat_state.is_action_used/is_support_used/is_consumable_used`.

- [ ] **Step 5: Manual verify.** Open each bucket; confirm the sheet slides over a dimmed scene at fixed
  height, lists usable options with correct charge glyphs, scrolls with a bottom fade past ~5 items,
  cancel returns cleanly; a single-target weapon highlights all living enemies and hits the tapped one;
  after the Action resolves the circle reads "End Turn" and used buckets grey out; End Turn requires a
  tap.

- [ ] **Step 6: Commit.**
```bash
git add src/presentation/screens/combat.tscn src/presentation/screens/combat.gd \
        src/presentation/components/selection_sheet.tscn src/presentation/components/selection_sheet.gd
git commit -m "feat(mvp2): combat action bar, selection sheet, target selection (UI-COMBAT-007..-011)"
```

---

### Task PU3.4 — Omen overlay: `OmenOverlayViewModel` (TDD) + overlay view

**Files:**
- Create: `src/presentation/view_models/omen_overlay_view_model.gd`
- Test: `tests/test_omen_overlay_view_model.gd`
- Create: `src/presentation/screens/omen_overlay.tscn` + `omen_overlay.gd`

The omen draw is an **overlay on the combat screen**, not a scene switch (`UI-OMEN-001`). The engine
signals a draw and exposes the three drawn cards via `combat_state.current_cycle.drawn_cards` and the
legal `CHOOSE_OMEN` actions (6 = 3 cards × 2 sides). The view-model maps the three cards to the two-box
anatomy (`UI-OMEN-003`) and pairs each card+side with its `CHOOSE_OMEN` action for the two-step flow
(`UI-OMEN-004`).

- [ ] **Step 1: Write the failing test.**

```gdscript
# tests/test_omen_overlay_view_model.gd
extends GdUnitTestSuite

func _cycle_with_cards(cards: Array) -> GameState:
	var gs := GameState.new()
	gs.combat_state = CombatState.new()
	gs.combat_state.current_cycle = OmenCycleState.new()
	gs.combat_state.current_cycle.drawn_cards.assign(cards)
	return gs

# UI-OMEN-003: every drawn card shows both an effect box and a duration (number) box.
func test_three_cards_have_effect_and_duration_boxes() -> void:
	var gs := _cycle_with_cards([
		{"card_id": "burning_omen", "timer_value": 3},
		{"card_id": "chill_omen", "timer_value": 5},
		{"card_id": "spark_omen", "timer_value": 2},
	])
	var vm := OmenOverlayViewModel.new(gs, [], _FakeOmenContent.new())
	var cards := vm.cards()
	assert_int(cards.size()).is_equal(3)
	assert_int(cards[0]["duration"]).is_equal(3)
	assert_bool(cards[0].has("effect_icon")).is_true()

# UI-OMEN-004: each card exposes its two CHOOSE_OMEN actions (one per side), paired for the flow.
func test_card_pairs_both_side_actions() -> void:
	var gs := _cycle_with_cards([{"card_id": "burning_omen", "timer_value": 3}])
	var legal := [
		{"type": "CHOOSE_OMEN", "card_index": 0, "side": "enemy"},
		{"type": "CHOOSE_OMEN", "card_index": 0, "side": "player"},
	]
	var vm := OmenOverlayViewModel.new(gs, legal, _FakeOmenContent.new())
	var sides := vm.side_actions(0)
	assert_dict(sides["enemy"]).is_equal({"type": "CHOOSE_OMEN", "card_index": 0, "side": "enemy"})
	assert_dict(sides["player"]).is_equal({"type": "CHOOSE_OMEN", "card_index": 0, "side": "player"})
```

> Add `_FakeOmenContent` exposing `get_omen_card(id)` → an `OmenCardData` with a display name / effect
> summary / status id, so `cards()` can build `effect_icon`, effect text (via `DisplayText`), and the
> duration. Confirm `OmenCardData`'s exact fields (Task PU0.2 read) before finalising the mapping.

- [ ] **Step 2: Run to verify it fails.** Expected: FAIL — `OmenOverlayViewModel` not found.
- [ ] **Step 3: Implement** `cards()` (per card: `effect_icon`, effect `DisplayText` segment,
  `duration`) and `side_actions(index)` (`{"enemy": dict, "player": dict}` from the legal set). Cite
  `UI-OMEN-003/-004/-008`.

- [ ] **Step 4: Run to verify pass.** Expected: PASS (2 cases).

- [ ] **Step 5: Build `omen_overlay.tscn` + script (manual-verified).** Dimmed overlay on a `CanvasLayer`
  over the still-visible combat board (`UI-OMEN-001`); three cards in a fixed vertical stack that never
  reposition (`UI-OMEN-002/-007`); two-box anatomy per card (`UI-OMEN-003`). Two-step flow
  (`UI-OMEN-004`): tap a card → it docks centered showing **effect box only** (`UI-OMEN-006`) and the
  real board positions pulse as target zones — enemy cluster + vessel footprint only, companions excluded
  (`UI-OMEN-005`); tap a side → submit that card+side's `CHOOSE_OMEN` action. Selectable cards glow, zones
  pulse, **no text prompts** (`UI-OMEN-009`). On resolution (`UI-OMEN-008`): chosen card fully hidden with
  its slot space preserved, auto-applied card shows effect box only, leftover card shows duration box only
  (its number becomes the new countdown); then the overlay fades silently to the plain combat screen
  (`UI-OMEN-010`), badge updated, status chip on each affected side. `combat.gd` shows the overlay when a
  draw is pending (the legal actions contain `CHOOSE_OMEN`) and hides it after submit.

- [ ] **Step 6: Manual verify** a full omen draw during combat: overlay dims but board stays visible;
  pick a card (docks centered, duration box gone); zones pulse with no text; pick a side; the three cards
  resolve in place without shifting; overlay fades; the badge shows the leftover number and a status chip
  appears on the affected side.

- [ ] **Step 7: Commit.**
```bash
git add src/presentation/view_models/omen_overlay_view_model.gd tests/test_omen_overlay_view_model.gd \
        src/presentation/screens/omen_overlay.tscn src/presentation/screens/omen_overlay.gd \
        src/presentation/screens/combat.gd
git commit -m "feat(mvp2): omen overlay — two-step draw, in-place resolution (ui-omen-screen)"
```

---

### Task PU3.5 — Combat event feedback (`SignalBus` → visuals) (manual-verified)

**Files:** Extend `combat.gd`.

`LLD-PLATFORM-004` requires every meaningful event to have a visual representation (audio is
supplementary). Connect the combat screen to `SignalBus` and react visually — **and re-render the
view-model** so HP bars, status rows, and intents stay live.

- [ ] **Step 1: Connect signals** in `bind()` (disconnect in `_exit_tree`): `damage_dealt` → floating
  damage number in the damage type's tint over the target; `status_applied`/`status_cleared` → refresh
  that unit's `status_row` + a brief flash; `unit_died` → death fade; `item_broken`/`item_discarded` →
  a break/discard cue on the inventory affordance; `turn_started` → reset the action bar to its default
  state; `omen_drawn` → show the omen overlay; `combat_started` → full re-render. Each handler re-derives
  a fresh `CombatViewModel` from `run.game_state` and re-renders the affected stacks.

- [ ] **Step 2: Manual verify** a whole encounter: hitting an enemy shows a tinted damage number and its
  HP bar drops; applying Burning adds the icon to the status row; a death fades the unit; the omen draw
  auto-opens; nothing important is conveyed by sound alone (mute and confirm full legibility,
  `LLD-PLATFORM-004`).

- [ ] **Step 3: Commit.**
```bash
git add src/presentation/screens/combat.gd
git commit -m "feat(mvp2): combat visual-first event feedback via SignalBus (LLD-PLATFORM-004)"
```

---

# Phase PU4 — Inventory view + integration

### Task PU4.1 — Inventory display (manual-verified)

**Files:** Create `src/presentation/components/inventory_strip.tscn` + `.gd`; embed in `combat.tscn` and
`room_select.tscn` (or a shared HUD).

`P-UI.3` calls for the inventory to show charges and per-encounter-countdown counters. MVP1 has no
floor-bound items (that flag is deferred), so this task shows: each of the 3 slots (null = empty), the
item's category icon (`ArtPaths.item_icon`), and its `ChargeDots` (`remaining`/`max` from content). No
new engine work.

- [ ] **Step 1: Build the strip** — 3 slots, each `item_icon` + `ChargeDots`; empty slots render a faint
  placeholder. Reuse `ChargeDots.marks`.
- [ ] **Step 2: Manual verify** the inventory reflects the Pilgrim's starting items and updates when a
  weapon's charges deplete or an item breaks (watch across a combat).
- [ ] **Step 3: Commit.**
```bash
git add src/presentation/components/inventory_strip.tscn src/presentation/components/inventory_strip.gd \
        src/presentation/screens/combat.tscn src/presentation/screens/room_select.tscn
git commit -m "feat(mvp2): inventory strip — slots, category icons, charge dots"
```

---

### Task PU4.2 — Full playthrough verification (manual, gated)

**Files:** none (verification task).

- [ ] **Step 1: Confirm the headless determinism gate is still green** (no presentation change may have
  leaked into the domain/application path):
Run the full suite (`-a res://tests`). Expected: exit 0, all suites green including
`test_headless_determinism.gd`.

- [ ] **Step 2: Play a full Pilgrim Floor-3 run through the UI**, seed 1. Verify on **both** targets:
  (a) in-editor / desktop run (`…win64_console.exe --path .`) for fast iteration with
  `emulate_touch_from_mouse`, and (b) the **Web export in a mobile-sized browser viewport** (the primary
  target) — export the Web build, serve it (`godot --headless --export-release "Web" …` then any static
  server), open it, and use browser dev-tools device emulation at 390×844 with touch. Walk the whole MVP1
  path: choose doors → fight combats (open buckets, use Default Strike + items, target enemies, resolve
  omen draws, end turns) → take loot → reach and defeat the Judge → run ends. There is no
  `NON_COMBAT_EVENT` room on this path in MVP1 (MF/WS/Rest are Plan 2), so every room the run produces has
  a screen. Confirm touch taps (not just mouse) drive every interaction.

- [ ] **Step 2b: Verify web save/reload persistence.** In the Web build, trigger a background save (choose
  a door) and a checkpoint save (defeat a floor boss), then **reload the browser tab** and confirm the
  save file is still present via `PersistenceService.read_save` (Godot's IndexedDB `user://` sync is async
  — see decision 4). If the reload shows no save, add an explicit flush **inside `PersistenceService`**
  only (branch on `OS.has_feature("web")`); no engine change. Native/desktop `user://` needs no such step.

- [ ] **Step 3: Record the result** against `SCOPE-002`'s "no missing interactions" bar **for the
  combat/nav/loot path** in a short `docs/ui/mvp2-plan1-playthrough.md`: what worked, any interaction gap,
  and the explicit carry-forward that MF/WS/Rest screens + `TradeGenerator` are Plan 2. **Do not** claim
  full `SCOPE-002` completion — Plan 1 satisfies the combat/nav/loot slice; Plan 2 closes the rest.

- [ ] **Step 4: Commit.**
```bash
git add docs/ui/mvp2-plan1-playthrough.md
git commit -m "docs(mvp2): Plan 1 playthrough verification — combat/nav/loot path complete"
```

---

## Definition of done (Plan 1)

A human plays a full Pilgrim Floor-3 run through the portrait UI **in a mobile-sized browser (Web
export)** — and, for dev iteration, on desktop with touch emulation — exercising navigation
(room-select), combat (formations, action bar, selection sheet, target selection, omen overlay, live
event feedback), and loot, all via touch: the same path `AIPlayerAgent` drives headlessly today. The
headless determinism gate stays green. All view-model logic is TDD-covered; view scenes are manually
verified.

**Carry-forward to Plan 2 (non-combat events):** Memory Fragment (Cat A / Companion / Cat C), Wandering
Soul, Elite Gate, and Rest screens, plus their engine layer — `TradeGenerator` (`LLD-ARCH-021`),
`ACCEPT_TRADE`/`DECLINE_TRADE`/`ACCEPT_OPTION_*` actions, `NON_COMBAT_EVENT` orchestration, MF/WS/Rest
floor generation, and the open values (HP-for-item buckets `HLD-ITEMS-011`, Rest heal `HLD-RUN-006`).
**Web persistence:** no backend rewrite is needed (`PersistenceService` already isolates storage per
`LLD-ARCH-007`, and Godot's Web export persists `user://` to IndexedDB — see decision 4); PU4.2's
save/reload verification is the only outstanding check, and any fix it surfaces stays inside
`PersistenceService`.

**Spec debt:** none outstanding for this plan. The mobile/web pivot's spec reconciliation
(`LLD-PLATFORM-001`, `LLD-PLATFORM-005`, `SCOPE-002`) was applied via OpenSpec change
`pivot-platform-mobile-web-first` (2026-07-10) — see PU0.1. The one remaining flag is content, not spec
debt: dropping the real per-enemy door-symbol assets from the art session into `ArtPaths.DOOR_SYMBOLS`
(`UI-ROOM-002`, still `[OPEN·MVP2]` in the specs pending that art pass).

---

## Self-review (done during authoring)

- **Spec coverage:** every `UI-*` requirement across the six presentation specs maps to a task —
  global-conventions → PU0.2/PU0.3; combat-screen `-001..-011` → PU3.1–PU3.5; loot-screen → PU2;
  room-select → PU1; omen-screen → PU3.4; art-assets → PU0.1 (import)/PU0.2 (paths); platform-constraints
  `-001..-004` → PU0.1/PU0.4/PU3.5. Rest/MF/WS specs are intentionally Plan 2 (their engine is deferred).
- **Type consistency:** action selector keys (`room_id`, `item_id`, `slot_index`, `ability_id`,
  `target_id`, `card_index`, `side`, `send_to_bottom`) match the verified resolver/injector shapes;
  view-models return dictionaries the paired views submit verbatim; `bind(run, content)` is the uniform
  screen entry point; `ChargeDots.marks`/`StatusRow.layout` signatures are used consistently.
- **Placeholder scan:** the only deliberate placeholders are the door-symbol art (owner-resolved art
  session, flagged) and the two thin component `render()` bodies (manual-verified per the TDD-logic /
  thin-view decision) — both explicitly called out, not silent TODOs.
