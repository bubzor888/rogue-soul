# Tests for DamageCalculator + deal_damage handler (T5.2): the 7-step pipeline,
# the worked scenarios, Hardened absorption, evade miss, 0-HP clamp + died.
# @Spec: LLD-ARCH-019, HLD-COMBAT-005, -007, -016, -017, -018, -019
extends GdUnitTestSuite


class StubContent:
	var enemies: Dictionary = {}
	func get_enemy(id: String):
		return enemies.get(id, null)


class StubRng:
	var value: int = 50
	func randi_range(_stream: int, _a: int, _b: int) -> int:
		return value


func _enemy_data(id: String, resistances: Array) -> EnemyData:
	var e := EnemyData.new()
	e.enemy_id = id
	e.resistances.assign(resistances)
	return e


func _status(id: String, string_param: String = "", magnitude: int = 0) -> StatusInstance:
	var s := StatusInstance.new()
	s.status_id = id
	s.string_param = string_param
	s.magnitude = magnitude
	return s


# GameState with a player vessel (attacker "player") and one enemy target.
func _gs(enemy_id: String, enemy_hp: int) -> GameState:
	var gs := GameState.new()
	gs.vessel_state = VesselState.new()
	gs.vessel_state.vessel_id = "pilgrim"
	gs.combat_state = CombatState.new()
	var enemy := EnemyState.new()
	enemy.enemy_id = enemy_id
	enemy.instance_id = "enemy_0"
	enemy.hp = enemy_hp
	enemy.max_hp = enemy_hp
	gs.combat_state.enemies.assign([enemy])
	return gs


func _enemy(gs: GameState) -> EnemyState:
	return gs.combat_state.enemies[0]


# --- Worked scenarios -------------------------------------------------------

# 7 × 1.5 (Last Stand) × 2.0 (Charge) × 1.5 (Vulnerable) = 31.5 → 31.
func test_last_stand_charge_vulnerability_31() -> void:
	var gs := _gs("skeleton", 50)
	gs.vessel_state.active_statuses.assign([_status("last_stand"), _status("charge")])
	_enemy(gs).active_statuses.assign([_status("vulnerable", "physical")])

	var content := StubContent.new()
	content.enemies["skeleton"] = _enemy_data("skeleton", [])
	var r := DamageCalculator.resolve_hit(gs, "player", "enemy_0", 7, "physical", content, null)
	assert_int(r["damage"]).is_equal(31)
	assert_int(_enemy(gs).hp).is_equal(19)


func test_resistance_cancels_vulnerability() -> void:
	var gs := _gs("fire_elemental", 50)
	_enemy(gs).active_statuses.assign([_status("vulnerable", "fire")])
	var content := StubContent.new()
	content.enemies["fire_elemental"] = _enemy_data("fire_elemental", ["fire"])
	# 10 base fire: resist ×0.5 and vuln ×1.5 cancel → ×1.0 → 10.
	var r := DamageCalculator.resolve_hit(gs, "player", "enemy_0", 10, "fire", content, null)
	assert_int(r["damage"]).is_equal(10)


func test_resistance_only_halves() -> void:
	var gs := _gs("fire_elemental", 50)
	var content := StubContent.new()
	content.enemies["fire_elemental"] = _enemy_data("fire_elemental", ["fire"])
	var r := DamageCalculator.resolve_hit(gs, "player", "enemy_0", 10, "fire", content, null)
	assert_int(r["damage"]).is_equal(5)


func test_vulnerability_only_amplifies() -> void:
	var gs := _gs("skeleton", 50)
	_enemy(gs).active_statuses.assign([_status("vulnerable", "fire")])
	var content := StubContent.new()
	content.enemies["skeleton"] = _enemy_data("skeleton", [])
	var r := DamageCalculator.resolve_hit(gs, "player", "enemy_0", 10, "fire", content, null)
	assert_int(r["damage"]).is_equal(15)


# Type Convert overrides the damage type before resistance applies.
func test_type_convert_override() -> void:
	var gs := _gs("fire_elemental", 50)
	gs.vessel_state.active_statuses.assign([_status("type_convert", "fire")])
	var content := StubContent.new()
	content.enemies["fire_elemental"] = _enemy_data("fire_elemental", ["fire"])
	# physical 6 → converted to fire → enemy resists fire ×0.5 → 3.
	var r := DamageCalculator.resolve_hit(gs, "player", "enemy_0", 6, "physical", content, null)
	assert_int(r["damage"]).is_equal(3)
	assert_str(r["type"]).is_equal("fire")


