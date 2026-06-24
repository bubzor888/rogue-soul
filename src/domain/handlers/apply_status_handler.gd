# @Spec: HLD-COMBAT-006, HLD-COMBAT-015, HLD-COMBAT-018, HLD-COMBAT-019, LLD-ARCH-018
#
# ApplyStatusHandler ("apply_status") — creates/refreshes a StatusInstance on a
# unit, applying colon-encoding split and the magnitude stacking rules via
# StatusRules. Params:
#   status_id (String, colon-encoded ok), magnitude (int), remaining_ticks (int),
#   target ("target" | "source" | "self"; default "target").
#
# Note: when invoked as part of an ability/omen, the resolver supplies
# remaining_ticks from the current omen cycle's timer (T5.4); here it is taken
# from params so the handler stays self-contained.
class_name ApplyStatusHandler
extends AbilityHandler


func apply(ctx: AbilityContext) -> void:
	var raw_status_id := str(ctx.params.get("status_id", ""))
	if raw_status_id == "":
		return
	var magnitude := int(ctx.params.get("magnitude", 0))
	var remaining_ticks := int(ctx.params.get("remaining_ticks", 0))
	var unit_id := _resolve_target_id(ctx)
	var statuses := StatusRules.resolve_statuses(ctx.game_state, unit_id)
	StatusRules.apply_to_unit(statuses, raw_status_id, magnitude, remaining_ticks)


func _resolve_target_id(ctx: AbilityContext) -> String:
	match str(ctx.params.get("target", "target")):
		"source", "self":
			return ctx.source_id
		_:
			# Offensive consumables are non-targeted actions (no target_id); auto-target
			# the first living enemy. Real per-target selection is an MVP2 UI concern.
			if ctx.target_id != "":
				return ctx.target_id
			return _first_living_enemy(ctx.game_state)


func _first_living_enemy(game_state: GameState) -> String:
	if game_state == null or game_state.combat_state == null:
		return ""
	for enemy in game_state.combat_state.enemies:
		if enemy.hp > 0:
			return enemy.instance_id
	return ""
