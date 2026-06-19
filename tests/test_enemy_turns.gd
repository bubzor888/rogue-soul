# Tests for CombatResolver enemy turns & intent engine (T5.5): weighted/forced/
# restricted intent selection, consecutive cap, evade, Charge→Release, multi-hit
# damage + evade miss, status_apply (+ stacking, targets), intent handlers,
# resolve_enemy_summon (family-card injection), and turns_alive tracking.
# @Spec: HLD-COMBAT-009, -014, -016, LLD-ARCH-019, LLD-ARCH-018
extends GdUnitTestSuite


# --- Stubs ------------------------------------------------------------------

class StubContent:
	var enemies: Dictionary = {}
	func get_enemy(id: String):
		return enemies.get(id, null)


# Scriptable RNG: pops `queue` in call order; otherwise clamps `default` into the
# requested [a, b] range (so damage rolls with min==max are deterministic and the
# default selection roll resolves to the first weighted candidate).
class StubRng:
	var queue: Array = []
	var default: int = 0
	func randi_range(_stream: int, a: int, b: int) -> int:
		var v: int = default
		if not queue.is_empty():
			v = queue.pop_front()
		return clampi(v, a, b)


# --- Intent / enemy builders ------------------------------------------------

func _intent(id: String) -> IntentWeight:
	var w := IntentWeight.new()
	w.intent_id = id
	w.weight = 1
	return w


func _attack_intent(id: String, dmin: int, dmax: int, hits: int = 1) -> IntentWeight:
	var w := _intent(id)
	w.damage_min = dmin
	w.damage_max = dmax
	w.hit_count = hits
	return w


func _enemy_data(id: String, intents: Array, conditionals: Array = [], dmg_type: String = "physical", contributions: Array = []) -> EnemyData:
	var e := EnemyData.new()
	e.enemy_id = id
	e.damage_type = dmg_type
	e.intent_weights.assign(intents)
	e.intent_conditionals.assign(conditionals)
	e.omen_contributions.assign(contributions)
	return e


func _conditional(condition: String, intent_id: String = "", intent_ids: Array = []) -> IntentConditional:
	var c := IntentConditional.new()
	c.condition = condition
	c.intent_id = intent_id
	c.intent_ids.assign(intent_ids)
	return c


# A combat GameState: a vessel (the player target) plus the given enemy specs.
# enemy_specs: { enemy_id, instance_id, hp?, max_hp? }.
func _gs(content: StubContent, enemy_specs: Array, player_hp: int = 30) -> GameState:
	var gs := GameState.new()
	gs.vessel_state = VesselState.new()
	gs.vessel_state.vessel_id = "pilgrim"
	gs.vessel_state.hp = player_hp
	gs.vessel_state.max_hp = 30
	gs.combat_state = CombatState.new()
	gs.combat_state.omen_deck = OmenDeckState.new()
	var enemies: Array[EnemyState] = []
	for spec in enemy_specs:
		var e := EnemyState.new()
		e.enemy_id = spec["enemy_id"]
		e.instance_id = spec["instance_id"]
		e.hp = spec.get("hp", 10)
		e.max_hp = spec.get("max_hp", 10)
		enemies.append(e)
	gs.combat_state.enemies.assign(enemies)
	return gs


func _enemy(gs: GameState, instance_id: String) -> EnemyState:
	for e in gs.combat_state.enemies:
		if e.instance_id == instance_id:
			return e
	return null


func _resolver(content: StubContent, rng) -> CombatResolver:
	return CombatResolver.new(rng, content, AbilityPipeline.with_default_handlers())


# --- Intent selection -------------------------------------------------------

# Weighted roll: with weights [a:1, b:1] (total 2), an rng r of 1 selects "b".
func test_weighted_selection_picks_by_roll() -> void:
	var content := StubContent.new()
	content.enemies["goblin"] = _enemy_data("goblin", [_intent("a"), _intent("b")])
	var gs := _gs(content, [{"enemy_id": "goblin", "instance_id": "goblin_0"}])
	var rng := StubRng.new()
	rng.queue = [1]  # cumulative index 1 → second candidate "b"
	_resolver(content, rng).resolve_enemy_turns(gs)
	assert_str(_enemy(gs, "goblin_0").current_intent).is_equal("b")


