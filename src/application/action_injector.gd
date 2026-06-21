# @Spec: LLD-ARCH-003
#
# ActionInjector — the single interface through which all decisions (UI, AI, debug
# tools) enter the game loop (LLD-ARCH-003). Application layer: operates on
# GameState and the injected collaborators, never touches the scene tree.
#
# Responsibilities:
#   - get_legal_actions(): the legal action set for the current run phase. Combat
#     delegates to CombatResolver (the gating authority, LLD-ARCH-019); navigation
#     and loot are enumerated here.
#   - submit_action(): validates the action against the legal set (illegal → log +
#     state unchanged, never throw) and dispatches it. Combat actions delegate to
#     CombatResolver, after which ActionInjector owns the post-resolution item
#     bookkeeping: break detection + removal + item_broken emit + burden −1
#     (LLD-ARCH-011, HLD-ITEMS-005, HLD-RUN-007). Loot acquisition adds the item
#     with no inventory cap and burden +2 (HLD-ITEMS-001, HLD-RUN-007).
#
# Collaborators are injected (matching the ChargeManager/CombatResolver pattern):
# the CombatResolver, a ChargeManager (for break detection), a `content` provider
# (for an acquired item's max_charges), and the SignalBus (the one autoload it
# emits on). Phase transitions after an action belong to RunController (T6.4), so
# CHOOSE_DOOR / END_TURN are validated here but leave state for the orchestrator.
class_name ActionInjector
extends RefCounted

const ACTION_CHOOSE_DOOR := "CHOOSE_DOOR"
const ACTION_CHOOSE_LOOT := "CHOOSE_LOOT"
const ACTION_DECLINE_LOOT := "DECLINE_LOOT"
const ACTION_END_TURN := "END_TURN"

## Burden deltas (HLD-RUN-007): acquiring an item is +2; fully spending one is −1.
const BURDEN_ON_ACQUIRE := 2
const BURDEN_ON_SPENT := 1

var _resolver
var _charge_manager
var _content
var _signal_bus


# resolver: CombatResolver; charge_manager: ChargeManager (break detection);
# content: provider with get_ability(id) (acquired item max_charges); signal_bus:
# SignalBus (item_broken / item_acquired emits). All optional for testability.
func _init(resolver = null, charge_manager = null, content = null, signal_bus = null) -> void:
	_resolver = resolver
	_charge_manager = charge_manager
	_content = content
	_signal_bus = signal_bus


# The legal action set for the current run phase. Combat delegates to the resolver
# (priority-ordered gating, LLD-ARCH-019); navigation and loot are enumerated here.
# Terminal/transitional phases (FLOOR_TRANSITION, RUN_END, NON_COMBAT_EVENT [MVP2])
# have no player actions in MVP1. @Spec: LLD-ARCH-003, LLD-ARCH-019
func get_legal_actions(game_state: GameState) -> Array:
	match game_state.run_phase:
		GameState.RunPhase.COMBAT:
			return _resolver.get_legal_combat_actions(game_state) if _resolver != null else []
		GameState.RunPhase.NAVIGATION:
			return _navigation_actions(game_state)
		GameState.RunPhase.LOOT_SELECTION:
			return _loot_actions(game_state)
		_:
			return []


# One CHOOSE_DOOR per door in the current two-door choice (HLD-DOOR-001).
func _navigation_actions(game_state: GameState) -> Array:
	var actions: Array = []
	if game_state.navigation_state == null:
		return actions
	for door in game_state.navigation_state.doors_ahead:
		actions.append({"type": ACTION_CHOOSE_DOOR, "room_id": door.room_id})
	return actions


# One CHOOSE_LOOT per offer plus DECLINE_LOOT. No inventory cap (HLD-ITEMS-001):
# offers are never withheld for a full inventory — the item is always acquirable.
func _loot_actions(game_state: GameState) -> Array:
	var actions: Array = []
	if game_state.navigation_state != null:
		for item_id in game_state.navigation_state.loot_offers:
			actions.append({"type": ACTION_CHOOSE_LOOT, "item_id": item_id})
	actions.append({"type": ACTION_DECLINE_LOOT})
	return actions


