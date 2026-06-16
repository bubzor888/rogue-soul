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

### T0.1 — Repository structure & layer skeleton
Create the `src/{infrastructure,domain,application,presentation}` and `data/*` and `tests/`
directory tree above. Add a short `src/README.md` restating the four-layer rule and `@Spec`
convention so it's discoverable in-tree.
- **@Spec:** `LLD-ARCH-001`
- **DoD:** directories exist; no logic yet; committed.

### T0.2 — Install & wire GdUnit4 v6.1.x  *(prerequisite; may need human action)*
Install GdUnit4 v6.1.x as a Godot plugin (Asset Store / addon), enable it, and confirm a trivial
headless test runs from the command line producing JUnit XML. Document the exact headless test
command in `tests/README.md`.
- **@Spec:** `LLD-ARCH-015`
- **DoD:** `runtest` headless command green on an empty sample test; command documented.
- **Note:** plugin install is a manual editor step — flag to the human if it can't be scripted.

### T0.3 — `GameConfig` autoload
Infrastructure autoload holding `HEADLESS`, `DEBUG`, `SAVE_VERSION`, and global constants. No logic.
- **@Spec:** `LLD-ARCH-007`, `LLD-ARCH-002`, `LLD-ARCH-010`, `LLD-ARCH-014`
- **DoD:** autoload registered; flags readable; defaults set (`HEADLESS=true` for MVP1 dev runs).

---

## Phase 1 — Infrastructure Autoloads

### T1.1 — `RNGService` (TDD)  ⭐ mandated test system
Named-stream RNG: `NAVIGATION`, `COMBAT`, `LOOT`, `EVENTS`. Each stream is a `RandomNumberGenerator`
seeded `base_seed + stream_index`. Public `roll(stream)` / helpers; seed injection at run start.
Write `tests/test_rng.gd` first: determinism from seed, stream independence (no cross-contamination),
pre-computed expected sequence.
- **@Spec:** `LLD-ARCH-008`, `LLD-ARCH-015`
- **DoD:** all RNG tests green; no direct `randf()` anywhere.

### T1.2 — `SignalBus` autoload
Infrastructure global signal bus declaring the full MVP1 signal catalogue from `LLD-ARCH-009`
(`phase_changed`, `save_requested`, `combat_started/ended`, `turn_started`, `action_resolved`,
`damage_dealt`, `status_applied/cleared`, `unit_died`, `omen_drawn/applied`, `item_broken/
discarded/acquired`, `room_entered`, `floor_transitioned`). Signals only — no logic.
- **@Spec:** `LLD-ARCH-009`, `LLD-ARCH-007`
- **DoD:** all listed signals declared with correct payload types.

### T1.3 — `EventLog` autoload (TDD)  ⭐ mandated test system
Structured newline-delimited JSON recorder. Connects to `SignalBus` signals (domain never calls
EventLog directly). In-memory buffer; flush at floor transition / boss completion / run end.
Categories per `LLD-ARCH-013`. RNG-roll events only when `GameConfig.DEBUG`. Writes via
`PersistenceService` to `user://logs/run_<seed>_<timestamp>.jsonl`. Records `run_started`/`run_end`
meta events with seed. Write `tests/test_event_log.gd` first.
- **@Spec:** `LLD-ARCH-013`, `LLD-ARCH-008` (seed recording), `LLD-ARCH-015`
- **DoD:** event format valid/parseable; buffer flush at checkpoints; debug-gated RNG logging; tests green.
- **Dependency:** needs T1.4 (PersistenceService) for actual file writes — can stub then wire.

### T1.4 — `PersistenceService` autoload
Sole `FileAccess` abstraction. JSON read/write, `user://logs/` and save paths, `SAVE_VERSION`
stamping, and a migration hook (`LLD-ARCH-010`). Migration table can start empty.
- **@Spec:** `LLD-ARCH-007`, `LLD-ARCH-010`
- **DoD:** read/write round-trips; version stamped; migration entry-point present.

---

## Phase 2 — Domain Data Model

