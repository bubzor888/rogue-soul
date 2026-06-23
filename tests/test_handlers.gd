# Tests for the T4.2 self-contained handlers (apply_status, cleanse_status,
# peek_omen_deck, apply_mending_by_burden_tier) and the shared StatusRules.
# @Spec: HLD-COMBAT-006, -010, -015, -018, -019, HLD-RUN-007, LLD-ARCH-018
extends GdUnitTestSuite


func _gs_with_vessel() -> GameState:
	var gs := GameState.new()
	gs.vessel_state = VesselState.new()
	gs.vessel_state.vessel_id = "pilgrim"
	return gs


func _ctx(gs: GameState, target_id: String, params: Dictionary) -> AbilityContext:
	var ctx := AbilityContext.new(gs, "src", target_id)
	ctx.params = params
	return ctx


func _vessel_statuses(gs: GameState) -> Array:
	return gs.vessel_state.active_statuses


# --- apply_status -----------------------------------------------------------

# An offensive consumable (e.g. Fire Bomb) is a non-targeted action — the handler
# auto-targets the first living enemy when target is "target" with no target_id.
# @Spec: LLD-ITEMS-007, HLD-COMBAT-006
func test_apply_status_auto_targets_first_living_enemy() -> void:
	var gs := GameState.new()
	gs.vessel_state = VesselState.new()
	gs.combat_state = CombatState.new()
	var dead := EnemyState.new()
	dead.instance_id = "skeleton_0"
	dead.hp = 0
	var alive := EnemyState.new()
	alive.instance_id = "skeleton_1"
	alive.hp = 10
	gs.combat_state.enemies.assign([dead, alive])
	# "player" source, no target_id given.
	var ctx := AbilityContext.new(gs, "player", "")
	ctx.params = {"status_id": "burning", "magnitude": 5, "remaining_ticks": 2}
	ApplyStatusHandler.new().apply(ctx)
	assert_int(alive.active_statuses.size()).is_equal(1)        # first LIVING enemy
	assert_int(dead.active_statuses.size()).is_equal(0)


func test_apply_status_colon_split() -> void:
	var gs := _gs_with_vessel()
	ApplyStatusHandler.new().apply(_ctx(gs, "player", {"status_id": "vulnerable:fire", "remaining_ticks": 2}))
	var s: StatusInstance = _vessel_statuses(gs)[0]
	assert_str(s.status_id).is_equal("vulnerable")
	assert_str(s.string_param).is_equal("fire")


func test_apply_status_additive_stacks() -> void:
	var gs := _gs_with_vessel()
	var h := ApplyStatusHandler.new()
	h.apply(_ctx(gs, "player", {"status_id": "burning", "magnitude": 2, "remaining_ticks": 3}))
	h.apply(_ctx(gs, "player", {"status_id": "burning", "magnitude": 2, "remaining_ticks": 3}))
	assert_int(_vessel_statuses(gs).size()).is_equal(1)
	assert_int(_vessel_statuses(gs)[0].magnitude).is_equal(4)


func test_apply_status_max_wins() -> void:
	var gs := _gs_with_vessel()
	var h := ApplyStatusHandler.new()
	h.apply(_ctx(gs, "player", {"status_id": "mending", "magnitude": 5, "remaining_ticks": 3}))
	h.apply(_ctx(gs, "player", {"status_id": "mending", "magnitude": 3, "remaining_ticks": 3}))
	assert_int(_vessel_statuses(gs)[0].magnitude).is_equal(5)  # higher wins, no downgrade


func test_apply_status_chilled_idempotent() -> void:
	var gs := _gs_with_vessel()
	var h := ApplyStatusHandler.new()
	h.apply(_ctx(gs, "player", {"status_id": "chilled", "magnitude": 1, "remaining_ticks": 3}))
	h.apply(_ctx(gs, "player", {"status_id": "chilled", "magnitude": 9, "remaining_ticks": 3}))
	assert_int(_vessel_statuses(gs).size()).is_equal(1)
	assert_int(_vessel_statuses(gs)[0].magnitude).is_equal(1)  # idempotent — unchanged


func test_apply_status_type_convert_replaces() -> void:
	var gs := _gs_with_vessel()
	var h := ApplyStatusHandler.new()
	h.apply(_ctx(gs, "player", {"status_id": "type_convert:fire", "remaining_ticks": 3}))
	h.apply(_ctx(gs, "player", {"status_id": "type_convert:ice", "remaining_ticks": 3}))
	assert_int(_vessel_statuses(gs).size()).is_equal(1)  # only one type_convert
	assert_str(_vessel_statuses(gs)[0].string_param).is_equal("ice")


func test_apply_status_shift_trigger_default() -> void:
	var gs := _gs_with_vessel()
	ApplyStatusHandler.new().apply(_ctx(gs, "player", {"status_id": "shocked", "remaining_ticks": 2}))
	assert_str(_vessel_statuses(gs)[0].trigger).is_equal("shift")


# --- cleanse_status (category-scoped, never universal) ----------------------

