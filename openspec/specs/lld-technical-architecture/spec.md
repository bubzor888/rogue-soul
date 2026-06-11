
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
```

`get_legal_actions()` MUST always return at least one valid action in a non-terminal state. `submit_action()` with an illegal action MUST log an error and return state unchanged — never throw.

#### Scenario: Illegal action safety
- **WHEN** an illegal action is submitted to ActionInjector
- **THEN** the game state is unchanged and an error is logged; no exception is raised

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
| `item_acquired(item_id)` | RunController | String | EventLog |
| `room_entered(room_type, encounter_id)` | RunController | String, String | EventLog |
| `floor_transitioned(from_floor, to_floor)` | RunController | int, int | EventLog |

#### Scenario: Domain-presentation decoupling
- **WHEN** CombatResolver applies damage
- **THEN** it emits `SignalBus.damage_dealt`; the presentation layer updates health bars without CombatResolver knowing any UI exists

#### Scenario: EventLog subscribes via SignalBus
- **WHEN** any logged event signal fires on SignalBus
- **THEN** EventLog's connected handler writes the event to the in-memory buffer — no domain class calls EventLog directly

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

**VesselState fields:** `vessel_id: String`, `hp: int`, `max_hp: int`, `ability_states: Array[AbilityState]`, `active_statuses: Array[StatusInstance]`

**AbilityState fields:** `ability_id: String`, `remaining_charges: int`

**ItemInstance fields:** `item_id: String`, `remaining_charges: int`

**StatusInstance fields:** `status_id: String`, `remaining_ticks: int`, `magnitude: int` (used for statuses whose numeric value evolves over ticks: Chilled's accumulating flat damage reduction, Poisoned's current damage value, Bleed's current stack count; 0 for statuses that do not use it)

**CompanionState fields:** `companion_id: String`, `ability_states: Array[AbilityState]` (for companion abilities with charges), `companion_timer: int` (generic countdown for companions with a budget, e.g. Shadow's 20 HP drain limit; copied from `CompanionData.initial_timer` on activation; -1 = not used by this companion; decremented by CombatResolver when the timer-consuming effect fires; companion departs when this reaches 0), `companion_context: Dictionary` (companion-specific runtime state not covered by standard fields, e.g. Shadow's `{ "current_target_instance_id": "wolf_0" }`; read and written by the companion's handler chain). No `hp` field — companions are not targetable in combat (see `HLD-COMPANION-001`).

**NavigationState fields:** `rooms_completed_this_floor: int`, `segment_room_counts: Dictionary` (room type → count, for pool exhaustion per `HLD-DOOR-004`), `doors_ahead: Array[DoorData]` (the current two-door choice; empty outside NAVIGATION phase), `companion_offered_this_floor: bool` (true once any companion encounter has fired this floor — Worn Map or Memory Fragment; blocks further companion draws from MF pool per `HLD-MF-004`)

**DoorData fields:** `room_type: String` (RoomType enum value), `encounter_id: String` (enemy_id for combat; event_id for non-combat), `room_id: String` (unique per-run identifier for logging)

**CombatState fields:** `enemies: Array[EnemyState]`, `turn_number: int`, `omen_deck: OmenDeckState`, `current_cycle: OmenCycleState` (null between cycles)

**EnemyState fields:** `enemy_id: String`, `instance_id: String` (unique per-combat, e.g. `"skeleton_0"` and `"skeleton_1"` for two Skeletons — enables individual targeting), `hp: int`, `max_hp: int`, `active_statuses: Array[StatusInstance]`, `current_intent: String` (intent type ID set at start of each enemy turn; empty string if not yet set), `last_intent_id: String` (intent type ID selected on the previous turn; empty string at combat start), `intent_streak: int` (number of consecutive turns the current intent has been selected; resets to 1 on intent change, increments on repeat; 0 at combat start), `is_charging: bool` (true when a Charge→Release intent is in the charge phase; the release fires on the next turn unconditionally)

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

#### Scenario: StatusInstance magnitude tracks Chilled accumulation
- **WHEN** a unit with Chilled status reaches tick 2
- **THEN** the StatusInstance for Chilled has `magnitude` equal to the accumulated flat damage reduction (sum of tick 1 reduction + tick 2 reduction); CombatResolver reads this value when calculating outgoing damage

#### Scenario: StatusInstance magnitude tracks Poisoned value
- **WHEN** a unit has the Poisoned status and an omen tick occurs
- **THEN** CombatResolver reads `magnitude` as the current poison damage value, deals that damage, then writes `magnitude * 3` back as the new value for the next tick

#### Scenario: StatusInstance magnitude tracks Bleed stacks
- **WHEN** a Bleed status is applied to a unit with 5 stacks
- **THEN** the StatusInstance for Bleed has `magnitude` set to 5; after the first tick it is set to 2 (floor(5/2)); CombatResolver reads and writes this value each tick

#### Scenario: Intent streak resets on change
- **WHEN** an enemy selects a different intent than last turn
- **THEN** `last_intent_id` is updated to the new intent and `intent_streak` is set to 1

#### Scenario: Intent streak increments on repeat
- **WHEN** an enemy selects the same intent as last turn
- **THEN** `intent_streak` increments by 1 before the consecutive cap check is applied

#### Scenario: Charge→Release state persists across turns
- **WHEN** an enemy begins a Charge→Release intent
- **THEN** `is_charging` is set to true; on the next turn CombatResolver checks this flag before rolling a new intent

---

### Requirement: [LLD-ARCH-018] Data Resource Schemas
The following Resource subclasses SHALL define the schema for all `.tres` content files loaded by registries at startup (see `LLD-ARCH-006`). These are the data-side of the HLD/LLD boundary — the engine knows the schema; content files supply the values.

**AbilityData** (used for both vessel abilities AND items — items are abilities with `breaks_at_zero: true`):

| Field | Type | Notes |
|---|---|---|
| `ability_id` | String | Unique identifier; matches filename convention |
| `display_name` | String | Player-visible name |
| `action_bucket` | String | `"attack"` \| `"support"` \| `"consumable"` \| `"passive"` |
| `max_charges` | int | 0 = unlimited (passive, default strike) |
| `breaks_at_zero` | bool | true for items; false for vessel abilities |
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
| `enemy_tags` | Array[String] | e.g. `["undead"]`, `["beast"]`, `["elemental_fire"]` — used by omen card effects |
| `omen_contributions` | Array[String] | Card IDs added to deck while this enemy is alive |
| `intent_weights` | Array[IntentWeight] | Weighted random pool (evaluated if no conditional matches) |
| `intent_conditionals` | Array[IntentConditional] | Evaluated first; first match short-circuits the roll |

**IntentWeight:**

| Field | Type | Notes |
|---|---|---|
| `intent_id` | String | Unique identifier for this intent within the enemy (e.g. `"strike"`, `"chill_touch"`, `"slam"`) |
| `weight` | int | Relative weight; higher = more likely; all weights in the table are summed to determine probability |
| `damage_min` | int | Minimum damage on execution; 0 for non-damage intents |
| `damage_max` | int | Maximum damage on execution; 0 for non-damage intents; MUST be ≥ damage_min |
| `is_charge_release` | bool | true if this intent uses the Charge→Release two-turn pattern (see `HLD-COMBAT-014`) |
| `max_consecutive` | int | Maximum times this intent may be selected consecutively; 0 = no limit |
| `status_apply` | String | Status ID to apply on execution; empty string if none |

**IntentConditional:**

| Field | Type | Notes |
|---|---|---|
| `condition` | String | e.g. `"hp_below_percent:50"`, `"ally_count_above:1"`, `"turn_number:1"` |
| `intent_id` | String | Intent selected when condition is true; must match an intent_id in intent_weights |

**CompanionData:**

| Field | Type | Notes |
|---|---|---|
| `companion_id` | String | |
| `display_name` | String | |
| `omen_contributions` | Array[String] | Card IDs added while companion is active |
| `trigger` | String | Trigger type ID (see `HLD-COMPANION-003`): `"turn_end"` or `"vessel_death_intercept"` |
| `handlers` | Array[HandlerConfig] | Executed via AbilityPipeline on trigger |
| `granted_ability_id` | String | ability_id of the active ability granted to the vessel while this companion is active; empty string if none; loaded from AbilityRegistry at startup |
| `initial_timer` | int | Starting value for `CompanionState.companion_timer`; 0 = this companion does not use the timer |
| `departure_trigger` | String | Condition that causes departure: `"ability_used"` (granted ability was used), `"timer_exhausted"` (companion_timer reached 0), `"intercept_triggered"` (vessel_death_intercept fired), `"after_boss_only"` (no mid-floor condition) |

#### Scenario: Item uses AbilityData schema
- **WHEN** the Walking Staff item is defined as a `.tres` file
- **THEN** it uses AbilityData with `action_bucket: "attack"`, `breaks_at_zero: true`, `max_charges: 6`, and one HandlerConfig entry `{ handler_id: "deal_damage", params: { base_damage: 6, damage_type: "physical" } }`

#### Scenario: Enemy conditional intent overrides random
- **WHEN** CombatResolver resolves an enemy's intent and an IntentConditional matches (e.g. HP < 50%)
- **THEN** the matched intent_id is selected without rolling the COMBAT RNG stream; the weighted roll is skipped entirely

#### Scenario: Enemy weighted intent uses COMBAT stream
- **WHEN** no IntentConditional matches for an enemy
- **THEN** CombatResolver performs one weighted roll against the COMBAT RNG stream to select from intent_weights

#### Scenario: Damage range defines per-intent variance
- **WHEN** an enemy's intent with damage_min 2 and damage_max 4 executes
- **THEN** CombatResolver rolls one value in [2, 4] inclusive using the COMBAT stream and applies that as base damage

#### Scenario: Non-damage intent has zero damage fields
- **WHEN** an enemy's intent has damage_min 0 and damage_max 0
- **THEN** no damage is dealt; any status_apply field is processed if non-empty

#### Scenario: Startup validation rejects unknown handler_id
- **WHEN** the game starts and AbilityRegistry loads a HandlerConfig with an unregistered handler_id
- **THEN** the game fails with a fatal error before the first frame (per `LLD-ARCH-005`)

---

### Requirement: [LLD-ARCH-019] CombatResolver
CombatResolver SHALL be a `RefCounted` subclass in `src/domain/`. It is the sole authority for all combat rule application — damage calculation, status effect resolution, enemy intent selection, omen tick processing, and legal action generation. No other class applies combat rules.

CombatResolver receives `RNGService` as a constructor dependency. It MUST NOT access any autoload directly — all external dependencies are injected.

**Interface:**

```
get_legal_combat_actions(game_state: GameState) -> Array[Dictionary]
    Returns all valid player actions for the current combat turn.
    Always returns at least one action (Default Strike is always legal).
    If an active companion (bound or temporary) has a non-empty granted_ability_id, the
    corresponding AbilityData is included as a legal action using its configured action_bucket.
    For Raven Mark specifically, only non-elite, non-boss living enemies are valid targets.

