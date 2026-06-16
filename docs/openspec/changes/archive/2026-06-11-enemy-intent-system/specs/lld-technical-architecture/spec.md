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

**StatusInstance fields:** `status_id: String`, `remaining_ticks: int`, `magnitude: int` (used by Chilled's accumulating flat reduction; 0 for statuses with no magnitude)

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
         (apply damage_max..damage_min roll and/or status_apply); set is_charging to false.
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
1. Base damage: for player attacks, the flat value from HandlerConfig params; for enemy attacks, a value rolled in [damage_min, damage_max] using the COMBAT stream
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
