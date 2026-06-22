# Tests for ActionInjector (T6.1): the single decision entry point (LLD-ARCH-003).
# get_legal_actions() dispatches by run phase (combat → CombatResolver, navigation,
# loot); submit_action() validates against the legal set (illegal → log + unchanged,
# never throw) and owns the post-resolution item bookkeeping — attack-item break
# detection + item_broken emit + burden −1 (HLD-ITEMS-005, HLD-RUN-007) and loot
# acquisition with no inventory cap + burden +2 (HLD-ITEMS-001, HLD-RUN-007).
# @Spec: LLD-ARCH-003, LLD-ARCH-011, LLD-ARCH-009, HLD-RUN-007, HLD-ITEMS-001, HLD-ITEMS-005
extends GdUnitTestSuite

const SignalBusScript = preload("res://src/infrastructure/signal_bus.gd")


# --- Stubs ------------------------------------------------------------------

class StubContent:
	var vessels: Dictionary = {}
	var abilities: Dictionary = {}  # also the item catalogue (items are AbilityData)
	var enemies: Dictionary = {}
	var omen_cards: Dictionary = {}
	var companions: Dictionary = {}
	func get_vessel(id: String):
		return vessels.get(id, null)
	func get_ability(id: String):
		return abilities.get(id, null)
	func get_enemy(id: String):
		return enemies.get(id, null)
	func get_omen_card(id: String):
		return omen_cards.get(id, null)
	func get_companion(id: String):
		return companions.get(id, null)


class StubRng:
	var queue: Array = []
	var default: int = 100  # default high → no evade miss (>34)
	func randi_range(_stream: int, a: int, b: int) -> int:
		var v: int = default
		if not queue.is_empty():
			v = queue.pop_front()
		return clampi(v, a, b)


# --- Builders ---------------------------------------------------------------

func _ability(id: String, bucket: String, handlers: Array = [], max_charges: int = 0, breaks: bool = false) -> AbilityData:
	var a := AbilityData.new()
	a.ability_id = id
	a.action_bucket = bucket
	a.max_charges = max_charges
	a.breaks_at_zero = breaks
	a.handlers.assign(handlers)
	return a


func _deal_damage(base: int) -> HandlerConfig:
	var hc := HandlerConfig.new()
	hc.handler_id = "deal_damage"
	hc.params = {"base_damage": base, "damage_type": "physical", "mode": "single"}
	return hc


func _injector(content: StubContent, rng = null, bus = null) -> ActionInjector:
	var resolver := CombatResolver.new(rng, content, AbilityPipeline.with_default_handlers(), bus)
	var charge_manager := ChargeManager.new(Callable(content, "get_ability"))
	return ActionInjector.new(resolver, charge_manager, content, bus)


func _combat_gs(content: StubContent, enemy_hp: int = 10) -> GameState:
	var gs := GameState.new()
	gs.run_phase = GameState.RunPhase.COMBAT
	gs.vessel_state = VesselState.new()
	gs.vessel_state.vessel_id = "pilgrim"
	gs.vessel_state.hp = 20
	gs.vessel_state.max_hp = 30
	gs.combat_state = CombatState.new()
	gs.combat_state.omen_deck = OmenDeckState.new()
	var e := EnemyState.new()
	e.enemy_id = "skeleton"
	e.instance_id = "enemy_0"
	e.hp = enemy_hp
	e.max_hp = 10
	gs.combat_state.enemies.assign([e])
	var vd := VesselData.new()
	vd.default_strike_id = "default_strike"
	content.vessels["pilgrim"] = vd
	content.abilities["default_strike"] = _ability("default_strike", "attack", [_deal_damage(2)], 0, false)
	content.enemies["skeleton"] = EnemyData.new()
	return gs


func _nav_gs() -> GameState:
	var gs := GameState.new()
	gs.run_phase = GameState.RunPhase.NAVIGATION
	gs.navigation_state = NavigationState.new()
	return gs


func _loot_gs(content: StubContent, offers: Array) -> GameState:
	var gs := GameState.new()
	gs.run_phase = GameState.RunPhase.LOOT_SELECTION
	gs.navigation_state = NavigationState.new()
	gs.navigation_state.loot_offers.assign(offers)
	return gs


func _door(room_type: String, encounter_id: String, room_id: String) -> DoorData:
	var d := DoorData.new()
	d.room_type = room_type
	d.encounter_id = encounter_id
	d.room_id = room_id
	return d


