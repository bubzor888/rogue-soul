## MODIFIED Requirements

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
