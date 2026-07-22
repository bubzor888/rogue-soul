# @Spec: UI-COMBAT-001, UI-COMBAT-002, UI-COMBAT-003, UI-COMBAT-004, UI-COMBAT-006, UI-COMBAT-009
#
# CombatViewModel — maps COMBAT GameState + the legal combat actions to the combat
# display: enemy formation positions, per-unit stacks (sprite/hp/status/intent), the
# omen countdown, and the three action buckets. Pure/headless. Bucket rows are built
# from get_legal_actions() so all gating (stun, zero-charge, repent, omen-choice,
# read-the-road) is already reflected — the view never re-derives legality. The view
# submits a row's paired action verbatim (filling target_id on enemy tap).
class_name CombatViewModel
extends RefCounted

# Normalized formation constants (fractions of the enemy-area band / screen).
const _Y_SINGLE := 0.27
const _Y_BACK := 0.18
const _Y_FRONT := 0.36
const _SCALE_BACK := 0.8
const _SCALE_FRONT := 1.0

var _gs: GameState
var _legal: Array
var _content

func _init(gs: GameState, legal_actions: Array, content) -> void:
	_gs = gs
	_legal = legal_actions
	_content = content

# --- Formation (UI-COMBAT-001/-002) ----------------------------------------

func enemy_positions() -> Array:
	var n := _enemies().size()
	match n:
		0: return []
		1: return [{"x": 0.5, "y": _Y_SINGLE, "scale": _SCALE_FRONT}]
		2: return [
				{"x": 0.28, "y": _Y_SINGLE, "scale": _SCALE_FRONT},
				{"x": 0.72, "y": _Y_SINGLE, "scale": _SCALE_FRONT},
			]
		3: return [
				{"x": 0.5, "y": _Y_BACK, "scale": _SCALE_BACK},   # back-center (primary = enemies[0])
				{"x": 0.20, "y": _Y_FRONT, "scale": _SCALE_FRONT},
				{"x": 0.80, "y": _Y_FRONT, "scale": _SCALE_FRONT},
			]
		_:
			var out: Array = []
			for i in n:
				out.append({"x": (i + 1.0) / (n + 1.0), "y": _Y_SINGLE, "scale": _SCALE_FRONT})
			return out

# --- Unit stacks (UI-COMBAT-003/-004) --------------------------------------

func enemy_stacks() -> Array:
	var stacks: Array = []
	for e in _enemies():
		stacks.append({
			"instance_id": e.instance_id,
			"sprite": ArtPaths.enemy_sprite(e.enemy_id),
			"intent_icon": ArtPaths.intent_icon(e.current_intent) if e.current_intent != "" else "",
			"hp": {"cur": e.hp, "max": e.max_hp},
			"statuses": _status_ids(e.active_statuses),
		})
	return stacks

func vessel_stack() -> Dictionary:
	var v := _gs.vessel_state
	if v == null:
		return {}
	return {
		"sprite": ArtPaths.vessel_sprite(v.vessel_id),
		"hp": {"cur": v.hp, "max": v.max_hp},
		"statuses": _status_ids(v.active_statuses),
	}

# --- Top bar (UI-COMBAT-006) -----------------------------------------------

func omen_countdown() -> int:
	var c := _gs.combat_state
	if c != null and c.current_cycle != null:
		return c.current_cycle.ticks_remaining
	return 0

# --- Action buckets (UI-COMBAT-009) ----------------------------------------

# Rows for a bucket ("action"|"support"|"consumable"), deduped by ability/slot with
# their valid target set aggregated. requires_target is true when the ability enumerated
# one legal action per living enemy (targeted); untargeted actions keep target_id "".
func bucket_rows(bucket: String) -> Array:
	var by_key: Dictionary = {}
	var order: Array = []
	for a in _legal:
		var t := str(a.get("type", ""))
		var key := ""
		var b := ""
		if t == "USE_ABILITY":
			var aid := str(a.get("ability_id", ""))
			b = _ability_bucket(aid)
			key = "ability:" + aid
		elif t == "USE_ITEM":
			var slot := int(a.get("slot_index", -1))
			if not _item_usable(slot):
				continue  # encounter-countdown items (e.g. Worn Map) decrement passively, not used
			b = _item_bucket(slot)
			key = "item:%d" % slot
		else:
			continue
		if b != bucket:
			continue
		if not by_key.has(key):
			by_key[key] = _new_row(t, a, bucket)
			order.append(key)
		var target_id := str(a.get("target_id", ""))
		if target_id != "":
			by_key[key]["targets"].append(target_id)
	var rows: Array = []
	for key in order:
		var row: Dictionary = by_key[key]
		row["requires_target"] = not (row["targets"] as Array).is_empty()
		rows.append(row)
	return rows

# Non-bucket action-bar affordances the view drives directly.
func evade_action() -> Dictionary:
	return _find_action("EVADE")

func end_turn_action() -> Dictionary:
	return _find_action("END_TURN")

func has_omen_choice() -> bool:
	return not _find_action("CHOOSE_OMEN").is_empty()