resolve_player_action(action: Dictionary, game_state: GameState) -> GameState
    Applies one player action. Returns updated GameState.
    Runs the handler chain via AbilityPipeline.
    Applies vulnerability, resistance, and damage modifier rules from hld-combat-system.
    If the resolved action used a companion's granted_ability_id and the companion's
    departure_trigger is "ability_used", the companion departs as part of this resolution.

resolve_enemy_turns(game_state: GameState) -> GameState
    Resolves all living enemies' turns in order.
    For each enemy:
      1. If enemy.is_charging is true: execute the release of the Charge→Release intent
         (roll damage in [damage_min, damage_max] using COMBAT stream and/or apply status_apply);
         set is_charging to false.
      2. Otherwise: evaluate intent_conditionals first; if a condition matches, force that intent_id.
         If no condition matches, roll the COMBAT stream against intent_weights.
      3. Consecutive cap check (step 2 only): if the selected intent_id equals last_intent_id
         AND intent_streak >= max_consecutive AND max_consecutive > 0, re-roll until a different
         intent_id is selected.
      4. Update last_intent_id and intent_streak on EnemyState.
      5. If the selected intent has is_charge_release true: set is_charging to true; show charge
         indicator; deal no damage this turn.
      6. Otherwise execute the intent: roll damage in [damage_min, damage_max] using COMBAT stream
         (if damage_max > 0); apply status_apply if non-empty (subject to HLD-COMBAT-015 for Chilled).
    Sets current_intent on EnemyState for display.

