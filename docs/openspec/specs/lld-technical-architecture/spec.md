## Purpose
Defines the technical architecture of Soul Protocol — layer structure, domain entities, resource schemas, core systems, and combat resolver interface.
## Requirements
### Requirement: [LLD-ARCH-001] Four-Layer Architecture
The codebase SHALL follow a strict four-layer dependency rule. Inner layers never depend on outer layers. The rule is enforced by project structure and code review discipline (not by language access modifiers).

```
Presentation  →  Application  →  Domain  →  Infrastructure
```

| Layer | Godot Location | May depend on | Must not depend on |
|---|---|---|---|
| Infrastructure | `src/infrastructure/` + Autoloads | Nothing | Domain, Application, Presentation |
| Domain | `src/domain/` | Infrastructure only | Application, Presentation, Godot scene tree |
| Application | `src/application/` | Domain + Infrastructure | Presentation, Godot scene tree |
| Presentation | `src/presentation/` (scenes) | All layers | Nothing upward |

#### Scenario: Domain layer purity
- **WHEN** any domain class is implemented
- **THEN** it MUST NOT instantiate a Node or access the scene tree; it MUST extend RefCounted or Resource

---

### Requirement: [LLD-ARCH-002] Headless Execution
The game loop SHALL have zero dependency on rendering or input devices. Domain layer classes run in headless mode for simulation and testing.

**Rendering layer behaviour:** All rendering nodes and UI scenes MUST check `GameConfig.HEADLESS` at `_ready()` and either instantiate normally or skip entirely (call `queue_free()`). They do not receive data, emit signals, or take actions when headless is true.

**Domain layer constraint:** The domain layer (game loop, combat resolver, RNG, event log) MUST NOT check `GameConfig.HEADLESS`. These systems always run. Headless is a presentation concern, not a logic concern.

#### Scenario: AI player runs headless
- **WHEN** `GameConfig.HEADLESS` is true
- **THEN** a complete run can execute via AIPlayerAgent without any scene tree or display

#### Scenario: Rendering nodes self-disable
- **WHEN** `GameConfig.HEADLESS` is true and a rendering node initialises
- **THEN** that node calls `queue_free()` at `_ready()` and takes no further action — no data binding, no signal connections

#### Scenario: Domain layer never checks headless
- **WHEN** any domain class is implemented
- **THEN** it MUST NOT contain any reference to `GameConfig.HEADLESS` — the flag is invisible below the presentation layer

---

### Requirement: [LLD-ARCH-003] Action Command Pattern
All game decisions SHALL be serialisable Dictionary commands. ActionInjector is the single interface through which all decisions (from UI, AI, or debug tools) enter the game loop.

```
{ "type": "USE_ABILITY", "ability_id": "slash", "target_id": "enemy_0" }
{ "type": "USE_ITEM", "slot_index": 2, "target_id": "self" }
{ "type": "END_TURN" }
{ "type": "CHOOSE_DOOR", "room_id": "room_12" }
{ "type": "REPENT_DISCARD", "slot_index": N }
{ "type": "READ_THE_ROAD_COMMIT", "send_to_bottom": [N, ...] }
{ "type": "ACCEPT_TRADE", "offer_index": N }
{ "type": "DECLINE_TRADE" }
{ "type": "ACCEPT_OPTION_1" }
{ "type": "ACCEPT_OPTION_2" }
{ "type": "CHOOSE_LOOT", "item_id": "ember_shard" }
{ "type": "DECLINE_LOOT" }
```

`get_legal_actions()` MUST always return at least one valid action in a non-terminal state. `submit_action()` with an illegal action MUST log an error and return state unchanged — never throw.

**`REPENT_DISCARD` action:** Legal only when `combat_state.pending_repent_slots` is non-empty (see `LLD-ARCH-017`). `slot_index` must be one of the indices in `pending_repent_slots`. When `pending_repent_slots` is non-empty, `get_legal_combat_actions()` returns ONLY `REPENT_DISCARD` actions — one per pending slot — and no other action types. Resolving the action discards the item at that slot, heals the player 5 HP directly, decrements `item_burden_score` by 1, emits `SignalBus.item_discarded`, and clears `pending_repent_slots` (see `LLD-ARCH-019`).

**`READ_THE_ROAD_COMMIT` action:** Legal only when `combat_state.read_the_road_active` is `true` (see `LLD-ARCH-017`). `send_to_bottom` is an `Array[int]` of 0–3 indices into the top of the draw pile (0 = top card, 1 = second, 2 = third); an empty array means keep all in place. Duplicate indices and out-of-range indices are invalid. When `read_the_road_active` is `true`, `get_legal_combat_actions()` returns ONLY `READ_THE_ROAD_COMMIT` — no other action types. Resolving the action reorders the draw pile and clears `read_the_road_active` (see `LLD-ARCH-019`).

**`ACCEPT_TRADE` action:** Legal only in `NON_COMBAT_EVENT` phase when `navigation_state.event_type` is `"wandering_soul"` or `"mf_cat_a"` and `event_offers` is non-empty. `offer_index` must be a valid index into `navigation_state.event_offers`. Resolving the action applies the trade (pays give side, receives receive side per the TradeOffer Dictionary at that index), removes the accepted offer from `event_offers`, and emits `SignalBus.item_acquired` or equivalent. Multiple trades may be accepted in sequence (Wandering Soul allows accepting all offers); `get_legal_actions()` continues returning `ACCEPT_TRADE` for remaining offers and `DECLINE_TRADE` until `event_offers` is empty, at which point RunController transitions to `NAVIGATION`.

**`DECLINE_TRADE` action:** Legal in `NON_COMBAT_EVENT` phase when `event_type` is `"wandering_soul"` or `"mf_cat_a"`. Submitting this action means the player is done with the event (walks away from remaining offers). RunController clears `event_offers` and transitions to `NAVIGATION`. For `"mf_cat_a"` this represents walking away from the single fair-trade offer.

**`ACCEPT_OPTION_1` / `ACCEPT_OPTION_2` actions:** Legal only in `NON_COMBAT_EVENT` phase when `event_type` is `"mf_cat_c"`. `DECLINE_TRADE` is NOT legal in this event type — the player must choose one option (see `HLD-MF-005`). `ACCEPT_OPTION_1` resolves the bad deal (player pays the cost item, receives the reward item from Option 1). `ACCEPT_OPTION_2` resolves cutting losses (player pays the loss from Option 2, receives nothing). After either resolves, RunController transitions to `NAVIGATION`.

**`CHOOSE_LOOT` action:** Legal only in `LOOT_SELECTION` phase. `item_id` must be one of the two item_ids in `navigation_state.loot_offers`. Resolving the action adds the chosen item to the player's inventory (incrementing `item_burden_score` by 2; see `HLD-RUN-007`), emits `SignalBus.item_acquired`, clears `loot_offers`, and RunController transitions to `NAVIGATION`. If the inventory has no free slot, the item cannot be picked — `get_legal_actions()` excludes that offer (only `DECLINE_LOOT` is returned).

**`DECLINE_LOOT` action:** Legal in `LOOT_SELECTION` phase. The player walks away from both loot options with nothing. RunController clears `loot_offers` and transitions to `NAVIGATION`.

#### Scenario: Illegal action safety
- **WHEN** an illegal action is submitted to ActionInjector
- **THEN** the game state is unchanged and an error is logged; no exception is raised

#### Scenario: REPENT_DISCARD only legal when Repent choice is pending
- **WHEN** `combat_state.pending_repent_slots` is empty
- **THEN** `get_legal_combat_actions()` does not include any `REPENT_DISCARD` action; Default Strike, Evade, and other standard actions are returned normally

#### Scenario: Repent pending — only REPENT_DISCARD actions returned
- **WHEN** `combat_state.pending_repent_slots` is `[1, 2]` (slots 1 and 2 are revealed)
- **THEN** `get_legal_combat_actions()` returns exactly two `REPENT_DISCARD` actions with `slot_index: 1` and `slot_index: 2`; no other action types are included

#### Scenario: READ_THE_ROAD_COMMIT only legal during Read the Road
- **WHEN** `combat_state.read_the_road_active` is `false`
- **THEN** `get_legal_combat_actions()` does not include any `READ_THE_ROAD_COMMIT` action

#### Scenario: Read the Road active — only READ_THE_ROAD_COMMIT returned
- **WHEN** `combat_state.read_the_road_active` is `true`
- **THEN** `get_legal_combat_actions()` returns exactly one `READ_THE_ROAD_COMMIT` action; no other action types are included

#### Scenario: Wandering Soul — accept one offer, more remain
- **WHEN** the player submits `ACCEPT_TRADE { offer_index: 0 }` in a Wandering Soul event with 3 offers
- **THEN** that trade resolves; `event_offers` now has 2 entries; `get_legal_actions()` returns `ACCEPT_TRADE` for indices 0 and 1 plus `DECLINE_TRADE`

#### Scenario: Wandering Soul — decline ends event
- **WHEN** the player submits `DECLINE_TRADE` in a Wandering Soul event
- **THEN** RunController clears `event_offers` and transitions to `NAVIGATION` regardless of how many offers remain

#### Scenario: MF Cat C — no decline available
- **WHEN** the game is in `NON_COMBAT_EVENT` with `event_type: "mf_cat_c"`
- **THEN** `get_legal_actions()` returns only `ACCEPT_OPTION_1` and `ACCEPT_OPTION_2`; `DECLINE_TRADE` is not included

#### Scenario: CHOOSE_LOOT with full inventory
- **WHEN** the player is in `LOOT_SELECTION` and all 3 inventory slots are occupied
- **THEN** `get_legal_actions()` returns only `DECLINE_LOOT`; no `CHOOSE_LOOT` actions are included

#### Scenario: DECLINE_LOOT — walk away empty-handed
- **WHEN** the player submits `DECLINE_LOOT` in `LOOT_SELECTION` phase
- **THEN** no item is added to inventory; `loot_offers` is cleared; RunController transitions to `NAVIGATION`

---

### Requirement: [LLD-ARCH-004] GameState Immutability
GameState SHALL be treated as immutable by convention — methods return a new state rather than mutating in place. `GameState.clone()` is a first-class requirement.

GameState SHALL also be fully serialisable to and from JSON at any point during a run. `GameState.to_json() -> Dictionary` and `GameState.from_json(data: Dictionary) -> GameState` are required methods. This enables mid-run state snapshots for AI simulation, targeted testing from a specific state, and state diffing before and after an action.

#### Scenario: State branching for AI
- **WHEN** the AIPlayerAgent evaluates multiple action options
- **THEN** it can clone GameState and simulate each branch without side effects on the real game state

#### Scenario: GameState round-trip serialisation
- **WHEN** `GameState.to_json()` is called and the result is passed to `GameState.from_json()`
- **THEN** the deserialised state is identical to the original — all fields, statuses, and run state are preserved

#### Scenario: Mid-run snapshot
- **WHEN** a specific combat scenario needs to be reproduced for targeted testing
- **THEN** a JSON snapshot taken at any point in the run can be loaded to resume from that exact state

---

### Requirement: [LLD-ARCH-005] Ability Pipeline (Chain of Responsibility)
Vessel abilities and items SHALL both execute through the same AbilityPipeline using a Chain of Responsibility pattern. An ability/item is an ordered list of HandlerConfig entries. New vessel abilities are data files; new code is only required for genuinely novel effects.

#### Scenario: New vessel ability, no new code
- **WHEN** a new vessel ability is defined using only existing handlers
- **THEN** the new ability is a .tres data file only — no AbilityHandler subclass is written

#### Scenario: Handler startup validation
- **WHEN** the game starts
- **THEN** AbilityRegistry validates that every handler_id in every ability/item chain resolves to a known handler; unknown IDs are a fatal startup error

---

### Requirement: [LLD-ARCH-006] Registry + Data Files Pattern
VesselRegistry, ItemRegistry, and AbilityRegistry SHALL discover content via directory scan at startup. New content is added by adding files — no registration code required.

#### Scenario: New vessel added
- **WHEN** a new VesselData .tres file is placed in `data/vessels/`
- **THEN** the game discovers and loads it at startup without any code change

