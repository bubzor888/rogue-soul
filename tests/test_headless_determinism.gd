# T7.2 — Full headless determinism integration gate (the primary MVP1 integration
# test). Running the same seed twice through AIPlayerAgent must produce byte-identical
# RunResults (same turns, same outcome, same floors). Exercised across several seeds.
# Uses the real RNGService autoload to prove the game streams reset cleanly per run;
# content is stubbed (Phase 8 content isn't required for the determinism property).
# @Spec: LLD-ARCH-020, LLD-ARCH-008, SCOPE-001
extends GdUnitTestSuite

const SignalBusScript = preload("res://src/infrastructure/signal_bus.gd")


# --- Stub content (a fully playable Floor-3 run) ----------------------------

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


func _deal_damage(base: int) -> HandlerConfig:
	var hc := HandlerConfig.new()
	hc.handler_id = "deal_damage"
	hc.params = {"base_damage": base, "damage_type": "physical", "mode": "single"}
	return hc


func _ability(id: String, bucket: String, handlers: Array, max_charges: int) -> AbilityData:
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


func _enemy_data(id: String, hp: int) -> EnemyData:
	var e := EnemyData.new()
	e.enemy_id = id
	e.max_hp = hp
	e.damage_type = "physical"
	e.omen_contributions.assign(["%s_card" % id])
	e.intent_weights.assign([_strike_intent(2, 4)])
	return e


func _floor() -> FloorProfile:
	var p := FloorProfile.new()
	p.floor_id = "floor_3"
	p.floor_number = 3
	p.pre_elite_rooms = 4
	p.post_elite_rooms = 4
	p.boss_enemy_id = "the_judge"
	p.normal_enemy_pool.assign(["skeleton", "zombie"])
	p.elite_enemy_pool.assign(["bear"])
	p.normal_durability_pool.assign(["staff", "club"])
	p.normal_consumable_pool.assign(["bomb", "tonic"])
	p.elite_durability_pool.assign(["maul"])
	p.elite_consumable_pool.assign(["poultice"])
	return p


func _content() -> StubContent:
	var c := StubContent.new()
	var vd := VesselData.new()
	vd.vessel_id = "pilgrim"
	vd.max_hp = 30
	vd.default_strike_id = "strike"
	vd.starting_item_ids.assign(["staff"])
	vd.omen_contributions.assign(["c1", "c2", "c3"])
	c.vessels["pilgrim"] = vd
	c.abilities["strike"] = _ability("strike", "attack", [_deal_damage(7)], 0)
	c.abilities["staff"] = _ability("staff", "attack", [_deal_damage(6)], 3)
	for id in ["skeleton", "zombie", "bear", "the_judge"]:
		c.enemies[id] = _enemy_data(id, 8)
	c.floors["floor_3"] = _floor()
	return c


# A fresh agent wired to the REAL RNGService autoload (the game streams) and a
# fresh SignalBus. The decision RNG is the agent's own, seeded in run_to_completion.
func _agent() -> AIPlayerAgent:
	return AIPlayerAgent.new(RNGService, _content(), auto_free(SignalBusScript.new()))


# --- The gate ---------------------------------------------------------------

func test_same_seed_produces_identical_run_results() -> void:
	for seed in [1, 7, 42, 99, 1234, 65535]:
		var first: RunResult = _agent().run_to_completion(seed, "pilgrim")
		var second: RunResult = _agent().run_to_completion(seed, "pilgrim")
		assert_bool(first.equals(second)) \
			.override_failure_message(
				"Non-deterministic run for seed %d: %s vs %s"
					% [seed, first.to_dict(), second.to_dict()]) \
			.is_true()


func test_run_result_records_seed_and_vessel() -> void:
	var result: RunResult = _agent().run_to_completion(42, "pilgrim")
	assert_int(result.seed).is_equal(42)
	assert_str(result.vessel_id).is_equal("pilgrim")
	assert_bool(result.outcome in ["death", "completion"]).is_true()


# Different seeds should generally diverge — proves the seed actually drives the
# run (a constant result would also be "deterministic" but meaningless).
func test_different_seeds_can_diverge() -> void:
	var outcomes: Array = []
	var turns: Array = []
	for seed in range(40):
		var r: RunResult = _agent().run_to_completion(seed, "pilgrim")
		outcomes.append(r.outcome)
		turns.append(r.turn_count)
	# Across 40 seeds the random agent must not collapse to a single fixed run.
	var distinct := {}
	for i in outcomes.size():
		distinct[str(outcomes[i]) + ":" + str(turns[i])] = true
	assert_int(distinct.size()).is_greater(1)
