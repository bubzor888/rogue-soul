# Tests for NavigationModel (T6.2): data-driven Floor 3 generation — the two-door
# choice for each room, the fixed Elite Gate at room 5, the Judge after room 9, the
# pool-exhaustion both-doors rule (MVP1: only combat is in the pool → both doors are
# combat with distinct enemy identities), and determinism on the NAVIGATION stream.
# @Spec: HLD-RUN-004, HLD-RUN-005, HLD-DOOR-001, HLD-DOOR-002, HLD-DOOR-004, LLD-FLOOR-STRUCT-001, LLD-FLOOR-STRUCT-006, LLD-FLOOR-BEATS-004, LLD-FLOOR-BEATS-005, LLD-ARCH-008
extends GdUnitTestSuite


# --- Stubs ------------------------------------------------------------------

# Controlled rng: pops values off a queue (clamped to range), else `default`.
class StubRng:
	var queue: Array = []
	var default: int = 0
	func randi_range(_stream: int, a: int, b: int) -> int:
		var v: int = default
		if not queue.is_empty():
			v = queue.pop_front()
		return clampi(v, a, b)


# A real per-stream seeded rng — same seed ⇒ same sequence (determinism tests).
class SeededRng:
	var _seed: int
	var _rngs: Dictionary = {}
	func _init(s: int) -> void:
		_seed = s
	func randi_range(stream: int, a: int, b: int) -> int:
		if not _rngs.has(stream):
			var r := RandomNumberGenerator.new()
			r.seed = _seed + stream
			_rngs[stream] = r
		return _rngs[stream].randi_range(a, b)


# --- Builders ---------------------------------------------------------------

func _profile(normal: Array, elite: Array = [], pre: int = 4, post: int = 4) -> FloorProfile:
	var p := FloorProfile.new()
	p.floor_id = "floor_3"
	p.floor_number = 3
	p.pre_elite_rooms = pre
	p.post_elite_rooms = post
	p.boss_enemy_id = "the_judge"
	p.normal_enemy_pool.assign(normal)
	p.elite_enemy_pool.assign(elite)
	return p


func _gs(rooms_completed: int) -> GameState:
	var gs := GameState.new()
	gs.floor_number = 3
	gs.navigation_state = NavigationState.new()
	gs.navigation_state.rooms_completed_this_floor = rooms_completed
	return gs


func _model(rng = null) -> NavigationModel:
	return NavigationModel.new(rng)


func _room_types(doors: Array) -> Array:
	var out: Array = []
	for d in doors:
		out.append(d.room_type)
	return out


func _encounter_ids(doors: Array) -> Array:
	var out: Array = []
	for d in doors:
		out.append(d.encounter_id)
	return out


# --- FloorProfile helpers ---------------------------------------------------

# Floor 3 = 4 pre-elite + Elite Gate + 4 post-elite = 9 rooms; Gate at room 5.
func test_profile_total_rooms_and_elite_gate() -> void:
	var p := _profile(["skeleton"], ["bear"], 4, 4)
	assert_int(p.total_rooms()).is_equal(9)
	assert_int(p.elite_gate_room()).is_equal(5)


# --- Standard combat rooms --------------------------------------------------

# Room 1 (rooms_completed 0) presents two combat doors from the normal pool.
func test_room_1_two_combat_doors() -> void:
	var p := _profile(["skeleton", "wolf"])
	var doors := _model(StubRng.new()).generate_doors(_gs(0), p)
	assert_int(doors.size()).is_equal(2)
	assert_array(_room_types(doors)).is_equal(["combat", "combat"])
	for id in _encounter_ids(doors):
		assert_bool(id in ["skeleton", "wolf"]).is_true()


# With ≥2 enemy types available, the two combat doors show distinct identities (HLD-DOOR-002/-004).
func test_combat_doors_distinct_enemies() -> void:
	var p := _profile(["a", "b", "c"])
	var rng := StubRng.new()
	rng.queue = [0, 0]  # first index 0; second index 0 → bumped past 0 → distinct
	var doors := _model(rng).generate_doors(_gs(0), p)
	assert_str(doors[0].encounter_id).is_not_equal(doors[1].encounter_id)


