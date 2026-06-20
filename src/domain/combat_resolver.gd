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
const BUCKET_PASSIVE := "passive"

## COMBAT RNG stream index (RNGService.Stream.COMBAT). Held as a const so the
## resolver never touches the autoload global (matches DamageCalculator).
const STREAM_COMBAT := 1

## Cards drawn per omen cycle (HLD-OMEN-001).
const CYCLE_DRAW := 3

## Repent heal when the player has no items to discard (LLD-ARCH-019).
const REPENT_HEAL := 5

## Per-tick increase to a Chilled status's flat reduction. MVP1 default: the
## StatusInstance has no field to carry a data-driven per-card step (only
## `magnitude`, which is the current accumulated reduction), so the step is a
## constant here. Flagged for a spec/schema decision if data-driven steps are needed.
const CHILLED_TICK_STEP := 1

var _rng
var _content
var _pipeline
var _signal_bus


# rng: RNGService; content: provider with get_vessel(id)/get_ability(id);
# pipeline: AbilityPipeline; signal_bus: SignalBus (the one autoload the resolver
# may emit on, per LLD-ARCH-019 — injected so the Domain layer stays testable and
# decoupled from the autoload, matching EventLog.connect_to_bus). All optional.
func _init(rng = null, content = null, pipeline = null, signal_bus = null) -> void:
	_rng = rng
	_content = content
	_pipeline = pipeline
	_signal_bus = signal_bus


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


## --- Omen system: assembly, draw cycle, choice, reshuffle, removal (T5.4) ---
##
## Source split decision (recorded so it isn't re-litigated): vessel/item/floor/
## companion card ids are passed in via `source_card_ids` because resolving them
## needs registry + FloorProfile lookups that live in the Application layer (the
## same injection pattern as ChargeManager/ContentRegistry). Enemy contributions
## are derived here from CombatState because the two-tier model (HLD-OMEN-006) is
## core combat logic the Domain resolver owns.

# Assemble a fresh omen deck from the four sources (HLD-OMEN-004): the passed-in
# vessel/item/floor/companion card ids plus the enemy two-tier contributions
# (HLD-OMEN-006). Assigns timer values via COMBAT (LLD-OMEN-MECH-008/-009),
# shuffles, then runs the passive-ability handler pass (which may set
# read_the_road_active — caller waits for READ_THE_ROAD_COMMIT if so).
# @Spec: HLD-COMBAT-008, HLD-OMEN-004, HLD-OMEN-006, LLD-OMEN-MECH-008, LLD-OMEN-MECH-009, LLD-ARCH-019
func assemble_omen_deck(source_card_ids: Array, game_state: GameState) -> GameState:
	var combat := game_state.combat_state
	if combat == null:
		return game_state

	var card_ids: Array = []
	for cid in source_card_ids:
		card_ids.append(str(cid))
	card_ids.append_array(_enemy_card_contributions(game_state))

	var deck := OmenDeckState.new()
	deck.draw_pile.assign(_build_timed_entries(card_ids))
	_shuffle_in_place(deck.draw_pile)
	combat.omen_deck = deck

	_run_passive_omen_handlers(game_state)
	return game_state


# Two-tier enemy omen contribution (HLD-OMEN-006): Tier 1 family card (index 0)
# once per living instance; Tier 2 type card (index 1, if present) once per type.
func _enemy_card_contributions(game_state: GameState) -> Array:
	var ids: Array = []
	var types_seen: Dictionary = {}
	for enemy in game_state.combat_state.enemies:
		var data = _content.get_enemy(enemy.enemy_id) if _content != null else null
		if data == null or data.omen_contributions.is_empty():
			continue
		ids.append(str(data.omen_contributions[0]))  # Tier 1: per instance
		if data.omen_contributions.size() > 1 and not types_seen.has(enemy.enemy_id):
			ids.append(str(data.omen_contributions[1]))  # Tier 2: per type
		types_seen[enemy.enemy_id] = true
	return ids


# Pair each card id with a timer value drawn from the fixed 25/50/25 split
# (LLD-OMEN-MECH-008). The split is count-based (exact "nearest whole-number")
# then the assignment to cards is randomised by the deck shuffle.
func _build_timed_entries(card_ids: Array) -> Array:
	var timers := _timer_value_pool(card_ids.size())
	_shuffle_in_place(timers)
	var entries: Array = []
	for i in card_ids.size():
		entries.append({"card_id": card_ids[i], "timer_value": timers[i]})
	return entries


