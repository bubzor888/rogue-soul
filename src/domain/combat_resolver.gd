# @Spec: LLD-ARCH-019
#
# CombatResolver — the sole authority for combat rule application (LLD-ARCH-019).
# RefCounted, Domain layer. Receives its dependencies by injection and MUST NOT
# access any autoload directly: RNGService for rolls, a `content` provider (the
# ContentRegistry-style lookup, passed in by the Application layer), and an
# AbilityPipeline for handler chains. Emits cross-cutting events on SignalBus
# (the one permitted autoload) — added in later sub-tasks.
#
# Built incrementally across T5.1–T5.7. T5.1: get_legal_combat_actions.
class_name CombatResolver
extends RefCounted

# Action type vocabulary. USE_ABILITY/USE_ITEM/END_TURN/READ_THE_ROAD_COMMIT/
# REPENT_DISCARD are the MVP1 combat commands (LLD-ARCH-003). EVADE is the Evade
# Action-bucket option (HLD-COMBAT-017).
const ACTION_USE_ABILITY := "USE_ABILITY"
const ACTION_USE_ITEM := "USE_ITEM"
const ACTION_EVADE := "EVADE"
const ACTION_END_TURN := "END_TURN"
const ACTION_READ_THE_ROAD_COMMIT := "READ_THE_ROAD_COMMIT"
const ACTION_REPENT_DISCARD := "REPENT_DISCARD"
const ACTION_CHOOSE_OMEN := "CHOOSE_OMEN"

const SIDE_PLAYER := "player"
const SIDE_ENEMY := "enemy"

const BUCKET_ATTACK := "attack"

## Per-tick increase to a Chilled status's flat reduction. MVP1 default: the
## StatusInstance has no field to carry a data-driven per-card step (only
## `magnitude`, which is the current accumulated reduction), so the step is a
## constant here. Flagged for a spec/schema decision if data-driven steps are needed.
const CHILLED_TICK_STEP := 1

var _rng
var _content
var _pipeline


# rng: RNGService; content: provider with get_vessel(id)/get_ability(id);
# pipeline: AbilityPipeline. All injected — no autoload access.
func _init(rng = null, content = null, pipeline = null) -> void:
	_rng = rng
	_content = content
	_pipeline = pipeline


# All valid player actions for the current combat turn, with the priority-ordered
# gating from LLD-ARCH-019. Always returns at least one action.
# @Spec: LLD-ARCH-019, LLD-ARCH-003, HLD-COMBAT-004, HLD-COMBAT-011, HLD-COMBAT-017
func get_legal_combat_actions(game_state: GameState) -> Array:
	var combat := game_state.combat_state

	# 1. Read the Road pending → only the commit action.
	if combat != null and combat.read_the_road_active:
		return [{"type": ACTION_READ_THE_ROAD_COMMIT, "send_to_bottom": []}]

	# 2. Omen choice pending → only CHOOSE_OMEN actions (LLD-ARCH-024).
	if combat != null and combat.current_cycle != null and not combat.current_cycle.sides_assigned:
		return _omen_choice_actions(combat.current_cycle)

	# 3. Repent pending → only a discard action per revealed slot.
	if combat != null and not combat.pending_repent_slots.is_empty():
		var repent_actions: Array = []
		for slot in combat.pending_repent_slots:
			repent_actions.append({"type": ACTION_REPENT_DISCARD, "slot_index": slot})
		return repent_actions

	# 4. Standard action set.
	return _standard_actions(game_state)


# One CHOOSE_OMEN action per (card_index, side). @Spec: LLD-ARCH-024
func _omen_choice_actions(cycle: OmenCycleState) -> Array:
	var actions: Array = []
	for card_index in cycle.drawn_cards.size():
		for side in [SIDE_PLAYER, SIDE_ENEMY]:
			actions.append({"type": ACTION_CHOOSE_OMEN, "card_index": card_index, "side": side})
	return actions


func _standard_actions(game_state: GameState) -> Array:
	var actions: Array = []
	var vessel := game_state.vessel_state
	var stunned := vessel != null and vessel.is_stunned
	var targets := _living_enemy_ids(game_state)

	# Default Strike + Evade are Action-bucket options — excluded while stunned.
	if not stunned:
		var strike_id := _default_strike_id(vessel)
		for target_id in targets:
			actions.append({"type": ACTION_USE_ABILITY, "ability_id": strike_id, "target_id": target_id})
		actions.append({"type": ACTION_EVADE})

	# Vessel abilities that still have charges.
	if vessel != null:
		for ability_state in vessel.ability_states:
			if ability_state.remaining_charges <= 0:
				continue
			var bucket := _bucket_of(ability_state.ability_id)
			if bucket == BUCKET_ATTACK and stunned:
				continue
			actions.append_array(_use_ability_actions(ability_state.ability_id, bucket, targets))

	# Inventory items that still have charges.
	for i in game_state.inventory.size():
		var item: ItemInstance = game_state.inventory[i]
		if item == null or item.remaining_charges <= 0:
			continue
		var bucket := _bucket_of(item.item_id)
		if bucket == BUCKET_ATTACK and stunned:
			continue
		actions.append_array(_use_item_actions(i, bucket, targets))

	# Guarantee at least one action (e.g. stunned with no Support/Consumable items).
	if actions.is_empty():
		actions.append({"type": ACTION_END_TURN})
	return actions


# Attack-bucket abilities/items produce one action per living enemy target; other
# buckets (support/consumable/passive) produce a single non-targeted action.
func _use_ability_actions(ability_id: String, bucket: String, targets: Array) -> Array:
	if bucket == BUCKET_ATTACK:
		var out: Array = []
		for target_id in targets:
			out.append({"type": ACTION_USE_ABILITY, "ability_id": ability_id, "target_id": target_id})
		return out
	return [{"type": ACTION_USE_ABILITY, "ability_id": ability_id, "target_id": ""}]