### T2.1 — Data resource schemas (`LLD-ARCH-018`)
Define `Resource` subclasses with `@Spec` annotations for every content schema: `AbilityData`
(shared by items), `HandlerConfig`, `VesselData`, `EnemyData`, `IntentWeight`, `IntentConditional`,
`OmenCardData`, `CompanionData`. Every field JSON-serialisable. Include the colon-encoding
convention note for parameterized statuses in `AbilityData`/`OmenCardData` doc comments.
- **@Spec:** `LLD-ARCH-018`, `LLD-ARCH-006`
- **DoD:** all schema classes compile; fields match the spec tables exactly.

### T2.2 — `GameState` + sub-Resources with serialisation (TDD)  ⭐ mandated test system
Implement `GameState` and all sub-Resources from `LLD-ARCH-017`: `VesselState`, `ItemInstance`,
`AbilityState`, `StatusInstance`, `CompanionState`, `NavigationState`, `DoorData`, `CombatState`,
`EnemyState`, `OmenDeckState`, `OmenCycleState`. Implement `clone()`, `to_json()`, `from_json()`.
Define the `RunPhase` enum. Write `tests/test_game_state.gd` first: round-trip serialisation
identity; clone independence; field-level defaults (e.g. `is_evading` resets, `string_param` "").
- **@Spec:** `LLD-ARCH-017`, `LLD-ARCH-004`, `LLD-ARCH-015`
- **DoD:** round-trip and clone tests green; all fields present with correct types/defaults.

---

## Phase 3 — Registries, Charge Management & Constants

### T3.1 — `ReplenishEvents` constants + `ChargeManager` (decrement asymmetry)
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

### T3.2 — `ContentRegistry` autoload (single registry, directory scan + startup validation)
One `ContentRegistry` autoload (the **8th autoload**, see registries note above) owning sub-registries
`AbilityRegistry`, `VesselRegistry`, `ItemRegistry`, `EnemyRegistry`, `OmenCardRegistry`,
`CompanionRegistry` (as needed for MVP1). At engine boot it scans each `data/` subdir, indexes by id,
and a validator verifies every `handler_id` in every chain resolves — unknown ids are a **fatal
startup error**. RunController/CombatResolver read `ContentRegistry` for lookups; they never own or
rebuild it.
- **@Spec:** `LLD-ARCH-006`, `LLD-ARCH-005`, `LLD-ARCH-007` (autoload list extension)
- **DoD:** placing a `.tres` makes content discoverable with no code change; unknown handler id aborts startup at boot.

---

## Phase 4 — Ability Pipeline & Handlers

### T4.1 — `AbilityPipeline` + `AbilityHandler` base + handler registry
Chain-of-Responsibility executor: an ability/item is an ordered `Array[HandlerConfig]`; handlers
run left-to-right over a shared context (`game_state`, source, target, params). Base class +
registry keyed by `handler_id`. Enforce naming convention (`DealDamageHandler` → `"deal_damage"`).
- **@Spec:** `LLD-ARCH-005`, `LLD-ARCH-012`
- **DoD:** a 2-handler test chain executes in order; registry resolves ids.

### T4.2 — Concrete handlers for MVP1
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

> Note: `apply_buff` (Charge), `remove_status` (Hardy), passive Last-Stand modifier are `[OPEN·MVP3]`
> — defer. The damage resolver's Charge/Last-Stand multiplier *hooks* are built in T5.2 but unused in MVP1.

---

## Phase 5 — CombatResolver (the core engine) ⭐ mandated test system

`CombatResolver` is a `RefCounted` in `src/domain/`, takes `RNGService` as a constructor dependency,
never touches autoloads except emitting on `SignalBus` (`LLD-ARCH-019`). Build `tests/
test_combat_resolver.gd` incrementally alongside each sub-task. Split across sessions:

### T5.1 — Legal-action generation & gating
`get_legal_combat_actions()` with the priority-ordered gating from `LLD-ARCH-019`:
(1) `read_the_road_active` → only `READ_THE_ROAD_COMMIT`; (2) `pending_repent_slots` → only
`REPENT_DISCARD`; (3) otherwise the action-bucket set — Default Strike always legal, Evade always
legal, ability/item actions, `is_stunned` excludes Action bucket. Always returns ≥1 action.
- **@Spec:** `LLD-ARCH-019`, `LLD-ARCH-003`, `HLD-COMBAT-004`, `HLD-COMBAT-011`, `HLD-COMBAT-017`
- **DoD:** scenarios from `LLD-ARCH-019` (gating priority, stun exclusion, zero-charge fallback) green.

