# @Spec: LLD-ARCH-016, UI-OMEN-001
#
# Faithful mount test: drives a run into COMBAT and lets ScreenManager mount combat.tscn
# on the phase_changed signal — exactly as the real game does — then asserts the screen
# opens on its first interaction (the omen draw / Read-the-Road prompt), NOT a bare,
# empty action bar. This catches the ordering bug where phase_changed(COMBAT) fires
# before the omen cycle is initialised (the screen would render stale pre-turn state).
extends GdUnitTestSuite

var _prev_headless: bool

func before_test() -> void:
	_prev_headless = GameConfig.HEADLESS
	GameConfig.HEADLESS = false

func after_test() -> void:
	GameConfig.HEADLESS = _prev_headless
	# reset the shared ScreenManager autoload state we touched
	ScreenManager.screen_root = null
	ScreenManager.active_run = null
	if ScreenManager._current_screen != null and is_instance_valid(ScreenManager._current_screen):
		ScreenManager._current_screen.queue_free()
	ScreenManager._current_screen = null

func _mount_combat() -> Node:
	var rc: RunController = auto_free(RunController.new())
	add_child(rc)
	rc.configure(RNGService, ContentRegistry, SignalBus)

	var screen_root: Control = auto_free(Control.new())
	add_child(screen_root)
	ScreenManager.screen_root = screen_root
	ScreenManager.active_run = rc
	ScreenManager.register_phase_scene(GameState.RunPhase.COMBAT, "res://src/presentation/screens/combat.tscn")

	rc.start_run(1, "pilgrim")                       # NAVIGATION (no combat scene)
	rc.submit_action(rc.get_legal_actions()[0])      # → _enter_combat → phase_changed → mount combat
	return ScreenManager._current_screen

func test_combat_opens_on_omen_or_readroad_not_bare_action_bar() -> void:
	var screen := _mount_combat()
	assert_object(screen).is_not_null()
	# Combat's first interaction is always an omen draw (or the Pilgrim's Read the Road),
	# so exactly one of the overlay / forced sheet must be active on mount.
	var omen_visible: bool = screen.get_node("OmenOverlay").visible
	var sheet_visible: bool = screen.get_node("Sheet").visible
	assert_bool(omen_visible or sheet_visible) \
		.override_failure_message("Combat mounted on a bare action bar — omen cycle not ready at phase_changed") \
		.is_true()

# The Read-the-Road commit resolves the peek and advances to the omen choice overlay —
# proves the full interaction (not the old empty-commit stub) works through the UI.
func test_read_the_road_commit_advances_to_omen_overlay() -> void:
	var screen := _mount_combat()
	# Pilgrim combat opens on Read the Road → shown on the omen overlay (not the sheet).
	assert_bool(screen.get_node("OmenOverlay").visible).is_true()
	assert_str(screen._omen_state).is_equal("read_the_road")
	assert_int(screen._rtr_slots.size()).is_greater(0)
	# Send the top card to the bottom and commit.
	screen._rtr_selected = {0: true}
	screen._commit_read_the_road()
	# read_the_road resolved → omen choice pending → overlay now in the card-select state.
	assert_bool(screen.get_node("OmenOverlay").visible).is_true()
	assert_str(screen._omen_state).is_equal("cards")

# The two-step omen flow: choose a card (→ side step, staged card + zones), then choose a
# side, which submits CHOOSE_OMEN and resolves the cycle (sides assigned) before the reveal.
func test_omen_choose_card_then_side_resolves_cycle() -> void:
	var screen := _mount_combat()
	screen._rtr_selected = {}
	screen._commit_read_the_road()               # → omen "cards" state
	assert_str(screen._omen_state).is_equal("cards")
	assert_int(screen._omen_slots.size()).is_greater(0)

	# Tap routing: the slot owns gui_input (STOP); its contents must be transparent to the
	# mouse (IGNORE) or they swallow the tap and the card can't be selected.
	var slot0: Dictionary = screen._omen_slots[0]
	assert_int((slot0["slot"] as Control).mouse_filter).is_equal(Control.MOUSE_FILTER_STOP)
	assert_int((slot0["effect_box"] as Control).mouse_filter).is_equal(Control.MOUSE_FILTER_IGNORE)
	assert_int((slot0["duration_box"] as Control).mouse_filter).is_equal(Control.MOUSE_FILTER_IGNORE)

	screen._choose_omen_card(0)                   # step 1 → 2
	assert_str(screen._omen_state).is_equal("side")
	assert_bool(screen.get_node("OmenOverlay/StagedCard").visible).is_true()
	assert_bool(screen.get_node("OmenOverlay/EnemyZone").visible).is_true()
	assert_bool(screen.get_node("OmenOverlay/VesselZone").visible).is_true()

	# The zones must receive taps across their whole rect: the receded card stack
	# (container included) and staged card are transparent; the zones themselves are STOP.
	assert_int((screen._omen_cards as Control).mouse_filter).is_equal(Control.MOUSE_FILTER_IGNORE)
	assert_int((screen.get_node("OmenOverlay/StagedCard") as Control).mouse_filter).is_equal(Control.MOUSE_FILTER_IGNORE)
	assert_int((screen.get_node("OmenOverlay/EnemyZone") as Control).mouse_filter).is_equal(Control.MOUSE_FILTER_STOP)
	assert_int((screen.get_node("OmenOverlay/VesselZone") as Control).mouse_filter).is_equal(Control.MOUSE_FILTER_STOP)

	screen._on_omen_side("player")                # step 2 → 3 (submits CHOOSE_OMEN)
	var rc = ScreenManager.active_run
	assert_bool(rc.game_state.combat_state.current_cycle.sides_assigned).is_true()
	assert_str(screen._omen_state).is_equal("reveal")
