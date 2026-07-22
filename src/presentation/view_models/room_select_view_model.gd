# @Spec: UI-ROOM-002, UI-ROOM-008, UI-ROOM-007
#
# RoomSelectViewModel — maps NAVIGATION GameState + the legal CHOOSE_DOOR actions to the
# room-select display. Pure/headless; the view renders these dictionaries and submits the
# paired action verbatim. A door's symbol identifies the SPECIFIC enemy for combat doors
# (UI-ROOM-002) and a fixed symbol for MF/WS doors.
class_name RoomSelectViewModel
extends RefCounted

const _MF_SYMBOL := ArtPaths.DOOR_SYMBOL_PLACEHOLDER  # fixed MF symbol (real asset in the art session)
const _WS_SYMBOL := ArtPaths.DOOR_SYMBOL_PLACEHOLDER  # fixed WS symbol (real asset in the art session)

var _gs: GameState
var _legal: Array
var _floor_total: int

func _init(gs: GameState, legal_actions: Array, floor_total: int = -1) -> void:
	_gs = gs
	_legal = legal_actions
	_floor_total = floor_total  # real per-floor room count (FloorProfile.total_rooms); -1 = derive

# One row per door: { "symbol": path, "action": the paired CHOOSE_DOOR dict }.
func door_rows() -> Array:
	var rows: Array = []
	for door in _gs.navigation_state.doors_ahead:
		var action := _action_for(door.room_id)
		if action.is_empty():
			continue
		rows.append({"symbol": _symbol_for(door), "action": action})
	return rows

func _action_for(room_id: String) -> Dictionary:
	for a in _legal:
		if str(a.get("type", "")) == "CHOOSE_DOOR" and str(a.get("room_id", "")) == room_id:
			return a
	return {}

func _symbol_for(door: DoorData) -> String:
	match door.room_type:
		"memory_fragment": return _MF_SYMBOL
		"wandering_soul": return _WS_SYMBOL
		_: return ArtPaths.door_symbol(door.encounter_id)  # combat/elite: per-enemy symbol

# @Spec: UI-ROOM-008
# Prefer the injected real floor total (FloorProfile.total_rooms, supplied by the view
# from content); fall back to summing segment_room_counts for pure/headless callers.
func total_rooms() -> int:
	if _floor_total >= 0:
		return _floor_total
	var n := 0
	for count in _gs.navigation_state.segment_room_counts.values():
		n += int(count)
	return n

func rooms_completed() -> int:
	return _gs.navigation_state.rooms_completed_this_floor

# @Spec: UI-ROOM-007
func vessel_sprite() -> String:
	return ArtPaths.vessel_sprite(_gs.vessel_state.vessel_id) if _gs.vessel_state != null else ""