---

### Requirement: [LLD-ARCH-007] Autoloads
The following SHALL be implemented as Godot Autoloads (global singletons):

| Autoload | Layer | Role |
|---|---|---|
| GameConfig | Infrastructure | Environment flags (HEADLESS, DEBUG), global constants |
| RNGService | Infrastructure | All randomness via named streams; randf() is never called directly |
| EventLog | Infrastructure | Structured JSON event recorder; flushed at floor transitions |
| PersistenceService | Infrastructure | All FileAccess abstracted here |
| SignalBus | Infrastructure | Global signal bus for cross-cutting events; all layers may emit and connect |
| ScreenManager | Application | Owns all scene transitions; reacts to SignalBus.phase_changed |
| SaveManager | Application | Coordinates save/load; reacts to SignalBus.save_requested |

**RunController is NOT an autoload.** It is an Application-layer node instantiated when a run begins and freed when it ends (see `LLD-ARCH-016`). ScreenManager and SaveManager connect to its signals via SignalBus, not directly.

#### Scenario: No direct FileAccess
- **WHEN** any domain or application class needs to read/write files
- **THEN** it MUST call PersistenceService — never FileAccess directly

#### Scenario: SignalBus accessible from domain layer
- **WHEN** a domain class (e.g. CombatResolver) needs to emit a cross-cutting event
- **THEN** it emits on SignalBus — this is legal because SignalBus is Infrastructure, which Domain may depend on

---

### Requirement: [LLD-ARCH-008] RNG Streams
All randomness SHALL flow through RNGService named streams. The global `randf()` function is NEVER called anywhere in the codebase — calling it directly is a bug.

| Stream | Usage |
|---|---|
| NAVIGATION | Room sequence generation |
| COMBAT | Combat RNG (hit rolls, damage variance, enemy intent selection) |
| LOOT | Item drops, loot table rolls |
| EVENTS | Non-combat event outcomes, Memory Fragment content |

**Derived seed formula:** Each stream is a separate `RandomNumberGenerator` instance initialised with `base_seed + stream_index`. A single base seed fully determines a run; no need to store or display multiple seeds.

**Seed I/O:** The run seed SHALL be injectable at run start — a caller can pass a specific seed to reproduce a prior run. The seed SHALL be automatically written to the EventLog on run end (death or completion) in the format: `{ "event": "run_end", "data": { "seed": <value>, "vessel": <id>, "floor_reached": <n>, "outcome": "death|completion" } }`.

#### Scenario: Seeded reproducibility
- **WHEN** a run is started with the same seed
- **THEN** the same room sequence, combat outcomes, and loot drops are produced

#### Scenario: Stream independence
- **WHEN** a new RNG call is added to the COMBAT stream (e.g. a new proc mechanic)
- **THEN** NAVIGATION, LOOT, and EVENTS stream sequences are unaffected for the same seed

#### Scenario: No direct randf() calls
- **WHEN** any class requires a random value
- **THEN** it MUST call `RNGService.roll(<stream_name>)` — never `randf()` or `randi()` directly

#### Scenario: Seed recorded on run end
- **WHEN** a run ends by death or completion
- **THEN** the EventLog records the seed, vessel ID, floor reached, and outcome before the final flush

---

### Requirement: [LLD-ARCH-009] SignalBus Decoupling
SignalBus SHALL be an Infrastructure autoload. Domain code emits on SignalBus for cross-cutting events. Presentation code connects to SignalBus. Neither layer knows about the other.

**MVP1 signal catalogue:**

| Signal | Emitter | Payload | Consumers |
|---|---|---|---|
| `phase_changed(new_phase, old_phase)` | RunController | RunPhase enums | ScreenManager |
| `save_requested(save_type)` | RunController | SaveType enum | SaveManager |
| `combat_started(combat_state)` | RunController | CombatState | ScreenManager, EventLog |
| `combat_ended(outcome)` | RunController | String ("victory"\|"defeat") | ScreenManager, EventLog |
| `turn_started(turn_number)` | CombatResolver | int | Presentation |
| `action_resolved(action, result)` | CombatResolver | Dictionary, Dictionary | EventLog, Presentation |
| `damage_dealt(source_id, target_id, amount, type)` | CombatResolver | ids, int, String | EventLog, Presentation |
| `status_applied(unit_id, status_id, ticks)` | CombatResolver | ids, int | EventLog, Presentation |
| `status_cleared(unit_id, status_id)` | CombatResolver | ids | EventLog, Presentation |
| `unit_died(unit_id)` | CombatResolver | String | EventLog, Presentation |
| `omen_drawn(cards)` | CombatResolver | Array[String] | EventLog, Presentation |
| `omen_applied(card_id, side)` | CombatResolver | String, String | EventLog, Presentation |
| `item_broken(item_id, slot_index)` | ActionInjector | String, int | EventLog, SignalBus consumers |
| `item_discarded(item_id, slot_index)` | CombatResolver | String, int | EventLog |
| `item_acquired(item_id)` | RunController | String | EventLog |
| `room_entered(room_type, encounter_id)` | RunController | String, String | EventLog |
| `floor_transitioned(from_floor, to_floor)` | RunController | int, int | EventLog |

