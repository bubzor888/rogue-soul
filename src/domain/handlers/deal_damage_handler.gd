# @Spec: HLD-COMBAT-005, HLD-COMBAT-016, LLD-ABILITIES-004, LLD-ITEMS-005, LLD-ITEMS-006, LLD-ARCH-019
#
# DealDamageHandler ("deal_damage") — player-side damage. Resolves targets per the
# mode, then runs each hit through the shared DamageCalculator (the 7-step
# pipeline). Records one result Dictionary per hit on ctx.results for the resolver
# to emit (damage_dealt / unit_died, T5.6). Params:
#   base_damage (int), damage_type (String, default "physical"),
#   mode ("single" | "all" | "arc"; default "single"),
#   arc_targets (int, extra targets for "arc"; default 1).
#
# Needs ctx.content (target resistances) and ctx.rng (evade roll) — injected by the
# resolver when it builds the context.
class_name DealDamageHandler
extends AbilityHandler


func apply(ctx: AbilityContext) -> void:
	var base_damage := int(ctx.params.get("base_damage", 0))
	var damage_type := str(ctx.params.get("damage_type", "physical"))
	for target_id in _resolve_targets(ctx):
		ctx.results.append(DamageCalculator.resolve_hit(
			ctx.game_state, ctx.source_id, target_id, base_damage, damage_type, ctx.content, ctx.rng))


# Targets per mode: single → the action target; all → every living enemy; arc →
# the target plus up to arc_targets other living enemies. @Spec: HLD-COMBAT-016
func _resolve_targets(ctx: AbilityContext) -> Array:
	var mode := str(ctx.params.get("mode", "single"))
	if mode == "single":
		return [ctx.target_id]

	var living := _living_enemy_ids(ctx.game_state)
	if mode == "all":
		return living

	# arc: primary target first, then up to arc_targets others.
	var extra := int(ctx.params.get("arc_targets", 1))
	var out: Array = [ctx.target_id]
	for id in living:
		if out.size() > extra:  # primary + extra
			break
		if id != ctx.target_id:
			out.append(id)
	return out


func _living_enemy_ids(game_state: GameState) -> Array:
	var ids: Array = []
	if game_state.combat_state == null:
		return ids
	for enemy in game_state.combat_state.enemies:
		if enemy.hp > 0:
			ids.append(enemy.instance_id)
	return ids
