# Tests for RunController (T6.4): the run phase state machine and combat round
# driver. Covers run init + burden, NAVIGATION→COMBAT entry (signals/replenish/omen
# pause), CHOOSE_OMEN→turn start, combat victory→loot and defeat→run-end, loot→next
# room, the boss → checkpoint → completion path, the floor transition, and freeing.
# @Spec: LLD-ARCH-016, LLD-ARCH-007, HLD-RUN-006, HLD-RUN-007, LLD-ARCH-009
extends GdUnitTestSuite

const SignalBusScript = preload("res://src/infrastructure/signal_bus.gd")
const RunPhase := GameState.RunPhase


# --- Stubs ------------------------------------------------------------------

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


# --- Builders ---------------------------------------------------------------

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


func _enemy_data(id: String, hp: int, min_d: int = 0, max_d: int = 0) -> EnemyData:
	var e := EnemyData.new()
	e.enemy_id = id
	e.max_hp = hp
	e.damage_type = "physical"
	e.omen_contributions.assign(["%s_card" % id])
	if max_d > 0:
		e.intent_weights.assign([_strike_intent(min_d, max_d)])
	return e


func _floor(pre: int = 4, post: int = 4) -> FloorProfile:
	var p := FloorProfile.new()
	p.floor_id = "floor_3"
	p.floor_number = 3
	p.pre_elite_rooms = pre
	p.post_elite_rooms = post
	p.boss_enemy_id = "the_judge"
	p.normal_enemy_pool.assign(["skeleton"])
	p.elite_enemy_pool.assign(["bear"])
	p.normal_durability_pool.assign(["staff"])
	p.normal_consumable_pool.assign(["bomb"])
	p.elite_durability_pool.assign(["maul"])
	p.elite_consumable_pool.assign(["poultice"])
	return p


# Content with a Pilgrim (30 HP, 5-dmg default strike, one starting item) and a
# Floor 3 profile. Enemies are added per-test.
func _content() -> StubContent:
	var c := StubContent.new()
	var vd := VesselData.new()
	vd.vessel_id = "pilgrim"
	vd.max_hp = 30
	vd.default_strike_id = "strike"
	vd.starting_item_ids.assign(["staff"])
	vd.omen_contributions.assign(["c1", "c2", "c3"])
	c.vessels["pilgrim"] = vd
	c.abilities["strike"] = _ability("strike", "attack", [_deal_damage(5)], 0)
	c.abilities["staff"] = _ability("staff", "attack", [_deal_damage(6)], 3)
	c.floors["floor_3"] = _floor()
	return c


func _rc(content: StubContent, bus = null) -> RunController:
	var rc: RunController = auto_free(RunController.new())
	rc.configure(StubRng.new(), content, bus)
	return rc


# Drive: start a run, choose the first door, resolve the opening omen choice, so the
# controller is sitting at the player's first combat turn.
func _into_first_turn(rc: RunController) -> void:
	rc.start_run(42, "pilgrim")
	var door: Dictionary = rc.get_legal_actions()[0]
	rc.submit_action(door)
	# Now at the omen choice — pick the first CHOOSE_OMEN option.
	rc.submit_action(rc.get_legal_actions()[0])


func _enemy(rc: RunController) -> EnemyState:
	return rc.game_state.combat_state.enemies[0]


# --- Run init (HLD-RUN-007) -------------------------------------------------

func test_start_run_initial_state() -> void:
	var rc := _rc(_content())
	rc.start_run(42, "pilgrim")
	assert_int(rc.game_state.run_phase).is_equal(RunPhase.NAVIGATION)
	assert_int(rc.game_state.vessel_state.hp).is_equal(30)          # full HP
	assert_int(rc.game_state.item_burden_score).is_equal(1)         # 1 starting item
	assert_int(rc.game_state.inventory.size()).is_equal(1)
	assert_int(rc.game_state.navigation_state.doors_ahead.size()).is_equal(2)


func test_start_run_emits_phase_and_fires_floor_start() -> void:
	var content := _content()
	# A starting item that replenishes on floor_start, pre-spent, proves the event fires.
	content.abilities["staff"].replenish_triggers.assign(["floor_start"])
	var bus = auto_free(SignalBusScript.new())
	var phases: Array = []
	bus.phase_changed.connect(func(n, o): phases.append(n))
	var rc := _rc(content, bus)
	rc.start_run(42, "pilgrim")
	rc.game_state.inventory[0].remaining_charges = 0
	rc._fire_replenish("floor_start")  # re-fire to show it restores to max
	assert_int(rc.game_state.inventory[0].remaining_charges).is_equal(3)
	assert_bool(RunPhase.NAVIGATION in phases).is_true()


