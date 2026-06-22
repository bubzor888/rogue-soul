# @Spec: LLD-ARCH-007, LLD-ARCH-010
#
# PersistenceService — Infrastructure autoload. The SOLE abstraction over
# FileAccess: no other class in the codebase opens files directly (LLD-ARCH-007).
# Provides JSON read/write, plain-text/append (for EventLog's .jsonl), versioned
# save read/write with a migration hook (LLD-ARCH-010), and path helpers.
#
# Registered as an autoload in project.godot (no `class_name`, to avoid colliding
# with the autoload global).
#
# Layer note: depends only on GameConfig (same Infrastructure layer) for
# SAVE_VERSION. It must NOT depend on EventLog (EventLog depends on this), so
# internal failures are surfaced via push_error/push_warning, never via EventLog.
#
# Web note (LLD-PLATFORM-005, deferred to MVP4): a localStorage/IndexedDB backend
# may replace the FileAccess calls here; keeping all file I/O behind this service
# is what makes that swap a single-file change.
extends Node

## Standard directories (under user://, writable in all build configs incl. export).
const LOGS_DIR := "user://logs"
const SAVES_DIR := "user://saves"

## Key under which the save schema version is stamped into every save (LLD-ARCH-010).
const SAVE_VERSION_KEY := "save_version"

# Migration table: from_version (int) -> Callable(data: Dictionary) -> Dictionary.
# Starts empty (LLD-ARCH-010 "migration table can start empty"); populate via
# register_migration as breaking save-schema changes land.
var _migrations: Dictionary = {}


## --- Generic JSON I/O -------------------------------------------------------

# Parse a JSON file. Returns the decoded Variant (Dictionary/Array/...), or null
# if the file is missing or the contents are not valid JSON.
func read_json(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		return null
	var text := _read_text(path)
	if text == "":
		return null
	var result: Variant = JSON.parse_string(text)
	if result == null:
		push_error("PersistenceService: invalid JSON in %s" % path)
	return result


# Serialise `data` to (pretty) JSON and write it, creating parent dirs as needed.
# Returns true on success. @Spec: LLD-ARCH-010 (JSON for debuggability)
func write_json(path: String, data: Variant) -> bool:
	return write_text(path, JSON.stringify(data, "\t"))


## --- Plain text (EventLog .jsonl) -------------------------------------------

# Overwrite a file with `text`, creating parent dirs as needed. Returns success.
func write_text(path: String, text: String) -> bool:
	_ensure_parent_dir(path)
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		push_error("PersistenceService: cannot write %s (err %d)" % [path, FileAccess.get_open_error()])
		return false
	f.store_string(text)
	return true


# Append `text` to a file (creating it if absent). Used for newline-delimited
# event logs so EventLog can flush incrementally without rewriting the whole file.
func append_text(path: String, text: String) -> bool:
	_ensure_parent_dir(path)
	var f: FileAccess
	if FileAccess.file_exists(path):
		f = FileAccess.open(path, FileAccess.READ_WRITE)
		if f != null:
			f.seek_end()
	else:
		f = FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		push_error("PersistenceService: cannot append %s (err %d)" % [path, FileAccess.get_open_error()])
		return false
	f.store_string(text)
	return true


func file_exists(path: String) -> bool:
	return FileAccess.file_exists(path)


# Delete a file if it exists (e.g. SaveManager "Start Over" clearing a checkpoint).
# Returns true if the file is gone afterwards. @Spec: LLD-ARCH-007
func delete_file(path: String) -> bool:
	if not FileAccess.file_exists(path):
		return true
	return DirAccess.remove_absolute(path) == OK


# List filenames (not full paths) in a directory, optionally filtered by extension
# (without the dot, e.g. "tres"). Returns empty if the directory does not exist.
# Used by ContentRegistry for boot-time content discovery. @Spec: LLD-ARCH-006
func list_files(dir_path: String, extension: String = "") -> PackedStringArray:
	var out := PackedStringArray()
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return out
	for f in dir.get_files():
		if extension == "" or f.get_extension() == extension:
			out.append(f)
	return out


## --- Versioned saves (LLD-ARCH-010) -----------------------------------------

# Stamp the current SAVE_VERSION into `data` and write it as JSON. Does not mutate
# the caller's dictionary. @Spec: LLD-ARCH-010
func write_save(path: String, data: Dictionary) -> bool:
	var stamped := data.duplicate(true)
	stamped[SAVE_VERSION_KEY] = GameConfig.SAVE_VERSION
	return write_json(path, stamped)


# Read a save, running any registered migrations if its version is older than the
# current SAVE_VERSION before returning. Returns {} if missing/unreadable.
# @Spec: LLD-ARCH-010
func read_save(path: String) -> Dictionary:
	var raw: Variant = read_json(path)
	if raw == null or not (raw is Dictionary):
		return {}
	return _apply_migrations(raw as Dictionary)


# Migration entry-point: register a function that upgrades a save FROM `from_version`
# to from_version + 1. @Spec: LLD-ARCH-010
func register_migration(from_version: int, fn: Callable) -> void:
	_migrations[from_version] = fn


# Apply migrations sequentially until the save reaches the current SAVE_VERSION.
# A missing migration for a needed step is a hard error (stops, returns as-is).
func _apply_migrations(data: Dictionary) -> Dictionary:
	var version: int = int(data.get(SAVE_VERSION_KEY, 0))
	while version < GameConfig.SAVE_VERSION:
		if not _migrations.has(version):
			push_error("PersistenceService: no migration from save_version %d (target %d)" % [version, GameConfig.SAVE_VERSION])
			return data
		data = (_migrations[version] as Callable).call(data)
		version += 1
		data[SAVE_VERSION_KEY] = version
	return data


## --- Path helpers -----------------------------------------------------------

# Canonical run-log path: user://logs/run_<seed>_<timestamp>.jsonl (LLD-ARCH-013).
func log_file_path(seed: int, timestamp: String) -> String:
	return "%s/run_%d_%s.jsonl" % [LOGS_DIR, seed, timestamp]


## --- Internal ---------------------------------------------------------------

func _read_text(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	return f.get_as_text()


func _ensure_parent_dir(path: String) -> void:
	var dir := path.get_base_dir()
	if dir != "" and not DirAccess.dir_exists_absolute(dir):
		var err := DirAccess.make_dir_recursive_absolute(dir)
		if err != OK:
			push_warning("PersistenceService: could not create dir %s (err %d)" % [dir, err])
