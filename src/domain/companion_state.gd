# @Spec: LLD-ARCH-017, LLD-ARCH-004
#
# CompanionState — runtime state of an active companion. No hp field: companions
# are not targetable in combat (HLD-COMPANION-001).
class_name CompanionState
extends Resource

@export var companion_id: String = ""
@export var ability_states: Array[AbilityState] = []

## Generic countdown (e.g. Shadow's HP-drain budget); copied from
## CompanionData.initial_timer on activation; -1 = not used by this companion.
@export var companion_timer: int = 0

## Companion-specific runtime state not covered by standard fields (free-form;
## read/written by the companion's handler chain).
@export var companion_context: Dictionary = {}


func to_json() -> Dictionary:
	return {
		"companion_id": companion_id,
		"ability_states": Serde.res_array_to_json(ability_states),
		"companion_timer": companion_timer,
		"companion_context": companion_context.duplicate(true),
	}


static func from_json(data: Dictionary) -> CompanionState:
	var c := CompanionState.new()
	c.companion_id = str(data.get("companion_id", ""))
	c.ability_states.assign(Serde.res_array_from_json(data.get("ability_states", []), Callable(AbilityState, "from_json")))
	c.companion_timer = int(data.get("companion_timer", 0))
	c.companion_context = (data.get("companion_context", {}) as Dictionary).duplicate(true)
	return c
