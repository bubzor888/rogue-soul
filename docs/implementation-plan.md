# Soul Protocol — Implementation Plan

> **Status:** Living document. MVP1 is detailed to session-sized tasks; MVP2–MVP4 are
> outlined and will be detailed in future planning passes once the engine has settled.
>
> **How to use this document (for implementing agents):**
> - Work top-to-bottom within a phase. Phases are ordered by dependency.
> - Each task lists the **`@Spec` requirement IDs** it fulfils. Tag every class and method
>   you write with those IDs per `CLAUDE.md` (`# @Spec: <ID>, <ID>`). Cite the method-level
>   requirement on the method, not just the class-level one.
> - **TDD is bundled into each task.** For the five mandated core systems (RNG, CombatResolver,
>   EventLog, GameState serialiser, ActionInjector — see `LLD-ARCH-015`), write the GdUnit4
>   tests first, then the implementation. Tests ship in the same task, not a later pass.
> - Respect the four-layer dependency rule (`LLD-ARCH-001`) on every file you place.
> - If you implement behaviour with no spec, tag `@Spec: [PENDING]` and flag it — write the
>   spec before shipping.
> - Check the box, note the commit, move on.

---

## Architectural Ground Rules (read once, apply always)

These come straight from `lld-technical-architecture` and `lld-platform-constraints`. They
constrain *every* task below.

1. **Four-layer dependency rule** (`LLD-ARCH-001`). Inner layers never import outer ones.
   ```
   Presentation → Application → Domain → Infrastructure
   ```
   | Layer | Location | May depend on |
   |---|---|---|
   | Infrastructure | `src/infrastructure/` + Autoloads | nothing |
   | Domain | `src/domain/` | Infrastructure only; `RefCounted`/`Resource` only, no Node/scene tree |
   | Application | `src/application/` | Domain + Infrastructure; no scene tree |
   | Presentation | `src/presentation/` (scenes) | all layers |

2. **Headless purity** (`LLD-ARCH-002`). Domain/Application never reference `GameConfig.HEADLESS`.
   Only Presentation nodes check it and `queue_free()` themselves when headless.

3. **All randomness via `RNGService` named streams** (`LLD-ARCH-008`). `randf()`/`randi()` are
   never called directly. AI decisions use a *separate* local RNG (`LLD-ARCH-020`).

4. **All file I/O via `PersistenceService`** (`LLD-ARCH-007`). Never `FileAccess` directly.

5. **GameState is JSON-serialisable and clone-able** (`LLD-ARCH-004`, `-017`). No Node, Callable,
   or Object references in any domain Resource field.

6. **Decisions are serialisable Dictionary commands through `ActionInjector`** (`LLD-ARCH-003`).
   Illegal actions log an error and return state unchanged — never throw.

7. **Content is data, not code** (`LLD-ARCH-005`, `-006`, `-018`). No `if vessel_id == "pilgrim"`
   in the engine. New vessels/items/enemies/omens are `.tres` files discovered by registries.

8. **Single debug flag** (`LLD-ARCH-014`): `GameConfig.DEBUG`. No separate debug build.

9. **Testing**: GdUnit4 **v6.1.x** (matches Godot 4.6.x) — `LLD-ARCH-015`. Tests live in `tests/`.

10. **ARCH cites structure; HLD cites rules — cite both.** `LLD-ARCH-*` requirements describe *how*
    the system is built (layers, serialisation, resolver interface). `HLD-*` requirements describe
    *what the behaviour is* (Cleanse categories, durability decrement, damage multipliers). A method
    enacting a rule tags **both** — e.g. `# @Spec: LLD-ARCH-019, HLD-COMBAT-007, HLD-COMBAT-018`.
    Never let an ARCH citation stand in for the HLD rule it happens to describe. The HLD Coverage
    Matrix at the end of this document is the authoritative check that no HLD requirement is dropped.

### Target directory layout

```
src/
  infrastructure/      # GameConfig, RNGService, EventLog, PersistenceService, SignalBus, constants
  domain/              # GameState + sub-Resources, data schemas, CombatResolver, registries' data
  application/         # RunController, ActionInjector, AIPlayerAgent, generators, registries, managers
  presentation/        # (MVP2+) scenes & UI
data/
  vessels/  abilities/  items/  enemies/  omen_cards/  companions/  floors/
tests/                 # GdUnit4 suites: test_rng.gd, test_combat_resolver.gd, ...
```

