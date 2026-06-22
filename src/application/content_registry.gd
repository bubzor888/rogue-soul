# @Spec: LLD-ARCH-006, LLD-ARCH-005, LLD-ARCH-007
#
# ContentRegistry — the 8th autoload (extends the 7 in LLD-ARCH-007). It owns the
# process-wide, read-only content catalogues: abilities/items, vessels, enemies,
# omen cards, companions. At boot it scans each `data/` subdir, indexes content by
# id, and (once the AbilityPipeline handler registry exists — T4.1) validates that
# every handler_id in every chain resolves. Unknown ids are a fatal startup error.
#
# Layer note: this returns Domain Resources, so it sits at the Application level
# (like ScreenManager/SaveManager). Domain code (e.g. CombatResolver) never reads
# it directly — per LLD-ARCH-019 the resolver touches no autoload but SignalBus;
# Application code reads ContentRegistry and injects the data it needs. No
# `class_name` (would collide with the autoload global).
#
# Directory listing is delegated to PersistenceService (the DirAccess owner);
# `.tres` loading uses ResourceLoader (resource loading, distinct from FileAccess).
extends Node

const ABILITIES_DIR := "res://data/abilities"
const ITEMS_DIR := "res://data/items"
const VESSELS_DIR := "res://data/vessels"
const ENEMIES_DIR := "res://data/enemies"
const OMEN_CARDS_DIR := "res://data/omen_cards"
const COMPANIONS_DIR := "res://data/companions"
const FLOORS_DIR := "res://data/floors"

# Indexes keyed by id. Abilities and items share one index — items ARE AbilityData
# (LLD-ARCH-018), keyed by ability_id (== item_id).
var _abilities: Dictionary = {}    # ability_id -> AbilityData (abilities + items)
var _vessels: Dictionary = {}      # vessel_id   -> VesselData
var _enemies: Dictionary = {}      # enemy_id    -> EnemyData
var _omen_cards: Dictionary = {}   # card_id     -> OmenCardData
var _companions: Dictionary = {}   # companion_id-> CompanionData
var _floors: Dictionary = {}       # floor_id    -> FloorProfile

# Fatal load problems (duplicate/empty id, load failure) collected during a scan.
var load_errors: PackedStringArray = PackedStringArray()


func _ready() -> void:
	load_all()
	if not load_errors.is_empty():
		_abort("content load errors: %s" % str(load_errors))
	# Fatal startup error if any content references an unknown handler (LLD-ARCH-005).
	validate_handlers(AbilityPipeline.default_handler_ids())


## --- Scan & index -----------------------------------------------------------

# Load every content directory into its index. Idempotent (clears first).
func load_all() -> void:
	_abilities = {}
	_vessels = {}
	_enemies = {}
	_omen_cards = {}
	_companions = {}
	_floors = {}
	load_errors = PackedStringArray()
	_index_into(_abilities, ABILITIES_DIR, "ability_id")
	_index_into(_abilities, ITEMS_DIR, "ability_id")  # items are AbilityData too
	_index_into(_vessels, VESSELS_DIR, "vessel_id")
	_index_into(_enemies, ENEMIES_DIR, "enemy_id")
	_index_into(_omen_cards, OMEN_CARDS_DIR, "card_id")
	_index_into(_companions, COMPANIONS_DIR, "companion_id")
	_index_into(_floors, FLOORS_DIR, "floor_id")


# Load all `.tres` in dir_path into target, keyed by the resource's id_field.
# Records (does not raise) duplicate/empty-id/load-failure into load_errors so the
# caller decides whether to abort — keeps unit tests free of engine shutdown.
func _index_into(target: Dictionary, dir_path: String, id_field: String) -> void:
	for filename in PersistenceService.list_files(dir_path, "tres"):
		var path := "%s/%s" % [dir_path, filename]
		var res: Resource = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_REPLACE)
		if res == null:
			load_errors.append("failed to load %s" % path)
			continue
		var id: String = str(res.get(id_field))
		if id == "":
			load_errors.append("%s has empty %s" % [path, id_field])
			continue
		if target.has(id):
			load_errors.append("duplicate id '%s' (%s)" % [id, path])
			continue
		target[id] = res


## --- Lookups (read-only) ----------------------------------------------------

func get_ability(id: String) -> AbilityData:
	return _abilities.get(id, null)


func has_ability(id: String) -> bool:
	return _abilities.has(id)


func get_vessel(id: String) -> VesselData:
	return _vessels.get(id, null)


func get_enemy(id: String) -> EnemyData:
	return _enemies.get(id, null)


func get_omen_card(id: String) -> OmenCardData:
	return _omen_cards.get(id, null)


func get_companion(id: String) -> CompanionData:
	return _companions.get(id, null)


func get_floor(id: String) -> FloorProfile:
	return _floors.get(id, null)


# Resolve a floor profile by its floor number (NavigationModel/RunController look up
# the profile for the current floor). Null if none defined. @Spec: HLD-RUN-005
func get_floor_by_number(n: int) -> FloorProfile:
	for fp in _floors.values():
		if fp.floor_number == n:
			return fp
	return null


## --- Handler validation (LLD-ARCH-005) --------------------------------------

# Every handler_id referenced by any loaded content chain (abilities/items, omen
# cards, enemy intents, companions).
func collect_handler_ids() -> PackedStringArray:
	var ids: Dictionary = {}
	for ability in _abilities.values():
		for h in ability.handlers:
			ids[h.handler_id] = true
	for card in _omen_cards.values():
		for h in card.handlers:
			ids[h.handler_id] = true
	for enemy in _enemies.values():
		for intent in enemy.intent_weights:
			for h in intent.handlers:
				ids[h.handler_id] = true
	for companion in _companions.values():
		for h in companion.handlers:
			ids[h.handler_id] = true
	return PackedStringArray(ids.keys())


# Handler ids referenced by content but absent from the known set (empty = valid).
func find_unresolved_handlers(known_handler_ids) -> PackedStringArray:
	var known: Dictionary = {}
	for k in known_handler_ids:
		known[k] = true
	var unresolved := PackedStringArray()
	for hid in collect_handler_ids():
		if not known.has(hid):
			unresolved.append(hid)
	return unresolved


# Boot-time gate (called once the handler registry exists — T4.1): a fatal startup
# error if any content references an unknown handler. @Spec: LLD-ARCH-005
func validate_handlers(known_handler_ids) -> void:
	var unresolved := find_unresolved_handlers(known_handler_ids)
	if not unresolved.is_empty():
		_abort("unresolved handler ids: %s" % str(unresolved))


## --- Internal ---------------------------------------------------------------

# Fatal startup error (LLD-ARCH-005): log and stop the engine. Unit tests exercise
# the lower-level detection methods and never reach this.
func _abort(message: String) -> void:
	push_error("ContentRegistry FATAL: %s" % message)
	get_tree().quit(1)