# A matching conditional with a forced intent_id selects it with no COMBAT roll.
func test_conditional_forces_intent_no_roll() -> void:
	var content := StubContent.new()
	var cond := _conditional("turn_number:1", "sleeping")
	content.enemies["bear"] = _enemy_data("bear", [_intent("sleeping"), _attack_intent("maul", 5, 5)], [cond])
	var gs := _gs(content, [{"enemy_id": "bear", "instance_id": "bear_0"}])
	var rng := StubRng.new()
	rng.queue = []  # empty: any COMBAT roll would clamp-default; none should occur
	_resolver(content, rng).resolve_enemy_turns(gs)
	assert_str(_enemy(gs, "bear_0").current_intent).is_equal("sleeping")
	assert_int(gs.vessel_state.hp).is_equal(30)  # sleeping deals no damage


# A conditional with intent_ids restricts the weighted roll to that subset.
func test_conditional_restricts_pool() -> void:
	var content := StubContent.new()
	# ally_count_above:0 → restricted to [bite_pack, evade]; bite_lone ineligible.
	var cond := _conditional("ally_count_above:0", "", ["bite_pack", "evade"])
	var intents := [_attack_intent("bite_lone", 9, 9), _attack_intent("bite_pack", 3, 3), _intent("evade")]
	intents[2].is_evade = true
	content.enemies["wolf"] = _enemy_data("wolf", intents, [cond])
	var gs := _gs(content, [
		{"enemy_id": "wolf", "instance_id": "wolf_0"},
		{"enemy_id": "wolf", "instance_id": "wolf_1"},
	])
	var rng := StubRng.new()
	rng.default = 0  # first eligible of the restricted pool → bite_pack
	_resolver(content, rng).resolve_enemy_turns(gs)
	assert_str(_enemy(gs, "wolf_0").current_intent).is_equal("bite_pack")


# Consecutive cap: an intent at its max consecutive count is re-rolled to a different one.
func test_consecutive_cap_rerolls() -> void:
	var content := StubContent.new()
	var a := _attack_intent("a", 2, 2)
	a.max_consecutive = 2
	content.enemies["goblin"] = _enemy_data("goblin", [a, _attack_intent("b", 1, 1)])
	var gs := _gs(content, [{"enemy_id": "goblin", "instance_id": "goblin_0"}])
	var e := _enemy(gs, "goblin_0")
	e.last_intent_id = "a"
	e.intent_streak = 2  # already at the cap
	var rng := StubRng.new()
	# First roll → "a" (index 0); capped → re-roll → "b" (cumulative index 1).
	rng.queue = [0, 1, 1]
	_resolver(content, rng).resolve_enemy_turns(gs)
	assert_str(e.current_intent).is_equal("b")
	assert_int(e.intent_streak).is_equal(1)  # changed intent resets streak


# Selecting the same intent again (under the cap) increments the streak.
func test_streak_increments_on_repeat() -> void:
	var content := StubContent.new()
	var a := _attack_intent("a", 2, 2)
	a.max_consecutive = 3
	content.enemies["goblin"] = _enemy_data("goblin", [a])
	var gs := _gs(content, [{"enemy_id": "goblin", "instance_id": "goblin_0"}])
	var e := _enemy(gs, "goblin_0")
	e.last_intent_id = "a"
	e.intent_streak = 1
	_resolver(content, StubRng.new()).resolve_enemy_turns(gs)
	assert_str(e.current_intent).is_equal("a")
	assert_int(e.intent_streak).is_equal(2)


# --- Evade / stun -----------------------------------------------------------

# An Evade intent sets is_evading and deals no damage.
func test_evade_intent_sets_flag() -> void:
	var content := StubContent.new()
	var ev := _intent("evade")
	ev.is_evade = true
	content.enemies["wolf"] = _enemy_data("wolf", [ev])
	var gs := _gs(content, [{"enemy_id": "wolf", "instance_id": "wolf_0"}])
	_resolver(content, StubRng.new()).resolve_enemy_turns(gs)
	assert_bool(_enemy(gs, "wolf_0").is_evading).is_true()
	assert_int(gs.vessel_state.hp).is_equal(30)


# A stunned enemy resets is_stunned and takes no action this turn.
func test_stunned_enemy_skips_turn() -> void:
	var content := StubContent.new()
	content.enemies["goblin"] = _enemy_data("goblin", [_attack_intent("hit", 5, 5)])
	var gs := _gs(content, [{"enemy_id": "goblin", "instance_id": "goblin_0"}])
	_enemy(gs, "goblin_0").is_stunned = true
	_resolver(content, StubRng.new()).resolve_enemy_turns(gs)
	assert_bool(_enemy(gs, "goblin_0").is_stunned).is_false()
	assert_int(gs.vessel_state.hp).is_equal(30)  # no damage dealt


