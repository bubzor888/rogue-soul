# @Spec: UI-COMBAT-001, UI-COMBAT-002, UI-COMBAT-003, UI-COMBAT-006, UI-COMBAT-009
extends GdUnitTestSuite

# Minimal content stub so the view-model resolves buckets/summaries without the registry.
class _FakeContent:
	var abilities: Dictionary = {}
	func get_ability(id): return abilities.get(id)
	func get_vessel(_id): return null
	func get_enemy(_id): return null
	func get_omen_card(id: String) -> OmenCardData:
		var c := OmenCardData.new(); c.card_id = id; c.display_name = id; return c
	static func new_with_strike() -> _FakeContent:
		var c := _FakeContent.new()
		var a := AbilityData.new()
		a.ability_id = "default_strike"
		a.action_bucket = "attack"
		a.display_name = "Strike"
		a.max_charges = 0
		c.abilities["default_strike"] = a
		return c

func _enemy(id: String, inst: String, hp: int) -> EnemyState:
	var e := EnemyState.new(); e.enemy_id = id; e.instance_id = inst; e.hp = hp; e.max_hp = hp; return e

func _combat_state(enemies: Array) -> GameState:
	var gs := GameState.new()
	gs.vessel_state = VesselState.new(); gs.vessel_state.hp = 20; gs.vessel_state.max_hp = 20
	gs.combat_state = CombatState.new()
	gs.combat_state.enemies.assign(enemies)
	gs.combat_state.current_cycle = OmenCycleState.new()
	gs.combat_state.current_cycle.ticks_remaining = 2
	return gs

# UI-COMBAT-001: single enemy centered at the enemy-area midpoint (~27% height).
func test_single_enemy_centered() -> void:
	var gs := _combat_state([_enemy("plague_rat", "plague_rat_0", 6)])
	var vm := CombatViewModel.new(gs, [], _FakeContent.new())
	var pos := vm.enemy_positions()
	assert_int(pos.size()).is_equal(1)
	assert_float(pos[0]["x"]).is_equal_approx(0.5, 0.001)
	assert_float(pos[0]["y"]).is_equal_approx(0.27, 0.01)

# UI-COMBAT-002: two-enemy uses its OWN 28%/72% spacing, not the triangle's 20%/80%.
func test_two_enemy_horizontal_spacing() -> void:
	var gs := _combat_state([_enemy("wolf", "wolf_0", 5), _enemy("wolf", "wolf_1", 5)])
	var vm := CombatViewModel.new(gs, [], _FakeContent.new())
	var pos := vm.enemy_positions()
	assert_float(pos[0]["x"]).is_equal_approx(0.28, 0.001)
	assert_float(pos[1]["x"]).is_equal_approx(0.72, 0.001)

# UI-COMBAT-001: three-enemy triangle — back-center higher and smaller, front pair 20%/80%.
func test_three_enemy_triangle() -> void:
	var gs := _combat_state([_enemy("a", "a_0", 5), _enemy("b", "b_0", 5), _enemy("c", "c_0", 5)])
	var vm := CombatViewModel.new(gs, [], _FakeContent.new())
	var pos := vm.enemy_positions()
	assert_float(pos[0]["x"]).is_equal_approx(0.5, 0.001)   # back-center
	assert_float(pos[0]["y"]).is_equal_approx(0.18, 0.01)
	assert_bool(pos[0]["scale"] < pos[1]["scale"]).is_true() # back reads smaller/further
	assert_float(pos[1]["x"]).is_equal_approx(0.20, 0.001)
	assert_float(pos[2]["x"]).is_equal_approx(0.80, 0.001)

func test_omen_countdown_from_cycle() -> void:
	var gs := _combat_state([_enemy("a", "a_0", 5)])
	var vm := CombatViewModel.new(gs, [], _FakeContent.new())
	assert_int(vm.omen_countdown()).is_equal(2)

# UI-COMBAT-009: buckets are partitioned from the legal actions (gating already applied upstream).
func test_action_bucket_partition_from_legal() -> void:
	var gs := _combat_state([_enemy("a", "a_0", 5)])
	var legal := [
		{"type": "USE_ABILITY", "ability_id": "default_strike", "target_id": "a_0"},
		{"type": "EVADE"},
		{"type": "END_TURN"},
	]
	var vm := CombatViewModel.new(gs, legal, _FakeContent.new_with_strike())
	var action_rows := vm.bucket_rows("action")
	# Default Strike appears in the Action bucket, paired with its USE_ABILITY action.
	assert_bool(action_rows.any(func(r): return r["action"]["ability_id"] == "default_strike")).is_true()

# LLD-ABILITIES-005: Read the Road exposes the top 3 draw-pile cards with their indices.
func test_read_the_road_shows_top_three_cards() -> void:
	var gs := _combat_state([_enemy("a", "a_0", 5)])
	gs.combat_state.omen_deck = OmenDeckState.new()
	gs.combat_state.omen_deck.draw_pile.assign([
		{"card_id": "c0", "timer_value": 3},
		{"card_id": "c1", "timer_value": 4},
		{"card_id": "c2", "timer_value": 5},
		{"card_id": "c3", "timer_value": 6},
	])
	var vm := CombatViewModel.new(gs, [], _FakeContent.new())
	var cards := vm.read_the_road_cards()
	assert_int(cards.size()).is_equal(3)  # window = min(2, size-1) = 2 → indices 0,1,2
	assert_int(cards[0]["index"]).is_equal(0)
	assert_int(cards[0]["duration"]).is_equal(3)
	assert_int(cards[2]["index"]).is_equal(2)

# HLD-ITEMS-003: an encounter-countdown item (Worn Map) is not an active combat action.
func test_encounter_countdown_item_excluded_from_buckets() -> void:
	var gs := _combat_state([_enemy("a", "a_0", 5)])
	var item := ItemInstance.new(); item.item_id = "worn_map"
	gs.inventory.assign([item, null, null])
	var content := _FakeContent.new()
	var wm := AbilityData.new()
	wm.ability_id = "worn_map"; wm.action_bucket = "support"; wm.display_name = "Worn Map"
	wm.is_encounter_countdown = true
	content.abilities["worn_map"] = wm
	var legal := [{"type": "USE_ITEM", "slot_index": 0, "target_id": ""}]
	var vm := CombatViewModel.new(gs, legal, content)
	assert_int(vm.bucket_rows("support").size()).is_equal(0)
