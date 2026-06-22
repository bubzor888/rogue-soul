# Tests for status tick & shift resolution (T5.3): per-tick effects, decrement +
# clear, the LLD-ARCH-023 shift order, deferred Vulnerable, plus Chilled outgoing
# reduction and Hardened per-hit semantics in DamageCalculator.
# @Spec: LLD-ARCH-019, LLD-ARCH-023, HLD-COMBAT-006, -015, -018, -019
extends GdUnitTestSuite


class StubContent:
	var enemies: Dictionary = {}
	func get_enemy(id: String):
		return enemies.get(id, null)


func _resolver() -> CombatResolver:
	return CombatResolver.new()


func _st(id: String, magnitude: int, remaining_ticks: int, trigger: String = "tick") -> StatusInstance:
	var s := StatusInstance.new()
	s.status_id = id
	s.magnitude = magnitude
	s.remaining_ticks = remaining_ticks
	s.trigger = trigger
	return s


func _enemy(hp: int, max_hp: int = 0) -> EnemyState:
	var e := EnemyState.new()
	e.enemy_id = "skeleton"
	e.instance_id = "enemy_0"
	e.hp = hp
	e.max_hp = max_hp if max_hp > 0 else hp
	return e


func _gs(enemy: EnemyState) -> GameState:
	var gs := GameState.new()
	gs.combat_state = CombatState.new()
	gs.combat_state.enemies.assign([enemy])
	return gs


func _statuses(gs: GameState) -> Array:
	return gs.combat_state.enemies[0].active_statuses


# --- Per-tick effects -------------------------------------------------------

func test_burning_tick() -> void:
	var e := _enemy(20)
	e.active_statuses.assign([_st("burning", 3, 2)])
	var gs := _gs(e)
	_resolver().resolve_omen_tick(gs)
	assert_int(e.hp).is_equal(17)
	assert_int(_statuses(gs)[0].magnitude).is_equal(3)  # burning is flat (constant)
	assert_int(_statuses(gs)[0].remaining_ticks).is_equal(1)


func test_poison_tripling() -> void:
	var e := _enemy(30)
	e.active_statuses.assign([_st("poisoned", 2, 3)])
	var gs := _gs(e)
	var r := _resolver()
	r.resolve_omen_tick(gs)
	assert_int(e.hp).is_equal(28)
	assert_int(_statuses(gs)[0].magnitude).is_equal(6)
	r.resolve_omen_tick(gs)
	assert_int(e.hp).is_equal(22)
	assert_int(_statuses(gs)[0].magnitude).is_equal(18)


func test_bleed_decay_sequence() -> void:
	var e := _enemy(30)
	e.active_statuses.assign([_st("bleed", 5, 5)])
	var gs := _gs(e)
	var r := _resolver()
	r.resolve_omen_tick(gs)  # deal 5, stacks → 2
	assert_int(e.hp).is_equal(25)
	r.resolve_omen_tick(gs)  # deal 2, stacks → 1
	assert_int(e.hp).is_equal(23)
	r.resolve_omen_tick(gs)  # deal 1, stacks → 0, clears
	assert_int(e.hp).is_equal(22)
	assert_int(_statuses(gs).size()).is_equal(0)


func test_mending_heals_and_clamps() -> void:
	var e := _enemy(20, 30)
	e.active_statuses.assign([_st("mending", 5, 3)])
	var gs := _gs(e)
	_resolver().resolve_omen_tick(gs)
	assert_int(e.hp).is_equal(25)


func test_mending_clamps_at_max() -> void:
	var e := _enemy(28, 30)
	e.active_statuses.assign([_st("mending", 5, 3)])
	_resolver().resolve_omen_tick(_gs(e))
	assert_int(e.hp).is_equal(30)


func test_chilled_accumulates() -> void:
	var e := _enemy(30)
	e.active_statuses.assign([_st("chilled", 1, 5)])
	var gs := _gs(e)
	_resolver().resolve_omen_tick(gs)
	assert_int(_statuses(gs)[0].magnitude).is_equal(2)  # +CHILLED_TICK_STEP


# --- Decrement & clear ------------------------------------------------------

func test_expired_tick_status_cleared() -> void:
	var e := _enemy(20)
	e.active_statuses.assign([_st("burning", 3, 1)])
	var gs := _gs(e)
	_resolver().resolve_omen_tick(gs)
	assert_int(e.hp).is_equal(17)  # fired this tick
	assert_int(_statuses(gs).size()).is_equal(0)  # then expired & cleared


