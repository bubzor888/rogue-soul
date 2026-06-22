# @Spec: LLD-ARCH-005, LLD-ARCH-012
#
# AbilityPipeline — the Chain-of-Responsibility executor (LLD-ARCH-005). An
# ability/item/omen/intent is an ordered Array[HandlerConfig]; the pipeline runs
# each handler left-to-right over a shared AbilityContext. Handlers are resolved
# by handler_id from an internal registry. Domain layer (RefCounted).
class_name AbilityPipeline
extends RefCounted

var _handlers: Dictionary = {}  # handler_id -> AbilityHandler


# Register a handler under its derived id (LLD-ARCH-012). Duplicate ids are a bug.
func register(handler: AbilityHandler) -> void:
	var id := handler.get_handler_id()
	if _handlers.has(id):
		push_error("AbilityPipeline: duplicate handler id '%s'" % id)
		return
	_handlers[id] = handler


func has_handler(id: String) -> bool:
	return _handlers.has(id)


func known_handler_ids() -> PackedStringArray:
	return PackedStringArray(_handlers.keys())


# Run an ordered handler chain over a shared context, left to right. Each config's
# params are placed on the context before its handler runs. @Spec: LLD-ARCH-005
func execute(handler_configs: Array, ctx: AbilityContext) -> void:
	for config in handler_configs:
		var handler: AbilityHandler = _handlers.get(config.handler_id)
		if handler == null:
			# Should never happen post-validation (LLD-ARCH-005); guard defensively.
			push_error("AbilityPipeline: no handler registered for '%s'" % config.handler_id)
			continue
		ctx.params = config.params
		handler.apply(ctx)


# Build a pipeline with every concrete MVP1 handler registered. Used both
# per-resolver and for ContentRegistry's boot-time handler validation.
static func with_default_handlers() -> AbilityPipeline:
	var pipeline := AbilityPipeline.new()
	pipeline.register(DealDamageHandler.new())          # T5.2 — DamageCalculator 7-step pipeline
	pipeline.register(ApplyStatusHandler.new())
	pipeline.register(CleanseStatusHandler.new())
	pipeline.register(PeekOmenDeckHandler.new())
	pipeline.register(ApplyMendingByBurdenTierHandler.new())
	pipeline.register(RestoreItemChargesHandler.new())  # T8.1 — Good as New (content lookup via ctx.content)
	# Still sequenced to later (their core logic is that work):
	#   elemental_synergy / sacred_ground / combustible_oil — omen mechanics (T5.4) + content
	return pipeline


# The set of handler_ids the engine knows about — ContentRegistry validates every
# content handler_id against this at boot (LLD-ARCH-005).
static func default_handler_ids() -> PackedStringArray:
	return with_default_handlers().known_handler_ids()
