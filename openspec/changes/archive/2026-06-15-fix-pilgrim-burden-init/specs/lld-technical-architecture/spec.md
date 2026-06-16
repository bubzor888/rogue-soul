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
