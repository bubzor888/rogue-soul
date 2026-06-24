# T8.5 content regression: the omen cards load from data/omen_cards/ through the live
# ContentRegistry and match LLD-OMEN-CARD-001..-005/-011..-019. Also verifies the
# Floor 3 ambient deck (LLD-OMEN-CARD-008) and every enemy/Judge omen contribution
# now resolves to a real card.
# @Spec: LLD-OMEN-CARD-001, LLD-OMEN-CARD-002, LLD-OMEN-CARD-003, LLD-OMEN-CARD-004, LLD-OMEN-CARD-005, LLD-OMEN-CARD-008, LLD-OMEN-CARD-011, LLD-OMEN-CARD-012, LLD-OMEN-CARD-013, LLD-OMEN-CARD-014, LLD-OMEN-CARD-015, LLD-OMEN-CARD-016, LLD-OMEN-CARD-017, LLD-OMEN-CARD-018, LLD-OMEN-CARD-019
extends GdUnitTestSuite


func _card(id: String) -> OmenCardData:
	return ContentRegistry.get_omen_card(id)


func test_status_cards() -> void:
	assert_str(_card("burning").status_id).is_equal("burning")
	assert_int(_card("burning").status_magnitude).is_equal(5)
	assert_str(_card("shocked").status_id).is_equal("shocked")
	assert_str(_card("chilled").status_id).is_equal("chilled")
	assert_str(_card("mending").status_id).is_equal("mending")
	assert_int(_card("mending").status_magnitude).is_equal(3)
	assert_str(_card("emboldened_physical").status_id).is_equal("emboldened:physical")
	assert_int(_card("emboldened_physical").status_magnitude).is_equal(2)
	assert_str(_card("exposed").status_id).is_equal("exposed")


func test_elemental_vulnerable_and_emboldened_cards() -> void:
	for elem in ["fire", "lightning", "ice"]:
		assert_str(_card("vulnerable_%s" % elem).status_id).is_equal("vulnerable:%s" % elem)
		assert_str(_card("emboldened_%s" % elem).status_id).is_equal("emboldened:%s" % elem)


func test_enemy_family_type_cards() -> void:
	# Grave Knit heals undead only (Mending 5, tag-gated).
	var gk := _card("grave_knit")
	assert_str(gk.status_id).is_equal("mending")
	assert_int(gk.status_magnitude).is_equal(5)
	assert_str(gk.requires_tag).is_equal("undead")
	# Thick Hide: 3-per-hit reduction on beasts (realised as Hardened).
	var th := _card("thick_hide")
	assert_str(th.status_id).is_equal("hardened")
	assert_int(th.status_magnitude).is_equal(3)
	assert_str(th.requires_tag).is_equal("beast")


func test_elemental_synergy_type_convert() -> void:
	for elem in ["fire", "ice", "lightning"]:
		var c := _card("elemental_synergy_%s" % elem)
		assert_str(c.status_id).is_equal("type_convert:%s" % elem)
		assert_int(c.handlers.size()).is_equal(0)  # status-only, no custom handler


func test_sacred_ground_inert_placeholder() -> void:
	# MVP1 placeholder — no totems in the Floor 3 pool; doubling handler is MVP3.
	var sg := _card("sacred_ground")
	assert_object(sg).is_not_null()
	assert_str(sg.status_id).is_equal("")
	assert_int(sg.handlers.size()).is_equal(0)


func test_floor3_ambient_deck_resolves() -> void:
	var profile: FloorProfile = ContentRegistry.get_floor_by_number(3)
	assert_int(profile.ambient_omen_cards.size()).is_equal(12)   # LLD-OMEN-CARD-008
	for id in profile.ambient_omen_cards:
		assert_object(_card(id)) \
			.override_failure_message("Ambient card '%s' did not resolve" % id).is_not_null()


# Every omen card any Floor 3 enemy (and the Judge) contributes now resolves.
func test_all_enemy_omen_contributions_resolve() -> void:
	var ids := ["skeleton", "zombie", "plague_rat", "wolf", "bear", "fire_elemental",
		"ice_elemental", "lightning_elemental", "low_hp_fanatic", "high_hp_fanatic",
		"the_judge"]
	for enemy_id in ids:
		var e: EnemyData = ContentRegistry.get_enemy(enemy_id)
		for card_id in e.omen_contributions + e.direct_omen_contributions:
			assert_object(_card(str(card_id))) \
				.override_failure_message("%s contributes unresolved card '%s'" % [enemy_id, card_id]) \
				.is_not_null()
