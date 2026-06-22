# Tests for GameState + sub-Resources (T2.2): round-trip serialisation identity,
# JSON-text survival (int casting), clone independence, null slots, defaults.
# @Spec: LLD-ARCH-017, LLD-ARCH-004, LLD-ARCH-015
extends GdUnitTestSuite


# Build a fully-populated GameState exercising every sub-Resource and edge case
# (null inventory slot, companions, statuses, omen deck + cycle).
func _make_full_state() -> GameState:
	var ability := AbilityState.new()
	ability.ability_id = "throw_rock"
	ability.remaining_charges = 2

	var status := StatusInstance.new()
	status.status_id = "vulnerable"
	status.remaining_ticks = 3
	status.magnitude = 0
	status.trigger = "tick"
	status.string_param = "fire"

	var vessel := VesselState.new()
	vessel.vessel_id = "pilgrim"
	vessel.hp = 20
	vessel.max_hp = 30
	vessel.ability_states.assign([ability])
	vessel.active_statuses.assign([status])
	vessel.is_evading = true
	vessel.is_stunned = false

	var item := ItemInstance.new()
	item.item_id = "walking_staff"
	item.remaining_charges = 6

	var companion := CompanionState.new()
	companion.companion_id = "worn_map_guide"
	companion.companion_timer = -1
	companion.companion_context = {"note": "temp"}

	var door := DoorData.new()
	door.room_type = "combat"
	door.encounter_id = "skeleton"
	door.room_id = "room_4"

	var nav := NavigationState.new()
	nav.rooms_completed_this_floor = 4
	nav.segment_room_counts = {"combat": 3, "elite": 1}
	nav.doors_ahead.assign([door])
	nav.companion_offered_this_floor = true
	nav.event_type = ""
	nav.loot_offers.assign(["ointment", "rope_flail"])

	var enemy := EnemyState.new()
	enemy.enemy_id = "skeleton"
	enemy.instance_id = "skeleton_0"
	enemy.hp = 8
	enemy.max_hp = 10
	enemy.current_intent = "strike"
	enemy.intent_streak = 2

	var deck := OmenDeckState.new()
	deck.draw_pile.assign([{"card_id": "stillness", "timer_value": 2}])
	deck.discard_pile.assign([{"card_id": "burning", "timer_value": 4}])

	var cycle := OmenCycleState.new()
	cycle.drawn_cards.assign([{"card_id": "stillness", "timer_value": 2}])
	cycle.player_choice_index = 0
	cycle.timer_index = 2
	cycle.sides_assigned = true

	var combat := CombatState.new()
	combat.enemies.assign([enemy])
	combat.turn_number = 5
	combat.omen_deck = deck
	combat.current_cycle = cycle
	combat.pending_repent_slots.assign([0, 2])
	combat.read_the_road_active = false
	combat.pending_vulnerable_units.assign(["enemy_0"])

	var gs := GameState.new()
	gs.run_seed = 424242
	gs.vessel_state = vessel
	gs.inventory.assign([item, null])  # one item, one empty slot
	gs.temporary_companion = companion
	gs.floor_number = 3
	gs.run_phase = GameState.RunPhase.COMBAT
	gs.navigation_state = nav
	gs.combat_state = combat
	gs.item_burden_score = 3
	return gs


# In-memory Dictionary round-trip is identity (no stringify => ints stay ints).
# @Spec: LLD-ARCH-004
func test_in_memory_round_trip_identity() -> void:
	var gs := _make_full_state()
	var original := gs.to_json()
	var restored := GameState.from_json(original)
	assert_dict(restored.to_json()).is_equal(original)


# Field-level spot checks after round-trip.
func test_round_trip_field_fidelity() -> void:
	var gs := _make_full_state()
	var r := GameState.from_json(gs.to_json())
	assert_int(r.run_seed).is_equal(424242)
	assert_int(r.run_phase).is_equal(GameState.RunPhase.COMBAT)
	assert_str(r.vessel_state.vessel_id).is_equal("pilgrim")
	assert_int(r.vessel_state.hp).is_equal(20)
	assert_bool(r.vessel_state.is_evading).is_true()
	assert_str(r.vessel_state.active_statuses[0].string_param).is_equal("fire")
	assert_int(r.combat_state.enemies[0].hp).is_equal(8)
	assert_array(r.combat_state.pending_repent_slots).is_equal([0, 2])
	assert_int(r.item_burden_score).is_equal(3)


