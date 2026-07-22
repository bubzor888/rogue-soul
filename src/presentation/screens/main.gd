# @Spec: LLD-PLATFORM-001, LLD-ARCH-016
#
# Main — the MVP2 played-run root. Registers each phase's screen scene path with
# ScreenManager, then tells GameSession to begin() — which starts the RunController and
# drives the first phase_changed, mounting the room-select screen under ScreenRoot.
extends Control

const RunPhase := GameState.RunPhase

@onready var _screen_root: Control = $ScreenRoot
@onready var _session: GameSession = $GameSession

func _ready() -> void:
	ScreenManager.register_phase_scene(RunPhase.NAVIGATION, "res://src/presentation/screens/room_select.tscn")
	ScreenManager.register_phase_scene(RunPhase.COMBAT, "res://src/presentation/screens/combat.tscn")
	ScreenManager.register_phase_scene(RunPhase.LOOT_SELECTION, "res://src/presentation/screens/loot.tscn")
	# NON_COMBAT_EVENT is registered by Plan 2. FLOOR_TRANSITION/RUN_END have no screen in MVP2.
	_session.begin(_screen_root)
