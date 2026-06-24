# Tests for CombatResolver.resolve_player_action (T5.6): the dispatcher for
# standard actions (flag reset, Evade, handler-chain run, charge decrement +
# weapon preservation, signal emission) and the two interactive resolutions
# READ_THE_ROAD_COMMIT (descending splice) and REPENT_DISCARD (remove / heal /
# burden / item_discarded). CHOOSE_OMEN dispatch is also covered.
# @Spec: LLD-ARCH-019, LLD-ARCH-003, HLD-COMBAT-017, HLD-RUN-007, LLD-OMEN-CARD-020
extends GdUnitTestSuite

const SignalBusScript = preload("res://src/infrastructure/signal_bus.gd")


# --- Stubs ------------------------------------------------------------------

class StubContent:
	var vessels: Dictionary = {}
	var abilities: Dictionary = {}
	var enemies: Dictionary = {}
	var omen_cards: Dictionary = {}
	func get_vessel(id: String):
		return vessels.get(id, null)
	func get_ability(id: String):
		return abilities.get(id, null)
	func get_enemy(id: String):
		return enemies.get(id, null)
	func get_omen_card(id: String):
		return omen_cards.get(id, null)


class StubRng:
	var queue: Array = []
	var default: int = 0
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


func _deal_damage(base: int, mode: String = "single") -> HandlerConfig:
	var hc := HandlerConfig.new()
	hc.handler_id = "deal_damage"
	hc.params = {"base_damage": base, "damage_type": "physical", "mode": mode}
	return hc


func _gs(content: StubContent, enemy_hp: int = 10) -> GameState:
	var gs := GameState.new()
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
	content.vessels["pilgrim"] = VesselData.new()
	content.enemies["skeleton"] = EnemyData.new()
	return gs


func _resolver(content: StubContent, rng = null, bus = null) -> CombatResolver:
	return CombatResolver.new(rng, content, AbilityPipeline.with_default_handlers(), bus)


func _enemy(gs: GameState) -> EnemyState:
	return gs.combat_state.enemies[0]


# --- READ_THE_ROAD_COMMIT ---------------------------------------------------

# Descending splice: send_to_bottom [2, 0] on [A,B,C,D,E] → [B,D,E,C,A].
func test_read_the_road_descending_splice() -> void:
	var content := StubContent.new()
	var gs := _gs(content)
	gs.combat_state.read_the_road_active = true
	gs.combat_state.omen_deck.draw_pile.assign([
		{"card_id": "A", "timer_value": 1}, {"card_id": "B", "timer_value": 1},
		{"card_id": "C", "timer_value": 1}, {"card_id": "D", "timer_value": 1},
		{"card_id": "E", "timer_value": 1},
	])
	_resolver(content).resolve_player_action({"type": "READ_THE_ROAD_COMMIT", "send_to_bottom": [2, 0]}, gs)
	var ids := _card_ids(gs.combat_state.omen_deck.draw_pile)
	assert_array(ids).is_equal(["B", "D", "E", "C", "A"])
	assert_bool(gs.combat_state.read_the_road_active).is_false()


# Empty send_to_bottom leaves the pile unchanged but clears the flag.
func test_read_the_road_empty_send() -> void:
	var content := StubContent.new()
	var gs := _gs(content)
	gs.combat_state.read_the_road_active = true
	gs.combat_state.omen_deck.draw_pile.assign([
		{"card_id": "A", "timer_value": 1}, {"card_id": "B", "timer_value": 1},
	])
	_resolver(content).resolve_player_action({"type": "READ_THE_ROAD_COMMIT", "send_to_bottom": []}, gs)
	assert_array(_card_ids(gs.combat_state.omen_deck.draw_pile)).is_equal(["A", "B"])
	assert_bool(gs.combat_state.read_the_road_active).is_false()


# Not active → error + unchanged (flag stays false, pile untouched).
func test_read_the_road_not_active_unchanged() -> void:
	var content := StubContent.new()
	var gs := _gs(content)
	gs.combat_state.read_the_road_active = false
	gs.combat_state.omen_deck.draw_pile.assign([{"card_id": "A", "timer_value": 1}])
	_resolver(content).resolve_player_action({"type": "READ_THE_ROAD_COMMIT", "send_to_bottom": [0]}, gs)
	assert_array(_card_ids(gs.combat_state.omen_deck.draw_pile)).is_equal(["A"])