# A pool of n timer values split 25% ones / 50% twos / 25% threes (rounded).
func _timer_value_pool(n: int) -> Array:
	var ones := int(round(n * 0.25))
	var threes := int(round(n * 0.25))
	var twos := maxi(n - ones - threes, 0)
	var pool: Array = []
	for _i in ones:
		pool.append(1)
	for _i in twos:
		pool.append(2)
	for _i in threes:
		pool.append(3)
	return pool


# In-place Fisher-Yates using the COMBAT stream. No-op without an injected rng.
func _shuffle_in_place(arr: Array) -> void:
	if _rng == null:
		return
	for i in range(arr.size() - 1, 0, -1):
		var j: int = _rng.randi_range(STREAM_COMBAT, 0, i)
		var tmp = arr[i]
		arr[i] = arr[j]
		arr[j] = tmp


# Run each passive vessel ability's handler chain after deck assembly. Returns
# early if a handler sets read_the_road_active (Read the Road passive variant).
func _run_passive_omen_handlers(game_state: GameState) -> void:
	var vessel := game_state.vessel_state
	if vessel == null or _content == null or _pipeline == null:
		return
	for ability_state in vessel.ability_states:
		var data = _content.get_ability(ability_state.ability_id)
		if data == null or data.action_bucket != BUCKET_PASSIVE:
			continue
		var ctx := AbilityContext.new(game_state, "player", "")
		ctx.content = _content
		ctx.rng = _rng
		_pipeline.execute(data.handlers, ctx)
		if game_state.combat_state != null and game_state.combat_state.read_the_road_active:
			return


# End the current omen cycle and begin a new one, pausing for the player's
# CHOOSE_OMEN (LLD-ARCH-024). Fires shift statuses (LLD-ARCH-023), clears expired
# statuses, discards the spent cycle, draws 3 (reshuffling if short), and records
# the Exposed-marked units for the deferred Vulnerable applied at CHOOSE_OMEN.
# Steps 4-5 (deferred Vulnerable + played-card application) move to CHOOSE_OMEN
# because the new cycle timer is the leftover card, unknown until the choice.
# @Spec: LLD-ARCH-019, LLD-ARCH-023, LLD-ARCH-024, HLD-OMEN-001, HLD-OMEN-003
func resolve_omen_cycle_start(game_state: GameState) -> GameState:
	var combat := game_state.combat_state
	if combat == null or combat.omen_deck == null:
		return game_state

	# Step 1-2: fire shift-triggered statuses, then clear all expired statuses.
	var pending_vulnerable := fire_shift_statuses(game_state)
	clear_expired_statuses(game_state)

	# Discard the spent cycle's cards so they can return on reshuffle (HLD-OMEN-003).
	if combat.current_cycle != null:
		combat.omen_deck.discard_pile.append_array(combat.current_cycle.drawn_cards)

	# Step 3: draw a new cycle of 3 and pause.
	var cycle := OmenCycleState.new()
	cycle.drawn_cards.assign(_draw_cards(combat.omen_deck, CYCLE_DRAW))
	cycle.player_choice_index = -1
	cycle.sides_assigned = false
	combat.current_cycle = cycle

	combat.pending_vulnerable_units.assign(pending_vulnerable)
	return game_state


# Draw n cards from the top of the draw pile, reshuffling the discard pile back in
# first when fewer than n remain (HLD-OMEN-003). Stops early only if truly empty.
func _draw_cards(deck: OmenDeckState, n: int) -> Array:
	if deck.draw_pile.size() < n:
		_reshuffle(deck)
	var drawn: Array = []
	for _i in n:
		if deck.draw_pile.is_empty():
			break
		drawn.append(deck.draw_pile.pop_front())
	return drawn


# Fold the discard pile into the draw pile and reshuffle (HLD-OMEN-003). Timer
# values ride along on the entries — they are never re-rolled (LLD-OMEN-MECH-009).
func _reshuffle(deck: OmenDeckState) -> void:
	deck.draw_pile.append_array(deck.discard_pile)
	deck.discard_pile.assign([])
	_shuffle_in_place(deck.draw_pile)


