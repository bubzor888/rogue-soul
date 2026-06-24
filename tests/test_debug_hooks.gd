# T9.1 — headless debug hooks (LLD-ARCH-014). Each hook is gated on GameConfig.DEBUG:
# inert when false, active when true. Covers set-HP on any unit, keep-player-alive,
# force-enemy-intent, force-loot, and the RNG stream monitor / seed display.
# @Spec: LLD-ARCH-014, LLD-ARCH-008
extends GdUnitTestSuite


class StubContent:
	var enemies: Dictionary = {}
	func get_enemy(id: String): return enemies.get(id, null)


# Always restore the single debug flag so DEBUG state never leaks between tests.
func after_test() -> void:
	GameConfig.DEBUG = false


func _gs() -> GameState:
	var gs := GameState.new()
	gs.vessel_state = VesselState.new()
	gs.vessel_state.vessel_id = "pilgrim"
	gs.vessel_state.hp = 10
	gs.vessel_state.max_hp = 24
	gs.navigation_state = NavigationState.new()
	gs.combat_state = CombatState.new()
	var e := EnemyState.new()
	e.enemy_id = "skeleton"
	e.instance_id = "skeleton_0"
	e.hp = 5
	e.max_hp = 12
	gs.combat_state.enemies.assign([e])
	return gs


# --- Gating -----------------------------------------------------------------

func test_hooks_inert_when_debug_false() -> void:
	GameConfig.DEBUG = false
	var gs := _gs()
	DebugHooks.set_unit_hp(gs, "player", 24)
	DebugHooks.keep_player_alive(gs)
	DebugHooks.force_loot_offers(gs, ["staff"])
	assert_int(gs.vessel_state.hp).is_equal(10)                 # unchanged
	assert_int(gs.navigation_state.loot_offers.size()).is_equal(0)


# --- set-HP on any unit -----------------------------------------------------

func test_set_unit_hp_player_and_enemy() -> void:
	GameConfig.DEBUG = true
	var gs := _gs()
	DebugHooks.set_unit_hp(gs, "player", 20)
	DebugHooks.set_unit_hp(gs, "skeleton_0", 1)
	assert_int(gs.vessel_state.hp).is_equal(20)
	assert_int(gs.combat_state.enemies[0].hp).is_equal(1)


func test_set_unit_hp_clamps_to_max() -> void:
	GameConfig.DEBUG = true
	var gs := _gs()
	DebugHooks.set_unit_hp(gs, "player", 999)
	assert_int(gs.vessel_state.hp).is_equal(24)                 # clamped to max_hp


func test_keep_player_alive_restores_full() -> void:
	GameConfig.DEBUG = true
	var gs := _gs()
	gs.vessel_state.hp = 0
	DebugHooks.keep_player_alive(gs)
	assert_int(gs.vessel_state.hp).is_equal(24)


# --- force-loot -------------------------------------------------------------

func test_force_loot_offers() -> void:
	GameConfig.DEBUG = true
	var gs := _gs()
	DebugHooks.force_loot_offers(gs, ["iron_maul", "poultice"])
	assert_array(gs.navigation_state.loot_offers).is_equal(["iron_maul", "poultice"])


# --- force-enemy-intent -----------------------------------------------------

func test_force_enemy_intent_overrides_selection() -> void:
	GameConfig.DEBUG = true
	var content := StubContent.new()
	var ed := EnemyData.new()
	ed.enemy_id = "bear"
	ed.max_hp = 22
	var strike := IntentWeight.new()
	strike.intent_id = "strike"
	strike.weight = 100
	strike.damage_min = 4
	strike.damage_max = 6
	var frenzy := IntentWeight.new()
	frenzy.intent_id = "frenzy"
	frenzy.weight = 0  # never randomly picked
	frenzy.status_apply = "frenzied"
	frenzy.status_target = "self"
	ed.intent_weights.assign([strike, frenzy])
	content.enemies["bear"] = ed

	var gs := _gs()
	var bear := EnemyState.new()
	bear.enemy_id = "bear"
	bear.instance_id = "bear_0"
	bear.hp = 22
	bear.max_hp = 22
	bear.turns_alive = 1
	gs.combat_state.enemies.assign([bear])

	var resolver := CombatResolver.new(null, content, AbilityPipeline.with_default_handlers())
	DebugHooks.force_enemy_intent(resolver, "frenzy")
	resolver.resolve_enemy_turns(gs)
	# The (weight-0) frenzy was forced → Bear frenzied itself.
	var has_frenzied := false
	for s in gs.combat_state.enemies[0].active_statuses:
		if s.status_id == "frenzied":
			has_frenzied = true
	assert_bool(has_frenzied).is_true()
	assert_str(gs.combat_state.enemies[0].current_intent).is_equal("frenzy")


# --- RNG monitor / seed -----------------------------------------------------

func test_rng_stream_counts_and_seed() -> void:
	GameConfig.DEBUG = true
	var rng = RNGService
	rng.seed_run(77)
	rng.randi_range(1, 0, 10)   # one COMBAT roll
	rng.randi_range(1, 0, 10)   # another
	var counts := DebugHooks.rng_stream_counts(rng)
	assert_int(counts["combat"]).is_equal(2)
	assert_int(counts["navigation"]).is_equal(0)
	assert_int(DebugHooks.active_seed(rng)).is_equal(77)
