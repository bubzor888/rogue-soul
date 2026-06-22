# @Spec: LLD-ARCH-011, LLD-ARCH-016, HLD-ITEMS-004, HLD-ITEMS-005
#
# ChargeManager — handles all charge replenishment and durability decrement for
# abilities and items (LLD-ARCH-011). Application layer: operates on GameState,
# never touches the scene tree.
#
# It needs each charge holder's AbilityData (max_charges, action_bucket,
# breaks_at_zero, replenish_triggers). Rather than depend on ContentRegistry
# (T3.2) directly, the lookup is injected as a Callable — RunController passes the
# registry; tests pass a stub. (id: String) -> AbilityData | null.
#
# Break-at-zero policy (LLD-ARCH-011): ChargeManager only *flags* items that have
# broken (0 charges + breaks_at_zero). The actual removal + `item_broken` emit
# happens in ActionInjector (T6.1). Abilities never break.
class_name ChargeManager
extends RefCounted

## Action buckets (HLD-ITEMS-004). Support-durability items decrement per encounter.
const BUCKET_ATTACK := "attack"
const BUCKET_SUPPORT := "support"
const BUCKET_CONSUMABLE := "consumable"
const BUCKET_PASSIVE := "passive"

var _lookup: Callable


func _init(data_lookup: Callable) -> void:
	_lookup = data_lookup


# Restore charges for every ability/item whose replenish_triggers contains
# event_id. @Spec: LLD-ARCH-011
func fire_replenish_event(game_state: GameState, event_id: String) -> void:
	if game_state.vessel_state != null:
		for ast in game_state.vessel_state.ability_states:
			_maybe_replenish(ast, ast.ability_id, event_id)
	for companion in [game_state.bound_companion, game_state.temporary_companion]:
		if companion != null:
			for ast in companion.ability_states:
				_maybe_replenish(ast, ast.ability_id, event_id)
	for item in game_state.inventory:
		if item != null:
			_maybe_replenish(item, item.item_id, event_id)


# Per-encounter decrement for Support (Durability) items — once on room entry,
# regardless of activation (HLD-ITEMS-005). Returns the inventory slots of items
# that broke (0 charges + breaks_at_zero). @Spec: HLD-ITEMS-005, HLD-ITEMS-004
func decrement_support_items(game_state: GameState) -> Array[int]:
	var broken_slots: Array[int] = []
	for i in game_state.inventory.size():
		var item: ItemInstance = game_state.inventory[i]
		if item == null:
			continue
		var data = _lookup.call(item.item_id)
		if data == null or data.action_bucket != BUCKET_SUPPORT:
			continue
		item.remaining_charges = maxi(item.remaining_charges - 1, 0)
		if _is_broken(item.remaining_charges, data):
			broken_slots.append(i)
	return broken_slots


# Per-use decrement for an Attack (Durability) or Consumable item on activation
# (HLD-ITEMS-005). Returns true if the item broke. @Spec: HLD-ITEMS-005
func decrement_on_use(item: ItemInstance) -> bool:
	var data = _lookup.call(item.item_id)
	if data == null:
		return false
	item.remaining_charges = maxi(item.remaining_charges - 1, 0)
	return _is_broken(item.remaining_charges, data)


# Inventory slots flagged for removal (0 charges + breaks_at_zero). ActionInjector
# (T6.1) consumes this to remove items and emit `item_broken`. @Spec: LLD-ARCH-011
func get_broken_slots(game_state: GameState) -> Array[int]:
	var out: Array[int] = []
	for i in game_state.inventory.size():
		var item: ItemInstance = game_state.inventory[i]
		if item == null:
			continue
		var data = _lookup.call(item.item_id)
		if data != null and _is_broken(item.remaining_charges, data):
			out.append(i)
	return out


func _maybe_replenish(charge_holder, id: String, event_id: String) -> void:
	var data = _lookup.call(id)
	if data == null:
		return
	if event_id in data.replenish_triggers:
		charge_holder.remaining_charges = data.max_charges


func _is_broken(remaining_charges: int, data) -> bool:
	return remaining_charges <= 0 and data.breaks_at_zero