> **Registries are a single `ContentRegistry` autoload.** Content catalogues are immutable,
> process-wide, read-only lookups that are identical for every run — the opposite of RunController,
> which is run-scoped because it holds mutable run state (`LLD-ARCH-016`). Rebuilding registries per
> run would re-scan disk for no benefit and would delay the `LLD-ARCH-005` "fatal startup error"
> validation past engine boot. Therefore: one `ContentRegistry` Infrastructure-ish autoload (decision:
> registered as the **8th autoload**, extending the 7 in `LLD-ARCH-007`) owns the five sub-registries
> (Ability, Vessel, Item, Enemy, OmenCard/Companion). It scans `data/` and validates all handler ids
> once at boot. Domain/Application code **reads** it for lookups but never owns or rebuilds it. The
> Resources it returns are pure domain types. (Rationale recorded so it isn't re-litigated.)

---

# MVP1 — Headless Single-Floor Pilgrim Run (`SCOPE-001`)

**Definition of done:** `AIPlayerAgent.run_to_completion(seed, "pilgrim")` executes a full Floor 3
run headlessly from start to the Judge, fully deterministic for a given seed, with all combat,
omen, status, loot, navigation, and burden systems functional. No UI. (`SCOPE-001`, `LLD-ARCH-020`.)

**MVP1 scoping notes (resolved from specs, do not re-litigate):**
- Non-combat *event* encounters — Memory Fragment, Wandering Soul, Elite Gate trade UI — are
  **MVP2** (`SCOPE-002`). MVP1 Floor 3 generation produces **combat, elite combat, the Worn Map
  forced companion beat, and the Judge** only. MF/WS segment caps are effectively 0 for MVP1.
- `TradeGenerator` (`LLD-ARCH-021`) and the `ACCEPT_TRADE`/`DECLINE_TRADE`/`ACCEPT_OPTION_*`
  actions are **MVP2**. MVP1 implements only `USE_ABILITY`, `USE_ITEM`, `END_TURN`, `CHOOSE_DOOR`,
  `REPENT_DISCARD`, `READ_THE_ROAD_COMMIT`, `CHOOSE_LOOT`, `DECLINE_LOOT`.
- Vessel abilities flagged `[OPEN·MVP3]` (Charge, Hardy, Last Stand) are **not** MVP1.
- HP-bucket trade values are `[OPEN·MVP2]`; not needed for MVP1.

---

## Phase 0 — Scaffolding & Conventions

### T0.1 — Repository structure & layer skeleton  ✅ **Done**
Create the `src/{infrastructure,domain,application,presentation}` and `data/*` and `tests/`
directory tree above. Add a short `src/README.md` restating the four-layer rule and `@Spec`
convention so it's discoverable in-tree.
- **@Spec:** `LLD-ARCH-001`
- **DoD:** directories exist; no logic yet; committed.
- ✅ Layer tree (`src/{infrastructure,domain,application,presentation}`), `data/*` (vessels,
  abilities, items, enemies, omen_cards, companions, floors), and `tests/` created (each with a
  `.gitkeep`); `src/README.md` restates the four-layer rule and `@Spec` convention.

### T0.2 — Install & wire GdUnit4 v6.1.x  ✅ **Done**
Install GdUnit4 v6.1.x as a Godot plugin (Asset Store / addon), enable it, and confirm a trivial
headless test runs from the command line producing JUnit XML. Document the exact headless test
command in `tests/README.md`.
- **@Spec:** `LLD-ARCH-015`
- **DoD:** `runtest` headless command green on an empty sample test; command documented.
- **Note:** plugin install is a manual editor step — flag to the human if it can't be scripted.
- ✅ GdUnit4 **v6.1.3** (latest 6.1.x, matches Godot 4.6.x) installed at `addons/gdUnit4/` and
  enabled in `project.godot` `[editor_plugins]`. Godot binary:
  `C:\Program Files\GoDot\Godot_v4.6.3-stable_win64.exe`. Global class cache built via
  `--headless --import`. `tests/test_sample.gd` runs green headlessly (exit 0, JUnit XML at
  `reports/report_<n>/results.xml`, git-ignored). Canonical headless command documented in
  `tests/README.md`. No manual editor step was needed — fully scripted.

### T0.3 — `GameConfig` autoload  ✅ **Done**
Infrastructure autoload holding `HEADLESS`, `DEBUG`, `SAVE_VERSION`, and global constants. No logic.
- **@Spec:** `LLD-ARCH-007`, `LLD-ARCH-002`, `LLD-ARCH-010`, `LLD-ARCH-014`
- **DoD:** autoload registered; flags readable; defaults set (`HEADLESS=true` for MVP1 dev runs).
- ✅ `src/infrastructure/game_config.gd` (`extends Node`, no `class_name` to avoid colliding with the
  autoload global), registered in `project.godot` `[autoload]` as `GameConfig`. `HEADLESS=true`,
  `DEBUG=false`, `SAVE_VERSION=1`. Flags are `const` (no logic; `DEBUG` is the single boolean constant
  per `LLD-ARCH-014`). Verified by `tests/test_game_config.gd` (4 cases, green). `SAVE_VERSION` initialized
  to `1` — no value was specified in the spec.

---

## Phase 1 — Infrastructure Autoloads

### T1.1 — `RNGService` (TDD)  ⭐ mandated test system  ✅ **Done**
Named-stream RNG: `NAVIGATION`, `COMBAT`, `LOOT`, `EVENTS`. Each stream is a `RandomNumberGenerator`
seeded `base_seed + stream_index`. Public `roll(stream)` / helpers; seed injection at run start.
Write `tests/test_rng.gd` first: determinism from seed, stream independence (no cross-contamination),
pre-computed expected sequence.
- **@Spec:** `LLD-ARCH-008`, `LLD-ARCH-015`
- **DoD:** all RNG tests green; no direct `randf()` anywhere.
- ✅ `src/infrastructure/rng_service.gd` (autoload `RNGService`, no `class_name`): `Stream` enum
  (NAVIGATION/COMBAT/LOOT/EVENTS = indices 0–3), `seed_run(base_seed)`, `roll`/`roll_range`/
  `randi_range`, plus `get_call_count` for the LLD-ARCH-014 debug monitor. `tests/test_rng.gd`
  written first — 7 cases, all green: same-seed determinism, derived-seed formula (each stream matches
  a reference `RandomNumberGenerator` seeded `base+index` — the "pre-computed expected sequence"),
  no cross-stream contamination, different-seed divergence, `[0,1)` bound, deterministic bounded
  `randi_range`, re-seed reset. No direct `randf()`/`randi()` outside RNGService (verified by grep).

### T1.2 — `SignalBus` autoload  ✅ **Done**
Infrastructure global signal bus declaring the full MVP1 signal catalogue from `LLD-ARCH-009`
(`phase_changed`, `save_requested`, `combat_started/ended`, `turn_started`, `action_resolved`,
`damage_dealt`, `status_applied/cleared`, `unit_died`, `omen_drawn/applied`, `item_broken/
discarded/acquired`, `room_entered`, `floor_transitioned`). Signals only — no logic.
- **@Spec:** `LLD-ARCH-009`, `LLD-ARCH-007`
- **DoD:** all listed signals declared with correct payload types.
- ✅ `src/infrastructure/signal_bus.gd` (autoload `SignalBus`, no `class_name`): all 17 signals
  declared. **Layer note:** Infrastructure may depend on nothing (`LLD-ARCH-001`), so domain-typed
  payloads are declared with built-in base types to avoid importing Domain — enum payloads
  (`RunPhase`/`SaveType` for `phase_changed`/`save_requested`) typed `int`; `combat_state` typed
  `Resource` (CombatState's base). The emitting domain code passes the concrete types. `tests/
  test_signal_bus.gd` pins every signal's name + arity and guards against undeclared drift (2 cases,
  green).

### T1.3 — `EventLog` autoload (TDD)  ⭐ mandated test system  ✅ **Done**
Structured newline-delimited JSON recorder. Connects to `SignalBus` signals (domain never calls
EventLog directly). In-memory buffer; flush at floor transition / boss completion / run end.
Categories per `LLD-ARCH-013`. RNG-roll events only when `GameConfig.DEBUG`. Writes via
`PersistenceService` to `user://logs/run_<seed>_<timestamp>.jsonl`. Records `run_started`/`run_end`
meta events with seed. Write `tests/test_event_log.gd` first.
- **@Spec:** `LLD-ARCH-013`, `LLD-ARCH-008` (seed recording), `LLD-ARCH-015`
- **DoD:** event format valid/parseable; buffer flush at checkpoints; debug-gated RNG logging; tests green.
- **Dependency:** needs T1.4 (PersistenceService) for actual file writes — can stub then wire.
- ✅ `src/infrastructure/event_log.gd` (autoload `EventLog`, listed after GameConfig/SignalBus/
  PersistenceService since it depends on all three). `record()` emits `{tick, category, event, data}`;
  `connect_to_bus()` wires all 15 recordable SignalBus signals → navigation/combat/items categories
  (domain never calls EventLog directly); in-memory buffer; `flush()` appends newline-delimited JSON
  via PersistenceService and clears; `floor_transitioned` auto-flushes; `start_run`/`end_run` record
  `meta` events with seed (end flushes). RNG rolls gated via `debug_rng_logging` (defaults from
  `GameConfig.DEBUG`). **Decision:** `tick` is a monotonic per-event counter for MVP1 (no game-clock
  source yet). T1.4 done first, so PersistenceService is wired real (not stubbed). `tests/
  test_event_log.gd` written first — 11 cases green (format, tick increment, parseable jsonl flush,
  append-across-flushes, empty no-op, RNG gating both branches, run_started/run_end meta, SignalBus
  wiring, floor-transition flush). No direct `FileAccess` (only PersistenceService).

### T1.4 — `PersistenceService` autoload  ✅ **Done**
Sole `FileAccess` abstraction. JSON read/write, `user://logs/` and save paths, `SAVE_VERSION`
stamping, and a migration hook (`LLD-ARCH-010`). Migration table can start empty.
- **@Spec:** `LLD-ARCH-007`, `LLD-ARCH-010`
- **DoD:** read/write round-trips; version stamped; migration entry-point present.
- ✅ `src/infrastructure/persistence_service.gd` (autoload `PersistenceService`, no `class_name`):
  `read_json`/`write_json`, `write_text`/`append_text` (for EventLog `.jsonl`), versioned
  `write_save` (stamps `GameConfig.SAVE_VERSION`) / `read_save` (runs migrations on older versions),
  `register_migration` hook (table starts empty), `log_file_path(seed, ts)` per `LLD-ARCH-013`, and
  auto parent-dir creation. Sole `FileAccess`/`DirAccess` user — verified by grep (no other `src/`
  file touches them). `tests/test_persistence_service.gd` — 9 cases green (round-trip, JSON
  int→float contract, missing-file→null, version stamping, no-mutation, current-version read,
  migration upgrade, append accumulation, log-path format).

---

## Phase 2 — Domain Data Model

### T2.1 — Data resource schemas (`LLD-ARCH-018`)  ✅ **Done**
Define `Resource` subclasses with `@Spec` annotations for every content schema: `AbilityData`
(shared by items), `HandlerConfig`, `VesselData`, `EnemyData`, `IntentWeight`, `IntentConditional`,
`OmenCardData`, `CompanionData`. Every field JSON-serialisable. Include the colon-encoding
convention note for parameterized statuses in `AbilityData`/`OmenCardData` doc comments.
- **@Spec:** `LLD-ARCH-018`, `LLD-ARCH-006`
- **DoD:** all schema classes compile; fields match the spec tables exactly.
- ✅ All 8 schemas in `src/domain/` (each `class_name … extends Resource`, `@Spec`-annotated, all
  fields `@export`): `handler_config`, `ability_data`, `vessel_data`, `enemy_data`, `intent_weight`,
  `intent_conditional`, `omen_card_data`, `companion_data`. Fields match the `LLD-ARCH-018` tables
  exactly, including non-zero defaults (`IntentWeight.hit_count=1`, `status_target="player"`).
  Colon-encoding convention documented in `AbilityData`/`OmenCardData`/`IntentWeight` headers.
  `tests/test_data_schemas.gd` — 10 cases green (defaults, nested typed arrays, is-Resource). Domain
  purity verified by grep: no `Node`/`HEADLESS`/`FileAccess`/`SignalBus` references in `src/domain/`.

### T2.2 — `GameState` + sub-Resources with serialisation (TDD)  ⭐ mandated test system  ✅ **Done**
Implement `GameState` and all sub-Resources from `LLD-ARCH-017`: `VesselState`, `ItemInstance`,
`AbilityState`, `StatusInstance`, `CompanionState`, `NavigationState`, `DoorData`, `CombatState`,
`EnemyState`, `OmenDeckState`, `OmenCycleState`. Implement `clone()`, `to_json()`, `from_json()`.
Define the `RunPhase` enum. Write `tests/test_game_state.gd` first: round-trip serialisation
identity; clone independence; field-level defaults (e.g. `is_evading` resets, `string_param` "").
- **@Spec:** `LLD-ARCH-017`, `LLD-ARCH-004`, `LLD-ARCH-015`
- **DoD:** round-trip and clone tests green; all fields present with correct types/defaults.
- ✅ `GameState` + all 11 sub-Resources in `src/domain/` (each `class_name … extends Resource`,
  fields match `LLD-ARCH-017` exactly). `RunPhase` enum on `GameState`
  (NAVIGATION..RUN_END). `to_json`/`from_json` on every type; **`clone()` = `from_json(to_json())`**
  (single serialisation path, guaranteed deep independence). `from_json` defensively `int()`-casts so
  both the in-memory Dictionary path and the JSON-**text** path (PersistenceService save files) are
  correct — the int→float issue flagged in T1.4. Shared static helper `src/domain/serde.gd` (`Serde`)
  keeps (de)serialisation terse. **Decision:** `OmenCycleState.timer_index` defaults `-1` (= not yet
  assigned — it's the leftover index, derivable only after the player/random indices are set, so read it
  only when `sides_assigned`; `LLD-ARCH-017` updated directly to record this). `tests/test_game_state.gd` written
  first — 8 cases green: in-memory round-trip identity, field fidelity, JSON-text int casting, null
  inventory slots preserved, clone independence (deep mutation isolation), null sub-resources, defaults,
  RunPhase enum. Domain purity verified by grep.

---

## Phase 3 — Registries, Charge Management & Constants

### T3.1 — `ReplenishEvents` constants + `ChargeManager` (decrement asymmetry)  ✅ **Done**
String constants for `encounter_start/end`, `floor_start/end` (`LLD-ARCH-016`). `ChargeManager`
restores charges for abilities/items whose `replenish_triggers` contain a fired event; items with
`breaks_at_zero` are flagged for removal at 0 (removal itself happens in ActionInjector). Implement
the **decrement asymmetry** (`HLD-ITEMS-005`): Attack-durability items lose 1 charge **per use**
(handled at action resolution in T6.1); Support-durability items lose 1 charge **per encounter**
(once on room entry regardless of activation — Worn Map relies on this). Category/bucket mapping per
`HLD-ITEMS-004`.
- **@Spec:** `LLD-ARCH-011`, `LLD-ARCH-016`, `HLD-ITEMS-004`, `HLD-ITEMS-005`
- **DoD:** replenishment fires correctly; break-at-zero flagging works; support items decrement once
  per encounter, attack items decrement per use (verified with Worn Map and Walking Staff).
- ✅ `src/infrastructure/replenish_events.gd` (`ReplenishEvents`: 4 const event IDs). `src/application/
  charge_manager.gd` (`ChargeManager`, RefCounted): `fire_replenish_event` (restores abilities/items —
  incl. companion abilities — whose `replenish_triggers` match, to `max_charges`); `decrement_support_items`
  (per-encounter −1 for `action_bucket=="support"`, returns broken slots); `decrement_on_use` (per-use −1
  for attack/consumable, returns broke); `get_broken_slots` (flags 0-charge `breaks_at_zero` items for
  ActionInjector to remove). **Decision:** the AbilityData lookup is injected as a `Callable` (not a direct
  ContentRegistry dep, since T3.2 isn't built) — RunController/ContentRegistry supplies it later; tests
  stub it. Bucket constants per `HLD-ITEMS-004`. `tests/test_charge_manager.gd` — 12 cases green
  (replenish match/non-match/items, Worn Map per-encounter, Walking Staff per-use + untouched-by-encounter,
  zero clamp, break flagging, non-breaking-at-zero, constants). Application purity verified by grep.

### T3.2 — `ContentRegistry` autoload (single registry, directory scan + startup validation)  ✅ **Done**
One `ContentRegistry` autoload (the **8th autoload**, see registries note above) owning sub-registries
`AbilityRegistry`, `VesselRegistry`, `ItemRegistry`, `EnemyRegistry`, `OmenCardRegistry`,
`CompanionRegistry` (as needed for MVP1). At engine boot it scans each `data/` subdir, indexes by id,
and a validator verifies every `handler_id` in every chain resolves — unknown ids are a **fatal
startup error**. RunController/CombatResolver read `ContentRegistry` for lookups; they never own or
rebuild it.
- **@Spec:** `LLD-ARCH-006`, `LLD-ARCH-005`, `LLD-ARCH-007` (autoload list extension)
- **DoD:** placing a `.tres` makes content discoverable with no code change; unknown handler id aborts startup at boot.
- ✅ `src/application/content_registry.gd` (autoload `ContentRegistry`, 8th; no `class_name`). `_ready`
  → `load_all()` scans the six `data/` dirs, indexes by id (abilities **and** items share one
  `ability_id` index — items are AbilityData), records duplicate/empty-id/load-fail into `load_errors`,
  and `_abort()`s (push_error + `get_tree().quit(1)`) on any. Typed getters `get_ability`/`get_vessel`/
  `get_enemy`/`get_omen_card`/`get_companion` + `has_ability`. Handler validation: `collect_handler_ids`
  (across abilities/omen cards/enemy intents/companions), `find_unresolved_handlers(known)`,
  `validate_handlers(known)` → fatal on unknown. **Decisions:** (1) sub-registries are internal
  per-type dictionaries, not separate classes (MVP1 simplification); (2) layer = **Application** (returns
  Domain Resources; Domain code never reads it — per `LLD-ARCH-019` content is injected into
  CombatResolver, matching ChargeManager's Callable lookup); (3) **boot-time handler validation against
  the real handler set is wired in T4.1** (handler registry doesn't exist yet) — detection + abort path
  implemented and tested now. Dir listing added to `PersistenceService.list_files` (keeps `DirAccess`
  centralized); `.tres` via `ResourceLoader` (CACHE_MODE_REPLACE). `tests/test_content_registry.gd` —
  6 cases green (discovery by id, non-tres ignored, duplicate-id error, missing→null, handler collection,
  unresolved detection). Boots cleanly against empty `data/` dirs (no abort).

---

## Phase 4 — Ability Pipeline & Handlers

### T4.1 — `AbilityPipeline` + `AbilityHandler` base + handler registry  ✅ **Done**
Chain-of-Responsibility executor: an ability/item is an ordered `Array[HandlerConfig]`; handlers
run left-to-right over a shared context (`game_state`, source, target, params). Base class +
registry keyed by `handler_id`. Enforce naming convention (`DealDamageHandler` → `"deal_damage"`).
- **@Spec:** `LLD-ARCH-005`, `LLD-ARCH-012`
- **DoD:** a 2-handler test chain executes in order; registry resolves ids.
- ✅ Three Domain classes in `src/domain/`: `AbilityContext` (shared mutable ctx: `game_state`,
  `source_id`, `target_id`, `params`, `results`), `AbilityHandler` (base; `apply(ctx)` to override;
  **`get_handler_id()` derives the id from the class global name** — strip `Handler`, PascalCase→
  snake_case — so `LLD-ARCH-012` can't be violated), `AbilityPipeline` (`register`/`has_handler`/
  `known_handler_ids`/`execute` left-to-right; `with_default_handlers`/`default_handler_ids` static
  factory — empty until T4.2). **Closed the T3.2 seam:** `ContentRegistry._ready` now calls
  `validate_handlers(AbilityPipeline.default_handler_ids())` — unknown content handler ids abort boot.
  `tests/test_ability_pipeline.gd` — 6 cases green (order, per-config params, registry membership,
  context carries state, `derive_handler_id` cases, default set empty). Domain purity verified
  (ContentRegistry mentions are comments only).

### T4.2 — Concrete handlers for MVP1  🟡 **Partial — self-contained handlers done; damage/content-coupled sequenced to T5.2**
Implement the handlers MVP1 content needs (each `@Spec`-tagged to the requirement that drives it):
- `deal_damage` — flat player damage + type; **multi-target/arc modes** for items that hit all
  enemies (Rope Flail) or arc to a second target (Arc Wand) (`HLD-COMBAT-005`, `-016`; Throw Rock
  `LLD-ABILITIES-004`; `LLD-ITEMS-005`/`-006`).
- `apply_status` — create/refresh StatusInstance with colon-encoding split & magnitude rules
  (`HLD-COMBAT-006`, `-015`, `-018`, `-019`; `LLD-ARCH-018`).
- `cleanse_status` — category-scoped status removal (no universal cleanse): Small/Medium Amethyst
  clear Shocked/Chilled/Vulnerable(Physical); Ointment clears Burning/Poisoned. **MVP1 — these items
  are in the Floor-3 pools.** (`HLD-COMBAT-010`, `LLD-ITEMS-001`, `LLD-ITEMS-005`/`-007`).
- `peek_omen_deck` — sets `read_the_road_active` (Read the Road, `LLD-ABILITIES-005`).
- `restore_item_charges` — Good as New (`LLD-ABILITIES-003`).
- `apply_mending_by_burden_tier` — Witness intents read `item_burden_score` (`LLD-ARCH-018/-019`,
  `LLD-ENEMIES-021/-022`, `HLD-RUN-007`).
- Any handler required by Floor-3 omen cards with non-status effects (Elemental Synergy, Sacred
  Ground — `LLD-OMEN-CARD-013/-014`). Note Combustible Oil's branch (Vulnerable, or burst if already
  Burning) is a conditional `deal_damage`/`apply_status` chain (`LLD-ITEMS-007`).
- **@Spec:** as listed per handler.
- **DoD:** each handler unit-tested for its core effect; cleanse is category-scoped (never universal);
  multi-target/arc verified; all handlers referenced by MVP1 content resolve at startup.
- 🟡 **Done now** (self-contained; in `src/domain/handlers/`, each `class_name …Handler extends AbilityHandler`,
  registered in `AbilityPipeline.with_default_handlers()`):
  - `apply_status` (`ApplyStatusHandler`) — colon split + stacking via shared `src/domain/status_rules.gd`
    (`StatusRules`: additive [burning/poisoned/bleed], max-wins [hardened/emboldened/mending], idempotent
    [chilled], type_convert replacement, shift-trigger default).
  - `cleanse_status` (`CleanseStatusHandler`) — category-scoped, data-driven `clears` matcher list
    (matches `string_param` so Vulnerable(Physical) clears without touching Vulnerable(Fire)); never universal.
  - `peek_omen_deck` (`PeekOmenDeckHandler`) — sets `read_the_road_active`.
  - `apply_mending_by_burden_tier` (`ApplyMendingByBurdenTierHandler`) — reads `item_burden_score`, picks
    magnitude from data-driven `tiers`, applies Mending (max-wins prevents mid-cycle downgrade).
  - `tests/test_handlers.gd` — 14 cases green. Full suite 90/90.
- ⏳ **Sequenced (flagged), each blocked by later work whose core logic it *is*:**
  - ✅ `deal_damage` → **done in T5.2** (the 7-step `DamageCalculator` + multi-target/arc handler).
  - ✅ `restore_item_charges` (Good as New, `LLD-ABILITIES-003`) → **done in T8.1** (`RestoreItemChargesHandler`,
    `max_charges` looked up via `ctx.content`).
  - Omen-card non-status handlers (Elemental Synergy/Sacred Ground `LLD-OMEN-CARD-013/-014`, Combustible Oil
    branch `LLD-ITEMS-007`) → **T5.4** omen mechanics + Phase-8 content.
  > These are **not** registered yet, so Phase-8 content referencing them would (correctly) abort boot via
  > the T3.2/T4.1 validator until they land — a built-in reminder to complete them before T8.

> Note: `apply_buff` (Charge), `remove_status` (Hardy), passive Last-Stand modifier are `[OPEN·MVP3]`
> — defer. The damage resolver's Charge/Last-Stand multiplier *hooks* are built in T5.2 but unused in MVP1.

---

## Phase 5 — CombatResolver (the core engine) ⭐ mandated test system

`CombatResolver` is a `RefCounted` in `src/domain/`, takes `RNGService` as a constructor dependency,
never touches autoloads except emitting on `SignalBus` (`LLD-ARCH-019`). Build `tests/
test_combat_resolver.gd` incrementally alongside each sub-task. Split across sessions:

### T5.1 — Legal-action generation & gating  ✅ **Done**
`get_legal_combat_actions()` with the priority-ordered gating from `LLD-ARCH-019`:
(1) `read_the_road_active` → only `READ_THE_ROAD_COMMIT`; (2) `pending_repent_slots` → only
`REPENT_DISCARD`; (3) otherwise the action-bucket set — Default Strike always legal, Evade always
legal, ability/item actions, `is_stunned` excludes Action bucket. Always returns ≥1 action.
- **@Spec:** `LLD-ARCH-019`, `LLD-ARCH-003`, `HLD-COMBAT-004`, `HLD-COMBAT-011`, `HLD-COMBAT-017`
- **DoD:** scenarios from `LLD-ARCH-019` (gating priority, stun exclusion, zero-charge fallback) green.
- ✅ `src/domain/combat_resolver.gd` (`CombatResolver`, RefCounted) started. **Constructor injection**
  (`_init(rng, content, pipeline)`) — RNGService + a `content` provider (ContentRegistry-style
  `get_vessel`/`get_ability`) + AbilityPipeline; **no autoload access** (verified by grep), matching the
  ChargeManager pattern and `LLD-ARCH-019`. `get_legal_combat_actions` implements the 3-branch priority
  gate; standard set = Default Strike (one USE_ABILITY per living enemy) + EVADE + charged abilities/items;
  stun drops Action-bucket (Strike/Evade/attack abilities+items), keeps Support/Consumable; END_TURN
  fallback guarantees ≥1. **Decisions:** Default Strike = `USE_ABILITY` with the vessel's
  `default_strike_id` (not tracked in `ability_states`); Evade modeled as `{"type":"EVADE"}` (spec doesn't
  pin these shapes — documented; ActionInjector validates in T6.1); attack actions enumerate per living
  target, non-attack are single non-targeted. `tests/test_combat_resolver.gd` (grows across T5.x) — 10
  cases green: read-the-road gate, repent-per-slot, read-the-road > repent priority, zero-charge fallback
  (Strike+Evade), per-target strike, dead-enemy exclusion, stun keeps support / excludes attack item /
  END_TURN fallback, ≥1. Full suite 100/100.

### T5.2 — Damage resolution order  ✅ **Done**
The 7-step (0–7) pipeline from `LLD-ARCH-019`: evade miss → base+type (with Type Convert override)
→ Emboldened flat → Last Stand ×1.5 → Charge ×2 / Emboldened elemental ×1.5 → resistance ×0.5 →
vulnerability ×1.5 → resistance+vuln cancel. Player damage flat, enemy damage rolled on COMBAT.
- **@Spec:** `LLD-ARCH-019`, `HLD-COMBAT-005`, `-007`, `-016`, `-017`, `-018`, `-019`
- **DoD:** the worked scenarios (Last Stand+Charge+Vuln=31; resistance cancels vuln; type-convert
  interactions; Hardened absorption to 0) green; 0-HP clamp + `unit_died` (no negative HP).
- ✅ **Done** (also resolves the `deal_damage` handler deferred from T4.2). `src/domain/damage_calculator.gd`
  (`DamageCalculator`, static): the shared 7-step routine — evade-miss (COMBAT roll ≤34) → type +
  Type-Convert override (matched by id, string_param IS the type) → Emboldened-physical flat → Last Stand
  ×1.5 (MVP3 hook) → Charge ×2 (consumed) / Emboldened-elemental ×1.5 → resistance/vulnerability with
  cancel-to-×1.0. **Multipliers accumulate as float, floored once at end** (7×1.5×2×1.5=31.5→31); Hardened
  absorbs from the floored int; HP clamps at 0 with `died` flag (never negative). Base is an input (player
  flat / enemy pre-rolled). `src/domain/handlers/deal_damage_handler.gd` (`DealDamageHandler`,
  registered) — single/all/arc targeting, records one result per hit on `ctx.results` (resolver emits in
  T5.6). `AbilityContext` extended with injected `content`/`rng`. **Decisions:** Hardened per-hit cap now;
  per-tick budget/reset is T5.3. `STREAM_COMBAT=1` const (avoids touching the RNGService autoload global).
  `tests/test_damage.gd` — 15 cases green (all worked scenarios + resist-only/vuln-only, Emboldened
  flat/elemental, evade miss/hit via stub rng, 0-HP clamp+died, charge consumed, handler single/all,
  registration). Full suite 115/115. No autoload access.

### T5.3 — Status tick & shift resolution  ✅ **Done**
`resolve_omen_tick` (tick-trigger effects fire: Burning/Chilled/Poisoned/Mending/Hardened/Bleed;
decrement all; clear expired tick statuses) and `resolve_omen_cycle_start` shift handling
(`death_mark`→`shocked`→`exposed` order per `LLD-ARCH-023`; deferred Vulnerable application).
- **@Spec:** `LLD-ARCH-019`, `LLD-ARCH-023`, `HLD-COMBAT-006`, `-015`, `-018`, `-019`
- **DoD:** Bleed decay sequence, Poison tripling, Chilled accumulation, shift ordering scenarios green.
- ✅ **Done.** `CombatResolver.resolve_omen_tick` — per-unit (vessel + enemies): Burning (dmg=mag, flat),
  Poisoned (dmg=mag then ×3), Bleed (dmg=mag then floor(mag/2), clears at 0), Mending (heal=mag, clamp
  max_hp), Chilled (mag += step), Hardened (no-op — see below); then decrement `remaining_ticks` on ALL,
  clear expired **tick** statuses (shift statuses at 0 left for cycle start). Shift handling:
  `fire_shift_statuses` fires in `LLD-ARCH-023` order (death_mark instant-kill skips rest on that unit →
  shocked sets is_stunned → exposed returns pending-Vulnerable ids), `clear_expired_statuses` (step 2),
  `apply_deferred_vulnerable(ids, new_timer)` (step 4; timer from the draw in T5.4). Added **Chilled
  outgoing reduction** to `DamageCalculator` (flat, never reduces a non-zero hit below 1 — was missed in
  T5.2). `death_mark` added to `StatusRules.SHIFT_TRIGGER`. **Hardened finalized:** per-hit absorption cap,
  `magnitude` constant (the single `magnitude` field can't hold both a depleting per-tick budget and a
  reset value); "resets each tick" holds trivially since it never depletes → tick effect is a no-op. The
  T5.2 provisional flag is resolved. `tests/test_status_resolution.gd` — 15 cases green. Full suite 130/130.
  ⚠️ **Flag (single-field limitation):** Chilled's per-tick *step* ("amounts defined by omen card") can't be
  data-driven with only `magnitude`; using a constant `CHILLED_TICK_STEP=1` for MVP1. If per-card steps (or
  a true per-tick Hardened budget) are needed, `StatusInstance` needs an extra field (small `LLD-ARCH-017`
  spec/schema change) — worth a deliberate decision before Floor-3 Chilled/Hardened content is tuned (T8.3).

### T5.4 — Omen system: assembly, draw cycle, timers, reshuffle  ✅ **Done**
`assemble_omen_deck` (four sources, timer assignment via COMBAT per `LLD-OMEN-MECH-008/-009`, then
passive handler pass that may set `read_the_road_active`); three-card draw cycle (player-choice +
random + timer card per `HLD-OMEN-001`); deck reshuffle (`HLD-OMEN-003`); two-tier enemy
contribution & removal (`HLD-OMEN-006`); per-unit / tag-conditional application (`HLD-OMEN-005`).
- **@Spec:** `HLD-COMBAT-008`, `HLD-OMEN-001`..`-006`, `LLD-OMEN-MECH-008`, `-009`, `LLD-ARCH-019`, `LLD-ARCH-024`
- **DoD:** deck composition, timer distribution, reshuffle, tier-1/tier-2 removal scenarios green.
- 🟡 **Done so far:**
  - **Spec prerequisite** — the omen *choice* had no MVP1 action (`HLD-OMEN-001` says the player picks a
    card+side, but the action set omitted it). Resolved via OpenSpec change `add-choose-omen-action`
    (archived `2026-06-19`): new **`LLD-ARCH-024` Omen Choice Action** — `CHOOSE_OMEN
    {card_index, side}`, the gating priority (read_the_road → omen-choice → repent → standard), the
    `resolve_player_action` flow (choice → random-assign → leftover=timer → deferred Vulnerable → apply 2
    cards), the `resolve_omen_cycle_start` restructure (draw + pause), and a new `CombatState.
    pending_vulnerable_units` field to carry the Exposed deferred-Vulnerable across the choice pause.
  - **Foundation (code):** `CombatState.pending_vulnerable_units` field + serialisation (round-trip tested);
    the **omen-choice gating branch** in `get_legal_combat_actions` (6 actions = 3 cards × 2 sides;
    read_the_road priority; inactive once `sides_assigned`). `tests/test_combat_resolver.gd` +3 cases. Full
    suite 133/133.
- ✅ **Machinery (code)** — all in `CombatResolver` (Domain, no autoload access; verified by grep):
  - `assemble_omen_deck(source_card_ids, game_state)` — merges the passed-in vessel/item/floor/companion
    card ids with the **two-tier enemy contributions** (`HLD-OMEN-006`: Tier-1 family card `omen_contributions[0]`
    per instance, Tier-2 type card `omen_contributions[1]` per type), assigns timers (25/50/25 via COMBAT,
    `LLD-OMEN-MECH-008/-009`), shuffles, then runs the passive-ability handler pass (read_the_road short-circuit).
  - `resolve_omen_cycle_start` restructured per `LLD-ARCH-024` — fire shifts → clear expired → discard spent
    cycle → draw 3 (reshuffle if short, `HLD-OMEN-003`) → record `pending_vulnerable_units` → **pause** for CHOOSE_OMEN.
  - `resolve_choose_omen(action, game_state)` — sides/timer derivation, deferred Vulnerable applied with the new
    timer, per-unit/tag-conditional application of the 2 played cards (`HLD-OMEN-005`), Repent special handling
    (0→heal / 1→one slot / 2+→two via COMBAT, early-return halt), Type Convert replacement (via `StatusRules`).
  - `remove_enemy_omen_cards(unit_id, game_state)` — two-tier removal helper (`HLD-OMEN-006`) for `resolve_enemy_death`
    (T5.7) to call; family copy always, type card only on last-of-type; cards already in the cycle untouched.
  - `tests/test_omen_system.gd` — 19 cases green (two-tier composition same/distinct types, family-only, 25/50/25
    distribution, cycle draw+pause, reshuffle, CHOOSE_OMEN sides/timer/card-application, tag filter, family-to-player
    safe, deferred Vulnerable, invalid no-op, Repent 0/1/2-item, two-tier removal incl. discard-pile). Full suite **152/152**.
- **Decisions:** (1) **Source split** — vessel/item/floor/companion card ids are *injected* via `source_card_ids`
  (they need registry + FloorProfile lookups outside Domain); enemy contributions are derived inside (Domain owns
  CombatState + the two-tier rule). Mirrors the ChargeManager/ContentRegistry injection pattern. (2) `CHOOSE_OMEN`
  resolution lives in its own `resolve_choose_omen` method (not folded into `resolve_player_action`, which is T5.6 —
  T5.6's dispatcher will call it). (3) Timer split is **count-based exact** (nearest whole-number per `LLD-OMEN-MECH-008`)
  with randomised assignment via the shuffle, so distribution is invariant under the RNG.
- ⏳ **Still deferred (content-coupled, land with Phase 8):** the omen-card **non-status handlers**
  (`elemental_synergy`/`sacred_ground` `LLD-OMEN-CARD-013/-014`, Combustible Oil branch `LLD-ITEMS-007`) — the
  `_apply_omen_card` handler-chain call site is wired, but the concrete handlers are not registered yet, so the
  T3.2/T4.1 boot validator will (correctly) reject content referencing them until they land in T8. The passive-handler
  pass is implemented but exercises no MVP1 content (Pilgrim has no passive omen ability).

### T5.5 — Enemy turns & intent engine  ✅ **Done**
`resolve_enemy_turns`: per-enemy reset, Charge→Release continuation, intent_conditionals (forced
`intent_id` / restricted `intent_ids`), weighted COMBAT roll, consecutive cap re-roll, evade,
multi-hit, `status_apply` (+magnitude rules), custom `handlers`, `summon_enemy_id`. Plus
`resolve_enemy_summon` (inject family card) and `turns_alive` tracking.
- **@Spec:** `HLD-COMBAT-009`, `-014`, `-016`, `LLD-ARCH-019`, `LLD-ARCH-018`
- **DoD:** weighted/conditional/consecutive/charge-release/summon/multi-hit scenarios green.
- ✅ **Done** — all in `CombatResolver` (Domain, no autoload access; verified by grep):
  - `resolve_enemy_turns` — iterates a roster **snapshot** (so a mid-pass summon acts next round, not
    this one); per enemy: step 0 flag reset + stun-skip (a stun during charge clears `is_charging`, so the
    release **never fires** per `HLD-COMBAT-014`), step 1 unconditional Charge→Release (no roll/cap), steps
    2-3 intent selection, step 4 streak/`last_intent_id`/`current_intent` update, step 5 Evade, step 6 begin
    charge, step 7 execute. `turns_alive` increments after each enemy acts.
  - `_select_intent` — conditionals first (forced `intent_id` skips roll+cap; `intent_ids` restricts the
    pool), then weighted COMBAT roll with consecutive-cap re-roll (bounded). `_condition_met` supports
    `hp_below_percent`/`hp_percent_lte`/`ally_count_above`/`ally_count_equals`/`turn_number` (the last reads
    per-enemy `turns_alive`).
  - `_execute_intent` — `hit_count` independent COMBAT damage rolls via the shared `DamageCalculator`
    (per-hit evade miss), then `status_apply` (player/self/allies targets, magnitude rules via `StatusRules`),
    then the intent `handlers` chain (cycle `remaining_ticks` injected; `apply_mending_by_burden_tier` lands on
    an ally), then `summon_enemy_id`.
  - `resolve_enemy_summon` — fresh `EnemyState` at full HP with a unique `<id>_<n>` instance id and
    `turns_alive=1`; injects one Tier-1 family card (`omen_contributions[0]`) into the draw pile with a single
    25/50/25 timer (`HLD-OMEN-006`).
  - `tests/test_enemy_turns.gd` — 21 cases green. Full suite **173/173**.
- **Schema:** added `EnemyState.turns_alive` (default 1) — it was already mandated by `LLD-ARCH-017`'s
  IntentConditional notes + Spark scenarios but the **EnemyState field enumeration omitted it**; corrected the
  enumeration in `lld-technical-architecture` directly (a same-requirement consistency fix, not new design).
- **Decisions / flags:** (1) the charged intent on release is looked up by `last_intent_id` (preserved across
  the charge turn since no new roll happens). (2) Enemy-applied (individual) statuses use the **omen cycle
  timer** as `remaining_ticks` via `_cycle_remaining_ticks`; with no per-cycle countdown stored this is the
  cycle *length*, so a mid-cycle application lasts a full span — precise mid-cycle remaining-tick accounting is
  an orchestration concern for **T6.4** (flagged). (3) For `status_target: "allies"` handler intents the
  handler target is the caster's first living ally (covers Witness→Judge); handlers may override via params.

### T5.6 — Player action resolution  ✅ **Done**
`resolve_player_action` for standard actions (flag resets, Evade, AbilityPipeline run, evade-miss
charge preservation, burden updates) plus the two interactive resolutions `READ_THE_ROAD_COMMIT`
and `REPENT_DISCARD` (item removal, 5 HP heal, burden −1, `item_discarded` emit).
- **@Spec:** `LLD-ARCH-019`, `LLD-ARCH-003`, `HLD-COMBAT-017`, `HLD-RUN-007`, `LLD-OMEN-CARD-020`
- **DoD:** Repent (0/1/2+ items) and Read-the-Road splice scenarios green; charge preservation correct.
- ✅ **Done** — `resolve_player_action` is the dispatcher in `CombatResolver`:
  - **READ_THE_ROAD_COMMIT** — validates `read_the_road_active` + `send_to_bottom` (window `[0, min(2,size-1)]`,
    no dupes), splices chosen cards to the bottom in **descending** index order, clears the flag; does not
    advance the cycle or reset per-turn flags. Invalid → error + unchanged.
  - **REPENT_DISCARD** — validates `slot_index ∈ pending_repent_slots`; nulls the slot (keeps other indices
    stable), heals 5 (clamp), burden −1 (floor 0), emits `item_discarded`, clears pending. Invalid → unchanged.
  - **CHOOSE_OMEN** — dispatched to `resolve_choose_omen` (T5.4).
  - **Standard** — resets `is_evading`/`is_stunned`; Evade sets `is_evading` and returns; otherwise runs the
    item/ability `handlers` chain, emits `damage_dealt`/`unit_died`/`action_resolved` from the recorded results,
    and decrements the charge — **weapon preservation** (attack + `breaks_at_zero`, full miss → not consumed),
    consumables always, support per-encounter (not per-use), charged abilities decrement their `AbilityState`,
    unlimited abilities untouched.
  - `tests/test_player_action.gd` — 18 cases green. Full suite **191/191**.
- **Decisions / boundary:** (1) **SignalBus is injected** as an optional 4th constructor arg (the resolver
  emits on it per `LLD-ARCH-019` but stays decoupled/testable — matches `EventLog.connect_to_bus`; tests pass a
  fresh bus instance and record emissions). (2) **Charge decrement lives here** (the resolver knows hit/miss for
  preservation); **T6.1 ActionInjector** owns the post-decrement bookkeeping (break detection, `item_broken`
  emit, burden −1 on break, removal, acquisition) and will not re-decrement. (3) Companion `granted_ability_id`
  departure on `ability_used` is mentioned in the `LLD-ARCH-019` spec but **deferred to T5.7** (CompanionState
  handling lands there) — flagged.

### T5.7 — Enemy death, companion triggers, death intercept  ✅ **Done**
`resolve_enemy_death` (omen card removal + `on_death_apply_to_player` + `on_death_summons`),
`resolve_companion_trigger` (turn_end), `check_vessel_death_intercept` (synchronous, pre-`unit_died`).
- **@Spec:** `LLD-ARCH-019`, `HLD-OMEN-006`, `HLD-COMPANION-003`, `LLD-ARCH-018`
- **DoD:** Witness/Plague-Rat on-death status, Lightning Elemental spark summon, intercept scenarios green.
- ✅ **Done** — all in `CombatResolver`:
  - `resolve_enemy_death` — (1) two-tier omen card removal (reuses `remove_enemy_omen_cards`, T5.4; cycle cards
    untouched), (2) `on_death_apply_to_player` applied via `StatusRules` (colon split, `remaining_ticks` = cycle
    timer, additive/max-wins stacking), (3) `on_death_summons` → one `resolve_enemy_summon` per id (Lightning
    Elemental → 2 Sparks).
  - `resolve_companion_trigger` — fires every active companion (bound + temporary) whose `CompanionData.trigger`
    matches; a `timer_exhausted` companion decrements `companion_timer` per fire and departs at 0.
  - `check_vessel_death_intercept` — runs the `vessel_death_intercept` companion's chain (may restore HP) then
    departs it and returns; the caller (T6.4) reads `vessel.hp > 0` to suppress `unit_died`.
  - Picked up the T5.6 deferral: a `granted_ability_id` companion with `departure_trigger == "ability_used"`
    now departs inside `resolve_player_action` when that ability resolves.
  - `tests/test_enemy_death.gd` — 11 cases green (uses a test-only `TestHealHandler` to make companion chains
    observable). Full suite **202/202**.
- **Decision:** "depart" nulls whichever slot (`bound_companion`/`temporary_companion`) holds the companion —
  even a bound companion is consumed by a one-time `vessel_death_intercept` per `HLD-COMPANION-003`. The dead
  enemy's `EnemyState` is left in the array at hp 0 (consistent with the engine's clamp-not-remove death model;
  array removal, if any, is the orchestrator's call in T6.4).

---

## Phase 6 — Application Orchestration

### T6.1 — `ActionInjector` (TDD)  ⭐ mandated test system  ✅ **Done**
Single entry point for all decisions. `get_legal_actions()` (combat + navigation + loot phases),
`submit_action()` (validates against legal set; illegal → log + unchanged state, no throw). Handles
attack-item per-use charge decrement (`HLD-ITEMS-005`) / break + `item_broken` emit + burden −1, and
item acquisition (no inventory cap, burden +2 — `HLD-ITEMS-001`, `HLD-RUN-007`).
Write `tests/test_action_injector.gd`.
- **@Spec:** `LLD-ARCH-003`, `LLD-ARCH-011`, `LLD-ARCH-009`, `HLD-RUN-007`, `HLD-ITEMS-001`, `HLD-ITEMS-005`, `LLD-ARCH-015`
- **DoD:** legal-set correctness, illegal-action safety, item-break flow, no-cap acquisition scenarios green.
- ✅ `src/application/action_injector.gd` (`ActionInjector`, RefCounted, Application layer; no autoload/
  FileAccess/RNG access — verified by grep). Collaborators injected (CombatResolver, ChargeManager,
  `content` provider, SignalBus) per the established pattern. `get_legal_actions` dispatches by
  `run_phase`: COMBAT delegates to `CombatResolver.get_legal_combat_actions` (the gating authority,
  `LLD-ARCH-019`); NAVIGATION → one `CHOOSE_DOOR` per door; LOOT_SELECTION → one `CHOOSE_LOOT` per offer +
  `DECLINE_LOOT`; terminal/transitional phases → `[]`. `submit_action` validates via `_is_legal`
  (type + selector-key match; `send_to_bottom` is the player's free choice, validated by the resolver),
  illegal → `push_error` + unchanged. Combat actions delegate to `resolve_player_action`, then
  `_finalize_broken_items` (reads `ChargeManager.get_broken_slots` → null the slot, burden −1 [floor 0],
  emit `item_broken`); REPENT discards are the resolver's (`item_discarded`, already-null slot) so they
  aren't double-counted. `CHOOSE_LOOT` acquires at full `max_charges` (no cap: fill a null slot else
  append), burden +2, emit `item_acquired`, clear offers. `tests/test_action_injector.gd` written first —
  19 cases green (phase dispatch incl. combat gating delegation, no-cap loot offers, terminal empty,
  illegal-in-phase + illegal-target safety, attack-item break/no-break, consumable spend, weapon
  miss-preservation, loot acquire/fill-slot/append-when-full/decline, door + end-turn pass-throughs).
  Full suite **221/221**.
- **Decisions / flags:** (1) **Boundary** — ActionInjector owns post-resolution item *bookkeeping*
  (break detection, removal, `item_broken`, burden ±) and loot *acquisition*; the resolver owns charge
  *decrement* (T5.6, no re-decrement here); **phase transitions** after `CHOOSE_DOOR`/`END_TURN`/loot are
  RunController's (T6.4), so those actions are validated-then-pass-through here. (2) `item_acquired` is
  emitted here (mirrors `item_broken`'s ActionInjector attribution and the T6.1 DoD), though the
  `SignalBus` doc-comment still attributes it to RunController — minor attribution note, no behaviour change.
  (3) **Spec reconciled (no-cap confirmed with the designer):** `LLD-ARCH-003` previously said a full
  inventory auto-excludes `CHOOSE_LOOT` (only `DECLINE_LOOT` returned), contradicting `HLD-ITEMS-001`
  ("no inventory cap … item added regardless of how many held"). Confirmed there is **no cap and no
  auto-decline**; the inventory is unbounded, both offers are always selectable, and `DECLINE_LOOT` is a
  *voluntary* strategic choice (skipping loot keeps `item_burden_score` low for the Judge). Fixed
  `lld-technical-architecture` directly (same-requirement consistency fix): the `CHOOSE_LOOT` clause +
  its scenario now state no-cap, and the `GameState.inventory` row notes the array may grow past 3.

### T6.2 — `FloorProfile` + `NavigationModel` (Floor 3 generation)  ✅ **Done**
Data-driven `FloorProfile` resource (`HLD-RUN-005`). Counter-based 9-room generation for Floor 3:
4 pre-elite, Elite Gate at room 5, 4 post-elite, then Judge; two-door choice with full enemy
identity; pool exhaustion both-doors rule; segment caps; the Judge is the fixed final-floor boss
(`HLD-RUN-004`). **MVP1: combat/elite/boss + Worn Map beat only** (MF/WS deferred). Uses NAVIGATION
stream.
- **@Spec:** `HLD-RUN-004`, `HLD-RUN-005`, `HLD-DOOR-001`..`-004`, `LLD-FLOOR-STRUCT-001/-006`, `LLD-FLOOR-PATT-001/-002/-003`, `LLD-ARCH-008`
- **DoD:** deterministic 9-room sequences; Elite Gate fixed at 5; Judge at end; caps respected.
- ✅ `src/domain/floor_profile.gd` (`FloorProfile`, Domain content Resource like `EnemyData` — loaded
  from `.tres`, no to_json): `floor_id`/`floor_number`, `pre_elite_rooms`/`post_elite_rooms`,
  `boss_enemy_id`, `normal_enemy_pool`/`elite_enemy_pool`, plus `total_rooms()` (= pre+1+post) and
  `elite_gate_room()` (= pre+1). The fixed 9-room layout (`LLD-FLOOR-STRUCT-006`) is expressed as
  segment sizes, so a new floor is a new `.tres` (`HLD-RUN-005`). `data/floors/floor_3.tres` created
  (4/Gate/4; normal pool skeleton/zombie/plague_rat/wolf/fire_elemental/ice_elemental; elite pool
  bear/lightning_elemental; boss `the_judge`) — the **first real content `.tres` in the repo**,
  generated via `ResourceSaver` for a guaranteed-valid format.
- ✅ `src/application/navigation_model.gd` (`NavigationModel`, RefCounted, Application; rng injected like
  CombatResolver — no autoload/FileAccess/scene-tree access, verified by grep). `generate_doors(gs,
  profile)` returns the two-door choice for room `rooms_completed+1`: the Elite Gate (`elite_gate_room()`)
  yields one `elite_combat` door (elite pool) + one `combat` door (normal pool); every other room yields
  two `combat` doors with **distinct** enemy identities (`HLD-DOOR-002`), collapsing to the same identity
  only when the pool has one type (`HLD-DOOR-004`); past the last room it returns `[]` (Judge next,
  `LLD-FLOOR-BEATS-005`). `is_boss_next()` reports when only the boss remains. Door selection uses 2
  bounded rolls on the **NAVIGATION** stream (`_two_distinct_from`: roll i, roll j over the remaining,
  skip past i) so distinctness costs no retry loop and is deterministic. Each `DoorData` gets a stable
  `room_id` (`f<floor>_r<room>_d<door>`).
- ✅ `ContentRegistry` extended to scan `data/floors/` (`get_floor(id)`, `get_floor_by_number(n)`) — floor
  profiles are content, resolved by number at run time.
- ✅ `tests/test_navigation_model.gd` (11 cases, written first) — profile helpers, two combat doors,
  distinct/single-pool identities, distinct room_ids, Elite Gate at 5 + position-follows-profile,
  no-doors-after-room-9 + `is_boss_next`, same-seed determinism, full 9-room walk. `test_content_registry.gd`
  +2 (temp-dir floor index + real `floor_3.tres` end-to-end load). Full suite **234/234**.
- **Scope / decisions:** (1) **MVP1 deferrals** — Memory Fragment / Wandering Soul room types and their
  per-segment caps (`LLD-FLOOR-PATT-003`) are **MVP2**; with combat the only pooled type, "caps respected"
  reduces to "both doors combat", and the pool-exhaustion rule (`HLD-DOOR-004`) is exercised via the
  single-enemy-pool case. The opening/combat-lock beats (`LLD-FLOOR-BEATS-001/-002`) are moot without
  non-combat types. (2) **Worn Map single-door beat (room 4)** is **T6.6** — `NavigationModel` generates
  the standard two-door structure; T6.6 overrides room 4. (3) **Rest on elite path** (`LLD-FLOOR-BEATS-006`,
  room 6 after the elite door) is not yet modelled — flagged for T6.4 orchestration / a later pass, as it
  depends on which room-5 door was taken (post-choice state the generator doesn't yet read). (4) **Loot
  pools** belong on `FloorProfile` too but are added in **T6.3** (`LootGenerator`) to keep this task's
  schema to what navigation uses.

### T6.3 — `LootGenerator`  ✅ **Done**
Two-item offer (one durability, one consumable) from normal vs elite pools by encounter tier;
empty-pool fallbacks; LOOT stream only.
- **@Spec:** `LLD-ARCH-022`, `HLD-COMBAT-012`, `-013`, `LLD-ARCH-008`
- **DoD:** elite vs normal pool separation; one-of-each; LOOT-stream-only scenarios green.
- ✅ `src/application/loot_generator.gd` (`LootGenerator`, RefCounted, Application; rng + `content`
  provider injected — no autoload/FileAccess/scene-tree access, verified by grep). `generate_loot_offers(
  game_state, elite)` resolves the floor's `FloorProfile` via `content.get_floor_by_number(floor_number)`,
  draws one durability + one consumable from the tier's pools (elite → `elite_*` pools, else `normal_*`)
  on the **LOOT** stream, and returns an `Array` of item_ids **without mutating GameState** (RunController
  stores them in `NavigationState.loot_offers`). Empty-pool fallbacks: one empty → both from the other
  (distinct when ≥2, via the same no-retry distinct-pick as NavigationModel); both empty → `[]` (handled
  like DECLINE_LOOT). Null profile → `[]`.
- ✅ `FloorProfile` extended with the four loot pools (`normal_durability_pool`/`normal_consumable_pool`/
  `elite_durability_pool`/`elite_consumable_pool` — LLD-ITEMS-005/-007/-006/-008); `data/floors/floor_3.tres`
  regenerated with the canonical Floor 3 item ids (Cracked Cudgel … Small Amethyst; Iron Maul … Medium
  Amethyst; Fire Bomb … Frost Shard; Poultice/Brittle Charm/Fulminating Powder).
- ✅ `tests/test_loot_generator.gd` (11 cases, written first) — normal/elite tier separation (no
  cross-tier leakage), one-durability-one-consumable, both empty-pool fallbacks + both-empty `[]`,
  fallback distinctness, **LOOT-stream-only** (stub rng records every stream used), null-profile `[]`,
  no-GameState-mutation (to_json before/after), same-seed determinism. Full suite **245/245**.
- **Decision:** the spec signature `generate_loot_offers(game_state, elite)` resolves the profile from
  `game_state.floor_number` via the injected content provider (rather than taking a `FloorProfile` param
  like `NavigationModel`) — kept faithful to `LLD-ARCH-022`.

### T6.4 — `RunController` (orchestrator)  ✅ **Done**
Application-layer node (not autoload). Phase state machine (`NAVIGATION`, `COMBAT`,
`LOOT_SELECTION`, `NON_COMBAT_EVENT` [stub for MVP1], `FLOOR_TRANSITION`, `RUN_END`). Fires
replenishment events to ChargeManager; emits `save_requested` (BACKGROUND after door, CHECKPOINT
after boss); floor transition (full HP restore, temporary companion departs); initializes and
maintains `item_burden_score`; wires loot selection. Communicates only via SignalBus.
- **@Spec:** `LLD-ARCH-016`, `LLD-ARCH-007`, `HLD-RUN-006`, `HLD-RUN-007`, `LLD-ARCH-009`
- **DoD:** full phase walk fires correct signals/replenishments; burden lifecycle correct; freed at run end.
- ✅ `src/application/run_controller.gd` (`RunController`, extends Node, Application; no autoload access
  except the injected SignalBus — verified by grep). `configure(rng, content, signal_bus)` builds the
  collaborators (CombatResolver, ActionInjector, NavigationModel, LootGenerator, ChargeManager,
  AbilityPipeline). `start_run(seed, vessel_id)` seeds RNG, builds the initial GameState (vessel at full
  HP, ability/item charges, **burden = starting-item count**, bound companion if any), fires `floor_start`,
  and enters NAVIGATION with the first doors. `get_legal_actions()`/`submit_action()` are the agent/UI
  surface — every decision routes through ActionInjector (`LLD-ARCH-003`), then `_advance()` drives phases.
- ✅ **Phase walk:** NAVIGATION `CHOOSE_DOOR` → BACKGROUND save + `room_entered`/`combat_started` +
  `encounter_start` replenish → COMBAT (deck assembled, first omen cycle paused for `CHOOSE_OMEN`). After
  `CHOOSE_OMEN` → `begin_player_turn` (buckets reset). Combat victory → `encounter_end` + `combat_ended` +
  `rooms_completed++` + LootGenerator offers → LOOT_SELECTION. Defeat → RUN_END("death"). Loot pick/decline
  → next doors (NAVIGATION) or, after room 9, the boss. Boss victory → CHECKPOINT save → RUN_END("completion").
- ✅ **Combat round driver** (`_run_enemy_phase`): `END_TURN` → `end_player_turn` (clears stun) →
  `resolve_enemy_turns` → death processing → `resolve_omen_tick` (decrements the new `OmenCycleState.
  ticks_remaining`) → if the cycle expired, `resolve_omen_cycle_start` (next cycle, pause for `CHOOSE_OMEN`),
  else `begin_player_turn`. `_process_deaths` calls `resolve_enemy_death` once per 0-HP enemy (omen removal +
  on-death status/summons); `_check_combat_end` runs `check_vessel_death_intercept` before declaring defeat.
- ✅ **Phase-5 backfill (the full-bucket decision):** `CombatState` gained `is_action_used`/`is_support_used`/
  `is_consumable_used`; `get_legal_combat_actions` now gates each HLD-COMBAT-001 bucket (Action mandatory +
  stun-blocked, Support/Consumable optional, END_TURN legal once Action is satisfied/impossible);
  `resolve_player_action` marks the used bucket; new `begin_player_turn`/`end_player_turn` own the
  is_evading/is_stunned/bucket resets (moved off per-action). `OmenCycleState.ticks_remaining` is the precise
  per-cycle countdown that **resolves the T5.5 deferral** — `_cycle_remaining_ticks` now returns the live
  remaining ticks. T5.6/T5.1/T5.7 tests updated accordingly (turn-lifecycle + bucket-gating coverage added).
- ✅ Tests: `tests/test_run_controller.gd` (10 cases — init/burden, door→combat signals+replenish+omen pause,
  choose-omen→turn, victory→loot, loot→navigation (+2 burden), defeat→run-end, enemy-phase cycle tick,
  boss→checkpoint→completion, floor transition HP-restore + temp-companion departs). `test_player_action`/
  `test_combat_resolver`/`test_enemy_death` updated for the new turn model. Full suite **261/261**.
- **Decisions / flags:** (1) **RunController is the agent surface** — it exposes get/submit that delegate to
  ActionInjector (LLD-ARCH-003 honored) and then advance phases; the AIPlayerAgent (T7.1) talks to it. (2)
  `SaveType` enum (BACKGROUND/CHECKPOINT) is owned by RunController (it has a `class_name`, unlike the
  no-`class_name` autoloads); **SaveManager (T6.5)** consumes `RunController.SaveType` rather than redefining it. (3) **MVP1 single floor** — `_floor_transition` (HP restore +
  temp-companion departure + `floor_transitioned`, HLD-RUN-006) is implemented and unit-tested but only fired
  by multi-floor runs (MVP3+); the Judge's defeat ends the run. (4) ✅ **One enemy per encounter — RESOLVED
  in T8.3:** `EnemyData.pre_elite_count`/`post_elite_count` + `RunController._encounter_count` now spawn N
  same-type enemies (3 Plague Rats, 2–3 Wolves, …). *Mixed*-composition encounters (the Judge + 2 Witnesses)
  are still pending — that's **T8.4** (boss composition). The round loop is roster-size agnostic. (5)
  **unit_died for status-tick kills** isn't emitted (only the resolver's damage-path emits it); minor logging
  gap, state is correct. (6) `NON_COMBAT_EVENT` is unused in MVP1 (MF/WS deferred); the Worn Map single-door
  beat is **T6.6**. (7) **Rest-on-elite-path** (room 6, `LLD-FLOOR-BEATS-006`) still not modelled — the door
  choice at room 5 isn't yet read post-resolution to force a rest at room 6 (flagged in T6.2; revisit with MF/WS).

### T6.5 — `SaveManager` + `ScreenManager` (headless-appropriate)  ✅ **Done**
`SaveManager` autoload reacts to `save_requested`, coordinates JSON save/load via
PersistenceService, offers resume/start-over on existing CHECKPOINT. `ScreenManager` autoload
reacts to `phase_changed` — **no-op/headless-safe for MVP1** (real scenes are MVP2) but the
subscription wiring exists.
- **@Spec:** `LLD-ARCH-007`, `LLD-ARCH-016`, `LLD-ARCH-010`
- **DoD:** background + checkpoint saves written and reloadable; resume/start-over branch works headlessly.
- ✅ `src/application/save_manager.gd` (`SaveManager`, autoload #9, no `class_name`). Single MVP1 save slot
  (`user://saves/run.json`, overridable via `save_path` for tests). `save(game_state, save_type)` writes
  `{save_type, state}` through `PersistenceService.write_save` (version-stamped, LLD-ARCH-010);
  `load_run()`/`resume()` rebuild the GameState via `read_save` (runs migrations); `has_save()`/
  `has_checkpoint()` (CHECKPOINT-only → the Resume/Start-Over gate); `start_over()` clears the slot.
  Signal path: `connect_to_bus(bus)` wires `save_requested` → `_on_save_requested`, which serialises the
  state RunController registers via `set_active_state` (the signal carries only the SaveType, so the
  payload is supplied out-of-band — RunController → SaveManager, never the reverse).
- ✅ `src/application/screen_manager.gd` (`ScreenManager`, autoload #10). `connect_to_bus(bus)` wires
  `phase_changed` → tracks `current_phase`; under `GameConfig.HEADLESS` (MVP1) it does no scene work
  (the only `HEADLESS` check, per LLD-ARCH-002). Real scene switching is MVP2.
- ✅ `PersistenceService.delete_file(path)` added (start-over needs deletion; stays the sole FileAccess/
  DirAccess owner). Both autoloads registered in `project.godot` (#9, #10).
- ✅ `tests/test_save_manager.gd` (8 cases — save/load round-trip, missing→null, checkpoint vs background
  detection, resume, start-over clears, signal-path save, no-active-state no-op) + `tests/
  test_screen_manager.gd` (2 — phase tracked, headless safe). Engine boots with both autoloads. Full
  suite **271/271**.
- **Decisions / flags:** (1) `connect_to_bus(bus)` takes the bus explicitly (mirrors `EventLog`) so tests
  use a fresh `SignalBus`; `_ready` passes the global. (2) **RunController→SaveManager wiring deferred to
  T7's run bootstrap:** RunController does not itself call `SaveManager.set_active_state` (keeps it
  decoupled and avoids save side-effects in RunController unit tests) — the AIPlayerAgent/headless bootstrap
  registers the active run. (3) BACKGROUND resumes silently; only CHECKPOINT trips the Resume/Start-Over
  prompt (a UI concern surfaced via `has_checkpoint()` for MVP2).

### T6.6 — Encounter-countdown system + Worn Map companion beat  ✅ **Done**
Implement the **encounter-countdown item system** (`HLD-ITEMS-003`): counter decrements 1 per
completed encounter (combat/non-combat; boss slot never triggers), replaces the *next* regular room
with the triggered encounter when it hits 0 (no extra room — total stays fixed), removes the item
after triggering, and is acquirable only when enough non-boss encounters remain (constraint enforced
at acquisition). Worn Map is the MVP1 instance: at 0 charges it forces a single-door temporary
companion beat (`HLD-DOOR-001`). Temporary companion is floor-scoped (departs at boss if unused —
`HLD-RUN-006`); companion limit of one (`HLD-COMPANION-004`).
- **@Spec:** `HLD-ITEMS-003`, `HLD-COMPANION-001`, `-003`, `-004`, `HLD-DOOR-001`, `HLD-RUN-006`, `LLD-ITEMS-004`, `LLD-FLOOR-BEATS-003`
- **DoD:** counter decrements on all non-boss encounters; next room replaced (not appended) at 0;
  item removed after trigger; beat fires once per floor; companion acts on turn_end; departs correctly.
- ✅ **Key reuse:** the Worn Map is a Support (durability) item, so its "counter" is just its charges —
  already decremented per-encounter by `ChargeManager.decrement_support_items` (T3.1). T6.6 adds only the
  *break-behaviour* difference (trigger a beat vs. plain break) and wires the per-encounter decrement into
  RunController.
- ✅ Schema: `AbilityData` gained `is_encounter_countdown: bool` + `triggered_room_type: String`
  (HLD-ITEMS-003; synced to `LLD-ARCH-018`). `FloorProfile` gained `temporary_companion_pool: Array[String]`;
  `data/floors/floor_3.tres` regenerated with `["raven","shadow","life_mote"]` (`LLD-MF-009`).
- ✅ `NavigationModel.generate_triggered_beat(room_type, …)` — a forced **single-door** beat
  (HLD-DOOR-001), companion drawn from `temporary_companion_pool` on the NAVIGATION stream.
- ✅ RunController wiring: `_complete_encounter()` runs after each non-boss encounter (combat victory +
  the beat itself) — decrements Support items, and on a 0-charge break either sets the pending triggered
  room (encounter-countdown → Worn Map removed, burden −1) or emits `item_broken` (ordinary support break).
  `_generate_doors` emits the single-door beat when a trigger is pending (replacing the next room — total
  count fixed, since the beat consumes a room slot). `_post_navigation` routes a `"companion"` door to
  `_enter_companion_beat` (adds the temp companion under the one-temp limit, sets
  `companion_offered_this_floor`, `rooms_completed++`, back to NAVIGATION). `_run_enemy_phase` now fires
  `resolve_companion_trigger("turn_end")` **before** enemy turns (HLD-COMPANION-003). `_finish_floor` clears
  any unused temporary companion (departs after the boss, HLD-COMPANION-001).
- ✅ `tests/test_run_controller.gd` +5 (per-encounter decrement; trigger→single-door beat + Worn Map
  removed; beat adds temp companion + offer flag + room count; turn_end fire + timer_exhausted departure;
  boss does **not** decrement the countdown). Full suite **276/276**.
- **Decisions / flags:** (1) ⚠️ **Loot-acquisition constraint deferred** — HLD-ITEMS-003's "acquirable only
  when enough non-boss encounters remain" applies only when an encounter-countdown item is offered as
  *loot*; the only MVP1 instance (Worn Map) is a starting item, so no MVP1 loot path offers one. The
  ActionInjector get_legal/acquire guard is deferred to when such items enter a loot pool (post-MVP1) —
  flagged rather than written as dead code. (2) The Worn Map trigger removes the item + burden −1 (fully
  spent, HLD-RUN-007) but does **not** emit `item_broken` (it triggered, it didn't break). (3) The beat is
  resolved synchronously within NAVIGATION (no combat/loot); `NON_COMBAT_EVENT` phase stays unused in MVP1.
  (4) Worn Map `.tres` + Pilgrim/companion content are **Phase 8** — T6.6 is engine + stub-content tests.

---

**Phase 6 complete.** ✅ Application orchestration (ActionInjector, NavigationModel, LootGenerator,
RunController, SaveManager/ScreenManager, encounter-countdown/Worn Map) all landed; full suite 276/276.
Next: **Phase 7** — AIPlayerAgent (T7.1) + the full headless determinism integration gate (T7.2), which
also wires RunController → SaveManager and exercises the loop end-to-end (needs Phase 8 content for a real
run; the determinism gate can run on stub content first).

---

## Phase 7 — AIPlayerAgent & Integration

### T7.1 — `AIPlayerAgent` (Random strategy)  ✅ **Done**
`RefCounted` in `src/application/`. `play_turn()` picks uniformly at random from
`ActionInjector.get_legal_actions()` using its **own** local RNG (never RNGService).
`run_to_completion(seed, vessel_id)` → `RunResult`.
- **@Spec:** `LLD-ARCH-020`, `LLD-ARCH-003`
- **DoD:** completes a run headlessly; AI RNG never advances game streams.
- ✅ `src/application/ai_player_agent.gd` (`AIPlayerAgent`, RefCounted, Application; no autoload access —
  `rng`/`content`/`signal_bus` injected, decision RNG is its own). `play_turn(surface)` draws one legal
  action uniformly from `surface.get_legal_actions()` via its dedicated `ai_rng: RandomNumberGenerator`
  and submits it (empty set → no-op). `run_to_completion(seed, vessel_id)` seeds `ai_rng` from the same
  `seed` (deterministic *and* stream-independent), builds + configures a `RunController`, drives
  `get_legal_actions`/`submit_action` until `is_finished()`, and returns a `RunResult`. A `MAX_ACTIONS`
  guard prevents a wedged loop from hanging CI. `src/application/run_result.gd` (`RunResult`, RefCounted)
  — `seed`/`vessel_id`/`floors_completed`/`outcome`/`turn_count` + `equals()`/`to_dict()`.
- ✅ `tests/test_ai_player_agent.gd` (5 cases, written first) — play_turn submits one legal action,
  empty-set no-op, **selection uses the local RNG not game streams** (a reference RNG seeded identically
  reproduces every choice; the injected game-rng spy records 0 calls), run_to_completion returns a
  finished RunResult, two same-seed runs agree.
- **Decision / deviation (flagged):** the spec's `play_turn(game_state)` signature predates the T6.4
  "RunController is the agent surface" decision — the agent talks to the **RunController surface**
  (`get_legal_actions`/`submit_action`, which route through ActionInjector per `LLD-ARCH-003`), not raw
  GameState, so phase advancement happens. `play_turn(surface)` accepts any object with that surface,
  keeping the unit test decoupled from RunController internals.

### T7.2 — Full headless determinism integration test  ✅ **Done**
End-to-end: run the same seed twice through `AIPlayerAgent` → identical `RunResult` (turns, loot,
outcome). This is the primary MVP1 integration gate.
- **@Spec:** `LLD-ARCH-020`, `LLD-ARCH-008`, `SCOPE-001`
- **DoD:** two runs of N seeds produce byte-identical RunResults; green in headless CI command.
- ✅ `tests/test_headless_determinism.gd` (3 cases) — wires the agent to the **real `RNGService`
  autoload** + a fresh SignalBus over stub Floor-3 content (a fully playable run; Phase-8 content not
  required for the determinism property, per the Phase 6 closing note). `test_same_seed_produces_
  identical_run_results` runs each of 6 seeds twice and asserts `RunResult.equals()` (with the diff in
  the failure message) — proves the game streams reset cleanly per run. Plus: RunResult records
  seed/vessel/outcome, and **40-seed divergence** (the run isn't a constant) so the gate is meaningful.
  Full suite **284/284**.

---

**Phase 7 complete.** ✅ `AIPlayerAgent` (Random strategy, dedicated decision RNG) + `RunResult` landed,
and the headless determinism integration gate is green over multiple seeds — the full MVP1 engine loop
(navigation → combat → omen → loot → boss → run end) runs end-to-end and deterministically on stub
content. **The MVP1 *engine* is feature-complete; what remains is Phase 8 content** (real Pilgrim,
Floor-3 enemies, the Judge, items, omen cards) plus the few content-coupled handlers deferred to land
with it (`restore_item_charges`, `elemental_synergy`/`sacred_ground`, the Combustible Oil branch).

---

## Phase 8 — MVP1 Content (data files — no engine code)

> All tasks here produce `.tres`/data only. No `@Spec` on data files; ensure the *schema* classes
> (Phase 2) carry the annotations. Each task's DoD includes "discovered by registry; handler ids
> resolve at startup; AIPlayerAgent run exercises it."

### T8.1 — The Pilgrim vessel + abilities  ✅ **Done**
`pilgrim.tres` (`LLD-VESSELS-001`), Throw Rock (`LLD-ABILITIES-004`), Read the Road
(`LLD-ABILITIES-005`), Good as New (`LLD-ABILITIES-003`), Stillness vessel omen card
(`LLD-OMEN-CARD-006`).
- ✅ Five `.tres` authored (via `ResourceSaver` for guaranteed-valid format, then the one-off
  generator removed — the `.tres` are the source of truth): `data/vessels/pilgrim.tres` (HP 24,
  `default_strike_id="throw_rock"`, abilities `[read_the_road, good_as_new]`, no companion, **2 copies
  of Stillness** in `omen_contributions`, 3 starting items per `LLD-ITEMS-004`); `data/abilities/
  throw_rock.tres` (attack, unlimited, `deal_damage{base_damage:3}`); `data/abilities/read_the_road.tres`
  (**passive** — auto-fires at combat start via the existing `_run_passive_omen_handlers` pass,
  `peek_omen_deck`); `data/abilities/good_as_new.tres` (support, 1 charge, `floor_start` replenish,
  `restore_item_charges`); `data/omen_cards/stillness.tres` (no status, no handlers — does nothing on
  either side, number-only timer).
- ✅ **Unblocked the T4.2 deferral:** `restore_item_charges` (`RestoreItemChargesHandler`) is now
  implemented + registered — Good as New refills one item to max via `ctx.content` (the `AbilityContext`
  content provider added in T5.2). An explicit `target_slot` restores that slot (player choice, MVP2 UI);
  with none given it auto-targets the most-depleted eligible item, matching the engine's "support actions
  are a single non-targeted action" model so the MVP1 random agent exercises a real effect. Single-use
  items are never affected. `tests/test_restore_item_charges.gd` — 5 cases (TDD).
- ✅ `tests/test_pilgrim_content.gd` — 6 cases reading the **shipped** `.tres` through the live
  `ContentRegistry` autoload (vessel/ability shapes match the specs; every Pilgrim handler resolves in
  the pipeline). The real ContentRegistry boots cleanly with the new content (boot-time handler
  validation passes). Full suite **295/295**.
- **Decisions / flags:** (1) **Targeting** — true per-item-slot enumeration for Good as New (and any
  targeted support ability) is an MVP2 UI concern; MVP1 uses the auto-target. Flagged on the handler.
  (2) `starting_item_ids` references `walking_staff`/`spoiled_potion`/`worn_map` whose `.tres` land in
  **T8.2** — until then they resolve to `null` (no boot error; `_build_initial_state` already tolerates
  null item data). A full real-content `AIPlayerAgent` run is only completable once T8.2–T8.4 (items,
  Floor-3 enemies, the Judge) land; T8.1's "run exercises it" is satisfied by the boot validation +
  content-load tests.

### T8.2 — Pilgrim starting items  ✅ **Done**
**Three** starting items per `LLD-ITEMS-004`: Walking Staff (attack durability), Spoiled Potion
(consumable, Poisoned), Worn Map (support durability / encounter-countdown), each with precomputed
`score` per `LLD-ITEMS-011`.
- ✅ **Resolved** (change `fix-pilgrim-burden-init`): `LLD-ARCH-017`'s burden-init scenario now agrees
  with `LLD-ITEMS-004` — the Pilgrim has **3** starting items → `item_burden_score` initializes to **3**
  (1 per starting item per `HLD-RUN-007`). Used in T6.4 (`_build_initial_state` sets burden =
  `starting_item_ids.size()`, now 3 for the real Pilgrim).
- ✅ Three item `.tres` in `data/items/` (items are `AbilityData` with `breaks_at_zero` — scanned into the
  shared ability index): `walking_staff.tres` (attack, 6 charges, `deal_damage{base_damage:6}`, **score
  42**); `spoiled_potion.tres` (consumable, 1 charge, `apply_status{poisoned, magnitude:2}` — X=2, **score
  15**); `worn_map.tres` (support, 3 charges, `is_encounter_countdown`, `triggered_room_type="companion"`,
  no active handler, **score 28**). Scores per `LLD-IR-011`.
- ✅ **Engine gap fixed (TDD):** player status-applying actions now inherit the current omen cycle's
  `remaining_ticks` (Spoiled Potion authored without `remaining_ticks` per spec would otherwise expire at
  the next tick before dealing damage). `_resolve_standard_action` injects `_cycle_remaining_ticks` into
  the handler params before executing, mirroring the enemy-intent path (`_execute_intent`); handlers that
  ignore it (deal_damage, restore_item_charges, …) are unaffected. `tests/test_player_action.gd` +1.
- ✅ `tests/test_pilgrim_items_content.gd` — 4 cases reading the shipped `.tres` through `ContentRegistry`
  (shapes/effects/scores; all three Pilgrim starting items now resolve and their handlers are known to
  the pipeline). Full suite **300/300**. The Pilgrim run now builds with 3 real items + burden 3.

### T8.3 — Floor 3 enemies (non-boss)  ✅ **Done**
Skeleton, Zombie, Plague Rat, Wolf, Bear, Fire/Ice/Lightning Elementals, Low/High HP Fanatics,
Buff/Absorption Totems (`LLD-ENEMIES-004`–`-008`, `-014`–`-020`), plus encounter structure
(`LLD-ENEMIES-009`).
- ✅ **13 enemy `.tres`** in `data/enemies/` (generated via `ResourceSaver`, generator removed): skeleton,
  zombie, plague_rat, wolf, bear, fire_elemental, ice_elemental, lightning_elemental, lightning_spark,
  low_hp_fanatic, high_hp_fanatic, buff_totem, absorption_totem — HP/damage type/resistances/
  vulnerabilities/tags/encounter counts/intents/conditionals/on-death all per the LLD-ENEMIES tables
  (Zombie Slam charge→release, Wolf pack/lone `ally_count` conditionals + Howl summon, Bear `turn_number:1`
  sleeping + 2-hit swipe + self-frenzy, the two-phase Lightning Elemental → 2 Sparks with turn-gated
  escalation, Totem `status_target:"allies"` buffs).
- ✅ **Two approved engine additions (both TDD):**
  - **Innate elemental vulnerability** — `EnemyData.vulnerabilities: Array[String]` (mirrors `resistances`);
    `DamageCalculator` OR-combines innate + status Vulnerable (single ×1.5, no double-stack, cancels with
    resistance). Reconciled `HLD-COMBAT-007` via OpenSpec change `add-innate-enemy-vulnerability`
    (archived `2026-06-22`); `EnemyData` schema field added to `LLD-ARCH-018` by direct consistency edit
    (T5.5 precedent). `tests/test_damage.gd` +4.
  - **Multi-enemy encounters** (resolves the T6.4 "one enemy per encounter" flag) — `EnemyData.
    pre_elite_count`/`post_elite_count` (`LLD-ENEMIES-002`, added to `LLD-ARCH-018`); `RunController.
    _enter_combat` spawns N distinct instances (`<id>_<i>`) via `_encounter_count` (elite-gate/boss → 1;
    normal rooms → pre/post count by whether the elite gate is passed). The round loop was already
    roster-agnostic. `tests/test_run_controller.gd` +3.
  - **Frenzied composite** (needed by Bear, in the elite pool; also Fanatics) — `DamageCalculator` now
    treats a `frenzied` status as both Emboldened (Physical) flat (attacker) and Vulnerable (Physical) ×1.5
    (target); added to `StatusRules.MAX_WINS`. This implements the existing `HLD-COMBAT-006` Frenzied
    definition (no spec change). `tests/test_damage.gd` +3.
- ✅ `tests/test_floor3_enemies_content.gd` — 10 cases reading the shipped `.tres` through `ContentRegistry`
  (per-enemy spec fidelity + every Floor 3 pool enemy resolves; boss correctly still null pending T8.4).
  ContentRegistry boots clean with all 13. Full suite **320/320**.
- **Decisions / flags:** (1) **Fanatics/Totems authored but not yet in the Floor 3 pool** — pool
  finalization is **T8.6**; the Totems additionally need *mixed-composition* encounters (Fanatic+Totem),
  which is `[OPEN·MVP3]` (current multi-enemy support spawns N of the *same* type). (2) **Plague Rat poison
  immunity** (`LLD-ENEMIES-006`) is not modelled — `EnemyData` has no immunity field; flagged (low impact —
  rats die in 1–2 hits; the only MVP1 poison source is the Spoiled Potion). (3) **Bear frenzy magnitude**
  set to 2 (spec omits it; needed for the Emboldened-physical half of Frenzied) — flagged for tuning.
  (4) The boss + Witnesses (mixed composition) are **T8.4**. (5) ✅ **RESOLVED** — the pre-existing
  `hld-combat-system` strict-validation error (and the wider SHALL/MUST + Purpose lint debt across 10 specs)
  was cleared in a 2026-06-24 spec-hygiene pass; all 23 specs now pass `openspec validate --strict`, so
  archive no longer needs `--no-validate`.

### T8.4 — The Judge boss + Witnesses  ✅ **Done**
`the_judge.tres` (`LLD-ENEMIES-010`) — the fixed final-floor boss (`HLD-RUN-004`), Witness of Mercy /
Vengeance (`LLD-ENEMIES-021/-022`), Repent card (`LLD-OMEN-CARD-020`). Verifies burden-tier handler
(T4.2) and Pass Judgment phase trigger.
- ✅ **4 `.tres`** authored (generator removed): `data/enemies/the_judge.tres` (HP 30, physical, `judge`
  tag; strike 50% / suffer→Bleed +3 30% / ponder→evade 20%; **Pass Judgment** `pass_judgment`
  charge→release forced by `hp_percent_lte:30` conditional), `witness_of_mercy.tres` + `witness_of_vengeance.tres`
  (HP 10, `judge_witness`), `data/omen_cards/repent.tres`.
- ✅ **Engine additions (all TDD):**
  - **Mixed-composition encounters** — `EnemyData.accompanied_by` (the Judge spawns its two Witnesses,
    primary first so the Witnesses' `allies` intents target the Judge) + `ends_combat_on_death` (the Judge
    is the only required kill — `RunController._required_kill_dead` ends combat in victory regardless of
    living Witnesses). `RunController._enter_combat` now spawns primary + escorts via `_spawn_into`.
    `tests/test_run_controller.gd` +2.
  - **Direct omen contributions** — `EnemyData.direct_omen_contributions` injects cards verbatim per
    instance, bypassing the two-tier model (the Judge's Repent ×3, `LLD-OMEN-CARD-020`).
    `CombatResolver._enemy_card_contributions` appends them. `tests/test_omen_system.gd` +1.
  - **Burden-tier handler generalized** — `apply_mending_by_burden_tier` gained an optional `status_id`
    param (default `mending`): Mercy applies tier-based Mending (1/3/5), Vengeance tier-based
    Emboldened (Physical) (1/2/3) via the same handler. The handler id is unchanged (the spec names it for
    Mercy). `tests/test_handlers.gd` +1.
  - The Witnesses' kill consequences use `on_death_apply_to_player` (Mercy → `vulnerable:physical`,
    Vengeance → `frenzied` mag 2). Pass Judgment's charge→release rides the existing intent engine (no
    new code). All four new `EnemyData` fields added to `LLD-ARCH-018` by direct consistency edit.
- ✅ `tests/test_judge_content.gd` — 6 cases (composition/required-kill, Repent ×3, intents + Pass
  Judgment conditional, both Witnesses' tier handlers, boss now resolves). The earlier T8.3 "boss is null"
  assertion updated to "resolves". ContentRegistry boots clean; full suite **330/330**.
- **Decisions / flags:** (1) `accompanied_by` + `ends_combat_on_death` generalise mixed composition —
  reusable for the MVP3 Fanatic+Totem pairing. (2) Vengeance's tier handler reuses the Mercy-named handler
  with a `status_id` param (spec leaves Vengeance's handler unnamed); the name is a slight misnomer for the
  Emboldened case — documented on the handler. (3) Bear frenzy / Witness-of-Vengeance Frenzied magnitudes
  both 2 (consistent with the Fanatic taunt; spec omits explicit values) — flagged for tuning.

### T8.5 — Omen cards (floor / enemy / shared)  ✅ **Done**
Floor 3 default deck (`LLD-OMEN-CARD-008`), Exposed floor card (`-019`), enemy family/type cards
(`-011` Grave Knit, `-012` Thick Hide, `-013` Elemental Synergy, `-014` Sacred Ground), status
cards (Burning, Shocked, Chilled, Emboldened ×2, Vulnerable ×3, Mending — `-001`..`-005`, `-015`..`-018`),
number distribution (`LLD-OMEN-MECH-008`).
- ✅ **18 omen-card `.tres`** in `data/omen_cards/` (generator removed): status cards `burning`(mag 5),
  `shocked`, `chilled`(mag 2), `mending`(mag 3), `emboldened_physical`(mag 2), `emboldened_{fire,lightning,ice}`,
  `vulnerable_{fire,lightning,ice}`, `exposed`; enemy cards `grave_knit`(mending 5, tag undead),
  `thick_hide`(hardened 3, tag beast), `elemental_synergy_{fire,ice,lightning}`(type_convert), `sacred_ground`.
  All effects ride existing engine mechanics (StatusRules + DamageCalculator + the shift/tick resolvers) —
  **no new handlers** (Stillness/Repent were done in T8.1/T8.4).
- ✅ **Floor ambient deck wired** — `FloorProfile.ambient_omen_cards` (the 12 `LLD-OMEN-CARD-008` cards) +
  `RunController._omen_sources` now shuffles the floor's ambient cards into every combat deck alongside the
  vessel/companion/enemy sources (`HLD-OMEN-004`). `floor_3.tres` updated with the 12 ambient ids.
  `tests/test_run_controller.gd` +1.
- ✅ **Number distribution** (`LLD-OMEN-MECH-008`) was already implemented (`_timer_value_pool` 25/50/25) and
  is covered by `test_omen_system.gd` — timers are assigned at deck assembly, not authored on cards.
- ✅ `tests/test_omen_cards_content.gd` — 7 cases reading the shipped `.tres` (status/magnitude/tag/
  type-convert fidelity, the 12-card ambient deck resolves, and **every** Floor 3 enemy + Judge omen
  contribution now resolves to a real card). ContentRegistry boots clean. Full suite **338/338**.
- **Decisions / flags:** (1) **Thick Hide → `hardened`** — the spec names a distinct "Thick Hide" status but
  its mechanic (−3 per hit) is identical to Hardened, so the card applies `hardened` (mag 3) to beasts,
  reusing the tested absorption path. No functional difference in MVP1 (nothing distinguishes them); a
  dedicated status would only matter if a future cleanse/interaction must tell them apart. (2) **Chilled
  per-tick step** — card authored with starting magnitude 2 (`LLD-OMEN-CARD-003` wants 2→4 across ticks),
  but the engine increments by the `CHILLED_TICK_STEP=1` const (the T5.3 single-field limitation), so it
  escalates 2→3 not 2→4. Functional (reduction increases, never to 0) but not the exact cadence — flagged;
  exact per-card steps need a `StatusInstance` step field. (3) **Sacred Ground** authored as an **inert
  placeholder** (no status/handler) — its Totem-aura doubling needs the `sacred_ground` handler + totem
  auras, both MVP3; no totems are in the MVP1 Floor 3 pool, so it never meaningfully fires. Keeps boot clean
  (no unregistered handler) and lets the Fanatic family-card reference resolve.

### T8.6 — Item drop pools + Floor 3 profile  ✅ **Done**
Normal/elite durability and consumable pools (`LLD-ITEMS-005`–`-008`) and the Floor 3 `FloorProfile`
data (`lld-floor`). Confirm LootGenerator draws the right tiers.
- ✅ **22 loot-item `.tres`** in `data/items/` (generator removed): normal/elite durability weapons
  (Cracked Cudgel, Rope Flail [all], Battered Sword, Ember Shard, Spark Rod, Frost Sliver / Iron Maul,
  Spiked Chain [all], Soldier's Blade, Smoldering Brand, Arc Wand [arc], Glacial Brand), the two Amethysts
  (cleanse), and the consumables (Fire Bomb, Ointment, Combustible Oil, Hardening Resin, Frost Shard /
  Poultice, Brittle Charm, Fulminating Powder). Buckets/charges/effects per `LLD-ITEMS-005..-008`,
  authored `score` per `LLD-IR-011`. The Floor 3 loot pools were already on `floor_3.tres` (T6.3); every id
  now resolves.
- ✅ **Enemy pool finalized** (resolves the T8.3 flag) — added Low/High HP Fanatic to `normal_enemy_pool`
  per the authoritative `LLD-ENEMIES-002` normal table (they're standalone-capable; their inert Sacred
  Ground + Mending cards resolve). Totems stay out — they require mixed-composition Fanatic+Totem pairing
  (`[OPEN·MVP3]`). The real-content run still completes deterministically with Fanatics in rotation.
- ✅ **Engine additions (all TDD):**
  - **Offensive-consumable targeting** — `ApplyStatusHandler` auto-targets the first living enemy when the
    action is non-targeted (Fire Bomb / Frost Shard / Brittle Charm / Fulminating Powder are single
    non-targeted actions; real per-target choice is MVP2 UI). `tests/test_handlers.gd` +1.
  - **`combustible_oil` handler** (the last deferred MVP1 handler) — branching: Vulnerable (Fire), or a
    6-fire burst if the target is already Burning. Registered. `tests/test_combustible_oil.gd` (4 cases).
  - **Arc damage** — `deal_damage` gained an `arc_damage` param (Arc Wand: 9 primary + 4 arc); defaults to
    `base_damage` so other modes are unchanged. `tests/test_damage.gd` +1.
- ✅ `tests/test_floor3_loot_content.gd` — 6 cases (every pool item resolves + handlers known; weapon/
  consumable/Amethyst/Arc-Wand fidelity; **LootGenerator draws one durability + one consumable from the
  correct tier** against real content).
- ✅ **MVP1 integration capstone** — `tests/test_mvp1_real_run.gd` (3 cases): `AIPlayerAgent` drives a full
  Pilgrim Floor 3 run against the **real** `ContentRegistry` + `RNGService`, start → Judge → `RUN_END`,
  deterministically (the stub-free `SCOPE-001` gate). A 30-seed progress check confirms rooms are cleared
  (enemies take damage and die, loot/navigation advance). `RunResult` gained `rooms_cleared` for this.
  Full suite **352/352**.
- **Decisions / flags:** (1) **Random agent doesn't win the floor** — across 30 seeds, runs clear ~2 rooms
  then die (diagnostics confirmed enemies die / the loop advances; not a bug). A purely random policy can't
  clear 9 rooms + the Judge with the Pilgrim's low damage; winnability needs a smarter agent — the MVP1
  gate is *deterministic completion*, not random victory. (2) **Frost Shard → Chilled** per `LLD-ITEMS-007`
  (its explicit scenario). ✅ **Resolved** (2026-06-24): removed the stale Frost Shard → Vulnerable (Ice)
  example from `HLD-COMBAT-007` and dropped Frost Shard from the Vulnerable (Ice) "pairs with" list in
  `LLD-OMEN-CARD-016` — Chilled no longer co-applies Vulnerable, and Frost Shard only applies Chilled.
  (3) **Small/Medium
  Amethyst** are Support (durability) so they auto-decrement per encounter (1/2 charges) — a single-
  encounter cleanse window, consistent with `LLD-ITEMS-002`. (4) Offensive-consumable auto-targeting is an
  MVP1 simplification (MVP2 adds real target selection).

### T8.7 — Item score table sanity pass  ✅ **Done**
Verify every MVP1 item's authored `score` matches `LLD-ITEMS-011` / `LLD-IR` formulas.
- **@Spec (schema/validator):** `LLD-ARCH-018`, `HLD-ITEMS-006`/`-007`/`-008`, `LLD-ITEMS-011`
- ✅ `tests/test_item_scores.gd` — 3 cases pinning all **25** MVP1 items' shipped `score` (read via
  ContentRegistry) to the canonical `LLD-IR-011` values, asserting every item is `breaks_at_zero`, and that
  the three vessel abilities (throw_rock / read_the_road / good_as_new) carry `score` 0 and are not items.
  All authored scores match the spec table (no drift). Full suite **355/355**.

---

**Phase 8 complete.** ✅ All MVP1 content authored and validated: the Pilgrim + abilities (T8.1), starting
items (T8.2), 13 Floor 3 enemies (T8.3), the Judge + Witnesses (T8.4), 18 omen cards (T8.5), 22 loot items
+ pool finalization (T8.6), and the score sanity pass (T8.7). The **MVP1 definition of done is met**:
`AIPlayerAgent.run_to_completion(seed, "pilgrim")` executes a full, deterministic, headless Floor 3 run
against the real content registry (`tests/test_mvp1_real_run.gd`). Remaining: the light **Phase 9** debug
hooks. Outstanding flags (none block MVP1): Chilled per-tick step cadence (T5.3/T8.5), Sacred Ground /
Totem aura doubling + Fanatic-Totem mixed encounters (MVP3), offensive-consumable + Good-as-New target
selection (MVP2 UI), and a smarter (non-random) agent for winnability. *(The spec-hygiene SHALL/MUST +
Purpose lint debt was cleared 2026-06-24 — all 23 specs pass `openspec validate --strict`.)*

---

## Phase 9 — MVP1 Debug Affordances (light)

### T9.1 — Headless debug hooks gated on `GameConfig.DEBUG`  ✅ **Done**
Minimal for headless: seed display/override, RNG stream call-count monitor, force-enemy-intent,
force-loot-drop, set-HP — exposed as code-path hooks (no UI yet). All gated on `DEBUG`.
- **@Spec:** `LLD-ARCH-014`
- **DoD:** hooks active only when `DEBUG`; off by default; no separate build.
- ✅ `src/application/debug_hooks.gd` (`DebugHooks`, static toolkit, Application layer) — every method is a
  no-op unless `GameConfig.DEBUG`: `set_unit_hp` (force-set HP on **any** unit — player or enemy, clamped),
  `keep_player_alive` (full-restore the vessel), `force_enemy_intent`, `force_loot_offers`,
  `rng_stream_counts` (the RNG monitor, via `RNGService.get_call_count`), `active_seed` (seed display). The
  toolkit is called by the harness / a future debug UI; the engine never calls into it, so normal play is
  unaffected.
- ✅ Supporting changes: `GameConfig.DEBUG` is now a settable `var` (still the single flag — the spec's
  "set … for export" wording implies settable; also lets tests toggle debug paths). `CombatResolver` gained
  an inert `debug_forced_intent` field (set only via the DEBUG-gated `force_enemy_intent`) honored at the top
  of `_select_intent` — Domain stays autoload-free.
- ✅ `tests/test_debug_hooks.gd` — 7 cases (inert when DEBUG off; set-HP player+enemy+clamp; keep-alive;
  force-loot; force-intent overrides the roll; RNG counts + seed). Plus `test_mvp1_real_run.gd`
  `test_invincible_run_clears_whole_floor`: with `keep_player_alive` each turn the random agent traverses
  all 9 rooms and **beats the Judge** (`outcome == "completion"`) — the "keep the player alive to exercise
  every room" use case, proving the whole floor is reachable/clearable. Full suite **363/363**.

---

**Phase 9 complete — MVP1 is done.** ✅ `AIPlayerAgent.run_to_completion(seed, "pilgrim")` executes a full,
deterministic, headless Floor 3 run start → Judge → `RUN_END` on the real content registry, all systems
(combat, omen, status, loot, navigation, burden, companion, debug) functional and unit-tested (363 green).
This satisfies the MVP1 definition of done (`SCOPE-001`). Carry-forward (none block MVP1; MVP2/MVP3 + a
spec-hygiene pass): Chilled per-tick step cadence, Sacred Ground/Totem doubling + Fanatic-Totem mixed
encounters, item/ability target *selection* UI, and a non-random agent for unaided winnability. *(The
SHALL/MUST + Purpose spec-lint debt was cleared 2026-06-24 — all 23 specs pass `openspec validate
--strict`.)*

---

# MVP2 — Playable with UI (`SCOPE-002`) — *outline*

All MVP1 systems plus the full Presentation layer on desktop. Detail in a later pass. Major epics:

- **P-UI.1 Presentation foundation** — portrait-first layout, anchor/Container-based UI, abstract
  input actions, `ScreenManager` real scene transitions, headless self-disable on all nodes.
  (`LLD-PLATFORM-001`, `-002`, `-003`, `LLD-ARCH-002`)
- **P-UI.2 Combat screen** — enemy/player/companion layout, action bar, omen display, enemy intent
  display, status visualisation, visual-first feedback for every event. (`HLD-COMBAT-009`,
  `LLD-PLATFORM-001`, `-004`)
- **P-UI.3 Navigation & inventory UI** — door symbols + look-ahead, inventory (charges, floor-bound
  marks, encounter-countdown counters), loot selection screen. (`HLD-RUN-001`, `-002`, `HLD-DOOR-*`,
  `HLD-ITEMS-002`, `-003`)
- **P-EVT.1 Non-combat events + `TradeGenerator`** — Memory Fragment (Cat A/B/C), Wandering Soul,
  Elite Gate; `ACCEPT_TRADE`/`DECLINE_TRADE`/`ACCEPT_OPTION_*` actions; HP-bucket resolution
  (`[OPEN·MVP2]`). (`LLD-ARCH-021`, `hld-wandering-soul`, `hld-memory-fragments`, `LLD-IR-009/-010`)
- **P-OPEN.1 Resolve MVP2 open items** — symbol visual language (`HLD-RUN-002`, `HLD-DOOR-005`), HP
  bucket amounts (`HLD-ITEMS-011`).
- **DoD:** a human completes a full Pilgrim Floor 3 run through the UI with no missing interaction
  (`SCOPE-002`).

---

# MVP3 — Floor 2 + Tier 2 Vessels (`SCOPE-003`) — *outline*

- **Vessels:** Drifter (Hardy, Ferret bound companion) and Hedge Knight (Last Stand, Charge),
  starting items and vessel omen cards. Implements the `[OPEN·MVP3]` handlers: `apply_buff`
  (Charge), `remove_status`/Hardy-clearable flag (Hardy), passive Last-Stand modifier.
  (`LLD-VESSELS-002/-003`, `LLD-ABILITIES-006/-007/-008`, `LLD-ITEMS-009/-010`, `LLD-OMEN-CARD-007/-009/-010`)
- **Floor 2:** Blurred Deep (Hedge Knight) / Unmarked Edge (Drifter) — enemy pools, generation,
  floor omen cards, FloorProfiles.
- **Run structure:** two-floor runs (Floor 2 → Floor 3); vessel unlock on Pilgrim completion.
  (`HLD-VESSEL-003`, `HLD-RUN-004` intermediate bosses)
- **DoD:** full 2-floor run completable with either Tier 2 vessel (`SCOPE-003`).

---

# MVP4 — Tier 3 Vessels + Full Run (`SCOPE-004`) — *outline*

- **Vessels:** Paladin, Battle Wizard, Shaman (spirit animal), Ranger (Bear) — full ability sets,
  starting items, vessel omen cards; possible additional damage types (`HLD-COMBAT-005` `[OPEN·MVP4]`).
- **Floor 1 origin floors:** Crypt/Catacomb and Contested Wilderness.
- **Run structure:** three-floor runs (Floor 1 → 2 → 3); extended unlock tree.
- **Web export prep:** resolve PersistenceService localStorage/IndexedDB backend
  (`LLD-PLATFORM-005` `[OPEN·MVP4]`).
- **DoD:** full 3-floor run completable with any of the seven vessels (`SCOPE-004`).

---

## Cross-cutting reminders for every session

- Re-read the cited `@Spec` requirements before editing a tagged class/method. If your change makes
  a spec inaccurate, update the spec via the OpenSpec propose/apply/archive cycle first (or flag it).
- Keep the domain layer Node-free and headless-flag-free.
- Every new `handler_id` must be registered and pass startup validation.
- Add/extend the GdUnit4 suite in the same task as the code it covers.
- Run the headless determinism integration test (T7.2) after any change to RNG, CombatResolver,
  generators, or RunController.

---

## Appendix A — HLD Coverage Matrix

Every HLD requirement, mapped to where it is realised. This is the authoritative check that nothing
is silently dropped. **MVP1** = covered by an MVP1 task; **MVP2/3/4** = deferred to that milestone's
outline; **Design-framing** = a narrative/design constraint with no direct code task (it shapes
content and atmosphere, not engine behaviour — listed so it is consciously acknowledged, not missed).

### hld-combat-system
| Req | Covered by |
|---|---|
| HLD-COMBAT-001 Turn-Based Only | MVP1 — intrinsic to T5.x (no real-time loop); design-framing |
| HLD-COMBAT-004 Action Economy | MVP1 T5.1 |
| HLD-COMBAT-005 Damage Types | MVP1 T4.2, T5.2 |
| HLD-COMBAT-006 Status Effects | MVP1 T4.2, T5.3 |
| HLD-COMBAT-007 Vulnerability | MVP1 T5.2 |
| HLD-COMBAT-008 Omen System (pointer) | MVP1 T5.4 |
| HLD-COMBAT-009 Enemy Intent | MVP1 T5.5 |
| HLD-COMBAT-010 Cleanse | MVP1 T4.2 (`cleanse_status`) |
| HLD-COMBAT-011 Default Strike | MVP1 T5.1, T8.1 (Throw Rock) |
| HLD-COMBAT-012 Post-Combat Loot | MVP1 T6.3 |
| HLD-COMBAT-013 Elite Combat Rewards | MVP1 T6.3 |
| HLD-COMBAT-014 Charge→Release | MVP1 T5.5 |
| HLD-COMBAT-015 Chilled Idempotency | MVP1 T5.3 |
| HLD-COMBAT-016 Enemy Damage Variance | MVP1 T5.2, T5.5 |
| HLD-COMBAT-017 Evade | MVP1 T5.1, T5.2, T5.6 |
| HLD-COMBAT-018 Magnitude-Additive Reapply | MVP1 T5.3 |
| HLD-COMBAT-019 Max-Wins Reapply | MVP1 T5.2, T5.3 |

### hld-omen-system
| Req | Covered by |
|---|---|
| HLD-OMEN-001 Three-Card Draw | MVP1 T5.4 |
| HLD-OMEN-002 Timer/Status Interaction | MVP1 T5.3, T5.4 (timer drives `remaining_ticks`) |
| HLD-OMEN-003 Deck Reshuffle | MVP1 T5.4 |
| HLD-OMEN-004 Four-Source Assembly | MVP1 T5.4 |
| HLD-OMEN-005 Application Model | MVP1 T5.4 |
| HLD-OMEN-006 Two-Tier Enemy Contribution | MVP1 T5.4, T5.7 |

### hld-run-structure
| Req | Covered by |
|---|---|
| HLD-RUN-001 Corridor Navigation | MVP1 T6.2 (logic); MVP2 P-UI.3 (look-ahead UI) |
| HLD-RUN-002 Door Symbols | MVP2 P-UI.3 (symbols are visual) |
| HLD-RUN-004 Boss Structure (Judge final) | MVP1 T6.2, T8.4 |
| HLD-RUN-005 Room Composition (FloorProfile) | MVP1 T6.2 |
| HLD-RUN-006 Floor Transition | MVP1 T6.4, T6.6 |
| HLD-RUN-007 Item Burden Score | MVP1 T6.1, T6.4, T5.6 |
| HLD-DOOR-001 Two-Door Choice | MVP1 T6.2 |
| HLD-DOOR-002 Combat Doors — Enemy Identity | MVP1 T6.2 (data); MVP2 (display) |
| HLD-DOOR-003 Non-Combat Doors — Symbol | MVP2 P-EVT.1 / P-UI.3 |
| HLD-DOOR-004 Pool Exhaustion Both-Doors | MVP1 T6.2 |
| HLD-DOOR-005 Non-Combat Symbol Language | MVP2 P-OPEN.1 (`[OPEN·MVP2]`) |

### hld-item-system
| Req | Covered by |
|---|---|
| HLD-ITEMS-001 No Inventory Cap | MVP1 T6.1 |
| HLD-ITEMS-002 Floor-Bound Item Flag | **Deferred** — no MVP1 item is floor-bound; engine flag + expiry at MVP2 when relevant content appears (flagged below) |
| HLD-ITEMS-003 Encounter-Countdown | MVP1 T6.6 (Worn Map) |
| HLD-ITEMS-004 Categories/Action Buckets | MVP1 T3.1, T5.1 |
| HLD-ITEMS-005 Durability Decrement Rules | MVP1 T3.1, T6.1 |
| HLD-ITEMS-006 Two Scoring Scales | MVP1 T8.7 (authoring); MVP2 TradeGenerator |
| HLD-ITEMS-007 Compositional Scoring | MVP1 T8.7 (authoring worksheet) |
| HLD-ITEMS-008 Competent-Play Baseline | MVP1 T8.7 (authoring) |
| HLD-ITEMS-009 Trade Fairness Tolerance | MVP2 P-EVT.1 (TradeGenerator) |
| HLD-ITEMS-010 Cross-Category Trade Policy | MVP2 P-EVT.1 |
| HLD-ITEMS-011 HP Conversion Concept | MVP2 P-EVT.1 / P-OPEN.1 (`[OPEN·MVP2]`) |

### hld-vessel-system
| Req | Covered by |
|---|---|
| HLD-VESSEL-001 Vessel as Class | MVP1 T8.1 (fixed ability set) |
| HLD-VESSEL-002 Vessel Identity | Design-framing / content (T8.1 lore fields) |
| HLD-VESSEL-003 Unlock Conditions | MVP3 (unlock system) |
| HLD-VESSEL-007 Hierarchy & Narrative Tree | MVP3/MVP4 + design-framing |

### hld-companion-system
| Req | Covered by |
|---|---|
| HLD-COMPANION-001 Two-Tier System | MVP1 T6.6 (temporary); bound companions MVP3 |
| HLD-COMPANION-003 Trigger Types | MVP1 T5.7, T6.6 |
| HLD-COMPANION-004 Temporary Limit | MVP1 T6.6 |

### hld-wandering-soul  (entire spec → MVP2 P-EVT.1)
HLD-WS-001..008 — Trade structure, types, HP-for-item guarantee, item-for-HP healing, no currency,
score fairness, no companion offers, post-elite guarantee. All **MVP2** (TradeGenerator + event UI).

### hld-memory-fragments  (entire spec → MVP2 P-EVT.1)
HLD-MF-001..005 — Door symbol, three-category weighted draw, Category A fair trade, companion
encounter, Category C unfair trade. All **MVP2**. (Note: HLD-MF-004 companion encounter is the
*Memory Fragment* companion source; the MVP1 Worn Map beat (T6.6) is the separate starting-item path.)

### hld-game-concept & hld-narrative  (design-framing)
| Req | Status |
|---|---|
| HLD-CONCEPT-001 Core Premise | Design-framing |
| HLD-CONCEPT-002 Setting | Design-framing |
| HLD-CONCEPT-003 Narrative Goal — Solace | Design-framing |
| HLD-CONCEPT-004 Run Length Target | MVP1 measurable via `LLD-FLOOR-STRUCT-002` (~30 min) |
| HLD-CONCEPT-005 Roguelite (Not Roguelike) | MVP1 persistence model (T6.5) + meta-progression (post-MVP) |
| HLD-NAR-001 Soul and Solace | Design-framing / content |
| HLD-NAR-002 The Guardian's Test | Design-framing (realised by the Judge, T8.4) |
| HLD-NAR-003 Floor Atmosphere Degradation | MVP2+ presentation / content |

### Open flags surfaced by this matrix
1. **HLD-ITEMS-002 Floor-Bound flag** has no MVP1 content instance. Decide: build the engine flag now
   (cheap, in T3.1/`ItemInstance`) or defer to MVP2 when a floor-bound item exists. Recommend building
   the data field now, wiring expiry at MVP2.
2. ✅ **Resolved** — starting-item-count vs burden-init contradiction (change `fix-pilgrim-burden-init`):
   `LLD-ARCH-017` now matches `LLD-ITEMS-004` (Pilgrim: 3 starting items → burden init 3). `HLD-RUN-007`
   was already correct (its 2-item scenario is a generic illustration).
3. **HLD-COMBAT-005 `[OPEN·MVP4]`** additional damage types — out of MVP1–3 scope.

---

## Appendix B — Technical Debt

Spec changes (via the OpenSpec propose/apply/archive cycle) that alter behavior already
represented in code, or that a not-yet-written system must account for once built. Each entry
notes what changed, what code is or will be affected, and whether it's actionable now or blocked
on a future task. Remove an entry once its code sync lands.

| Change | Spec(s) touched | Code impact | Status |
|---|---|---|---|
| `remove-companion-swap` | `hld-memory-fragments` (`HLD-MF-004`), `lld-floor` (`LLD-FLOOR-BEATS-003`) | No code to fix today — the swap fallback was never implemented (T6.6 only ever coded the Worn Map's *after-the-fact* `companion_offered_this_floor` flag in `navigation_state.gd`/`run_controller.gd`; no Memory Fragment generator exists yet to have coded the swap itself). Forward-looking: when the MVP2 Memory Fragment generator (`HLD-MF-002` category draw) is built, it MUST exclude the Companion Encounter category whenever the player holds an unfired Worn Map, not only after `companion_offered_this_floor` is true. | Blocked on Memory Fragment generator task (MVP2) — implement the exclusion check there directly; no separate follow-up task needed. |