# --- Charge → Release -------------------------------------------------------

# A Charge→Release intent's charge turn sets is_charging and deals no damage.
func test_charge_turn_sets_charging_no_damage() -> void:
	var content := StubContent.new()
	var charge := _attack_intent("big_smash", 20, 20)
	charge.is_charge_release = true
	content.enemies["ogre"] = _enemy_data("ogre", [charge])
	var gs := _gs(content, [{"enemy_id": "ogre", "instance_id": "ogre_0"}])
	_resolver(content, StubRng.new()).resolve_enemy_turns(gs)
	assert_bool(_enemy(gs, "ogre_0").is_charging).is_true()
	assert_int(gs.vessel_state.hp).is_equal(30)  # charge turn deals no damage


# On the next turn, a charging enemy releases unconditionally and clears is_charging.
func test_charge_release_fires_next_turn() -> void:
	var content := StubContent.new()
	var charge := _attack_intent("big_smash", 12, 12)
	charge.is_charge_release = true
	content.enemies["ogre"] = _enemy_data("ogre", [charge, _attack_intent("filler", 1, 1)])
	var gs := _gs(content, [{"enemy_id": "ogre", "instance_id": "ogre_0"}])
	var e := _enemy(gs, "ogre_0")
	e.is_charging = true
	e.last_intent_id = "big_smash"  # the charged intent
	e.current_intent = "big_smash"
	_resolver(content, StubRng.new()).resolve_enemy_turns(gs)
	assert_bool(e.is_charging).is_false()
	assert_int(gs.vessel_state.hp).is_equal(18)  # 30 − 12 release


# Stun during the charge turn cancels the release (it never fires).
func test_stun_cancels_charge_release() -> void:
	var content := StubContent.new()
	var charge := _attack_intent("big_smash", 12, 12)
	charge.is_charge_release = true
	content.enemies["ogre"] = _enemy_data("ogre", [charge])
	var gs := _gs(content, [{"enemy_id": "ogre", "instance_id": "ogre_0"}])
	var e := _enemy(gs, "ogre_0")
	e.is_charging = true
	e.is_stunned = true
	_resolver(content, StubRng.new()).resolve_enemy_turns(gs)
	assert_bool(e.is_charging).is_false()  # release cancelled
	assert_int(gs.vessel_state.hp).is_equal(30)


# --- Damage execution -------------------------------------------------------

# Multi-hit: hit_count independent rolls, summed.
func test_multi_hit_sums_damage() -> void:
	var content := StubContent.new()
	content.enemies["bear"] = _enemy_data("bear", [_attack_intent("swipe", 3, 3, 2)])
	var gs := _gs(content, [{"enemy_id": "bear", "instance_id": "bear_0"}])
	_resolver(content, StubRng.new()).resolve_enemy_turns(gs)
	assert_int(gs.vessel_state.hp).is_equal(24)  # 30 − (3 + 3)


# Each hit rolls evade-miss independently when the player is evading.
func test_evading_player_one_hit_misses() -> void:
	var content := StubContent.new()
	content.enemies["bear"] = _enemy_data("bear", [_attack_intent("swipe", 4, 4, 2)])
	var gs := _gs(content, [{"enemy_id": "bear", "instance_id": "bear_0"}])
	gs.vessel_state.is_evading = true
	var rng := StubRng.new()
	# Roll order: intent selection, then per hit (damage roll, miss roll).
	# Hit 1: dmg 4, miss roll 0 (≤34 → miss). Hit 2: dmg 4, miss roll 99 (>34 → lands).
	rng.queue = [0, 4, 0, 4, 99]
	_resolver(content, rng).resolve_enemy_turns(gs)
	assert_int(gs.vessel_state.hp).is_equal(26)  # only the second hit (4) lands


# --- Status application -----------------------------------------------------

# A status_apply intent applies the status to the player.
func test_status_apply_to_player() -> void:
	var content := StubContent.new()
	var kindle := _intent("kindle")
	kindle.status_apply = "burning"
	kindle.status_magnitude = 2
	content.enemies["fire_elem"] = _enemy_data("fire_elem", [kindle], [], "fire")
	var gs := _gs(content, [{"enemy_id": "fire_elem", "instance_id": "fire_elem_0"}])
	gs.combat_state.current_cycle = _assigned_cycle(2)
	_resolver(content, StubRng.new()).resolve_enemy_turns(gs)
	var statuses := gs.vessel_state.active_statuses
	assert_int(statuses.size()).is_equal(1)
	assert_str(statuses[0].status_id).is_equal("burning")
	assert_int(statuses[0].magnitude).is_equal(2)


