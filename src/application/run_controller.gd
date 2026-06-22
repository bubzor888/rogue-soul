# @Spec: LLD-ARCH-016
#
# RunController — the run orchestrator (LLD-ARCH-016). An Application-layer Node
# (NOT an autoload) created when a run begins and freed at RUN_END. It owns the
# GameState and the phase state machine, drives the combat round loop, fires
# replenishment events to ChargeManager, emits save triggers, and performs the
# floor transition. It knows nothing of rendering — it communicates via SignalBus.
#
# It is the single object the AIPlayerAgent (and, in MVP2, the UI) talks to:
# get_legal_actions()/submit_action() route every decision through ActionInjector
# (LLD-ARCH-003), then RunController advances the phase based on what was submitted.
#
# MVP1 scope & simplifications (flagged):
#   - Single floor (Floor 3 → the Judge → completion); the multi-floor transition
#     machinery (_floor_transition) exists for MVP3+ but the final floor ends the run.
#   - One enemy per combat encounter: EnemyData carries no encounter-count and
#     FloorProfile no boss composition, so multi-enemy encounters (3 Wolves, the
#     Judge's two Witnesses) await an encounter-composition schema. The round loop is
#     roster-size agnostic, so this is purely a setup simplification.
#   - Omen sources = the vessel's (and bound companion's) omen_contributions; enemy
#     contributions are derived by the resolver (HLD-OMEN-006).
class_name RunController
extends Node

const RunPhase := GameState.RunPhase

## Save trigger kinds (LLD-ARCH-016). The canonical enum will live on SaveManager
## (T6.5); these int values are what save_requested carries until then.
enum SaveType { BACKGROUND, CHECKPOINT }

# Injected collaborators.
var _rng
var _content
var _signal_bus
var _pipeline
var _resolver: CombatResolver
var _injector: ActionInjector
var _nav: NavigationModel
var _loot: LootGenerator
var _charges: ChargeManager

# Run state.
var game_state: GameState
var outcome: String = ""          # "" until RUN_END, then "death" | "completion"
var turn_count: int = 0           # player turns started
var floors_completed: int = 0

# Combat bookkeeping.
var _current_elite: bool = false  # active combat draws elite loot?
var _in_boss: bool = false        # active combat is the floor boss?
var _dead_processed: Dictionary = {}  # enemy instance_ids whose death was resolved
var _pending_triggered_room_type: String = ""  # encounter-countdown trigger (HLD-ITEMS-003)


# Inject dependencies and build the collaborators. Call once before start_run.
# `content` is a ContentRegistry-style provider; `rng` an RNGService-style stream rng.
func configure(rng, content, signal_bus) -> void:
	_rng = rng
	_content = content
	_signal_bus = signal_bus
	_pipeline = AbilityPipeline.with_default_handlers()
	_resolver = CombatResolver.new(rng, content, _pipeline, signal_bus)
	_charges = ChargeManager.new(Callable(content, "get_ability"))
	_nav = NavigationModel.new(rng)
	_loot = LootGenerator.new(rng, content)
	_injector = ActionInjector.new(_resolver, _charges, content, signal_bus)


## --- Run lifecycle ----------------------------------------------------------

# Seed the streams, build the initial state, and enter NAVIGATION with the first
# door choice. @Spec: LLD-ARCH-016, LLD-ARCH-008, HLD-RUN-007
func start_run(seed: int, vessel_id: String) -> void:
	if _rng != null and _rng.has_method("seed_run"):
		_rng.seed_run(seed)
	game_state = _build_initial_state(seed, vessel_id)
	_set_phase(RunPhase.NAVIGATION)
	_fire_replenish(ReplenishEvents.FLOOR_START)
	_generate_doors()


# The agent/UI surface: the legal actions for the current phase (via ActionInjector).
func get_legal_actions() -> Array:
	return _injector.get_legal_actions(game_state)


# The agent/UI surface: apply one decision (through ActionInjector, LLD-ARCH-003),
# then advance the phase machine based on what was submitted.
func submit_action(action: Dictionary) -> void:
	_injector.submit_action(action, game_state)
	_advance(action)


func is_finished() -> bool:
	return game_state != null and game_state.run_phase == RunPhase.RUN_END


## --- Initial state ----------------------------------------------------------

