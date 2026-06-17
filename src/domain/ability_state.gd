# @Spec: LLD-ARCH-017, LLD-ARCH-004
#
# AbilityState — runtime charge state for one vessel/companion ability.
class_name AbilityState
extends Resource

@export var ability_id: String = ""
@export var remaining_charges: int = 0


func to_json() -> Dictionary:
	return {"ability_id": ability_id, "remaining_charges": remaining_charges}


static func from_json(data: Dictionary) -> AbilityState:
	var s := AbilityState.new()
	s.ability_id = str(data.get("ability_id", ""))
	s.remaining_charges = int(data.get("remaining_charges", 0))
	return s
