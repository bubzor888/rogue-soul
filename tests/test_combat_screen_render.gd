# @Spec: UI-COMBAT-001, UI-COMBAT-003, UI-COMBAT-004, LLD-ARCH-016
#
# Renders the real combat screen against a real Pilgrim run driven to COMBAT, inside the
# active test SceneTree (so _ready fires synchronously and @onready node vars resolve,
# exactly as ScreenManager mounts it). This exercises bind()/_refresh() — the node-
# building code the parse/instantiate guard cannot reach — and would have caught the
# null-node / missing-method runtime failures. Sets GameConfig.HEADLESS=false so the
# screen renders instead of self-freeing, and restores it after each test.
extends GdUnitTestSuite

var _prev_headless: bool

func before_test() -> void:
	_prev_headless = GameConfig.HEADLESS
	GameConfig.HEADLESS = false

func after_test() -> void:
	GameConfig.HEADLESS = _prev_headless

func _run_to_combat() -> RunController:
	var rc: RunController = auto_free(RunController.new())
	add_child(rc)
	rc.configure(RNGService, ContentRegistry, SignalBus)
	rc.start_run(1, "pilgrim")
	rc.submit_action(rc.get_legal_actions()[0])  # first door → combat
	return rc

func test_combat_screen_binds_and_renders_units() -> void:
	var rc := _run_to_combat()
	assert_int(rc.game_state.run_phase).is_equal(GameState.RunPhase.COMBAT)

	var screen = load("res://src/presentation/screens/combat.tscn").instantiate()
	add_child(screen)                 # active tree → _ready fires, @onready resolves
	auto_free(screen)
	screen.bind(rc, ContentRegistry)  # → _refresh builds the board

	# Enemy formation + vessel stack were built (UI-COMBAT-001/-004).
	assert_int(screen.get_node("Board/EnemyArea").get_child_count()).is_greater(0)
	assert_int(screen.get_node("Board/VesselStack").get_child_count()).is_greater(0)
	# Combat opens on the Pilgrim's Read the Road → shown on the omen overlay.
	assert_bool(screen.get_node("OmenOverlay").visible).is_true()
	assert_str(screen._omen_state).is_equal("read_the_road")
