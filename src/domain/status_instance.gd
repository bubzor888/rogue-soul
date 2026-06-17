# @Spec: LLD-ARCH-017, LLD-ARCH-004
#
# StatusInstance — one active status effect on a unit. `magnitude` carries the
# evolving numeric value (Chilled reduction, Poisoned value, Bleed stacks, ...);
# `trigger` is "tick" (fires each omen tick) or "shift" (fires once at tick 0);
# `string_param` is the type qualifier for parameterized statuses (e.g. "fire"
# when status_id is "type_convert"/"vulnerable"/"emboldened").
class_name StatusInstance
extends Resource

@export var status_id: String = ""
@export var remaining_ticks: int = 0
@export var magnitude: int = 0
@export var trigger: String = "tick"
@export var string_param: String = ""


func to_json() -> Dictionary:
	return {
		"status_id": status_id,
		"remaining_ticks": remaining_ticks,
		"magnitude": magnitude,
		"trigger": trigger,
		"string_param": string_param,
	}


static func from_json(data: Dictionary) -> StatusInstance:
	var s := StatusInstance.new()
	s.status_id = str(data.get("status_id", ""))
	s.remaining_ticks = int(data.get("remaining_ticks", 0))
	s.magnitude = int(data.get("magnitude", 0))
	s.trigger = str(data.get("trigger", "tick"))
	s.string_param = str(data.get("string_param", ""))
	return s
