# Tests for RNGService (T1.1) — written before the implementation (TDD).
#
# Covers the LLD-ARCH-015 RNG checklist: correct stream init from seed; derived
# stream seeds produce expected values; no cross-stream contamination; same seed
# always produces the same sequence.
# @Spec: LLD-ARCH-008, LLD-ARCH-015
extends GdUnitTestSuite

const RNGServiceScript = preload("res://src/infrastructure/rng_service.gd")

const SEED: int = 123456789
const N: int = 8


# Build a fresh, auto-freed service seeded with the given base seed.
func _service(base_seed: int = SEED):
	var rng = auto_free(RNGServiceScript.new())
	rng.seed_run(base_seed)
	return rng


# Pull `count` floats from a stream into an Array for exact comparison.
func _pull(rng, stream: int, count: int = N) -> Array:
	var out: Array = []
	for _i in count:
		out.append(rng.roll(stream))
	return out


# Same seed → identical sequence on every stream (determinism).
# @Spec: LLD-ARCH-008
func test_same_seed_same_sequence() -> void:
	var a = _service()
	var b = _service()
	for stream in [
		RNGServiceScript.Stream.NAVIGATION,
		RNGServiceScript.Stream.COMBAT,
		RNGServiceScript.Stream.LOOT,
		RNGServiceScript.Stream.EVENTS,
	]:
		assert_array(_pull(a, stream)).is_equal(_pull(b, stream))


# Each stream equals a reference RNG seeded base_seed + stream_index.
# This is the "pre-computed expected sequence" check and pins the derived-seed
# formula exactly. @Spec: LLD-ARCH-008
func test_derived_seed_formula() -> void:
	var indices := {
		RNGServiceScript.Stream.NAVIGATION: 0,
		RNGServiceScript.Stream.COMBAT: 1,
		RNGServiceScript.Stream.LOOT: 2,
		RNGServiceScript.Stream.EVENTS: 3,
	}
	for stream in indices:
		var ref := RandomNumberGenerator.new()
		ref.seed = SEED + indices[stream]
		var expected: Array = []
		for _i in N:
			expected.append(ref.randf())

		var rng = _service()
		assert_array(_pull(rng, stream)).is_equal(expected)


# Consuming one stream must not perturb the others (no contamination).
# @Spec: LLD-ARCH-008
func test_no_cross_stream_contamination() -> void:
	# Baseline NAVIGATION sequence with no other stream touched.
	var baseline = _service()
	var nav_baseline := _pull(baseline, RNGServiceScript.Stream.NAVIGATION)

	# Now hammer COMBAT, LOOT, EVENTS before reading NAVIGATION.
	var rng = _service()
	_pull(rng, RNGServiceScript.Stream.COMBAT, 50)
	_pull(rng, RNGServiceScript.Stream.LOOT, 50)
	_pull(rng, RNGServiceScript.Stream.EVENTS, 50)
	var nav_after := _pull(rng, RNGServiceScript.Stream.NAVIGATION)

	assert_array(nav_after).is_equal(nav_baseline)


# Different base seeds produce different sequences.
# @Spec: LLD-ARCH-008
func test_different_seeds_differ() -> void:
	var a := _pull(_service(SEED), RNGServiceScript.Stream.COMBAT)
	var b := _pull(_service(SEED + 1), RNGServiceScript.Stream.COMBAT)
	assert_array(a).is_not_equal(b)


# roll() stays in [0, 1).
# @Spec: LLD-ARCH-008
func test_roll_in_unit_interval() -> void:
	var rng = _service()
	for _i in 100:
		var v: float = rng.roll(RNGServiceScript.Stream.COMBAT)
		assert_float(v).is_between(0.0, 1.0)
		assert_bool(v < 1.0).is_true()


# randi_range() is deterministic, in-bounds, and matches a reference RNG.
# @Spec: LLD-ARCH-008
func test_randi_range_deterministic_and_bounded() -> void:
	var ref := RandomNumberGenerator.new()
	ref.seed = SEED + 2  # LOOT index
	var expected: Array = []
	for _i in N:
		expected.append(ref.randi_range(1, 6))

	var rng = _service()
	var actual: Array = []
	for _i in N:
		var v: int = rng.randi_range(RNGServiceScript.Stream.LOOT, 1, 6)
		assert_int(v).is_between(1, 6)
		actual.append(v)

	assert_array(actual).is_equal(expected)


# Re-seeding the same service resets its streams to the start of the sequence.
# @Spec: LLD-ARCH-008
func test_reseed_resets_streams() -> void:
	var rng = _service()
	var first := _pull(rng, RNGServiceScript.Stream.NAVIGATION)
	rng.seed_run(SEED)
	var second := _pull(rng, RNGServiceScript.Stream.NAVIGATION)
	assert_array(second).is_equal(first)