# Burning magnitude stacks additively onto an existing Burning (scenario 1133).
func test_status_apply_stacks_burning() -> void:
	var content := StubContent.new()
	var kindle := _intent("kindle")
	kindle.status_apply = "burning"
	kindle.status_magnitude = 2
	content.enemies["fire_elem"] = _enemy_data("fire_elem", [kindle], [], "fire")
	var gs := _gs(content, [{"enemy_id": "fire_elem", "instance_id": "fire_elem_0"}])
	gs.combat_state.current_cycle = _assigned_cycle(2)
	var existing := StatusInstance.new()
	existing.status_id = "burning"
	existing.magnitude = 3
	existing.remaining_ticks = 2
	existing.trigger = "tick"
	gs.vessel_state.active_statuses.assign([existing])
	_resolver(content, StubRng.new()).resolve_enemy_turns(gs)
	assert_int(gs.vessel_state.active_statuses.size()).is_equal(1)
	assert_int(gs.vessel_state.active_statuses[0].magnitude).is_equal(5)  # 3 + 2


# status_target "self" applies to the caster.
func test_status_apply_self() -> void:
	var content := StubContent.new()
	var harden := _intent("harden")
	harden.status_apply = "hardened"
	harden.status_magnitude = 4
	harden.status_target = "self"
	content.enemies["golem"] = _enemy_data("golem", [harden])
	var gs := _gs(content, [{"enemy_id": "golem", "instance_id": "golem_0"}])
	gs.combat_state.current_cycle = _assigned_cycle(3)
	_resolver(content, StubRng.new()).resolve_enemy_turns(gs)
	assert_int(_enemy(gs, "golem_0").active_statuses.size()).is_equal(1)
	assert_int(gs.vessel_state.active_statuses.size()).is_equal(0)


# status_target "allies" applies to every living ally except the caster.
func test_status_apply_allies() -> void:
	var content := StubContent.new()
	var buff := _intent("rally")
	buff.status_apply = "emboldened:physical"
	buff.status_magnitude = 2
	buff.status_target = "allies"
	content.enemies["totem"] = _enemy_data("totem", [buff])
	content.enemies["grunt"] = _enemy_data("grunt", [_intent("idle")])
	var gs := _gs(content, [
		{"enemy_id": "totem", "instance_id": "totem_0"},
		{"enemy_id": "grunt", "instance_id": "grunt_0"},
		{"enemy_id": "grunt", "instance_id": "grunt_1"},
	])
	gs.combat_state.current_cycle = _assigned_cycle(2)
	# Only resolve the totem's turn by making the grunts already acted is hard;
	# instead assert the totem buffed both grunts (not itself).
	_resolver(content, StubRng.new()).resolve_enemy_turns(gs)
	assert_int(_enemy(gs, "totem_0").active_statuses.size()).is_equal(0)  # not self
	assert_bool(_has_status(_enemy(gs, "grunt_0"), "emboldened")).is_true()
	assert_bool(_has_status(_enemy(gs, "grunt_1"), "emboldened")).is_true()


# --- Intent handlers (step 7d) ----------------------------------------------

# An intent's handler chain runs after status_apply; the burden-tier Mending
# handler applies Mending to an ally (the boss) using item_burden_score.
func test_intent_handlers_apply_mending_to_ally() -> void:
	var content := StubContent.new()
	var testify := _intent("testify_mercy")
	testify.status_target = "allies"
	var hc := HandlerConfig.new()
	hc.handler_id = "apply_mending_by_burden_tier"
	hc.params = {"tiers": [{"max": 5, "magnitude": 2}, {"max": -1, "magnitude": 5}]}
	testify.handlers.assign([hc])
	content.enemies["witness"] = _enemy_data("witness", [testify])
	content.enemies["judge"] = _enemy_data("judge", [_intent("idle")])
	var gs := _gs(content, [
		{"enemy_id": "witness", "instance_id": "witness_0"},
		{"enemy_id": "judge", "instance_id": "judge_0", "hp": 40, "max_hp": 40},
	])
	gs.item_burden_score = 10  # > 5 → magnitude 5 tier
	gs.combat_state.current_cycle = _assigned_cycle(2)
	_resolver(content, StubRng.new()).resolve_enemy_turns(gs)
	var judge := _enemy(gs, "judge_0")
	assert_bool(_has_status(judge, "mending")).is_true()
	for s in judge.active_statuses:
		if s.status_id == "mending":
			assert_int(s.magnitude).is_equal(5)


