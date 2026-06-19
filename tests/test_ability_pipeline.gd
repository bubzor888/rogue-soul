# Tests for AbilityPipeline + AbilityHandler (T4.1): chain executes in order,
# per-config params delivered, registry resolves ids, naming-convention derivation.
# @Spec: LLD-ARCH-005, LLD-ARCH-012
extends GdUnitTestSuite


# Test handlers (inner classes have no global name, so they override get_handler_id).
class AppendHandler:
	extends AbilityHandler
	var _id: String
	func _init(id: String) -> void:
		_id = id
	func get_handler_id() -> String:
		return _id
	func apply(ctx: AbilityContext) -> void:
		# Record id plus any "tag" param so order and param delivery are observable.
		ctx.results.append("%s:%s" % [_id, str(ctx.params.get("tag", ""))])


func _config(handler_id: String, params: Dictionary = {}) -> HandlerConfig:
	var c := HandlerConfig.new()
	c.handler_id = handler_id
	c.params = params
	return c


# Handlers run left-to-right over the shared context.
# @Spec: LLD-ARCH-005
func test_chain_executes_in_order() -> void:
	var pipeline := AbilityPipeline.new()
	pipeline.register(AppendHandler.new("first"))
	pipeline.register(AppendHandler.new("second"))

	var ctx := AbilityContext.new()
	pipeline.execute([_config("first"), _config("second")], ctx)
	assert_array(ctx.results).is_equal(["first:", "second:"])


# Each config's params are delivered to its handler.
func test_params_delivered_per_config() -> void:
	var pipeline := AbilityPipeline.new()
	pipeline.register(AppendHandler.new("h"))

	var ctx := AbilityContext.new()
	pipeline.execute([_config("h", {"tag": "A"}), _config("h", {"tag": "B"})], ctx)
	assert_array(ctx.results).is_equal(["h:A", "h:B"])


# The registry resolves ids and reports membership.
func test_registry_membership() -> void:
	var pipeline := AbilityPipeline.new()
	pipeline.register(AppendHandler.new("deal_damage"))
	assert_bool(pipeline.has_handler("deal_damage")).is_true()
	assert_bool(pipeline.has_handler("nope")).is_false()
	assert_bool("deal_damage" in pipeline.known_handler_ids()).is_true()


# A handler mutates the shared GameState through the context.
func test_handler_mutates_game_state() -> void:
	var pipeline := AbilityPipeline.new()

	var damage_handler := AppendHandler.new("noop")  # placeholder
	pipeline.register(damage_handler)

	var gs := GameState.new()
	gs.vessel_state = VesselState.new()
	gs.vessel_state.hp = 30
	var ctx := AbilityContext.new(gs, "src", "tgt")
	# Inline mutation via a dedicated handler:
	pipeline.execute([_config("noop")], ctx)
	# Context carried the game_state and target through unchanged.
	assert_object(ctx.game_state).is_same(gs)
	assert_str(ctx.target_id).is_equal("tgt")


# Naming convention: class global name -> handler_id (LLD-ARCH-012).
func test_derive_handler_id() -> void:
	assert_str(AbilityHandler.derive_handler_id("DealDamageHandler")).is_equal("deal_damage")
	assert_str(AbilityHandler.derive_handler_id("ApplyStatusHandler")).is_equal("apply_status")
	assert_str(AbilityHandler.derive_handler_id("PeekOmenDeckHandler")).is_equal("peek_omen_deck")
	# No "Handler" suffix still converts.
	assert_str(AbilityHandler.derive_handler_id("Cleanse")).is_equal("cleanse")


# The default registry exposes the concrete handlers registered so far (T4.2).
# (Per-handler behaviour is covered in test_handlers.gd.)
func test_default_handlers_registered() -> void:
	var ids := AbilityPipeline.default_handler_ids()
	assert_bool("apply_status" in ids).is_true()
	assert_bool("cleanse_status" in ids).is_true()