# Resolve a CHOOSE_OMEN action (LLD-ARCH-024): assign sides, derive the timer from
# the leftover card, apply the deferred Vulnerable, and apply the two played cards.
# Illegal actions log an error and return state unchanged (LLD-ARCH-003).
# @Spec: LLD-ARCH-024, LLD-ARCH-019, LLD-ARCH-003, HLD-OMEN-001, HLD-OMEN-005
func resolve_choose_omen(action: Dictionary, game_state: GameState) -> GameState:
	var combat := game_state.combat_state
	var cycle: OmenCycleState = combat.current_cycle if combat != null else null
	if cycle == null or cycle.sides_assigned:
		push_error("CHOOSE_OMEN: no pending omen choice")
		return game_state

	var card_index := int(action.get("card_index", -1))
	var side := str(action.get("side", ""))
	if card_index < 0 or card_index >= cycle.drawn_cards.size():
		push_error("CHOOSE_OMEN: card_index out of range")
		return game_state
	if side != SIDE_PLAYER and side != SIDE_ENEMY:
		push_error("CHOOSE_OMEN: invalid side '%s'" % side)
		return game_state

	# Assign sides: player choice, a random one of the other two, and the leftover
	# becomes the timer card.
	cycle.player_choice_index = card_index
	var others: Array = []
	for i in cycle.drawn_cards.size():
		if i != card_index:
			others.append(i)
	cycle.random_assignment_index = -1
	if not others.is_empty():
		var pick := 0
		if others.size() > 1 and _rng != null:
			pick = _rng.randi_range(STREAM_COMBAT, 0, others.size() - 1)
		cycle.random_assignment_index = others[pick]
	cycle.timer_index = -1
	for i in others:
		if i != cycle.random_assignment_index:
			cycle.timer_index = i
	var new_timer := 0
	if cycle.timer_index >= 0:
		new_timer = int(cycle.drawn_cards[cycle.timer_index].get("timer_value", 0))

	# Mark resolved before applying cards so the omen-choice gate (LLD-ARCH-024) is
	# off even on the Repent early-return path (where the Repent gate takes over).
	cycle.sides_assigned = true

	# Step 4: apply the deferred Vulnerable (Exposed shift) with the known timer.
	apply_deferred_vulnerable(game_state, combat.pending_vulnerable_units, new_timer)
	combat.pending_vulnerable_units.assign([])

	# Step 5: apply the two played cards (player choice + random) to their sides.
	var opposite := SIDE_ENEMY if side == SIDE_PLAYER else SIDE_PLAYER
	var player_card_id := str(cycle.drawn_cards[card_index].get("card_id", ""))
	if _apply_omen_card(player_card_id, side, new_timer, game_state):
		return game_state  # Repent halt: remaining card not applied this cycle step
	if cycle.random_assignment_index >= 0:
		var random_card_id := str(cycle.drawn_cards[cycle.random_assignment_index].get("card_id", ""))
		_apply_omen_card(random_card_id, opposite, new_timer, game_state)
	return game_state


# Apply one played omen card to a side (HLD-OMEN-005). Returns true if a Repent
# card halted further card processing (it set pending_repent_slots).
# @Spec: HLD-OMEN-005, HLD-COMBAT-015, -018, -019, LLD-OMEN-CARD-020
func _apply_omen_card(card_id: String, side: String, timer: int, game_state: GameState) -> bool:
	if card_id == "":
		return false
	var card = _content.get_omen_card(card_id) if _content != null else null
	if card == null:
		return false

	# Repent steered to the player side has special interactive handling.
	if card.card_id == "repent" and side == SIDE_PLAYER:
		return _apply_repent(game_state)

	if card.status_id != "":
		for unit in _units_on_side(game_state, side):
			if card.requires_tag != "" and not _unit_has_tag(unit, card.requires_tag):
				continue
			StatusRules.apply_to_unit(unit.active_statuses, card.status_id, card.status_magnitude, timer)

	# Non-status card effects (e.g. Elemental Synergy, Sacred Ground) run their
	# handler chain. The concrete handlers land with their Phase-8 content; until
	# then ContentRegistry's boot validator (LLD-ARCH-005) rejects content that
	# references an unregistered handler.
	if not card.handlers.is_empty() and _pipeline != null:
		var ctx := AbilityContext.new(game_state, "", "")
		ctx.content = _content
		ctx.rng = _rng
		_pipeline.execute(card.handlers, ctx)
	return false


