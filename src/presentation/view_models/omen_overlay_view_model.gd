# @Spec: UI-OMEN-003, UI-OMEN-004, UI-OMEN-008
#
# OmenOverlayViewModel — maps the current omen cycle's drawn cards + the legal
# CHOOSE_OMEN actions to the overlay display. Each card has the two-box anatomy
# (UI-OMEN-003): an effect box (icon + DisplayText segment) and a duration box (the
# timer number). side_actions pairs each card index with its two CHOOSE_OMEN actions
# (one per side) for the two-step flow (UI-OMEN-004). Pure/headless.
class_name OmenOverlayViewModel
extends RefCounted

var _gs: GameState
var _legal: Array
var _content

func _init(gs: GameState, legal_actions: Array, content) -> void:
	_gs = gs
	_legal = legal_actions
	_content = content

# One display card per drawn omen, in draw order (fixed positions, UI-OMEN-002/-007).
func cards() -> Array:
	var out: Array = []
	for entry in _drawn():
		var card_id := str(entry.get("card_id", ""))
		var duration := int(entry.get("timer_value", 0))
		var d = _content.get_omen_card(card_id) if _content != null else null
		var status_id := str(d.status_id) if d != null else ""
		var display_name := str(d.display_name) if d != null else card_id
		var effect: Dictionary
		if status_id != "":
			effect = {"bbcode": "[b]%s[/b]" % display_name, "icons": [ArtPaths.status_icon(status_id)]}
		else:
			effect = DisplayText.plain(display_name)
		out.append({
			"card_id": card_id,
			"name": display_name,
			"duration": duration,
			"effect_icon": ArtPaths.status_icon(status_id) if status_id != "" else "",
			"effect": effect,
			"status_id": status_id,
		})
	return out

# @Spec: UI-OMEN-004 — the two CHOOSE_OMEN actions for a card index, keyed by side.
func side_actions(card_index: int) -> Dictionary:
	var sides: Dictionary = {}
	for a in _legal:
		if str(a.get("type", "")) == "CHOOSE_OMEN" and int(a.get("card_index", -1)) == card_index:
			sides[str(a.get("side", ""))] = a
	return sides

func _drawn() -> Array:
	var c := _gs.combat_state
	if c != null and c.current_cycle != null:
		return c.current_cycle.drawn_cards
	return []
