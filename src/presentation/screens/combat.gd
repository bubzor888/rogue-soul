# @Spec: UI-COMBAT-001, UI-COMBAT-002, UI-COMBAT-003, UI-COMBAT-004, UI-COMBAT-006, UI-COMBAT-007, UI-COMBAT-008, UI-COMBAT-009, UI-COMBAT-011, UI-OMEN-001, LLD-PLATFORM-004, LLD-ARCH-002
#
# combat.gd — the COMBAT view. Mounts once on the COMBAT phase_changed, then self-
# refreshes on SignalBus combat signals and after every submit (the whole turn loop
# runs without a phase change). Each refresh rebuilds a fresh CombatViewModel and
# renders the enemy formation, unit stacks, omen badge, and the current interaction
# mode: omen draw overlay (UI-OMEN-001), repent/read-road prompts, or the standard
# action bar + selection sheet + target selection (UI-COMBAT-007..-011). Never builds
# an action itself — submits the view-model's paired legal action verbatim.
extends Control

var _run
var _content

# targeting state
var _pending_action: Dictionary = {}
var _valid_targets: Array = []
var _targeting := false

# sheet mode: "bucket" (header cancels) | "read_the_road" (header commits) | "repent"
var _sheet_mode := "bucket"
var _rtr_selected: Dictionary = {}  # draw-pile index -> true (cards to send to bottom)

# omen overlay two-step flow (UI-OMEN-003..-008): "cards" → "side" → reveal
var _omen_state := ""
var _omen_chosen_index := -1
var _omen_revealing := false     # blocks signal-driven _refresh during the reveal
var _omen_slots: Array = []      # per drawn card: {node, effect_box, duration_box, tag}
var _rtr_slots: Array = []       # Read-the-Road: per card {index, sel_lbl}

var _enemy_cells: Dictionary = {}  # instance_id -> cell Control

@onready var _board: Control = $Board
@onready var _enemy_area: Control = $Board/EnemyArea
@onready var _vessel_stack: VBoxContainer = $Board/VesselStack
@onready var _omen_badge: Label = $Board/OmenBadge
@onready var _support_btn: Button = $Board/ActionBar/SupportBtn
@onready var _action_btn: Button = $Board/ActionBar/ActionBtn
@onready var _consumable_btn: Button = $Board/ActionBar/ConsumableBtn
@onready var _end_turn_btn: Button = $Board/ActionBar/EndTurnBtn
@onready var _fx: Control = $FxLayer
@onready var _sheet: PanelContainer = $Sheet
@onready var _sheet_list: VBoxContainer = $Sheet/SheetBox/SheetScroll/SheetList
@onready var _sheet_header: Button = $Sheet/SheetBox/SheetHeader
@onready var _omen_overlay: ColorRect = $OmenOverlay
@onready var _omen_cards: VBoxContainer = $OmenOverlay/OmenCards
@onready var _omen_prompt_main: Label = $OmenOverlay/OmenPromptMain
@onready var _omen_prompt_sub: Label = $OmenOverlay/OmenPromptSub
@onready var _enemy_zone: Button = $OmenOverlay/EnemyZone
@onready var _vessel_zone: Button = $OmenOverlay/VesselZone
@onready var _staged_card: PanelContainer = $OmenOverlay/StagedCard

func bind(run, content) -> void:
	_run = run
	_content = content
	if GameConfig.HEADLESS:
		queue_free()  # never render under headless (LLD-ARCH-002)
		return
	_wire_buttons()
	_connect_signals()
	_refresh()

func _wire_buttons() -> void:
	_support_btn.pressed.connect(_on_bucket.bind("support"))
	_action_btn.pressed.connect(_on_action_button)
	_consumable_btn.pressed.connect(_on_bucket.bind("consumable"))
	_end_turn_btn.pressed.connect(_on_end_turn)
	_sheet_header.pressed.connect(_on_sheet_header)
	_enemy_zone.pressed.connect(_on_omen_side.bind("enemy"))
	_vessel_zone.pressed.connect(_on_omen_side.bind("player"))
	_omen_prompt_main.mouse_filter = Control.MOUSE_FILTER_IGNORE  # decorative — never block a zone
	_omen_prompt_sub.mouse_filter = Control.MOUSE_FILTER_IGNORE

