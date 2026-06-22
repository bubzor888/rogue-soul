# @Spec: LLD-ARCH-005, LLD-ARCH-012
#
# AbilityHandler — base class for one link in an ability/item/omen/intent handler
# chain. Subclasses override apply() to perform an effect on the context's
# GameState. Domain layer (RefCounted).
#
# Naming convention (LLD-ARCH-012): a handler's registered id is derived from its
# class's global name — strip the trailing "Handler", convert PascalCase to
# snake_case (e.g. DealDamageHandler -> "deal_damage"). Deriving the id (rather
# than declaring it separately) makes the convention impossible to violate.
class_name AbilityHandler
extends RefCounted


# Perform this handler's effect, mutating ctx.game_state. Override in subclasses.
func apply(_ctx: AbilityContext) -> void:
	push_error("AbilityHandler.apply() not implemented for '%s'" % get_handler_id())


# The handler_id this handler registers under. Derived from the class global name.
# Subclasses without a global name (e.g. test inner classes) may override.
func get_handler_id() -> String:
	return derive_handler_id(get_script().get_global_name())


# Strip a trailing "Handler" and convert PascalCase to snake_case.
# "DealDamageHandler" -> "deal_damage". @Spec: LLD-ARCH-012
static func derive_handler_id(global_name: String) -> String:
	var base := global_name
	if base.ends_with("Handler"):
		base = base.substr(0, base.length() - "Handler".length())
	return _pascal_to_snake(base)


static func _pascal_to_snake(s: String) -> String:
	var out := ""
	for i in s.length():
		var ch := s[i]
		if ch >= "A" and ch <= "Z":
			if i > 0:
				out += "_"
			out += ch.to_lower()
		else:
			out += ch
	return out