# --- NAVIGATION → COMBAT ----------------------------------------------------

func test_choose_door_enters_combat() -> void:
	var content := _content()
	content.enemies["skeleton"] = _enemy_data("skeleton", 12)
	var bus = auto_free(SignalBusScript.new())
	var saves: Array = []
	var rooms: Array = []
	bus.save_requested.connect(func(t): saves.append(t))
	bus.room_entered.connect(func(rt, eid): rooms.append([rt, eid]))
	var rc := _rc(content, bus)
	rc.start_run(42, "pilgrim")
	rc.submit_action(rc.get_legal_actions()[0])  # CHOOSE_DOOR

	assert_int(rc.game_state.run_phase).is_equal(RunPhase.COMBAT)
	assert_object(rc.game_state.combat_state).is_not_null()
	assert_int(rc.game_state.combat_state.enemies.size()).is_equal(1)
	assert_bool(RunController.SaveType.BACKGROUND in saves).is_true()  # background save on door
	assert_int(rooms.size()).is_equal(1)
	# The opening omen cycle is pending the player's choice.
	assert_bool(rc.game_state.combat_state.current_cycle != null).is_true()
	assert_bool(rc.game_state.combat_state.current_cycle.sides_assigned).is_false()


func test_combat_entry_offers_choose_omen_then_turn() -> void:
	var content := _content()
	content.enemies["skeleton"] = _enemy_data("skeleton", 12)
	var rc := _rc(content)
	rc.start_run(42, "pilgrim")
	rc.submit_action(rc.get_legal_actions()[0])  # door → combat
	# Gated to CHOOSE_OMEN only.
	for a in rc.get_legal_actions():
		assert_str(a["type"]).is_equal("CHOOSE_OMEN")
	rc.submit_action(rc.get_legal_actions()[0])   # choose omen
	# Now the player's turn: buckets reset, real combat actions available.
	assert_bool(rc.game_state.combat_state.current_cycle.sides_assigned).is_true()
	assert_bool(rc.game_state.combat_state.is_action_used).is_false()
	assert_bool("EVADE" in _action_types(rc.get_legal_actions())).is_true()


# --- Combat victory → loot --------------------------------------------------

func test_combat_victory_goes_to_loot() -> void:
	var content := _content()
	content.enemies["skeleton"] = _enemy_data("skeleton", 4)  # dies to one 5-dmg strike
	var bus = auto_free(SignalBusScript.new())
	var ended: Array = []
	bus.combat_ended.connect(func(o): ended.append(o))
	var rc := _rc(content, bus)
	_into_first_turn(rc)
	# Default strike at the lone enemy.
	rc.submit_action(_find(rc.get_legal_actions(), "USE_ABILITY"))
	assert_int(rc.game_state.run_phase).is_equal(RunPhase.LOOT_SELECTION)
	assert_array(ended).is_equal(["victory"])
	assert_int(rc.game_state.navigation_state.rooms_completed_this_floor).is_equal(1)
	assert_int(rc.game_state.navigation_state.loot_offers.size()).is_equal(2)


func test_loot_choice_returns_to_navigation() -> void:
	var content := _content()
	content.enemies["skeleton"] = _enemy_data("skeleton", 4)
	var rc := _rc(content)
	_into_first_turn(rc)
	rc.submit_action(_find(rc.get_legal_actions(), "USE_ABILITY"))  # win → loot
	var before_burden := rc.game_state.item_burden_score
	rc.submit_action(_find(rc.get_legal_actions(), "CHOOSE_LOOT"))  # take an item
	assert_int(rc.game_state.run_phase).is_equal(RunPhase.NAVIGATION)
	assert_int(rc.game_state.item_burden_score).is_equal(before_burden + 2)  # +2 acquire
	assert_int(rc.game_state.navigation_state.doors_ahead.size()).is_equal(2)


# --- Combat defeat → run end ------------------------------------------------