# Repent special handling (LLD-ARCH-019 / LLD-OMEN-CARD-020). Returns true if it
# set pending_repent_slots (halting further omen card application this step).
func _apply_repent(game_state: GameState) -> bool:
	var non_empty: Array = []
	for i in game_state.inventory.size():
		if game_state.inventory[i] != null:
			non_empty.append(i)
	var n := non_empty.size()
	if n == 0:
		_heal_unit(game_state.vessel_state, REPENT_HEAL)
		return false
	var combat := game_state.combat_state
	if n == 1:
		combat.pending_repent_slots.assign([non_empty[0]])
		return true
	combat.pending_repent_slots.assign(_pick_two_distinct(non_empty))
	return true


# Pick two distinct entries from a list via the COMBAT stream.
func _pick_two_distinct(indices: Array) -> Array:
	var pool := indices.duplicate()
	var out: Array = []
	for _k in 2:
		if pool.is_empty():
			break
		var j := 0
		if _rng != null:
			j = _rng.randi_range(STREAM_COMBAT, 0, pool.size() - 1)
		out.append(pool[j])
		pool.remove_at(j)
	return out


# The living units on a side: the vessel for "player", the living enemies for
# "enemy". The player is never tagged, so family-specific cards are always safe.
func _units_on_side(game_state: GameState, side: String) -> Array:
	var units: Array = []
	if side == SIDE_PLAYER:
		if game_state.vessel_state != null:
			units.append(game_state.vessel_state)
	elif game_state.combat_state != null:
		for enemy in game_state.combat_state.enemies:
			if enemy.hp > 0:
				units.append(enemy)
	return units


func _unit_has_tag(unit, tag: String) -> bool:
	if not (unit is EnemyState):
		return false  # the player carries no enemy_tags (HLD-OMEN-005)
	var data = _content.get_enemy(unit.enemy_id) if _content != null else null
	return data != null and tag in data.enemy_tags


# Remove a dead enemy's omen card contributions (HLD-OMEN-006): one Tier-1 family
# card copy always; the Tier-2 type card only when this was the last living enemy
# of its type. Cards already drawn into the current cycle are untouched. Called by
# resolve_enemy_death (T5.7). @Spec: HLD-OMEN-006, LLD-ARCH-019
func remove_enemy_omen_cards(unit_id: String, game_state: GameState) -> void:
	var combat := game_state.combat_state
	if combat == null or combat.omen_deck == null:
		return
	var dead := _find_enemy(game_state, unit_id)
	if dead == null:
		return
	var data = _content.get_enemy(dead.enemy_id) if _content != null else null
	if data == null or data.omen_contributions.is_empty():
		return
	_remove_one_card(combat.omen_deck, str(data.omen_contributions[0]))  # Tier 1
	if data.omen_contributions.size() > 1 and not _type_still_alive(game_state, dead.enemy_id, unit_id):
		_remove_one_card(combat.omen_deck, str(data.omen_contributions[1]))  # Tier 2


func _type_still_alive(game_state: GameState, enemy_id: String, exclude_instance: String) -> bool:
	for enemy in game_state.combat_state.enemies:
		if enemy.instance_id == exclude_instance:
			continue
		if enemy.enemy_id == enemy_id and enemy.hp > 0:
			return true
	return false


# Remove one copy of a card from the deck — draw pile first, else discard pile.
func _remove_one_card(deck: OmenDeckState, card_id: String) -> void:
	if not _remove_one_from(deck.draw_pile, card_id):
		_remove_one_from(deck.discard_pile, card_id)


func _remove_one_from(pile: Array, card_id: String) -> bool:
	for i in pile.size():
		if pile[i]["card_id"] == card_id:
			pile.remove_at(i)
			return true
	return false


func _find_enemy(game_state: GameState, unit_id: String) -> EnemyState:
	if game_state.combat_state == null:
		return null
	for enemy in game_state.combat_state.enemies:
		if enemy.instance_id == unit_id:
			return enemy
	return null


## --- Enemy turns & intent engine (T5.5) -------------------------------------

# Resolve every living enemy's turn in order (LLD-ARCH-019 resolve_enemy_turns).
# Iterates a snapshot taken up front so mid-pass summons act next round, not now.
# @Spec: LLD-ARCH-019, HLD-COMBAT-009, HLD-COMBAT-014, HLD-COMBAT-016
func resolve_enemy_turns(game_state: GameState) -> GameState:
	if game_state.combat_state == null:
		return game_state
	var roster: Array = []
	for enemy in game_state.combat_state.enemies:
		roster.append(enemy)
	for enemy in roster:
		if enemy.hp <= 0:
			continue  # died earlier this resolution
		_resolve_one_enemy(enemy, game_state)
		enemy.turns_alive += 1
	return game_state


