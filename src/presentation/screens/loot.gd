# @Spec: UI-LOOT-001, UI-LOOT-002, UI-LOOT-004, UI-LOOT-005, UI-LOOT-006, UI-LOOT-007, UI-LOOT-008, LLD-ARCH-002
#
# loot.gd — the LOOT_SELECTION view. Renders the count strip + typed offer cards from
# LootViewModel and drives the ternary choice. Asymmetric commit (UI-LOOT-008): tapping
# a card submits CHOOSE_LOOT immediately; "Leave both" requires a confirm tap before
# DECLINE_LOOT. Never builds an action itself — it submits the VM-paired legal action.
extends Control

var _run
var _content
var _decline_armed := false

@onready var _count_strip: HBoxContainer = $CountStrip
@onready var _loot_image: TextureRect = $LootImage
@onready var _cards: VBoxContainer = $Cards
@onready var _decline: Button = $DeclineBar

func bind(run, content) -> void:
	_run = run
	_content = content
	if GameConfig.HEADLESS:
		queue_free()  # never render under headless (LLD-ARCH-002)
		return
	_render()

func _render() -> void:
	var vm := LootViewModel.new(_run.game_state, _run.get_legal_actions(), _content)
	_render_count_strip(vm.count_strip())
	_loot_image.texture = load(ArtPaths.LOOT_PLACEHOLDER)
	_render_cards(vm.offer_cards())
	_decline.text = "Leave both"
	if not _decline.pressed.is_connected(_on_decline):
		_decline.pressed.connect(_on_decline)

# @Spec: UI-LOOT-002
func _render_count_strip(strip: Dictionary) -> void:
	for c in _count_strip.get_children():
		c.queue_free()
	_add_count("weapon", int(strip["weapons"]))
	_add_count("support", int(strip["support"]))
	_add_count("consumable", int(strip["consumables"]))

func _add_count(category: String, n: int) -> void:
	var icon := TextureRect.new()
	icon.texture = load(ArtPaths.item_icon(category))
	icon.custom_minimum_size = Vector2(22, 22)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_count_strip.add_child(icon)
	var lbl := Label.new()
	lbl.text = "x%d" % n
	_count_strip.add_child(lbl)

func _render_cards(cards: Array) -> void:
	for c in _cards.get_children():
		c.queue_free()
	for card in cards:
		_cards.add_child(_build_card(card))

func _build_card(card: Dictionary) -> Control:
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_STOP  # whole card is tappable (UI-LOOT-008)
	var box := VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(box)

	var name_lbl := Label.new()
	name_lbl.text = str(card["name"])
	name_lbl.add_theme_font_size_override("font_size", 18)
	name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(name_lbl)

	match str(card["kind"]):
		"weapon":
			box.add_child(_weapon_row(card))
			_append_charges(box, int(card["charges"]))
		"consumable":
			box.add_child(_effect_label(card))
		"support":
			box.add_child(_effect_label(card))
			var drain := _plain_label("Drains 1 charge per room")
			box.add_child(drain)
			_append_charges(box, int(card["charges"]))

	var hint := _plain_label("Tap to take")
	hint.modulate = Color(1, 1, 1, 0.5)
	box.add_child(hint)

	var action: Dictionary = card["action"]
	panel.gui_input.connect(_on_card_input.bind(action))
	return panel

# UI-LOOT-004: damage hero number + DamageTypeIcon (shape+tint, no damage-type word).
func _weapon_row(card: Dictionary) -> Control:
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var dmg := Label.new()
	dmg.text = str(card["damage"])
	dmg.add_theme_font_size_override("font_size", 30)
	dmg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(dmg)
	var dti = load("res://src/presentation/components/damage_type_icon.tscn").instantiate()
	dti.set_type(str(card["damage_type"]))
	dti.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(dti)
	if str(card["hits"]) != "single":
		row.add_child(_plain_label("(%s)" % str(card["hits"])))
	return row

# UI-LOOT-005/-006: "Gain/Apply <Status>" with the status icon, via DisplayText grammar.
func _effect_label(card: Dictionary) -> Control:
	var eff: Dictionary = card["effect"]
	var rt := RichTextLabel.new()
	rt.bbcode_enabled = true
	rt.fit_content = true
	rt.scroll_active = false
	rt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rt.custom_minimum_size = Vector2(0, 24)
	if eff.is_empty():
		rt.text = "Support effect"
	else:
		var status_id := str(eff.get("status_id", ""))
		var keyword := status_id.capitalize()
		var verb := "Gain" if str(card["target"]) == "self" else "Apply"
		var seg := DisplayText.effect_line(verb, keyword, status_id)
		rt.text = str(seg["bbcode"])
	return rt

func _append_charges(box: VBoxContainer, charges: int) -> void:
	var dots = load("res://src/presentation/components/charge_dots.tscn").instantiate()
	dots.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(dots)
	dots.render(charges, charges)  # a fresh item shows all charges remaining

func _plain_label(text: String) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return lbl

func _on_card_input(event: InputEvent, action: Dictionary) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_run.submit_action(action)  # CHOOSE_LOOT — immediate (UI-LOOT-008)

# @Spec: UI-LOOT-008 — decline is the guarded side: arm on first tap, submit on second.
func _on_decline() -> void:
	if not _decline_armed:
		_decline_armed = true
		_decline.text = "Tap again to leave both"
		return
	_run.submit_action(LootViewModel.new(_run.game_state, _run.get_legal_actions(), _content).decline_action())
