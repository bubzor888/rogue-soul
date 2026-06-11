## MODIFIED Requirements

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
| companions | Companion summoned, companion damaged, companion died |
| rng | Every roll: stream, call index, raw value, resolved outcome (debug mode only) |
| meta | Run started (seed, vessel), run ended (seed, vessel, floor, outcome) |

**Buffer and flush policy:** The EventLog MUST use an in-memory buffer during play. The buffer SHALL be flushed to file at: (1) every floor transition, (2) every boss completion, (3) run end (death or completion). This bounds data loss on crash to the current floor's events. Continuous per-event file I/O is NOT permitted.

**RNG roll logging:** Raw RNG roll events (category: `rng`) SHALL only be written when `GameConfig.DEBUG` is true. Outcome events (damage dealt, item acquired, room generated) are always logged regardless of debug state.

**Log storage:** Logs are written via `PersistenceService` (per `LLD-ARCH-007`). Each run produces one log file. Log files are retained in the `playtests/` directory.

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
