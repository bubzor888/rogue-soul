# @Spec: HLD-COMBAT-010, LLD-ITEMS-001, LLD-ITEMS-005, LLD-ITEMS-007
#
# CleanseStatusHandler ("cleanse_status") — category-scoped status removal. There
# is NO universal cleanse (HLD-COMBAT-010): each cleansing item lists exactly which
# statuses it clears (e.g. Amethyst clears Shocked/Chilled/Vulnerable(Physical);
# Ointment clears Burning/Poisoned). Params:
#   clears (Array of { status_id, string_param? }) — a status matches when its
#     status_id equals and, if string_param is given in the matcher, its
#     string_param equals too (so "vulnerable:physical" can be cleared without
#     touching "vulnerable:fire").
#   target ("source" | "self" | "target"; default "source" — you cleanse yourself).
class_name CleanseStatusHandler
extends AbilityHandler


func apply(ctx: AbilityContext) -> void:
	var matchers: Array = ctx.params.get("clears", [])
	if matchers.is_empty():
		return
	var unit_id := _resolve_target_id(ctx)
	var statuses := StatusRules.resolve_statuses(ctx.game_state, unit_id)
	var kept: Array = []
	for s in statuses:
		if not _matches_any(s, matchers):
			kept.append(s)
	statuses.assign(kept)


func _matches_any(status: StatusInstance, matchers: Array) -> bool:
	for m in matchers:
		var sid := str(m.get("status_id", ""))
		if status.status_id != sid:
			continue
		var sparam := str(m.get("string_param", ""))
		if sparam == "" or status.string_param == sparam:
			return true
	return false


func _resolve_target_id(ctx: AbilityContext) -> String:
	match str(ctx.params.get("target", "source")):
		"target":
			return ctx.target_id
		_:
			return ctx.source_id