# @Spec: LLD-PLATFORM-004 — every meaningful event has a visual representation.
func _connect_signals() -> void:
	SignalBus.turn_started.connect(_on_event)
	SignalBus.action_resolved.connect(_on_action_resolved)
	SignalBus.status_applied.connect(_on_event3)
	SignalBus.status_cleared.connect(_on_event2)
	SignalBus.unit_died.connect(_on_event1)
	SignalBus.omen_drawn.connect(_on_event1)
	SignalBus.omen_applied.connect(_on_event2)
	SignalBus.item_broken.connect(_on_event2)
	SignalBus.damage_dealt.connect(_on_damage_dealt)

func _exit_tree() -> void:
	for s in [SignalBus.turn_started, SignalBus.action_resolved, SignalBus.status_applied,
			SignalBus.status_cleared, SignalBus.unit_died, SignalBus.omen_drawn,
			SignalBus.omen_applied, SignalBus.item_broken, SignalBus.damage_dealt]:
		pass  # connections auto-drop when this node frees; explicit disconnect not required

# Signal adapters (varied arg counts) → a single refresh.
func _on_event(_a = null) -> void: _refresh()
func _on_event1(_a) -> void: _refresh()
func _on_event2(_a, _b) -> void: _refresh()
func _on_event3(_a, _b, _c) -> void: _refresh()
func _on_action_resolved(_action: Dictionary, _result: Dictionary) -> void: _refresh()

func _on_damage_dealt(_source_id: String, target_id: String, amount: int, type: String) -> void:
	_spawn_damage_number(target_id, amount, type)
	_refresh()

# ---- master render --------------------------------------------------------

func _refresh() -> void:
	if _omen_revealing:
		return  # hold the board steady while the omen reveal animation plays
	if _run == null or _run.game_state == null or _run.game_state.combat_state == null:
		return
	var legal: Array = _run.get_legal_actions()
	var vm := CombatViewModel.new(_run.game_state, legal, _content)
	_render_enemies(vm)
	_render_vessel(vm)
	_omen_badge.text = "Omen draw in: %d" % vm.omen_countdown()

	if vm.has_omen_choice():
		_show_omen(legal)
		return

	# Read the Road (Pilgrim): peek the top draw-pile cards and send some to the bottom.
	if not _first_of(legal, "READ_THE_ROAD_COMMIT").is_empty():
		_open_read_the_road(vm)
		return

	_hide_omen()  # neither omen selection nor Read the Road is active

	# Repent (the Judge): one forced discard per revealed slot.
	var repents := _repent_actions(legal)
	if not repents.is_empty():
		_open_repent(repents)
		return

	_render_action_bar(vm)

func _render_enemies(vm: CombatViewModel) -> void:
	if not _targeting:
		for c in _enemy_area.get_children():
			c.queue_free()
		_enemy_cells.clear()
		var positions := vm.enemy_positions()
		var stacks := vm.enemy_stacks()
		for i in stacks.size():
			var cell := _build_enemy_cell(stacks[i], positions[i] if i < positions.size() else {"x": 0.5, "y": 0.27, "scale": 1.0})
			_enemy_area.add_child(cell)
			_enemy_cells[str(stacks[i]["instance_id"])] = cell

