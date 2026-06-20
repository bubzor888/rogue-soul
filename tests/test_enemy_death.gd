# Tests for CombatResolver death & companion handling (T5.7): resolve_enemy_death
# (omen card removal + on_death status + on_death summons), resolve_companion_trigger
# (matching fire / timer decrement / departure), check_vessel_death_intercept
# (HP restore + depart, no unit_died), and companion departure on ability_used.
# @Spec: LLD-ARCH-019, HLD-OMEN-006, HLD-COMPANION-003, LLD-ARCH-018
extends GdUnitTestSuite


# --- A test handler whose id is fixed (test inner class has no global name) ---

class TestHealHandler:
	extends AbilityHandler
	func get_handler_id() -> String:
		return "test_heal"
	func apply(ctx: AbilityContext) -> void:
		ctx.game_state.vessel_state.hp = int(ctx.params.get("amount", 5))


# --- Stubs ------------------------------------------------------------------

class StubContent:
	var abilities: Dictionary = {}
	var enemies: Dictionary = {}
	var companions: Dictionary = {}
	func get_ability(id: String):
		return abilities.get(id, null)
	func get_enemy(id: String):
		return enemies.get(id, null)
	func get_companion(id: String):
		return companions.get(id, null)


class StubRng:
	var default: int = 0
	func randi_range(_stream: int, a: int, b: int) -> int:
		return clampi(default, a, b)


# --- Builders ---------------------------------------------------------------

func _enemy_data(id: String, contributions: Array = [], on_death: String = "", on_death_mag: int = 0, summons: Array = []) -> EnemyData:
	var e := EnemyData.new()
	e.enemy_id = id
	e.max_hp = 6
	e.omen_contributions.assign(contributions)
	e.on_death_apply_to_player = on_death
	e.on_death_apply_magnitude = on_death_mag
	e.on_death_summons.assign(summons)
	return e


func _companion_data(id: String, trigger: String, handlers: Array = [], departure: String = "", granted: String = "", initial_timer: int = 0) -> CompanionData:
	var c := CompanionData.new()
	c.companion_id = id
	c.trigger = trigger
	c.handlers.assign(handlers)
	c.departure_trigger = departure
	c.granted_ability_id = granted
	c.initial_timer = initial_timer
	return c


func _heal_config(amount: int) -> HandlerConfig:
	var hc := HandlerConfig.new()
	hc.handler_id = "test_heal"
	hc.params = {"amount": amount}
	return hc


func _gs(content: StubContent, enemy_specs: Array, cycle_timer: int = 2) -> GameState:
	var gs := GameState.new()
	gs.vessel_state = VesselState.new()
	gs.vessel_state.vessel_id = "pilgrim"
	gs.vessel_state.hp = 20
	gs.vessel_state.max_hp = 30
	gs.combat_state = CombatState.new()
	gs.combat_state.omen_deck = OmenDeckState.new()
	var enemies: Array[EnemyState] = []
	for spec in enemy_specs:
		var e := EnemyState.new()
		e.enemy_id = spec["enemy_id"]
		e.instance_id = spec["instance_id"]
		e.hp = spec.get("hp", 6)
		e.max_hp = 6
		enemies.append(e)
	gs.combat_state.enemies.assign(enemies)
	# A resolved cycle so on_death/individual statuses get remaining_ticks.
	var cycle := OmenCycleState.new()
	cycle.drawn_cards.assign([
		{"card_id": "a", "timer_value": 1}, {"card_id": "b", "timer_value": 1},
		{"card_id": "c", "timer_value": cycle_timer},
	])
	cycle.timer_index = 2
	cycle.sides_assigned = true
	gs.combat_state.current_cycle = cycle
	return gs


func _pipeline() -> AbilityPipeline:
	var p := AbilityPipeline.with_default_handlers()
	p.register(TestHealHandler.new())
	return p


func _resolver(content: StubContent, rng = null) -> CombatResolver:
	return CombatResolver.new(rng, content, _pipeline())


func _player_status(gs: GameState, status_id: String) -> StatusInstance:
	for s in gs.vessel_state.active_statuses:
		if s.status_id == status_id:
			return s
	return null