func _item(id: String, charges: int) -> ItemInstance:
	var it := ItemInstance.new()
	it.item_id = id
	it.remaining_charges = charges
	return it


func _enemy(gs: GameState) -> EnemyState:
	return gs.combat_state.enemies[0]


func _types(actions: Array) -> Array:
	var out: Array = []
	for a in actions:
		out.append(a["type"])
	return out


# --- get_legal_actions: phase dispatch --------------------------------------

# COMBAT phase delegates to CombatResolver.get_legal_combat_actions (Evade present).
func test_combat_phase_delegates_to_resolver() -> void:
	var content := StubContent.new()
	var gs := _combat_gs(content)
	var actions := _injector(content, StubRng.new()).get_legal_actions(gs)
	assert_bool("EVADE" in _types(actions)).is_true()
	assert_bool("USE_ABILITY" in _types(actions)).is_true()


# Combat gating passes through: read_the_road_active → only READ_THE_ROAD_COMMIT.
func test_combat_gating_delegates() -> void:
	var content := StubContent.new()
	var gs := _combat_gs(content)
	gs.combat_state.read_the_road_active = true
	var actions := _injector(content, StubRng.new()).get_legal_actions(gs)
	assert_int(actions.size()).is_equal(1)
	assert_str(actions[0]["type"]).is_equal("READ_THE_ROAD_COMMIT")


# NAVIGATION phase → one CHOOSE_DOOR per door, carrying the room_id.
func test_navigation_door_actions() -> void:
	var content := StubContent.new()
	var gs := _nav_gs()
	gs.navigation_state.doors_ahead.assign([
		_door("combat", "skeleton", "room_1"),
		_door("combat", "wolf", "room_2"),
	])
	var actions := _injector(content).get_legal_actions(gs)
	assert_array(actions).is_equal([
		{"type": "CHOOSE_DOOR", "room_id": "room_1"},
		{"type": "CHOOSE_DOOR", "room_id": "room_2"},
	])


# LOOT_SELECTION → one CHOOSE_LOOT per offer plus DECLINE_LOOT.
func test_loot_actions_offer_each_plus_decline() -> void:
	var content := StubContent.new()
	var gs := _loot_gs(content, ["ember_shard", "ointment"])
	var actions := _injector(content).get_legal_actions(gs)
	assert_array(actions).is_equal([
		{"type": "CHOOSE_LOOT", "item_id": "ember_shard"},
		{"type": "CHOOSE_LOOT", "item_id": "ointment"},
		{"type": "DECLINE_LOOT"},
	])


# No inventory cap (HLD-ITEMS-001): a full 3-slot inventory still offers CHOOSE_LOOT.
func test_loot_no_cap_full_inventory_still_offers() -> void:
	var content := StubContent.new()
	var gs := _loot_gs(content, ["x"])
	gs.inventory.assign([_item("a", 1), _item("b", 1), _item("c", 1)])
	var actions := _injector(content).get_legal_actions(gs)
	assert_array(actions).is_equal([
		{"type": "CHOOSE_LOOT", "item_id": "x"},
		{"type": "DECLINE_LOOT"},
	])


# Terminal phase (RUN_END) yields no player actions.
func test_terminal_phase_no_actions() -> void:
	var content := StubContent.new()
	var gs := GameState.new()
	gs.run_phase = GameState.RunPhase.RUN_END
	assert_array(_injector(content).get_legal_actions(gs)).is_equal([])


# --- submit_action: illegal-action safety -----------------------------------

# An action illegal in the current phase leaves the state unchanged.
func test_illegal_action_in_phase_unchanged() -> void:
	var content := StubContent.new()
	var gs := _combat_gs(content, 10)
	gs.item_burden_score = 3
	_injector(content, StubRng.new()).submit_action({"type": "CHOOSE_LOOT", "item_id": "x"}, gs)
	assert_int(_enemy(gs).hp).is_equal(10)
	assert_int(gs.item_burden_score).is_equal(3)


# A combat action with a non-legal target (no such living enemy) is rejected.
func test_illegal_combat_target_unchanged() -> void:
	var content := StubContent.new()
	content.abilities["throw_rock"] = _ability("throw_rock", "attack", [_deal_damage(5)])
	var gs := _combat_gs(content, 10)
	_injector(content, StubRng.new()).submit_action(
		{"type": "USE_ABILITY", "ability_id": "throw_rock", "target_id": "enemy_99"}, gs)
	assert_int(_enemy(gs).hp).is_equal(10)