func _build_enemy_cell(stack: Dictionary, pos: Dictionary) -> Control:
	var cell := VBoxContainer.new()
	cell.anchor_left = pos["x"]; cell.anchor_right = pos["x"]
	cell.anchor_top = pos["y"]; cell.anchor_bottom = pos["y"]
	cell.grow_horizontal = Control.GROW_DIRECTION_BOTH
	cell.grow_vertical = Control.GROW_DIRECTION_BOTH
	cell.alignment = BoxContainer.ALIGNMENT_CENTER
	var scale: float = float(pos.get("scale", 1.0))

	# intent icon (UI-COMBAT-003)
	if str(stack["intent_icon"]) != "":
		var intent := TextureRect.new()
		intent.texture = load(str(stack["intent_icon"]))
		intent.custom_minimum_size = Vector2(24, 24) * scale
		intent.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		intent.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cell.add_child(intent)

	var sprite := TextureRect.new()
	sprite.texture = load(str(stack["sprite"]))
	sprite.custom_minimum_size = Vector2(84, 84) * scale
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cell.add_child(sprite)

	var hp = load("res://src/presentation/components/hp_bar.tscn").instantiate()
	hp.custom_minimum_size = Vector2(84, 8) * Vector2(scale, 1.0)
	hp.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cell.add_child(hp)
	hp.set_hp(int(stack["hp"]["cur"]), int(stack["hp"]["max"]))

	var statuses = load("res://src/presentation/components/status_row.tscn").instantiate()
	statuses.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cell.add_child(statuses)
	statuses.render(stack["statuses"], 4)

	# whole cell tappable for target selection (UI-COMBAT-011)
	cell.mouse_filter = Control.MOUSE_FILTER_STOP
	cell.gui_input.connect(_on_enemy_input.bind(str(stack["instance_id"])))
	return cell

func _render_vessel(vm: CombatViewModel) -> void:
	for c in _vessel_stack.get_children():
		c.queue_free()
	var stack := vm.vessel_stack()
	if stack.is_empty():
		return
	var sprite := TextureRect.new()
	sprite.texture = load(str(stack["sprite"]))
	sprite.custom_minimum_size = Vector2(90, 90)
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_vessel_stack.add_child(sprite)
	var hp = load("res://src/presentation/components/hp_bar.tscn").instantiate()
	hp.custom_minimum_size = Vector2(90, 10)
	_vessel_stack.add_child(hp)
	hp.set_hp(int(stack["hp"]["cur"]), int(stack["hp"]["max"]))
	var statuses = load("res://src/presentation/components/status_row.tscn").instantiate()
	_vessel_stack.add_child(statuses)
	statuses.render(stack["statuses"], 4)

# ---- action bar (UI-COMBAT-007/-008) --------------------------------------

func _render_action_bar(vm: CombatViewModel) -> void:
	_board.get_node("ActionBar").visible = true
	# Action circle relabels to End Turn once the mandatory Action is spent (UI-COMBAT-008).
	var action_used := vm.is_action_used()
	_action_btn.text = "End Turn" if action_used else "Action"
	_support_btn.disabled = vm.is_support_used() or vm.bucket_rows("support").is_empty()
	_consumable_btn.disabled = vm.is_consumable_used() or vm.bucket_rows("consumable").is_empty()
	_end_turn_btn.visible = not vm.end_turn_action().is_empty() and not action_used

func _on_action_button() -> void:
	var vm := _vm()
	if vm.is_action_used():
		_on_end_turn()  # circle has become End Turn (UI-COMBAT-008)
	else:
		_on_bucket("action")

func _on_bucket(bucket: String) -> void:
	_sheet_mode = "bucket"
	var rows := _vm().bucket_rows(bucket)
	if bucket == "action":
		var ev := _vm().evade_action()  # Evade leads the Action sheet (above the weapons)
		if not ev.is_empty():
			rows = rows.duplicate()
			rows.push_front({"label": "Evade", "icon": "", "summary": "no damage this turn",
				"charges": {}, "requires_target": false, "targets": [], "action": ev})
	_populate_sheet(rows)
	_show_sheet(true)

func _on_end_turn() -> void:
	var et := _vm().end_turn_action()
	if not et.is_empty():
		_submit(et)

# ---- selection sheet (UI-COMBAT-009/-010) ---------------------------------

func _populate_sheet(rows: Array) -> void:
	for c in _sheet_list.get_children():
		c.queue_free()
	_sheet_header.text = "Cancel"
	_sheet_header.disabled = false
	for row in rows:
		_sheet_list.add_child(_build_sheet_row(row))

func _build_sheet_row(row: Dictionary) -> Control:
	var btn := Button.new()
	var charges := _charge_text(row.get("charges", {}))
	var summary := str(row.get("summary", ""))
	btn.text = "%s   %s   %s" % [str(row["label"]), summary, charges]
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.pressed.connect(_on_row_selected.bind(row))
	return btn

