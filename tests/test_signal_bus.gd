# Verifies the SignalBus autoload (T1.2) declares the full LLD-ARCH-009 MVP1
# signal catalogue with the correct parameter counts. Signals-only contract, so
# the test pins names + arity (the bus has no behaviour to exercise).
# @Spec: LLD-ARCH-009
extends GdUnitTestSuite

const SignalBusScript = preload("res://src/infrastructure/signal_bus.gd")

# Expected signal name -> parameter count, straight from the LLD-ARCH-009 table.
const EXPECTED := {
	"phase_changed": 2,
	"save_requested": 1,
	"combat_started": 1,
	"combat_ended": 1,
	"turn_started": 1,
	"action_resolved": 2,
	"damage_dealt": 4,
	"status_applied": 3,
	"status_cleared": 2,
	"unit_died": 1,
	"omen_drawn": 1,
	"omen_applied": 2,
	"item_broken": 2,
	"item_discarded": 2,
	"item_acquired": 1,
	"room_entered": 2,
	"floor_transitioned": 2,
}


func _arg_count(bus, signal_name: String) -> int:
	for sig in bus.get_signal_list():
		if sig["name"] == signal_name:
			return sig["args"].size()
	return -1


func test_all_signals_declared_with_correct_arity() -> void:
	var bus = auto_free(SignalBusScript.new())
	for signal_name in EXPECTED:
		assert_bool(bus.has_signal(signal_name)) \
			.override_failure_message("Missing signal: %s" % signal_name) \
			.is_true()
		assert_int(_arg_count(bus, signal_name)) \
			.override_failure_message("Wrong arg count for %s" % signal_name) \
			.is_equal(EXPECTED[signal_name])


func test_no_unexpected_user_signals() -> void:
	# Guard against drift: only the catalogued signals should be user-declared.
	# (Filters out the built-in Node/Object signals via Object.has_user_signal-
	# style intent: user signals are those NOT defined on a bare Node.)
	var bus = auto_free(SignalBusScript.new())
	var baseline = auto_free(Node.new())
	var baseline_names := {}
	for sig in baseline.get_signal_list():
		baseline_names[sig["name"]] = true

	for sig in bus.get_signal_list():
		var name: String = sig["name"]
		if baseline_names.has(name):
			continue  # inherited Node/Object signal, ignore
		assert_bool(EXPECTED.has(name)) \
			.override_failure_message("Unexpected signal declared: %s" % name) \
			.is_true()