func test_hardened_absorbs_to_zero() -> void:
	var gs := _gs("totem", 50)
	_enemy(gs).active_statuses.assign([_status("hardened", "", 5)])
	var content := StubContent.new()
	content.enemies["totem"] = _enemy_data("totem", [])
	var r := DamageCalculator.resolve_hit(gs, "player", "enemy_0", 4, "physical", content, null)
	assert_int(r["damage"]).is_equal(0)
	assert_int(_enemy(gs).hp).is_equal(50)  # no damage taken


func test_emboldened_physical_flat_bonus() -> void:
	var gs := _gs("skeleton", 50)
	gs.vessel_state.active_statuses.assign([_status("emboldened", "physical", 3)])
	var content := StubContent.new()
	content.enemies["skeleton"] = _enemy_data("skeleton", [])
	var r := DamageCalculator.resolve_hit(gs, "player", "enemy_0", 5, "physical", content, null)
	assert_int(r["damage"]).is_equal(8)  # 5 + 3 flat


func test_emboldened_elemental_multiplier() -> void:
	var gs := _gs("skeleton", 50)
	gs.vessel_state.active_statuses.assign([_status("emboldened", "fire", 0)])
	var content := StubContent.new()
	content.enemies["skeleton"] = _enemy_data("skeleton", [])
	var r := DamageCalculator.resolve_hit(gs, "player", "enemy_0", 4, "fire", content, null)
	assert_int(r["damage"]).is_equal(6)  # 4 × 1.5


# --- Evade, clamp, charge ---------------------------------------------------

func test_evade_miss() -> void:
	var gs := _gs("skeleton", 50)
	_enemy(gs).is_evading = true
	var rng := StubRng.new()
	rng.value = 0  # <= 34 → miss
	var r := DamageCalculator.resolve_hit(gs, "player", "enemy_0", 10, "physical", StubContent.new(), rng)
	assert_bool(r["missed"]).is_true()
	assert_int(_enemy(gs).hp).is_equal(50)  # untouched


func test_evade_hit_when_roll_above_threshold() -> void:
	var gs := _gs("skeleton", 50)
	_enemy(gs).is_evading = true
	var rng := StubRng.new()
	rng.value = 50  # > 34 → hit
	var content := StubContent.new()
	content.enemies["skeleton"] = _enemy_data("skeleton", [])
	var r := DamageCalculator.resolve_hit(gs, "player", "enemy_0", 10, "physical", content, rng)
	assert_bool(r["missed"]).is_false()
	assert_int(_enemy(gs).hp).is_equal(40)


func test_hp_clamps_at_zero_and_reports_died() -> void:
	var gs := _gs("skeleton", 3)
	var content := StubContent.new()
	content.enemies["skeleton"] = _enemy_data("skeleton", [])
	var r := DamageCalculator.resolve_hit(gs, "player", "enemy_0", 10, "physical", content, null)
	assert_int(_enemy(gs).hp).is_equal(0)  # never negative
	assert_bool(r["died"]).is_true()


func test_charge_consumed_after_hit() -> void:
	var gs := _gs("skeleton", 50)
	gs.vessel_state.active_statuses.assign([_status("charge")])
	var content := StubContent.new()
	content.enemies["skeleton"] = _enemy_data("skeleton", [])
	DamageCalculator.resolve_hit(gs, "player", "enemy_0", 5, "physical", content, null)
	assert_int(gs.vessel_state.active_statuses.size()).is_equal(0)  # charge removed


# --- deal_damage handler ----------------------------------------------------

func test_deal_damage_handler_single() -> void:
	var gs := _gs("skeleton", 50)
	var content := StubContent.new()
	content.enemies["skeleton"] = _enemy_data("skeleton", [])
	var ctx := AbilityContext.new(gs, "player", "enemy_0")
	ctx.content = content
	ctx.params = {"base_damage": 6, "damage_type": "physical"}
	DealDamageHandler.new().apply(ctx)
	assert_int(_enemy(gs).hp).is_equal(44)
	assert_int(ctx.results.size()).is_equal(1)
	assert_int(ctx.results[0]["damage"]).is_equal(6)


func test_deal_damage_handler_all_targets() -> void:
	var gs := _gs("skeleton", 50)
	var second := EnemyState.new()
	second.enemy_id = "skeleton"
	second.instance_id = "enemy_1"
	second.hp = 50
	gs.combat_state.enemies.append(second)
	var content := StubContent.new()
	content.enemies["skeleton"] = _enemy_data("skeleton", [])
	var ctx := AbilityContext.new(gs, "player", "enemy_0")
	ctx.content = content
	ctx.params = {"base_damage": 5, "damage_type": "physical", "mode": "all"}
	DealDamageHandler.new().apply(ctx)
	assert_int(gs.combat_state.enemies[0].hp).is_equal(45)
	assert_int(gs.combat_state.enemies[1].hp).is_equal(45)


func test_deal_damage_registered() -> void:
	assert_bool(AbilityPipeline.with_default_handlers().has_handler("deal_damage")).is_true()
