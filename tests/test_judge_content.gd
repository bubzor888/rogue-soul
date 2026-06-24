# T8.4 content regression: The Judge boss + two Witnesses + Repent card load from
# data/ through the live ContentRegistry and match LLD-ENEMIES-010/-021/-022 and
# LLD-OMEN-CARD-020 (mixed composition, required-kill, Repent ×3, Pass Judgment
# conditional, tier-based Witness handlers).
# @Spec: LLD-ENEMIES-010, LLD-ENEMIES-021, LLD-ENEMIES-022, LLD-OMEN-CARD-020, HLD-RUN-004
extends GdUnitTestSuite


func _intent(e: EnemyData, id: String) -> IntentWeight:
	for w in e.intent_weights:
		if w.intent_id == id:
			return w
	return null


func test_judge_composition_and_required_kill() -> void:
	var j: EnemyData = ContentRegistry.get_enemy("the_judge")
	assert_object(j).is_not_null()
	assert_int(j.max_hp).is_equal(30)
	assert_array(j.enemy_tags).is_equal(["judge"])
	assert_array(j.accompanied_by).is_equal(["witness_of_mercy", "witness_of_vengeance"])
	assert_bool(j.ends_combat_on_death).is_true()              # only required kill


func test_judge_repent_x3_direct_contribution() -> void:
	var j: EnemyData = ContentRegistry.get_enemy("the_judge")
	assert_int(j.omen_contributions.size()).is_equal(0)        # not via two-tier
	assert_array(j.direct_omen_contributions).is_equal(["repent", "repent", "repent"])
	# Repent card resolves and is inert by data (the resolver special-cases it).
	var repent: OmenCardData = ContentRegistry.get_omen_card("repent")
	assert_object(repent).is_not_null()
	assert_str(repent.status_id).is_equal("")
	assert_int(repent.handlers.size()).is_equal(0)


func test_judge_intents_and_pass_judgment() -> void:
	var j: EnemyData = ContentRegistry.get_enemy("the_judge")
	assert_int(_intent(j, "strike").weight).is_equal(50)
	assert_str(_intent(j, "suffer").status_apply).is_equal("bleed")
	assert_int(_intent(j, "suffer").status_magnitude).is_equal(3)
	assert_bool(_intent(j, "ponder").is_evade).is_true()
	# Pass Judgment: forced ≤30% HP, charge→release.
	assert_bool(_intent(j, "pass_judgment").is_charge_release).is_true()
	var forced := {}
	for c in j.intent_conditionals:
		forced[c.condition] = c.intent_id
	assert_str(forced["hp_percent_lte:30"]).is_equal("pass_judgment")


func test_witness_of_mercy() -> void:
	var m: EnemyData = ContentRegistry.get_enemy("witness_of_mercy")
	assert_int(m.max_hp).is_equal(10)
	assert_str(m.on_death_apply_to_player).is_equal("vulnerable:physical")
	var t := _intent(m, "testify_mercy")
	assert_str(t.status_target).is_equal("allies")            # heals The Judge
	assert_str(t.handlers[0].handler_id).is_equal("apply_mending_by_burden_tier")
	# Default status (no status_id param) = Mending; High-tier magnitude 5.
	var tiers: Array = t.handlers[0].params["tiers"]
	assert_int(int(tiers[2]["magnitude"])).is_equal(5)


func test_witness_of_vengeance() -> void:
	var v: EnemyData = ContentRegistry.get_enemy("witness_of_vengeance")
	assert_str(v.on_death_apply_to_player).is_equal("frenzied")
	var t := _intent(v, "testify_vengeance")
	assert_str(str(t.handlers[0].params.get("status_id", ""))).is_equal("emboldened:physical")
	var tiers: Array = t.handlers[0].params["tiers"]
	assert_int(int(tiers[2]["magnitude"])).is_equal(3)        # High-tier Emboldened +3


# The Floor 3 boss now resolves (was null before T8.4).
func test_floor3_boss_resolves() -> void:
	var profile: FloorProfile = ContentRegistry.get_floor_by_number(3)
	assert_object(ContentRegistry.get_enemy(profile.boss_enemy_id)).is_not_null()
