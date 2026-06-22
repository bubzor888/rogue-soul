# @Spec: LLD-ARCH-017, LLD-ARCH-004
#
# NavigationState — current navigation/encounter context within a floor.
class_name NavigationState
extends Resource

@export var rooms_completed_this_floor: int = 0

## room type -> count, for pool exhaustion (HLD-DOOR-004).
@export var segment_room_counts: Dictionary = {}

## The current two-door choice; empty outside NAVIGATION phase.
@export var doors_ahead: Array[DoorData] = []

## true once any companion encounter has fired this floor (blocks further MF
## companion draws — HLD-MF-004).
@export var companion_offered_this_floor: bool = false

## Current non-combat event sub-type: "wandering_soul" | "mf_cat_a" | "mf_cat_c"
## | "companion" | ""; empty outside NON_COMBAT_EVENT phase.
@export var event_type: String = ""

## Trade offer Dictionaries (TradeOffer format, LLD-ARCH-021); empty outside a
## trade event or after it resolves.
@export var event_offers: Array[Dictionary] = []

## Exactly 2 item_id strings set by LootGenerator in LOOT_SELECTION; empty otherwise.
@export var loot_offers: Array[String] = []


func to_json() -> Dictionary:
	return {
		"rooms_completed_this_floor": rooms_completed_this_floor,
		"segment_room_counts": segment_room_counts.duplicate(true),
		"doors_ahead": Serde.res_array_to_json(doors_ahead),
		"companion_offered_this_floor": companion_offered_this_floor,
		"event_type": event_type,
		"event_offers": Serde.dicts_dup(event_offers),
		"loot_offers": loot_offers.duplicate(),
	}


static func from_json(data: Dictionary) -> NavigationState:
	var n := NavigationState.new()
	n.rooms_completed_this_floor = int(data.get("rooms_completed_this_floor", 0))
	n.segment_room_counts = Serde.int_dict(data.get("segment_room_counts", {}))
	n.doors_ahead.assign(Serde.res_array_from_json(data.get("doors_ahead", []), Callable(DoorData, "from_json")))
	n.companion_offered_this_floor = bool(data.get("companion_offered_this_floor", false))
	n.event_type = str(data.get("event_type", ""))
	n.event_offers.assign(Serde.dicts_dup(data.get("event_offers", [])))
	n.loot_offers.assign(Serde.str_array(data.get("loot_offers", [])))
	return n