# Validate the action against the legal set, then dispatch. An illegal action logs
# an error and returns the state unchanged — never throws (LLD-ARCH-003).
# @Spec: LLD-ARCH-003
func submit_action(action: Dictionary, game_state: GameState) -> GameState:
	if not _is_legal(action, game_state):
		push_error("ActionInjector: illegal action %s" % str(action))
		return game_state

	match str(action.get("type", "")):
		ACTION_CHOOSE_LOOT:
			return _resolve_choose_loot(action, game_state)
		ACTION_DECLINE_LOOT:
			return _resolve_decline_loot(game_state)
		ACTION_CHOOSE_DOOR, ACTION_END_TURN:
			# Validated as legal; the phase transition / turn advance is the
			# orchestrator's responsibility (RunController, T6.4).
			return game_state
		_:
			return _resolve_combat_action(action, game_state)


# An action is legal if a candidate of the same type matches on all selector keys.
# `send_to_bottom` is the player's free choice (the resolver validates it), so it is
# not part of the match. @Spec: LLD-ARCH-003
func _is_legal(action: Dictionary, game_state: GameState) -> bool:
	var action_type := str(action.get("type", ""))
	for candidate in get_legal_actions(game_state):
		if str(candidate.get("type", "")) != action_type:
			continue
		if _selectors_match(candidate, action):
			return true
	return false


func _selectors_match(candidate: Dictionary, action: Dictionary) -> bool:
	for key in candidate:
		if key == "type" or key == "send_to_bottom":
			continue
		if not action.has(key) or action[key] != candidate[key]:
			return false
	return true


# Delegate a combat action to the resolver (which applies the rules and decrements
# charges, LLD-ARCH-019), then finalize any items that broke from that decrement.
func _resolve_combat_action(action: Dictionary, game_state: GameState) -> GameState:
	var new_state: GameState = game_state
	if _resolver != null:
		new_state = _resolver.resolve_player_action(action, game_state)
	_finalize_broken_items(new_state)
	return new_state


# Remove items the resolver's charge decrement reduced to 0 (breaks_at_zero): null
# the slot, decrement burden, and emit item_broken (HLD-ITEMS-005, HLD-RUN-007,
# LLD-ARCH-011). REPENT discards are handled in the resolver (item_discarded) and
# leave a null slot, so they are not double-counted here.
# @Spec: LLD-ARCH-011, HLD-ITEMS-005, HLD-RUN-007, LLD-ARCH-009
func _finalize_broken_items(game_state: GameState) -> void:
	if _charge_manager == null:
		return
	for slot in _charge_manager.get_broken_slots(game_state):
		var item: ItemInstance = game_state.inventory[slot]
		var item_id := item.item_id if item != null else ""
		game_state.inventory[slot] = null
		game_state.item_burden_score = maxi(game_state.item_burden_score - BURDEN_ON_SPENT, 0)
		if _signal_bus != null:
			_signal_bus.item_broken.emit(item_id, slot)


# Acquire the chosen loot item: add it at full charges (no inventory cap), raise
# burden by 2, emit item_acquired, and clear the offers. The phase transition back
# to NAVIGATION is RunController's (T6.4). @Spec: HLD-ITEMS-001, HLD-RUN-007, LLD-ARCH-009
func _resolve_choose_loot(action: Dictionary, game_state: GameState) -> GameState:
	var item_id := str(action.get("item_id", ""))
	var data = _content.get_ability(item_id) if _content != null else null
	var item := ItemInstance.new()
	item.item_id = item_id
	item.remaining_charges = data.max_charges if data != null else 0
	_add_to_inventory(game_state, item)
	game_state.item_burden_score += BURDEN_ON_ACQUIRE
	if _signal_bus != null:
		_signal_bus.item_acquired.emit(item_id)
	_clear_loot_offers(game_state)
	return game_state


# Fill the first empty (null) slot; otherwise append (no cap, HLD-ITEMS-001).
func _add_to_inventory(game_state: GameState, item: ItemInstance) -> void:
	for i in game_state.inventory.size():
		if game_state.inventory[i] == null:
			game_state.inventory[i] = item
			return
	game_state.inventory.append(item)


# Walk away from the loot choice with nothing; clear the offers (RunController, T6.4,
# transitions to NAVIGATION). @Spec: LLD-ARCH-003
func _resolve_decline_loot(game_state: GameState) -> GameState:
	_clear_loot_offers(game_state)
	return game_state


func _clear_loot_offers(game_state: GameState) -> void:
	if game_state.navigation_state != null:
		game_state.navigation_state.loot_offers.assign([])