func test_shift_status_not_fired_or_cleared_on_tick() -> void:
	var e := _enemy(20)
	e.active_statuses.assign([_st("shocked", 0, 1, "shift")])
	var gs := _gs(e)
	_resolver().resolve_omen_tick(gs)
	assert_bool(e.is_stunned).is_false()       # shift effect did NOT fire on tick
	assert_int(_statuses(gs).size()).is_equal(1)  # not cleared (ticks now 0)


# --- Shift order (LLD-ARCH-023) ---------------------------------------------

func test_death_mark_fires_before_shocked() -> void:
	var e := _enemy(20)
	e.active_statuses.assign([_st("death_mark", 0, 0, "shift"), _st("shocked", 0, 0, "shift")])
	var gs := _gs(e)
	_resolver().fire_shift_statuses(gs)
	assert_int(e.hp).is_equal(0)          # death_mark killed it
	assert_bool(e.is_stunned).is_false()  # shocked skipped (already dead)


func test_shift_per_unit_isolation() -> void:
	var a := _enemy(20)
	a.instance_id = "enemy_a"
	a.active_statuses.assign([_st("death_mark", 0, 0, "shift")])
	var b := _enemy(20)
	b.instance_id = "enemy_b"
	b.active_statuses.assign([_st("shocked", 0, 0, "shift")])
	var gs := GameState.new()
	gs.combat_state = CombatState.new()
	gs.combat_state.enemies.assign([a, b])
	_resolver().fire_shift_statuses(gs)
	assert_int(a.hp).is_equal(0)
	assert_bool(b.is_stunned).is_true()


func test_exposed_returns_pending_and_applies_vulnerable() -> void:
	var e := _enemy(20)
	e.active_statuses.assign([_st("exposed", 0, 0, "shift")])
	var gs := _gs(e)
	var r := _resolver()
	var pending := r.fire_shift_statuses(gs)
	assert_array(pending).is_equal(["enemy_0"])
	r.apply_deferred_vulnerable(gs, pending, 2)
	# Now the enemy has a vulnerable:physical with the new cycle timer.
	var vuln := _find(_statuses(gs), "vulnerable", "physical")
	assert_object(vuln).is_not_null()
	assert_int(vuln.remaining_ticks).is_equal(2)


func test_clear_expired_removes_shift_at_zero() -> void:
	var e := _enemy(20)
	e.active_statuses.assign([_st("shocked", 0, 0, "shift")])
	var gs := _gs(e)
	_resolver().clear_expired_statuses(gs)
	assert_int(_statuses(gs).size()).is_equal(0)


# --- Chilled reduction & Hardened per-hit (DamageCalculator) ----------------

func test_chilled_reduces_outgoing_damage() -> void:
	var gs := _gs(_enemy(50))
	gs.vessel_state = VesselState.new()
	gs.vessel_state.vessel_id = "pilgrim"
	gs.vessel_state.active_statuses.assign([_st("chilled", 3, 5)])
	var content := StubContent.new()
	var ed := EnemyData.new()
	ed.enemy_id = "skeleton"
	content.enemies["skeleton"] = ed
	var r := DamageCalculator.resolve_hit(gs, "player", "enemy_0", 10, "physical", content, null)
	assert_int(r["damage"]).is_equal(7)  # 10 - 3


func test_chilled_never_reduces_to_zero() -> void:
	var gs := _gs(_enemy(50))
	gs.vessel_state = VesselState.new()
	gs.vessel_state.vessel_id = "pilgrim"
	gs.vessel_state.active_statuses.assign([_st("chilled", 9, 5)])
	var content := StubContent.new()
	var ed := EnemyData.new()
	ed.enemy_id = "skeleton"
	content.enemies["skeleton"] = ed
	var r := DamageCalculator.resolve_hit(gs, "player", "enemy_0", 2, "physical", content, null)
	assert_int(r["damage"]).is_equal(1)  # floored at 1, not 0


# Two hits vs Hardened 5 are each capped independently (per-hit, non-depleting).
func test_hardened_is_per_hit_not_a_depleting_budget() -> void:
	var enemy := _enemy(50)
	enemy.active_statuses.assign([_st("hardened", 5, 3)])
	var gs := _gs(enemy)
	var content := StubContent.new()
	var ed := EnemyData.new()
	ed.enemy_id = "skeleton"
	content.enemies["skeleton"] = ed
	DamageCalculator.resolve_hit(gs, "player", "enemy_0", 4, "physical", content, null)
	DamageCalculator.resolve_hit(gs, "player", "enemy_0", 4, "physical", content, null)
	assert_int(enemy.hp).is_equal(50)  # both 4-damage hits fully absorbed


func _find(statuses: Array, status_id: String, string_param: String) -> StatusInstance:
	for s in statuses:
		if s.status_id == status_id and s.string_param == string_param:
			return s
	return null
