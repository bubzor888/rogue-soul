# @Spec: LLD-ARCH-019, HLD-COMBAT-005, HLD-COMBAT-007, HLD-COMBAT-016, HLD-COMBAT-017, HLD-COMBAT-018, HLD-COMBAT-019
#
# DamageCalculator — the shared 7-step damage resolution routine (LLD-ARCH-019),
# used by both player damage (deal_damage handler) and enemy damage
# (resolve_enemy_turns, T5.5). Multipliers accumulate as float and are floored
# once at the end (7 × 1.5 × 2.0 × 1.5 = 31.5 → 31). Pure static domain helper.
#
# The base damage is an input: player damage is the flat HandlerConfig value;
# enemy damage is pre-rolled [damage_min, damage_max] on the COMBAT stream by the
# caller. The COMBAT-stream evade-miss roll (step 0) is done here when rng is set.
class_name DamageCalculator
extends RefCounted

## RNGService.Stream.COMBAT index (kept local so Domain doesn't touch the autoload
## global; the enum order is stable — NAVIGATION=0, COMBAT=1, LOOT=2, EVENTS=3).
const STREAM_COMBAT := 1

## 35% miss: roll [0,99] on COMBAT, miss if <= 34 (HLD-COMBAT-017).
const EVADE_MISS_MAX := 34


# Resolve one hit: apply the full pipeline, mutate target.hp (clamped at 0), and
# return { missed, damage, type, target_id, died }. @Spec: LLD-ARCH-019
static func resolve_hit(game_state: GameState, attacker_id: String, target_id: String, base_damage: int, base_type: String, content, rng) -> Dictionary:
	var target = _resolve_unit(game_state, target_id)
	if target == null:
		return {"missed": false, "damage": 0, "type": base_type, "target_id": target_id, "died": false}

	# Step 0: evade miss.
	if target.is_evading and rng != null:
		if rng.randi_range(STREAM_COMBAT, 0, 99) <= EVADE_MISS_MAX:
			return {"missed": true, "damage": 0, "type": base_type, "target_id": target_id, "died": false}

	var attacker_statuses := StatusRules.resolve_statuses(game_state, attacker_id)
	var target_statuses: Array = target.active_statuses

	# Step 1: base value + type, with Type Convert override (attacker). Type Convert
	# matches by id only — its string_param IS the conversion type.
	var type := base_type
	var type_convert := _find_by_id(attacker_statuses, "type_convert")
	if type_convert != null:
		type = type_convert.string_param
	var value := float(base_damage)

	# Step 2: Emboldened (physical) flat bonus.
	var emb_physical := _find(attacker_statuses, "emboldened", "physical")
	if emb_physical != null and type == "physical":
		value += float(emb_physical.magnitude)

	# Step 3: Last Stand ×1.5 (hook; MVP3 content).
	if _find(attacker_statuses, "last_stand", "") != null:
		value *= 1.5

	# Step 4: Charge ×2 (consumed after); Emboldened (elemental) ×1.5.
	var charge := _find(attacker_statuses, "charge", "")
	if charge != null:
		value *= 2.0
	if type != "physical" and _find(attacker_statuses, "emboldened", type) != null:
		value *= 1.5

	# Steps 5–7: Resistance ×0.5 / Vulnerability ×1.5, cancelling to ×1.0 if both.
	var resists := _target_resists(target, type, content)
	var vulnerable := _find(target_statuses, "vulnerable", type) != null
	if resists and vulnerable:
		pass  # cancel → ×1.0
	elif resists:
		value *= 0.5
	elif vulnerable:
		value *= 1.5

	var final_damage := int(floor(value))

	# Chilled: flat reduction to the ATTACKER's outgoing damage; never reduces a
	# non-zero hit to 0 (HLD-COMBAT, Chilled). @Spec: HLD-COMBAT-015
	var chilled := _find_by_id(attacker_statuses, "chilled")
	if chilled != null and final_damage > 0:
		final_damage = maxi(final_damage - chilled.magnitude, 1)

	# Hardened absorption — per-hit cap; magnitude is constant (the single
	# StatusInstance.magnitude can't hold both a current budget and a reset value,
	# so "absorbs up to X per tick; resets each tick" is realised as up-to-X per
	# hit, which never depletes — see resolve_omen_tick). @Spec: LLD-ARCH-019
	var hardened := _find(target_statuses, "hardened", "")
	if hardened != null:
		final_damage = maxi(final_damage - hardened.magnitude, 0)

	# Apply (clamp at 0 — never negative HP).
	var was_alive: bool = target.hp > 0
	target.hp = maxi(target.hp - final_damage, 0)
	var died: bool = was_alive and target.hp == 0

	# Charge is consumed on use.
	if charge != null:
		StatusRules._remove_all(attacker_statuses, "charge")

	return {"missed": false, "damage": final_damage, "type": type, "target_id": target_id, "died": died}


# Resolve a unit (VesselState or EnemyState) by id. Both expose hp / is_evading /
# active_statuses; EnemyState additionally carries enemy_id (for resistances).
static func _resolve_unit(game_state: GameState, unit_id: String):
	var vessel := game_state.vessel_state
	if vessel != null and (unit_id == "player" or unit_id == vessel.vessel_id):
		return vessel
	if game_state.combat_state != null:
		for enemy in game_state.combat_state.enemies:
			if enemy.instance_id == unit_id:
				return enemy
	return null


static func _target_resists(target, damage_type: String, content) -> bool:
	if content == null or not (target is EnemyState):
		return false
	var enemy_data = content.get_enemy(target.enemy_id)
	return enemy_data != null and damage_type in enemy_data.resistances


static func _find(statuses: Array, status_id: String, string_param: String) -> StatusInstance:
	for s in statuses:
		if s.status_id == status_id and s.string_param == string_param:
			return s
	return null


static func _find_by_id(statuses: Array, status_id: String) -> StatusInstance:
	for s in statuses:
		if s.status_id == status_id:
			return s
	return null