func _resolve_one_enemy(enemy: EnemyState, game_state: GameState) -> void:
	# Step 0: reset per-turn flags; a stunned enemy skips its whole turn. A stun
	# during a charge cancels the pending release (HLD-COMBAT-014: never fires).
	var was_stunned := enemy.is_stunned
	enemy.is_evading = false
	enemy.is_stunned = false
	if was_stunned:
		enemy.is_charging = false
		return

	# Step 1: a charging enemy releases unconditionally — no roll, no streak/cap.
	if enemy.is_charging:
		enemy.is_charging = false
		var charged := _find_intent(enemy, enemy.last_intent_id, game_state)
		if charged != null:
			_execute_intent(enemy, charged, game_state)
		return

	# Steps 2-3: select the intent (forced / restricted / full pool + cap re-roll).
	var intent := _select_intent(enemy, game_state)
	if intent == null:
		return

	# Step 4: update streak + last_intent_id; set current_intent for display.
	if intent.intent_id == enemy.last_intent_id:
		enemy.intent_streak += 1
	else:
		enemy.intent_streak = 1
	enemy.last_intent_id = intent.intent_id
	enemy.current_intent = intent.intent_id

	# Step 5: Evade. Step 6: begin a Charge→Release (no damage this turn).
	if intent.is_evade:
		enemy.is_evading = true
		return
	if intent.is_charge_release:
		enemy.is_charging = true
		return

	# Step 7: execute the intent.
	_execute_intent(enemy, intent, game_state)


# Steps 2-3: evaluate conditionals (first match short-circuits), then roll; a
# forced intent_id skips the roll and the consecutive cap.
func _select_intent(enemy: EnemyState, game_state: GameState) -> IntentWeight:
	var data = _content.get_enemy(enemy.enemy_id) if _content != null else null
	if data == null:
		return null

	var pool: Array = data.intent_weights
	for cond in data.intent_conditionals:
		if not _condition_met(cond.condition, enemy, game_state):
			continue
		if cond.intent_id != "":
			return _find_intent(enemy, cond.intent_id, game_state)  # forced — no roll/cap
		if not cond.intent_ids.is_empty():
			pool = _restrict_pool(data.intent_weights, cond.intent_ids)
		break  # first matching conditional wins

	# Weighted roll with consecutive-cap re-roll (HLD-COMBAT-009).
	var intent := _weighted_pick(pool)
	var attempts := 0
	while intent != null and _violates_cap(intent, enemy) and attempts < 20:
		intent = _weighted_pick(pool)
		attempts += 1
	return intent


func _violates_cap(intent: IntentWeight, enemy: EnemyState) -> bool:
	return intent.intent_id == enemy.last_intent_id \
		and intent.max_consecutive > 0 \
		and enemy.intent_streak >= intent.max_consecutive


func _restrict_pool(weights: Array, intent_ids: Array) -> Array:
	var pool: Array = []
	for w in weights:
		if w.intent_id in intent_ids:
			pool.append(w)
	return pool


# Weighted random selection over a pool on the COMBAT stream. Weight-0 intents are
# never randomly selected (only reachable via a forced conditional).
func _weighted_pick(pool: Array) -> IntentWeight:
	var total := 0
	for w in pool:
		if w.weight > 0:
			total += w.weight
	if total <= 0:
		return null
	var r := 0
	if _rng != null:
		r = _rng.randi_range(STREAM_COMBAT, 0, total - 1)
	var cumulative := 0
	for w in pool:
		if w.weight <= 0:
			continue
		cumulative += w.weight
		if r < cumulative:
			return w
	return null


func _find_intent(enemy: EnemyState, intent_id: String, game_state: GameState) -> IntentWeight:
	var data = _content.get_enemy(enemy.enemy_id) if _content != null else null
	if data == null:
		return null
	for w in data.intent_weights:
		if w.intent_id == intent_id:
			return w
	return null


