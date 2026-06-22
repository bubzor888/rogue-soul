# @Spec: LLD-ARCH-018, LLD-ARCH-006
#
# IntentConditional — a condition that, when true, forces or restricts an enemy's
# intent selection. Evaluated before the weighted roll; the first match
# short-circuits. Use either `intent_id` (forced) or `intent_ids` (restricted
# pool), not both. Pure data Resource (Domain layer).
class_name IntentConditional
extends Resource

## Condition evaluated by CombatResolver. Supported forms:
## "hp_below_percent:N", "hp_percent_lte:N", "ally_count_above:N",
## "ally_count_equals:N", "turn_number:N" (per-enemy turns_alive).
@export var condition: String = ""

## When non-empty: this intent is selected directly (no COMBAT roll). Must match
## an intent_id in intent_weights. Use either intent_id or intent_ids, not both.
@export var intent_id: String = ""

## When non-empty: restricts the weighted roll to these intent IDs (a COMBAT roll
## is still performed within the subset). Use either intent_id or intent_ids.
@export var intent_ids: Array[String] = []