# @Spec: LLD-ABILITIES-005 — the top draw-pile cards the player may send to the bottom
# during Read the Road. Window mirrors the resolver: indices 0..min(2, size-1) (top 3).
func read_the_road_cards() -> Array:
	var out: Array = []
	var combat := _gs.combat_state
	if combat == null or combat.omen_deck == null:
		return out
	var draw: Array = combat.omen_deck.draw_pile
	var window: int = mini(2, draw.size() - 1)
	for i in range(window + 1):
		var entry: Dictionary = draw[i]
		var card_id := str(entry.get("card_id", ""))
		var d = _content.get_omen_card(card_id) if _content != null else null
		out.append({
			"index": i,
			"card_id": card_id,
			"name": str(d.display_name) if d != null else card_id,
			"duration": int(entry.get("timer_value", 0)),
			"status_id": str(d.status_id) if d != null else "",
		})
	return out

func is_action_used() -> bool:
	return _gs.combat_state != null and _gs.combat_state.is_action_used

func is_support_used() -> bool:
	return _gs.combat_state != null and _gs.combat_state.is_support_used

func is_consumable_used() -> bool:
	return _gs.combat_state != null and _gs.combat_state.is_consumable_used

# --- internals -------------------------------------------------------------

func _enemies() -> Array:
	return _gs.combat_state.enemies if _gs.combat_state != null else []

func _status_ids(statuses: Array) -> Array:
	var ids: Array = []
	for s in statuses:
		ids.append(s.status_id)
	return ids

func _find_action(type: String) -> Dictionary:
	for a in _legal:
		if str(a.get("type", "")) == type:
			return a
	return {}

func _new_row(type: String, a: Dictionary, bucket: String) -> Dictionary:
	var row := {
		"label": "",
		"icon": ArtPaths.item_icon(_icon_key(bucket)),
		"summary": "",
		"charges": {},
		"requires_target": false,
		"targets": [],
		"action": {},
	}
	if type == "USE_ABILITY":
		var aid := str(a.get("ability_id", ""))
		row["action"] = {"type": "USE_ABILITY", "ability_id": aid, "target_id": ""}
		var d = _content.get_ability(aid) if _content != null else null
		row["label"] = str(d.display_name) if d != null else aid
		row["charges"] = _ability_charges(aid, d)
		row["summary"] = _summary_of(d)
	else:
		var slot := int(a.get("slot_index", -1))
		row["action"] = {"type": "USE_ITEM", "slot_index": slot, "target_id": ""}
		var item = _gs.inventory[slot] if (slot >= 0 and slot < _gs.inventory.size()) else null
		var did = _content.get_ability(item.item_id) if (item != null and _content != null) else null
		row["label"] = str(did.display_name) if did != null else ""
		if item != null and did != null:
			row["charges"] = {"remaining": item.remaining_charges, "max": did.max_charges}
		row["summary"] = _summary_of(did)
	return row

func _ability_bucket(ability_id: String) -> String:
	var d = _content.get_ability(ability_id) if _content != null else null
	return _bucket_from(d.action_bucket) if d != null else "action"

func _item_bucket(slot: int) -> String:
	if slot < 0 or slot >= _gs.inventory.size():
		return "action"
	var item = _gs.inventory[slot]
	if item == null:
		return "action"
	var d = _content.get_ability(item.item_id) if _content != null else null
	return _bucket_from(d.action_bucket) if d != null else "action"

# Whether an inventory item is actively usable in combat. Encounter-countdown items
# (HLD-ITEMS-003, e.g. the Worn Map) decrement automatically per encounter and have no
# active use, so they never appear as a selectable action.
func _item_usable(slot: int) -> bool:
	if slot < 0 or slot >= _gs.inventory.size():
		return false
	var item = _gs.inventory[slot]
	if item == null:
		return false
	var d = _content.get_ability(item.item_id) if _content != null else null
	if d == null:
		return false
	return not d.is_encounter_countdown

# attack + passive (default strike) → the Action bucket; support/consumable map through.
func _bucket_from(action_bucket: String) -> String:
	match action_bucket:
		"support": return "support"
		"consumable": return "consumable"
		_: return "action"

func _icon_key(bucket: String) -> String:
	match bucket:
		"support": return "support"
		"consumable": return "consumable"
		_: return "weapon"

func _ability_charges(ability_id: String, d) -> Dictionary:
	var max_c: int = int(d.max_charges) if d != null else 0
	if max_c == 0:
		return {"unlimited": true}  # Default Strike / passive
	var remaining := max_c
	if _gs.vessel_state != null:
		for ast in _gs.vessel_state.ability_states:
			if ast.ability_id == ability_id:
				remaining = ast.remaining_charges
				break
	return {"remaining": remaining, "max": max_c}

func _summary_of(d) -> String:
	if d == null:
		return ""
	for h in d.handlers:
		if h == null:
			continue
		if str(h.handler_id) == "deal_damage":
			return "%d dmg" % int(h.params.get("base_damage", 0))
		if str(h.handler_id) == "apply_status":
			return str(h.params.get("status_id", ""))
	return ""
