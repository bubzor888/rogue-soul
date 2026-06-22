# @Spec: LLD-ARCH-017, LLD-ARCH-004
#
# ItemInstance — runtime state for one inventory item (charges remaining).
class_name ItemInstance
extends Resource

@export var item_id: String = ""
@export var remaining_charges: int = 0


func to_json() -> Dictionary:
	return {"item_id": item_id, "remaining_charges": remaining_charges}


static func from_json(data: Dictionary) -> ItemInstance:
	var s := ItemInstance.new()
	s.item_id = str(data.get("item_id", ""))
	s.remaining_charges = int(data.get("remaining_charges", 0))
	return s
