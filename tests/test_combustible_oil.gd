# Tests for the combustible_oil handler (LLD-ITEMS-007): branching consumable —
# applies Vulnerable (Fire) to the target enemy, OR if the enemy is already Burning
# deals a 6 flat fire-damage burst instead (no extra Vulnerable). Non-targeted
# action → auto-targets the first living enemy.
# @Spec: LLD-ITEMS-007, HLD-COMBAT-007
extends GdUnitTestSuite


class StubContent:
	var enemies: Dictionary = {}
	func get_enemy(id: String): return enemies.get(id, null)
	func get_ability(_id: String): return null


func _gs(enemy_hp: int) -> GameState:
	var gs := GameState.new()
	gs.vessel_state = VesselState.new()
	gs.combat_state = CombatState.new()
	var e := EnemyState.new()
	e.enemy_id = "skeleton"
	e.instance_id = "skeleton_0"
	e.hp = enemy_hp
	e.max_hp = enemy_hp
	gs.combat_state.enemies.assign([e])
	return gs


func _ctx(gs: GameState) -> AbilityContext:
	var ctx := AbilityContext.new(gs, "player", "")  # non-targeted (auto-targets enemy)
	var content := StubContent.new()
	content.enemies["skeleton"] = EnemyData.new()
	ctx.content = content
	ctx.params = {"remaining_ticks": 2, "burst_damage": 6}
	return ctx


func _enemy(gs: GameState) -> EnemyState:
	return gs.combat_state.enemies[0]


# Non-Burning target → gains Vulnerable (Fire), no damage.
func test_non_burning_applies_vulnerable_fire() -> void:
	var gs := _gs(20)
	CombustibleOilHandler.new().apply(_ctx(gs))
	var statuses := _enemy(gs).active_statuses
	assert_int(statuses.size()).is_equal(1)
	assert_str(statuses[0].status_id).is_equal("vulnerable")
	assert_str(statuses[0].string_param).is_equal("fire")
	assert_int(_enemy(gs).hp).is_equal(20)  # no damage


# Already-Burning target → 6 flat fire burst, no new Vulnerable.
func test_burning_target_takes_burst() -> void:
	var gs := _gs(20)
	var burning := StatusInstance.new()
	burning.status_id = "burning"
	burning.magnitude = 5
	_enemy(gs).active_statuses.assign([burning])
	CombustibleOilHandler.new().apply(_ctx(gs))
	assert_int(_enemy(gs).hp).is_equal(14)  # 20 − 6 burst
	# No vulnerable added (still just the Burning).
	for s in _enemy(gs).active_statuses:
		assert_str(s.status_id).is_not_equal("vulnerable")


func test_registered_in_pipeline() -> void:
	assert_bool(AbilityPipeline.with_default_handlers().has_handler("combustible_oil")).is_true()
