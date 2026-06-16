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

**VesselState fields:** `vessel_id: String`, `hp: int`, `max_hp: int`, `ability_states: Array[AbilityState]`, `active_statuses: Array[StatusInstance]`, `is_evading: bool` (true when the vessel chose Evade this turn; resets to false at the start of each player turn before any action is processed), `is_stunned: bool` (true when the vessel has been stunned by a Shocked shift trigger; blocks the Action bucket for the next player turn; resets to false at the start of resolve_player_action)

**AbilityState fields:** `ability_id: String`, `remaining_charges: int`

**ItemInstance fields:** `item_id: String`, `remaining_charges: int`

**StatusInstance fields:** `status_id: String`, `remaining_ticks: int`, `magnitude: int` (used for statuses whose numeric value evolves over ticks: Chilled's accumulating flat damage reduction, Poisoned's current damage value, Bleed's current stack count; 0 for statuses that do not use it), `trigger: String` (`"tick"` = effect fires on each omen tick while remaining_ticks > 0; `"shift"` = effect fires once when remaining_ticks hits 0 at the omen shift; default `"tick"`)

**CompanionState fields:** `companion_id: String`, `ability_states: Array[AbilityState]` (for companion abilities with charges), `companion_timer: int` (generic countdown for companions with a budget, e.g. Shadow's 20 HP drain limit; copied from `CompanionData.initial_timer` on activation; -1 = not used by this companion; decremented by CombatResolver when the timer-consuming effect fires; companion departs when this reaches 0), `companion_context: Dictionary` (companion-specific runtime state not covered by standard fields, e.g. Shadow's `{ "current_target_instance_id": "wolf_0" }`; read and written by the companion's handler chain). No `hp` field — companions are not targetable in combat (see `HLD-COMPANION-001`).

**NavigationState fields:** `rooms_completed_this_floor: int`, `segment_room_counts: Dictionary` (room type → count, for pool exhaustion per `HLD-DOOR-004`), `doors_ahead: Array[DoorData]` (the current two-door choice; empty outside NAVIGATION phase), `companion_offered_this_floor: bool` (true once any companion encounter has fired this floor — Worn Map or Memory Fragment; blocks further companion draws from MF pool per `HLD-MF-004`)

**DoorData fields:** `room_type: String` (RoomType enum value), `encounter_id: String` (enemy_id for combat; event_id for non-combat), `room_id: String` (unique per-run identifier for logging)

**CombatState fields:** `enemies: Array[EnemyState]`, `turn_number: int`, `omen_deck: OmenDeckState`, `current_cycle: OmenCycleState` (null between cycles)

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
| `enemy_tags` | Array[String] | e.g. `["undead"]`, `["beast"]`, `["elemental_fire"]` — used by omen card tag filtering and omen card effects |
| `omen_contributions` | Array[String] | Card IDs added to deck while this enemy is alive |
| `intent_weights` | Array[IntentWeight] | Weighted random pool (evaluated if no conditional matches) |
| `intent_conditionals` | Array[IntentConditional] | Evaluated first; first match short-circuits the roll |

**IntentWeight:**

| Field | Type | Notes |
|---|---|---|
| `intent_id` | String | Unique identifier for this intent within the enemy |
| `weight` | int | Relative weight; higher = more likely |
| `damage_min` | int | Minimum damage on execution; 0 for non-damage intents |
| `damage_max` | int | Maximum damage on execution; MUST be ≥ damage_min |
| `is_charge_release` | bool | true if this intent uses the Charge→Release two-turn pattern |
| `is_evade` | bool | true if this intent is the Evade action; damage_min, damage_max, and status_apply are ignored |
| `max_consecutive` | int | Maximum times this intent may be selected consecutively; 0 = no limit |
| `status_apply` | String | Status ID to apply to the player on execution; empty string if none |
| `status_target` | String | `"player"` (default) \| `"self"` — determines whether status_apply targets the player or the enemy itself |

**IntentConditional:**

| Field | Type | Notes |
|---|---|---|
| `condition` | String | e.g. `"hp_below_percent:50"`, `"ally_count_above:1"`, `"turn_number:1"` |
| `intent_id` | String | Intent selected when condition is true; must match an intent_id in intent_weights |

**OmenCardData:**

| Field | Type | Notes |
|---|---|---|
| `card_id` | String | Unique identifier; matches filename convention |
| `display_name` | String | Player-visible name |
| `status_id` | String | Status ID applied to each eligible unit when the card fires; empty string for cards with no status effect (e.g. Stillness) or cards whose effect is delivered via handlers |
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

#### Scenario: OmenCardData tag filter — undead only
- **WHEN** the Grave Knit omen card (requires_tag: "undead") is applied to a side with one Skeleton and one Plague Rat
- **THEN** the Skeleton receives a Mending StatusInstance; the Plague Rat receives nothing

#### Scenario: OmenCardData tag filter — player side
- **WHEN** any omen card with requires_tag: "undead" is steered to the player side
- **THEN** no StatusInstance is created; the player is not tagged and receives no effect

#### Scenario: Enemy conditional intent overrides random
- **WHEN** CombatResolver resolves an enemy's intent and an IntentConditional matches
- **THEN** the matched intent_id is selected without rolling the COMBAT stream

#### Scenario: Enemy weighted intent uses COMBAT stream
- **WHEN** no IntentConditional matches for an enemy
- **THEN** CombatResolver performs one weighted roll against the COMBAT stream

#### Scenario: Enemy Evade intent sets is_evading
- **WHEN** an enemy's selected intent has is_evade: true
- **THEN** CombatResolver sets that enemy's is_evading to true and does not process damage or status for that intent

---

### Requirement: [LLD-ARCH-019] CombatResolver
CombatResolver SHALL be a `RefCounted` subclass in `src/domain/`. It is the sole authority for all combat rule application. CombatResolver receives `RNGService` as a constructor dependency. It MUST NOT access any autoload directly.

**Interface:**

```
get_legal_combat_actions(game_state: GameState) -> Array[Dictionary]
    Returns all valid player actions for the current combat turn.
    Always returns at least one action (Default Strike is always legal).
    Evade is always included as a legal Action bucket option.
    If vessel_state.is_stunned is true: all Action bucket options are excluded from the
    returned array; Support and Consumable options remain included.
    If an active companion has a non-empty granted_ability_id, it is included using its
    configured action_bucket.
    For Raven Mark specifically, only non-elite, non-boss living enemies are valid targets.

resolve_player_action(action: Dictionary, game_state: GameState) -> GameState
    Applies one player action. Returns updated GameState.
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
      2. Otherwise: evaluate intent_conditionals; roll COMBAT stream against intent_weights if none match.
      3. Consecutive cap check (step 2 only): re-roll if intent_id == last_intent_id and streak >= max_consecutive.
      4. Update last_intent_id and intent_streak on EnemyState.
      5. If selected intent has is_evade: true: set enemy.is_evading = true; skip to next enemy.
      6. If selected intent has is_charge_release: true: set is_charging = true; deal no damage this turn.
      7. Otherwise execute the intent: roll damage in [damage_min, damage_max] (if damage_max > 0);
         apply status_apply if non-empty (to player if status_target: "player", to self if "self");
         subject to HLD-COMBAT-015 for Chilled idempotency.
         If vessel_state.is_evading is true: per-hit miss roll (35% via COMBAT stream).
    Sets current_intent on EnemyState for display.

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
      from step 1, apply a new Vulnerable (Physical) StatusInstance with
      remaining_ticks = new cycle timer value.
    Step 5 — Apply on-draw statuses: for each of the two played cards in the new cycle,
      apply the card's status_id (if non-empty) to each eligible unit on the target side,
      filtering by requires_tag. New StatusInstances get remaining_ticks = new cycle timer.
      Execute any handlers on OmenCardData for cards that have non-status effects.

assemble_omen_deck(sources: Array[String], game_state: GameState) -> GameState
    Builds OmenDeckState from all contributing sources (vessel, enemies, items, companions).
    Assigns timer values via COMBAT stream per LLD-OMEN-MECH-008.

resolve_enemy_death(unit_id: String, game_state: GameState) -> GameState
    Removes the dead enemy's family card copy from draw_pile and discard_pile immediately.
    Checks for last-of-type; removes type card if so (per HLD-OMEN-006).
    Cards already drawn into OmenCycleState are NOT removed.
```

**Damage resolution order** (applied in this sequence for every hit):
0. Evade miss check: if the target has is_evading = true, roll [0, 99] via COMBAT stream; if ≤ 34 (35% miss), skip all remaining steps
1. Base damage: player flat value from HandlerConfig; enemy rolled [damage_min, damage_max] via COMBAT stream
2. Flat attacker bonuses: if attacker has Emboldened (Physical) and damage type is physical, add flat bonus (value defined in LLD)
3. Passive modifiers: Last Stand ×1.5 if active
4. Buff modifiers: Charged ×2 if active (consumed after); Emboldened (elemental) ×1.5 if attacker has matching elemental Emboldened status
5. Resistance (×0.5 if target resists damage type)
6. Vulnerability (×1.5 if target is vulnerable to damage type)
7. Resistance + Vulnerability cancel: if both apply to the same type → net ×1.0
8. Clamp to minimum 1

#### Scenario: Legal actions always include Default Strike and Evade
- **WHEN** the vessel has zero item charges remaining and no ability charges
- **THEN** `get_legal_combat_actions()` returns exactly two actions: Default Strike and Evade

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

#### Scenario: Enemy intent conditional short-circuits roll
- **WHEN** an enemy has a `"turn_number:1"` conditional mapped to `"sleeping"` and it is the first turn
- **THEN** `current_intent` is set to `"sleeping"` with no COMBAT stream roll