func _build_initial_state(seed: int, vessel_id: String) -> GameState:
	var gs := GameState.new()
	gs.run_seed = seed
	gs.floor_number = 3  # MVP1: Floor 3
	gs.navigation_state = NavigationState.new()

	var vd: VesselData = _content.get_vessel(vessel_id)
	var vessel := VesselState.new()
	vessel.vessel_id = vessel_id
	vessel.hp = vd.max_hp if vd != null else 0
	vessel.max_hp = vd.max_hp if vd != null else 0
	if vd != null:
		for ability_id in vd.ability_ids:
			var ad: AbilityData = _content.get_ability(ability_id)
			var ast := AbilityState.new()
			ast.ability_id = ability_id
			ast.remaining_charges = ad.max_charges if ad != null else 0
			vessel.ability_states.append(ast)
	gs.vessel_state = vessel

	# Starting items + burden init (+1 per starting item — HLD-RUN-007).
	if vd != null:
		for item_id in vd.starting_item_ids:
			var id_data: AbilityData = _content.get_ability(item_id)
			var item := ItemInstance.new()
			item.item_id = item_id
			item.remaining_charges = id_data.max_charges if id_data != null else 0
			gs.inventory.append(item)
		gs.item_burden_score = vd.starting_item_ids.size()
		if vd.bound_companion_id != "":
			gs.bound_companion = _build_companion(vd.bound_companion_id)
	return gs


func _build_companion(companion_id: String) -> CompanionState:
	var cs := CompanionState.new()
	cs.companion_id = companion_id
	var cd: CompanionData = _content.get_companion(companion_id)
	if cd != null:
		cs.companion_timer = cd.initial_timer
	return cs


## --- Navigation -------------------------------------------------------------

func _generate_doors() -> void:
	# A pending encounter-countdown trigger (e.g. the Worn Map) replaces the next room
	# with a forced single-door beat instead of the normal two-door choice (HLD-ITEMS-003).
	if _pending_triggered_room_type != "":
		var room_type := _pending_triggered_room_type
		_pending_triggered_room_type = ""
		game_state.navigation_state.doors_ahead.assign(
			_nav.generate_triggered_beat(room_type, game_state, _profile()))
		return
	game_state.navigation_state.doors_ahead.assign(_nav.generate_doors(game_state, _profile()))


func _profile() -> FloorProfile:
	return _content.get_floor_by_number(game_state.floor_number)


func _advance(action: Dictionary) -> void:
	match game_state.run_phase:
		RunPhase.NAVIGATION:
			_post_navigation(action)
		RunPhase.COMBAT:
			_post_combat(action)
		RunPhase.LOOT_SELECTION:
			_post_loot(action)


func _post_navigation(action: Dictionary) -> void:
	if str(action.get("type", "")) != ActionInjector.ACTION_CHOOSE_DOOR:
		return
	var door := _find_door(str(action.get("room_id", "")))
	if door == null:
		return
	# Background save the moment the door is confirmed (LLD-ARCH-016).
	_emit_save(SaveType.BACKGROUND)
	game_state.navigation_state.doors_ahead.assign([])
	if door.room_type == NavigationModel.ROOM_COMPANION:
		_enter_companion_beat(door.encounter_id)
	else:
		_enter_combat(door.encounter_id, door.room_type)


func _find_door(room_id: String) -> DoorData:
	for d in game_state.navigation_state.doors_ahead:
		if d.room_id == room_id:
			return d
	return null


# Resolve a forced temporary-companion beat (HLD-ITEMS-003 / LLD-FLOOR-BEATS-003): the
# companion joins (one-temp-companion limit, HLD-COMPANION-004 — a new one replaces any
# existing), the floor's companion offer is marked used, and the beat consumes a room
# slot (rooms_completed++, total floor count unchanged). No combat, no loot — control
# returns to NAVIGATION (or the boss if this was the last room).
# @Spec: HLD-COMPANION-001, HLD-COMPANION-004, HLD-DOOR-001, LLD-FLOOR-BEATS-003
func _enter_companion_beat(companion_id: String) -> void:
	game_state.temporary_companion = _build_companion(companion_id)
	game_state.navigation_state.companion_offered_this_floor = true
	if _signal_bus != null:
		_signal_bus.room_entered.emit(NavigationModel.ROOM_COMPANION, companion_id)
	game_state.navigation_state.rooms_completed_this_floor += 1
	_complete_encounter()
	if _nav.is_boss_next(game_state, _profile()):
		_enter_boss()
	else:
		_set_phase(RunPhase.NAVIGATION)
		_generate_doors()


