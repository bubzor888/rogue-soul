# Tests for SaveManager (T6.5): versioned run save/load via PersistenceService, the
# CHECKPOINT detection that gates Resume / Start Over, and the save_requested signal
# path. @Spec: LLD-ARCH-007, LLD-ARCH-016, LLD-ARCH-010
extends GdUnitTestSuite

const SaveManagerScript = preload("res://src/application/save_manager.gd")
const SignalBusScript = preload("res://src/infrastructure/signal_bus.gd")

const TMP_SAVE := "user://test_savemgr/run.json"
const BACKGROUND := RunController.SaveType.BACKGROUND
const CHECKPOINT := RunController.SaveType.CHECKPOINT


func before_test() -> void:
	_cleanup()


func after_test() -> void:
	_cleanup()


func _cleanup() -> void:
	if FileAccess.file_exists(TMP_SAVE):
		DirAccess.remove_absolute(TMP_SAVE)


func _mgr():
	var m = auto_free(SaveManagerScript.new())
	m.save_path = TMP_SAVE
	return m


func _gs(hp: int = 20) -> GameState:
	var gs := GameState.new()
	gs.run_seed = 1234
	gs.floor_number = 3
	gs.vessel_state = VesselState.new()
	gs.vessel_state.vessel_id = "pilgrim"
	gs.vessel_state.hp = hp
	gs.vessel_state.max_hp = 30
	gs.item_burden_score = 5
	return gs


# --- Save / load round-trip -------------------------------------------------

func test_save_load_round_trip() -> void:
	var m = _mgr()
	var gs := _gs(17)
	assert_bool(m.save(gs, BACKGROUND)).is_true()
	var loaded: GameState = m.load_run()
	assert_object(loaded).is_not_null()
	assert_dict(loaded.to_json()).is_equal(gs.to_json())


func test_load_missing_returns_null() -> void:
	var m = _mgr()
	assert_object(m.load_run()).is_null()
	assert_bool(m.has_save()).is_false()
	assert_bool(m.has_checkpoint()).is_false()


# --- Checkpoint detection (Resume / Start Over gate) ------------------------

func test_checkpoint_save_is_detected() -> void:
	var m = _mgr()
	m.save(_gs(), CHECKPOINT)
	assert_bool(m.has_save()).is_true()
	assert_bool(m.has_checkpoint()).is_true()


func test_background_save_is_not_a_checkpoint() -> void:
	var m = _mgr()
	m.save(_gs(), BACKGROUND)
	assert_bool(m.has_save()).is_true()
	assert_bool(m.has_checkpoint()).is_false()


func test_resume_returns_saved_state() -> void:
	var m = _mgr()
	var gs := _gs(9)
	m.save(gs, CHECKPOINT)
	assert_dict(m.resume().to_json()).is_equal(gs.to_json())


func test_start_over_clears_save() -> void:
	var m = _mgr()
	m.save(_gs(), CHECKPOINT)
	m.start_over()
	assert_bool(m.has_save()).is_false()
	assert_object(m.load_run()).is_null()


# --- save_requested signal path ---------------------------------------------

func test_save_requested_signal_saves_active_state() -> void:
	var m = _mgr()
	var bus = auto_free(SignalBusScript.new())
	m.connect_to_bus(bus)
	var gs := _gs(12)
	m.set_active_state(gs)
	bus.save_requested.emit(CHECKPOINT)
	assert_bool(m.has_checkpoint()).is_true()
	assert_dict(m.load_run().to_json()).is_equal(gs.to_json())


func test_save_requested_without_active_state_is_noop() -> void:
	var m = _mgr()
	var bus = auto_free(SignalBusScript.new())
	m.connect_to_bus(bus)
	bus.save_requested.emit(BACKGROUND)  # no set_active_state
	assert_bool(m.has_save()).is_false()