# --- resolve_enemy_death: omen card removal ---------------------------------

# The last enemy of a type dies → both its family card and the type card are removed.
func test_enemy_death_removes_family_and_type_cards() -> void:
	var content := StubContent.new()
	content.enemies["rat"] = _enemy_data("rat", ["thick_hide", "exposed"])
	var gs := _gs(content, [{"enemy_id": "rat", "instance_id": "rat_0", "hp": 0}])
	gs.combat_state.omen_deck.draw_pile.assign([
		{"card_id": "thick_hide", "timer_value": 1},
		{"card_id": "exposed", "timer_value": 1},
	])
	_resolver(content).resolve_enemy_death("rat_0", gs)
	var pile := gs.combat_state.omen_deck.draw_pile
	assert_int(_count(pile, "thick_hide")).is_equal(0)
	assert_int(_count(pile, "exposed")).is_equal(0)


# --- resolve_enemy_death: on_death status -----------------------------------

# Witness: on death applies Vulnerable (Physical) to the player with the cycle timer.
func test_enemy_death_applies_vulnerable_to_player() -> void:
	var content := StubContent.new()
	content.enemies["witness"] = _enemy_data("witness", [], "vulnerable:physical", 0)
	var gs := _gs(content, [{"enemy_id": "witness", "instance_id": "witness_0", "hp": 0}], 2)
	_resolver(content).resolve_enemy_death("witness_0", gs)
	var vuln := _player_status(gs, "vulnerable")
	assert_object(vuln).is_not_null()
	assert_str(vuln.string_param).is_equal("physical")
	assert_int(vuln.remaining_ticks).is_equal(2)  # current cycle timer


# Plague Rat: on death applies Poisoned magnitude 2 (additive onto existing).
func test_enemy_death_poison_stacks_additively() -> void:
	var content := StubContent.new()
	content.enemies["plague_rat"] = _enemy_data("plague_rat", [], "poisoned", 2)
	var gs := _gs(content, [{"enemy_id": "plague_rat", "instance_id": "plague_rat_0", "hp": 0}])
	var existing := StatusInstance.new()
	existing.status_id = "poisoned"
	existing.magnitude = 3
	existing.remaining_ticks = 2
	existing.trigger = "tick"
	gs.vessel_state.active_statuses.assign([existing])
	_resolver(content).resolve_enemy_death("plague_rat_0", gs)
	assert_int(_player_status(gs, "poisoned").magnitude).is_equal(5)  # 3 + 2


# Max-wins: a lower-magnitude on-death Mending does not downgrade an active higher one.
func test_enemy_death_max_wins_does_not_downgrade() -> void:
	var content := StubContent.new()
	content.enemies["x"] = _enemy_data("x", [], "mending", 2)
	var gs := _gs(content, [{"enemy_id": "x", "instance_id": "x_0", "hp": 0}])
	var existing := StatusInstance.new()
	existing.status_id = "mending"
	existing.magnitude = 5
	existing.remaining_ticks = 2
	existing.trigger = "tick"
	gs.vessel_state.active_statuses.assign([existing])
	_resolver(content).resolve_enemy_death("x_0", gs)
	assert_int(_player_status(gs, "mending").magnitude).is_equal(5)  # unchanged


# --- resolve_enemy_death: on_death summons ----------------------------------

# Lightning Elemental: on death summons two Sparks.
func test_enemy_death_summons_two() -> void:
	var content := StubContent.new()
	content.enemies["lightning_spark"] = _enemy_data("lightning_spark")
	content.enemies["lightning_elem"] = _enemy_data("lightning_elem", [], "", 0, ["lightning_spark", "lightning_spark"])
	var gs := _gs(content, [{"enemy_id": "lightning_elem", "instance_id": "lightning_elem_0", "hp": 0}])
	_resolver(content).resolve_enemy_death("lightning_elem_0", gs)
	var sparks := 0
	for e in gs.combat_state.enemies:
		if e.enemy_id == "lightning_spark":
			sparks += 1
	assert_int(sparks).is_equal(2)


# --- resolve_companion_trigger ----------------------------------------------