# --- submit_action: combat delegation ---------------------------------------

# A legal USE_ABILITY (the always-legal Default Strike) is delegated and deals damage.
func test_use_ability_delegates_damage() -> void:
	var content := StubContent.new()
	var gs := _combat_gs(content, 10)  # default_strike deals 2 (see _combat_gs)
	_injector(content, StubRng.new()).submit_action(
		{"type": "USE_ABILITY", "ability_id": "default_strike", "target_id": "enemy_0"}, gs)
	assert_int(_enemy(gs).hp).is_equal(8)


# --- submit_action: attack-item break flow (HLD-ITEMS-005, LLD-ARCH-011) ----

# A weapon at 1 charge that lands breaks: removed, item_broken emitted, burden −1.
func test_attack_item_break_flow() -> void:
	var content := StubContent.new()
	content.abilities["staff"] = _ability("staff", "attack", [_deal_damage(4)], 1, true)
	var gs := _combat_gs(content)
	gs.item_burden_score = 5
	gs.inventory.assign([_item("staff", 1)])
	var bus = auto_free(SignalBusScript.new())
	var broken: Array = []
	bus.item_broken.connect(func(id, slot): broken.append([id, slot]))

	_injector(content, StubRng.new(), bus).submit_action(
		{"type": "USE_ITEM", "slot_index": 0, "target_id": "enemy_0"}, gs)

	assert_object(gs.inventory[0]).is_null()            # removed
	assert_array(broken).is_equal([["staff", 0]])       # item_broken emitted
	assert_int(gs.item_burden_score).is_equal(4)        # −1 on break


# A weapon with charges left after use is not removed; no item_broken, no burden change.
func test_attack_item_no_break_when_charges_remain() -> void:
	var content := StubContent.new()
	content.abilities["staff"] = _ability("staff", "attack", [_deal_damage(4)], 2, true)
	var gs := _combat_gs(content)
	gs.item_burden_score = 5
	gs.inventory.assign([_item("staff", 2)])
	var bus = auto_free(SignalBusScript.new())
	var broken: Array = []
	bus.item_broken.connect(func(id, slot): broken.append([id, slot]))

	_injector(content, StubRng.new(), bus).submit_action(
		{"type": "USE_ITEM", "slot_index": 0, "target_id": "enemy_0"}, gs)

	assert_int(gs.inventory[0].remaining_charges).is_equal(1)
	assert_array(broken).is_equal([])
	assert_int(gs.item_burden_score).is_equal(5)


# A spent consumable (breaks_at_zero) is removed with burden −1 and item_broken.
# The resolver lists non-attack items as non-targeted (target_id ""); a consumable
# always decrements on use regardless of effect, so it breaks at 0.
func test_consumable_spent_removed_and_burden_decrement() -> void:
	var content := StubContent.new()
	content.abilities["bomb"] = _ability("bomb", "consumable", [], 1, true)
	var gs := _combat_gs(content)
	gs.item_burden_score = 3
	gs.inventory.assign([_item("bomb", 1)])
	var bus = auto_free(SignalBusScript.new())
	var broken: Array = []
	bus.item_broken.connect(func(id, slot): broken.append([id, slot]))

	_injector(content, StubRng.new(), bus).submit_action(
		{"type": "USE_ITEM", "slot_index": 0, "target_id": ""}, gs)

	assert_object(gs.inventory[0]).is_null()
	assert_array(broken).is_equal([["bomb", 0]])
	assert_int(gs.item_burden_score).is_equal(2)


# A weapon whose only hit misses preserves its charge (resolver) and does not break.
func test_weapon_miss_preserves_charge_no_break() -> void:
	var content := StubContent.new()
	content.abilities["staff"] = _ability("staff", "attack", [_deal_damage(4)], 1, true)
	var gs := _combat_gs(content)
	gs.item_burden_score = 5
	_enemy(gs).is_evading = true
	gs.inventory.assign([_item("staff", 1)])
	var rng := StubRng.new()
	rng.queue = [0]  # evade miss roll (≤34 → miss)
	var bus = auto_free(SignalBusScript.new())
	var broken: Array = []
	bus.item_broken.connect(func(id, slot): broken.append([id, slot]))

	_injector(content, rng, bus).submit_action(
		{"type": "USE_ITEM", "slot_index": 0, "target_id": "enemy_0"}, gs)

	assert_int(gs.inventory[0].remaining_charges).is_equal(1)  # preserved
	assert_array(broken).is_equal([])
	assert_int(gs.item_burden_score).is_equal(5)


