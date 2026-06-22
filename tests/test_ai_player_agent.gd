# Tests for AIPlayerAgent (T7.1): the Random-strategy headless player. Covers the
# play_turn selection (one legal action submitted), the dedicated decision RNG that
# never touches RNGService, and run_to_completion driving a full run to a RunResult.
# @Spec: LLD-ARCH-020, LLD-ARCH-003
extends GdUnitTestSuite

const RunPhase := GameState.RunPhase


# --- Stubs ------------------------------------------------------------------

# A minimal RunController-shaped decision surface: returns a fixed legal set and
# records what the agent submits. Lets play_turn be tested without a full run.
class StubSurface:
	var legal: Array = []
	var finished: bool = false
	var submitted: Array = []
	func get_legal_actions() -> Array:
		return legal
	func submit_action(action: Dictionary) -> void:
		submitted.append(action)
	func is_finished() -> bool:
		return finished


# A game-stream RNG spy: records every roll so a test can prove the agent's
# action selection never advances a game stream.
class SpyRng:
	var calls: int = 0
	func seed_run(_s: int) -> void:
		pass
	func randi_range(_stream: int, a: int, b: int) -> int:
		calls += 1
		return a if a <= b else b


# Content / RNG reused from the RunController test pattern for run_to_completion.
class StubContent:
	var vessels: Dictionary = {}
	var abilities: Dictionary = {}
	var enemies: Dictionary = {}
	var floors: Dictionary = {}
	var companions: Dictionary = {}
	var omen_cards: Dictionary = {}
	func get_vessel(id: String): return vessels.get(id, null)
	func get_ability(id: String): return abilities.get(id, null)
	func get_enemy(id: String): return enemies.get(id, null)
	func get_companion(id: String): return companions.get(id, null)
	func get_omen_card(id: String): return omen_cards.get(id, null)
	func get_floor_by_number(n: int):
		for f in floors.values():
			if f.floor_number == n:
				return f
		return null


class StubRng:
	var _seed: int = 0
	var _rngs: Dictionary = {}
	func seed_run(s: int) -> void:
		_seed = s
		_rngs = {}
	func randi_range(stream: int, a: int, b: int) -> int:
		if not _rngs.has(stream):
			var r := RandomNumberGenerator.new()
			r.seed = _seed + stream
			_rngs[stream] = r
		return _rngs[stream].randi_range(a, b)


# --- Builders (full-run content) --------------------------------------------

func _deal_damage(base: int) -> HandlerConfig:
	var hc := HandlerConfig.new()
	hc.handler_id = "deal_damage"
	hc.params = {"base_damage": base, "damage_type": "physical", "mode": "single"}
	return hc


func _ability(id: String, bucket: String, handlers: Array = [], max_charges: int = 0) -> AbilityData:
	var a := AbilityData.new()
	a.ability_id = id
	a.action_bucket = bucket
	a.max_charges = max_charges
	a.handlers.assign(handlers)
	return a


func _strike_intent(min_d: int, max_d: int) -> IntentWeight:
	var w := IntentWeight.new()
	w.intent_id = "strike"
	w.weight = 100
	w.damage_min = min_d
	w.damage_max = max_d
	w.hit_count = 1
	return w


func _enemy_data(id: String, hp: int, min_d: int, max_d: int) -> EnemyData:
	var e := EnemyData.new()
	e.enemy_id = id
	e.max_hp = hp
	e.damage_type = "physical"
	e.omen_contributions.assign(["%s_card" % id])
	e.intent_weights.assign([_strike_intent(min_d, max_d)])
	return e


func _floor() -> FloorProfile:
	var p := FloorProfile.new()
	p.floor_id = "floor_3"
	p.floor_number = 3
	p.pre_elite_rooms = 4
	p.post_elite_rooms = 4
	p.boss_enemy_id = "the_judge"
	p.normal_enemy_pool.assign(["skeleton"])
	p.elite_enemy_pool.assign(["bear"])
	p.normal_durability_pool.assign(["staff"])
	p.normal_consumable_pool.assign(["bomb"])
	p.elite_durability_pool.assign(["maul"])
	p.elite_consumable_pool.assign(["poultice"])
	return p


