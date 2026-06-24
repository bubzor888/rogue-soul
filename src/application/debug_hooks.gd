# @Spec: LLD-ARCH-014
#
# DebugHooks — the MVP1 headless debug toolkit (LLD-ARCH-014). A static collection
# of code-path hooks (no UI yet) for inspecting and steering a run: force-set HP on
# any unit, keep the player alive (to exercise every room with the random agent),
# force a specific enemy intent, force a loot drop, and read the RNG stream monitor /
# active seed.
#
# Every hook is gated on the single `GameConfig.DEBUG` flag and is a no-op when it is
# false — the tooling ships in every build but stays inert in release (no separate
# debug build). The harness / a future debug UI calls these; the engine never calls
# into them, so nothing in normal play depends on this class.
#
# Application layer: it touches GameState/CombatResolver (Domain) and GameConfig
# (Infrastructure). It holds no state of its own.
class_name DebugHooks
extends RefCounted


# Force-set HP on any unit (player vessel or an enemy by instance_id), clamped to
# [0, max_hp]. @Spec: LLD-ARCH-014
static func set_unit_hp(game_state: GameState, unit_id: String, hp: int) -> void:
	if not GameConfig.DEBUG:
		return
	var unit = _find_unit(game_state, unit_id)
	if unit != null:
		unit.hp = clampi(hp, 0, unit.max_hp)


# Restore the vessel to full HP — call each turn to keep the player alive so a random
# run traverses every room/enemy for content testing. @Spec: LLD-ARCH-014
static func keep_player_alive(game_state: GameState) -> void:
	if not GameConfig.DEBUG:
		return
	var vessel := game_state.vessel_state
	if vessel != null:
		vessel.hp = vessel.max_hp


# Force every enemy that owns it to use `intent_id`, overriding conditionals and the
# weighted roll. Pass "" to clear. @Spec: LLD-ARCH-014
static func force_enemy_intent(resolver: CombatResolver, intent_id: String) -> void:
	if not GameConfig.DEBUG:
		return
	resolver.debug_forced_intent = intent_id


# Override the current loot offers with specific item ids. @Spec: LLD-ARCH-014
static func force_loot_offers(game_state: GameState, item_ids: Array) -> void:
	if not GameConfig.DEBUG:
		return
	if game_state.navigation_state != null:
		game_state.navigation_state.loot_offers.assign(item_ids)


# The RNG stream call-count monitor — per-stream rolls since the last seed_run
# (makes cross-stream contamination visible). @Spec: LLD-ARCH-014, LLD-ARCH-008
static func rng_stream_counts(rng) -> Dictionary:
	if not GameConfig.DEBUG or rng == null:
		return {}
	return {
		"navigation": rng.get_call_count(0),
		"combat": rng.get_call_count(1),
		"loot": rng.get_call_count(2),
		"events": rng.get_call_count(3),
	}


# The active run seed (for display / reproduction). @Spec: LLD-ARCH-014, LLD-ARCH-008
static func active_seed(rng) -> int:
	if not GameConfig.DEBUG or rng == null:
		return 0
	return rng.base_seed


static func _find_unit(game_state: GameState, unit_id: String):
	var vessel := game_state.vessel_state
	if vessel != null and (unit_id == "player" or unit_id == vessel.vessel_id):
		return vessel
	if game_state.combat_state != null:
		for enemy in game_state.combat_state.enemies:
			if enemy.instance_id == unit_id:
				return enemy
	return null