# Invalid indices (out of allowed window / duplicate) → unchanged, flag stays true.
func test_read_the_road_invalid_indices_unchanged() -> void:
	var content := StubContent.new()
	var gs := _gs(content)
	gs.combat_state.read_the_road_active = true
	gs.combat_state.omen_deck.draw_pile.assign([
		{"card_id": "A", "timer_value": 1}, {"card_id": "B", "timer_value": 1},
		{"card_id": "C", "timer_value": 1},
	])
	# Duplicate index → invalid.
	_resolver(content).resolve_player_action({"type": "READ_THE_ROAD_COMMIT", "send_to_bottom": [1, 1]}, gs)
	assert_array(_card_ids(gs.combat_state.omen_deck.draw_pile)).is_equal(["A", "B", "C"])
	assert_bool(gs.combat_state.read_the_road_active).is_true()


# --- REPENT_DISCARD ---------------------------------------------------------

func test_repent_discard_removes_heals_burden_emits() -> void:
	var content := StubContent.new()
	var gs := _gs(content)
	gs.vessel_state.hp = 20
	gs.item_burden_score = 4
	var item := ItemInstance.new()
	item.item_id = "spoiled_potion"
	var item2 := ItemInstance.new()
	item2.item_id = "walking_staff"
	gs.inventory.assign([item, item2])
	gs.combat_state.pending_repent_slots.assign([0, 1])

	var bus = auto_free(SignalBusScript.new())
	var emitted: Array = []
	bus.item_discarded.connect(func(id, slot): emitted.append([id, slot]))

	_resolver(content, StubRng.new(), bus).resolve_player_action({"type": "REPENT_DISCARD", "slot_index": 0}, gs)

	assert_object(gs.inventory[0]).is_null()             # removed
	assert_object(gs.inventory[1]).is_not_null()         # other slot intact
	assert_int(gs.vessel_state.hp).is_equal(25)          # +5 heal
	assert_int(gs.item_burden_score).is_equal(3)         # −1 burden
	assert_array(gs.combat_state.pending_repent_slots).is_equal([])
	assert_array(emitted).is_equal([["spoiled_potion", 0]])


# Heal clamps to max_hp.
func test_repent_discard_heal_clamps() -> void:
	var content := StubContent.new()
	var gs := _gs(content)
	gs.vessel_state.hp = 28
	gs.vessel_state.max_hp = 30
	var item := ItemInstance.new()
	item.item_id = "x"
	gs.inventory.assign([item])
	gs.combat_state.pending_repent_slots.assign([0])
	_resolver(content).resolve_player_action({"type": "REPENT_DISCARD", "slot_index": 0}, gs)
	assert_int(gs.vessel_state.hp).is_equal(30)


# Burden floors at 0.
func test_repent_discard_burden_floors_at_zero() -> void:
	var content := StubContent.new()
	var gs := _gs(content)
	gs.item_burden_score = 0
	var item := ItemInstance.new()
	item.item_id = "x"
	gs.inventory.assign([item])
	gs.combat_state.pending_repent_slots.assign([0])
	_resolver(content).resolve_player_action({"type": "REPENT_DISCARD", "slot_index": 0}, gs)
	assert_int(gs.item_burden_score).is_equal(0)


# Slot not in pending → error + unchanged.
func test_repent_discard_invalid_slot_unchanged() -> void:
	var content := StubContent.new()
	var gs := _gs(content)
	var item := ItemInstance.new()
	item.item_id = "x"
	gs.inventory.assign([item])
	gs.combat_state.pending_repent_slots.assign([0])
	_resolver(content).resolve_player_action({"type": "REPENT_DISCARD", "slot_index": 2}, gs)
	assert_object(gs.inventory[0]).is_not_null()  # not removed
	assert_array(gs.combat_state.pending_repent_slots).is_equal([0])  # not cleared


# --- Turn lifecycle & buckets (HLD-COMBAT-001) ------------------------------

# begin_player_turn resets the per-turn buckets and the prior Evade — but NOT the
# stun, which must block the Action bucket for this turn.
func test_begin_player_turn_resets_buckets_and_evade() -> void:
	var content := StubContent.new()
	var gs := _gs(content)
	gs.vessel_state.is_evading = true
	gs.vessel_state.is_stunned = true
	gs.combat_state.is_action_used = true
	gs.combat_state.is_support_used = true
	gs.combat_state.is_consumable_used = true
	_resolver(content).begin_player_turn(gs)
	assert_bool(gs.vessel_state.is_evading).is_false()
	assert_bool(gs.combat_state.is_action_used).is_false()
	assert_bool(gs.combat_state.is_support_used).is_false()
	assert_bool(gs.combat_state.is_consumable_used).is_false()
	assert_bool(gs.vessel_state.is_stunned).is_true()  # stun persists into the turn


