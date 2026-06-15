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
| `score` | int | Precomputed item score from LLD-IR-011 (Durability or Consumable scale as applicable); 0 for vessel abilities, which are not traded. Set by the designer when authoring the `.tres` file using the LLD-IR formulas as a worksheet; never derived at runtime. |
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
| `on_death_apply_to_player` | String | Colon-encoded status ID (same format as `status_apply` in IntentWeight) applied to the player when this enemy dies; the StatusInstance's `remaining_ticks` is set to the current omen cycle's remaining ticks at the moment of death; empty string = no on-death status consequence. Used by the Witnesses (Vulnerable, Frenzied) and Plague Rat (Poisoned). |
| `on_death_apply_magnitude` | int | Magnitude value for the StatusInstance created by `on_death_apply_to_player`. For magnitude-additive statuses (Burning, Poisoned, Bleed — see `HLD-COMBAT-018`), if the target already has the status active, this value is added to existing magnitude. For max-wins statuses, higher magnitude wins. Ignored for statuses that do not use magnitude. Defaults 0. |

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
| `handlers` | Array[HandlerConfig] | Optional custom handler chain executed by CombatResolver via AbilityPipeline after standard `status_apply` processing. Used for intent effects that cannot be expressed as a static `status_magnitude` — for example, the Witnesses' tier-based magnitude intents (`testify_mercy`, `testify_vengeance`) which read `game_state.item_burden_score` at resolution time. Defaults to `[]`. Empty array = no custom handlers beyond `status_apply`. |

**IntentConditional:**

