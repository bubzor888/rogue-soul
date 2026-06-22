# Tests for PersistenceService (T1.4): JSON round-trip, SAVE_VERSION stamping,
# and the migration entry-point.
# @Spec: LLD-ARCH-007, LLD-ARCH-010
extends GdUnitTestSuite

const PersistenceServiceScript = preload("res://src/infrastructure/persistence_service.gd")

# Isolated scratch dir under user:// so tests never touch real logs/saves.
const TMP_DIR := "user://test_persistence_tmp"


func _service():
	return auto_free(PersistenceServiceScript.new())


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


# JSON write → read returns an identical structure for JSON-stable types.
# @Spec: LLD-ARCH-010
func test_json_round_trip() -> void:
	var svc = _service()
	var path := "%s/data.json" % TMP_DIR
	var data := {"name": "pilgrim", "ratio": 0.5, "flag": true, "items": ["staff", "map"], "nested": {"a": "x"}}

	assert_bool(svc.write_json(path, data)).is_true()
	var loaded: Variant = svc.read_json(path)
	assert_dict(loaded).is_equal(data)


# Contract: JSON decodes all numbers as float (an int written round-trips as a
# float). Callers that need ints (e.g. GameState.from_json, T2.2) must cast.
func test_json_numbers_decode_as_float() -> void:
	var svc = _service()
	var path := "%s/num.json" % TMP_DIR
	svc.write_json(path, {"hp": 30})
	var loaded: Variant = svc.read_json(path)
	assert_bool(typeof(loaded["hp"]) == TYPE_FLOAT).is_true()
	assert_int(int(loaded["hp"])).is_equal(30)


# Reading a missing file returns null, not an error/crash.
func test_read_missing_returns_null() -> void:
	var svc = _service()
	assert_object(svc.read_json("%s/nope.json" % TMP_DIR)).is_null()


# write_save stamps the current SAVE_VERSION into the file.
# @Spec: LLD-ARCH-010
func test_write_save_stamps_version() -> void:
	var svc = _service()
	var path := "%s/save.json" % TMP_DIR
	assert_bool(svc.write_save(path, {"floor": 3})).is_true()

	var raw: Variant = svc.read_json(path)
	assert_int(int(raw[svc.SAVE_VERSION_KEY])).is_equal(GameConfig.SAVE_VERSION)
	# Original payload preserved alongside the stamp.
	assert_int(int(raw["floor"])).is_equal(3)


# write_save must not mutate the caller's dictionary.
func test_write_save_does_not_mutate_input() -> void:
	var svc = _service()
	var data := {"floor": 1}
	svc.write_save("%s/s.json" % TMP_DIR, data)
	assert_bool(data.has(svc.SAVE_VERSION_KEY)).is_false()


# A current-version save reads back without needing migration.
func test_read_save_current_version() -> void:
	var svc = _service()
	var path := "%s/cur.json" % TMP_DIR
	svc.write_save(path, {"floor": 2})
	var loaded: Dictionary = svc.read_save(path)
	assert_int(int(loaded["floor"])).is_equal(2)


# A registered migration upgrades an older save before it is returned.
# @Spec: LLD-ARCH-010 (migration entry-point)
func test_migration_upgrades_old_save() -> void:
	var svc = _service()
	var path := "%s/old.json" % TMP_DIR
	# Hand-write a v0 save (bypass write_save's stamping).
	svc.write_json(path, {"floor": 1})  # no save_version key => treated as 0

	# Migration 0 -> 1: add a field that v1 expects.
	svc.register_migration(0, func(d: Dictionary) -> Dictionary:
		d["migrated"] = true
		return d)

	var loaded: Dictionary = svc.read_save(path)
	assert_bool(loaded.get("migrated", false)).is_true()
	assert_int(int(loaded[svc.SAVE_VERSION_KEY])).is_equal(GameConfig.SAVE_VERSION)


# Append builds newline-delimited content (the EventLog .jsonl pattern).
func test_append_text_accumulates() -> void:
	var svc = _service()
	var path := "%s/log.jsonl" % TMP_DIR
	svc.append_text(path, "line1\n")
	svc.append_text(path, "line2\n")
	assert_str(svc._read_text(path)).is_equal("line1\nline2\n")


# log_file_path follows the LLD-ARCH-013 naming convention.
func test_log_file_path_format() -> void:
	var svc = _service()
	assert_str(svc.log_file_path(12345, "20260616T120000")) \
		.is_equal("user://logs/run_12345_20260616T120000.jsonl")
