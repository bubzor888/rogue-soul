# T8.3 content regression: the Floor 3 non-boss enemies load from data/enemies/
# through the live ContentRegistry autoload and match LLD-ENEMIES-004..-008/-014..-020
# (HP, damage type, resistances/vulnerabilities, tags, encounter counts, intents,
# conditionals, on-death). Also verifies every enemy referenced by the Floor 3
# profile pools resolves.
# @Spec: LLD-ENEMIES-002, LLD-ENEMIES-004, LLD-ENEMIES-005, LLD-ENEMIES-006, LLD-ENEMIES-007, LLD-ENEMIES-008, LLD-ENEMIES-014, LLD-ENEMIES-015, LLD-ENEMIES-016, LLD-ENEMIES-017, LLD-ENEMIES-018, LLD-ENEMIES-019, LLD-ENEMIES-020
extends GdUnitTestSuite


func _intent(e: EnemyData, id: String) -> IntentWeight:
	for w in e.intent_weights:
		if w.intent_id == id:
			return w
	return null


func test_all_floor3_non_boss_enemies_load() -> void:
	for id in ["skeleton", "zombie", "plague_rat", "wolf", "bear", "fire_elemental",
			"ice_elemental", "lightning_elemental", "lightning_spark",
			"low_hp_fanatic", "high_hp_fanatic", "buff_totem", "absorption_totem"]:
		assert_object(ContentRegistry.get_enemy(id)) \
			.override_failure_message("Enemy '%s' did not load" % id).is_not_null()


func test_skeleton() -> void:
	var e: EnemyData = ContentRegistry.get_enemy("skeleton")
	assert_int(e.max_hp).is_equal(12)
	assert_array(e.vulnerabilities).is_equal(["fire"])     # innate fire vulnerability
	assert_array(e.enemy_tags).is_equal(["undead"])
	assert_int(e.pre_elite_count).is_equal(1)
	assert_int(e.post_elite_count).is_equal(2)
	assert_int(_intent(e, "strike").weight).is_equal(70)
	assert_int(_intent(e, "strike").damage_min).is_equal(4)
	assert_str(_intent(e, "chill_touch").status_apply).is_equal("chilled")


func test_zombie_slam_is_charge_release() -> void:
	var e: EnemyData = ContentRegistry.get_enemy("zombie")
	assert_int(e.max_hp).is_equal(16)
	assert_bool(_intent(e, "slam").is_charge_release).is_true()
	assert_int(_intent(e, "slam").max_consecutive).is_equal(1)


func test_plague_rat_pack_and_on_death_poison() -> void:
	var e: EnemyData = ContentRegistry.get_enemy("plague_rat")
	assert_int(e.max_hp).is_equal(3)
	assert_int(e.pre_elite_count).is_equal(3)
	assert_str(e.on_death_apply_to_player).is_equal("poisoned")
	assert_int(e.on_death_apply_magnitude).is_equal(2)


func test_wolf_pack_lone_conditionals() -> void:
	var e: EnemyData = ContentRegistry.get_enemy("wolf")
	assert_int(e.pre_elite_count).is_equal(2)
	assert_int(e.post_elite_count).is_equal(3)
	assert_str(_intent(e, "howl").summon_enemy_id).is_equal("wolf")
	var conds := {}
	for c in e.intent_conditionals:
		conds[c.condition] = c.intent_ids
	assert_array(conds["ally_count_above:0"]).is_equal(["bite_pack", "evade"])
	assert_array(conds["ally_count_equals:0"]).is_equal(["bite_lone", "howl"])


func test_bear_sleeps_turn_one_and_frenzies() -> void:
	var e: EnemyData = ContentRegistry.get_enemy("bear")
	assert_int(e.max_hp).is_equal(22)
	assert_int(_intent(e, "swipe").hit_count).is_equal(2)         # two independent hits
	assert_str(_intent(e, "frenzy").status_apply).is_equal("frenzied")
	assert_str(_intent(e, "frenzy").status_target).is_equal("self")
	var forced := {}
	for c in e.intent_conditionals:
		forced[c.condition] = c.intent_id
	assert_str(forced["turn_number:1"]).is_equal("sleeping")


func test_elementals_resist_and_vuln() -> void:
	var fire: EnemyData = ContentRegistry.get_enemy("fire_elemental")
	assert_array(fire.resistances).is_equal(["fire"])
	assert_array(fire.vulnerabilities).is_equal(["ice"])
	var ice: EnemyData = ContentRegistry.get_enemy("ice_elemental")
	assert_array(ice.resistances).is_equal(["ice"])
	assert_array(ice.vulnerabilities).is_equal(["fire"])


func test_lightning_elemental_two_phase() -> void:
	var e: EnemyData = ContentRegistry.get_enemy("lightning_elemental")
	assert_int(e.max_hp).is_equal(18)
	assert_array(e.resistances).is_equal(["lightning"])
	assert_array(e.on_death_summons).is_equal(["lightning_spark", "lightning_spark"])
	# Turn-gated escalation via conditionals.
	var forced := {}
	for c in e.intent_conditionals:
		forced[c.condition] = c.intent_id
	assert_str(forced["turn_number:1"]).is_equal("lightning_surge_1")
	# Spark: dormant on its first turn, no omen contributions.
	var spark: EnemyData = ContentRegistry.get_enemy("lightning_spark")
	assert_int(spark.max_hp).is_equal(6)
	assert_int(spark.omen_contributions.size()).is_equal(0)


func test_totems_buff_allies_no_omen() -> void:
	var buff: EnemyData = ContentRegistry.get_enemy("buff_totem")
	assert_int(buff.omen_contributions.size()).is_equal(0)
	assert_str(_intent(buff, "embolden_allies").status_apply).is_equal("emboldened:physical")
	assert_str(_intent(buff, "embolden_allies").status_target).is_equal("allies")
	var absorb: EnemyData = ContentRegistry.get_enemy("absorption_totem")
	assert_str(_intent(absorb, "harden_allies").status_apply).is_equal("hardened")
	assert_int(_intent(absorb, "harden_allies").status_magnitude).is_equal(3)


# Every enemy the Floor 3 profile draws from must resolve in the registry.
func test_floor3_pool_enemies_resolve() -> void:
	var profile: FloorProfile = ContentRegistry.get_floor_by_number(3)
	assert_object(profile).is_not_null()
	for id in profile.normal_enemy_pool + profile.elite_enemy_pool:
		assert_object(ContentRegistry.get_enemy(id)) \
			.override_failure_message("Floor 3 pool enemy '%s' did not resolve" % id).is_not_null()
	# The boss is authored in T8.4.
	assert_object(ContentRegistry.get_enemy(profile.boss_enemy_id)) \
		.override_failure_message("Boss '%s' did not resolve" % profile.boss_enemy_id).is_not_null()