# --- submit_action: loot acquisition (HLD-ITEMS-001, HLD-RUN-007) -----------

# CHOOSE_LOOT adds the item at full charges, burden +2, item_acquired, offers cleared.
func test_choose_loot_adds_item_burden_emit() -> void:
	var content := StubContent.new()
	content.abilities["ember_shard"] = _ability("ember_shard", "consumable", [], 3, true)
	var gs := _loot_gs(content, ["ember_shard", "ointment"])
	gs.item_burden_score = 4
	var bus = auto_free(SignalBusScript.new())
	var acquired: Array = []
	bus.item_acquired.connect(func(id): acquired.append(id))

	_injector(content, null, bus).submit_action({"type": "CHOOSE_LOOT", "item_id": "ember_shard"}, gs)

	assert_int(gs.inventory.size()).is_equal(1)
	assert_str(gs.inventory[0].item_id).is_equal("ember_shard")
	assert_int(gs.inventory[0].remaining_charges).is_equal(3)  # initialised to max_charges
	assert_int(gs.item_burden_score).is_equal(6)               # +2
	assert_array(acquired).is_equal(["ember_shard"])
	assert_array(gs.navigation_state.loot_offers).is_equal([])  # cleared


# A free (null) slot is filled before appending a new one.
func test_choose_loot_fills_free_slot() -> void:
	var content := StubContent.new()
	content.abilities["x"] = _ability("x", "consumable", [], 2, true)
	var gs := _loot_gs(content, ["x"])
	gs.inventory.assign([_item("a", 1), null, _item("c", 1)])
	_injector(content, null).submit_action({"type": "CHOOSE_LOOT", "item_id": "x"}, gs)
	assert_int(gs.inventory.size()).is_equal(3)            # no new slot appended
	assert_str(gs.inventory[1].item_id).is_equal("x")      # filled the null slot


# No cap: acquiring with a full inventory appends a new slot (HLD-ITEMS-001).
func test_choose_loot_no_cap_appends_when_full() -> void:
	var content := StubContent.new()
	content.abilities["x"] = _ability("x", "consumable", [], 2, true)
	var gs := _loot_gs(content, ["x"])
	gs.inventory.assign([_item("a", 1), _item("b", 1), _item("c", 1)])
	gs.item_burden_score = 6
	_injector(content, null).submit_action({"type": "CHOOSE_LOOT", "item_id": "x"}, gs)
	assert_int(gs.inventory.size()).is_equal(4)            # appended beyond 3
	assert_str(gs.inventory[3].item_id).is_equal("x")
	assert_int(gs.item_burden_score).is_equal(8)


# DECLINE_LOOT walks away: no item, offers cleared, burden unchanged.
func test_decline_loot_clears_offers_no_item() -> void:
	var content := StubContent.new()
	var gs := _loot_gs(content, ["x", "y"])
	gs.item_burden_score = 4
	_injector(content, null).submit_action({"type": "DECLINE_LOOT"}, gs)
	assert_int(gs.inventory.size()).is_equal(0)
	assert_array(gs.navigation_state.loot_offers).is_equal([])
	assert_int(gs.item_burden_score).is_equal(4)


# --- submit_action: orchestration pass-throughs -----------------------------

# CHOOSE_DOOR is legal and leaves state for the orchestrator (no injector mutation).
func test_choose_door_legal_unchanged() -> void:
	var content := StubContent.new()
	var gs := _nav_gs()
	gs.navigation_state.doors_ahead.assign([_door("combat", "skeleton", "room_1")])
	_injector(content).submit_action({"type": "CHOOSE_DOOR", "room_id": "room_1"}, gs)
	assert_int(gs.navigation_state.doors_ahead.size()).is_equal(1)  # untouched by injector


# END_TURN is the legal fallback when stunned with no usable items; submit is a no-op.
func test_end_turn_legal_unchanged() -> void:
	var content := StubContent.new()
	var gs := _combat_gs(content, 10)
	gs.vessel_state.is_stunned = true  # excludes the Action bucket → END_TURN fallback
	var actions := _injector(content, StubRng.new()).get_legal_actions(gs)
	assert_array(_types(actions)).is_equal(["END_TURN"])
	_injector(content, StubRng.new()).submit_action({"type": "END_TURN"}, gs)
	assert_int(_enemy(gs).hp).is_equal(10)