func _charge_text(charges: Dictionary) -> String:
	if charges.is_empty():
		return ""
	if charges.get("unlimited", false):
		return "(unlimited)"
	return "(%d/%d)" % [int(charges.get("remaining", 0)), int(charges.get("max", 0))]

func _on_row_selected(row: Dictionary) -> void:
	if bool(row.get("requires_target", false)):
		_enter_targeting(row["action"], row["targets"])
	else:
		_submit(row["action"])

func _show_sheet(open: bool) -> void:
	_sheet.visible = open

func _close_sheet() -> void:
	_show_sheet(false)

# ---- target selection (UI-COMBAT-011) -------------------------------------

func _enter_targeting(action_template: Dictionary, targets: Array) -> void:
	_pending_action = action_template
	_valid_targets = targets
	_targeting = true
	_show_sheet(false)
	_omen_badge.text = "Tap a target"
	for id in _enemy_cells:
		var cell: Control = _enemy_cells[id]
		cell.modulate = Color(1.4, 1.2, 0.4) if targets.has(id) else Color(0.6, 0.6, 0.6)

func _on_enemy_input(event: InputEvent, instance_id: String) -> void:
	if not _targeting:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not _valid_targets.has(instance_id):
			return
		var action := _pending_action.duplicate()
		action["target_id"] = instance_id
		_exit_targeting()
		_submit(action)

func _exit_targeting() -> void:
	_targeting = false
	_pending_action = {}
	_valid_targets = []
	for id in _enemy_cells:
		(_enemy_cells[id] as Control).modulate = Color.WHITE

# ---- omen overlay: two-step draw → choose card → choose side → reveal ------
# @Spec: UI-OMEN-001, UI-OMEN-003, UI-OMEN-004, UI-OMEN-005, UI-OMEN-006, UI-OMEN-008

func _show_omen(legal: Array) -> void:
	_omen_overlay.visible = true
	_board.get_node("ActionBar").visible = false
	_show_sheet(false)
	_omen_state = "cards"
	_omen_chosen_index = -1
	_staged_card.visible = false
	_enemy_zone.visible = false
	_vessel_zone.visible = false
	_omen_cards.modulate = Color.WHITE
	_omen_cards.mouse_filter = Control.MOUSE_FILTER_STOP  # reset after a prior side-step set it IGNORE
	_omen_prompt_main.text = "Choose an Omen"
	_omen_prompt_sub.text = "Tap a card to select it"
	_build_omen_cards(legal)

func _build_omen_cards(legal: Array) -> void:
	for c in _omen_cards.get_children():
		c.queue_free()
	_omen_slots.clear()
	var vm := OmenOverlayViewModel.new(_run.game_state, legal, _content)
	var cards := vm.cards()
	for i in cards.size():
		_omen_slots.append(_build_omen_slot(cards[i], i))

# One card slot = an effect box (icon + name + desc) beside a duration box (number).
# Both boxes are separate so the reveal step can hide one while the other holds place.
func _build_omen_slot(card: Dictionary, index: int) -> Dictionary:
	var slot := PanelContainer.new()
	slot.custom_minimum_size = Vector2(0, 78)
	slot.mouse_filter = Control.MOUSE_FILTER_STOP
	slot.clip_contents = true
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	slot.add_child(row)

	var desc_text := "Applies %s to chosen side" % str(card["name"]) if str(card["status_id"]) != "" else str(card["name"])
	var effect_box := _make_effect_box(str(card["name"]), desc_text, str(card["effect_icon"]))

	var duration_box := PanelContainer.new()
	duration_box.custom_minimum_size = Vector2(52, 0)
	var dur_col := VBoxContainer.new()
	dur_col.alignment = BoxContainer.ALIGNMENT_CENTER
	var num := Label.new()
	num.text = str(card["duration"])
	num.add_theme_font_size_override("font_size", 26)
	num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dur_col.add_child(num)
	var tlabel := Label.new()
	tlabel.text = "turns"
	tlabel.modulate = Color(1, 1, 1, 0.6)
	tlabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dur_col.add_child(tlabel)
	duration_box.add_child(dur_col)

	row.add_child(effect_box)
	row.add_child(duration_box)

	var tag := Label.new()
	tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tag.modulate = Color(1, 1, 1, 0.65)
	tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var wrap := VBoxContainer.new()
	wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrap.add_child(slot)
	wrap.add_child(tag)
	_omen_cards.add_child(wrap)

	# The slot's contents must not swallow the tap — only the slot (STOP) handles gui_input.
	_ignore_mouse_recursive(row)
	slot.gui_input.connect(_on_omen_card_input.bind(index))
	return {"wrap": wrap, "slot": slot, "effect_box": effect_box, "duration_box": duration_box, "tag": tag}

