# Verifies the GameConfig autoload (T0.3) is registered and its flags/constants
# are readable with the MVP1 defaults.
# @Spec: LLD-ARCH-007, LLD-ARCH-002, LLD-ARCH-010, LLD-ARCH-014
extends GdUnitTestSuite


func test_autoload_registered() -> void:
	# The global `GameConfig` exists because it is registered as an autoload.
	assert_object(GameConfig).is_not_null()


func test_headless_default_true_for_mvp1() -> void:
	# @Spec: LLD-ARCH-002 — MVP1 dev runs are headless.
	assert_bool(GameConfig.HEADLESS).is_true()


func test_debug_default_false() -> void:
	# @Spec: LLD-ARCH-014 — debug tooling ships gated and off by default.
	assert_bool(GameConfig.DEBUG).is_false()


func test_save_version_is_positive_int() -> void:
	# @Spec: LLD-ARCH-010 — a concrete version is stamped into every save.
	assert_int(GameConfig.SAVE_VERSION).is_greater_equal(1)
