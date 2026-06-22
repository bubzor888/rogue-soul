# @Spec: HLD-COMBAT-006, HLD-COMBAT-015, HLD-COMBAT-018, HLD-COMBAT-019, LLD-ARCH-018
#
# StatusRules — shared domain logic for *applying* status effects: colon-encoding
# split, stacking rules, and unit resolution. Used by the status handlers (T4.2)
# and by CombatResolver's omen application (T5.4). Pure static domain helper.
#
# Note: the per-tick *effects* of these statuses (Burning damage, Poison
# escalation, Chilled accumulation, ...) are resolved in T5.3 — this file only
# governs how a status instance is created/merged when applied.
class_name StatusRules
extends RefCounted

## Re-application adds to existing magnitude (HLD-COMBAT-018).
const MAGNITUDE_ADDITIVE := ["burning", "poisoned", "bleed"]

## Re-application keeps the higher magnitude (HLD-COMBAT-019).
const MAX_WINS := ["hardened", "emboldened", "mending"]

## Re-application is a no-op (HLD-COMBAT-015).
const IDEMPOTENT := ["chilled"]

## Statuses whose effect fires once at the omen shift (remaining_ticks == 0)
## rather than per tick (death_mark/shocked/exposed — see LLD-ARCH-023).
const SHIFT_TRIGGER := ["shocked", "exposed", "death_mark"]


# Split a (possibly colon-encoded) status id into [status_id, string_param].
# "vulnerable:fire" -> ["vulnerable", "fire"]; "burning" -> ["burning", ""].
# @Spec: LLD-ARCH-018
static func split_status_id(raw: String) -> Array:
	var idx := raw.find(":")
	if idx == -1:
		return [raw, ""]
	return [raw.substr(0, idx), raw.substr(idx + 1)]


static func default_trigger(status_id: String) -> String:
	return "shift" if status_id in SHIFT_TRIGGER else "tick"


# Apply a status to a unit's active_statuses array (mutated in place), honoring
# the stacking rules. @Spec: HLD-COMBAT-015, HLD-COMBAT-018, HLD-COMBAT-019
static func apply_to_unit(statuses: Array, raw_status_id: String, magnitude: int, remaining_ticks: int) -> void:
	var parts := split_status_id(raw_status_id)
	var sid: String = parts[0]
	var sparam: String = parts[1]

	# Type Convert: only one may be active; a new one replaces any existing
	# (regardless of type). @Spec: HLD-COMBAT (Type Convert)
	if sid == "type_convert":
		_remove_all(statuses, "type_convert")

	var existing := _find(statuses, sid, sparam)
	if existing != null:
		if sid in MAGNITUDE_ADDITIVE:
			existing.magnitude += magnitude
			existing.remaining_ticks = maxi(existing.remaining_ticks, remaining_ticks)
		elif sid in MAX_WINS:
			existing.magnitude = maxi(existing.magnitude, magnitude)
			existing.remaining_ticks = maxi(existing.remaining_ticks, remaining_ticks)
		elif sid in IDEMPOTENT:
			pass  # idempotent — re-application has no effect (HLD-COMBAT-015)
		else:
			existing.remaining_ticks = maxi(existing.remaining_ticks, remaining_ticks)
		return

	var inst := StatusInstance.new()
	inst.status_id = sid
	inst.string_param = sparam
	inst.magnitude = magnitude
	inst.remaining_ticks = remaining_ticks
	inst.trigger = default_trigger(sid)
	statuses.append(inst)


# Resolve a unit's active_statuses array by id. "player" or the vessel_id selects
# the vessel; otherwise an enemy instance_id. Returns the array by reference (so
# callers mutate in place), or null if no such unit.
static func resolve_statuses(game_state: GameState, unit_id: String) -> Array:
	var vessel := game_state.vessel_state
	if vessel != null and (unit_id == "player" or unit_id == vessel.vessel_id):
		return vessel.active_statuses
	if game_state.combat_state != null:
		for enemy in game_state.combat_state.enemies:
			if enemy.instance_id == unit_id:
				return enemy.active_statuses
	return []


static func _find(statuses: Array, status_id: String, string_param: String) -> StatusInstance:
	for s in statuses:
		if s.status_id == status_id and s.string_param == string_param:
			return s
	return null


static func _remove_all(statuses: Array, status_id: String) -> void:
	var kept: Array = []
	for s in statuses:
		if s.status_id != status_id:
			kept.append(s)
	statuses.assign(kept)