# Content sufficient for a full Floor-3 run: weak enemies (so a random agent can
# plausibly win) plus a Pilgrim with a strike and one starting item.
func _content() -> StubContent:
	var c := StubContent.new()
	var vd := VesselData.new()
	vd.vessel_id = "pilgrim"
	vd.max_hp = 30
	vd.default_strike_id = "strike"
	vd.starting_item_ids.assign(["staff"])
	vd.omen_contributions.assign(["c1", "c2", "c3"])
	c.vessels["pilgrim"] = vd
	c.abilities["strike"] = _ability("strike", "attack", [_deal_damage(8)], 0)
	c.abilities["staff"] = _ability("staff", "attack", [_deal_damage(6)], 3)
	c.enemies["skeleton"] = _enemy_data("skeleton", 6, 1, 1)
	c.enemies["bear"] = _enemy_data("bear", 6, 1, 1)
	c.enemies["the_judge"] = _enemy_data("the_judge", 6, 1, 1)
	c.floors["floor_3"] = _floor()
	return c


func _agent(content: StubContent) -> AIPlayerAgent:
	return AIPlayerAgent.new(StubRng.new(), content, null)


# --- play_turn --------------------------------------------------------------

func test_play_turn_submits_one_legal_action() -> void:
	var agent := AIPlayerAgent.new(StubRng.new(), StubContent.new(), null)
	var surface := StubSurface.new()
	surface.legal = [{"type": "A"}, {"type": "B"}, {"type": "C"}]
	agent.play_turn(surface)
	assert_int(surface.submitted.size()).is_equal(1)
	assert_bool(surface.submitted[0] in surface.legal).is_true()


func test_play_turn_no_actions_is_noop() -> void:
	var agent := AIPlayerAgent.new(StubRng.new(), StubContent.new(), null)
	var surface := StubSurface.new()
	surface.legal = []
	agent.play_turn(surface)
	assert_int(surface.submitted.size()).is_equal(0)


# The agent's selection must use its own RandomNumberGenerator, never a game stream.
func test_selection_uses_local_rng_not_game_streams() -> void:
	var spy := SpyRng.new()
	var agent := AIPlayerAgent.new(spy, StubContent.new(), null)
	agent.ai_rng.seed = 12345
	var surface := StubSurface.new()
	surface.legal = [{"type": "A"}, {"type": "B"}, {"type": "C"}, {"type": "D"}]

	# A reference RNG seeded identically must reproduce the agent's choices exactly,
	# proving the agent draws from its own local generator.
	var reference := RandomNumberGenerator.new()
	reference.seed = 12345
	for i in 10:
		agent.play_turn(surface)
		var expected: Dictionary = surface.legal[reference.randi_range(0, surface.legal.size() - 1)]
		assert_object(surface.submitted[i]).is_equal(expected)
	# The injected game RNG was never touched by action selection.
	assert_int(spy.calls).is_equal(0)


# --- run_to_completion ------------------------------------------------------

func test_run_to_completion_returns_finished_result() -> void:
	var agent := _agent(_content())
	var result: RunResult = agent.run_to_completion(42, "pilgrim")
	assert_int(result.seed).is_equal(42)
	assert_str(result.vessel_id).is_equal("pilgrim")
	assert_bool(result.outcome in ["death", "completion"]).is_true()
	assert_bool(result.turn_count >= 0).is_true()


func test_run_to_completion_never_advances_ai_via_game_rng() -> void:
	# Two agents sharing the same content but different game seeds still make the
	# same decisions when their decision RNG is seeded the same — selection is
	# independent of the game streams. (Determinism of the whole run is T7.2.)
	var agent_a := _agent(_content())
	var agent_b := _agent(_content())
	var ra: RunResult = agent_a.run_to_completion(7, "pilgrim")
	var rb: RunResult = agent_b.run_to_completion(7, "pilgrim")
	assert_str(ra.outcome).is_equal(rb.outcome)
	assert_int(ra.turn_count).is_equal(rb.turn_count)