# Shared effect box (icon + name + wrapped description) used by omen cards and Read-the-
# Road cards, so both read identically. Top-aligned with a line of top padding.
func _make_effect_box(display_name: String, desc_text: String, effect_icon: String) -> PanelContainer:
	var effect_box := PanelContainer.new()
	effect_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	effect_box.clip_contents = true
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_bottom", 6)
	effect_box.add_child(margin)
	var eff_row := HBoxContainer.new()
	eff_row.add_theme_constant_override("separation", 12)
	margin.add_child(eff_row)
	if effect_icon != "":
		var icon := TextureRect.new()
		icon.texture = load(effect_icon)
		icon.custom_minimum_size = Vector2(28, 28)
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		eff_row.add_child(icon)
	var text_col := VBoxContainer.new()
	text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_col.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	var name_lbl := Label.new()
	name_lbl.text = display_name
	name_lbl.add_theme_font_size_override("font_size", 14)
	text_col.add_child(name_lbl)
	if desc_text != "":
		var desc := Label.new()
		desc.text = desc_text
		desc.modulate = Color(1, 1, 1, 0.7)
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc.add_theme_font_size_override("font_size", 11)
		desc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		text_col.add_child(desc)
	eff_row.add_child(text_col)
	return effect_box

# ---- Read the Road: same card layout as the omen draw, minus the duration box; the
# right box shows the toggle state, and a Commit button sits below the cards. ----------

func _open_read_the_road(vm: CombatViewModel) -> void:
	_omen_overlay.visible = true
	_board.get_node("ActionBar").visible = false
	_show_sheet(false)
	_omen_state = "read_the_road"
	_rtr_selected.clear()
	_enemy_zone.visible = false
	_vessel_zone.visible = false
	_staged_card.visible = false
	_omen_cards.modulate = Color.WHITE
	_omen_cards.mouse_filter = Control.MOUSE_FILTER_STOP
	_omen_prompt_main.text = "Read the Road"
	_omen_prompt_sub.text = "Tap to toggle cards"
	_build_rtr_cards(vm)

func _build_rtr_cards(vm: CombatViewModel) -> void:
	for c in _omen_cards.get_children():
		c.queue_free()
	_rtr_slots.clear()
	for card in vm.read_the_road_cards():
		_rtr_slots.append(_build_rtr_slot(card, int(card["index"])))
	var commit := Button.new()
	commit.text = "Commit"
	commit.custom_minimum_size = Vector2(0, 40)
	commit.pressed.connect(_commit_read_the_road)
	_omen_cards.add_child(commit)

func _build_rtr_slot(card: Dictionary, index: int) -> Dictionary:
	var slot := PanelContainer.new()
	slot.custom_minimum_size = Vector2(0, 78)
	slot.mouse_filter = Control.MOUSE_FILTER_STOP
	slot.clip_contents = true
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	slot.add_child(row)

	var status_id := str(card["status_id"])
	var effect_icon := ArtPaths.status_icon(status_id) if status_id != "" else ""
	var desc_text := "Applies %s to chosen side" % str(card["name"]) if status_id != "" else str(card["name"])
	var effect_box := _make_effect_box(str(card["name"]), desc_text, effect_icon)

	# Right box shows the toggle state instead of a duration.
	var sel_box := PanelContainer.new()
	sel_box.custom_minimum_size = Vector2(72, 0)
	var sel_lbl := Label.new()
	sel_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sel_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	sel_box.add_child(sel_lbl)

	row.add_child(effect_box)
	row.add_child(sel_box)

	var wrap := VBoxContainer.new()
	wrap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrap.add_child(slot)
	_omen_cards.add_child(wrap)

	_ignore_mouse_recursive(row)
	slot.gui_input.connect(_on_rtr_card_input.bind(index))
	var s := {"index": index, "sel_lbl": sel_lbl}
	_update_rtr_indicator(s)
	return s

