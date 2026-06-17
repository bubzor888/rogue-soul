# @Spec: LLD-ARCH-018, LLD-ARCH-006
#
# IntentWeight — one selectable enemy intent with its weight and execution data.
# An enemy's intent_weights form a weighted random pool (rolled on the COMBAT
# stream), unless an IntentConditional forces or restricts the selection.
# Pure data Resource (Domain layer).
class_name IntentWeight
extends Resource

## Unique identifier for this intent within the enemy.
@export var intent_id: String = ""

## Relative weight; higher = more likely; 0 = never randomly selected
## (only reachable via an IntentConditional forced match).
@export var weight: int = 0

## Minimum damage per hit on execution; 0 for non-damage intents.
@export var damage_min: int = 0

## Maximum damage per hit on execution; MUST be >= damage_min.
@export var damage_max: int = 0

## Number of independent damage rolls on execution (each subject to evade miss).
@export var hit_count: int = 1

## true if this intent uses the Charge -> Release two-turn pattern.
@export var is_charge_release: bool = false

## true if this intent is the Evade action (damage/status fields ignored).
@export var is_evade: bool = false

## Max consecutive selections allowed; 0 = no limit.
@export var max_consecutive: int = 0

## Status ID to apply on execution; "" if none. Colon-encoding convention applies
## (e.g. "vulnerable:physical" -> status_id "vulnerable", string_param "physical").
@export var status_apply: String = ""

## Magnitude for the applied status (e.g. Burning fire/tick); 0 default; ignored
## for non-magnitude statuses. Stacking/keep-higher rules per HLD-COMBAT-018/-019.
@export var status_magnitude: int = 0

## "player" (default) | "self" | "allies".
@export var status_target: String = "player"

## When non-empty, spawns one enemy of this enemy_id when the intent resolves.
@export var summon_enemy_id: String = ""

## Optional custom handler chain run after standard status_apply processing.
@export var handlers: Array[HandlerConfig] = []
