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


func to_json() -> Dictionary:
	return {
		"enemies": Serde.res_array_to_json(enemies),
		"turn_number": turn_number,
		"omen_deck": Serde.to_json_or_null(omen_deck),
		"current_cycle": Serde.to_json_or_null(current_cycle),
		"pending_repent_slots": pending_repent_slots.duplicate(),
		"read_the_road_active": read_the_road_active,
	}


static func from_json(data: Dictionary) -> CombatState:
	var c := CombatState.new()
	c.enemies.assign(Serde.res_array_from_json(data.get("enemies", []), Callable(EnemyState, "from_json")))
	c.turn_number = int(data.get("turn_number", 0))
	c.omen_deck = Serde.obj_from_json(data.get("omen_deck"), Callable(OmenDeckState, "from_json"))
	c.current_cycle = Serde.obj_from_json(data.get("current_cycle"), Callable(OmenCycleState, "from_json"))
	c.pending_repent_slots.assign(Serde.int_array(data.get("pending_repent_slots", [])))
	c.read_the_road_active = bool(data.get("read_the_road_active", false))
	return c