func _on_rtr_card_input(event: InputEvent, index: int) -> void:
	if _omen_state != "read_the_road":
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _rtr_selected.has(index):
			_rtr_selected.erase(index)
		else:
			_rtr_selected[index] = true
		for s in _rtr_slots:
			if int(s["index"]) == index:
				_update_rtr_indicator(s)

func _update_rtr_indicator(s: Dictionary) -> void:
	var lbl: Label = s["sel_lbl"]
	if _rtr_selected.has(int(s["index"])):
		lbl.text = "SEND\n↓ BOTTOM"
		lbl.modulate = Color("c9a24a")
	else:
		lbl.text = "keep"
		lbl.modulate = Color(1, 1, 1, 0.3)

# Make `node` and every Control under it transparent to the mouse. Used both to let a
# card slot's contents pass taps up to the slot, and to let the whole receded card stack
# (container included — a STOP container blocks clicks in the gaps between cards) pass
# taps through to the omen target zones behind it.
func _ignore_mouse_recursive(node: Node) -> void:
	if node is Control:
		(node as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in node.get_children():
		_ignore_mouse_recursive(child)

func _on_omen_card_input(event: InputEvent, index: int) -> void:
	if _omen_state != "cards":
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_choose_omen_card(index)

# Step 1 → 2: the chosen card docks centered (effect only) and the board zones pulse.
func _choose_omen_card(index: int) -> void:
	_omen_chosen_index = index
	_omen_state = "side"
	_omen_prompt_main.text = "Choose a side"
	_omen_prompt_sub.text = "Tap the ally or enemy zone"
	_omen_cards.modulate = Color(1, 1, 1, 0.12)  # whole stack recedes (UI-OMEN-005)
	_populate_staged(index)
	_staged_card.visible = true
	_enemy_zone.visible = true
	_vessel_zone.visible = true
	_pulse(_enemy_zone)
	_pulse(_vessel_zone)
	# The receded cards + staged card must not swallow taps meant for the pulsing zones.
	_ignore_mouse_recursive(_omen_cards)
	_staged_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ignore_mouse_recursive(_staged_card)

func _populate_staged(index: int) -> void:
	for c in _staged_card.get_children():
		c.queue_free()
	var slot: Dictionary = _omen_slots[index]
	var vm := OmenOverlayViewModel.new(_run.game_state, _run.get_legal_actions(), _content)
	var card: Dictionary = vm.cards()[index]
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	if str(card["effect_icon"]) != "":
		var icon := TextureRect.new()
		icon.texture = load(str(card["effect_icon"]))
		icon.custom_minimum_size = Vector2(36, 36)
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		row.add_child(icon)
	var name_lbl := Label.new()
	name_lbl.text = str(card["name"])
	name_lbl.add_theme_font_size_override("font_size", 18)
	row.add_child(name_lbl)
	_staged_card.add_child(row)

# Step 2 → 3: submit the chosen card + tapped side, then reveal in place.
func _on_omen_side(side_key: String) -> void:
	if _omen_state != "side" or _omen_chosen_index < 0:
		return
	var vm := OmenOverlayViewModel.new(_run.game_state, _run.get_legal_actions(), _content)
	var actions := vm.side_actions(_omen_chosen_index)
	if not actions.has(side_key):
		return
	_omen_revealing = true  # freeze the board through the reveal (status_applied refreshes are held)
	_run.submit_action(actions[side_key])
	_reveal_omen()

# Step 3: cards resolve without repositioning — chosen hides, the enemy's auto-applied
# card shows effect only, the leftover shows its number (the new countdown). UI-OMEN-008.
func _reveal_omen() -> void:
	_omen_state = "reveal"
	_staged_card.visible = false
	_enemy_zone.visible = false
	_vessel_zone.visible = false
	_omen_cards.modulate = Color.WHITE
	_omen_prompt_main.text = "Placing the rest"
	_omen_prompt_sub.text = ""
	var cycle = _run.game_state.combat_state.current_cycle
	if cycle != null:
		for i in _omen_slots.size():
			var s: Dictionary = _omen_slots[i]
			if i == cycle.player_choice_index:
				(s["slot"] as Control).modulate = Color(1, 1, 1, 0)  # hidden, space kept
			elif i == cycle.random_assignment_index:
				(s["duration_box"] as Control).modulate = Color(1, 1, 1, 0)
				(s["tag"] as Label).text = "auto-applied"
			elif i == cycle.timer_index:
				(s["effect_box"] as Control).modulate = Color(1, 1, 1, 0)
				(s["tag"] as Label).text = "becomes timer"
	get_tree().create_timer(1.3).timeout.connect(_finish_omen)

func _finish_omen() -> void:
	_omen_revealing = false
	_omen_overlay.visible = false
	_omen_state = ""
	_refresh()  # the turn has begun — show the action bar (badge shows the new countdown)

func _pulse(node: Control) -> void:
	var tw := create_tween().set_loops()
	tw.tween_property(node, "modulate:a", 0.55, 0.7)
	tw.tween_property(node, "modulate:a", 1.0, 0.7)

func _hide_omen() -> void:
	if _omen_state == "reveal":
		return  # don't yank the overlay out from under the reveal animation
	_omen_overlay.visible = false

func _commit_read_the_road() -> void:
	var indices: Array = _rtr_selected.keys()
	indices.sort()
	_rtr_selected.clear()
	_submit({"type": "READ_THE_ROAD_COMMIT", "send_to_bottom": indices})

# ---- Repent (the Judge) forced discard ------------------------------------

func _repent_actions(legal: Array) -> Array:
	var out: Array = []
	for a in legal:
		if str(a.get("type", "")) == "REPENT_DISCARD":
			out.append(a)
	return out

func _open_repent(repents: Array) -> void:
	_sheet_mode = "repent"
	_board.get_node("ActionBar").visible = false
	for c in _sheet_list.get_children():
		c.queue_free()
	_sheet_header.text = "Repent — choose a card to discard"
	_sheet_header.disabled = true  # forced — no cancel
	for a in repents:
		var btn := Button.new()
		btn.text = "Discard slot %d" % int(a.get("slot_index", -1))
		btn.pressed.connect(_submit.bind(a))
		_sheet_list.add_child(btn)
	_show_sheet(true)

# The sheet header cancels a bucket sheet (repent's header is disabled; Read the Road
# now lives on the omen overlay, not the sheet).
func _on_sheet_header() -> void:
	_close_sheet()

func _first_of(legal: Array, type: String) -> Dictionary:
	for a in legal:
		if str(a.get("type", "")) == type:
			return a
	return {}

# ---- feedback + submit ----------------------------------------------------

func _spawn_damage_number(target_id: String, amount: int, type: String) -> void:
	var lbl := Label.new()
	lbl.text = "-%d" % amount
	lbl.modulate = ArtPaths.damage_tint(type)
	lbl.add_theme_font_size_override("font_size", 22)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var cell: Control = _enemy_cells.get(target_id)
	if cell != null:
		lbl.global_position = cell.global_position + Vector2(20, -10)
	else:
		lbl.anchor_left = 0.5; lbl.anchor_top = 0.5
	_fx.add_child(lbl)
	var tw := create_tween()
	tw.tween_property(lbl, "position:y", lbl.position.y - 40, 0.6)
	tw.parallel().tween_property(lbl, "modulate:a", 0.0, 0.6)
	tw.tween_callback(lbl.queue_free)

func _vm() -> CombatViewModel:
	return CombatViewModel.new(_run.game_state, _run.get_legal_actions(), _content)

func _submit(action: Dictionary) -> void:
	_close_sheet()
	_run.submit_action(action)
	# The whole enemy phase resolves synchronously inside submit_action; refresh once
	# on the settled state (signals during the phase also refresh, which is harmless).
	if is_inside_tree():
		_refresh()