# Per-encounter bookkeeping run after any completed non-boss encounter (HLD-ITEMS-003):
# decrement Support (durability) items once (ChargeManager), then finalise any that
# reached 0 — an encounter-countdown item (Worn Map) sets the pending triggered room
# and is removed; an ordinary support item breaks (item_broken). Both decrement burden
# (item fully spent, HLD-RUN-007). @Spec: HLD-ITEMS-003, HLD-ITEMS-005, HLD-RUN-007
func _complete_encounter() -> void:
	for slot in _charges.decrement_support_items(game_state):
		var item: ItemInstance = game_state.inventory[slot]
		if item == null:
			continue
		var data: AbilityData = _content.get_ability(item.item_id)
		game_state.inventory[slot] = null
		game_state.item_burden_score = maxi(game_state.item_burden_score - 1, 0)
		if data != null and data.is_encounter_countdown:
			_pending_triggered_room_type = data.triggered_room_type
		elif _signal_bus != null:
			_signal_bus.item_broken.emit(item.item_id, slot)


## --- Combat entry & round loop ----------------------------------------------

func _enter_combat(encounter_id: String, room_type: String) -> void:
	_current_elite = room_type == NavigationModel.ROOM_ELITE_COMBAT
	_dead_processed = {}
	var combat := CombatState.new()
	combat.omen_deck = OmenDeckState.new()
	var ed: EnemyData = _content.get_enemy(encounter_id)
	if ed != null:
		# Encounter size per LLD-ENEMIES-002: pre/post-elite counts for normal rooms;
		# elite gate and boss spawn one (elites are solo; boss composition is T8.4).
		for i in _encounter_count(ed, room_type):
			var e := EnemyState.new()
			e.enemy_id = encounter_id
			e.instance_id = "%s_%d" % [encounter_id, i]
			e.hp = ed.max_hp
			e.max_hp = ed.max_hp
			e.turns_alive = 1
			combat.enemies.append(e)
	game_state.combat_state = combat

	_fire_replenish(ReplenishEvents.ENCOUNTER_START)
	if _signal_bus != null:
		_signal_bus.room_entered.emit(room_type, encounter_id)
		_signal_bus.combat_started.emit(combat)
	_set_phase(RunPhase.COMBAT)

	# Assemble the deck and open the first omen cycle (pauses for CHOOSE_OMEN).
	_resolver.assemble_omen_deck(_omen_sources(), game_state)
	_resolver.resolve_omen_cycle_start(game_state)


# Number of enemies to spawn for an encounter (LLD-ENEMIES-002). Elite-gate and boss
# rooms spawn one; normal combat rooms use the enemy's pre- or post-elite count
# based on whether the elite gate has been passed. @Spec: LLD-ENEMIES-002, LLD-ENEMIES-009
func _encounter_count(ed: EnemyData, room_type: String) -> int:
	if room_type != NavigationModel.ROOM_COMBAT:
		return 1  # elite gate (solo) / boss
	var profile := _profile()
	var gate := profile.elite_gate_room() if profile != null else 0
	var post_elite := game_state.navigation_state.rooms_completed_this_floor >= gate
	return maxi(ed.post_elite_count if post_elite else ed.pre_elite_count, 1)


func _omen_sources() -> Array:
	var ids: Array = []
	var vd: VesselData = _content.get_vessel(game_state.vessel_state.vessel_id)
	if vd != null:
		ids.append_array(vd.omen_contributions)
	if game_state.bound_companion != null:
		var cd: CompanionData = _content.get_companion(game_state.bound_companion.companion_id)
		if cd != null:
			ids.append_array(cd.omen_contributions)
	return ids


func _post_combat(action: Dictionary) -> void:
	var type := str(action.get("type", ""))

	# Omen choice just resolved → begin the player's turn (reset buckets).
	if type == CombatResolver.ACTION_CHOOSE_OMEN:
		var cycle := game_state.combat_state.current_cycle
		if cycle != null and cycle.sides_assigned:
			_begin_player_turn()
		return

	# A player action may have killed an enemy; process deaths then check for end.
	_process_deaths()
	if _check_combat_end():
		return

	if type == CombatResolver.ACTION_END_TURN:
		_run_enemy_phase()


func _begin_player_turn() -> void:
	_resolver.begin_player_turn(game_state)
	turn_count += 1


# Companion turn_end → enemy turn → omen tick → (new cycle | next player turn), with
# death/end checks. Companions act at the end of the player's turn, before the enemies
# (HLD-COMPANION-003).
func _run_enemy_phase() -> void:
	_resolver.resolve_companion_trigger("turn_end", game_state)
	_process_deaths()
	if _check_combat_end():
		return
	_resolver.end_player_turn(game_state)
	_resolver.resolve_enemy_turns(game_state)
	_process_deaths()
	if _check_combat_end():
		return

	_resolver.resolve_omen_tick(game_state)
	_process_deaths()
	if _check_combat_end():
		return

	var cycle := game_state.combat_state.current_cycle
	if cycle != null and cycle.ticks_remaining <= 0:
		# Cycle expired → draw the next one and pause for CHOOSE_OMEN (shifts may kill).
		_resolver.resolve_omen_cycle_start(game_state)
		_process_deaths()
		if _check_combat_end():
			return
	else:
		_begin_player_turn()


