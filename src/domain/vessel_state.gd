# @Spec: LLD-ARCH-017, LLD-ARCH-004
#
# VesselState — runtime state of the player's vessel.
class_name VesselState
extends Resource

@export var vessel_id: String = ""
@export var hp: int = 0
@export var max_hp: int = 0
@export var ability_states: Array[AbilityState] = []
@export var active_statuses: Array[StatusInstance] = []

## true when the vessel chose Evade this turn; reset at the start of each player
## turn before any action is processed.
@export var is_evading: bool = false

## true when stunned by a Shocked shift; blocks the Action bucket for the next
## player turn; reset at the start of resolve_player_action.
@export var is_stunned: bool = false


func to_json() -> Dictionary:
	return {
		"vessel_id": vessel_id,
		"hp": hp,
		"max_hp": max_hp,
		"ability_states": Serde.res_array_to_json(ability_states),
		"active_statuses": Serde.res_array_to_json(active_statuses),
		"is_evading": is_evading,
		"is_stunned": is_stunned,
	}


static func from_json(data: Dictionary) -> VesselState:
	var v := VesselState.new()
	v.vessel_id = str(data.get("vessel_id", ""))
	v.hp = int(data.get("hp", 0))
	v.max_hp = int(data.get("max_hp", 0))
	v.ability_states.assign(Serde.res_array_from_json(data.get("ability_states", []), Callable(AbilityState, "from_json")))
	v.active_statuses.assign(Serde.res_array_from_json(data.get("active_statuses", []), Callable(StatusInstance, "from_json")))
	v.is_evading = bool(data.get("is_evading", false))
	v.is_stunned = bool(data.get("is_stunned", false))
	return v