resolve_companion_trigger(trigger_id: String, game_state: GameState) -> GameState
    Fires the companion's handler chain if a companion is active and its trigger matches.
    For "turn_end" companions with a timer: after the handler chain resolves, decrements
    companion_timer by the amount consumed (capped at actual effect — e.g. if enemy had 1 HP,
    only 1 is subtracted). If companion_timer reaches 0 and departure_trigger is
    "timer_exhausted", the companion departs immediately.

check_vessel_death_intercept(game_state: GameState) -> GameState
    Called synchronously when vessel HP reaches 0, BEFORE unit_died is emitted.
    If an active companion has trigger == "vessel_death_intercept":
      1. Run the companion's handler chain (e.g. restore vessel HP to 5)
      2. Depart the companion (set temporary_companion or bound_companion to null)
      3. Return updated GameState with vessel alive — unit_died is NOT emitted
    If no such companion is active, returns game_state unchanged and unit_died proceeds normally.

resolve_omen_tick(game_state: GameState) -> GameState
    Advances one omen tick: applies per-turn status effects (Burning, Chilled, Poisoned,
    Mending, Hardened, Grave Knit), decrements remaining_ticks, clears expired statuses.

resolve_omen_cycle_start(game_state: GameState) -> GameState
    Draws 3 cards from OmenDeckState into OmenCycleState. Reshuffles discard into draw
    pile first if draw pile has fewer than 3 cards.