# Step 7: damage (hit_count rolls, each evade-checked) → status_apply → handler
# chain → summon. @Spec: HLD-COMBAT-016, HLD-COMBAT-017, HLD-COMBAT-009
func _execute_intent(enemy: EnemyState, intent: IntentWeight, game_state: GameState) -> void:
	var damage_type := _enemy_damage_type(enemy)
	if intent.damage_max > 0:
		for _h in maxi(intent.hit_count, 1):
			var base := intent.damage_min
			if _rng != null:
				base = _rng.randi_range(STREAM_COMBAT, intent.damage_min, intent.damage_max)
			DamageCalculator.resolve_hit(game_state, enemy.instance_id, "player", base, damage_type, _content, _rng)

	if intent.status_apply != "":
		var ticks := _cycle_remaining_ticks(game_state)
		for target in _status_targets(enemy, intent.status_target, game_state):
			StatusRules.apply_to_unit(target.active_statuses, intent.status_apply, intent.status_magnitude, ticks)

	if not intent.handlers.is_empty() and _pipeline != null:
		var ctx := AbilityContext.new(game_state, enemy.instance_id, _handler_target_id(enemy, intent.status_target, game_state))
		ctx.content = _content
		ctx.rng = _rng
		# Inject the cycle remaining ticks so status-applying handlers (e.g.
		# apply_mending_by_burden_tier) use the omen-cycle duration.
		var ticks := _cycle_remaining_ticks(game_state)
		for config in intent.handlers:
			config.params["remaining_ticks"] = ticks
		_pipeline.execute(intent.handlers, ctx)

	if intent.summon_enemy_id != "":
		resolve_enemy_summon(intent.summon_enemy_id, game_state)


func _enemy_damage_type(enemy: EnemyState) -> String:
	var data = _content.get_enemy(enemy.enemy_id) if _content != null else null
	return data.damage_type if data != null else "physical"


# status_target: "player" → the vessel; "self" → the caster; "allies" → every
# living enemy except the caster.
func _status_targets(enemy: EnemyState, status_target: String, game_state: GameState) -> Array:
	match status_target:
		"self":
			return [enemy]
		"allies":
			var allies: Array = []
			for other in game_state.combat_state.enemies:
				if other.instance_id != enemy.instance_id and other.hp > 0:
					allies.append(other)
			return allies
		_:
			return [game_state.vessel_state] if game_state.vessel_state != null else []


# The single target id a handler chain acts on, derived from status_target. For
# "allies" handlers (single-ally buffs like the Witnesses' Mending to The Judge)
# this is the first living ally; handlers may still override via their own params.
func _handler_target_id(enemy: EnemyState, status_target: String, game_state: GameState) -> String:
	match status_target:
		"self":
			return enemy.instance_id
		"allies":
			for other in game_state.combat_state.enemies:
				if other.instance_id != enemy.instance_id and other.hp > 0:
					return other.instance_id
			return ""
		_:
			return "player"


# The current omen cycle's tick budget — the leftover (timer) card's value once
# sides are assigned. Used as remaining_ticks for enemy-applied (individual)
# statuses, which clear at the next omen reset (LLD-OMEN-MECH-006).
# NOTE: with no per-cycle countdown stored, this returns the cycle *length*; a
# status applied mid-cycle therefore lasts a full timer span. Precise mid-cycle
# remaining-tick accounting is an orchestration concern (T6.4) — flagged.
func _cycle_remaining_ticks(game_state: GameState) -> int:
	var combat := game_state.combat_state
	if combat == null or combat.current_cycle == null:
		return 1
	var cycle := combat.current_cycle
	if cycle.sides_assigned and cycle.timer_index >= 0 and cycle.timer_index < cycle.drawn_cards.size():
		return int(cycle.drawn_cards[cycle.timer_index].get("timer_value", 1))
	return 1


# Evaluate an IntentConditional condition string against an enemy + game state.
func _condition_met(condition: String, enemy: EnemyState, game_state: GameState) -> bool:
	var parts := condition.split(":")
	if parts.size() != 2:
		return false
	var key: String = parts[0]
	var n := int(parts[1])
	match key:
		"hp_below_percent":
			return enemy.hp < enemy.max_hp * n / 100.0
		"hp_percent_lte":
			return enemy.hp <= enemy.max_hp * n / 100.0
		"ally_count_above":
			return _ally_count(enemy, game_state) > n
		"ally_count_equals":
			return _ally_count(enemy, game_state) == n
		"turn_number":
			return enemy.turns_alive == n
	return false


func _ally_count(enemy: EnemyState, game_state: GameState) -> int:
	var count := 0
	for other in game_state.combat_state.enemies:
		if other.instance_id != enemy.instance_id and other.hp > 0:
			count += 1
	return count


