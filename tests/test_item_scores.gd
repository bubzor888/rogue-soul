# T8.7 — item score sanity pass. Pins every MVP1 item's authored `score` (in its
# shipped .tres, read via ContentRegistry) to the canonical value in LLD-IR-011, and
# asserts vessel abilities carry score 0 (never traded, LLD-ARCH-018). Guards against
# score drift as items are re-authored.
# @Spec: LLD-ITEMS-011, LLD-ARCH-018, HLD-ITEMS-006, HLD-ITEMS-007, HLD-ITEMS-008
extends GdUnitTestSuite


# Canonical scores from LLD-IR-011 (the item ranking table is authoritative; the
# formula columns there derive these values).
const ITEM_SCORES := {
	# Pilgrim starting items (LLD-ITEMS-004)
	"walking_staff": 42, "spoiled_potion": 15, "worn_map": 28,
	# Normal durability (LLD-ITEMS-005)
	"cracked_cudgel": 41, "rope_flail": 61, "battered_sword": 49,
	"ember_shard": 39, "spark_rod": 39, "frost_sliver": 39, "small_amethyst": 16,
	# Normal consumable (LLD-ITEMS-007)
	"fire_bomb": 14, "ointment": 10, "combustible_oil": 17, "hardening_resin": 12, "frost_shard": 12,
	# Elite durability (LLD-ITEMS-006)
	"iron_maul": 70, "spiked_chain": 86, "soldiers_blade": 85, "smoldering_brand": 89,
	"arc_wand": 108, "glacial_brand": 89, "medium_amethyst": 28,
	# Elite consumable (LLD-ITEMS-008)
	"poultice": 13, "brittle_charm": 18, "fulminating_powder": 16,
}

const VESSEL_ABILITIES := ["throw_rock", "read_the_road", "good_as_new"]


func test_every_item_score_matches_lld_ir_011() -> void:
	for item_id in ITEM_SCORES:
		var a: AbilityData = ContentRegistry.get_ability(item_id)
		assert_object(a).override_failure_message("item '%s' not found" % item_id).is_not_null()
		assert_int(a.score) \
			.override_failure_message("%s score %d != LLD-IR-011 %d" % [item_id, a.score, ITEM_SCORES[item_id]]) \
			.is_equal(ITEM_SCORES[item_id])


func test_items_are_marked_breaks_at_zero() -> void:
	# Every droppable/starting item is an AbilityData with breaks_at_zero true (LLD-ARCH-018).
	for item_id in ITEM_SCORES:
		assert_bool(ContentRegistry.get_ability(item_id).breaks_at_zero) \
			.override_failure_message("%s is not breaks_at_zero" % item_id).is_true()


func test_vessel_abilities_score_zero() -> void:
	# Vessel abilities are never traded → score 0 (LLD-ARCH-018).
	for ability_id in VESSEL_ABILITIES:
		var a: AbilityData = ContentRegistry.get_ability(ability_id)
		assert_int(a.score).override_failure_message("%s should score 0" % ability_id).is_equal(0)
		assert_bool(a.breaks_at_zero).override_failure_message("%s is an ability, not an item" % ability_id).is_false()
