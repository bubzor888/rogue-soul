# @Spec: LLD-ARCH-016, LLD-ARCH-020
#
# GameSession — the presentation-side run driver. It is the human's replacement for
# AIPlayerAgent: it owns the live RunController (a Node child, in-tree so it can render),
# wires ScreenManager to switch screens on phase_changed, and starts the run. Screens
# read/submit through get_legal_actions()/submit_action() exactly as the AI does.
class_name GameSession
extends Node

@export var start_seed: int = 1
@export var start_vessel_id: String = "pilgrim"

var run: RunController

func begin(screen_root: Node) -> void:
	GameConfig.HEADLESS = false  # this is the played, on-screen run
	run = RunController.new()
	add_child(run)
	run.configure(RNGService, ContentRegistry, SignalBus)
	ScreenManager.screen_root = screen_root
	ScreenManager.active_run = run
	run.start_run(start_seed, start_vessel_id)  # fires the first phase_changed -> NAVIGATION