# --- Summon -----------------------------------------------------------------

# resolve_enemy_summon adds a fresh enemy and injects its Tier-1 family card.
func test_resolve_enemy_summon_adds_enemy_and_card() -> void:
	var content := StubContent.new()
	var summoned := _enemy_data("wolf", [_intent("idle")], [], "physical", ["thick_hide", "exposed"])
	summoned.max_hp = 6
	content.enemies["wolf"] = summoned
	var gs := _gs(content, [{"enemy_id": "wolf", "instance_id": "wolf_0"}])
	_resolver(content, StubRng.new()).resolve_enemy_summon("wolf", gs)
	# A new wolf was added with a unique instance_id and full HP.
	assert_int(gs.combat_state.enemies.size()).is_equal(2)
	var new_wolf := _enemy(gs, "wolf_1")
	assert_object(new_wolf).is_not_null()
	assert_int(new_wolf.hp).is_equal(6)
	assert_int(new_wolf.turns_alive).is_equal(1)
	# One Tier-1 family card (omen_contributions[0]) injected; type card NOT re-added.
	var pile := gs.combat_state.omen_deck.draw_pile
	var thick := 0
	for entry in pile:
		if entry["card_id"] == "thick_hide":
			thick += 1
	assert_int(thick).is_equal(1)


# A summon intent triggers resolve_enemy_summon during the enemy's turn.
func test_summon_intent_spawns_during_turn() -> void:
	var content := StubContent.new()
	var howl := _intent("howl")
	howl.summon_enemy_id = "wolf"
	var wolf := _enemy_data("wolf", [howl], [], "physical", ["thick_hide"])
	wolf.max_hp = 6
	content.enemies["wolf"] = wolf
	var gs := _gs(content, [{"enemy_id": "wolf", "instance_id": "wolf_0"}])
	_resolver(content, StubRng.new()).resolve_enemy_turns(gs)
	assert_int(gs.combat_state.enemies.size()).is_equal(2)  # the summoned wolf


# --- turns_alive ------------------------------------------------------------

# turns_alive increments after the enemy acts; the summoned enemy does not act
# this pass (snapshot taken before summon).
func test_turns_alive_increments() -> void:
	var content := StubContent.new()
	content.enemies["goblin"] = _enemy_data("goblin", [_intent("idle")])
	var gs := _gs(content, [{"enemy_id": "goblin", "instance_id": "goblin_0"}])
	assert_int(_enemy(gs, "goblin_0").turns_alive).is_equal(1)
	var r := _resolver(content, StubRng.new())
	r.resolve_enemy_turns(gs)
	assert_int(_enemy(gs, "goblin_0").turns_alive).is_equal(2)
	r.resolve_enemy_turns(gs)
	assert_int(_enemy(gs, "goblin_0").turns_alive).is_equal(3)


# turn_number:N conditional reads turns_alive: on the first turn (turns_alive 1)
# the turn_number:1 conditional matches and forces its intent.
func test_turn_number_conditional_uses_turns_alive() -> void:
	var content := StubContent.new()
	var cond := _conditional("turn_number:1", "dormant")
	content.enemies["spark"] = _enemy_data("spark", [_intent("dormant"), _attack_intent("zap", 5, 5)], [cond])
	var gs := _gs(content, [{"enemy_id": "spark", "instance_id": "spark_0"}])
	# Simulate a spark that has already lived a turn: turn_number:1 should NOT match.
	var e := _enemy(gs, "spark_0")
	e.turns_alive = 2
	var rng := StubRng.new()
	rng.queue = [1]  # weighted roll → "zap"
	_resolver(content, rng).resolve_enemy_turns(gs)
	assert_str(e.current_intent).is_equal("zap")  # conditional skipped, rolled zap


# --- Helpers ----------------------------------------------------------------

func _has_status(unit, status_id: String) -> bool:
	for s in unit.active_statuses:
		if s.status_id == status_id:
			return true
	return false


# A resolved omen cycle whose timer (leftover) card has the given timer value.
func _assigned_cycle(timer_value: int) -> OmenCycleState:
	var cycle := OmenCycleState.new()
	cycle.drawn_cards.assign([
		{"card_id": "x", "timer_value": 1},
		{"card_id": "y", "timer_value": 1},
		{"card_id": "z", "timer_value": timer_value},
	])
	cycle.player_choice_index = 0
	cycle.random_assignment_index = 1
	cycle.timer_index = 2
	cycle.sides_assigned = true
	return cycle
