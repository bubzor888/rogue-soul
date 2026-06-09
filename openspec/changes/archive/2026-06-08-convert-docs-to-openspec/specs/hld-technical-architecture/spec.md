## ADDED Requirements

### Requirement: [HLD-ARCH-001] Four-Layer Architecture
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

### Requirement: [HLD-ARCH-002] Headless Execution
The game loop SHALL have zero dependency on rendering or input devices. Domain layer classes run in headless mode for simulation and testing.

#### Scenario: AI player runs headless
- **WHEN** GameConfig.HEADLESS is true
- **THEN** a complete run can execute via AIPlayerAgent without any scene tree or display

---

### Requirement: [HLD-ARCH-003] Action Command Pattern
All game decisions SHALL be serialisable Dictionary commands. ActionInjector is the single interface through which all decisions (from UI, AI, or debug tools) enter the game loop.

```
{ "type": "USE_ABILITY", "ability_id": "slash", "target_id": "enemy_0" }
{ "type": "USE_ITEM", "slot_index": 2, "target_id": "self" }
{ "type": "END_TURN" }
{ "type": "CHOOSE_DOOR", "room_id": "room_12" }
{ "type": "CHOOSE_DEPTH", "depth": 2 }
{ "type": "SET_DEFAULT_ROW", "unit_id": "vessel", "row": "FRONT" }
```

`get_legal_actions()` MUST always return at least one valid action in a non-terminal state. `submit_action()` with an illegal action MUST log an error and return state unchanged — never throw.

#### Scenario: Illegal action safety
- **WHEN** an illegal action is submitted to ActionInjector
- **THEN** the game state is unchanged and an error is logged; no exception is raised

---

### Requirement: [HLD-ARCH-004] GameState Immutability
GameState SHALL be treated as immutable by convention — methods return a new state rather than mutating in place. `GameState.clone()` is a first-class requirement.

#### Scenario: State branching for AI
- **WHEN** the AIPlayerAgent evaluates multiple action options
- **THEN** it can clone GameState and simulate each branch without side effects on the real game state

---

### Requirement: [HLD-ARCH-005] Ability Pipeline (Chain of Responsibility)
Vessel abilities and items SHALL both execute through the same AbilityPipeline using a Chain of Responsibility pattern. An ability/item is an ordered list of HandlerConfig entries. New vessel abilities are data files; new code is only required for genuinely novel effects.

#### Scenario: New vessel ability, no new code
- **WHEN** a new vessel ability is defined using only existing handlers
- **THEN** the new ability is a .tres data file only — no AbilityHandler subclass is written

#### Scenario: Handler startup validation
- **WHEN** the game starts
- **THEN** AbilityRegistry validates that every handler_id in every ability/item chain resolves to a known handler; unknown IDs are a fatal startup error

---

### Requirement: [HLD-ARCH-006] Registry + Data Files Pattern
VesselRegistry, ItemRegistry, and AbilityRegistry SHALL discover content via directory scan at startup. New content is added by adding files — no registration code required.

#### Scenario: New vessel added
- **WHEN** a new VesselData .tres file is placed in `data/vessels/`
- **THEN** the game discovers and loads it at startup without any code change

---

### Requirement: [HLD-ARCH-007] Autoloads
The following SHALL be implemented as Godot Autoloads (global singletons):

| Autoload | Layer | Role |
|---|---|---|
| GameConfig | Infrastructure | Environment flags (HEADLESS, DEBUG), global constants |
| RNGService | Infrastructure | All randomness via named streams; randf() is never called directly |
| EventLog | Infrastructure | Structured JSON event recorder; flushed at floor transitions |
| PersistenceService | Infrastructure | All FileAccess abstracted here |
| ScreenManager | Application | Owns all scene transitions; reacts to RunController.phase_changed |
| SaveManager | Application | Coordinates save/load; listens to RunController signals |
| SignalBus | Application | Global signals for cross-cutting events |

#### Scenario: No direct FileAccess
- **WHEN** any domain or application class needs to read/write files
- **THEN** it MUST call PersistenceService — never FileAccess directly

---

### Requirement: [HLD-ARCH-008] RNG Streams
All randomness SHALL flow through RNGService named streams. The global `randf()` function is never called anywhere in the codebase.

| Stream | Usage |
|---|---|
| NAVIGATION | Room sequence generation |
| COMBAT | Combat RNG (hit rolls, etc.) |
| LOOT | Item drops |
| EVENTS | Non-combat event outcomes |

#### Scenario: Seeded reproducibility
- **WHEN** a run is started with the same seed
- **THEN** the same room sequence, combat outcomes, and loot drops are produced

---

### Requirement: [HLD-ARCH-009] SignalBus Decoupling
Domain code SHALL emit on SignalBus for cross-cutting events. Presentation code connects to SignalBus. Neither layer knows about the other.

Key signals: `companion_died`, `codex_entry_added`, `item_broken`.

#### Scenario: Domain-presentation decoupling
- **WHEN** a companion dies in domain code
- **THEN** the domain emits SignalBus.companion_died; the presentation layer reacts without the domain knowing a UI exists

---

### Requirement: [HLD-ARCH-010] Save Format and Migration
Save data SHALL be stored as JSON for debuggability and forward compatibility. GameConfig.SAVE_VERSION is written to every save. Version mismatch on load triggers a migration path.

#### Scenario: Save version migration
- **WHEN** a save file with an older SAVE_VERSION is loaded
- **THEN** PersistenceService applies the appropriate migration function before returning data

---

### Requirement: [HLD-ARCH-011] Charge Management
ChargeManager SHALL handle all replenishment events for both abilities and items. Replenishment event IDs are plain strings defined as constants in ReplenishEvents. Items break at zero if `breaks_at_zero: true`. Abilities never break.

#### Scenario: Replenishment event fires
- **WHEN** RunController fires a replenishment event (e.g. "floor_start")
- **THEN** ChargeManager restores charges for all abilities/items whose replenish_triggers contains that event ID

#### Scenario: Item breaks at zero
- **WHEN** an item's remaining_charges reaches 0 and breaks_at_zero is true
- **THEN** ActionInjector removes the ItemInstance from the slot and emits SignalBus.item_broken

---

### Requirement: [HLD-ARCH-012] Open Technical Decisions
The following architectural decisions are unresolved (see design doc §9):

- **T-2** Action economy: AP pool vs discrete flags
- **T-3** Enemy intent: telegraphed or hidden
- **T-4** Starting inventory size and maximum
- **T-5** Item acquisition: loot drops, merchant, or both
- **T-6** Soul-carried items: shared slots or separate soul layer
- **T-7** Bound companion revival mechanism
- **T-8** Bound + summoned companions simultaneously
- **T-9** MVP vessel count (minimum 3 suggested)
- **T-10** Web export target and timeline

#### Scenario: [OPEN] T-2 through T-10 resolution
- **WHEN** implementation of the relevant module begins
- **THEN** the corresponding open decision MUST be resolved before proceeding