# Pool of one type → both doors show that type (pool exhaustion rule, HLD-DOOR-004).
func test_single_enemy_pool_both_doors_same() -> void:
	var p := _profile(["only_enemy"])
	var doors := _model(StubRng.new()).generate_doors(_gs(0), p)
	assert_array(_room_types(doors)).is_equal(["combat", "combat"])
	assert_array(_encounter_ids(doors)).is_equal(["only_enemy", "only_enemy"])


# The two doors always carry distinct room_ids (for logging / selection).
func test_door_room_ids_distinct() -> void:
	var p := _profile(["skeleton", "wolf"])
	var doors := _model(StubRng.new()).generate_doors(_gs(0), p)
	assert_str(doors[0].room_id).is_not_equal(doors[1].room_id)


# --- Elite Gate (room 5, LLD-FLOOR-BEATS-004) -------------------------------

# Room 5 always offers one elite door + one standard combat door.
func test_elite_gate_at_room_5() -> void:
	var p := _profile(["skeleton"], ["bear", "lightning_elemental"], 4, 4)
	var doors := _model(StubRng.new()).generate_doors(_gs(4), p)  # next room = 5
	assert_int(doors.size()).is_equal(2)
	assert_str(doors[0].room_type).is_equal("elite_combat")
	assert_bool(doors[0].encounter_id in ["bear", "lightning_elemental"]).is_true()
	assert_str(doors[1].room_type).is_equal("combat")
	assert_str(doors[1].encounter_id).is_equal("skeleton")


# The Elite Gate position follows the profile (not hardcoded): pre=2 → gate at room 3.
func test_elite_gate_position_follows_profile() -> void:
	var p := _profile(["skeleton"], ["bear"], 2, 4)
	assert_str(_model(StubRng.new()).generate_doors(_gs(2), p)[0].room_type).is_equal("elite_combat")
	assert_array(_room_types(_model(StubRng.new()).generate_doors(_gs(0), p))).is_equal(["combat", "combat"])


# --- The Judge (after room 9, LLD-FLOOR-BEATS-005) --------------------------

# Once all 9 rooms are complete there is no door choice — the Judge is next.
func test_no_doors_after_last_room() -> void:
	var p := _profile(["skeleton"], ["bear"], 4, 4)
	assert_array(_model(StubRng.new()).generate_doors(_gs(9), p)).is_equal([])


func test_is_boss_next() -> void:
	var p := _profile(["skeleton"], ["bear"], 4, 4)
	assert_bool(_model().is_boss_next(_gs(9), p)).is_true()
	assert_bool(_model().is_boss_next(_gs(8), p)).is_false()
	assert_bool(_model().is_boss_next(_gs(0), p)).is_false()


# --- Determinism & full structure -------------------------------------------

# Same seed ⇒ identical generation (LLD-ARCH-008 NAVIGATION stream determinism).
func test_determinism_same_seed() -> void:
	var p := _profile(["skeleton", "wolf", "zombie", "plague_rat"])
	var a := _model(SeededRng.new(777)).generate_doors(_gs(0), p)
	var b := _model(SeededRng.new(777)).generate_doors(_gs(0), p)
	assert_array(_encounter_ids(a)).is_equal(_encounter_ids(b))


# Walking the whole floor: rooms 1–9 each present a choice; room 5 is the Elite
# Gate (an elite door present); all other rooms are combat-only; after 9 → no doors.
func test_full_nine_room_structure() -> void:
	var p := _profile(["skeleton", "wolf", "zombie"], ["bear", "lightning_elemental"], 4, 4)
	var model := _model(SeededRng.new(42))
	for room in range(1, 10):
		var doors := model.generate_doors(_gs(room - 1), p)
		assert_int(doors.size()).is_equal(2)
		if room == 5:
			assert_bool("elite_combat" in _room_types(doors)).is_true()
		else:
			assert_array(_room_types(doors)).is_equal(["combat", "combat"])
	assert_array(model.generate_doors(_gs(9), p)).is_equal([])
