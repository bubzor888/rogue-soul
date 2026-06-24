# T8.1 content regression: the shipped Pilgrim vessel + abilities + Stillness load
# from data/ through the live ContentRegistry autoload, match LLD-VESSELS-001 /
# LLD-ABILITIES-003/-004/-005 / LLD-OMEN-CARD-006, and every handler they reference
# resolves in the AbilityPipeline (the same set ContentRegistry validates at boot).
# @Spec: LLD-VESSELS-001, LLD-ABILITIES-003, LLD-ABILITIES-004, LLD-ABILITIES-005, LLD-OMEN-CARD-006
extends GdUnitTestSuite


func _known_handlers() -> PackedStringArray:
	return AbilityPipeline.default_handler_ids()


func test_pilgrim_vessel_matches_spec() -> void:
	var p: VesselData = ContentRegistry.get_vessel("pilgrim")
	assert_object(p).is_not_null()
	assert_int(p.max_hp).is_equal(24)                              # LLD-VESSELS-001
	assert_str(p.default_strike_id).is_equal("throw_rock")
	assert_array(p.ability_ids).contains(["read_the_road", "good_as_new"])
	assert_str(p.bound_companion_id).is_equal("")                 # no companion
	# Pilgrim contributes exactly 2 copies of Stillness (LLD-OMEN-CARD-006).
	assert_array(p.omen_contributions).is_equal(["stillness", "stillness"])
	assert_int(p.starting_item_ids.size()).is_equal(3)           # LLD-ITEMS-004


func test_throw_rock_default_strike() -> void:
	var a: AbilityData = ContentRegistry.get_ability("throw_rock")
	assert_object(a).is_not_null()
	assert_str(a.action_bucket).is_equal("attack")
	assert_int(a.max_charges).is_equal(0)                         # unlimited
	assert_int(a.handlers.size()).is_equal(1)
	assert_str(a.handlers[0].handler_id).is_equal("deal_damage")
	assert_int(int(a.handlers[0].params.get("base_damage", 0))).is_equal(3)


func test_read_the_road_passive() -> void:
	var a: AbilityData = ContentRegistry.get_ability("read_the_road")
	assert_object(a).is_not_null()
	assert_str(a.action_bucket).is_equal("passive")              # auto-triggered, no bucket
	assert_str(a.handlers[0].handler_id).is_equal("peek_omen_deck")


func test_good_as_new_support_floor_replenish() -> void:
	var a: AbilityData = ContentRegistry.get_ability("good_as_new")
	assert_object(a).is_not_null()
	assert_str(a.action_bucket).is_equal("support")             # does not consume Attack
	assert_int(a.max_charges).is_equal(1)
	assert_array(a.replenish_triggers).is_equal(["floor_start"])
	assert_str(a.handlers[0].handler_id).is_equal("restore_item_charges")


func test_stillness_has_no_effect() -> void:
	var c: OmenCardData = ContentRegistry.get_omen_card("stillness")
	assert_object(c).is_not_null()
	assert_str(c.status_id).is_equal("")                         # does nothing on either side
	assert_int(c.handlers.size()).is_equal(0)


func test_all_pilgrim_handlers_resolve() -> void:
	var known := _known_handlers()
	for ability_id in ["throw_rock", "read_the_road", "good_as_new"]:
		var a: AbilityData = ContentRegistry.get_ability(ability_id)
		for hc in a.handlers:
			assert_bool(hc.handler_id in known) \
				.override_failure_message("Unknown handler '%s' in %s" % [hc.handler_id, ability_id]) \
				.is_true()
