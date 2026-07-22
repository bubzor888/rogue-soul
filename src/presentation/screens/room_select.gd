# @Spec: UI-ROOM-001, UI-ROOM-003, UI-ROOM-004, UI-ROOM-005, UI-ROOM-008, LLD-ARCH-002
extends Control

var _run  # RunController
var _content  # ContentRegistry (for the real per-floor room count)
@onready var _doors: HBoxContainer = $Doors
@onready var _vessel: TextureRect = $VesselSprite
@onready var _progress: HBoxContainer = $ProgressBar

func bind(run, content) -> void:
	_run = run
	_content = content
	if GameConfig.HEADLESS:
		queue_free()  # never render under headless (LLD-ARCH-002)
		return
	_render()

func _render() -> void:
	var vm := RoomSelectViewModel.new(_run.game_state, _run.get_legal_actions(), _floor_total())
	# doors: symbol-only buttons (UI-ROOM-003), exactly two (UI-ROOM-001)
	var rows := vm.door_rows()
	var buttons := [$Doors/DoorButton0, $Doors/DoorButton1]
	for i in buttons.size():
		var btn: TextureButton = buttons[i]
		if i < rows.size():
			btn.texture_normal = load(rows[i]["symbol"])
			var action: Dictionary = rows[i]["action"]
			# submit the paired legal action verbatim
			if not btn.pressed.is_connected(_on_door):
				btn.pressed.connect(_on_door.bind(action))
			btn.visible = true
		else:
			btn.visible = false
	_vessel.texture = load(vm.vessel_sprite())
	_render_segments(vm.total_rooms(), vm.rooms_completed())

func _render_segments(total: int, filled: int) -> void:
	for c in _progress.get_children():
		c.queue_free()
	for i in total:
		var seg := ColorRect.new()
		seg.custom_minimum_size = Vector2(8, 6)
		seg.color = Color.WHITE if i < filled else Color(1, 1, 1, 0.25)
		_progress.add_child(seg)

func _on_door(action: Dictionary) -> void:
	_run.submit_action(action)  # RunController advances the phase; ScreenManager swaps the screen

# The exact room count for this floor (UI-ROOM-008) from content; -1 if unavailable.
func _floor_total() -> int:
	if _content == null:
		return -1
	var fp = _content.get_floor_by_number(_run.game_state.floor_number)
	return fp.total_rooms() if fp != null else -1
