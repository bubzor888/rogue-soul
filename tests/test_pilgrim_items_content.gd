# T8.2 content regression: the Pilgrim's three starting items load from data/items/
# through the live ContentRegistry autoload and match LLD-ITEMS-004 (shapes/effects)
# and LLD-IR-011 (scores). Confirms every Pilgrim starting item now resolves (the
# T8.1 references are satisfied) and their handlers are known to the pipeline.
# @Spec: LLD-ITEMS-004, LLD-ITEMS-011, LLD-VESSELS-001
extends GdUnitTestSuite


func _first_handler(a: AbilityData) -> HandlerConfig:
	return a.handlers[0]


func test_walking_staff() -> void:
	var a: AbilityData = ContentRegistry.get_ability("walking_staff")
	assert_object(a).is_not_null()
	assert_str(a.action_bucket).is_equal("attack")
	assert_int(a.max_charges).is_equal(6)
	assert_bool(a.breaks_at_zero).is_true()
	assert_int(a.score).is_equal(42)                              # LLD-IR-011
	assert_str(_first_handler(a).handler_id).is_equal("deal_damage")
	assert_int(int(_first_handler(a).params.get("base_damage", 0))).is_equal(6)


func test_spoiled_potion() -> void:
	var a: AbilityData = ContentRegistry.get_ability("spoiled_potion")
	assert_object(a).is_not_null()
	assert_str(a.action_bucket).is_equal("consumable")
	assert_int(a.max_charges).is_equal(1)
	assert_int(a.score).is_equal(15)                              # LLD-IR-011
	var h := _first_handler(a)
	assert_str(h.handler_id).is_equal("apply_status")
	assert_str(str(h.params.get("status_id", ""))).is_equal("poisoned")
	assert_int(int(h.params.get("magnitude", 0))).is_equal(2)    # starting X = 2


func test_worn_map_encounter_countdown() -> void:
	var a: AbilityData = ContentRegistry.get_ability("worn_map")
	assert_object(a).is_not_null()
	assert_str(a.action_bucket).is_equal("support")
	assert_int(a.max_charges).is_equal(3)
	assert_bool(a.breaks_at_zero).is_true()
	assert_bool(a.is_encounter_countdown).is_true()              # HLD-ITEMS-003
	assert_str(a.triggered_room_type).is_equal("companion")
	assert_int(a.score).is_equal(28)                             # LLD-IR-011
	assert_int(a.handlers.size()).is_equal(0)                    # passive countdown, no active effect


# Every starting item the Pilgrim references (T8.1) now resolves, and all their
# handlers are known to the pipeline (the boot validator's invariant).
func test_pilgrim_starting_items_all_resolve() -> void:
	var p: VesselData = ContentRegistry.get_vessel("pilgrim")
	var known := AbilityPipeline.default_handler_ids()
	assert_array(p.starting_item_ids).is_equal(["walking_staff", "spoiled_potion", "worn_map"])
	for item_id in p.starting_item_ids:
		var a: AbilityData = ContentRegistry.get_ability(item_id)
		assert_object(a) \
			.override_failure_message("Starting item '%s' did not resolve" % item_id) \
			.is_not_null()
		for hc in a.handlers:
			assert_bool(hc.handler_id in known) \
				.override_failure_message("Unknown handler '%s' in %s" % [hc.handler_id, item_id]) \
				.is_true()
