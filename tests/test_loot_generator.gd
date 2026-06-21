# Tests for LootGenerator (T6.3): the two-item post-combat offer (one durability +
# one consumable) drawn from the tier's pools — normal pools after standard combat,
# elite pools after elite combat — on the LOOT RNG stream only, with empty-pool
# fallbacks. LootGenerator returns item_ids and never mutates GameState.
# @Spec: LLD-ARCH-022, HLD-COMBAT-012, HLD-COMBAT-013, LLD-ARCH-008
extends GdUnitTestSuite

const STREAM_LOOT := 2


# --- Stubs ------------------------------------------------------------------

class StubContent:
	var floors_by_number: Dictionary = {}
	func get_floor_by_number(n: int):
		return floors_by_number.get(n, null)


# Records the stream of every roll so tests can assert LOOT-stream-only usage.
class StubRng:
	var queue: Array = []
	var default: int = 0
	var streams_used: Array = []
	func randi_range(stream: int, a: int, b: int) -> int:
		streams_used.append(stream)
		var v: int = default
		if not queue.is_empty():
			v = queue.pop_front()
		return clampi(v, a, b)


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

func _profile(nd: Array, nc: Array, ed: Array, ec: Array) -> FloorProfile:
	var p := FloorProfile.new()
	p.floor_id = "floor_3"
	p.floor_number = 3
	p.normal_durability_pool.assign(nd)
	p.normal_consumable_pool.assign(nc)
	p.elite_durability_pool.assign(ed)
	p.elite_consumable_pool.assign(ec)
	return p


func _content_with(profile: FloorProfile) -> StubContent:
	var c := StubContent.new()
	if profile != null:
		c.floors_by_number[profile.floor_number] = profile
	return c


func _gs() -> GameState:
	var gs := GameState.new()
	gs.floor_number = 3
	return gs


func _gen(content, rng = null) -> LootGenerator:
	return LootGenerator.new(rng, content)


# --- Tier separation --------------------------------------------------------

# Normal combat draws from the normal pools only.
func test_normal_combat_normal_pools() -> void:
	var p := _profile(["nd1", "nd2"], ["nc1", "nc2"], ["ed1"], ["ec1"])
	var offers := _gen(_content_with(p), StubRng.new()).generate_loot_offers(_gs(), false)
	assert_int(offers.size()).is_equal(2)
	assert_bool(offers[0] in ["nd1", "nd2"]).is_true()   # durability from normal
	assert_bool(offers[1] in ["nc1", "nc2"]).is_true()   # consumable from normal


# Elite combat draws from the elite pools only — no normal-tier items appear.
func test_elite_combat_elite_pools() -> void:
	var p := _profile(["nd1"], ["nc1"], ["ed1", "ed2"], ["ec1", "ec2"])
	var offers := _gen(_content_with(p), StubRng.new()).generate_loot_offers(_gs(), true)
	assert_int(offers.size()).is_equal(2)
	assert_bool(offers[0] in ["ed1", "ed2"]).is_true()
	assert_bool(offers[1] in ["ec1", "ec2"]).is_true()
	for id in offers:
		assert_bool(id in ["nd1", "nc1"]).is_false()     # no normal-tier leakage


# --- One durability, one consumable (HLD-COMBAT-012) ------------------------

func test_one_durability_one_consumable() -> void:
	var p := _profile(["sword", "club"], ["bomb", "salve"], [], [])
	var offers := _gen(_content_with(p), StubRng.new()).generate_loot_offers(_gs(), false)
	assert_bool(offers[0] in ["sword", "club"]).is_true()
	assert_bool(offers[1] in ["bomb", "salve"]).is_true()


# --- Empty-pool fallbacks ---------------------------------------------------

# Empty durability pool → both offers come from the consumable pool.
func test_empty_durability_both_from_consumable() -> void:
	var p := _profile([], ["c1", "c2", "c3"], [], [])
	var offers := _gen(_content_with(p), StubRng.new()).generate_loot_offers(_gs(), false)
	assert_int(offers.size()).is_equal(2)
	for id in offers:
		assert_bool(id in ["c1", "c2", "c3"]).is_true()


# Empty consumable pool → both offers come from the durability pool.
func test_empty_consumable_both_from_durability() -> void:
	var p := _profile(["d1", "d2", "d3"], [], [], [])
	var offers := _gen(_content_with(p), StubRng.new()).generate_loot_offers(_gs(), false)
	assert_int(offers.size()).is_equal(2)
	for id in offers:
		assert_bool(id in ["d1", "d2", "d3"]).is_true()


# Both pools empty → empty offer array (RunController treats as DECLINE_LOOT).
func test_both_pools_empty_returns_empty() -> void:
	var p := _profile([], [], [], [])
	var offers := _gen(_content_with(p), StubRng.new()).generate_loot_offers(_gs(), false)
	assert_array(offers).is_equal([])


# Single-pool fallback yields distinct items when the pool has ≥2 entries.
func test_fallback_distinct_when_possible() -> void:
	var rng := StubRng.new()
	rng.queue = [0, 0]  # first index 0; second bumped past 0 → distinct
	var p := _profile([], ["c1", "c2"], [], [])
	var offers := _gen(_content_with(p), rng).generate_loot_offers(_gs(), false)
	assert_str(offers[0]).is_not_equal(offers[1])


# --- Stream discipline & purity ---------------------------------------------

# Every random selection uses the LOOT stream and no other (LLD-ARCH-008).
func test_uses_loot_stream_only() -> void:
	var p := _profile(["d1", "d2"], ["c1", "c2"], [], [])
	var rng := StubRng.new()
	_gen(_content_with(p), rng).generate_loot_offers(_gs(), false)
	assert_bool(rng.streams_used.size() > 0).is_true()
	for s in rng.streams_used:
		assert_int(s).is_equal(STREAM_LOOT)


# No floor profile for the current floor → empty offers (no crash).
func test_no_profile_returns_empty() -> void:
	var offers := _gen(StubContent.new(), StubRng.new()).generate_loot_offers(_gs(), false)
	assert_array(offers).is_equal([])


# Generation does not mutate GameState (it only returns item_ids).
func test_does_not_mutate_game_state() -> void:
	var p := _profile(["d1"], ["c1"], [], [])
	var gs := _gs()
	var before := gs.to_json()
	_gen(_content_with(p), StubRng.new()).generate_loot_offers(gs, false)
	assert_dict(gs.to_json()).is_equal(before)


# Same seed ⇒ identical offers (LOOT-stream determinism).
func test_determinism_same_seed() -> void:
	var p := _profile(["d1", "d2", "d3"], ["c1", "c2", "c3"], [], [])
	var a := _gen(_content_with(p), SeededRng.new(99)).generate_loot_offers(_gs(), false)
	var b := _gen(_content_with(p), SeededRng.new(99)).generate_loot_offers(_gs(), false)
	assert_array(a).is_equal(b)