| Field | Type | Notes |
|---|---|---|
| `condition` | String | Condition string evaluated by CombatResolver before intent selection. Supported forms: `"hp_below_percent:N"` (HP strictly less than N% of max_hp), `"hp_percent_lte:N"` (HP less than or equal to N% of max_hp), `"ally_count_above:N"`, `"ally_count_equals:N"`, `"turn_number:N"`. **`turn_number:N`** is evaluated against a per-enemy turn counter (`turns_alive: int` on EnemyState; starts at 1 when the enemy enters combat — whether at encounter start or mid-combat via summon — and increments at the start of each of that enemy's turns in `resolve_enemy_turns`). For enemies present from combat start, `turns_alive` equals `CombatState.turn_number`. For enemies spawned mid-combat (e.g. Sparks, summoned wolves), `turns_alive` is independent of the global turn counter, allowing `turn_number:1` to correctly select a dormant intent on the Spark's first action regardless of when it was spawned. **`hp_percent_lte:N`** is used by The Judge's Pass Judgment phase trigger (`hp_percent_lte:30` — ≤30% of max_hp). |
| `intent_id` | String | When non-empty: intent selected directly when condition is true; no COMBAT stream roll; must match an intent_id in intent_weights; use either `intent_id` or `intent_ids`, not both |
| `intent_ids` | Array[String] | When non-empty: restricts the weighted roll to only these intent IDs from intent_weights (using their relative weights); a COMBAT stream roll is still performed within this subset; use either `intent_id` or `intent_ids`, not both |

**OmenCardData:**

| Field | Type | Notes |
|---|---|---|
| `card_id` | String | Unique identifier; matches filename convention |
| `display_name` | String | Player-visible name |
| `status_id` | String | Status ID applied to each eligible unit when the card fires; empty string for cards with no status effect (e.g. Stillness); colon-encoded parameterized statuses (e.g. `"type_convert:fire"`, `"vulnerable:lightning"`, `"emboldened:physical"`) are split on `:` by CombatResolver — left of `:` becomes StatusInstance.status_id, right becomes StatusInstance.string_param |
| `status_magnitude` | int | Magnitude value for StatusInstances created from this card's `status_id`. For Burning: fire damage per tick (e.g. 5 for the Burning omen card). For magnitude-additive statuses (see `HLD-COMBAT-018`), if the target already has the status active, this value is added to existing magnitude rather than creating a new instance. Defaults 0; ignored for statuses that do not use magnitude. |
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

#### Scenario: Item .tres file carries precomputed score
- **WHEN** an item AbilityData `.tres` file is loaded by ItemRegistry at startup
- **THEN** the `score` field contains the item's precomputed score from LLD-IR-011; the engine never derives this value at runtime

#### Scenario: Vessel ability score is zero
- **WHEN** a vessel ability `.tres` file (e.g. Pilgrim's Insight ability) is loaded
- **THEN** its `score` field is 0; vessel abilities are never traded and carry no score

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

#### Scenario: on_death_apply_to_player — Witness of Mercy
- **WHEN** the Witness of Mercy (`on_death_apply_to_player: "vulnerable:physical"`, `on_death_apply_magnitude: 0`) dies
- **THEN** `resolve_enemy_death` creates a `"vulnerable:physical"` StatusInstance on the player with `remaining_ticks` equal to the current omen cycle's remaining ticks

#### Scenario: on_death_apply_to_player — Plague Rat poison magnitude-additive
- **WHEN** a Plague Rat (`on_death_apply_to_player: "poisoned"`, `on_death_apply_magnitude: 2`) dies and the player already has Poisoned with magnitude 4
- **THEN** `resolve_enemy_death` increments the existing Poisoned StatusInstance's magnitude to 6 (magnitude-additive per HLD-COMBAT-018); no new StatusInstance is created

#### Scenario: on_death_apply_to_player — no consequence
- **WHEN** an enemy with `on_death_apply_to_player: ""` dies
- **THEN** `resolve_enemy_death` skips the on-death status step; only omen card removal is performed

#### Scenario: IntentWeight handlers — Witness tier-based magnitude
- **WHEN** the Witness of Mercy's `testify_mercy` intent resolves and its `handlers` array contains `{ "handler_id": "apply_mending_by_burden_tier" }`
- **THEN** CombatResolver executes the handler chain via AbilityPipeline after `status_apply` processing; the handler reads `game_state.item_burden_score` and applies Mending at the appropriate tier magnitude to The Judge

#### Scenario: hp_percent_lte condition — Judge Pass Judgment entry
- **WHEN** The Judge (max_hp: 30) has hp: 9 and CombatResolver evaluates its IntentConditionals
- **THEN** the condition `"hp_percent_lte:30"` is true (9/30 = 30% ≤ 30%); `pass_judgment` is selected; the normal intent pool is bypassed

#### Scenario: hp_percent_lte vs hp_below_percent — boundary distinction
- **WHEN** an enemy with max_hp: 30 has hp: 9 and both `"hp_percent_lte:30"` and `"hp_below_percent:30"` conditionals are defined
- **THEN** `hp_percent_lte:30` is true (9/30 = 30% ≤ 30%); `hp_below_percent:30` is false (9/30 = 30% is not strictly less than 30%)

---

## ADDED Requirements

### Requirement: [LLD-ARCH-021] TradeGenerator
TradeGenerator SHALL be a `RefCounted` subclass in `src/application/`. It is the sole system responsible for constructing trade offer arrays for Wandering Soul and Memory Fragment Category A and C encounters. It reads item pools from ItemRegistry, enforces the same-scale pairing rule (see `HLD-ITEMS-006`), applies the score tolerance formula (see `LLD-IR-010`), and resolves HP values via the HP conversion bucket tables (see `LLD-IR-009`). It uses the LOOT RNG stream (see `LLD-ARCH-008`) for all randomness. It does not modify GameState directly — it returns offer arrays that RunController stores for the encounter handler.

**Interface:**

```
generate_wandering_soul_offers(game_state: GameState) -> Array[Dictionary]
    Returns 2–3 trade offer Dictionaries for a Wandering Soul encounter.
    Always includes at least one HP-for-item offer (see HLD-WS-003).
    Item-for-item offers pair items from the same scoring scale within the ±20%
    tolerance window (see LLD-IR-010). HP amounts are resolved from LLD-IR-009 buckets.
    Uses LOOT stream for all item selection rolls.

generate_category_a_offer(game_state: GameState) -> Dictionary
    Returns one fair trade offer Dictionary for a Memory Fragment Category A encounter.
    Cost and reward are within the ±20% score tolerance window (see LLD-IR-010).
    Both sides are from the same scoring scale.

generate_category_c_offers(game_state: GameState) -> Array[Dictionary]
    Returns exactly two offer Dictionaries for a Memory Fragment Category C encounter.
    Option 1's cost exceeds the reward score by at least 50% above the fair tolerance
    window (see LLD-IR-010 and HLD-MF-005).
    Option 2 is a straight loss — cost with no reward.
    Uses LOOT stream for item selection.

is_fair_trade(score_a: int, score_b: int) -> bool
    Returns true when |score_a - score_b| ≤ 0.20 × max(score_a, score_b).
    Pure utility — no RNG, no registry access.

hp_for_score(score: int, scale: String) -> int
    Returns the HP bucket value for the given item score on the given scale
    ("durability" or "consumable"). Reads from LLD-IR-009 bucket tables.
    Returns 0 if the scale is unrecognised or the HP amounts are not yet set ([OPEN·MVP2]).
```

**TradeOffer Dictionary format** (all offers use this shape for GameState serialisability):

```
{
    "offer_type": String,   # "item_for_item" | "item_for_hp" | "hp_for_item" | "consumable_for_item" | "loss_only"
    "give_item_id": String, # ability_id of the item the player gives up; "" if HP cost
    "give_hp": int,         # HP the player pays; 0 if item cost
    "receive_item_id": String, # ability_id of the item the player receives; "" if HP reward
    "receive_hp": int,      # HP the player receives; 0 if item reward
}
```

#### Scenario: Wandering Soul always includes HP-for-item offer
- **WHEN** `generate_wandering_soul_offers` is called
- **THEN** at least one returned offer has `offer_type: "hp_for_item"`; this offer is never absent regardless of inventory state

#### Scenario: Item-for-item pair from same scale within tolerance
- **WHEN** `generate_wandering_soul_offers` generates an item-for-item trade
- **THEN** both `give_item_id` and `receive_item_id` resolve to items on the same scoring scale (both Durability or both Consumable), and `is_fair_trade(score_give, score_receive)` returns true

#### Scenario: is_fair_trade boundary — within tolerance
- **WHEN** `is_fair_trade(40, 49)` is called (gap = 9, 9/49 ≈ 18%)
- **THEN** returns true

#### Scenario: is_fair_trade boundary — outside tolerance
- **WHEN** `is_fair_trade(20, 49)` is called (gap = 29, 29/49 ≈ 59%)
- **THEN** returns false

#### Scenario: Category C Option 1 cost exceeds tolerance threshold
- **WHEN** `generate_category_c_offers` produces an Option 1 offer with reward score R
- **THEN** the cost score C satisfies C ≥ R × 1.70 (50% above the ±20% fair window upper bound of R × 1.20)

#### Scenario: TradeGenerator uses LOOT stream only
- **WHEN** `generate_wandering_soul_offers` or any generate method rolls for item selection
- **THEN** all random calls use the LOOT RNG stream; no other stream is consumed

#### Scenario: hp_for_score returns zero for OPEN bucket
- **WHEN** `hp_for_score` is called before HP bucket amounts are set ([OPEN·MVP2])
- **THEN** it returns 0; the caller substitutes a placeholder and the offer is skipped or deferred
