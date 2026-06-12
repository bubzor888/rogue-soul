## MODIFIED Requirements

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

**IntentConditional:**

| Field | Type | Notes |
|---|---|---|
| `condition` | String | Condition string evaluated by CombatResolver before intent selection. Supported forms: `"hp_below_percent:N"`, `"ally_count_above:N"`, `"ally_count_equals:N"`, `"turn_number:N"`. **`turn_number:N`** is evaluated against a per-enemy turn counter (`turns_alive: int` on EnemyState; starts at 1 when the enemy enters combat — whether at encounter start or mid-combat via summon — and increments at the start of each of that enemy's turns in `resolve_enemy_turns`). For enemies present from combat start, `turns_alive` equals `CombatState.turn_number`. For enemies spawned mid-combat (e.g. Sparks, summoned wolves), `turns_alive` is independent of the global turn counter, allowing `turn_number:1` to correctly select a dormant intent on the Spark's first action regardless of when it was spawned. |
| `intent_id` | String | When non-empty: intent selected directly when condition is true; no COMBAT stream roll; must match an intent_id in intent_weights; use either `intent_id` or `intent_ids`, not both |
| `intent_ids` | Array[String] | When non-empty: restricts the weighted roll to only these intent IDs from intent_weights (using their relative weights); a COMBAT stream roll is still performed within this subset; use either `intent_id` or `intent_ids`, not both |

**OmenCardData:**

| Field | Type | Notes |
|---|---|---|
| `card_id` | String | Unique identifier; matches filename convention |
| `display_name` | String | Player-visible name |
| `status_id` | String | Status ID applied to each eligible unit when the card fires; empty string for cards with no status effect (e.g. Stillness); colon-encoded parameterized statuses (e.g. `"type_convert:fire"`, `"vulnerable:lightning"`, `"emboldened:physical"`) are split on `:` by CombatResolver — left of `:` becomes StatusInstance.status_id, right becomes StatusInstance.string_param |
| `status_magnitude` | int | Magnitude value for StatusInstances created from this card's `status_id`. For Burning: fire damage per tick (e.g. 5 for the Burning omen card). For magnitude-additive statuses (see `HLD-COMBAT-018`), if the target already has the status active, this value is added to existing magnitude rather than creating a new instance. For max-wins statuses (Hardened, Emboldened — see `HLD-COMBAT-019`), the higher magnitude survives. Defaults 0; ignored for statuses that do not use magnitude. |
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
