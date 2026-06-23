# @Spec: HLD-RUN-007, HLD-COMBAT-019, LLD-ENEMIES-021, LLD-ENEMIES-022, LLD-ARCH-018
#
# ApplyMendingByBurdenTierHandler ("apply_mending_by_burden_tier") — the Witness
# of Mercy's testify_mercy effect: applies Mending to the target (The Judge) at a
# magnitude chosen by the player's current item_burden_score tier (HLD-RUN-007).
# Mending is max-wins (HLD-COMBAT-019), so a lower-tier re-application cannot
# downgrade an active higher Mending — StatusRules enforces this.
#
# Tier brackets are data-driven (authored on the Witness intent .tres, LLD-ENEMIES-
# 021/-022), keeping the LLD values out of the engine. Params:
#   status_id (String, default "mending") — the (colon-encoded) status applied by
#     tier. Mercy uses the default Mending; Vengeance passes "emboldened:physical".
#   tiers (Array of { max: int, magnitude: int }) — ordered low→high; the first
#     tier whose `max` >= burden (or max < 0 = unbounded) wins.
#   remaining_ticks (int) — supplied by the resolver from the omen cycle (T5.4).
class_name ApplyMendingByBurdenTierHandler
extends AbilityHandler


func apply(ctx: AbilityContext) -> void:
	var burden := ctx.game_state.item_burden_score
	var magnitude := _tier_magnitude(burden, ctx.params.get("tiers", []))
	var remaining_ticks := int(ctx.params.get("remaining_ticks", 0))
	var status_id := str(ctx.params.get("status_id", "mending"))
	var statuses := StatusRules.resolve_statuses(ctx.game_state, ctx.target_id)
	StatusRules.apply_to_unit(statuses, status_id, magnitude, remaining_ticks)


func _tier_magnitude(burden: int, tiers: Array) -> int:
	for tier in tiers:
		var tier_max := int(tier.get("max", -1))
		if tier_max < 0 or burden <= tier_max:
			return int(tier.get("magnitude", 0))
	return 0
