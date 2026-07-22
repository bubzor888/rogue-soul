# @Spec: LLD-ARCH-007, LLD-ARCH-016
#
# ScreenManager — Application autoload that owns scene transitions, reacting to
# SignalBus.phase_changed (LLD-ARCH-007). For MVP1 (headless, no UI) it is a
# no-op: the subscription wiring exists and it tracks the current phase, but it
# instantiates no scenes. Real scene switching lands in MVP2.
#
# Headless purity (LLD-ARCH-002): only this Presentation-adjacent autoload checks
# GameConfig.HEADLESS; under headless it performs no scene work.
#
# No `class_name` (autoload global).
extends Node

## The most recent phase seen (RunPhase int). -1 before any phase_changed.
var current_phase: int = -1

# Phase(int) -> scene resource path (String). Populated by Main at boot so Application
# holds only strings — it never imports a Presentation type (LLD-ARCH-001).
var _phase_scenes: Dictionary = {}
# Where instantiated screens are mounted, and a handle to the live run surface. Both set
# by the presentation Main before the first phase_changed.
var screen_root: Node = null
var active_run = null
var _current_screen: Node = null


func _ready() -> void:
	connect_to_bus(SignalBus)


# Wire the phase listener. Takes the bus explicitly so tests can connect a fresh bus.
func connect_to_bus(bus) -> void:
	bus.phase_changed.connect(_on_phase_changed)


# @Spec: LLD-ARCH-007
func register_phase_scene(phase: int, scene_path: String) -> void:
	_phase_scenes[phase] = scene_path


func scene_path_for_phase(phase: int) -> String:
	return str(_phase_scenes.get(phase, ""))


func _on_phase_changed(new_phase: int, _old_phase: int) -> void:
	current_phase = new_phase
	if GameConfig.HEADLESS:
		return  # headless: no scenes (LLD-ARCH-002)
	var path := scene_path_for_phase(new_phase)
	if path == "" or screen_root == null:
		return  # transitional phases (FLOOR_TRANSITION/RUN_END) have no screen
	if _current_screen != null:
		_current_screen.queue_free()
		_current_screen = null
	var scene: PackedScene = load(path)
	if scene == null:
		return
	_current_screen = scene.instantiate()
	screen_root.add_child(_current_screen)
	# Every screen implements bind(run, content) — duck-typed, no shared base type import.
	if _current_screen.has_method("bind"):
		_current_screen.bind(active_run, ContentRegistry)
