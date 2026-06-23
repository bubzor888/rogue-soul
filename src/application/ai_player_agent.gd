# @Spec: LLD-ARCH-020
#
# AIPlayerAgent — the headless Random-strategy player (LLD-ARCH-020). At each
# decision point it asks the run surface for the legal actions and picks one
# uniformly at random, using its OWN local RandomNumberGenerator. That generator
# is never RNGService: AI decisions must not advance — and therefore must not
# contaminate — any game RNG stream (LLD-ARCH-008). The whole run is still
# deterministic per seed because both the game streams (via RunController) and the
# decision RNG are seeded from the same `seed`.
#
# This is the primary integration driver for the full headless loop (T7.2). It
# talks only through RunController's get_legal_actions()/submit_action() surface,
# which routes every decision through ActionInjector (LLD-ARCH-003) — the agent
# itself never reaches into GameState or any resolver.
class_name AIPlayerAgent
extends RefCounted

# Injected game-side collaborators used to build a RunController per run. `rng` is
# an RNGService-style stream rng; `content` a ContentRegistry-style provider.
var _rng
var _content
var _signal_bus

# The dedicated decision RNG (LLD-ARCH-020) — never RNGService.
var ai_rng: RandomNumberGenerator

# Safety bound: a random agent advances the state on every action, so a real run
# terminates well within this. The cap only guards against an engine bug wedging
# the loop, so it never hangs a headless/CI gate.
const MAX_ACTIONS := 1_000_000


func _init(rng, content, signal_bus = null) -> void:
	_rng = rng
	_content = content
	_signal_bus = signal_bus
	ai_rng = RandomNumberGenerator.new()


# Pick one legal action uniformly at random from the surface and submit it. A
# surface is anything exposing get_legal_actions()/submit_action() — RunController
# in production. No legal actions → no-op. @Spec: LLD-ARCH-020, LLD-ARCH-003
func play_turn(surface) -> void:
	var actions: Array = surface.get_legal_actions()
	if actions.is_empty():
		return
	var index := ai_rng.randi_range(0, actions.size() - 1)
	surface.submit_action(actions[index])


# Start a fresh run with the given seed/vessel and play every decision randomly
# until RUN_END, returning the RunResult. Seeds the decision RNG from the same
# `seed` so the run is fully deterministic (T7.2) while staying independent of the
# game streams. @Spec: LLD-ARCH-020, LLD-ARCH-008
func run_to_completion(seed: int, vessel_id: String) -> RunResult:
	ai_rng.seed = seed
	var rc := RunController.new()
	rc.configure(_rng, _content, _signal_bus)
	rc.start_run(seed, vessel_id)

	var guard := 0
	while not rc.is_finished() and guard < MAX_ACTIONS:
		play_turn(rc)
		guard += 1

	var result := RunResult.new()
	result.seed = seed
	result.vessel_id = vessel_id
	result.floors_completed = rc.floors_completed
	result.outcome = rc.outcome
	result.turn_count = rc.turn_count
	if rc.game_state != null and rc.game_state.navigation_state != null:
		result.rooms_cleared = rc.game_state.navigation_state.rooms_completed_this_floor

	# RunController is a Node created outside the scene tree; free it explicitly
	# (it only queue_free()s itself when inside the tree).
	rc.free()
	return result