# end_player_turn clears the Shocked stun (it suppresses only one turn).
func test_end_player_turn_clears_stun() -> void:
	var content := StubContent.new()
	var gs := _gs(content)
	gs.vessel_state.is_stunned = true
	_resolver(content).end_player_turn(gs)
	assert_bool(gs.vessel_state.is_stunned).is_false()


# Evade sets is_evading and consumes the Action bucket.
func test_evade_sets_flag_and_marks_action_bucket() -> void:
	var content := StubContent.new()
	var gs := _gs(content)
	_resolver(content).resolve_player_action({"type": "EVADE"}, gs)
	assert_bool(gs.vessel_state.is_evading).is_true()
	assert_bool(gs.combat_state.is_action_used).is_true()


# A standard attack consumes the Action bucket.
func test_attack_marks_action_bucket() -> void:
	var content := StubContent.new()
	content.abilities["throw_rock"] = _ability("throw_rock", "attack", [_deal_damage(3)])
	var gs := _gs(content)
	_resolver(content).resolve_player_action({"type": "USE_ABILITY", "ability_id": "throw_rock", "target_id": "enemy_0"}, gs)
	assert_bool(gs.combat_state.is_action_used).is_true()


# --- Standard actions: handler chain + emission -----------------------------

# USE_ABILITY runs the deal_damage chain; the enemy takes damage and damage_dealt fires.
func test_use_ability_deals_damage_and_emits() -> void:
	var content := StubContent.new()
	content.abilities["throw_rock"] = _ability("throw_rock", "attack", [_deal_damage(5)])
	var gs := _gs(content, 10)
	var bus = auto_free(SignalBusScript.new())
	var dmg: Array = []
	bus.damage_dealt.connect(func(src, tgt, amt, type): dmg.append([src, tgt, amt, type]))
	_resolver(content, StubRng.new(), bus).resolve_player_action(
		{"type": "USE_ABILITY", "ability_id": "throw_rock", "target_id": "enemy_0"}, gs)
	assert_int(_enemy(gs).hp).is_equal(5)
	assert_array(dmg).is_equal([["player", "enemy_0", 5, "physical"]])


# Killing an enemy emits unit_died.
func test_killing_enemy_emits_unit_died() -> void:
	var content := StubContent.new()
	content.abilities["throw_rock"] = _ability("throw_rock", "attack", [_deal_damage(10)])
	var gs := _gs(content, 8)
	var bus = auto_free(SignalBusScript.new())
	var deaths: Array = []
	bus.unit_died.connect(func(id): deaths.append(id))
	_resolver(content, StubRng.new(), bus).resolve_player_action(
		{"type": "USE_ABILITY", "ability_id": "throw_rock", "target_id": "enemy_0"}, gs)
	assert_int(_enemy(gs).hp).is_equal(0)
	assert_array(deaths).is_equal(["enemy_0"])


# --- Charge decrement & weapon preservation (HLD-COMBAT-017) ----------------

# A weapon item against an evading enemy: if the hit misses, the charge is preserved.
func test_weapon_charge_preserved_on_full_miss() -> void:
	var content := StubContent.new()
	content.abilities["staff"] = _ability("staff", "attack", [_deal_damage(4)], 3, true)
	var gs := _gs(content)
	_enemy(gs).is_evading = true
	var item := ItemInstance.new()
	item.item_id = "staff"
	item.remaining_charges = 3
	gs.inventory.assign([item])
	var rng := StubRng.new()
	rng.queue = [0]  # evade miss roll 0 (≤34 → miss)
	_resolver(content, rng).resolve_player_action(
		{"type": "USE_ITEM", "slot_index": 0, "target_id": "enemy_0"}, gs)
	assert_int(gs.inventory[0].remaining_charges).is_equal(3)  # preserved


# A weapon item whose hit lands consumes a charge.
func test_weapon_charge_consumed_on_hit() -> void:
	var content := StubContent.new()
	content.abilities["staff"] = _ability("staff", "attack", [_deal_damage(4)], 3, true)
	var gs := _gs(content)
	var item := ItemInstance.new()
	item.item_id = "staff"
	item.remaining_charges = 3
	gs.inventory.assign([item])
	_resolver(content, StubRng.new()).resolve_player_action(
		{"type": "USE_ITEM", "slot_index": 0, "target_id": "enemy_0"}, gs)
	assert_int(gs.inventory[0].remaining_charges).is_equal(2)  # consumed


# A consumable item is always consumed, even against an evading target that misses.
func test_consumable_always_consumed() -> void:
	var content := StubContent.new()
	content.abilities["bomb"] = _ability("bomb", "consumable", [_deal_damage(4)], 1, true)
	var gs := _gs(content)
	_enemy(gs).is_evading = true
	var item := ItemInstance.new()
	item.item_id = "bomb"
	item.remaining_charges = 1
	gs.inventory.assign([item])
	var rng := StubRng.new()
	rng.queue = [0]  # miss
	_resolver(content, rng).resolve_player_action(
		{"type": "USE_ITEM", "slot_index": 0, "target_id": "enemy_0"}, gs)
	assert_int(gs.inventory[0].remaining_charges).is_equal(0)  # consumed regardless


