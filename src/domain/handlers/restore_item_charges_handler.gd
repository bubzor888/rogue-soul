# @Spec: LLD-ABILITIES-003, LLD-VESSELS-001
#
# RestoreItemChargesHandler ("restore_item_charges") — Good as New: refill one
# item's durability to its maximum (LLD-ABILITIES-003). Single-use items
# (max_charges <= 1) are never affected.
#
# Targeting: an explicit `target_slot` (the player's choice — surfaced as UI in
# MVP2) restores that inventory slot. With no slot given, the handler auto-targets
# the most-depleted eligible item (most missing charges; ties → lowest slot) so the
# headless random agent (MVP1) still produces a meaningful effect, matching the
# engine's "support abilities are a single non-targeted action" model. Per-slot
# enumeration for real player choice is an MVP2 concern.
#
# Needs the content provider (ctx.content) to read each item's max_charges.
class_name RestoreItemChargesHandler
extends AbilityHandler


func apply(ctx: AbilityContext) -> void:
	var gs := ctx.game_state
	if gs == null or ctx.content == null:
		return

	var slot := int(ctx.params.get("target_slot", -1))
	if slot >= 0:
		_restore_slot(gs, ctx.content, slot)
		return

	# Auto-target: the eligible item missing the most charges.
	var best_slot := -1
	var best_missing := 0
	for i in gs.inventory.size():
		var item: ItemInstance = gs.inventory[i]
		if item == null:
			continue
		var max_charges := _max_charges(ctx.content, item.item_id)
		if max_charges <= 1:
			continue  # single-use — never restored
		var missing := max_charges - item.remaining_charges
		if missing > best_missing:
			best_missing = missing
			best_slot = i
	if best_slot >= 0:
		_restore_slot(gs, ctx.content, best_slot)


# Restore the item at `slot` to its max, unless it is single-use (no effect).
func _restore_slot(gs: GameState, content, slot: int) -> void:
	if slot >= gs.inventory.size():
		return
	var item: ItemInstance = gs.inventory[slot]
	if item == null:
		return
	var max_charges := _max_charges(content, item.item_id)
	if max_charges <= 1:
		return  # single-use — no effect (LLD-ABILITIES-003)
	item.remaining_charges = max_charges


func _max_charges(content, item_id: String) -> int:
	var data = content.get_ability(item_id)
	return data.max_charges if data != null else 0