**`item_discarded` vs `item_broken`:** `item_broken` is emitted by ActionInjector when charge exhaustion destroys an item (the item's remaining_charges reached 0 and `breaks_at_zero: true`). `item_discarded` is emitted by CombatResolver when a player deliberately discards an item via Repent (see `LLD-OMEN-CARD-020`). Both trigger a burden score decrement of −1 (see `HLD-RUN-007`), but they are semantically distinct events logged under different EventLog entries. Neither event replaces the other.

#### Scenario: Domain-presentation decoupling
- **WHEN** CombatResolver applies damage
- **THEN** it emits `SignalBus.damage_dealt`; the presentation layer updates health bars without CombatResolver knowing any UI exists

#### Scenario: EventLog subscribes via SignalBus
- **WHEN** any logged event signal fires on SignalBus
- **THEN** EventLog's connected handler writes the event to the in-memory buffer — no domain class calls EventLog directly

#### Scenario: item_discarded emitted by CombatResolver on Repent resolution
- **WHEN** the player resolves a `REPENT_DISCARD` action and an item is removed from inventory
- **THEN** CombatResolver emits `SignalBus.item_discarded(item_id, slot_index)` before clearing `pending_repent_slots`; EventLog records the discard event in the `items` category

#### Scenario: item_broken and item_discarded are independent signals
- **WHEN** an item breaks due to charge exhaustion (ActionInjector) and separately a Repent discard occurs (CombatResolver) in the same combat
- **THEN** `item_broken` is emitted for the charge exhaustion; `item_discarded` is emitted for the Repent discard; no handler conflates the two

---

### Requirement: [LLD-ARCH-010] Save Format and Migration
Save data SHALL be stored as JSON for debuggability and forward compatibility. GameConfig.SAVE_VERSION is written to every save. Version mismatch on load triggers a migration path.

#### Scenario: Save version migration
- **WHEN** a save file with an older SAVE_VERSION is loaded
- **THEN** PersistenceService applies the appropriate migration function before returning data

---

### Requirement: [LLD-ARCH-011] Charge Management
ChargeManager SHALL handle all replenishment events for both abilities and items. Replenishment event IDs are plain strings defined as constants in ReplenishEvents. Items break at zero if `breaks_at_zero: true`. Abilities never break.

#### Scenario: Replenishment event fires
- **WHEN** RunController fires a replenishment event (e.g. "floor_start")
- **THEN** ChargeManager restores charges for all abilities/items whose replenish_triggers contains that event ID

#### Scenario: Item breaks at zero
- **WHEN** an item's remaining_charges reaches 0 and breaks_at_zero is true
- **THEN** ActionInjector removes the ItemInstance from the slot and emits SignalBus.item_broken

---

### Requirement: [LLD-ARCH-012] Handler Naming Convention
Handler class names SHALL be PascalCase with the suffix `Handler`. Their registered `handler_id` SHALL be snake_case matching the class name without the suffix. See `LLD-ARCH-005` for the AbilityPipeline architecture that consumes these handlers.

Example: `DealDamageHandler` → `"deal_damage"`, `ApplyStatusHandler` → `"apply_status"`

#### Scenario: Naming consistency
- **WHEN** a new handler is implemented
- **THEN** its class name is PascalCase ending in `Handler` and its registered handler_id is the snake_case equivalent; startup validation (per `LLD-ARCH-005`) fails if the ID is unregistered

---

### Requirement: [LLD-ARCH-013] Event Log
The EventLog autoload SHALL record every meaningful game event throughout a run as structured, newline-delimited JSON (one event object per line). The log is the primary diagnostic tool for manual playtesting, AI simulation analysis, and bug reproduction.

**Format:** Each event object MUST contain at minimum:
```
{ "tick": <int>, "category": <string>, "event": <string>, "data": { ... } }
```

**Event categories:**

| Category | Examples |
|---|---|
| navigation | Room entered, door chosen, floor transition |
| combat | Turn started, action taken, damage dealt/received, status applied, unit death |
| items | Item acquired, item used, item broken |
| companions | Companion summoned, companion departed |
| rng | Every roll: stream, call index, raw value, resolved outcome (debug mode only) |
| meta | Run started (seed, vessel), run ended (seed, vessel, floor, outcome) |

**Buffer and flush policy:** The EventLog MUST use an in-memory buffer during play. The buffer SHALL be flushed to file at: (1) every floor transition, (2) every boss completion, (3) run end (death or completion). This bounds data loss on crash to the current floor's events. Continuous per-event file I/O is NOT permitted.

**RNG roll logging:** Raw RNG roll events (category: `rng`) SHALL only be written when `GameConfig.DEBUG` is true. Outcome events (damage dealt, item acquired, room generated) are always logged regardless of debug state.

**Log storage:** Logs are written via `PersistenceService` to `user://logs/`. Each run produces one log file named by seed and timestamp (e.g. `run_<seed>_<timestamp>.jsonl`). The `user://logs/` directory is writable in all build configurations including exported builds.

#### Scenario: Event written on damage dealt
- **WHEN** a unit takes damage in combat
- **THEN** an event with category `combat`, event `damage_dealt`, and data containing source, target, amount, and damage type is written to the in-memory buffer

#### Scenario: Buffer flushed at floor transition
- **WHEN** the player transitions between floors
- **THEN** the in-memory event buffer is flushed to disk before the next floor begins

#### Scenario: RNG rolls suppressed in release
- **WHEN** `GameConfig.DEBUG` is false and a combat roll occurs
- **THEN** the roll outcome (e.g. damage dealt) is logged but the raw roll value and stream index are not

#### Scenario: Crash recovery via seed
- **WHEN** a crash occurs mid-floor and the log is partially flushed
- **THEN** the seed recorded at run start (in the `meta` / `run_started` event) is recoverable from the log; the full run can be reproduced from that seed

---

### Requirement: [LLD-ARCH-014] Debug Mode
Debug mode SHALL be controlled by a single boolean constant `GameConfig.DEBUG`. All debug UI nodes and code paths MUST gate on this flag. Debug mode MUST NOT be controlled by commented-out code, conditional compilation, or separate export configurations.

**Build strategy:** Debug UI and tooling are compiled into every build but gated by `GameConfig.DEBUG`. No separate debug build is required or maintained. The build under test is always the release build with the flag set.

**Debug node lifecycle:** All debug UI nodes MUST check `GameConfig.DEBUG` at `_ready()` and call `queue_free()` if false. Debug code paths in game logic are gated with `if GameConfig.DEBUG`.

**Per-system debug features** (added as each system is built):

| System | Debug Features |
|---|---|
| Core / RNG | Seed display and override input, RNG stream call count monitor |
| Navigation | Room sequence override (specify next N room types manually), current floor visualiser |
| Combat | Unit stat inspector, force-set HP on any unit, force specific enemy intent, freeze enemy AI, skip combat |
| Items | Full item spawner, force specific loot drop, set full inventory loadout |
| Companions | Toggle companion permadeath on/off, force revival scenario |
| Meta-progression | Override Soul Codex state, grant/revoke vessel unlocks, selective progression reset |

#### Scenario: Debug node self-destructs in release
- **WHEN** `GameConfig.DEBUG` is false and a debug UI node initialises
- **THEN** the node calls `queue_free()` at `_ready()` and is never visible or active

#### Scenario: Single flag controls all debug behaviour
- **WHEN** `GameConfig.DEBUG` is set to false for export
- **THEN** all debug overlays, inspectors, and code paths are inactive; no separate build step is required

#### Scenario: RNG stream monitor visible in debug
- **WHEN** `GameConfig.DEBUG` is true
- **THEN** a live readout shows the current call count for each RNG stream, making stream contamination (a roll on the wrong stream) immediately visible

---

### Requirement: [LLD-ARCH-015] Unit Testing
Soul Protocol SHALL use GdUnit4 v6.1.x as its unit testing framework. GdUnit4 is installed as a Godot plugin via the Asset Store. It supports headless command-line test runs and generates JUnit XML reports.

**Compatible version:** GdUnit4 v6.1.x is the correct line for Godot 4.6.x. v6.0.x covers only Godot 4.5–4.5.1; v5.x covers Godot 4.3–4.4. Using an incompatible version is a bug.

**What is unit tested** — pure logic systems with no scene dependency:

| System | What to Test |
|---|---|
| RNG | Correct stream initialisation from seed; derived stream seeds produce expected values; no cross-stream contamination; same seed always produces same sequence |
| Combat resolver | Damage calculations; legal action generation for a given state; action application produces correct state delta; edge cases (0 HP, full HP, empty inventory) |
| Event log | Events written in correct format; buffer flushes at checkpoints; log complete on run end; JSON is valid and parseable |
| GameState serialiser | Round-trip: serialise → deserialise produces identical state; state diff correct before and after a known action |
| Action injector | All legal actions returned for a known state; illegal actions rejected; state advances correctly after a valid action |

**What is NOT unit tested** (explicitly out of scope — covered by playtesting and manual review):
- Scene composition and node hierarchy
- UI layout, sizing, and visual correctness
- Animation and audio
- Input mapping and device handling
- Game feel — pacing, difficulty, moment-to-moment experience

**Test organisation:** Tests live in a top-level `tests/` directory. One test file per system under test: `tests/test_rng.gd`, `tests/test_combat_resolver.gd`, `tests/test_event_log.gd`, `tests/test_game_state.gd`, `tests/test_action_injector.gd`. The `tests/` directory is committed to version control.

#### Scenario: Headless test run
- **WHEN** GdUnit4 tests are run from the command line in headless mode
- **THEN** all tests execute without a display and produce a JUnit XML report

#### Scenario: RNG determinism test
- **WHEN** the RNG system is initialised with a known seed
- **THEN** the test asserts that the first N values from each stream match the pre-computed expected sequence

#### Scenario: Combat resolver edge case — zero HP
- **WHEN** the combat resolver applies damage that would reduce a unit to below 0 HP
- **THEN** the unit's HP is clamped to 0 and a unit_death event is emitted — never negative HP

#### Scenario: Illegal action rejection
- **WHEN** `ActionInjector.submit_action()` is called with an action not in `get_legal_actions()`
- **THEN** the game state is unchanged, an error is logged, and no exception is raised (per `LLD-ARCH-003`)

---

### Requirement: [LLD-ARCH-016] RunController
RunController SHALL be an Application-layer node (NOT an autoload) instantiated when a run begins and freed when it ends. It is the sole orchestrator of run phase transitions, replenishment events, and save triggers. It has no knowledge of rendering or UI — it communicates exclusively via SignalBus.

**Run phases:**

| Phase | Description |
|---|---|
| `NAVIGATION` | Player choosing between two doors |
| `COMBAT` | Active combat encounter |
| `LOOT_SELECTION` | Post-combat two-option loot pick |
| `NON_COMBAT_EVENT` | Memory Fragment, Wandering Soul, Elite Gate |
| `FLOOR_TRANSITION` | End-of-floor processing (HP restore, temporary companion departs) |
| `RUN_END` | Terminal state — death or completion |

**Replenishment events** fired to ChargeManager (see `LLD-ARCH-011`):

| Event ID | When fired |
|---|---|
| `"encounter_start"` | On entering any room with an encounter (combat or non-combat) |
| `"encounter_end"` | On leaving any encounter |
| `"floor_start"` | At the beginning of each floor |
| `"floor_end"` | At floor transition (after boss defeated, before HP restore) |

**Save triggers** emitted on SignalBus (`save_requested(SaveType)`):

| SaveType | When | Player-visible |
|---|---|---|
| `BACKGROUND` | Immediately after the player confirms a door choice | No — silent background save |
| `CHECKPOINT` | After floor completion (boss defeated, before transition) | Yes — on next load, player sees resume/restart option |

On reload with an existing `CHECKPOINT` save, the player is offered two options: **Resume** (load from checkpoint) or **Start Over** (discard run). Choosing Start Over clears the saved run state.

#### Scenario: Phase transition fires signal
- **WHEN** RunController transitions from NAVIGATION to COMBAT
- **THEN** `SignalBus.phase_changed(COMBAT, NAVIGATION)` is emitted; ScreenManager reacts to switch scenes

#### Scenario: Background save after door choice
- **WHEN** the player confirms a door selection in NAVIGATION phase
- **THEN** RunController emits `SignalBus.save_requested(BACKGROUND)` before advancing to the next phase; the save is invisible to the player

#### Scenario: Checkpoint save after floor boss
- **WHEN** the floor boss is defeated
- **THEN** RunController emits `SignalBus.save_requested(CHECKPOINT)` before emitting the floor transition; the next load offers resume or start over

#### Scenario: Replenishment on encounter start
- **WHEN** RunController transitions to COMBAT or NON_COMBAT_EVENT
- **THEN** ChargeManager receives the `"encounter_start"` replenishment event before the first player action

#### Scenario: RunController freed at run end
- **WHEN** the run reaches RUN_END phase
- **THEN** RunController emits `SignalBus.phase_changed(RUN_END, <previous>)`, completes final EventLog flush, and queues itself for deletion; no RunController instance exists between runs

---

### Requirement: [LLD-ARCH-017] GameState and Domain Entities
GameState SHALL be a `Resource` subclass in `src/domain/` composed of typed sub-Resources. All sub-types SHALL also be `Resource` subclasses. Every field in every type MUST be JSON-serialisable (no Node references, no Callable, no Object references).

**GameState fields:**

| Field | Type | Notes |
|---|---|---|
| `run_seed` | int | Base seed for all RNG streams |
| `vessel_state` | VesselState | Current vessel runtime state |
| `inventory` | Array[ItemInstance] | Up to 3 slots; null entries are empty slots |
| `bound_companion` | CompanionState | Null if vessel has no bound companion |
| `temporary_companion` | CompanionState | Null if no temporary companion active |
| `floor_number` | int | Current floor (3 for MVP1) |
| `run_phase` | int | RunPhase enum value |
| `navigation_state` | NavigationState | Current navigation context |
| `combat_state` | CombatState | Null when not in COMBAT phase |
| `item_burden_score` | int | Whole-run accumulated item burden (see HLD-RUN-007); initialized from vessel starting items at run start; updated by RunController (acquisition, run start), ActionInjector (item_broken), and CombatResolver (Repent discard) |

**VesselState fields:** `vessel_id: String`, `hp: int`, `max_hp: int`, `ability_states: Array[AbilityState]`, `active_statuses: Array[StatusInstance]`, `is_evading: bool` (true when the vessel chose Evade this turn; resets to false at the start of each player turn before any action is processed), `is_stunned: bool` (true when the vessel has been stunned by a Shocked shift trigger; blocks the Action bucket for the next player turn; resets to false at the start of resolve_player_action)

**AbilityState fields:** `ability_id: String`, `remaining_charges: int`

**ItemInstance fields:** `item_id: String`, `remaining_charges: int`

**StatusInstance fields:** `status_id: String`, `remaining_ticks: int`, `magnitude: int` (used for statuses whose numeric value evolves over ticks: Chilled's accumulating flat damage reduction, Poisoned's current damage value, Bleed's current stack count; 0 for statuses that do not use it), `trigger: String` (`"tick"` = effect fires on each omen tick while remaining_ticks > 0; `"shift"` = effect fires once when remaining_ticks hits 0 at the omen shift; default `"tick"`), `string_param: String` (type qualifier for parameterized statuses; empty string if not applicable; e.g. `"fire"` when status_id is `"type_convert"`, `"vulnerable"`, or `"emboldened"`; CombatResolver reads this to determine which type the effect applies to; default `""`)

**CompanionState fields:** `companion_id: String`, `ability_states: Array[AbilityState]` (for companion abilities with charges), `companion_timer: int` (generic countdown for companions with a budget, e.g. Shadow's 20 HP drain limit; copied from `CompanionData.initial_timer` on activation; -1 = not used by this companion; decremented by CombatResolver when the timer-consuming effect fires; companion departs when this reaches 0), `companion_context: Dictionary` (companion-specific runtime state not covered by standard fields, e.g. Shadow's `{ "current_target_instance_id": "wolf_0" }`; read and written by the companion's handler chain). No `hp` field — companions are not targetable in combat (see `HLD-COMPANION-001`).

**NavigationState fields:** `rooms_completed_this_floor: int`, `segment_room_counts: Dictionary` (room type → count, for pool exhaustion per `HLD-DOOR-004`), `doors_ahead: Array[DoorData]` (the current two-door choice; empty outside NAVIGATION phase), `companion_offered_this_floor: bool` (true once any companion encounter has fired this floor — Worn Map or Memory Fragment; blocks further companion draws from MF pool per `HLD-MF-004`), `event_type: String` (identifies the current non-combat event sub-type: `"wandering_soul"` | `"mf_cat_a"` | `"mf_cat_c"` | `"companion"` | `""`; empty string when not in `NON_COMBAT_EVENT` phase), `event_offers: Array[Dictionary]` (trade offer Dictionaries in TradeOffer format from `LLD-ARCH-021`; populated by RunController when entering a trade event; empty Array outside `NON_COMBAT_EVENT` phase or after the event resolves), `loot_offers: Array[String]` (exactly 2 item_id strings set by `LootGenerator` when entering `LOOT_SELECTION`; empty Array outside that phase)

**DoorData fields:** `room_type: String` (RoomType enum value), `encounter_id: String` (enemy_id for combat; event_id for non-combat), `room_id: String` (unique per-run identifier for logging)

**CombatState fields:** `enemies: Array[EnemyState]`, `turn_number: int`, `omen_deck: OmenDeckState`, `current_cycle: OmenCycleState` (null between cycles), `pending_repent_slots: Array[int]` (slot indices in `GameState.inventory` revealed by Repent and awaiting player discard choice; empty array when no Repent choice is pending; set by `resolve_omen_cycle_start` when Repent fires on player side with items present; cleared by `resolve_player_action` on `REPENT_DISCARD` resolution; see `LLD-ARCH-019`), `read_the_road_active: bool` (set to `true` by the `peek_omen_deck` handler immediately after `assemble_omen_deck` completes; cleared to `false` by `resolve_player_action` when `READ_THE_ROAD_COMMIT` is processed; default `false`; when `true`, `get_legal_combat_actions()` returns only `READ_THE_ROAD_COMMIT`; see `LLD-ARCH-019`)

**EnemyState fields:** `enemy_id: String`, `instance_id: String` (unique per-combat, e.g. `"skeleton_0"` and `"skeleton_1"` for two Skeletons — enables individual targeting), `hp: int`, `max_hp: int`, `active_statuses: Array[StatusInstance]`, `current_intent: String` (intent type ID set at start of each enemy turn; empty string if not yet set), `last_intent_id: String` (intent type ID selected on the previous turn; empty string at combat start), `intent_streak: int` (number of consecutive turns the current intent has been selected; resets to 1 on intent change, increments on repeat; 0 at combat start), `is_charging: bool` (true when a Charge→Release intent is in the charge phase; the release fires on the next turn unconditionally), `is_evading: bool` (true when this enemy chose Evade on its turn; resets to false at the start of that enemy's resolution in resolve_enemy_turns), `is_stunned: bool` (true when this enemy has been stunned by a Shocked shift trigger; the enemy skips its action this turn; resets to false at the start of that enemy's resolution in resolve_enemy_turns)

**OmenDeckState fields:** `draw_pile: Array[Dictionary]`, `discard_pile: Array[Dictionary]`. Each entry is `{ "card_id": String, "timer_value": int }`. Timer values are assigned once when the deck is assembled at combat start (see `LLD-OMEN-MECH-009`) and do not change on reshuffle — the discard pile preserves the originally-assigned values.

**OmenCycleState fields:** `drawn_cards: Array[Dictionary]` (exactly 3 entries, same `{ card_id, timer_value }` format as the deck), `player_choice_index: int` (-1 = not yet chosen), `random_assignment_index: int` (-1 = not yet assigned), `timer_index: int` (index into drawn_cards for the timer card), `sides_assigned: bool`

#### Scenario: Two enemies are individually targetable
- **WHEN** a combat contains two Skeletons
- **THEN** their EnemyState instances have `instance_id` values `"skeleton_0"` and `"skeleton_1"` respectively; actions targeting one do not affect the other

#### Scenario: CombatState is null outside combat
- **WHEN** the game is in NAVIGATION phase
- **THEN** `game_state.combat_state` is null; any attempt to read combat fields must check for null first

#### Scenario: CompanionState has no HP
- **WHEN** an enemy selects its intent
- **THEN** `get_legal_combat_actions()` never generates actions targeting a companion; companions are not valid action targets

#### Scenario: item_burden_score initialized at run start
- **WHEN** a Pilgrim run begins (Pilgrim has 3 starting items: Walking Staff, Spoiled Potion, Worn Map — see `LLD-ITEMS-004`)
- **THEN** `game_state.item_burden_score` is initialized to 3 (1 per starting item per HLD-RUN-007)

#### Scenario: item_burden_score persists across floors
- **WHEN** the player transitions from Floor 3 to the next floor
- **THEN** `game_state.item_burden_score` carries forward unchanged; no reset occurs

#### Scenario: pending_repent_slots empty when no Repent choice pending
- **WHEN** no Repent card has fired on the player side this turn
- **THEN** `combat_state.pending_repent_slots` is `[]`; `get_legal_combat_actions()` returns the standard action set

#### Scenario: pending_repent_slots set when Repent fires with 2+ items
- **WHEN** Repent fires on the player side and the player has items in slots 0 and 2
- **THEN** `combat_state.pending_repent_slots` is set to two randomly selected slot indices (e.g. `[0, 2]`) by `resolve_omen_cycle_start`; only REPENT_DISCARD actions are returned until resolved

#### Scenario: read_the_road_active false when no peek pending
- **WHEN** combat has started and the vessel has no `peek_omen_deck` ability (or it has already resolved)
- **THEN** `combat_state.read_the_road_active` is `false`; `get_legal_combat_actions()` returns the standard action set

#### Scenario: read_the_road_active set after assemble_omen_deck for Pilgrim
- **WHEN** `assemble_omen_deck` completes for a vessel with a `peek_omen_deck` handler
- **THEN** `combat_state.read_the_road_active` is `true` and only `READ_THE_ROAD_COMMIT` is a legal action

#### Scenario: StatusInstance magnitude tracks Chilled accumulation
- **WHEN** a unit with Chilled status reaches tick 2
- **THEN** the StatusInstance for Chilled has `magnitude` equal to the accumulated flat damage reduction; CombatResolver reads this value when calculating outgoing damage

#### Scenario: StatusInstance magnitude tracks Poisoned value
- **WHEN** a unit has the Poisoned status and an omen tick occurs
- **THEN** CombatResolver reads `magnitude` as the current poison damage value, deals that damage, then writes `magnitude * 3` back as the new value for the next tick

#### Scenario: StatusInstance magnitude tracks Bleed stacks
- **WHEN** a Bleed status is applied to a unit with 5 stacks
- **THEN** the StatusInstance for Bleed has `magnitude` set to 5; after the first tick it is set to 2 (floor(5/2)); CombatResolver reads and writes this value each tick

#### Scenario: Shift-triggered status does not fire per-tick
- **WHEN** a unit has the Shocked status (trigger: "shift") and an omen tick occurs
- **THEN** the Shocked effect does NOT fire; remaining_ticks decrements normally; the effect fires only when remaining_ticks reaches 0 at the omen shift

#### Scenario: Shocked fires at shift — is_stunned set
- **WHEN** a unit has the Shocked status and remaining_ticks reaches 0 at the omen shift
- **THEN** is_stunned is set to true on that unit; the Shocked StatusInstance is then cleared

#### Scenario: is_stunned blocks Action bucket only
- **WHEN** vessel_state.is_stunned is true at the start of the player's turn
- **THEN** get_legal_combat_actions excludes all Action bucket options; Support and Consumable options remain available

#### Scenario: is_stunned resets at start of player action
- **WHEN** resolve_player_action is called with vessel_state.is_stunned = true
- **THEN** is_stunned is reset to false at the start of resolution; it does not carry over to the following turn

#### Scenario: Intent streak resets on change
- **WHEN** an enemy selects a different intent than last turn
- **THEN** `last_intent_id` is updated to the new intent and `intent_streak` is set to 1

#### Scenario: Intent streak increments on repeat
- **WHEN** an enemy selects the same intent as last turn
- **THEN** `intent_streak` increments by 1 before the consecutive cap check is applied

#### Scenario: Charge→Release state persists across turns
- **WHEN** an enemy begins a Charge→Release intent
- **THEN** `is_charging` is set to true; on the next turn CombatResolver checks this flag before rolling a new intent

#### Scenario: is_evading resets at start of player turn
- **WHEN** a new player turn begins and resolve_player_action is called
- **THEN** CombatResolver sets vessel_state.is_evading to false before any action is processed

#### Scenario: Enemy is_evading resets at start of enemy resolution
- **WHEN** resolve_enemy_turns begins processing a specific enemy
- **THEN** that enemy's is_evading is set to false before intent selection

#### Scenario: StatusInstance string_param for Vulnerable (Fire)
- **WHEN** a Vulnerable StatusInstance is created for fire vulnerability
- **THEN** the instance has `status_id: "vulnerable"` and `string_param: "fire"`; CombatResolver reads string_param to determine which damage type gets the ×1.5 multiplier at step 6

#### Scenario: StatusInstance string_param for Type Convert (ice)
- **WHEN** a Type Convert (ice) StatusInstance is created
- **THEN** the instance has `status_id: "type_convert"` and `string_param: "ice"`; CombatResolver reads string_param at damage step 1 to override the attack's damage type

#### Scenario: StatusInstance string_param for Emboldened (Physical)
- **WHEN** an Emboldened StatusInstance is created from an Emboldened (Physical) omen card
- **THEN** the instance has `status_id: "emboldened"` and `string_param: "physical"`; CombatResolver applies the flat bonus at step 2 when physical damage is dealt

#### Scenario: event_offers populated on NON_COMBAT_EVENT entry
- **WHEN** RunController enters `NON_COMBAT_EVENT` phase for a Wandering Soul encounter
- **THEN** `navigation_state.event_type` is set to `"wandering_soul"` and `navigation_state.event_offers` contains 2–3 TradeOffer Dictionaries generated by `TradeGenerator`

#### Scenario: loot_offers populated on LOOT_SELECTION entry
- **WHEN** RunController enters `LOOT_SELECTION` phase after a combat
- **THEN** `navigation_state.loot_offers` contains exactly 2 item_id strings generated by `LootGenerator`; it is empty Array in all other phases

#### Scenario: event_type empty outside NON_COMBAT_EVENT
- **WHEN** the game is in NAVIGATION or COMBAT phase
- **THEN** `navigation_state.event_type` is `""`; `event_offers` is an empty Array

---

### Requirement: [LLD-ARCH-018] Data Resource Schemas
The following Resource subclasses SHALL define the schema for all `.tres` content files loaded by registries at startup (see `LLD-ARCH-006`). These are the data-side of the HLD/LLD boundary — the engine knows the schema; content files supply the values.

**Colon-encoding convention for parameterized statuses:** When a `status_id` or `status_apply` string contains a colon (e.g. `"type_convert:fire"`, `"vulnerable:lightning"`, `"emboldened:physical"`), CombatResolver splits on `:` at StatusInstance creation time. The left portion becomes `StatusInstance.status_id`; the right portion becomes `StatusInstance.string_param`. Plain status IDs without `:` (e.g. `"burning"`, `"frenzied"`) are used as-is with `string_param` left as `""`.

**AbilityData** (used for both vessel abilities AND items — items are abilities with `breaks_at_zero: true`):

| Field | Type | Notes |
|---|---|---|
| `ability_id` | String | Unique identifier; matches filename convention |
| `display_name` | String | Player-visible name |
| `action_bucket` | String | `"attack"` \| `"support"` \| `"consumable"` \| `"passive"` |
| `max_charges` | int | 0 = unlimited (passive, default strike) |
| `breaks_at_zero` | bool | true for items; false for vessel abilities |
| `score` | int | Precomputed item score from LLD-IR-011 (Durability or Consumable scale as applicable); 0 for vessel abilities, which are not traded. Set by the designer when authoring the `.tres` file using the LLD-IR formulas as a worksheet; never derived at runtime. |
| `replenish_triggers` | Array[String] | Event IDs from ReplenishEvents constants |
| `handlers` | Array[HandlerConfig] | Ordered chain; executed left to right |

**HandlerConfig:**

| Field | Type | Notes |
|---|---|---|
| `handler_id` | String | Snake_case; must resolve in AbilityRegistry at startup |
| `params` | Dictionary | Handler-specific parameters (e.g. `{ "base_damage": 6, "damage_type": "physical" }`) |

**VesselData:**

| Field | Type | Notes |
|---|---|---|
| `vessel_id` | String | |
| `display_name` | String | |
| `max_hp` | int | |
| `default_strike_id` | String | ability_id of the vessel's default strike ability |
| `ability_ids` | Array[String] | ability_ids (loaded from AbilityRegistry) |
| `starting_item_ids` | Array[String] | ability_ids of starting items (loaded from ItemRegistry) |
| `bound_companion_id` | String | Empty string if no bound companion |
| `omen_contributions` | Array[String] | Card IDs contributed to omen deck every combat |

**EnemyData:**

| Field | Type | Notes |
|---|---|---|
| `enemy_id` | String | |
| `display_name` | String | |
| `max_hp` | int | |
| `damage_type` | String | Damage type ID shared by all damage intents of this enemy |
| `resistances` | Array[String] | Damage type IDs this enemy resists (×0.5) |
| `enemy_tags` | Array[String] | e.g. `["undead"]`, `["beast"]`, `["elemental_fire"]` — used by omen card tag filtering and omen card effects |
| `omen_contributions` | Array[String] | Card IDs added to deck while this enemy is alive |
| `intent_weights` | Array[IntentWeight] | Weighted random pool (evaluated if no conditional matches, or restricted by a matching conditional's `intent_ids`) |
| `intent_conditionals` | Array[IntentConditional] | Evaluated first; first match short-circuits the roll |
| `on_death_summons` | Array[String] | List of enemy IDs to spawn via `resolve_enemy_summon` when this enemy dies. Each ID in the array spawns one new enemy instance starting fresh (with `turns_alive: 1`). `resolve_enemy_death` SHALL process this array after the normal omen card removal logic. Empty array = no on-death spawn. Used by the Lightning Elemental to spawn two `lightning_spark` enemies on death. |
| `on_death_apply_to_player` | String | Colon-encoded status ID (same format as `status_apply` in IntentWeight) applied to the player when this enemy dies; the StatusInstance's `remaining_ticks` is set to the current omen cycle's remaining ticks at the moment of death; empty string = no on-death status consequence. Used by the Witnesses (Vulnerable, Frenzied) and Plague Rat (Poisoned). |
| `on_death_apply_magnitude` | int | Magnitude value for the StatusInstance created by `on_death_apply_to_player`. For magnitude-additive statuses (Burning, Poisoned, Bleed — see `HLD-COMBAT-018`), if the target already has the status active, this value is added to existing magnitude. For max-wins statuses, higher magnitude wins. Ignored for statuses that do not use magnitude. Defaults 0. |

**IntentWeight:**

| Field | Type | Notes |
|---|---|---|
| `intent_id` | String | Unique identifier for this intent within the enemy |
| `weight` | int | Relative weight; higher = more likely; 0 = never randomly selected (only reachable via an IntentConditional forced match) |
| `damage_min` | int | Minimum damage per hit on execution; 0 for non-damage intents |
| `damage_max` | int | Maximum damage per hit on execution; MUST be ≥ damage_min |
| `hit_count` | int | Number of independent damage rolls on execution; defaults to 1; each roll is independently subject to evasion miss; damage_min/damage_max apply per roll |
| `is_charge_release` | bool | true if this intent uses the Charge→Release two-turn pattern |
| `is_evade` | bool | true if this intent is the Evade action; damage_min, damage_max, and status_apply are ignored |
| `max_consecutive` | int | Maximum times this intent may be selected consecutively; 0 = no limit |
| `status_apply` | String | Status ID to apply on execution; empty string if none; same colon-encoding convention as OmenCardData.status_id applies (e.g. `"vulnerable:physical"` creates a Vulnerable StatusInstance with string_param `"physical"`) |
| `status_magnitude` | int | Magnitude value for the StatusInstance created by `status_apply`. For Burning: fire damage per tick. For Poisoned: starting poison value. For Bleed: starting stack count. For Hardened: absorb value per hit. For Emboldened (Physical): flat damage bonus. When the target already has an active instance of the status: magnitude-additive statuses (Burning, Poisoned, Bleed — see `HLD-COMBAT-018`) increment existing magnitude; max-wins statuses (Hardened, Emboldened — see `HLD-COMBAT-019`) keep the higher magnitude; idempotent statuses (Chilled — see `HLD-COMBAT-015`) are unchanged. Defaults 0; ignored for statuses that do not use magnitude (e.g. Shocked, Vulnerable). |
| `status_target` | String | `"player"` (default) \| `"self"` \| `"allies"` — `"player"`: applies to the player; `"self"`: applies to the caster enemy; `"allies"`: applies to all living enemies on the enemy side except the caster (used by Totem buffing intents; see `LLD-ENEMIES-019`, `LLD-ENEMIES-020`) |
| `summon_enemy_id` | String | When non-empty, spawns one enemy of this enemy_id when the intent resolves; the spawned enemy is added to CombatState with full HP and a unique instance_id; its Tier 1 omen card (first entry in EnemyData.omen_contributions) is injected into OmenDeckState.draw_pile immediately (see `HLD-OMEN-006`); empty string = no summon |
| `handlers` | Array[HandlerConfig] | Optional custom handler chain executed by CombatResolver via AbilityPipeline after standard `status_apply` processing. Used for intent effects that cannot be expressed as a static `status_magnitude` — for example, the Witnesses' tier-based magnitude intents (`testify_mercy`, `testify_vengeance`) which read `game_state.item_burden_score` at resolution time. Defaults to `[]`. Empty array = no custom handlers beyond `status_apply`. |

**IntentConditional:**

| Field | Type | Notes |
|---|---|---|
| `condition` | String | Condition string evaluated by CombatResolver before intent selection. Supported forms: `"hp_below_percent:N"` (HP strictly less than N% of max_hp), `"hp_percent_lte:N"` (HP less than or equal to N% of max_hp), `"ally_count_above:N"`, `"ally_count_equals:N"`, `"turn_number:N"`. **`turn_number:N`** is evaluated against a per-enemy turn counter (`turns_alive: int` on EnemyState; starts at 1 when the enemy enters combat — whether at encounter start or mid-combat via summon — and increments at the start of each of that enemy's turns in `resolve_enemy_turns`). For enemies present from combat start, `turns_alive` equals `CombatState.turn_number`. For enemies spawned mid-combat (e.g. Sparks, summoned wolves), `turns_alive` is independent of the global turn counter, allowing `turn_number:1` to correctly select a dormant intent on the Spark's first action regardless of when it was spawned. **`hp_percent_lte:N`** is used by The Judge's Pass Judgment phase trigger (`hp_percent_lte:30` — ≤30% of max_hp). |
| `intent_id` | String | When non-empty: intent selected directly when condition is true; no COMBAT stream roll; must match an intent_id in intent_weights; use either `intent_id` or `intent_ids`, not both |
| `intent_ids` | Array[String] | When non-empty: restricts the weighted roll to only these intent IDs from intent_weights (using their relative weights); a COMBAT stream roll is still performed within this subset; use either `intent_id` or `intent_ids`, not both |

**OmenCardData:**

| Field | Type | Notes |
|---|---|---|
| `card_id` | String | Unique identifier; matches filename convention |
| `display_name` | String | Player-visible name |
| `status_id` | String | Status ID applied to each eligible unit when the card fires; empty string for cards with no status effect (e.g. Stillness); colon-encoded parameterized statuses (e.g. `"type_convert:fire"`, `"vulnerable:lightning"`, `"emboldened:physical"`) are split on `:` by CombatResolver — left of `:` becomes StatusInstance.status_id, right becomes StatusInstance.string_param |
| `status_magnitude` | int | Magnitude value for StatusInstances created from this card's `status_id`. For Burning: fire damage per tick (e.g. 5 for the Burning omen card). For magnitude-additive statuses (see `HLD-COMBAT-018`), if the target already has the status active, this value is added to existing magnitude rather than creating a new instance. Defaults 0; ignored for statuses that do not use magnitude. |
| `requires_tag` | String | Empty string = apply to all units on the target side; non-empty = only apply to units whose `enemy_tags` contains this value (e.g. `"undead"`, `"beast"`); if steered to the player side and the player is not tagged, no effect is applied |
| `handlers` | Array[HandlerConfig] | For cards with non-standard effects that cannot be expressed as a single status_id (e.g. Elemental Synergy, Sacred Ground); executed in addition to any status_id application |

**CompanionData:**

| Field | Type | Notes |
|---|---|---|
| `companion_id` | String | |
| `display_name` | String | |
| `omen_contributions` | Array[String] | Card IDs added while companion is active |
| `trigger` | String | Trigger type ID: `"turn_end"` or `"vessel_death_intercept"` |
| `handlers` | Array[HandlerConfig] | Executed via AbilityPipeline on trigger |
| `granted_ability_id` | String | ability_id of the active ability granted to the vessel; empty string if none |
| `initial_timer` | int | Starting value for `CompanionState.companion_timer`; 0 = not used |
| `departure_trigger` | String | `"ability_used"` \| `"timer_exhausted"` \| `"intercept_triggered"` \| `"after_boss_only"` |

#### Scenario: Item uses AbilityData schema
- **WHEN** the Walking Staff item is defined as a `.tres` file
- **THEN** it uses AbilityData with `action_bucket: "attack"`, `breaks_at_zero: true`, `max_charges: 6`, and one HandlerConfig entry

#### Scenario: Item .tres file carries precomputed score
- **WHEN** an item AbilityData `.tres` file is loaded by ItemRegistry at startup
- **THEN** the `score` field contains the item's precomputed score from LLD-IR-011; the engine never derives this value at runtime

#### Scenario: Vessel ability score is zero
- **WHEN** a vessel ability `.tres` file (e.g. Pilgrim's Insight ability) is loaded
- **THEN** its `score` field is 0; vessel abilities are never traded and carry no score

#### Scenario: OmenCardData tag filter — undead only
- **WHEN** the Grave Knit omen card (requires_tag: "undead") is applied to a side with one Skeleton and one Plague Rat
- **THEN** the Skeleton receives a Mending StatusInstance; the Plague Rat receives nothing

#### Scenario: OmenCardData tag filter — player side
- **WHEN** any omen card with requires_tag: "undead" is steered to the player side
- **THEN** no StatusInstance is created; the player is not tagged and receives no effect

#### Scenario: Enemy conditional intent overrides random — forced
- **WHEN** CombatResolver resolves an enemy's intent and an IntentConditional with a non-empty `intent_id` matches
- **THEN** the matched intent_id is selected without rolling the COMBAT stream

#### Scenario: Enemy conditional intent restricts pool — intent_ids
- **WHEN** CombatResolver resolves an enemy's intent and an IntentConditional with a non-empty `intent_ids` array matches
- **THEN** CombatResolver performs one weighted roll via the COMBAT stream, considering only the intents listed in `intent_ids` and their relative weights from `intent_weights`

#### Scenario: Enemy weighted intent uses COMBAT stream
- **WHEN** no IntentConditional matches for an enemy
- **THEN** CombatResolver performs one weighted roll against the full COMBAT stream using all entries in intent_weights

#### Scenario: Enemy Evade intent sets is_evading
- **WHEN** an enemy's selected intent has is_evade: true
- **THEN** CombatResolver sets that enemy's is_evading to true and does not process damage or status for that intent

#### Scenario: hit_count > 1 produces multiple independent rolls
- **WHEN** an enemy's intent has hit_count: 2 and damage_min: 3, damage_max: 5
- **THEN** CombatResolver performs 2 separate COMBAT stream rolls of [3, 5] each; each roll is independently subject to evasion miss if the target is evading

#### Scenario: summon_enemy_id spawns enemy with omen card
- **WHEN** an enemy's intent resolves and summon_enemy_id is `"wolf"`
- **THEN** a new Wolf EnemyState with full HP and a unique instance_id is added to CombatState.enemies; one Thick Hide card is injected into OmenDeckState.draw_pile immediately

#### Scenario: Colon-encoded status_id split on create
- **WHEN** CombatResolver applies an omen card with `status_id: "type_convert:fire"`
- **THEN** it creates a StatusInstance with `status_id: "type_convert"` and `string_param: "fire"`; the colon is not preserved in the instance

#### Scenario: Plain status_id unchanged
- **WHEN** CombatResolver applies an omen card with `status_id: "burning"`
- **THEN** it creates a StatusInstance with `status_id: "burning"` and `string_param: ""`; no splitting occurs

#### Scenario: IntentWeight status_magnitude used on first Burning application
- **WHEN** a Fire Elemental's Kindle intent (status_apply: "burning", status_magnitude: 2) resolves against a player with no active Burning
- **THEN** CombatResolver creates a new Burning StatusInstance with magnitude: 2

#### Scenario: IntentWeight status_magnitude stacks on second Burning application
- **WHEN** a Fire Elemental's Kindle intent (status_apply: "burning", status_magnitude: 2) resolves against a player who already has Burning with magnitude: 3
- **THEN** CombatResolver increments the existing Burning StatusInstance's magnitude to 5; no new StatusInstance is created

#### Scenario: OmenCardData status_magnitude applied to Burning omen card
- **WHEN** the Burning omen card (status_id: "burning", status_magnitude: 5) fires on an enemy with no active Burning
- **THEN** CombatResolver creates a Burning StatusInstance with magnitude: 5 on that enemy

#### Scenario: status_magnitude defaults 0 for non-magnitude statuses
- **WHEN** a Shocked omen card (status_magnitude: 0 by default) fires
- **THEN** the Shocked StatusInstance is created with magnitude: 0; the magnitude field is irrelevant and has no effect on Shocked's behaviour

#### Scenario: turn_number conditional — per-enemy for spawned Spark
- **WHEN** a Lightning Spark is spawned on global combat turn 3 and CombatResolver evaluates its intents
- **THEN** the Spark's `turns_alive` is 1; the `turn_number:1` conditional matches and `spark_dormant` is selected; the global `CombatState.turn_number` of 3 is irrelevant to this evaluation

#### Scenario: turn_number conditional — equivalent for combat-start enemies
- **WHEN** a Bear (present from combat start) evaluates its intents on global turn 1
- **THEN** its `turns_alive` is 1 and `CombatState.turn_number` is 1; `turn_number:1` matches via either interpretation

#### Scenario: on_death_summons — Lightning Elemental spawns Sparks
- **WHEN** the Lightning Elemental dies and its EnemyData has `on_death_summons: ["lightning_spark", "lightning_spark"]`
- **THEN** `resolve_enemy_death` calls `resolve_enemy_summon("lightning_spark", game_state)` twice; two new `lightning_spark` EnemyState instances with 6 HP, unique instance_ids, and `turns_alive: 1` are added to CombatState.enemies

#### Scenario: status_target "allies" — applies to all enemies except caster
- **WHEN** the Buff Totem's embolden_allies intent resolves (status_target: "allies")
- **THEN** all living enemies on the enemy side except the Buff Totem itself receive the Emboldened (Physical) StatusInstance; the Totem does not receive the status

#### Scenario: status_target "allies" — excludes dead enemies
- **WHEN** the Absorption Totem's harden_allies intent resolves and one Fanatic has already died this turn
- **THEN** Hardened is applied only to the living Fanatics; the dead enemy is skipped

#### Scenario: status_magnitude max-wins for Emboldened on Totem re-apply
- **WHEN** the Buff Totem applies Emboldened (Physical, magnitude 2) to a Fanatic that already has Emboldened (Physical) with magnitude 2
- **THEN** no change occurs (equal magnitude — max-wins rule, see `HLD-COMBAT-019`); the existing StatusInstance is unchanged

#### Scenario: on_death_apply_to_player — Witness of Mercy
- **WHEN** the Witness of Mercy (`on_death_apply_to_player: "vulnerable:physical"`, `on_death_apply_magnitude: 0`) dies
- **THEN** `resolve_enemy_death` creates a `"vulnerable:physical"` StatusInstance on the player with `remaining_ticks` equal to the current omen cycle's remaining ticks

#### Scenario: on_death_apply_to_player — Plague Rat poison magnitude-additive
- **WHEN** a Plague Rat (`on_death_apply_to_player: "poisoned"`, `on_death_apply_magnitude: 2`) dies and the player already has Poisoned with magnitude 4
- **THEN** `resolve_enemy_death` increments the existing Poisoned StatusInstance's magnitude to 6 (magnitude-additive per HLD-COMBAT-018); no new StatusInstance is created

#### Scenario: on_death_apply_to_player — no consequence
- **WHEN** an enemy with `on_death_apply_to_player: ""` dies
- **THEN** `resolve_enemy_death` skips the on-death status step; only omen card removal is performed

#### Scenario: IntentWeight handlers — Witness tier-based magnitude
- **WHEN** the Witness of Mercy's `testify_mercy` intent resolves and its `handlers` array contains `{ "handler_id": "apply_mending_by_burden_tier" }`
- **THEN** CombatResolver executes the handler chain via AbilityPipeline after `status_apply` processing; the handler reads `game_state.item_burden_score` and applies Mending at the appropriate tier magnitude to The Judge

#### Scenario: hp_percent_lte condition — Judge Pass Judgment entry
- **WHEN** The Judge (max_hp: 30) has hp: 9 and CombatResolver evaluates its IntentConditionals
- **THEN** the condition `"hp_percent_lte:30"` is true (9/30 = 30% ≤ 30%); `pass_judgment` is selected; the normal intent pool is bypassed

#### Scenario: hp_percent_lte vs hp_below_percent — boundary distinction
- **WHEN** an enemy with max_hp: 30 has hp: 9 and both `"hp_percent_lte:30"` and `"hp_below_percent:30"` conditionals are defined
- **THEN** `hp_percent_lte:30` is true (9/30 = 30% ≤ 30%); `hp_below_percent:30` is false (9/30 = 30% is not strictly less than 30%)

---

### Requirement: [LLD-ARCH-019] CombatResolver
CombatResolver SHALL be a `RefCounted` subclass in `src/domain/`. It is the sole authority for all combat rule application. CombatResolver receives `RNGService` as a constructor dependency. It MUST NOT access any autoload directly.

**Interface:**

```
get_legal_combat_actions(game_state: GameState) -> Array[Dictionary]
    Returns all valid player actions for the current combat turn.
    Priority-ordered gating (first matching branch wins):
    1. If combat_state.read_the_road_active is true: returns ONLY READ_THE_ROAD_COMMIT.
       No other action types are included. The guarantee of "at least one action" holds.
    2. If combat_state.pending_repent_slots is non-empty: returns ONLY REPENT_DISCARD actions,
       one per slot index in pending_repent_slots. No other action types are included.
    3. Otherwise (no pending interactive choice):
      Always returns at least one action (Default Strike is always legal).
      Evade is always included as a legal Action bucket option.
      If vessel_state.is_stunned is true: all Action bucket options are excluded from the
      returned array; Support and Consumable options remain included.
      If an active companion has a non-empty granted_ability_id, it is included using its
      configured action_bucket.
      For Raven Mark specifically, only non-elite, non-boss living enemies are valid targets.

resolve_player_action(action: Dictionary, game_state: GameState) -> GameState
    Applies one player action. Returns updated GameState.
    If action.type == "READ_THE_ROAD_COMMIT":
      - Validate that combat_state.read_the_road_active is true; if false, log error and
        return state unchanged.
      - Validate send_to_bottom: all indices in [0, min(2, draw_pile.size()-1)], no duplicates;
        if invalid, log error and return state unchanged.
      - Process in descending index order: for each index in send_to_bottom (sorted descending),
        pop draw_pile[index] and append it to the end of draw_pile.
      - Set combat_state.read_the_road_active = false.
      - Return updated GameState. Do NOT advance the omen cycle; combat setup continues.
        Do NOT reset vessel_state.is_evading or is_stunned here.
    If action.type == "REPENT_DISCARD":
      - Validate that action.slot_index is in combat_state.pending_repent_slots.
      - Remove the item at action.slot_index from inventory.
      - Heal player 5 HP directly (not Mending; clamp to max_hp).
      - Decrement game_state.item_burden_score by 1 (floor at 0).
      - Emit SignalBus.item_discarded(item_id, slot_index).
      - Clear combat_state.pending_repent_slots to [].
      - Return updated GameState. Do NOT reset vessel_state.is_evading or is_stunned here
        (these only reset at the start of a standard action, not Repent resolution).
    Otherwise (standard action):
      Resets vessel_state.is_evading and vessel_state.is_stunned to false at the start of
      resolution (clears flags from the prior turn).
      If the action is Evade: sets vessel_state.is_evading to true and returns immediately.
      For all other actions: runs the handler chain via AbilityPipeline.
      For attack actions against evading targets: per-hit miss roll (35% via COMBAT stream).
      Charge preservation: if ALL hits missed, weapon item charges are not decremented.
      Applies vulnerability, resistance, and damage modifier rules from hld-combat-system.
      If the resolved action used a companion's granted_ability_id and departure_trigger is
      "ability_used", the companion departs as part of this resolution.

resolve_enemy_turns(game_state: GameState) -> GameState
    Resolves all living enemies' turns in order.
    For each enemy:
      0. Reset enemy.is_evading and enemy.is_stunned to false.
         If enemy.is_stunned was true before reset: skip all remaining steps for this enemy
         (the enemy takes no action this turn).
      1. If enemy.is_charging is true: execute the Charge→Release release; set is_charging false.
      2. Otherwise: evaluate intent_conditionals in order; first match short-circuits:
           - If matched conditional has non-empty intent_id: select that intent directly
             (no COMBAT stream roll).
           - If matched conditional has non-empty intent_ids: roll COMBAT stream restricted
             to only those intent IDs using their relative weights from intent_weights.
         If no conditional matches: roll COMBAT stream against the full intent_weights pool.
      3. Consecutive cap check (step 2 non-forced rolls only): re-roll if intent_id ==
         last_intent_id and streak >= max_consecutive.
      4. Update last_intent_id and intent_streak on EnemyState.
      5. If selected intent has is_evade: true: set enemy.is_evading = true; skip to next enemy.
      6. If selected intent has is_charge_release: true: set is_charging = true; deal no damage this turn.
      7. Otherwise execute the intent:
           a. If hit_count > 1: perform hit_count independent iterations of the following;
              if hit_count == 1 (default): perform once.
           b. Each iteration: roll damage in [damage_min, damage_max] via COMBAT stream
              (if damage_max > 0); apply evasion miss check if vessel_state.is_evading is true
              (35% miss per hit via COMBAT stream); deal damage if hit lands.
           c. Apply status_apply if non-empty (to player if status_target: "player",
              to self if "self"); subject to HLD-COMBAT-015 for Chilled idempotency.
              For magnitude-additive statuses (Burning, Poisoned, Bleed — see HLD-COMBAT-018):
              if an active StatusInstance of that status already exists on the target, increment
              its magnitude by status_magnitude instead of creating a new StatusInstance.
              Otherwise create a new StatusInstance with magnitude = status_magnitude.
           d. If the selected IntentWeight has non-empty handlers: execute the handler chain
              via AbilityPipeline with game_state as context. Handler chains read and write
              game_state directly (e.g. apply_mending_by_burden_tier reads item_burden_score
              and applies the correct Mending magnitude to the target).
           e. If summon_enemy_id is non-empty: call resolve_enemy_summon(summon_enemy_id, game_state).
    Sets current_intent on EnemyState for display.

resolve_enemy_summon(enemy_id: String, game_state: GameState) -> GameState
    Spawns a new enemy of the given type mid-combat.
    Looks up EnemyData for enemy_id. Creates a new EnemyState with max_hp from EnemyData,
    assigns a unique instance_id (e.g. "wolf_1" if "wolf_0" already exists).
    Adds the new EnemyState to CombatState.enemies.
    Injects one copy of EnemyData.omen_contributions[0] (the Tier 1 family card) into
    OmenDeckState.draw_pile immediately (see HLD-OMEN-006 Tier 1).
    Returns updated GameState.

resolve_companion_trigger(trigger_id: String, game_state: GameState) -> GameState
    Fires the companion's handler chain if active and trigger matches.
    Decrements companion_timer when applicable; departs companion at 0.

check_vessel_death_intercept(game_state: GameState) -> GameState
    Called synchronously when vessel HP reaches 0, BEFORE unit_died is emitted.
    If an active companion has trigger == "vessel_death_intercept": run handler chain,
    depart companion, return updated GameState — unit_died is NOT emitted.

resolve_omen_tick(game_state: GameState) -> GameState
    Advances one omen tick.
    For each unit's active StatusInstances:
      - trigger: "tick" statuses: fire their per-tick effect (Burning damage, Chilled reduction,
        Poisoned escalation, Mending heal, Hardened absorption, Bleed decay).
      - trigger: "shift" statuses: do NOT fire; remaining_ticks decrements only.
    Decrements remaining_ticks on ALL active StatusInstances.
    Clears only trigger: "tick" StatusInstances whose remaining_ticks has reached 0.
    Shift-triggered StatusInstances at 0 are NOT cleared here — they are processed in
    resolve_omen_cycle_start.

resolve_omen_cycle_start(game_state: GameState) -> GameState
    Ends the current cycle and starts a new one.
    Step 1 — Fire shift-triggered statuses: for each unit, for each StatusInstance with
      trigger: "shift" and remaining_ticks == 0:
        - Shocked: set is_stunned = true on that unit.
        - Exposed: mark this unit as pending Vulnerable (Physical) application.
    Step 2 — Clear expired statuses: remove all StatusInstances with remaining_ticks == 0
      from all units (both tick-triggered and shift-triggered).
    Step 3 — Draw new cycle: draw 3 cards from OmenDeckState into OmenCycleState.
      Reshuffle discard into draw pile first if fewer than 3 cards remain.
      Determine the new cycle's timer value from the leftover (timer) card.
    Step 4 — Apply deferred Vulnerable: for each unit marked as pending Vulnerable (Physical)
      from step 1, apply a `"vulnerable:physical"` StatusInstance with
      remaining_ticks = new cycle timer value.
    Step 5 — Apply on-draw statuses: for each of the two played cards in the new cycle,
      apply the card's status_id (if non-empty) to each eligible unit on the target side,
      filtering by requires_tag. New StatusInstances get remaining_ticks = new cycle timer
      and magnitude = OmenCardData.status_magnitude.
      For magnitude-additive statuses (Burning, Poisoned, Bleed — see HLD-COMBAT-018): if the
      target already has an active instance of that status, increment existing magnitude by
      OmenCardData.status_magnitude instead of creating a new StatusInstance.
      Execute any handlers on OmenCardData for cards that have non-status effects.
      **Type Convert replacement:** when applying a `type_convert` StatusInstance to a unit
      that already has an active `type_convert` StatusInstance, remove the existing one first —
      only one Type Convert may be active on a unit at a time. This replacement rule also
      applies in resolve_player_action and resolve_enemy_turns when status_apply is processed.
      **Repent special handling:** if a played card has `card_id == "repent"` and its target
      side is the player:
        - Count the player's non-empty item slots (N).
        - If N == 0: immediately heal the player 5 HP; continue processing remaining cards.
        - If N == 1: set `combat_state.pending_repent_slots` to `[<that slot index>]`;
          return the GameState immediately (step 5 processing stops; remaining cards are
          not applied this cycle step — they apply after REPENT_DISCARD resolves).
        - If N >= 2: randomly select 2 non-empty item slot indices via COMBAT stream;
          set `combat_state.pending_repent_slots` to those two indices; return the GameState
          immediately (same early-return as N == 1).
      When `pending_repent_slots` is non-empty, `get_legal_combat_actions()` returns only
      REPENT_DISCARD actions until the player resolves the choice (see LLD-ARCH-019).

assemble_omen_deck(sources: Array[String], game_state: GameState) -> GameState
    Builds OmenDeckState from all contributing sources (vessel, enemies, items, companions).
    Assigns timer values via COMBAT stream per LLD-OMEN-MECH-008.
    After building and shuffling the draw pile, executes passive ability handlers from the
    vessel's AbilityData entries. If any handler sets read_the_road_active = true, returns
    the updated GameState immediately — the caller must wait for READ_THE_ROAD_COMMIT before
    proceeding to the first omen draw.

resolve_enemy_death(unit_id: String, game_state: GameState) -> GameState
    Removes the dead enemy's family card copy from draw_pile and discard_pile immediately.
    Checks for last-of-type; removes type card if so (per HLD-OMEN-006).
    Cards already drawn into OmenCycleState are NOT removed.
    After omen card removal: reads `EnemyData.on_death_apply_to_player` for the dead enemy.
    If non-empty, creates and applies a StatusInstance to the player:
      - `status_id` and `string_param` are parsed from the colon-encoded string (e.g.
        `"vulnerable:physical"` → status_id: "vulnerable", string_param: "physical").
      - `remaining_ticks` is set to the current omen cycle's remaining ticks at the moment
        of death resolution (guaranteed ≥ 1; see design.md open question re: ordering).
      - `magnitude` is set to `EnemyData.on_death_apply_magnitude`.
      - For magnitude-additive statuses (Burning, Poisoned, Bleed): if the player already
        has an active instance, increment its magnitude rather than creating a new one.
      - For max-wins statuses (Mending, Emboldened, Hardened, Vulnerable, Chilled, etc.):
        if the player already has an active instance with equal or greater magnitude,
        the new application is ignored.
```

**Damage resolution order** (applied in this sequence for every hit):
0. Evade miss check: if the target has is_evading = true, roll [0, 99] via COMBAT stream; if ≤ 34 (35% miss), skip all remaining steps
1. Base damage and type: determine base damage value (player flat value from HandlerConfig; enemy rolled [damage_min, damage_max] via COMBAT stream) and initial damage type (from EnemyData.damage_type or HandlerConfig.params.damage_type). **Type conversion override:** if the attacker has an active `type_convert` StatusInstance, replace the damage type with `StatusInstance.string_param` before any further steps.
2. Flat attacker bonuses: if attacker has an `emboldened` StatusInstance with `string_param: "physical"` and the resolved damage type is physical, add flat bonus (value defined in LLD)
3. Passive modifiers: Last Stand ×1.5 if active
4. Buff modifiers: Charged ×2 if active (consumed after); if attacker has an `emboldened` StatusInstance whose `string_param` matches the resolved damage type and `string_param` is not `"physical"`, apply ×1.5
5. Resistance (×0.5 if target resists the resolved damage type)
6. Vulnerability (×1.5 if target has an active `vulnerable` StatusInstance whose `string_param` matches the resolved damage type)
7. Resistance + Vulnerability cancel: if both apply to the same type → net ×1.0

#### Scenario: Legal actions always include Default Strike and Evade (no pending choice)
- **WHEN** the vessel has zero item charges remaining, no ability charges, `pending_repent_slots` is `[]`, and `read_the_road_active` is `false`
- **THEN** `get_legal_combat_actions()` returns exactly two actions: Default Strike and Evade

#### Scenario: read_the_road_active takes priority over pending_repent_slots
- **WHEN** both `read_the_road_active` is `true` and `pending_repent_slots` is non-empty
- **THEN** `get_legal_combat_actions()` returns only `READ_THE_ROAD_COMMIT`; the Repent choice is deferred until Read the Road resolves

#### Scenario: READ_THE_ROAD_COMMIT with partial send — descending splice order
- **WHEN** the player submits `READ_THE_ROAD_COMMIT` with `send_to_bottom: [2, 0]` and draw_pile is `[A, B, C, D, E]`
- **THEN** indices are processed descending (2 first, then 0): C appended → `[A, B, D, E, C]`; A appended → `[B, D, E, C, A]`; `read_the_road_active` is cleared

#### Scenario: READ_THE_ROAD_COMMIT with empty array — pile unchanged
- **WHEN** the player submits `READ_THE_ROAD_COMMIT` with `send_to_bottom: []`
- **THEN** draw_pile order is unchanged; `read_the_road_active` is cleared to `false`

#### Scenario: Hardened absorption can reduce damage to 0
- **WHEN** an enemy with Hardened magnitude 5 is struck for 4 damage (after all multipliers)
- **THEN** Hardened absorbs all 4 points; the enemy takes 0 damage; no minimum applies

#### Scenario: is_stunned excludes Action bucket from legal actions
- **WHEN** vessel_state.is_stunned is true at the start of the player's turn
- **THEN** `get_legal_combat_actions()` returns no Action bucket options; Support and Consumable options are still returned

#### Scenario: Shocked enemy skips its turn
- **WHEN** an enemy has is_stunned = true at the start of its resolution in resolve_enemy_turns
- **THEN** is_stunned is reset to false and all intent selection and execution steps are skipped; the enemy takes no action

#### Scenario: Exposed fires at shift — Vulnerable applied with new cycle timer
- **WHEN** resolve_omen_cycle_start processes a unit with an Exposed StatusInstance at remaining_ticks == 0
- **THEN** the Exposed status fires, marks the unit pending Vulnerable; after the new cycle draw determines a timer value of 2, Vulnerable (Physical) is applied with remaining_ticks = 2

#### Scenario: Emboldened (Physical) adds flat bonus to base damage
- **WHEN** the player has Emboldened (Physical) and attacks with a physical weapon dealing 6 base damage
- **THEN** the flat bonus (defined in LLD) is added before any multipliers are applied

#### Scenario: Damage resolution order — Last Stand + Charge + Vulnerability
- **WHEN** the Hedge Knight (HP < 25%) uses Charge and attacks a Vulnerable (Physical) enemy with a 7-damage weapon
- **THEN** step 0 passes (not evading); step 2 adds no flat bonus (no Emboldened); step 3 ×1.5 Last Stand; step 4 ×2.0 Charge; step 6 ×1.5 Vulnerable → 7 × 1.5 × 2.0 × 1.5 = 31 (rounded down)

#### Scenario: Resistance cancels Vulnerability
- **WHEN** CombatResolver resolves a fire attack against a Fire Elemental with Vulnerable (Fire)
- **THEN** resistance (×0.5) and vulnerability (×1.5) cancel; net ×1.0

#### Scenario: Enemy intent conditional short-circuits roll — turn_number forced
- **WHEN** an enemy has a `"turn_number:1"` conditional mapped to `"sleeping"` and it is the first turn
- **THEN** `current_intent` is set to `"sleeping"` with no COMBAT stream roll

#### Scenario: intent_ids conditional — Wolf pack pool
- **WHEN** a Wolf with the `ally_count_above:0` conditional has 1+ living allies
- **THEN** CombatResolver rolls the COMBAT stream restricted to the [bite_pack, evade] subset; other intents in intent_weights are ineligible this turn

#### Scenario: intent_ids conditional — Wolf alone pool
- **WHEN** a Wolf with the `ally_count_equals:0` conditional is the last wolf alive
- **THEN** CombatResolver rolls the COMBAT stream restricted to the [bite_lone, howl] subset; bite_pack and evade are ineligible this turn

#### Scenario: resolve_enemy_summon — Wolf Howl
- **WHEN** a Wolf's Howl intent resolves (summon_enemy_id: "wolf")
- **THEN** resolve_enemy_summon creates a new Wolf EnemyState at 6 HP; adds it to CombatState.enemies; injects one Thick Hide card into OmenDeckState.draw_pile; returns updated GameState

#### Scenario: Bear Swipe — two independent hits
- **WHEN** the Bear's Swipe intent resolves (hit_count: 2, damage_min: 3, damage_max: 5)
- **THEN** CombatResolver performs 2 separate [3, 5] COMBAT stream rolls; each is independently subject to evasion miss if the player is evading; damage from each landing hit is summed

#### Scenario: Type Convert overrides damage type before multipliers
- **WHEN** a player with a `type_convert` StatusInstance (`string_param: "fire"`) attacks with a physical weapon dealing 6 base damage
- **THEN** at step 1 the damage type is overridden to fire; the `emboldened:physical` flat bonus at step 2 does NOT apply (resolved type is now fire); steps 5 and 6 use fire for resistance and vulnerability checks

#### Scenario: Type Convert and Vulnerable stack correctly
- **WHEN** a player with Type Convert (fire) attacks a unit that has a `vulnerable` StatusInstance with `string_param: "fire"`
- **THEN** damage type is overridden to fire at step 1; step 6 applies ×1.5 because the Vulnerable string_param matches the resolved type

#### Scenario: Vulnerable string_param match — lightning
- **WHEN** CombatResolver resolves step 6 for a lightning attack against a unit with a `vulnerable` StatusInstance with `string_param: "lightning"`
- **THEN** ×1.5 multiplier applies; if string_param were `"fire"` or `"physical"`, no multiplier would apply for this lightning hit

#### Scenario: Emboldened (Physical) flat bonus — step 2
- **WHEN** the player has an `emboldened` StatusInstance with `string_param: "physical"` and attacks with a physical weapon dealing 6 base damage
- **THEN** the flat bonus is added at step 2 before any multipliers

#### Scenario: Emboldened (Fire) multiplier — step 4
- **WHEN** the player has an `emboldened` StatusInstance with `string_param: "fire"` and attacks with a fire weapon
- **THEN** step 4 applies ×1.5; step 2 does not apply (string_param is not "physical")

#### Scenario: Exposed deferred Vulnerable uses colon shorthand
- **WHEN** resolve_omen_cycle_start step 4 applies the deferred Vulnerable for an Exposed unit
- **THEN** CombatResolver creates a `"vulnerable:physical"` StatusInstance (split to status_id: "vulnerable", string_param: "physical") with remaining_ticks = new cycle timer

#### Scenario: resolve_enemy_turns step 7c — Burning magnitude stacking
- **WHEN** a Fire Elemental's Kindle intent (status_apply: "burning", status_magnitude: 2) resolves and the player already has Burning with magnitude 3
- **THEN** CombatResolver increments the existing Burning StatusInstance's magnitude to 5; no new StatusInstance is created; remaining_ticks is unchanged

#### Scenario: resolve_omen_cycle_start step 5 — Burning omen card magnitude
- **WHEN** the Burning omen card (status_id: "burning", status_magnitude: 5) fires on an enemy that has no active Burning
- **THEN** CombatResolver creates a new Burning StatusInstance on that enemy with magnitude: 5 and remaining_ticks = new cycle timer

#### Scenario: resolve_omen_cycle_start step 5 — Burning omen card stacks with existing
- **WHEN** the Burning omen card (status_magnitude: 5) fires on an enemy that already has Burning with magnitude 2
- **THEN** CombatResolver increments the existing Burning StatusInstance's magnitude to 7; no new StatusInstance is created

#### Scenario: Repent fires with 2+ items — pending_repent_slots set and step 5 pauses
- **WHEN** the Repent card fires on the player side and the player has items in slots 0 and 2
- **THEN** `combat_state.pending_repent_slots` is set to two randomly selected slot indices (e.g. `[0, 2]`); `resolve_omen_cycle_start` returns immediately without applying remaining cards; `get_legal_combat_actions()` returns only REPENT_DISCARD actions for those slot indices

#### Scenario: Repent fires with 0 items — immediate heal, no pause
- **WHEN** the Repent card fires on the player side and the player has no items in any slot
- **THEN** the player is healed 5 HP immediately; `pending_repent_slots` remains `[]`; omen cycle step 5 continues processing remaining cards normally

#### Scenario: REPENT_DISCARD resolves — item removed, heal applied, burden decremented
- **WHEN** the player submits a REPENT_DISCARD action with slot_index: 0 and `pending_repent_slots` is `[0, 2]`
- **THEN** the item in slot 0 is removed from the player's inventory; the player is healed 5 HP; `game_state.item_burden_score` is decremented by 1; `SignalBus.item_discarded` is emitted with (item_id, 0); `combat_state.pending_repent_slots` is cleared to `[]`

#### Scenario: resolve_enemy_death — Witness on-death status applied to player
- **WHEN** Witness of Mercy is killed and `EnemyData.on_death_apply_to_player` is `"vulnerable:physical"` with current cycle remaining_ticks = 2
- **THEN** a `vulnerable:physical` StatusInstance is created on the player with remaining_ticks = 2 (using max-wins rule against any existing Vulnerable)

#### Scenario: resolve_enemy_death — Plague Rat on-death Poisoned applied to player
- **WHEN** Plague Rat is killed and `EnemyData.on_death_apply_to_player` is `"poisoned"` with `on_death_apply_magnitude` = 2 and the player has no active Poisoned
- **THEN** a Poisoned StatusInstance with magnitude 2 and remaining_ticks = current cycle remaining ticks is created on the player

#### Scenario: resolve_enemy_turns step 7d — IntentWeight handlers executed after status_apply
- **WHEN** a Witness enemy's selected IntentWeight has `handlers: [{ "handler_id": "apply_mending_by_burden_tier" }]` and `game_state.item_burden_score` is 10 (Medium tier)
- **THEN** after step 7c (status_apply), AbilityPipeline executes apply_mending_by_burden_tier; the handler reads `item_burden_score`, determines Medium tier, and applies Mending magnitude 3 to The Judge using max-wins rules

### Requirement: [LLD-ARCH-020] AIPlayerAgent
AIPlayerAgent SHALL be a `RefCounted` subclass in `src/application/`. It implements the Random strategy: at each decision point, it calls `ActionInjector.get_legal_actions()` and selects uniformly at random using a dedicated local `RandomNumberGenerator` seeded independently (NOT from RNGService — AI decisions must not contaminate game RNG streams).

**Interface:**

```
play_turn(game_state: GameState) -> void
    Selects one legal action uniformly at random and submits it via ActionInjector.

run_to_completion(seed: int, vessel_id: String) -> RunResult
    Starts a new run with the given seed and vessel, plays all decisions randomly
    until RUN_END phase, returns a RunResult.
```

**RunResult fields:** `seed: int`, `vessel_id: String`, `floors_completed: int`, `outcome: String` (`"death"` | `"completion"`), `turn_count: int`

The Random agent is the primary integration test for the full headless loop. It MUST be buildable as soon as ActionInjector and CombatResolver exist, before any content is complete.

#### Scenario: Random agent uses separate RNG
- **WHEN** AIPlayerAgent selects a random action
- **THEN** it uses its own local RandomNumberGenerator instance — never RNGService — so AI decisions do not advance any game RNG stream

#### Scenario: Random agent completes a run
- **WHEN** `run_to_completion(seed, "pilgrim")` is called with GameConfig.HEADLESS true
- **THEN** the run executes without rendering until RUN_END phase and returns a RunResult with outcome set

#### Scenario: Random agent as integration test
- **WHEN** a new seed is run twice with the Random agent
- **THEN** both runs produce identical RunResult values — the same turns, same loot, same outcome — confirming full determinism

---

### Requirement: [LLD-ARCH-021] TradeGenerator
TradeGenerator SHALL be a `RefCounted` subclass in `src/application/`. It is the sole system responsible for constructing trade offer arrays for Wandering Soul and Memory Fragment Category A and C encounters. It reads item pools from ItemRegistry, enforces the same-scale pairing rule (see `HLD-ITEMS-006`), applies the score tolerance formula (see `LLD-IR-010`), and resolves HP values via the HP conversion bucket tables (see `LLD-IR-009`). It uses the LOOT RNG stream (see `LLD-ARCH-008`) for all randomness. It does not modify GameState directly — it returns offer arrays that RunController stores for the encounter handler.

**Interface:**

```
generate_wandering_soul_offers(game_state: GameState) -> Array[Dictionary]
    Returns 2–3 trade offer Dictionaries for a Wandering Soul encounter.
    Always includes at least one HP-for-item offer (see HLD-WS-003).
    Item-for-item offers pair items from the same scoring scale within the ±20%
    tolerance window (see LLD-IR-010). HP amounts are resolved from LLD-IR-009 buckets.
    Uses LOOT stream for all item selection rolls.

generate_category_a_offer(game_state: GameState) -> Dictionary
    Returns one fair trade offer Dictionary for a Memory Fragment Category A encounter.
    Cost and reward are within the ±20% score tolerance window (see LLD-IR-010).
    Both sides are from the same scoring scale.

generate_category_c_offers(game_state: GameState) -> Array[Dictionary]
    Returns exactly two offer Dictionaries for a Memory Fragment Category C encounter.
    Option 1's cost exceeds the reward score by at least 50% above the fair tolerance
    window (see LLD-IR-010 and HLD-MF-005).
    Option 2 is a straight loss — cost with no reward.
    Uses LOOT stream for item selection.

is_fair_trade(score_a: int, score_b: int) -> bool
    Returns true when |score_a - score_b| ≤ 0.20 × max(score_a, score_b).
    Pure utility — no RNG, no registry access.

hp_for_score(score: int, scale: String) -> int
    Returns the HP bucket value for the given item score on the given scale
    ("durability" or "consumable"). Reads from LLD-IR-009 bucket tables.
    Returns 0 if the scale is unrecognised or the HP amounts are not yet set ([OPEN·MVP2]).
```

**TradeOffer Dictionary format** (all offers use this shape for GameState serialisability):

```
{
    "offer_type": String,      # "item_for_item" | "item_for_hp" | "hp_for_item" | "consumable_for_item" | "loss_only"
    "give_item_id": String,    # ability_id of the item the player gives up; "" if HP cost
    "give_hp": int,            # HP the player pays; 0 if item cost
    "receive_item_id": String, # ability_id of the item the player receives; "" if HP reward
    "receive_hp": int,         # HP the player receives; 0 if item reward
}
```

#### Scenario: Wandering Soul always includes HP-for-item offer
- **WHEN** `generate_wandering_soul_offers` is called
- **THEN** at least one returned offer has `offer_type: "hp_for_item"`; this offer is never absent regardless of inventory state

#### Scenario: Item-for-item pair from same scale within tolerance
- **WHEN** `generate_wandering_soul_offers` generates an item-for-item trade
- **THEN** both `give_item_id` and `receive_item_id` resolve to items on the same scoring scale (both Durability or both Consumable), and `is_fair_trade(score_give, score_receive)` returns true

#### Scenario: is_fair_trade boundary — within tolerance
- **WHEN** `is_fair_trade(40, 49)` is called (gap = 9, 9/49 ≈ 18%)
- **THEN** returns true

#### Scenario: is_fair_trade boundary — outside tolerance
- **WHEN** `is_fair_trade(20, 49)` is called (gap = 29, 29/49 ≈ 59%)
- **THEN** returns false

#### Scenario: Category C Option 1 cost exceeds tolerance threshold
- **WHEN** `generate_category_c_offers` produces an Option 1 offer with reward score R
- **THEN** the cost score C satisfies C ≥ R × 1.70 (50% above the ±20% fair window upper bound of R × 1.20)

#### Scenario: TradeGenerator uses LOOT stream only
- **WHEN** `generate_wandering_soul_offers` or any generate method rolls for item selection
- **THEN** all random calls use the LOOT RNG stream; no other stream is consumed

#### Scenario: hp_for_score returns zero for OPEN bucket
- **WHEN** `hp_for_score` is called before HP bucket amounts are set ([OPEN·MVP2])
- **THEN** it returns 0; the caller substitutes a placeholder and the offer is skipped or deferred

---

### Requirement: [LLD-ARCH-022] LootGenerator
LootGenerator SHALL be a `RefCounted` subclass in `src/application/`. It is the sole system responsible for constructing the two-item loot offer array presented to the player in the `LOOT_SELECTION` phase after each combat. It selects items from the normal or elite drop pools based on whether the preceding combat was an elite encounter. It uses the LOOT RNG stream for all randomness and does not modify GameState directly — it returns an `Array[String]` of item_ids that RunController stores in `NavigationState.loot_offers`.

**Interface:**

```
generate_loot_offers(game_state: GameState, elite: bool) -> Array[String]
    Returns exactly 2 item_id strings.
    elite=true: draws from elite durability pool (LLD-ITEMS-006) and elite consumable
      pool (LLD-ITEMS-008).
    elite=false: draws from normal durability pool (LLD-ITEMS-005) and normal consumable
      pool (LLD-ITEMS-007).
    One item is drawn from the durability pool and one from the consumable pool, giving
    the player a meaningful choice between an attack/support item and a consumable.
    Both draws use the LOOT RNG stream.
    If a pool is empty (e.g. no consumables defined yet), both draws come from the
    non-empty pool. If both pools are empty, returns an empty Array (RunController
    transitions directly to NAVIGATION — same as DECLINE_LOOT).
```

#### Scenario: Elite combat produces elite loot offers
- **WHEN** `generate_loot_offers` is called with `elite: true`
- **THEN** both returned item_ids are drawn from the elite pools only; no normal-tier items appear

#### Scenario: Normal combat produces normal loot offers
- **WHEN** `generate_loot_offers` is called with `elite: false`
- **THEN** both returned item_ids are drawn from the normal pools only; no elite-tier items appear

#### Scenario: One durability, one consumable
- **WHEN** `generate_loot_offers` produces two items from non-empty pools
- **THEN** one item_id is from the durability pool for that tier and one is from the consumable pool; the player always has a weapon/support option and a consumable option

#### Scenario: LootGenerator uses LOOT stream only
- **WHEN** `generate_loot_offers` makes any random selection
- **THEN** all random calls use the LOOT RNG stream; no other stream is consumed

---

### Requirement: [LLD-ARCH-023] Shift Status Resolution Order
When multiple shift-triggered `StatusInstance`s (those with `trigger: "shift"` and `remaining_ticks == 0`) fire at Step 1 of `resolve_omen_cycle_start`, they SHALL be processed in the following order for each unit:

1. `death_mark` — the unit dies instantly; all remaining shift statuses on that unit are skipped
2. `shocked` — set `is_stunned = true` on the unit
3. `exposed` — mark the unit as pending Vulnerable (Physical) application (resolved at Step 4)

Any future shift-trigger statuses not listed here are processed after `exposed` in definition order.

#### Scenario: Death Mark fires before Shocked on same unit
- **WHEN** an enemy has both `death_mark` and `shocked` StatusInstances at remaining_ticks == 0 at the omen shift
- **THEN** `death_mark` fires first — the enemy dies; `shocked` does not set `is_stunned` on that unit (it is already dead)

#### Scenario: Death Mark does not affect other units' shift statuses
- **WHEN** enemy A has `death_mark` and enemy B has `shocked`, both at remaining_ticks == 0
- **THEN** enemy A dies from `death_mark`; enemy B's `shocked` processes normally and sets `is_stunned = true` on enemy B

