# T8.6 content regression: the Floor 3 drop-pool items load from data/items/ through
# the live ContentRegistry and match LLD-ITEMS-005..-008 (buckets, charges, effects,
# scores LLD-IR-011). Also confirms LootGenerator draws one durability + one
# consumable from the correct tier pool against real content.
# @Spec: LLD-ITEMS-005, LLD-ITEMS-006, LLD-ITEMS-007, LLD-ITEMS-008, LLD-ARCH-022
extends GdUnitTestSuite


func _item(id: String) -> AbilityData:
	return ContentRegistry.get_ability(id)


# Every item the Floor 3 profile can drop resolves, and all their handlers are known.
func test_all_floor3_pool_items_resolve() -> void:
	var profile: FloorProfile = ContentRegistry.get_floor_by_number(3)
	var known := AbilityPipeline.default_handler_ids()
	var pools := profile.normal_durability_pool + profile.normal_consumable_pool \
		+ profile.elite_durability_pool + profile.elite_consumable_pool
	for id in pools:
		var a := _item(id)
		assert_object(a).override_failure_message("Loot item '%s' did not resolve" % id).is_not_null()
		for hc in a.handlers:
			assert_bool(hc.handler_id in known) \
				.override_failure_message("Unknown handler '%s' in %s" % [hc.handler_id, id]).is_true()


func test_normal_weapons() -> void:
	var cudgel := _item("cracked_cudgel")
	assert_str(cudgel.action_bucket).is_equal("attack")
	assert_int(cudgel.max_charges).is_equal(3)
	assert_int(cudgel.score).is_equal(41)
	assert_int(int(cudgel.handlers[0].params["base_damage"])).is_equal(9)
	# Rope Flail hits all enemies.
	assert_str(str(_item("rope_flail").handlers[0].params.get("mode", ""))).is_equal("all")


func test_arc_wand_arc_params() -> void:
	var aw := _item("arc_wand")
	assert_int(aw.score).is_equal(108)
	var p := aw.handlers[0].params
	assert_str(str(p["mode"])).is_equal("arc")
	assert_int(int(p["base_damage"])).is_equal(9)
	assert_int(int(p["arc_damage"])).is_equal(4)


func test_consumables_effects() -> void:
	assert_str(_item("fire_bomb").handlers[0].handler_id).is_equal("apply_status")
	assert_int(int(_item("fire_bomb").handlers[0].params["magnitude"])).is_equal(5)
	assert_str(_item("combustible_oil").handlers[0].handler_id).is_equal("combustible_oil")
	assert_str(str(_item("poultice").handlers[0].params["target"])).is_equal("self")  # heals player
	assert_str(str(_item("brittle_charm").handlers[0].params["status_id"])).is_equal("vulnerable:physical")


func test_amethysts_cleanse() -> void:
	for id in ["small_amethyst", "medium_amethyst"]:
		var a := _item(id)
		assert_str(a.action_bucket).is_equal("support")
		assert_str(a.handlers[0].handler_id).is_equal("cleanse_status")
	assert_int(_item("small_amethyst").max_charges).is_equal(1)
	assert_int(_item("medium_amethyst").max_charges).is_equal(2)


# LootGenerator draws one durability + one consumable from the correct tier pool
# against real Floor 3 content. @Spec: LLD-ARCH-022, HLD-COMBAT-012, -013
func test_loot_generator_draws_correct_tiers() -> void:
	var profile: FloorProfile = ContentRegistry.get_floor_by_number(3)
	RNGService.seed_run(123)
	var gen := LootGenerator.new(RNGService, ContentRegistry)
	var gs := GameState.new()
	gs.floor_number = 3
	# Normal tier: one from normal_durability + one from normal_consumable.
	var normal: Array = gen.generate_loot_offers(gs, false)
	assert_int(normal.size()).is_equal(2)
	assert_bool(normal[0] in profile.normal_durability_pool).is_true()
	assert_bool(normal[1] in profile.normal_consumable_pool).is_true()
	# Elite tier: from the elite pools.
	var elite: Array = gen.generate_loot_offers(gs, true)
	assert_bool(elite[0] in profile.elite_durability_pool).is_true()
	assert_bool(elite[1] in profile.elite_consumable_pool).is_true()
