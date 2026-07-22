# @Spec: UI-ROOM-002, UI-ROOM-007, UI-ROOM-008
extends GdUnitTestSuite

func _door(room_id: String, room_type: String, enc: String) -> DoorData:
	var d := DoorData.new(); d.room_id = room_id; d.room_type = room_type; d.encounter_id = enc; return d

func _state_with_two_doors() -> GameState:
	var gs := GameState.new()
	gs.floor_number = 3
	gs.navigation_state = NavigationState.new()
	gs.navigation_state.rooms_completed_this_floor = 2
	gs.navigation_state.doors_ahead.assign([
		_door("r1", "combat", "plague_rat"),
		_door("r2", "combat", "skeleton"),
	])
	return gs

func test_two_door_rows_pair_symbol_with_legal_action() -> void:
	var gs := _state_with_two_doors()
	var legal := [
		{"type": "CHOOSE_DOOR", "room_id": "r1"},
		{"type": "CHOOSE_DOOR", "room_id": "r2"},
	]
	var vm := RoomSelectViewModel.new(gs, legal)
	var rows := vm.door_rows()
	assert_int(rows.size()).is_equal(2)
	assert_str(rows[0]["symbol"]).is_equal(ArtPaths.door_symbol("plague_rat"))
	assert_dict(rows[0]["action"]).is_equal({"type": "CHOOSE_DOOR", "room_id": "r1"})

# UI-ROOM-008: one segment per room; filled == rooms completed; exact real count (no obscuring).
func test_floor_progress_segments() -> void:
	var gs := _state_with_two_doors()
	gs.navigation_state.segment_room_counts = {"a": 5, "b": 4}  # 9 rooms total
	var vm := RoomSelectViewModel.new(gs, [])
	assert_int(vm.total_rooms()).is_equal(9)
	assert_int(vm.rooms_completed()).is_equal(2)

# The real floor total (from FloorProfile.total_rooms via the view) overrides the
# unpopulated segment_room_counts field, so the progress bar shows the true room count.
func test_floor_total_overrides_segment_sum() -> void:
	var gs := _state_with_two_doors()
	gs.navigation_state.segment_room_counts = {}  # engine leaves this empty in a real run
	var vm := RoomSelectViewModel.new(gs, [], 9)
	assert_int(vm.total_rooms()).is_equal(9)

func test_vessel_sprite_path() -> void:
	var gs := _state_with_two_doors()
	gs.vessel_state = VesselState.new(); gs.vessel_state.vessel_id = "pilgrim"
	var vm := RoomSelectViewModel.new(gs, [])
	assert_str(vm.vessel_sprite()).is_equal(ArtPaths.vessel_sprite("pilgrim"))
