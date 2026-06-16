# @Spec: LLD-ARCH-013, LLD-ARCH-008
#
# EventLog — Infrastructure autoload. Structured, newline-delimited JSON recorder
# (one event object per line). The primary diagnostic for playtesting, AI
# simulation analysis, and bug reproduction.
#
# Domain code NEVER calls EventLog directly (LLD-ARCH-009): EventLog subscribes to
# SignalBus and records what it hears. Run-lifecycle meta events (run_started /
# run_end) are recorded via public methods called by the Application layer
# (RunController / AIPlayerAgent), which may depend on Infrastructure.
#
# Buffering (LLD-ARCH-013): events accumulate in memory and are flushed to file at
# floor transition, boss completion (RunController calls flush()), and run end.
# Continuous per-event file I/O is not permitted. Writes go through
# PersistenceService — never FileAccess directly.
#
# Registered as an autoload in project.godot (no `class_name`).
extends Node

# In-memory event buffer; each entry is a {tick, category, event, data} Dictionary.
var _buffer: Array = []

# Monotonic per-event sequence number used as `tick`. No game-clock source exists
# yet for MVP1; this gives every event a unique, ordered tick and can be re-pointed
# at turn numbers later without changing the format.
var _tick: int = 0

# Destination log file (set by start_run, or directly in tests). Empty until a run
# starts; flush() is a no-op while empty.
var log_path: String = ""

# Whether raw RNG rolls (category `rng`) are recorded. Defaults from
# GameConfig.DEBUG (LLD-ARCH-013) but is a runtime var so it can be toggled
# (e.g. by tests) without a separate build.
var debug_rng_logging: bool = false


func _init() -> void:
	debug_rng_logging = GameConfig.DEBUG


func _ready() -> void:
	# In the autoload context, wire to the global SignalBus.
	connect_to_bus(SignalBus)


## --- Core recording ---------------------------------------------------------

# Append an event to the buffer in the LLD-ARCH-013 format. @Spec: LLD-ARCH-013
func record(category: String, event: String, data: Dictionary = {}) -> void:
	_buffer.append({
		"tick": _tick,
		"category": category,
		"event": event,
		"data": data,
	})
	_tick += 1


# Read-only view of the current buffer (for inspection/tests).
func get_buffered_events() -> Array:
	return _buffer


# Flush the buffer to the log file (append) and clear it. No-op if the buffer is
# empty or no log_path is set. @Spec: LLD-ARCH-013
func flush() -> void:
	if _buffer.is_empty() or log_path == "":
		return
	var lines: PackedStringArray = PackedStringArray()
	for e in _buffer:
		lines.append(JSON.stringify(e))
	PersistenceService.append_text(log_path, "\n".join(lines) + "\n")
	_buffer.clear()


## --- Run lifecycle (meta) ---------------------------------------------------

# Begin a run: derive the log path from the seed and record run_started.
# @Spec: LLD-ARCH-008, LLD-ARCH-013
func start_run(seed: int, vessel_id: String) -> void:
	log_path = PersistenceService.log_file_path(seed, _timestamp())
	record("meta", "run_started", {"seed": seed, "vessel": vessel_id})


# End a run: record run_end (seed, vessel, floor, outcome) then flush.
# @Spec: LLD-ARCH-008, LLD-ARCH-013
func end_run(seed: int, vessel_id: String, floor_reached: int, outcome: String) -> void:
	record("meta", "run_end", {
		"seed": seed,
		"vessel": vessel_id,
		"floor_reached": floor_reached,
		"outcome": outcome,
	})
	flush()


## --- RNG (debug-gated) ------------------------------------------------------

# Record a raw RNG roll — only when debug RNG logging is enabled (LLD-ARCH-013).
func log_rng_roll(stream: String, call_index: int, value: float, outcome: String) -> void:
	if not debug_rng_logging:
		return
	record("rng", "roll", {
		"stream": stream,
		"call_index": call_index,
		"value": value,
		"outcome": outcome,
	})


## --- SignalBus wiring -------------------------------------------------------

# Connect this EventLog's handlers to a SignalBus. Called with the autoload in
# _ready(); tests pass a local bus to exercise wiring in isolation.
func connect_to_bus(bus) -> void:
	bus.room_entered.connect(_on_room_entered)
	bus.floor_transitioned.connect(_on_floor_transitioned)
	bus.combat_started.connect(_on_combat_started)
	bus.combat_ended.connect(_on_combat_ended)
	bus.turn_started.connect(_on_turn_started)
	bus.action_resolved.connect(_on_action_resolved)
	bus.damage_dealt.connect(_on_damage_dealt)
	bus.status_applied.connect(_on_status_applied)
	bus.status_cleared.connect(_on_status_cleared)
	bus.unit_died.connect(_on_unit_died)
	bus.omen_drawn.connect(_on_omen_drawn)
	bus.omen_applied.connect(_on_omen_applied)
	bus.item_broken.connect(_on_item_broken)
	bus.item_discarded.connect(_on_item_discarded)
	bus.item_acquired.connect(_on_item_acquired)


func _on_room_entered(room_type: String, encounter_id: String) -> void:
	record("navigation", "room_entered", {"room_type": room_type, "encounter_id": encounter_id})


func _on_floor_transitioned(from_floor: int, to_floor: int) -> void:
	record("navigation", "floor_transitioned", {"from_floor": from_floor, "to_floor": to_floor})
	flush()  # bound data loss to a single floor (LLD-ARCH-013)


func _on_combat_started(_combat_state: Resource) -> void:
	record("combat", "combat_started", {})


func _on_combat_ended(outcome: String) -> void:
	record("combat", "combat_ended", {"outcome": outcome})


func _on_turn_started(turn_number: int) -> void:
	record("combat", "turn_started", {"turn_number": turn_number})


func _on_action_resolved(action: Dictionary, result: Dictionary) -> void:
	record("combat", "action_resolved", {"action": action, "result": result})


func _on_damage_dealt(source_id: String, target_id: String, amount: int, type: String) -> void:
	record("combat", "damage_dealt", {"source_id": source_id, "target_id": target_id, "amount": amount, "type": type})


func _on_status_applied(unit_id: String, status_id: String, ticks: int) -> void:
	record("combat", "status_applied", {"unit_id": unit_id, "status_id": status_id, "ticks": ticks})


func _on_status_cleared(unit_id: String, status_id: String) -> void:
	record("combat", "status_cleared", {"unit_id": unit_id, "status_id": status_id})


func _on_unit_died(unit_id: String) -> void:
	record("combat", "unit_died", {"unit_id": unit_id})


func _on_omen_drawn(cards: Array) -> void:
	record("combat", "omen_drawn", {"cards": cards})


func _on_omen_applied(card_id: String, side: String) -> void:
	record("combat", "omen_applied", {"card_id": card_id, "side": side})


func _on_item_broken(item_id: String, slot_index: int) -> void:
	record("items", "item_broken", {"item_id": item_id, "slot_index": slot_index})


func _on_item_discarded(item_id: String, slot_index: int) -> void:
	record("items", "item_discarded", {"item_id": item_id, "slot_index": slot_index})


func _on_item_acquired(item_id: String) -> void:
	record("items", "item_acquired", {"item_id": item_id})


## --- Internal ---------------------------------------------------------------

func _timestamp() -> String:
	# Compact, filename-safe timestamp (not part of run determinism).
	return Time.get_datetime_string_from_system(false, true).replace(":", "").replace("-", "").replace(" ", "T")
