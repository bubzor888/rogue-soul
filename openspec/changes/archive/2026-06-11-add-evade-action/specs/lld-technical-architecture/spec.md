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

**VesselState fields:** `vessel_id: String`, `hp: int`, `max_hp: int`, `ability_states: Array[AbilityState]`, `active_statuses: Array[StatusInstance]`, `is_evading: bool` (true when the vessel chose Evade this turn; CombatResolver resets to false at the start of each player turn before any action is processed)

**AbilityState fields:** `ability_id: String`, `remaining_charges: int`

**ItemInstance fields:** `item_id: String`, `remaining_charges: int`

**StatusInstance fields:** `status_id: String`, `remaining_ticks: int`, `magnitude: int` (used for statuses whose numeric value evolves over ticks: Chilled's accumulating flat damage reduction, Poisoned's current damage value, Bleed's current stack count; 0 for statuses that do not use it)

**CompanionState fields:** `companion_id: String`, `ability_states: Array[AbilityState]` (for companion abilities with charges), `companion_timer: int` (generic countdown for companions with a budget, e.g. Shadow's 20 HP drain limit; copied from `CompanionData.initial_timer` on activation; -1 = not used by this companion; decremented by CombatResolver when the timer-consuming effect fires; companion departs when this reaches 0), `companion_context: Dictionary` (companion-specific runtime state not covered by standard fields, e.g. Shadow's `{ "current_target_instance_id": "wolf_0" }`; read and written by the companion's handler chain). No `hp` field — companions are not targetable in combat (see `HLD-COMPANION-001`).

**NavigationState fields:** `rooms_completed_this_floor: int`, `segment_room_counts: Dictionary` (room type → count, for pool exhaustion per `HLD-DOOR-004`), `doors_ahead: Array[DoorData]` (the current two-door choice; empty outside NAVIGATION phase), `companion_offered_this_floor: bool` (true once any companion encounter has fired this floor — Worn Map or Memory Fragment; blocks further companion draws from MF pool per `HLD-MF-004`)

**DoorData fields:** `room_type: String` (RoomType enum value), `encounter_id: String` (enemy_id for combat; event_id for non-combat), `room_id: String` (unique per-run identifier for logging)

**CombatState fields:** `enemies: Array[EnemyState]`, `turn_number: int`, `omen_deck: OmenDeckState`, `current_cycle: OmenCycleState` (null between cycles)

**EnemyState fields:** `enemy_id: String`, `instance_id: String` (unique per-combat, e.g. `"skeleton_0"` and `"skeleton_1"` for two Skeletons — enables individual targeting), `hp: int`, `max_hp: int`, `active_statuses: Array[StatusInstance]`, `current_intent: String` (intent type ID set at start of each enemy turn; empty string if not yet set), `last_intent_id: String` (intent type ID selected on the previous turn; empty string at combat start), `intent_streak: int` (number of consecutive turns the current intent has been selected; resets to 1 on intent change, increments on repeat; 0 at combat start), `is_charging: bool` (true when a Charge→Release intent is in the charge phase; the release fires on the next turn unconditionally), `is_evading: bool` (true when this enemy chose Evade on its turn; CombatResolver resets to false at the start of that enemy's resolution in resolve_enemy_turns)

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

#### Scenario: is_evading resets at start of player turn
- **WHEN** a new player turn begins and resolve_player_action is called
- **THEN** CombatResolver sets vessel_state.is_evading to false before any action is processed; Evade from the prior turn no longer applies

#### Scenario: Enemy is_evading resets at start of enemy resolution
- **WHEN** resolve_enemy_turns begins processing a specific enemy
- **THEN** that enemy's is_evading is set to false before intent selection; Evade from the prior turn no longer applies

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
| `is_evade` | bool | true if this intent is the Evade action; on selection CombatResolver sets EnemyState.is_evading = true; damage_min, damage_max, and status_apply are ignored |
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

#### Scenario: Enemy Evade intent sets is_evading
- **WHEN** an enemy's selected intent has is_evade: true
- **THEN** CombatResolver sets that enemy's is_evading to true and does not process damage_min, damage_max, or status_apply for that intent

---

### Requirement: [LLD-ARCH-019] CombatResolver
CombatResolver SHALL be a `RefCounted` subclass in `src/domain/`. It is the sole authority for all combat rule application — damage calculation, status effect resolution, enemy intent selection, omen tick processing, and legal action generation. No other class applies combat rules.

CombatResolver receives `RNGService` as a constructor dependency. It MUST NOT access any autoload directly — all external dependencies are injected.

**Interface:**

```
get_legal_combat_actions(game_state: GameState) -> Array[Dictionary]
    Returns all valid player actions for the current combat turn.
    Always returns at least one action (Default Strike is always legal).
    Evade is always included as a legal Action bucket option regardless of available charges.
    If an active companion (bound or temporary) has a non-empty granted_ability_id, the
    corresponding AbilityData is included as a legal action using its configured action_bucket.
    For Raven Mark specifically, only non-elite, non-boss living enemies are valid targets.

resolve_player_action(action: Dictionary, game_state: GameState) -> GameState
    Applies one player action. Returns updated GameState.
    Resets vessel_state.is_evading to false at the start of resolution (clears Evade from
    the prior turn regardless of what action is chosen this turn).
    If the action is Evade: sets vessel_state.is_evading to true and returns immediately —
    no handler chain runs, no charges are decremented.
    For all other actions: runs the handler chain via AbilityPipeline.
    For attack actions: if any targeted enemy has is_evading = true, rolls one value in
    [0, 99] per hit against that enemy using the COMBAT stream; if the value is ≤ 34
    (35% miss), that hit misses — no damage and no status applied for that hit.
    Charge preservation: after resolving all hits, if the action item has action_bucket
    "attack" and breaks_at_zero: true, and ALL hits missed (every targeted enemy was
    evading and every miss roll triggered), does NOT decrement remaining_charges.
    Applies vulnerability, resistance, and damage modifier rules from hld-combat-system.
    If the resolved action used a companion's granted_ability_id and the companion's
    departure_trigger is "ability_used", the companion departs as part of this resolution.

resolve_enemy_turns(game_state: GameState) -> GameState
    Resolves all living enemies' turns in order.
    For each enemy:
      0. Reset enemy.is_evading to false (clears any Evade from the prior turn).
      1. If enemy.is_charging is true: execute the release of the Charge→Release intent
         (roll damage in [damage_min, damage_max] using COMBAT stream and/or apply status_apply);
         set is_charging to false.
      2. Otherwise: evaluate intent_conditionals first; if a condition matches, force that intent_id.
         If no condition matches, roll the COMBAT stream against intent_weights.
      3. Consecutive cap check (step 2 only): if the selected intent_id equals last_intent_id
         AND intent_streak >= max_consecutive AND max_consecutive > 0, re-roll until a different
         intent_id is selected.
      4. Update last_intent_id and intent_streak on EnemyState.
      5. If the selected intent has is_evade: true: set enemy.is_evading = true; skip to next enemy.
      6. If the selected intent has is_charge_release: true: set is_charging to true; show charge
         indicator; deal no damage this turn.
      7. Otherwise execute the intent: roll damage in [damage_min, damage_max] using COMBAT stream
         (if damage_max > 0); apply status_apply if non-empty (subject to HLD-COMBAT-015 for Chilled).
         If vessel_state.is_evading is true, roll one value in [0, 99] per hit using the COMBAT
         stream; if the value is ≤ 34 (35% miss), that hit misses — no damage and no status applied.
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
0. Evade miss check: if the target has is_evading = true, roll one value in [0, 99] using the COMBAT stream; if ≤ 34 (35% miss), skip all remaining steps for this hit — no damage, no status applied
1. Base damage: for player attacks, the flat value from HandlerConfig params; for enemy attacks, a value rolled in [damage_min, damage_max] using the COMBAT stream (see `HLD-COMBAT-016`)
2. Passive modifiers (Last Stand ×1.5 if active)
3. Buff modifiers (Charged ×2 if active, consumed after)
4. Resistance (×0.5 if target resists damage type)
5. Vulnerability (×1.5 if target is vulnerable to damage type)
6. Resistance + Vulnerability cancel: if both apply to the same type → net ×1.0
7. Clamp to minimum 1 (no hit ever deals 0 damage unless explicitly blocked)

#### Scenario: Legal actions always include Default Strike
- **WHEN** the vessel has zero item charges remaining and no ability charges
- **THEN** `get_legal_combat_actions()` returns at least two actions: Default Strike and Evade

#### Scenario: Evade is always a legal action
- **WHEN** the vessel has full attack ability charges and multiple attack items
- **THEN** `get_legal_combat_actions()` still includes Evade as a legal Action bucket option

#### Scenario: Player Evade sets flag and returns early
- **WHEN** the player selects Evade as their action
- **THEN** resolve_player_action sets vessel_state.is_evading to true and returns without running any handler chain or decrementing any charges

#### Scenario: Player attack against evading enemy rolls miss
- **WHEN** the player attacks an enemy with is_evading = true
- **THEN** CombatResolver rolls [0,99] per hit using the COMBAT stream; a value ≤ 34 triggers a miss — the hit deals no damage and applies no status

#### Scenario: Weapon charge not decremented on full miss
- **WHEN** the player attacks a single evading enemy and the miss roll triggers
- **THEN** the weapon item's remaining_charges is not decremented; the charge is preserved

#### Scenario: Weapon charge decremented if at least one hit lands
- **WHEN** the player attacks two enemies — one evading (miss roll triggers) and one not evading
- **THEN** the weapon charge IS decremented; one hit connected

#### Scenario: Evade flag resets before this turn's action
- **WHEN** resolve_player_action is called at the start of the player's turn
- **THEN** vessel_state.is_evading is set to false before processing any action, even if the player Evades again this turn

#### Scenario: Enemy Evade intent skips execution
- **WHEN** an enemy's selected intent has is_evade: true
- **THEN** enemy.is_evading is set to true; step 7 (damage/status execution) is skipped; the enemy deals no damage that turn

#### Scenario: Damage resolution order — Last Stand + Charge + Vulnerability
- **WHEN** the Hedge Knight (HP < 25%) uses Charge and attacks a Vulnerable (Physical) enemy with a 7-damage weapon
- **THEN** the Evade miss check (step 0) passes (enemy not evading); damage = 7 × 1.5 (Last Stand) × 2.0 (Charge) × 1.5 (Vulnerable) = 31 (rounded down)

#### Scenario: Resistance cancels Vulnerability
- **WHEN** CombatResolver resolves a fire attack against a Fire Elemental that also has Vulnerable (Fire) applied
- **THEN** the resistance (×0.5) and vulnerability (×1.5) cancel; the attack deals base damage × 1.0

#### Scenario: Enemy intent conditional short-circuits roll
- **WHEN** an enemy has a `"turn_number:1"` conditional mapped to `"sleeping"` and it is the first turn
- **THEN** `current_intent` is set to `"sleeping"` with no COMBAT stream roll
