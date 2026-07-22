# @Spec: UI-LOOT-002, UI-LOOT-004, UI-LOOT-005, UI-LOOT-006
#
# LootViewModel — maps LOOT_SELECTION GameState + the legal CHOOSE_LOOT/DECLINE_LOOT
# actions to the loot display: an inventory count strip (held items tallied by bucket,
# UI-LOOT-002) and one typed card per offer paired with its CHOOSE_LOOT action. Pure/
# headless; the view formats the raw values via DisplayText/ArtPaths. Card display
# values are extracted from the ability's handler chain (deal_damage / apply_status /
# cleanse_status params) — never from top-level AbilityData fields, which don't exist.
class_name LootViewModel
extends RefCounted

var _gs: GameState
var _legal: Array
var _content

func _init(gs: GameState, legal_actions: Array, content) -> void:
	_gs = gs
	_legal = legal_actions
	_content = content

# @Spec: UI-LOOT-002
# Held items tallied by category (weapons/support/consumables) from each item's bucket.
func count_strip() -> Dictionary:
	var strip := {"weapons": 0, "support": 0, "consumables": 0}
	for item in _gs.inventory:
		if item == null:
			continue
		var d = _content.get_ability(item.item_id) if _content != null else null
		if d == null:
			continue
		match d.action_bucket:
			"attack": strip["weapons"] += 1
			"support": strip["support"] += 1
			"consumable": strip["consumables"] += 1
	return strip

# One card per loot offer, paired with its CHOOSE_LOOT action.
func offer_cards() -> Array:
	var cards: Array = []
	for offer_id in _gs.navigation_state.loot_offers:
		var d = _content.get_ability(str(offer_id)) if _content != null else null
		if d == null:
			continue
		cards.append(_card_for(str(offer_id), d))
	return cards

# @Spec: UI-LOOT-008
func decline_action() -> Dictionary:
	for a in _legal:
		if str(a.get("type", "")) == "DECLINE_LOOT":
			return a
	return {}

# --- internals -------------------------------------------------------------

func _card_for(item_id: String, d) -> Dictionary:
	var kind := _kind_of(str(d.action_bucket))
	var card := {
		"kind": kind,
		"name": str(d.display_name),
		"damage": 0,
		"damage_type": "",
		"hits": "single",
		"effect": {},
		"target": "",
		"charges": int(d.max_charges),
		"action": _choose_loot_action(item_id),
	}
	if kind == "weapon":
		# UI-LOOT-004: damage/type from the deal_damage handler params.
		var dd := _handler_params(d, "deal_damage")
		card["damage"] = int(dd.get("base_damage", 0))
		card["damage_type"] = str(dd.get("damage_type", "physical"))
		card["hits"] = str(dd.get("mode", "single"))
	else:
		# UI-LOOT-005/-006: effect from apply_status (fallback cleanse_status).
		var eff := _effect_params(d)
		if not eff.is_empty():
			card["effect"] = {"status_id": str(eff.get("status_id", "")), "magnitude": int(eff.get("magnitude", 0))}
			card["target"] = str(eff.get("target", "target"))
	return card

func _kind_of(bucket: String) -> String:
	match bucket:
		"attack": return "weapon"
		"support": return "support"
		"consumable": return "consumable"
		_: return bucket

func _handler_params(d, handler_id: String) -> Dictionary:
	for h in d.handlers:
		if h != null and str(h.handler_id) == handler_id:
			return h.params
	return {}

# consumable/support effect: prefer apply_status, else cleanse_status.
func _effect_params(d) -> Dictionary:
	var p := _handler_params(d, "apply_status")
	if not p.is_empty():
		return p
	return _handler_params(d, "cleanse_status")

func _choose_loot_action(item_id: String) -> Dictionary:
	for a in _legal:
		if str(a.get("type", "")) == "CHOOSE_LOOT" and str(a.get("item_id", "")) == item_id:
			return a
	return {}