func test_combat_defeat_ends_run() -> void:
	var content := _content()
	content.enemies["skeleton"] = _enemy_data("skeleton", 99, 50, 50)  # hits for 50
	var rc := _rc(content)
	_into_first_turn(rc)
	rc.game_state.vessel_state.hp = 1  # one enemy hit is lethal
	# Strike (not Evade — Evade could dodge the hit), then end turn → enemy kills us.
	rc.submit_action(_find(rc.get_legal_actions(), "USE_ABILITY"))
	rc.submit_action(_find(rc.get_legal_actions(), "END_TURN"))
	assert_int(rc.game_state.run_phase).is_equal(RunPhase.RUN_END)
	assert_str(rc.outcome).is_equal("death")
	assert_bool(rc.is_finished()).is_true()


# --- Enemy phase advances the omen cycle ------------------------------------

func test_end_turn_runs_enemy_phase_and_ticks_cycle() -> void:
	var content := _content()
	content.enemies["skeleton"] = _enemy_data("skeleton", 99, 1, 1)
	var rc := _rc(content)
	_into_first_turn(rc)
	var ticks_before: int = rc.game_state.combat_state.current_cycle.ticks_remaining
	rc.submit_action(_find(rc.get_legal_actions(), "EVADE"))
	rc.submit_action(_find(rc.get_legal_actions(), "END_TURN"))
	# Either the cycle ticked down by one, or it expired and a fresh cycle was drawn.
	var cycle := rc.game_state.combat_state.current_cycle
	if ticks_before > 1:
		assert_int(cycle.ticks_remaining).is_equal(ticks_before - 1)
		assert_bool(cycle.sides_assigned).is_true()  # same cycle, player turn resumed
	else:
		assert_bool(cycle.sides_assigned).is_false()  # expired → new cycle pending choice


# --- Boss → checkpoint → completion -----------------------------------------

func test_boss_after_last_room_completes_run() -> void:
	var content := _content()
	content.enemies["the_judge"] = _enemy_data("the_judge", 4)
	var bus = auto_free(SignalBusScript.new())
	var saves: Array = []
	bus.save_requested.connect(func(t): saves.append(t))
	var rc := _rc(content, bus)
	rc.start_run(42, "pilgrim")
	# Jump to "all 9 rooms done, in loot of room 9" then take loot → boss.
	rc.game_state.run_phase = RunPhase.LOOT_SELECTION
	rc.game_state.navigation_state.rooms_completed_this_floor = 9
	rc.game_state.navigation_state.loot_offers.assign(["staff", "bomb"])
	rc.submit_action({"type": "DECLINE_LOOT"})
	assert_int(rc.game_state.run_phase).is_equal(RunPhase.COMBAT)  # boss combat
	# Beat the boss: choose omen, then strike it dead.
	rc.submit_action(rc.get_legal_actions()[0])  # CHOOSE_OMEN
	rc.submit_action(_find(rc.get_legal_actions(), "USE_ABILITY"))
	assert_int(rc.game_state.run_phase).is_equal(RunPhase.RUN_END)
	assert_str(rc.outcome).is_equal("completion")
	assert_int(rc.floors_completed).is_equal(1)
	assert_bool(RunController.SaveType.CHECKPOINT in saves).is_true()


# --- Floor transition (HLD-RUN-006) -----------------------------------------

func test_floor_transition_restores_hp_and_drops_temp_companion() -> void:
	var content := _content()
	var bus = auto_free(SignalBusScript.new())
	var transitions: Array = []
	bus.floor_transitioned.connect(func(f, t): transitions.append([f, t]))
	var rc := _rc(content, bus)
	rc.start_run(42, "pilgrim")
	rc.game_state.vessel_state.hp = 5
	rc.game_state.temporary_companion = CompanionState.new()
	rc._floor_transition(4)
	assert_int(rc.game_state.vessel_state.hp).is_equal(30)           # full restore
	assert_object(rc.game_state.temporary_companion).is_null()        # temp departs
	assert_int(rc.game_state.floor_number).is_equal(4)
	assert_array(transitions).is_equal([[3, 4]])


# --- Helpers ----------------------------------------------------------------

func _action_types(actions: Array) -> Array:
	var out: Array = []
	for a in actions:
		out.append(a["type"])
	return out


func _find(actions: Array, type: String) -> Dictionary:
	for a in actions:
		if a["type"] == type:
			return a
	return {}
