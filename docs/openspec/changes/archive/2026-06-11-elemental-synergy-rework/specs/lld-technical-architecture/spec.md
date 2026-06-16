## Modified Requirements

### MODIFIED: [LLD-ARCH-017] GameState and Domain Entities

*(Only the StatusInstance fields section changes. All other fields and scenarios are unchanged.)*

**StatusInstance fields:** `status_id: String`, `remaining_ticks: int`, `magnitude: int` (used for statuses whose numeric value evolves over ticks: Chilled's accumulating flat damage reduction, Poisoned's current damage value, Bleed's current stack count; 0 for statuses that do not use it), `trigger: String` (`"tick"` = effect fires on each omen tick while remaining_ticks > 0; `"shift"` = effect fires once when remaining_ticks hits 0 at the omen shift; default `"tick"`), `string_param: String` (type qualifier for parameterized statuses; empty string if not applicable; e.g. `"fire"` when status_id is `"type_convert"`, `"vulnerable"`, or `"emboldened"`; CombatResolver reads this to determine which type the effect applies to; default `""`)

No other fields on StatusInstance change.

#### Scenario: StatusInstance string_param for Vulnerable (Fire)
- **WHEN** a Vulnerable StatusInstance is created for fire vulnerability
- **THEN** the instance has `status_id: "vulnerable"` and `string_param: "fire"`; CombatResolver reads string_param to determine which damage type gets the ×1.5 multiplier at step 6

#### Scenario: StatusInstance string_param for Type Convert (ice)
- **WHEN** a Type Convert (ice) StatusInstance is created
- **THEN** the instance has `status_id: "type_convert"` and `string_param: "ice"`; CombatResolver reads string_param at damage step 1 to override the attack's damage type

#### Scenario: StatusInstance string_param for Emboldened (Physical)
- **WHEN** an Emboldened StatusInstance is created from an Emboldened (Physical) omen card
- **THEN** the instance has `status_id: "emboldened"` and `string_param: "physical"`; CombatResolver applies the flat bonus at step 2 when physical damage is dealt

---

### MODIFIED: [LLD-ARCH-018] Data Resource Schemas

*(Only the OmenCardData.status_id notes and IntentWeight.status_apply notes change. All other schema fields are unchanged.)*

**Colon-encoding convention for parameterized statuses:** When a `status_id` or `status_apply` string contains a colon (e.g. `"type_convert:fire"`, `"vulnerable:lightning"`, `"emboldened:physical"`), CombatResolver splits on `:` at StatusInstance creation time. The left portion becomes `StatusInstance.status_id`; the right portion becomes `StatusInstance.string_param`. Plain status IDs without `:` (e.g. `"burning"`, `"frenzied"`) are used as-is with `string_param` left as `""`.

Updated **OmenCardData** field notes:

| Field | Type | Notes |
|---|---|---|
| `status_id` | String | Status ID applied to each eligible unit when the card fires; empty string for cards with no status effect (e.g. Stillness); colon-encoded parameterized statuses (e.g. `"type_convert:fire"`, `"vulnerable:lightning"`, `"emboldened:physical"`) are split on `:` by CombatResolver — left of `:` becomes StatusInstance.status_id, right becomes StatusInstance.string_param |

Updated **IntentWeight** field notes:

| Field | Type | Notes |
|---|---|---|
| `status_apply` | String | Status ID to apply on execution; empty string if none; same colon-encoding convention as OmenCardData.status_id applies (e.g. `"vulnerable:physical"` creates a Vulnerable StatusInstance with string_param `"physical"`) |

#### Scenario: Colon-encoded status_id split on create
- **WHEN** CombatResolver applies an omen card with `status_id: "type_convert:fire"`
- **THEN** it creates a StatusInstance with `status_id: "type_convert"` and `string_param: "fire"`; the colon is not preserved in the instance

#### Scenario: Plain status_id unchanged
- **WHEN** CombatResolver applies an omen card with `status_id: "burning"`
- **THEN** it creates a StatusInstance with `status_id: "burning"` and `string_param: ""`; no splitting occurs

---

### MODIFIED: [LLD-ARCH-019] CombatResolver

*(Only the damage resolution order steps 1, 2, 4, 6, and the resolve_omen_cycle_start step 4 change. All other interface methods and scenarios are unchanged.)*

Updated **Damage resolution order:**

0. Evade miss check: if the target has is_evading = true, roll [0, 99] via COMBAT stream; if ≤ 34 (35% miss), skip all remaining steps
1. Base damage and type: determine base damage value (player flat value from HandlerConfig; enemy rolled [damage_min, damage_max] via COMBAT stream) and initial damage type (from EnemyData.damage_type or HandlerConfig.params.damage_type). **Type conversion override:** if the attacker has an active `type_convert` StatusInstance, replace the damage type with `StatusInstance.string_param` before any further steps.
2. Flat attacker bonuses: if attacker has an `emboldened` StatusInstance with `string_param: "physical"` and the resolved damage type is physical, add flat bonus (value defined in LLD)
3. Passive modifiers: Last Stand ×1.5 if active
4. Buff modifiers: Charged ×2 if active (consumed after); if attacker has an `emboldened` StatusInstance whose `string_param` matches the resolved damage type and `string_param` is not `"physical"`, apply ×1.5
5. Resistance (×0.5 if target resists the resolved damage type)
6. Vulnerability (×1.5 if target has an active `vulnerable` StatusInstance whose `string_param` matches the resolved damage type)
7. Resistance + Vulnerability cancel: if both apply to the resolved type → net ×1.0
8. Clamp to minimum 1

Updated **resolve_omen_cycle_start** step 4:
> Step 4 — Apply deferred Vulnerable: for each unit marked as pending Vulnerable (Physical) from step 1, apply a `"vulnerable:physical"` StatusInstance with `remaining_ticks` = new cycle timer value.

Type Convert replacement rule in **resolve_omen_cycle_start** (and in resolve_player_action / resolve_enemy_turns when status_apply is processed):
> When applying a `type_convert` StatusInstance to a unit that already has an active `type_convert` StatusInstance, remove the existing one first. Only one Type Convert may be active on a unit at a time.

#### Scenario: Type Convert overrides damage type before multipliers
- **WHEN** a player with a `type_convert` StatusInstance (`string_param: "fire"`) attacks with a physical weapon dealing 6 base damage
- **THEN** at step 1 the damage type is overridden to fire; the `emboldened:physical` flat bonus at step 2 does NOT apply (resolved type is now fire); steps 5 and 6 use fire for resistance and vulnerability checks

#### Scenario: Type Convert and Vulnerable stack correctly
- **WHEN** a player with Type Convert (fire) attacks a unit that has a `vulnerable` StatusInstance with `string_param: "fire"`
- **THEN** damage type is overridden to fire at step 1; step 6 applies ×1.5 because the Vulnerable string_param matches the resolved type

#### Scenario: Vulnerable string_param match — lightning
- **WHEN** CombatResolver resolves step 6 for a lightning attack against a unit with a `vulnerable` StatusInstance with `string_param: "lightning"`
- **THEN** ×1.5 multiplier applies; if string_param were `"fire"` or `"physical"`, no multiplier would apply for this lightning hit

#### Scenario: Emboldened (Physical) flat bonus — step 2
- **WHEN** the player has an `emboldened` StatusInstance with `string_param: "physical"` and attacks with a physical weapon dealing 6 base damage
- **THEN** the flat bonus is added at step 2 before any multipliers

#### Scenario: Emboldened (Fire) multiplier — step 4
- **WHEN** the player has an `emboldened` StatusInstance with `string_param: "fire"` and attacks with a fire weapon
- **THEN** step 4 applies ×1.5; step 2 does not apply (string_param is not "physical")

#### Scenario: Exposed deferred Vulnerable uses colon shorthand
- **WHEN** resolve_omen_cycle_start step 4 applies the deferred Vulnerable for an Exposed unit
- **THEN** CombatResolver creates a `"vulnerable:physical"` StatusInstance (split to status_id: "vulnerable", string_param: "physical") with remaining_ticks = new cycle timer