func test_cleanse_removes_only_listed() -> void:
	var gs := _gs_with_vessel()
	var h := ApplyStatusHandler.new()
	h.apply(_ctx(gs, "player", {"status_id": "shocked", "remaining_ticks": 2}))
	h.apply(_ctx(gs, "player", {"status_id": "chilled", "magnitude": 1, "remaining_ticks": 2}))
	h.apply(_ctx(gs, "player", {"status_id": "burning", "magnitude": 5, "remaining_ticks": 2}))

	# Amethyst-style cleanse: Shocked + Chilled (not Burning).
	CleanseStatusHandler.new().apply(_ctx(gs, "player", {
		"target": "target",
		"clears": [{"status_id": "shocked"}, {"status_id": "chilled"}],
	}))
	var remaining := _vessel_statuses(gs)
	assert_int(remaining.size()).is_equal(1)
	assert_str(remaining[0].status_id).is_equal("burning")


func test_cleanse_respects_string_param() -> void:
	var gs := _gs_with_vessel()
	var h := ApplyStatusHandler.new()
	h.apply(_ctx(gs, "player", {"status_id": "vulnerable:physical", "remaining_ticks": 2}))
	h.apply(_ctx(gs, "player", {"status_id": "vulnerable:fire", "remaining_ticks": 2}))

	CleanseStatusHandler.new().apply(_ctx(gs, "player", {
		"target": "target",
		"clears": [{"status_id": "vulnerable", "string_param": "physical"}],
	}))
	var remaining := _vessel_statuses(gs)
	assert_int(remaining.size()).is_equal(1)
	assert_str(remaining[0].string_param).is_equal("fire")  # physical cleared, fire kept


# --- peek_omen_deck ---------------------------------------------------------

func test_peek_sets_read_the_road_active() -> void:
	var gs := _gs_with_vessel()
	gs.combat_state = CombatState.new()
	PeekOmenDeckHandler.new().apply(_ctx(gs, "", {}))
	assert_bool(gs.combat_state.read_the_road_active).is_true()


# --- apply_mending_by_burden_tier -------------------------------------------

func _judge_gs(burden: int) -> GameState:
	var gs := GameState.new()
	gs.item_burden_score = burden
	gs.combat_state = CombatState.new()
	var judge := EnemyState.new()
	judge.enemy_id = "the_judge"
	judge.instance_id = "judge_0"
	gs.combat_state.enemies.assign([judge])
	return gs


const _TIERS := [{"max": 7, "magnitude": 1}, {"max": 13, "magnitude": 3}, {"max": -1, "magnitude": 5}]


func test_mending_low_tier() -> void:
	var gs := _judge_gs(5)
	ApplyMendingByBurdenTierHandler.new().apply(_ctx(gs, "judge_0", {"tiers": _TIERS, "remaining_ticks": 2}))
	assert_int(gs.combat_state.enemies[0].active_statuses[0].magnitude).is_equal(1)


func test_mending_medium_tier() -> void:
	var gs := _judge_gs(10)
	ApplyMendingByBurdenTierHandler.new().apply(_ctx(gs, "judge_0", {"tiers": _TIERS, "remaining_ticks": 2}))
	assert_int(gs.combat_state.enemies[0].active_statuses[0].magnitude).is_equal(3)


func test_mending_high_tier() -> void:
	var gs := _judge_gs(20)
	ApplyMendingByBurdenTierHandler.new().apply(_ctx(gs, "judge_0", {"tiers": _TIERS, "remaining_ticks": 2}))
	assert_int(gs.combat_state.enemies[0].active_statuses[0].magnitude).is_equal(5)


# Dropping a tier mid-fight cannot downgrade an active higher Mending (max-wins).
func test_mending_no_downgrade_mid_cycle() -> void:
	var gs := _judge_gs(20)
	var h := ApplyMendingByBurdenTierHandler.new()
	h.apply(_ctx(gs, "judge_0", {"tiers": _TIERS, "remaining_ticks": 2}))  # High -> 5
	gs.item_burden_score = 10  # drops to Medium
	h.apply(_ctx(gs, "judge_0", {"tiers": _TIERS, "remaining_ticks": 2}))  # Medium -> 3, loses
	assert_int(gs.combat_state.enemies[0].active_statuses[0].magnitude).is_equal(5)


# With a status_id param the handler applies that (colon-encoded) status by tier —
# the Witness of Vengeance's tier-based Emboldened (Physical). @Spec: LLD-ENEMIES-022
func test_burden_tier_applies_configured_status() -> void:
	var tiers := [{"max": 7, "magnitude": 1}, {"max": 13, "magnitude": 2}, {"max": -1, "magnitude": 3}]
	var gs := _judge_gs(20)  # High tier
	ApplyMendingByBurdenTierHandler.new().apply(
		_ctx(gs, "judge_0", {"status_id": "emboldened:physical", "tiers": tiers, "remaining_ticks": 2}))
	var s: StatusInstance = gs.combat_state.enemies[0].active_statuses[0]
	assert_str(s.status_id).is_equal("emboldened")
	assert_str(s.string_param).is_equal("physical")
	assert_int(s.magnitude).is_equal(3)


# --- registration -----------------------------------------------------------

func test_handlers_registered_with_derived_ids() -> void:
	var p := AbilityPipeline.with_default_handlers()
	for id in ["apply_status", "cleanse_status", "peek_omen_deck", "apply_mending_by_burden_tier"]:
		assert_bool(p.has_handler(id)).override_failure_message("missing %s" % id).is_true()
