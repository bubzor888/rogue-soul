# @Spec: LLD-ITEMS-007, HLD-COMBAT-007
#
# CombustibleOilHandler ("combustible_oil") — the branching Combustible Oil
# consumable: applies Vulnerable (Fire) to the target enemy, OR — if the enemy
# already has Burning — deals a flat fire-damage burst instead (no extra
# Vulnerable). The offensive action is non-targeted, so the handler auto-targets the
# first living enemy (matching ApplyStatusHandler; real targeting is MVP2 UI). Params:
#   burst_damage (int, default 6) — the flat fire burst vs an already-Burning enemy.
#   remaining_ticks (int) — supplied by the resolver from the omen cycle.
#
# Needs ctx.content + ctx.rng for the damage path (DamageCalculator).
class_name CombustibleOilHandler
extends AbilityHandler


func apply(ctx: AbilityContext) -> void:
	var target_id := ctx.target_id if ctx.target_id != "" else _first_living_enemy(ctx.game_state)
	if target_id == "":
		return
	var statuses := StatusRules.resolve_statuses(ctx.game_state, target_id)
	if _has_burning(statuses):
		# Already Burning → flat fire burst (the fire combo payoff), no new Vulnerable.
		var burst := int(ctx.params.get("burst_damage", 6))
		ctx.results.append(DamageCalculator.resolve_hit(
			ctx.game_state, "player", target_id, burst, "fire", ctx.content, ctx.rng))
	else:
		var remaining_ticks := int(ctx.params.get("remaining_ticks", 0))
		StatusRules.apply_to_unit(statuses, "vulnerable:fire", 0, remaining_ticks)


func _has_burning(statuses: Array) -> bool:
	for s in statuses:
		if s.status_id == "burning":
			return true
	return false


func _first_living_enemy(game_state: GameState) -> String:
	if game_state == null or game_state.combat_state == null:
		return ""
	for enemy in game_state.combat_state.enemies:
		if enemy.hp > 0:
			return enemy.instance_id
	return ""
