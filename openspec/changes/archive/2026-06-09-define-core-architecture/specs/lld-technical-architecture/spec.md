## MODIFIED Requirements

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

## ADDED Requirements

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

**StatusInstance fields:** `status_id: String`, `remaining_ticks: int`, `magnitude: int` (used by Chilled's accumulating flat reduction; 0 for statuses with no magnitude)

**CompanionState fields:** `companion_id: String`, `ability_states: Array[AbilityState]` (for companion abilities with charges). No `hp` field — companions are not targetable in combat (see `HLD-COMPANION-001`).

**NavigationState fields:** `rooms_completed_this_floor: int`, `segment_room_counts: Dictionary` (room type → count, for pool exhaustion per `HLD-DOOR-004`), `doors_ahead: Array[DoorData]` (the current two-door choice; empty outside NAVIGATION phase)

**DoorData fields:** `room_type: String` (RoomType enum value), `encounter_id: String` (enemy_id for combat; event_id for non-combat), `room_id: String` (unique per-run identifier for logging)

**CombatState fields:** `enemies: Array[EnemyState]`, `turn_number: int`, `omen_deck: OmenDeckState`, `current_cycle: OmenCycleState` (null between cycles)

**EnemyState fields:** `enemy_id: String`, `instance_id: String` (unique per-combat, e.g. `"skeleton_0"` and `"skeleton_1"` for two Skeletons — enables individual targeting), `hp: int`, `max_hp: int`, `active_statuses: Array[StatusInstance]`, `current_intent: String` (intent type ID set at start of each enemy turn; empty string if not yet set)

**OmenDeckState fields:** `draw_pile: Array[String]` (card IDs), `discard_pile: Array[String]`

**OmenCycleState fields:** `drawn_cards: Array[String]` (exactly 3 card IDs), `player_choice_index: int` (-1 = not yet chosen), `random_assignment_index: int` (-1 = not yet assigned), `timer_index: int` (index into drawn_cards for the timer card), `sides_assigned: bool`

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
| `base_damage` | int | Damage per attack before modifiers |
| `damage_type` | String | Damage type ID |
| `resistances` | Array[String] | Damage type IDs this enemy resists (×0.5) |
| `enemy_tags` | Array[String] | e.g. `["undead"]`, `["beast"]`, `["elemental_fire"]` — used by omen card effects |
| `omen_contributions` | Array[String] | Card IDs added to deck while this enemy is alive |
| `intent_weights` | Array[IntentWeight] | Weighted random pool (evaluated if no conditional matches) |
| `intent_conditionals` | Array[IntentConditional] | Evaluated first; first match short-circuits the roll |

**IntentWeight:**

| Field | Type | Notes |
|---|---|---|
| `intent_type` | String | e.g. `"attack"`, `"defend"`, `"special_buff"` |
| `weight` | int | Relative weight; higher = more likely |

**IntentConditional:**

| Field | Type | Notes |
|---|---|---|
| `condition` | String | e.g. `"hp_below_percent:50"`, `"ally_count_above:1"` |
| `intent_type` | String | Intent selected when condition is true |

**CompanionData:**

| Field | Type | Notes |
|---|---|---|
| `companion_id` | String | |
| `display_name` | String | |
| `omen_contributions` | Array[String] | Card IDs added while companion is active |
| `trigger` | String | ReplenishEvents constant ID (e.g. `"turn_end"`) |
| `handlers` | Array[HandlerConfig] | Executed via AbilityPipeline on trigger |

#### Scenario: Item uses AbilityData schema
- **WHEN** the Walking Staff item is defined as a `.tres` file
- **THEN** it uses AbilityData with `action_bucket: "attack"`, `breaks_at_zero: true`, `max_charges: 6`, and one HandlerConfig entry `{ handler_id: "deal_damage", params: { base_damage: 6, damage_type: "physical" } }`

#### Scenario: Enemy conditional intent overrides random
- **WHEN** CombatResolver resolves an enemy's intent and an IntentConditional matches (e.g. HP < 50%)
- **THEN** that intent is selected without rolling the COMBAT RNG stream; the weighted roll is skipped entirely

#### Scenario: Enemy weighted intent uses COMBAT stream
- **WHEN** no IntentConditional matches for an enemy
- **THEN** CombatResolver performs one weighted roll against the COMBAT RNG stream to select from intent_weights

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

resolve_player_action(action: Dictionary, game_state: GameState) -> GameState
    Applies one player action. Returns updated GameState.
    Runs the handler chain via AbilityPipeline.
    Applies vulnerability, resistance, and damage modifier rules from hld-combat-system.

resolve_enemy_turns(game_state: GameState) -> GameState
    Resolves all living enemies' turns in order.
    For each enemy: evaluates intent_conditionals first, then rolls COMBAT stream
    against intent_weights if no conditional matched. Sets current_intent on EnemyState.

resolve_companion_trigger(trigger_id: String, game_state: GameState) -> GameState
    Fires the companion's handler chain if a companion is active and its trigger matches.

resolve_omen_tick(game_state: GameState) -> GameState
    Advances one omen tick: applies per-turn status effects (Burning, Chilled, Poisoned,
    Mending, Hardened, Grave Knit), decrements remaining_ticks, clears expired statuses.

resolve_omen_cycle_start(game_state: GameState) -> GameState
    Draws 3 cards from OmenDeckState into OmenCycleState. Reshuffles discard into draw
    pile first if draw pile has fewer than 3 cards.
```

**Damage resolution order** (applied in this sequence for every hit):
1. Base damage from HandlerConfig params
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
- **WHEN** a Plague Rat has `hp_below_percent:50` conditional mapped to `"burrow"` and its HP is 40% of max
- **THEN** `current_intent` is set to `"burrow"` with no COMBAT stream roll

#### Scenario: Omen deck reshuffles when empty
- **WHEN** `resolve_omen_cycle_start` is called and the draw pile has fewer than 3 cards
- **THEN** the discard pile is shuffled into the draw pile first (using COMBAT stream), then 3 cards are drawn

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
