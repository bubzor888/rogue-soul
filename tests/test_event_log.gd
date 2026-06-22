# Tests for EventLog (T1.3) — written before the implementation (TDD).
# Covers the LLD-ARCH-013 checklist: event format valid/parseable; buffer flush
# at checkpoints; debug-gated RNG logging; meta run_started/run_end; SignalBus
# wiring (domain never calls EventLog directly).
# @Spec: LLD-ARCH-013, LLD-ARCH-008, LLD-ARCH-015
extends GdUnitTestSuite

const EventLogScript = preload("res://src/infrastructure/event_log.gd")
const SignalBusScript = preload("res://src/infrastructure/signal_bus.gd")

const TMP_DIR := "user://test_eventlog_tmp"


func _evlog():
	return auto_free(EventLogScript.new())


func before_test() -> void:
	_rmdir(TMP_DIR)


func after_test() -> void:
	_rmdir(TMP_DIR)


func _rmdir(path: String) -> void:
	if not DirAccess.dir_exists_absolute(path):
		return
	var dir := DirAccess.open(path)
	for f in dir.get_files():
		DirAccess.remove_absolute("%s/%s" % [path, f])
	DirAccess.remove_absolute(path)


func _read_lines(path: String) -> PackedStringArray:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return PackedStringArray()
	return f.get_as_text().strip_edges().split("\n")


# record() produces the LLD-ARCH-013 event shape and buffers it.
# @Spec: LLD-ARCH-013
func test_record_format() -> void:
	var ev = _evlog()
	ev.record("combat", "damage_dealt", {"amount": 5})
	var buf: Array = ev.get_buffered_events()
	assert_int(buf.size()).is_equal(1)
	var e: Dictionary = buf[0]
	assert_bool(e.has("tick") and e.has("category") and e.has("event") and e.has("data")).is_true()
	assert_int(typeof(e["tick"])).is_equal(TYPE_INT)
	assert_str(e["category"]).is_equal("combat")
	assert_str(e["event"]).is_equal("damage_dealt")
	assert_dict(e["data"]).is_equal({"amount": 5})


# tick increments monotonically per recorded event.
func test_tick_increments() -> void:
	var ev = _evlog()
	ev.record("combat", "a", {})
	ev.record("combat", "b", {})
	var buf: Array = ev.get_buffered_events()
	assert_int(buf[1]["tick"]).is_equal(buf[0]["tick"] + 1)


# flush() writes newline-delimited, parseable JSON via PersistenceService and
# clears the buffer. @Spec: LLD-ARCH-013
func test_flush_writes_parseable_jsonl_and_clears() -> void:
	var ev = _evlog()
	var path := "%s/run.jsonl" % TMP_DIR
	ev.log_path = path
	ev.record("combat", "damage_dealt", {"amount": 5})
	ev.record("items", "item_acquired", {"item_id": "staff"})
	ev.flush()

	assert_int(ev.get_buffered_events().size()).is_equal(0)
	var lines := _read_lines(path)
	assert_int(lines.size()).is_equal(2)
	for line in lines:
		var parsed: Variant = JSON.parse_string(line)
		assert_object(parsed).is_not_null()
		assert_bool((parsed as Dictionary).has("category")).is_true()


# Successive flushes append (bounding data loss, not overwriting).
func test_flush_appends_across_flushes() -> void:
	var ev = _evlog()
	var path := "%s/run.jsonl" % TMP_DIR
	ev.log_path = path
	ev.record("combat", "a", {})
	ev.flush()
	ev.record("combat", "b", {})
	ev.flush()
	assert_int(_read_lines(path).size()).is_equal(2)


# Flushing an empty buffer is a no-op (no error, no file churn).
func test_flush_empty_is_noop() -> void:
	var ev = _evlog()
	ev.log_path = "%s/run.jsonl" % TMP_DIR
	ev.flush()
	assert_bool(FileAccess.file_exists(ev.log_path)).is_false()


# RNG roll events are suppressed unless debug logging is on. @Spec: LLD-ARCH-013
func test_rng_logging_suppressed_by_default() -> void:
	var ev = _evlog()
	ev.debug_rng_logging = false
	ev.log_rng_roll("COMBAT", 3, 0.42, "hit")
	assert_int(ev.get_buffered_events().size()).is_equal(0)


func test_rng_logging_recorded_when_debug() -> void:
	var ev = _evlog()
	ev.debug_rng_logging = true
	ev.log_rng_roll("COMBAT", 3, 0.42, "hit")
	var buf: Array = ev.get_buffered_events()
	assert_int(buf.size()).is_equal(1)
	assert_str(buf[0]["category"]).is_equal("rng")


# start_run records a meta/run_started event carrying the seed and vessel, and
# sets the log path. @Spec: LLD-ARCH-008, LLD-ARCH-013
func test_start_run_records_meta_and_sets_path() -> void:
	var ev = _evlog()
	ev.start_run(987654, "pilgrim")
	assert_str(ev.log_path).is_not_empty()
	var e: Dictionary = ev.get_buffered_events()[0]
	assert_str(e["category"]).is_equal("meta")
	assert_str(e["event"]).is_equal("run_started")
	assert_int(int(e["data"]["seed"])).is_equal(987654)
	assert_str(e["data"]["vessel"]).is_equal("pilgrim")


# end_run records meta/run_end (seed, vessel, floor, outcome) and flushes.
# @Spec: LLD-ARCH-008, LLD-ARCH-013
func test_end_run_records_and_flushes() -> void:
	var ev = _evlog()
	ev.log_path = "%s/run.jsonl" % TMP_DIR
	ev.end_run(987654, "pilgrim", 3, "completion")
	assert_int(ev.get_buffered_events().size()).is_equal(0)  # flushed
	var lines := _read_lines(ev.log_path)
	var last: Dictionary = JSON.parse_string(lines[lines.size() - 1])
	assert_str(last["event"]).is_equal("run_end")
	assert_str(last["data"]["outcome"]).is_equal("completion")
	assert_int(int(last["data"]["floor_reached"])).is_equal(3)


# EventLog records events emitted on SignalBus — domain never calls it directly.
# @Spec: LLD-ARCH-009, LLD-ARCH-013
func test_records_from_signal_bus() -> void:
	var ev = _evlog()
	var bus = auto_free(SignalBusScript.new())
	ev.connect_to_bus(bus)

	bus.damage_dealt.emit("enemy_0", "player", 7, "fire")
	var buf: Array = ev.get_buffered_events()
	assert_int(buf.size()).is_equal(1)
	assert_str(buf[0]["category"]).is_equal("combat")
	assert_str(buf[0]["event"]).is_equal("damage_dealt")
	assert_int(int(buf[0]["data"]["amount"])).is_equal(7)


# floor_transitioned both records (navigation) and triggers a flush.
# @Spec: LLD-ARCH-013
func test_floor_transition_flushes() -> void:
	var ev = _evlog()
	ev.log_path = "%s/run.jsonl" % TMP_DIR
	var bus = auto_free(SignalBusScript.new())
	ev.connect_to_bus(bus)

	bus.room_entered.emit("combat", "skeleton_pack")
	bus.floor_transitioned.emit(3, 2)
	assert_int(ev.get_buffered_events().size()).is_equal(0)  # flushed
	# room_entered + floor_transitioned both persisted.
	assert_int(_read_lines(ev.log_path).size()).is_equal(2)