# Spawn a fresh enemy of enemy_id mid-combat and inject its Tier-1 family card
# (HLD-OMEN-006). @Spec: LLD-ARCH-019, HLD-OMEN-006, HLD-COMBAT-009
func resolve_enemy_summon(enemy_id: String, game_state: GameState) -> GameState:
	var combat := game_state.combat_state
	if combat == null:
		return game_state
	var data = _content.get_enemy(enemy_id) if _content != null else null
	if data == null:
		return game_state

	var spawned := EnemyState.new()
	spawned.enemy_id = enemy_id
	spawned.instance_id = _unique_instance_id(game_state, enemy_id)
	spawned.hp = data.max_hp
	spawned.max_hp = data.max_hp
	spawned.turns_alive = 1
	combat.enemies.append(spawned)

	if combat.omen_deck != null and not data.omen_contributions.is_empty():
		combat.omen_deck.draw_pile.append({
			"card_id": str(data.omen_contributions[0]),
			"timer_value": _roll_single_timer(),
		})
	return game_state


# Smallest unused "<enemy_id>_<n>" suffix.
func _unique_instance_id(game_state: GameState, enemy_id: String) -> String:
	var n := 0
	while true:
		var candidate := "%s_%d" % [enemy_id, n]
		if _find_enemy(game_state, candidate) == null:
			return candidate
		n += 1
	return "%s_0" % enemy_id


# A single timer value from the 25/50/25 distribution (LLD-OMEN-MECH-008) for a
# card injected mid-combat (no count-based split applies to one card).
func _roll_single_timer() -> int:
	if _rng == null:
		return 2
	var r: int = _rng.randi_range(STREAM_COMBAT, 0, 99)
	if r < 25:
		return 1
	if r < 75:
		return 2
	return 3


## --- Player action resolution (T5.6) ----------------------------------------

# Apply one player action and return the updated GameState (LLD-ARCH-019). The
# dispatcher: the two interactive resolutions, the omen-choice resolution
# (LLD-ARCH-024), and the standard action path. Illegal actions log an error and
# return state unchanged (LLD-ARCH-003 — never throw).
# @Spec: LLD-ARCH-019, LLD-ARCH-003, HLD-COMBAT-017, HLD-RUN-007, LLD-OMEN-CARD-020
func resolve_player_action(action: Dictionary, game_state: GameState) -> GameState:
	match str(action.get("type", "")):
		ACTION_READ_THE_ROAD_COMMIT:
			return _resolve_read_the_road(action, game_state)
		ACTION_REPENT_DISCARD:
			return _resolve_repent_discard(action, game_state)
		ACTION_CHOOSE_OMEN:
			return resolve_choose_omen(action, game_state)
		_:
			return _resolve_standard_action(action, game_state)


# READ_THE_ROAD_COMMIT: validate, splice the chosen draw-pile cards to the bottom
# in descending index order, clear the flag. Does NOT advance the omen cycle or
# reset the per-turn flags.
func _resolve_read_the_road(action: Dictionary, game_state: GameState) -> GameState:
	var combat := game_state.combat_state
	if combat == null or not combat.read_the_road_active:
		push_error("READ_THE_ROAD_COMMIT: read_the_road_active is false")
		return game_state

	var draw_pile := combat.omen_deck.draw_pile if combat.omen_deck != null else []
	var send: Array = action.get("send_to_bottom", [])
	# Valid indices: within [0, min(2, size-1)], no duplicates.
	var window := mini(2, draw_pile.size() - 1)
	var seen: Dictionary = {}
	for idx in send:
		var i := int(idx)
		if i < 0 or i > window or seen.has(i):
			push_error("READ_THE_ROAD_COMMIT: invalid send_to_bottom %s" % str(send))
			return game_state
		seen[i] = true

	# Process in descending index order so each pop leaves lower indices valid.
	var ordered: Array = seen.keys()
	ordered.sort()
	ordered.reverse()
	for i in ordered:
		draw_pile.append(draw_pile.pop_at(i))

	combat.read_the_road_active = false
	return game_state


# REPENT_DISCARD: remove the chosen item, heal 5 (clamp), decrement burden (floor
# 0), emit item_discarded, clear the pending slots. Does NOT reset per-turn flags.
# @Spec: LLD-ARCH-019, HLD-RUN-007, LLD-OMEN-CARD-020
func _resolve_repent_discard(action: Dictionary, game_state: GameState) -> GameState:
	var combat := game_state.combat_state
	var slot := int(action.get("slot_index", -1))
	if combat == null or not (slot in combat.pending_repent_slots):
		push_error("REPENT_DISCARD: slot %d not in pending_repent_slots" % slot)
		return game_state

	var item: ItemInstance = game_state.inventory[slot] if slot < game_state.inventory.size() else null
	var item_id := item.item_id if item != null else ""
	game_state.inventory[slot] = null  # null keeps other slot indices stable

	_heal_unit(game_state.vessel_state, REPENT_HEAL)
	game_state.item_burden_score = maxi(game_state.item_burden_score - 1, 0)
	if _signal_bus != null:
		_signal_bus.item_discarded.emit(item_id, slot)
	combat.pending_repent_slots.assign([])
	return game_state