### T5.2 — Damage resolution order
The 7-step (0–7) pipeline from `LLD-ARCH-019`: evade miss → base+type (with Type Convert override)
→ Emboldened flat → Last Stand ×1.5 → Charge ×2 / Emboldened elemental ×1.5 → resistance ×0.5 →
vulnerability ×1.5 → resistance+vuln cancel. Player damage flat, enemy damage rolled on COMBAT.
- **@Spec:** `LLD-ARCH-019`, `HLD-COMBAT-005`, `-007`, `-016`, `-017`, `-018`, `-019`
- **DoD:** the worked scenarios (Last Stand+Charge+Vuln=31; resistance cancels vuln; type-convert
  interactions; Hardened absorption to 0) green; 0-HP clamp + `unit_died` (no negative HP).

### T5.3 — Status tick & shift resolution
`resolve_omen_tick` (tick-trigger effects fire: Burning/Chilled/Poisoned/Mending/Hardened/Bleed;
decrement all; clear expired tick statuses) and `resolve_omen_cycle_start` shift handling
(`death_mark`→`shocked`→`exposed` order per `LLD-ARCH-023`; deferred Vulnerable application).
- **@Spec:** `LLD-ARCH-019`, `LLD-ARCH-023`, `HLD-COMBAT-006`, `-015`, `-018`, `-019`
- **DoD:** Bleed decay sequence, Poison tripling, Chilled accumulation, shift ordering scenarios green.

### T5.4 — Omen system: assembly, draw cycle, timers, reshuffle
`assemble_omen_deck` (four sources, timer assignment via COMBAT per `LLD-OMEN-MECH-008/-009`, then
passive handler pass that may set `read_the_road_active`); three-card draw cycle (player-choice +
random + timer card per `HLD-OMEN-001`); deck reshuffle (`HLD-OMEN-003`); two-tier enemy
contribution & removal (`HLD-OMEN-006`); per-unit / tag-conditional application (`HLD-OMEN-005`).
- **@Spec:** `HLD-COMBAT-008`, `HLD-OMEN-001`..`-006`, `LLD-OMEN-MECH-008`, `-009`, `LLD-ARCH-019`
- **DoD:** deck composition, timer distribution, reshuffle, tier-1/tier-2 removal scenarios green.

### T5.5 — Enemy turns & intent engine
`resolve_enemy_turns`: per-enemy reset, Charge→Release continuation, intent_conditionals (forced
`intent_id` / restricted `intent_ids`), weighted COMBAT roll, consecutive cap re-roll, evade,
multi-hit, `status_apply` (+magnitude rules), custom `handlers`, `summon_enemy_id`. Plus
`resolve_enemy_summon` (inject family card) and `turns_alive` tracking.
- **@Spec:** `HLD-COMBAT-009`, `-014`, `-016`, `LLD-ARCH-019`, `LLD-ARCH-018`
- **DoD:** weighted/conditional/consecutive/charge-release/summon/multi-hit scenarios green.

### T5.6 — Player action resolution
`resolve_player_action` for standard actions (flag resets, Evade, AbilityPipeline run, evade-miss
charge preservation, burden updates) plus the two interactive resolutions `READ_THE_ROAD_COMMIT`
and `REPENT_DISCARD` (item removal, 5 HP heal, burden −1, `item_discarded` emit).
- **@Spec:** `LLD-ARCH-019`, `LLD-ARCH-003`, `HLD-COMBAT-017`, `HLD-RUN-007`, `LLD-OMEN-CARD-020`
- **DoD:** Repent (0/1/2+ items) and Read-the-Road splice scenarios green; charge preservation correct.

### T5.7 — Enemy death, companion triggers, death intercept
`resolve_enemy_death` (omen card removal + `on_death_apply_to_player` + `on_death_summons`),
`resolve_companion_trigger` (turn_end), `check_vessel_death_intercept` (synchronous, pre-`unit_died`).
- **@Spec:** `LLD-ARCH-019`, `HLD-OMEN-006`, `HLD-COMPANION-003`, `LLD-ARCH-018`
- **DoD:** Witness/Plague-Rat on-death status, Lightning Elemental spark summon, intercept scenarios green.

