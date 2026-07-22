# Tests for ScreenManager (T6.5): the phase_changed subscription is wired and tracks
# the current phase; under MVP1 headless it performs no scene work (no crash).
# @Spec: LLD-ARCH-007, LLD-ARCH-016, LLD-ARCH-002
extends GdUnitTestSuite

const ScreenManagerScript = preload("res://src/application/screen_manager.gd")
const SignalBusScript = preload("res://src/infrastructure/signal_bus.gd")
const RunPhase := GameState.RunPhase


func _mgr_on(bus):
	var sm = auto_free(ScreenManagerScript.new())
	sm.connect_to_bus(bus)
	return sm


# phase_changed updates current_phase (subscription is wired).
func test_phase_changed_updates_current_phase() -> void:
	var bus = auto_free(SignalBusScript.new())
	var sm = _mgr_on(bus)
	assert_int(sm.current_phase).is_equal(-1)
	bus.phase_changed.emit(RunPhase.COMBAT, RunPhase.NAVIGATION)
	assert_int(sm.current_phase).is_equal(RunPhase.COMBAT)


# Under headless (MVP1) the handler is a no-op beyond tracking — no scene work, no crash.
func test_headless_phase_change_is_safe() -> void:
	var bus = auto_free(SignalBusScript.new())
	var sm = _mgr_on(bus)
	assert_bool(GameConfig.HEADLESS).is_true()  # MVP1 dev default
	bus.phase_changed.emit(RunPhase.RUN_END, RunPhase.COMBAT)
	assert_int(sm.current_phase).is_equal(RunPhase.RUN_END)


# MVP2: the phase->scene-path registry stores and resolves a registered path.
func test_registers_and_resolves_phase_scene_path() -> void:
	var sm = auto_free(ScreenManagerScript.new())
	sm.register_phase_scene(RunPhase.COMBAT, "res://src/presentation/screens/combat.tscn")
	assert_str(sm.scene_path_for_phase(RunPhase.COMBAT)).is_equal("res://src/presentation/screens/combat.tscn")


# An unregistered phase resolves to the empty string (transitional phases have no screen).
func test_unregistered_phase_returns_empty() -> void:
	var sm = auto_free(ScreenManagerScript.new())
	assert_str(sm.scene_path_for_phase(RunPhase.RUN_END)).is_equal("")