func _use_item_actions(slot_index: int, bucket: String, targets: Array) -> Array:
	if bucket == BUCKET_ATTACK:
		var out: Array = []
		for target_id in targets:
			out.append({"type": ACTION_USE_ITEM, "slot_index": slot_index, "target_id": target_id})
		return out
	return [{"type": ACTION_USE_ITEM, "slot_index": slot_index, "target_id": ""}]


func _living_enemy_ids(game_state: GameState) -> Array:
	var ids: Array = []
	if game_state.combat_state == null:
		return ids
	for enemy in game_state.combat_state.enemies:
		if enemy.hp > 0:
			ids.append(enemy.instance_id)
	return ids


func _default_strike_id(vessel: VesselState) -> String:
	if vessel == null or _content == null:
		return ""
	var vessel_data = _content.get_vessel(vessel.vessel_id)
	return vessel_data.default_strike_id if vessel_data != null else ""


func _bucket_of(content_id: String) -> String:
	if _content == null:
		return ""
	var data = _content.get_ability(content_id)
	return data.action_bucket if data != null else ""


## --- Status tick & shift resolution (T5.3) ----------------------------------

# Advance one omen tick: fire tick-triggered effects on every unit, decrement all
# active statuses, and clear expired tick statuses (shift statuses at 0 are left
# for the cycle start). @Spec: LLD-ARCH-019, HLD-COMBAT-006, -015, -018, -019
func resolve_omen_tick(game_state: GameState) -> GameState:
	for unit in _all_units(game_state):
		_tick_unit(unit)
	return game_state


func _tick_unit(unit) -> void:
	for status in unit.active_statuses:
		if status.trigger != "tick":
			continue
		match status.status_id:
			"burning":
				_damage_unit(unit, status.magnitude)
			"poisoned":
				_damage_unit(unit, status.magnitude)
				status.magnitude *= 3  # escalation (HLD-COMBAT, Poison)
			"bleed":
				_damage_unit(unit, status.magnitude)
				status.magnitude = int(floor(status.magnitude / 2.0))  # decay
			"mending":
				_heal_unit(unit, status.magnitude)
			"chilled":
				status.magnitude += CHILLED_TICK_STEP  # creeping reduction
			"hardened":
				pass  # per-hit cap; nothing to reset (see DamageCalculator)

	# Decrement remaining_ticks on ALL active statuses.
	for status in unit.active_statuses:
		status.remaining_ticks -= 1

	# Clear expired tick statuses (and Bleed that decayed to 0); keep shift statuses.
	var kept: Array = []
	for status in unit.active_statuses:
		var expired_tick: bool = status.trigger == "tick" and status.remaining_ticks <= 0
		var bleed_done: bool = status.status_id == "bleed" and status.magnitude <= 0
		if expired_tick or bleed_done:
			continue
		kept.append(status)
	unit.active_statuses.assign(kept)


# Fire shift-triggered statuses (those at remaining_ticks <= 0) for every unit in
# the LLD-ARCH-023 order: death_mark → shocked → exposed. Returns the unit ids that
# became pending-Vulnerable (Exposed) for deferred application. Does NOT clear
# statuses — the caller calls clear_expired_statuses after.
# @Spec: LLD-ARCH-023, HLD-COMBAT-006
func fire_shift_statuses(game_state: GameState) -> Array:
	var pending_vulnerable: Array = []
	for unit in _all_units(game_state):
		var fired: Dictionary = {}
		for status in unit.active_statuses:
			if status.trigger == "shift" and status.remaining_ticks <= 0:
				fired[status.status_id] = true
		if fired.has("death_mark"):
			unit.hp = 0  # instant death; remaining shifts on this unit are skipped
			continue
		if fired.has("shocked"):
			unit.is_stunned = true
		if fired.has("exposed"):
			pending_vulnerable.append(_unit_id(game_state, unit))
	return pending_vulnerable


# Remove every status at remaining_ticks <= 0 from all units (cycle-start step 2).
func clear_expired_statuses(game_state: GameState) -> void:
	for unit in _all_units(game_state):
		var kept: Array = []
		for status in unit.active_statuses:
			if status.remaining_ticks > 0:
				kept.append(status)
		unit.active_statuses.assign(kept)


# Apply the deferred Vulnerable (Physical) to each pending unit with the new
# cycle's timer as remaining_ticks (cycle-start step 4). The timer comes from the
# draw in T5.4. @Spec: HLD-COMBAT-006, LLD-ARCH-019
func apply_deferred_vulnerable(game_state: GameState, unit_ids: Array, new_cycle_timer: int) -> void:
	for unit_id in unit_ids:
		var statuses := StatusRules.resolve_statuses(game_state, unit_id)
		StatusRules.apply_to_unit(statuses, "vulnerable:physical", 0, new_cycle_timer)


func _all_units(game_state: GameState) -> Array:
	var units: Array = []
	if game_state.vessel_state != null:
		units.append(game_state.vessel_state)
	if game_state.combat_state != null:
		for enemy in game_state.combat_state.enemies:
			units.append(enemy)
	return units


func _unit_id(game_state: GameState, unit) -> String:
	if unit is EnemyState:
		return unit.instance_id
	return "player"


func _damage_unit(unit, amount: int) -> void:
	unit.hp = maxi(unit.hp - amount, 0)


func _heal_unit(unit, amount: int) -> void:
	unit.hp = mini(unit.hp + amount, unit.max_hp)
