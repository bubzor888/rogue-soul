# @Spec: LLD-ARCH-017, LLD-ARCH-004
#
# CombatState — the full state of an active combat encounter. Null on GameState
# when not in COMBAT phase.
class_name CombatState
extends Resource

@export var enemies: Array[EnemyState] = []
@export var turn_number: int = 0

## Always present during combat (null only on a freshly-constructed instance).
@export var omen_deck: OmenDeckState = null

## Null between cycles.
@export var current_cycle: OmenCycleState = null

## Inventory slot indices revealed by Repent and awaiting the player's discard
## choice; empty when no Repent choice is pending (set/cleared per LLD-ARCH-019).
@export var pending_repent_slots: Array[int] = []

## true after peek_omen_deck fires (Read the Road); while true,
## get_legal_combat_actions() returns only READ_THE_ROAD_COMMIT. Default false.
@export var read_the_road_active: bool = false

## Unit ids marked pending-Vulnerable by an Exposed shift at cycle start; the
## deferred "vulnerable:physical" is applied during CHOOSE_OMEN once the new cycle
## timer is known, then this is cleared (LLD-ARCH-024).
@export var pending_vulnerable_units: Array[String] = []

## Per-turn action-bucket usage (HLD-COMBAT-001): each bucket may be used once per
## player turn. Reset at the start of each player turn (begin_player_turn). The
## Action bucket is mandatory; Support/Consumable are optional. get_legal_combat_actions
## excludes a bucket's options once its flag is set.
@export var is_action_used: bool = false
@export var is_support_used: bool = false
@export var is_consumable_used: bool = false


func to_json() -> Dictionary:
	return {
		"enemies": Serde.res_array_to_json(enemies),
		"turn_number": turn_number,
		"omen_deck": Serde.to_json_or_null(omen_deck),
		"current_cycle": Serde.to_json_or_null(current_cycle),
		"pending_repent_slots": pending_repent_slots.duplicate(),
		"read_the_road_active": read_the_road_active,
		"pending_vulnerable_units": pending_vulnerable_units.duplicate(),
		"is_action_used": is_action_used,
		"is_support_used": is_support_used,
		"is_consumable_used": is_consumable_used,
	}


static func from_json(data: Dictionary) -> CombatState:
	var c := CombatState.new()
	c.enemies.assign(Serde.res_array_from_json(data.get("enemies", []), Callable(EnemyState, "from_json")))
	c.turn_number = int(data.get("turn_number", 0))
	c.omen_deck = Serde.obj_from_json(data.get("omen_deck"), Callable(OmenDeckState, "from_json"))
	c.current_cycle = Serde.obj_from_json(data.get("current_cycle"), Callable(OmenCycleState, "from_json"))
	c.pending_repent_slots.assign(Serde.int_array(data.get("pending_repent_slots", [])))
	c.read_the_road_active = bool(data.get("read_the_road_active", false))
	c.pending_vulnerable_units.assign(Serde.str_array(data.get("pending_vulnerable_units", [])))
	c.is_action_used = bool(data.get("is_action_used", false))
	c.is_support_used = bool(data.get("is_support_used", false))
	c.is_consumable_used = bool(data.get("is_consumable_used", false))
	return c