# Resolve the death consequences (omen card removal, on-death status/summons) of any
# enemy at 0 HP exactly once. @Spec: LLD-ARCH-019, HLD-OMEN-006
func _process_deaths() -> void:
	if game_state.combat_state == null:
		return
	for enemy in game_state.combat_state.enemies:
		if enemy.hp <= 0 and not _dead_processed.has(enemy.instance_id):
			_dead_processed[enemy.instance_id] = true
			_resolver.resolve_enemy_death(enemy.instance_id, game_state)


# Returns true (and ends combat) if the vessel died or all enemies are dead.
func _check_combat_end() -> bool:
	var vessel := game_state.vessel_state
	if vessel.hp <= 0:
		# A companion may intercept lethal damage (HLD-COMPANION-003).
		_resolver.check_vessel_death_intercept(game_state)
		if vessel.hp <= 0:
			_end_combat(false)
			return true
		return false
	if _living_enemy_count() == 0:
		_end_combat(true)
		return true
	return false


func _living_enemy_count() -> int:
	var n := 0
	for enemy in game_state.combat_state.enemies:
		if enemy.hp > 0:
			n += 1
	return n


func _end_combat(victory: bool) -> void:
	_fire_replenish(ReplenishEvents.ENCOUNTER_END)
	if _signal_bus != null:
		_signal_bus.combat_ended.emit("victory" if victory else "defeat")
	var was_boss := _in_boss
	game_state.combat_state = null

	if not victory:
		_end_run("death")
		return

	if was_boss:
		# Floor boss defeated → checkpoint, then finish the floor.
		_emit_save(SaveType.CHECKPOINT)
		_finish_floor()
		return

	# Standard/elite combat room completed → encounter bookkeeping (Support decrement /
	# Worn Map trigger), then loot.
	game_state.navigation_state.rooms_completed_this_floor += 1
	_complete_encounter()
	game_state.navigation_state.loot_offers.assign(_loot.generate_loot_offers(game_state, _current_elite))
	_set_phase(RunPhase.LOOT_SELECTION)


## --- Loot -------------------------------------------------------------------

# ActionInjector has already applied CHOOSE_LOOT/DECLINE_LOOT (item add + burden +
# offers clear). Advance to the next room, or enter the boss if all rooms are done.
func _post_loot(_action: Dictionary) -> void:
	_current_elite = false
	if _nav.is_boss_next(game_state, _profile()):
		_enter_boss()
	else:
		_set_phase(RunPhase.NAVIGATION)
		_generate_doors()


func _enter_boss() -> void:
	_in_boss = true
	_enter_combat(_profile().boss_enemy_id, "boss")


## --- Floor transition / run end ---------------------------------------------

func _finish_floor() -> void:
	floors_completed += 1
	# A temporary companion whose departure condition never fired departs after the boss
	# (HLD-COMPANION-001 / HLD-RUN-006).
	game_state.temporary_companion = null
	# MVP1 is a single floor: the Judge's defeat completes the run. The multi-floor
	# transition processing (HLD-RUN-006) lives in _floor_transition() for MVP3+.
	_end_run("completion")


# End-of-floor processing before the next floor begins (HLD-RUN-006): floor_end
# replenish, full HP restore, temporary companion departs, bound companion persists.
# Used by multi-floor runs (MVP3+); unit-tested directly for MVP1. @Spec: HLD-RUN-006
func _floor_transition(to_floor: int) -> void:
	var from_floor := game_state.floor_number
	_fire_replenish(ReplenishEvents.FLOOR_END)
	if game_state.vessel_state != null:
		game_state.vessel_state.hp = game_state.vessel_state.max_hp
	game_state.temporary_companion = null
	game_state.floor_number = to_floor
	if _signal_bus != null:
		_signal_bus.floor_transitioned.emit(from_floor, to_floor)


func _end_run(run_outcome: String) -> void:
	outcome = run_outcome
	_in_boss = false
	_set_phase(RunPhase.RUN_END)
	if is_inside_tree():
		queue_free()


## --- Helpers ----------------------------------------------------------------

func _set_phase(new_phase: int) -> void:
	var old_phase := game_state.run_phase
	game_state.run_phase = new_phase
	if _signal_bus != null:
		_signal_bus.phase_changed.emit(new_phase, old_phase)


func _fire_replenish(event_id: String) -> void:
	_charges.fire_replenish_event(game_state, event_id)


func _emit_save(save_type: int) -> void:
	if _signal_bus != null:
		_signal_bus.save_requested.emit(save_type)