# A matching trigger fires the companion's handler chain.
func test_companion_trigger_fires_matching() -> void:
	var content := StubContent.new()
	content.companions["ferret"] = _companion_data("ferret", "turn_end", [_heal_config(7)])
	var gs := _gs(content, [])
	gs.vessel_state.hp = 10
	var cs := CompanionState.new()
	cs.companion_id = "ferret"
	gs.bound_companion = cs
	_resolver(content).resolve_companion_trigger("turn_end", gs)
	assert_int(gs.vessel_state.hp).is_equal(7)  # handler ran


# A non-matching trigger does not fire the companion.
func test_companion_trigger_skips_non_matching() -> void:
	var content := StubContent.new()
	content.companions["shade"] = _companion_data("shade", "vessel_death_intercept", [_heal_config(7)])
	var gs := _gs(content, [])
	gs.vessel_state.hp = 10
	var cs := CompanionState.new()
	cs.companion_id = "shade"
	gs.temporary_companion = cs
	_resolver(content).resolve_companion_trigger("turn_end", gs)
	assert_int(gs.vessel_state.hp).is_equal(10)  # unchanged


# A timer-exhausted companion decrements its timer each trigger and departs at 0.
func test_companion_trigger_timer_departs_at_zero() -> void:
	var content := StubContent.new()
	content.companions["echo"] = _companion_data("echo", "turn_end", [], "timer_exhausted", "", 1)
	var gs := _gs(content, [])
	var cs := CompanionState.new()
	cs.companion_id = "echo"
	cs.companion_timer = 1
	gs.temporary_companion = cs
	_resolver(content).resolve_companion_trigger("turn_end", gs)
	assert_object(gs.temporary_companion).is_null()  # departed


# --- check_vessel_death_intercept -------------------------------------------

# An intercept companion restores HP and departs; the vessel survives.
func test_intercept_restores_hp_and_departs() -> void:
	var content := StubContent.new()
	content.companions["guardian"] = _companion_data("guardian", "vessel_death_intercept", [_heal_config(5)], "intercept_triggered")
	var gs := _gs(content, [])
	gs.vessel_state.hp = 0
	var cs := CompanionState.new()
	cs.companion_id = "guardian"
	gs.bound_companion = cs
	_resolver(content).check_vessel_death_intercept(gs)
	assert_int(gs.vessel_state.hp).is_equal(5)
	assert_object(gs.bound_companion).is_null()  # departed


# With no intercept companion, the vessel stays at 0 (caller will emit unit_died).
func test_no_intercept_leaves_hp_zero() -> void:
	var content := StubContent.new()
	content.companions["ferret"] = _companion_data("ferret", "turn_end", [_heal_config(5)])
	var gs := _gs(content, [])
	gs.vessel_state.hp = 0
	var cs := CompanionState.new()
	cs.companion_id = "ferret"
	gs.bound_companion = cs
	_resolver(content).check_vessel_death_intercept(gs)
	assert_int(gs.vessel_state.hp).is_equal(0)
	assert_object(gs.bound_companion).is_not_null()  # not departed


# --- Companion departs on ability_used (resolve_player_action wiring) --------

func test_companion_departs_on_ability_used() -> void:
	var content := StubContent.new()
	var grant := AbilityData.new()
	grant.ability_id = "ferret_dash"
	grant.action_bucket = "attack"
	content.abilities["ferret_dash"] = grant
	content.companions["ferret"] = _companion_data("ferret", "turn_end", [], "ability_used", "ferret_dash")
	var gs := _gs(content, [{"enemy_id": "rat", "instance_id": "rat_0"}])
	content.enemies["rat"] = _enemy_data("rat")
	var cs := CompanionState.new()
	cs.companion_id = "ferret"
	gs.temporary_companion = cs
	_resolver(content).resolve_player_action(
		{"type": "USE_ABILITY", "ability_id": "ferret_dash", "target_id": "rat_0"}, gs)
	assert_object(gs.temporary_companion).is_null()  # departed on use


# --- Helpers ----------------------------------------------------------------

func _count(pile: Array, card_id: String) -> int:
	var n := 0
	for entry in pile:
		if entry["card_id"] == card_id:
			n += 1
	return n