---

## Phase 6 — Application Orchestration

### T6.1 — `ActionInjector` (TDD)  ⭐ mandated test system
Single entry point for all decisions. `get_legal_actions()` (combat + navigation + loot phases),
`submit_action()` (validates against legal set; illegal → log + unchanged state, no throw). Handles
attack-item per-use charge decrement (`HLD-ITEMS-005`) / break + `item_broken` emit + burden −1, and
item acquisition (no inventory cap, burden +2 — `HLD-ITEMS-001`, `HLD-RUN-007`).
Write `tests/test_action_injector.gd`.
- **@Spec:** `LLD-ARCH-003`, `LLD-ARCH-011`, `LLD-ARCH-009`, `HLD-RUN-007`, `HLD-ITEMS-001`, `HLD-ITEMS-005`, `LLD-ARCH-015`
- **DoD:** legal-set correctness, illegal-action safety, item-break flow, no-cap acquisition scenarios green.

### T6.2 — `FloorProfile` + `NavigationModel` (Floor 3 generation)
Data-driven `FloorProfile` resource (`HLD-RUN-005`). Counter-based 9-room generation for Floor 3:
4 pre-elite, Elite Gate at room 5, 4 post-elite, then Judge; two-door choice with full enemy
identity; pool exhaustion both-doors rule; segment caps; the Judge is the fixed final-floor boss
(`HLD-RUN-004`). **MVP1: combat/elite/boss + Worn Map beat only** (MF/WS deferred). Uses NAVIGATION
stream.
- **@Spec:** `HLD-RUN-004`, `HLD-RUN-005`, `HLD-DOOR-001`..`-004`, `LLD-FLOOR-STRUCT-001/-006`, `LLD-FLOOR-PATT-001/-002/-003`, `LLD-ARCH-008`
- **DoD:** deterministic 9-room sequences; Elite Gate fixed at 5; Judge at end; caps respected.

### T6.3 — `LootGenerator`
Two-item offer (one durability, one consumable) from normal vs elite pools by encounter tier;
empty-pool fallbacks; LOOT stream only.
- **@Spec:** `LLD-ARCH-022`, `HLD-COMBAT-012`, `-013`, `LLD-ARCH-008`
- **DoD:** elite vs normal pool separation; one-of-each; LOOT-stream-only scenarios green.

### T6.4 — `RunController` (orchestrator)
Application-layer node (not autoload). Phase state machine (`NAVIGATION`, `COMBAT`,
`LOOT_SELECTION`, `NON_COMBAT_EVENT` [stub for MVP1], `FLOOR_TRANSITION`, `RUN_END`). Fires
replenishment events to ChargeManager; emits `save_requested` (BACKGROUND after door, CHECKPOINT
after boss); floor transition (full HP restore, temporary companion departs); initializes and
maintains `item_burden_score`; wires loot selection. Communicates only via SignalBus.
- **@Spec:** `LLD-ARCH-016`, `LLD-ARCH-007`, `HLD-RUN-006`, `HLD-RUN-007`, `LLD-ARCH-009`
- **DoD:** full phase walk fires correct signals/replenishments; burden lifecycle correct; freed at run end.

### T6.5 — `SaveManager` + `ScreenManager` (headless-appropriate) 
`SaveManager` autoload reacts to `save_requested`, coordinates JSON save/load via
PersistenceService, offers resume/start-over on existing CHECKPOINT. `ScreenManager` autoload
reacts to `phase_changed` — **no-op/headless-safe for MVP1** (real scenes are MVP2) but the
subscription wiring exists.
- **@Spec:** `LLD-ARCH-007`, `LLD-ARCH-016`, `LLD-ARCH-010`
- **DoD:** background + checkpoint saves written and reloadable; resume/start-over branch works headlessly.

### T6.6 — Encounter-countdown system + Worn Map companion beat
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

---

## Phase 7 — AIPlayerAgent & Integration

### T7.1 — `AIPlayerAgent` (Random strategy)
`RefCounted` in `src/application/`. `play_turn()` picks uniformly at random from
`ActionInjector.get_legal_actions()` using its **own** local RNG (never RNGService).
`run_to_completion(seed, vessel_id)` → `RunResult`.
- **@Spec:** `LLD-ARCH-020`, `LLD-ARCH-003`
- **DoD:** completes a run headlessly; AI RNG never advances game streams.

