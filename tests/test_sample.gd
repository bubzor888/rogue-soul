# Trivial smoke test proving the GdUnit4 headless runner works (T0.2).
# Safe to delete once the first real suite (test_rng.gd, T1.1) lands.
extends GdUnitTestSuite


func test_sanity() -> void:
	assert_int(1 + 1).is_equal(2)
