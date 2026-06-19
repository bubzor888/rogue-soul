# Tests for CombatResolver (T5.x). Built incrementally alongside each sub-task.
# T5.1: get_legal_combat_actions — priority gating, stun exclusion, ≥1 guarantee.
# @Spec: LLD-ARCH-019, LLD-ARCH-003, HLD-COMBAT-004, HLD-COMBAT-011, HLD-COMBAT-017
extends GdUnitTestSuite


# --- Stub content provider (the injected ContentRegistry-style lookup) -------

class StubContent:
	var vessels: Dictionary = {}
	var abilities: Dictionary = {}
	func get_vessel(id: String):
		return vessels.get(id, null)
	func get_ability(id: String):
		return abilities.get(id, null)


func _ability(id: String, bucket: String) -> AbilityData:
	var a := AbilityData.new()
	a.ability_id = id
	a.action_bucket = bucket
	return a


func _vessel_data(strike_id: String) -> VesselData:
	var v := VesselData.new()
	v.vessel_id = "pilgrim"
	v.default_strike_id = strike_id
	return v


# A combat GameState with `enemy_count` living enemies and a pilgrim vessel.
func _combat_state(content: StubContent, enemy_count: int = 1) -> GameState:
	content.vessels["pilgrim"] = _vessel_data("throw_rock")
	content.abilities["throw_rock"] = _ability("throw_rock", "attack")

	var gs := GameState.new()
	gs.vessel_state = VesselState.new()
	gs.vessel_state.vessel_id = "pilgrim"
	gs.combat_state = CombatState.new()
	var enemies: Array[EnemyState] = []
	for i in enemy_count:
		var e := EnemyState.new()
		e.instance_id = "enemy_%d" % i
		e.hp = 10
		enemies.append(e)
	gs.combat_state.enemies.assign(enemies)
	return gs


func _resolver(content: StubContent) -> CombatResolver:
	return CombatResolver.new(null, content, null)


func _types(actions: Array) -> Array:
	var out: Array = []
	for a in actions:
		out.append(a["type"])
	return out


# --- Gating priority --------------------------------------------------------

func test_read_the_road_gate_returns_only_commit() -> void:
	var content := StubContent.new()
	var gs := _combat_state(content)
	gs.combat_state.read_the_road_active = true
	var actions := _resolver(content).get_legal_combat_actions(gs)
	assert_int(actions.size()).is_equal(1)
	assert_str(actions[0]["type"]).is_equal("READ_THE_ROAD_COMMIT")


func test_repent_gate_returns_one_per_slot() -> void:
	var content := StubContent.new()
	var gs := _combat_state(content)
	gs.combat_state.pending_repent_slots.assign([0, 2])
	var actions := _resolver(content).get_legal_combat_actions(gs)
	assert_int(actions.size()).is_equal(2)
	assert_array(_types(actions)).is_equal(["REPENT_DISCARD", "REPENT_DISCARD"])
	assert_int(actions[0]["slot_index"]).is_equal(0)
	assert_int(actions[1]["slot_index"]).is_equal(2)


func test_read_the_road_takes_priority_over_repent() -> void:
	var content := StubContent.new()
	var gs := _combat_state(content)
	gs.combat_state.read_the_road_active = true
	gs.combat_state.pending_repent_slots.assign([0, 1])
	var actions := _resolver(content).get_legal_combat_actions(gs)
	assert_int(actions.size()).is_equal(1)
	assert_str(actions[0]["type"]).is_equal("READ_THE_ROAD_COMMIT")


# --- Standard set -----------------------------------------------------------

# Zero charges, one enemy → exactly Default Strike + Evade.
func test_zero_charge_fallback_is_strike_and_evade() -> void:
	var content := StubContent.new()
	var gs := _combat_state(content, 1)
	var actions := _resolver(content).get_legal_combat_actions(gs)
	assert_int(actions.size()).is_equal(2)
	assert_array(_types(actions)).contains_exactly_in_any_order(["USE_ABILITY", "EVADE"])
	# Default Strike targets the lone enemy.
	for a in actions:
		if a["type"] == "USE_ABILITY":
			assert_str(a["ability_id"]).is_equal("throw_rock")
			assert_str(a["target_id"]).is_equal("enemy_0")


# Default Strike enumerates one action per living enemy.
func test_default_strike_per_target() -> void:
	var content := StubContent.new()
	var gs := _combat_state(content, 2)
	var actions := _resolver(content).get_legal_combat_actions(gs)
	var strikes := 0
	for a in actions:
		if a["type"] == "USE_ABILITY":
			strikes += 1
	assert_int(strikes).is_equal(2)  # one per enemy


# Dead enemies are not valid targets.
func test_dead_enemies_excluded_as_targets() -> void:
	var content := StubContent.new()
	var gs := _combat_state(content, 2)
	gs.combat_state.enemies[0].hp = 0  # enemy_0 dead
	var actions := _resolver(content).get_legal_combat_actions(gs)
	for a in actions:
		if a["type"] == "USE_ABILITY":
			assert_str(a["target_id"]).is_equal("enemy_1")


# --- Stun -------------------------------------------------------------------

# Stunned: no Action-bucket options (no Strike/Evade); Support item remains.
func test_stun_excludes_action_bucket_keeps_support() -> void:
	var content := StubContent.new()
	var gs := _combat_state(content, 1)
	gs.vessel_state.is_stunned = true
	content.abilities["amethyst"] = _ability("amethyst", "support")
	var item := ItemInstance.new()
	item.item_id = "amethyst"
	item.remaining_charges = 1
	gs.inventory.assign([item])

	var actions := _resolver(content).get_legal_combat_actions(gs)
	var types := _types(actions)
	assert_bool("EVADE" in types).is_false()
	assert_bool("USE_ABILITY" in types).is_false()
	assert_bool("USE_ITEM" in types).is_true()


# Stunned with nothing usable → END_TURN (the ≥1 guarantee).
func test_stun_with_no_options_falls_back_to_end_turn() -> void:
	var content := StubContent.new()
	var gs := _combat_state(content, 1)
	gs.vessel_state.is_stunned = true
	var actions := _resolver(content).get_legal_combat_actions(gs)
	assert_array(_types(actions)).is_equal(["END_TURN"])


# An attack item while stunned is excluded; a support item would remain.
func test_stun_excludes_attack_item() -> void:
	var content := StubContent.new()
	var gs := _combat_state(content, 1)
	gs.vessel_state.is_stunned = true
	content.abilities["rope_flail"] = _ability("rope_flail", "attack")
	var item := ItemInstance.new()
	item.item_id = "rope_flail"
	item.remaining_charges = 2
	gs.inventory.assign([item])
	var actions := _resolver(content).get_legal_combat_actions(gs)
	assert_array(_types(actions)).is_equal(["END_TURN"])  # attack item excluded, nothing else


# --- Always ≥1 --------------------------------------------------------------

func test_always_at_least_one_action() -> void:
	var content := StubContent.new()
	var gs := _combat_state(content, 1)
	assert_bool(_resolver(content).get_legal_combat_actions(gs).size() >= 1).is_true()