### T7.2 — Full headless determinism integration test
End-to-end: run the same seed twice through `AIPlayerAgent` → identical `RunResult` (turns, loot,
outcome). This is the primary MVP1 integration gate.
- **@Spec:** `LLD-ARCH-020`, `LLD-ARCH-008`, `SCOPE-001`
- **DoD:** two runs of N seeds produce byte-identical RunResults; green in headless CI command.

---

## Phase 8 — MVP1 Content (data files — no engine code)

> All tasks here produce `.tres`/data only. No `@Spec` on data files; ensure the *schema* classes
> (Phase 2) carry the annotations. Each task's DoD includes "discovered by registry; handler ids
> resolve at startup; AIPlayerAgent run exercises it."

### T8.1 — The Pilgrim vessel + abilities
`pilgrim.tres` (`LLD-VESSELS-001`), Throw Rock (`LLD-ABILITIES-004`), Read the Road
(`LLD-ABILITIES-005`), Good as New (`LLD-ABILITIES-003`), Stillness vessel omen card
(`LLD-OMEN-CARD-006`).

### T8.2 — Pilgrim starting items
**Three** starting items per `LLD-ITEMS-004`: Walking Staff (attack durability), Spoiled Potion
(consumable, Poisoned), Worn Map (support durability / encounter-countdown), each with precomputed
`score` per `LLD-ITEMS-011`.
- ✅ **Resolved** (change `fix-pilgrim-burden-init`): `LLD-ARCH-017`'s burden-init scenario now agrees
  with `LLD-ITEMS-004` — the Pilgrim has **3** starting items → `item_burden_score` initializes to **3**
  (1 per starting item per `HLD-RUN-007`). Use 3 when setting the initial value in T6.4.

### T8.3 — Floor 3 enemies (non-boss)
Skeleton, Zombie, Plague Rat, Wolf, Bear, Fire/Ice/Lightning Elementals, Low/High HP Fanatics,
Buff/Absorption Totems (`LLD-ENEMIES-004`–`-008`, `-014`–`-020`), plus encounter structure
(`LLD-ENEMIES-009`).

### T8.4 — The Judge boss + Witnesses
`the_judge.tres` (`LLD-ENEMIES-010`) — the fixed final-floor boss (`HLD-RUN-004`), Witness of Mercy /
Vengeance (`LLD-ENEMIES-021/-022`), Repent card (`LLD-OMEN-CARD-020`). Verifies burden-tier handler
(T4.2) and Pass Judgment phase trigger.

### T8.5 — Omen cards (floor / enemy / shared)
Floor 3 default deck (`LLD-OMEN-CARD-008`), Exposed floor card (`-019`), enemy family/type cards
(`-011` Grave Knit, `-012` Thick Hide, `-013` Elemental Synergy, `-014` Sacred Ground), status
cards (Burning, Shocked, Chilled, Emboldened ×2, Vulnerable ×3, Mending — `-001`..`-005`, `-015`..`-018`),
number distribution (`LLD-OMEN-MECH-008`).

### T8.6 — Item drop pools + Floor 3 profile
Normal/elite durability and consumable pools (`LLD-ITEMS-005`–`-008`) and the Floor 3 `FloorProfile`
data (`lld-floor`). Confirm LootGenerator draws the right tiers.

### T8.7 — Item score table sanity pass
Verify every MVP1 item's authored `score` matches `LLD-ITEMS-011` / `LLD-IR` formulas.
- **@Spec (schema/validator):** `LLD-ARCH-018`, `HLD-ITEMS-006`/`-007`/`-008`, `LLD-ITEMS-011`

---

## Phase 9 — MVP1 Debug Affordances (light)

### T9.1 — Headless debug hooks gated on `GameConfig.DEBUG`
Minimal for headless: seed display/override, RNG stream call-count monitor, force-enemy-intent,
force-loot-drop, set-HP — exposed as code-path hooks (no UI yet). All gated on `DEBUG`.
- **@Spec:** `LLD-ARCH-014`
- **DoD:** hooks active only when `DEBUG`; off by default; no separate build.

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
