# MVP1 integration capstone: AIPlayerAgent drives a full Pilgrim Floor 3 run against
# the REAL shipped content (ContentRegistry) and RNGService, start → Judge → RUN_END,
# headlessly and deterministically (SCOPE-001). This is the stub-free version of the
# T7.2 gate, now that all Phase 8 content exists.
# @Spec: SCOPE-001, LLD-ARCH-020, LLD-ARCH-008
extends GdUnitTestSuite

const SignalBusScript = preload("res://src/infrastructure/signal_bus.gd")


func _agent() -> AIPlayerAgent:
	# Fresh SignalBus (avoids touching the EventLog/SaveManager autoloads); real
	# RNGService + ContentRegistry.
	return AIPlayerAgent.new(RNGService, ContentRegistry, auto_free(SignalBusScript.new()))


func after_test() -> void:
	GameConfig.DEBUG = false


func test_real_content_run_completes() -> void:
	for seed in [1, 42, 99, 777, 2024]:
		var r: RunResult = _agent().run_to_completion(seed, "pilgrim")
		assert_str(r.vessel_id).is_equal("pilgrim")
		assert_bool(r.outcome in ["death", "completion"]) \
			.override_failure_message("seed %d ended in '%s'" % [seed, r.outcome]).is_true()
		assert_bool(r.turn_count > 0).is_true()


func test_real_content_run_is_deterministic() -> void:
	for seed in [3, 50, 1234]:
		var a: RunResult = _agent().run_to_completion(seed, "pilgrim")
		var b: RunResult = _agent().run_to_completion(seed, "pilgrim")
		assert_bool(a.equals(b)) \
			.override_failure_message("non-deterministic seed %d: %s vs %s" % [seed, a.to_dict(), b.to_dict()]) \
			.is_true()


# Across many seeds the runs clear rooms — proving the full content stack (enemies
# take damage and die, loot is offered, navigation advances) actually works, not just
# that the loop terminates. A purely random agent rarely clears all 9 rooms + the
# Judge, so this asserts progress rather than victory.
func test_runs_make_combat_progress() -> void:
	var total_rooms := 0
	for seed in range(30):
		total_rooms += _agent().run_to_completion(seed, "pilgrim").rooms_cleared
	assert_int(total_rooms).override_failure_message(
		"0 rooms cleared across 30 runs — enemies may be unkillable").is_greater(5)


# With the DebugHooks.keep_player_alive hook (LLD-ARCH-014), an invincible random
# agent traverses all 9 rooms and beats the Judge — proving every room/enemy on the
# floor is reachable and clearable. This is the "keep the player alive to test all
# rooms" use case. @Spec: LLD-ARCH-014, SCOPE-001
func test_invincible_run_clears_whole_floor() -> void:
	GameConfig.DEBUG = true
	RNGService.seed_run(42)
	var agent := AIPlayerAgent.new(RNGService, ContentRegistry, auto_free(SignalBusScript.new()))
	agent.ai_rng.seed = 42
	var rc := RunController.new()
	rc.configure(RNGService, ContentRegistry, auto_free(SignalBusScript.new()))
	rc.start_run(42, "pilgrim")
	var guard := 0
	while not rc.is_finished() and guard < 1_000_000:
		DebugHooks.keep_player_alive(rc.game_state)   # never die
		agent.play_turn(rc)
		guard += 1
	# Invincible → cannot die → the run can only end by clearing the floor.
	assert_str(rc.outcome).is_equal("completion")
	assert_int(rc.floors_completed).is_equal(1)
	rc.free()
