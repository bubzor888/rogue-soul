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