# Standard action: clear prior-turn flags, then Evade or run the ability/item
# handler chain (with charge decrement + weapon preservation + emission).
func _resolve_standard_action(action: Dictionary, game_state: GameState) -> GameState:
	var vessel := game_state.vessel_state
	if vessel != null:
		vessel.is_evading = false
		vessel.is_stunned = false

	var type := str(action.get("type", ""))
	if type == ACTION_EVADE:
		if vessel != null:
			vessel.is_evading = true
		return game_state

	# Resolve the content id (ability_id for USE_ABILITY, the item's id for USE_ITEM).
	var content_id := ""
	var item: ItemInstance = null
	if type == ACTION_USE_ITEM:
		var slot := int(action.get("slot_index", -1))
		if slot < 0 or slot >= game_state.inventory.size() or game_state.inventory[slot] == null:
			push_error("USE_ITEM: invalid slot %d" % slot)
			return game_state
		item = game_state.inventory[slot]
		content_id = item.item_id
	elif type == ACTION_USE_ABILITY:
		content_id = str(action.get("ability_id", ""))
	else:
		push_error("resolve_player_action: unknown action type '%s'" % type)
		return game_state

	var data = _content.get_ability(content_id) if _content != null else null
	if data == null:
		push_error("resolve_player_action: unknown content id '%s'" % content_id)
		return game_state

	# Run the handler chain over a shared context.
	var ctx := AbilityContext.new(game_state, "player", str(action.get("target_id", "")))
	ctx.content = _content
	ctx.rng = _rng
	if _pipeline != null:
		_pipeline.execute(data.handlers, ctx)

	_emit_results(action, ctx.results)
	_consume_charge(type, data, item, vessel, content_id, _all_hits_missed(ctx.results))
	return game_state


# Decrement the charge used by this action. Weapon items (attack + breaks_at_zero)
# preserve their charge on a full miss (HLD-COMBAT-017); consumables always
# decrement; support items decrement per-encounter elsewhere (T3.1), not per use;
# charged abilities decrement their AbilityState; unlimited abilities do nothing.
func _consume_charge(type: String, data: AbilityData, item: ItemInstance, vessel: VesselState, content_id: String, all_missed: bool) -> void:
	if type == ACTION_USE_ITEM:
		if data.action_bucket == "support":
			return  # per-encounter decrement (ChargeManager), not per use
		if data.action_bucket == BUCKET_ATTACK and data.breaks_at_zero and all_missed:
			return  # weapon preservation
		if item != null:
			item.remaining_charges = maxi(item.remaining_charges - 1, 0)
	elif type == ACTION_USE_ABILITY:
		if data.max_charges <= 0 or vessel == null:
			return  # unlimited (default strike) — no charge tracking
		for ability_state in vessel.ability_states:
			if ability_state.ability_id == content_id:
				ability_state.remaining_charges = maxi(ability_state.remaining_charges - 1, 0)
				return


# True only when the action produced damage hits and every one missed (used for
# weapon charge preservation). Non-damage actions return false (charge consumed).
func _all_hits_missed(results: Array) -> bool:
	var saw_hit := false
	for r in results:
		if r is Dictionary and r.has("missed"):
			saw_hit = true
			if not r["missed"]:
				return false
	return saw_hit


# Emit combat-effect signals for the chain's recorded damage results, plus an
# action_resolved summary. No-op without an injected SignalBus.
func _emit_results(action: Dictionary, results: Array) -> void:
	if _signal_bus == null:
		return
	for r in results:
		if not (r is Dictionary and r.has("missed")):
			continue
		if r["missed"]:
			continue
		_signal_bus.damage_dealt.emit("player", str(r.get("target_id", "")), int(r.get("damage", 0)), str(r.get("type", "")))
		if r.get("died", false):
			_signal_bus.unit_died.emit(str(r.get("target_id", "")))
	_signal_bus.action_resolved.emit(action, {"results": results})
