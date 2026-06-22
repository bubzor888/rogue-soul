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


func _ready() -> void:
	connect_to_bus(SignalBus)


# Wire the phase listener. Takes the bus explicitly so tests can connect a fresh bus.
func connect_to_bus(bus) -> void:
	bus.phase_changed.connect(_on_phase_changed)


func _on_phase_changed(new_phase: int, _old_phase: int) -> void:
	current_phase = new_phase
	if GameConfig.HEADLESS:
		return  # MVP1: no scenes to switch
	# MVP2: switch to the scene registered for new_phase.
