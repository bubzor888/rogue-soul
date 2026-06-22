# @Spec: LLD-ARCH-007, LLD-ARCH-016, LLD-ARCH-010
#
# SaveManager — Application autoload that coordinates run save/load (LLD-ARCH-007).
# It reacts to SignalBus.save_requested (the WHEN) and serialises the active run's
# GameState through PersistenceService (versioned, LLD-ARCH-010). RunController
# registers the live state via set_active_state at run start — the signal carries
# only the SaveType, so the payload is supplied out-of-band (RunController is never
# driven by SaveManager; this is the reverse direction).
#
# Single save slot for MVP1. Both BACKGROUND and CHECKPOINT write a fully reloadable
# save; the SaveType is stored so that on next load a CHECKPOINT offers the player
# Resume / Start Over (LLD-ARCH-016), while a BACKGROUND save resumes silently.
#
# No `class_name` (autoload global). Layer note: Application — depends on Domain
# (GameState) + Infrastructure (PersistenceService, SignalBus). The pure
# save/load/resume/start_over API is testable without the signal wiring.
extends Node

const DEFAULT_SAVE_PATH := "user://saves/run.json"

const SAVE_TYPE_KEY := "save_type"
const STATE_KEY := "state"

## Overridable so tests can use a scratch path. Defaults to the single MVP1 slot.
var save_path: String = DEFAULT_SAVE_PATH

## The live run state RunController registers; serialised on save_requested.
var _active_state: GameState = null


func _ready() -> void:
	connect_to_bus(SignalBus)


# Wire the save trigger. Takes the bus explicitly so tests can connect a fresh
# SignalBus instance (mirrors EventLog.connect_to_bus).
func connect_to_bus(bus) -> void:
	bus.save_requested.connect(_on_save_requested)


# RunController registers the run to be saved (set once at start_run).
func set_active_state(game_state: GameState) -> void:
	_active_state = game_state


func _on_save_requested(save_type: int) -> void:
	if _active_state != null:
		save(_active_state, save_type)


## --- Save / load ------------------------------------------------------------

# Write the run state + its SaveType through PersistenceService (version-stamped).
# @Spec: LLD-ARCH-016, LLD-ARCH-010
func save(game_state: GameState, save_type: int) -> bool:
	return PersistenceService.write_save(save_path, {
		SAVE_TYPE_KEY: save_type,
		STATE_KEY: game_state.to_json(),
	})


# Load the saved run, or null if there is no (readable) save. Runs save migrations
# via PersistenceService.read_save. @Spec: LLD-ARCH-010
func load_run() -> GameState:
	var record := _read()
	if record.is_empty() or not record.has(STATE_KEY):
		return null
	return GameState.from_json(record[STATE_KEY])


func has_save() -> bool:
	return not _read().is_empty()


# True only when the existing save is a CHECKPOINT — the case that prompts the
# Resume / Start Over choice on next load (LLD-ARCH-016).
func has_checkpoint() -> bool:
	var record := _read()
	return not record.is_empty() and int(record.get(SAVE_TYPE_KEY, -1)) == RunController.SaveType.CHECKPOINT


# Resume: load the saved run as-is.
func resume() -> GameState:
	return load_run()


# Start Over: discard the saved run state (LLD-ARCH-016).
func start_over() -> void:
	PersistenceService.delete_file(save_path)
	_active_state = null


func _read() -> Dictionary:
	return PersistenceService.read_save(save_path)
