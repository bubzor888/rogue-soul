# @Spec: LLD-ARCH-017, LLD-ARCH-004
#
# EnemyState — runtime state of one enemy instance in combat. instance_id is
# unique per-combat (e.g. "skeleton_0", "skeleton_1") to enable individual targeting.
class_name EnemyState
extends Resource

@export var enemy_id: String = ""
@export var instance_id: String = ""
@export var hp: int = 0
@export var max_hp: int = 0
@export var active_statuses: Array[StatusInstance] = []

## Intent set at the start of each enemy turn; "" if not yet set.
@export var current_intent: String = ""

## Intent selected on the previous turn; "" at combat start.
@export var last_intent_id: String = ""

## Consecutive turns the current intent has been selected; 1 on change, +1 on
## repeat; 0 at combat start.
@export var intent_streak: int = 0

## true while a Charge->Release intent is in its charge phase.
@export var is_charging: bool = false

## true when this enemy chose Evade on its turn; reset at the start of its
## resolution in resolve_enemy_turns.
@export var is_evading: bool = false

## true when stunned by a Shocked shift; the enemy skips its action this turn;
## reset at the start of its resolution in resolve_enemy_turns.
@export var is_stunned: bool = false

## Per-enemy turn counter (LLD-ARCH-017). Starts at 1 when the enemy enters combat
## (combat start or mid-combat summon) and increments each of that enemy's turns in
## resolve_enemy_turns. The `turn_number:N` IntentConditional is evaluated against
## this, NOT the global CombatState.turn_number — so a Spark summoned on global
## turn 3 still matches `turn_number:1` on its own first action.
@export var turns_alive: int = 1


func to_json() -> Dictionary:
	return {
		"enemy_id": enemy_id,
		"instance_id": instance_id,
		"hp": hp,
		"max_hp": max_hp,
		"active_statuses": Serde.res_array_to_json(active_statuses),
		"current_intent": current_intent,
		"last_intent_id": last_intent_id,
		"intent_streak": intent_streak,
		"is_charging": is_charging,
		"is_evading": is_evading,
		"is_stunned": is_stunned,
		"turns_alive": turns_alive,
	}


static func from_json(data: Dictionary) -> EnemyState:
	var e := EnemyState.new()
	e.enemy_id = str(data.get("enemy_id", ""))
	e.instance_id = str(data.get("instance_id", ""))
	e.hp = int(data.get("hp", 0))
	e.max_hp = int(data.get("max_hp", 0))
	e.active_statuses.assign(Serde.res_array_from_json(data.get("active_statuses", []), Callable(StatusInstance, "from_json")))
	e.current_intent = str(data.get("current_intent", ""))
	e.last_intent_id = str(data.get("last_intent_id", ""))
	e.intent_streak = int(data.get("intent_streak", 0))
	e.is_charging = bool(data.get("is_charging", false))
	e.is_evading = bool(data.get("is_evading", false))
	e.is_stunned = bool(data.get("is_stunned", false))
	e.turns_alive = int(data.get("turns_alive", 1))
	return e
