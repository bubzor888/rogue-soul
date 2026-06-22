# @Spec: LLD-ARCH-017, LLD-ARCH-004
#
# DoorData — one door in the current two-door navigation choice.
class_name DoorData
extends Resource

## RoomType enum value (as a String for MVP1).
@export var room_type: String = ""

## enemy_id for combat doors; event_id for non-combat doors.
@export var encounter_id: String = ""

## Unique per-run identifier (for logging).
@export var room_id: String = ""


func to_json() -> Dictionary:
	return {"room_type": room_type, "encounter_id": encounter_id, "room_id": room_id}


static func from_json(data: Dictionary) -> DoorData:
	var d := DoorData.new()
	d.room_type = str(data.get("room_type", ""))
	d.encounter_id = str(data.get("encounter_id", ""))
	d.room_id = str(data.get("room_id", ""))
	return d
