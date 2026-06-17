# Verifies the data resource schemas (T2.1, LLD-ARCH-018) compile, instantiate,
# carry the spec-defined defaults, and accept nested typed-array assignment.
# @Spec: LLD-ARCH-018, LLD-ARCH-006
extends GdUnitTestSuite


func test_handler_config_defaults() -> void:
	var h := HandlerConfig.new()
	assert_str(h.handler_id).is_equal("")
	assert_dict(h.params).is_equal({})


func test_ability_data_defaults() -> void:
	var a := AbilityData.new()
	assert_str(a.ability_id).is_equal("")
	assert_str(a.action_bucket).is_equal("")
	assert_int(a.max_charges).is_equal(0)
	assert_bool(a.breaks_at_zero).is_false()
	assert_int(a.score).is_equal(0)
	assert_array(a.replenish_triggers).is_empty()
	assert_array(a.handlers).is_empty()


func test_vessel_data_defaults() -> void:
	var v := VesselData.new()
	assert_str(v.vessel_id).is_equal("")
	assert_int(v.max_hp).is_equal(0)
	assert_str(v.default_strike_id).is_equal("")
	assert_str(v.bound_companion_id).is_equal("")
	assert_array(v.ability_ids).is_empty()
	assert_array(v.starting_item_ids).is_empty()
	assert_array(v.omen_contributions).is_empty()


func test_enemy_data_defaults() -> void:
	var e := EnemyData.new()
	assert_str(e.enemy_id).is_equal("")
	assert_int(e.max_hp).is_equal(0)
	assert_str(e.damage_type).is_equal("")
	assert_str(e.on_death_apply_to_player).is_equal("")
	assert_int(e.on_death_apply_magnitude).is_equal(0)
	assert_array(e.resistances).is_empty()
	assert_array(e.enemy_tags).is_empty()
	assert_array(e.intent_weights).is_empty()
	assert_array(e.intent_conditionals).is_empty()
	assert_array(e.on_death_summons).is_empty()


# Non-default values from the spec must be honoured.
func test_intent_weight_defaults() -> void:
	var w := IntentWeight.new()
	assert_int(w.weight).is_equal(0)
	assert_int(w.hit_count).is_equal(1)          # spec default 1, not 0
	assert_str(w.status_target).is_equal("player")  # spec default "player"
	assert_bool(w.is_charge_release).is_false()
	assert_bool(w.is_evade).is_false()
	assert_int(w.max_consecutive).is_equal(0)
	assert_str(w.status_apply).is_equal("")
	assert_int(w.status_magnitude).is_equal(0)
	assert_str(w.summon_enemy_id).is_equal("")
	assert_array(w.handlers).is_empty()


func test_intent_conditional_defaults() -> void:
	var c := IntentConditional.new()
	assert_str(c.condition).is_equal("")
	assert_str(c.intent_id).is_equal("")
	assert_array(c.intent_ids).is_empty()


func test_omen_card_data_defaults() -> void:
	var o := OmenCardData.new()
	assert_str(o.card_id).is_equal("")
	assert_str(o.status_id).is_equal("")
	assert_int(o.status_magnitude).is_equal(0)
	assert_str(o.requires_tag).is_equal("")
	assert_array(o.handlers).is_empty()


func test_companion_data_defaults() -> void:
	var c := CompanionData.new()
	assert_str(c.companion_id).is_equal("")
	assert_str(c.trigger).is_equal("")
	assert_str(c.granted_ability_id).is_equal("")
	assert_int(c.initial_timer).is_equal(0)
	assert_str(c.departure_trigger).is_equal("")
	assert_array(c.omen_contributions).is_empty()
	assert_array(c.handlers).is_empty()


# Nested typed arrays accept the correct Resource types (the engine/.tres contract).
func test_nested_typed_arrays() -> void:
	var handler := HandlerConfig.new()
	handler.handler_id = "deal_damage"
	handler.params = {"base_damage": 6, "damage_type": "physical"}

	var ability := AbilityData.new()
	ability.handlers.append(handler)
	assert_int(ability.handlers.size()).is_equal(1)
	assert_str(ability.handlers[0].handler_id).is_equal("deal_damage")

	var intent := IntentWeight.new()
	intent.intent_id = "bite"
	var enemy := EnemyData.new()
	enemy.intent_weights.append(intent)
	enemy.intent_conditionals.append(IntentConditional.new())
	assert_int(enemy.intent_weights.size()).is_equal(1)
	assert_str(enemy.intent_weights[0].intent_id).is_equal("bite")
	assert_int(enemy.intent_conditionals.size()).is_equal(1)


# Schemas are domain Resources (no Node), per the layer rule.
func test_schemas_are_resources() -> void:
	assert_bool(AbilityData.new() is Resource).is_true()
	assert_bool(EnemyData.new() is Resource).is_true()
	assert_bool(OmenCardData.new() is Resource).is_true()
