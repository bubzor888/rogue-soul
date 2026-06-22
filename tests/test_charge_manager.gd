# Tests for ChargeManager (T3.1): replenishment, the durability decrement
# asymmetry (Walking Staff per-use vs Worn Map per-encounter), break-at-zero flagging.
# @Spec: LLD-ARCH-011, LLD-ARCH-016, HLD-ITEMS-004, HLD-ITEMS-005
extends GdUnitTestSuite


# --- AbilityData fixtures (the LLD content these rules act on) ---------------

func _ability(id: String, bucket: String, max_charges: int, breaks: bool, triggers: Array[String]) -> AbilityData:
	var a := AbilityData.new()
	a.ability_id = id
	a.action_bucket = bucket
	a.max_charges = max_charges
	a.breaks_at_zero = breaks
	a.replenish_triggers = triggers
	return a


# A catalog id -> AbilityData and the Callable lookup ChargeManager consumes.
func _catalog() -> Dictionary:
	return {
		# Walking Staff: attack durability, 6 charges, breaks at zero, no replenish.
		"walking_staff": _ability("walking_staff", ChargeManager.BUCKET_ATTACK, 6, true, []),
		# Worn Map: support durability, 3 charges, breaks at zero, no replenish.
		"worn_map": _ability("worn_map", ChargeManager.BUCKET_SUPPORT, 3, true, []),
		# Read the Road: vessel ability, 1 charge, never breaks, replenishes each encounter.
		"read_the_road": _ability("read_the_road", ChargeManager.BUCKET_PASSIVE, 1, false, ["encounter_start"] as Array[String]),
	}


func _manager(catalog: Dictionary) -> ChargeManager:
	return ChargeManager.new(func(id): return catalog.get(id, null))


func _item(id: String, charges: int) -> ItemInstance:
	var it := ItemInstance.new()
	it.item_id = id
	it.remaining_charges = charges
	return it


func _state_with_inventory(items: Array) -> GameState:
	var gs := GameState.new()
	gs.inventory.assign(items)
	return gs


# --- Replenishment ----------------------------------------------------------

func test_replenish_restores_matching_trigger() -> void:
	var cat := _catalog()
	var mgr := _manager(cat)
	var gs := GameState.new()
	gs.vessel_state = VesselState.new()
	var ast := AbilityState.new()
	ast.ability_id = "read_the_road"
	ast.remaining_charges = 0
	gs.vessel_state.ability_states.assign([ast])

	mgr.fire_replenish_event(gs, "encounter_start")
	assert_int(ast.remaining_charges).is_equal(1)  # restored to max_charges


func test_replenish_ignores_non_matching_trigger() -> void:
	var mgr := _manager(_catalog())
	var gs := GameState.new()
	gs.vessel_state = VesselState.new()
	var ast := AbilityState.new()
	ast.ability_id = "read_the_road"
	ast.remaining_charges = 0
	gs.vessel_state.ability_states.assign([ast])

	mgr.fire_replenish_event(gs, "floor_start")  # not in triggers
	assert_int(ast.remaining_charges).is_equal(0)


func test_replenish_applies_to_items_too() -> void:
	var cat := _catalog()
	cat["lucky_charm"] = _ability("lucky_charm", ChargeManager.BUCKET_SUPPORT, 2, false, ["floor_start"] as Array[String])
	var mgr := _manager(cat)
	var gs := _state_with_inventory([_item("lucky_charm", 0)])

	mgr.fire_replenish_event(gs, "floor_start")
	assert_int(gs.inventory[0].remaining_charges).is_equal(2)


# --- Decrement asymmetry ----------------------------------------------------

# Worn Map (Support durability) loses 1 per encounter regardless of activation.
func test_support_item_decrements_once_per_encounter() -> void:
	var mgr := _manager(_catalog())
	var gs := _state_with_inventory([_item("worn_map", 3)])

	mgr.decrement_support_items(gs)
	assert_int(gs.inventory[0].remaining_charges).is_equal(2)
	mgr.decrement_support_items(gs)
	mgr.decrement_support_items(gs)
	assert_int(gs.inventory[0].remaining_charges).is_equal(0)


# An attack item is NOT touched by the per-encounter support pass.
func test_attack_item_untouched_by_encounter_decrement() -> void:
	var mgr := _manager(_catalog())
	var gs := _state_with_inventory([_item("walking_staff", 6)])
	mgr.decrement_support_items(gs)
	assert_int(gs.inventory[0].remaining_charges).is_equal(6)


# Walking Staff (Attack durability) loses 1 per use only.
func test_attack_item_decrements_per_use() -> void:
	var mgr := _manager(_catalog())
	var staff := _item("walking_staff", 6)
	for _i in 3:
		mgr.decrement_on_use(staff)
	assert_int(staff.remaining_charges).is_equal(3)


func test_decrement_clamps_at_zero() -> void:
	var mgr := _manager(_catalog())
	var staff := _item("walking_staff", 1)
	mgr.decrement_on_use(staff)
	mgr.decrement_on_use(staff)  # already 0
	assert_int(staff.remaining_charges).is_equal(0)


# --- Break-at-zero flagging -------------------------------------------------

func test_decrement_on_use_reports_break() -> void:
	var mgr := _manager(_catalog())
	var staff := _item("walking_staff", 1)
	assert_bool(mgr.decrement_on_use(staff)).is_true()  # reached 0, breaks_at_zero


func test_support_decrement_returns_broken_slots() -> void:
	var mgr := _manager(_catalog())
	var gs := _state_with_inventory([_item("walking_staff", 6), _item("worn_map", 1)])
	var broke := mgr.decrement_support_items(gs)
	assert_array(broke).is_equal([1])  # worn_map at slot 1 hit 0


func test_get_broken_slots_scans_inventory() -> void:
	var mgr := _manager(_catalog())
	# worn_map at 0 (broken), walking_staff at 4 (fine), null slot.
	var gs := _state_with_inventory([_item("worn_map", 0), _item("walking_staff", 4), null])
	assert_array(mgr.get_broken_slots(gs)).is_equal([0])


func test_non_breaking_item_at_zero_not_flagged() -> void:
	var cat := _catalog()
	cat["eternal_charm"] = _ability("eternal_charm", ChargeManager.BUCKET_SUPPORT, 2, false, [] as Array[String])
	var mgr := _manager(cat)
	var gs := _state_with_inventory([_item("eternal_charm", 0)])
	assert_array(mgr.get_broken_slots(gs)).is_empty()


# --- Constants --------------------------------------------------------------

func test_replenish_event_constants() -> void:
	assert_str(ReplenishEvents.ENCOUNTER_START).is_equal("encounter_start")
	assert_str(ReplenishEvents.ENCOUNTER_END).is_equal("encounter_end")
	assert_str(ReplenishEvents.FLOOR_START).is_equal("floor_start")
	assert_str(ReplenishEvents.FLOOR_END).is_equal("floor_end")