assemble_omen_deck(sources: Array[String], game_state: GameState) -> GameState
    Builds OmenDeckState from all contributing sources (vessel, enemies, items, companions).
    Assigns timer values to every card using the COMBAT RNG stream per LLD-OMEN-MECH-008:
    25% chance value 1, 50% chance value 2, 25% chance value 3. Stores each entry as
    { card_id, timer_value } in the draw pile. Called once at combat start before any draws.
    Enemy contributions follow the two-tier model (HLD-OMEN-006): family cards are added
    once per enemy instance; type cards are added once per enemy type present. The deck entry
    for a type card MUST carry a reference to its owning enemy type so removal on last-of-type
    death can be performed correctly.

resolve_enemy_death(unit_id: String, game_state: GameState) -> GameState
    Removes the dead enemy's family card copy from draw_pile and discard_pile immediately.
    Also checks whether this was the last living enemy of its type; if so, removes that
    type's type card from draw_pile and discard_pile as well (per HLD-OMEN-006).
    Cards already drawn into OmenCycleState.drawn_cards are NOT removed — they complete
    their current cycle.
```

**Damage resolution order** (applied in this sequence for every hit):
1. Base damage: for player attacks, the flat value from HandlerConfig params; for enemy attacks, a value rolled in [damage_min, damage_max] using the COMBAT stream (see `HLD-COMBAT-016`)
2. Passive modifiers (Last Stand ×1.5 if active)
3. Buff modifiers (Charged ×2 if active, consumed after)
4. Resistance (×0.5 if target resists damage type)
5. Vulnerability (×1.5 if target is vulnerable to damage type)
6. Resistance + Vulnerability cancel: if both apply to the same type → net ×1.0
7. Clamp to minimum 1 (no hit ever deals 0 damage unless explicitly blocked)

#### Scenario: Legal actions always include Default Strike
- **WHEN** the vessel has zero item charges remaining and no ability charges
- **THEN** `get_legal_combat_actions()` returns exactly one action: the Default Strike

#### Scenario: Damage resolution order — Last Stand + Charge + Vulnerability
- **WHEN** the Hedge Knight (HP < 25%) uses Charge and attacks a Vulnerable (Physical) enemy with a 7-damage weapon
- **THEN** damage = 7 × 1.5 (Last Stand) × 2.0 (Charge) × 1.5 (Vulnerable) = 31 (rounded down)

#### Scenario: Resistance cancels Vulnerability
- **WHEN** CombatResolver resolves a fire attack against a Fire Elemental that also has Vulnerable (Fire) applied
- **THEN** the resistance (×0.5) and vulnerability (×1.5) cancel; the attack deals base damage × 1.0

#### Scenario: Enemy intent conditional short-circuits roll
- **WHEN** an enemy has a `"turn_number:1"` conditional mapped to `"sleeping"` and it is the first turn
- **THEN** `current_intent` is set to `"sleeping"` with no COMBAT stream roll

#### Scenario: Enemy consecutive re-roll
- **WHEN** an enemy rolls an intent and intent_streak >= max_consecutive for that intent
- **THEN** the COMBAT stream is rolled again; this repeats until a different intent_id is produced

#### Scenario: Charge→Release executes release unconditionally
- **WHEN** `resolve_enemy_turns` processes an enemy with is_charging true
- **THEN** the release damage is applied immediately without a new intent roll; is_charging is set to false

#### Scenario: Omen deck reshuffles when empty
- **WHEN** `resolve_omen_cycle_start` is called and the draw pile has fewer than 3 cards
- **THEN** the discard pile is shuffled into the draw pile first (using COMBAT stream), then 3 cards are drawn

#### Scenario: Companion granted ability in legal actions
- **WHEN** the vessel has an active companion with `granted_ability_id: "raven_mark"`
- **THEN** `get_legal_combat_actions()` includes the Raven Mark ability action using the Support bucket; elite enemies and the boss are excluded from valid targets

#### Scenario: vessel_death_intercept fires on any death source
- **WHEN** a Burning tick reduces the vessel to 0 HP while The Life Mote is active
- **THEN** `check_vessel_death_intercept` fires; vessel HP is set to 5; The Life Mote departs; `unit_died` is NOT emitted; combat continues

#### Scenario: Shadow timer depletes and companion departs mid-fight
- **WHEN** The Shadow's `companion_timer` reaches 0 during `resolve_companion_trigger`
- **THEN** The Shadow departs immediately as part of that resolution; it does not wait for the fight to end

---

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