# JSON-text round-trip: numbers survive as ints (from_json casts JSON floats).
# This is the save-file path through PersistenceService. @Spec: LLD-ARCH-017
func test_json_text_round_trip_casts_ints() -> void:
	var gs := _make_full_state()
	var text := JSON.stringify(gs.to_json())
	var parsed: Dictionary = JSON.parse_string(text)
	var r := GameState.from_json(parsed)

	assert_int(typeof(r.vessel_state.hp)).is_equal(TYPE_INT)
	assert_int(r.vessel_state.hp).is_equal(20)
	assert_int(typeof(r.floor_number)).is_equal(TYPE_INT)
	# Nested int inside an omen entry survives as int (Serde.omen_entries casts).
	assert_int(typeof(r.combat_state.omen_deck.draw_pile[0]["timer_value"])).is_equal(TYPE_INT)
	assert_int(r.combat_state.omen_deck.draw_pile[0]["timer_value"]).is_equal(2)
	# segment_room_counts values cast back to int.
	assert_int(typeof(r.navigation_state.segment_room_counts["combat"])).is_equal(TYPE_INT)


# Inventory null (empty) slots are preserved through serialisation.
# @Spec: LLD-ARCH-017
func test_inventory_null_slots_preserved() -> void:
	var r := GameState.from_json(_make_full_state().to_json())
	assert_int(r.inventory.size()).is_equal(2)
	assert_object(r.inventory[0]).is_not_null()
	assert_str(r.inventory[0].item_id).is_equal("walking_staff")
	assert_object(r.inventory[1]).is_null()


# clone() produces a deeply independent copy — mutating the clone never touches
# the original. @Spec: LLD-ARCH-004
func test_clone_independence() -> void:
	var gs := _make_full_state()
	var c := gs.clone()

	c.vessel_state.hp = 999
	c.vessel_state.active_statuses[0].magnitude = 999
	c.inventory[0].remaining_charges = 999
	c.combat_state.enemies[0].hp = 999
	c.combat_state.omen_deck.draw_pile[0]["timer_value"] = 999
	c.navigation_state.segment_room_counts["combat"] = 999
	c.temporary_companion.companion_context["note"] = "MUTATED"
	c.item_burden_score = 999

	assert_int(gs.vessel_state.hp).is_equal(20)
	assert_int(gs.vessel_state.active_statuses[0].magnitude).is_equal(0)
	assert_int(gs.inventory[0].remaining_charges).is_equal(6)
	assert_int(gs.combat_state.enemies[0].hp).is_equal(8)
	assert_int(gs.combat_state.omen_deck.draw_pile[0]["timer_value"]).is_equal(2)
	assert_int(gs.navigation_state.segment_room_counts["combat"]).is_equal(3)
	assert_str(gs.temporary_companion.companion_context["note"]).is_equal("temp")
	assert_int(gs.item_burden_score).is_equal(3)


# Null sub-resources round-trip as null (not empty objects).
func test_null_subresources_round_trip() -> void:
	var gs := GameState.new()  # everything default/null
	var r := GameState.from_json(gs.to_json())
	assert_object(r.vessel_state).is_null()
	assert_object(r.combat_state).is_null()
	assert_object(r.bound_companion).is_null()
	assert_object(r.navigation_state).is_null()


# Default field values match the spec (RunPhase default, reset flags, sentinels).
func test_defaults() -> void:
	var gs := GameState.new()
	assert_int(gs.run_phase).is_equal(GameState.RunPhase.NAVIGATION)
	assert_array(gs.inventory).is_empty()
	assert_int(gs.item_burden_score).is_equal(0)

	var v := VesselState.new()
	assert_bool(v.is_evading).is_false()
	assert_bool(v.is_stunned).is_false()

	var s := StatusInstance.new()
	assert_str(s.trigger).is_equal("tick")
	assert_str(s.string_param).is_equal("")

	var cyc := OmenCycleState.new()
	assert_int(cyc.player_choice_index).is_equal(-1)
	assert_int(cyc.random_assignment_index).is_equal(-1)


# RunPhase enum has the six phases in the spec order.
func test_runphase_enum_values() -> void:
	assert_int(GameState.RunPhase.NAVIGATION).is_equal(0)
	assert_int(GameState.RunPhase.COMBAT).is_equal(1)
	assert_int(GameState.RunPhase.LOOT_SELECTION).is_equal(2)
	assert_int(GameState.RunPhase.NON_COMBAT_EVENT).is_equal(3)
	assert_int(GameState.RunPhase.FLOOR_TRANSITION).is_equal(4)
	assert_int(GameState.RunPhase.RUN_END).is_equal(5)