# A charged vessel ability decrements its AbilityState charge on use.
func test_ability_charge_decrements() -> void:
	var content := StubContent.new()
	content.abilities["read_the_road"] = _ability("read_the_road", "support", [], 1, false)
	var gs := _gs(content)
	var st := AbilityState.new()
	st.ability_id = "read_the_road"
	st.remaining_charges = 1
	gs.vessel_state.ability_states.assign([st])
	_resolver(content).resolve_player_action(
		{"type": "USE_ABILITY", "ability_id": "read_the_road", "target_id": ""}, gs)
	assert_int(gs.vessel_state.ability_states[0].remaining_charges).is_equal(0)


# An unlimited ability (max_charges 0, e.g. default strike) does not track charges.
func test_unlimited_ability_no_charge_change() -> void:
	var content := StubContent.new()
	content.abilities["default_strike"] = _ability("default_strike", "attack", [_deal_damage(2)], 0, false)
	var gs := _gs(content)
	var st := AbilityState.new()
	st.ability_id = "default_strike"
	st.remaining_charges = 0
	gs.vessel_state.ability_states.assign([st])
	_resolver(content).resolve_player_action(
		{"type": "USE_ABILITY", "ability_id": "default_strike", "target_id": "enemy_0"}, gs)
	assert_int(gs.vessel_state.ability_states[0].remaining_charges).is_equal(0)


# --- Status handlers get the cycle timer ------------------------------------

func _apply_status(status_id: String, magnitude: int) -> HandlerConfig:
	var hc := HandlerConfig.new()
	hc.handler_id = "apply_status"
	hc.params = {"status_id": status_id, "magnitude": magnitude, "target": "target"}
	return hc


# A player status-applying item (e.g. Spoiled Potion → Poisoned) authored WITHOUT
# remaining_ticks must inherit the current omen cycle's remaining ticks, mirroring
# enemy intents — otherwise the status would expire at the next tick before doing
# anything. @Spec: HLD-COMBAT-006, LLD-ITEMS-004
func test_player_status_inherits_cycle_remaining_ticks() -> void:
	var content := StubContent.new()
	content.abilities["spoiled_potion"] = _ability("spoiled_potion", "consumable", [_apply_status("poisoned", 2)], 1, true)
	var gs := _gs(content)
	gs.combat_state.current_cycle = OmenCycleState.new()
	gs.combat_state.current_cycle.ticks_remaining = 3
	var item := ItemInstance.new()
	item.item_id = "spoiled_potion"
	item.remaining_charges = 1
	gs.inventory.assign([item])
	_resolver(content).resolve_player_action(
		{"type": "USE_ITEM", "slot_index": 0, "target_id": "enemy_0"}, gs)
	var statuses := _enemy(gs).active_statuses
	assert_int(statuses.size()).is_equal(1)
	assert_str(statuses[0].status_id).is_equal("poisoned")
	assert_int(statuses[0].magnitude).is_equal(2)
	assert_int(statuses[0].remaining_ticks).is_equal(3)  # inherited from the cycle


# --- CHOOSE_OMEN dispatch ---------------------------------------------------

# resolve_player_action routes CHOOSE_OMEN to the omen-choice resolution (T5.4).
func test_choose_omen_dispatch() -> void:
	var content := StubContent.new()
	content.omen_cards["c0"] = _omen_card("c0")
	content.omen_cards["c1"] = _omen_card("c1")
	var gs := _gs(content)
	var cycle := OmenCycleState.new()
	cycle.drawn_cards.assign([
		{"card_id": "c0", "timer_value": 1},
		{"card_id": "c1", "timer_value": 2},
		{"card_id": "c0", "timer_value": 3},
	])
	cycle.sides_assigned = false
	gs.combat_state.current_cycle = cycle
	_resolver(content, StubRng.new()).resolve_player_action(
		{"type": "CHOOSE_OMEN", "card_index": 0, "side": "enemy"}, gs)
	assert_bool(gs.combat_state.current_cycle.sides_assigned).is_true()


# --- Helpers ----------------------------------------------------------------

func _card_ids(pile: Array) -> Array:
	var ids: Array = []
	for entry in pile:
		ids.append(entry["card_id"])
	return ids


func _omen_card(id: String) -> OmenCardData:
	var c := OmenCardData.new()
	c.card_id = id
	return c
