# Tests for ContentRegistry (T3.2): directory-scan discovery, indexing by id,
# duplicate detection, and handler-chain resolution (LLD-ARCH-005/-006).
# @Spec: LLD-ARCH-006, LLD-ARCH-005
extends GdUnitTestSuite

const ContentRegistryScript = preload("res://src/application/content_registry.gd")

const TMP := "user://test_cr_tmp"


func before_test() -> void:
	_rmtree(TMP)


func after_test() -> void:
	_rmtree(TMP)


func _rmtree(path: String) -> void:
	if not DirAccess.dir_exists_absolute(path):
		return
	var dir := DirAccess.open(path)
	for f in dir.get_files():
		DirAccess.remove_absolute("%s/%s" % [path, f])
	for sub in dir.get_directories():
		_rmtree("%s/%s" % [path, sub])
	DirAccess.remove_absolute(path)


func _registry():
	return auto_free(ContentRegistryScript.new())


func _save_ability(dir: String, filename: String, ability_id: String) -> void:
	DirAccess.make_dir_recursive_absolute(dir)
	var a := AbilityData.new()
	a.ability_id = ability_id
	a.action_bucket = "attack"
	a.max_charges = 6
	ResourceSaver.save(a, "%s/%s" % [dir, filename])


# Dropping a .tres into a data dir makes it discoverable with no code change.
# @Spec: LLD-ARCH-006
func test_scan_discovers_tres_by_id() -> void:
	var abilities_dir := "%s/abilities" % TMP
	_save_ability(abilities_dir, "walking_staff.tres", "walking_staff")

	var reg = _registry()
	reg._index_into(reg._abilities, abilities_dir, "ability_id")

	assert_array(reg.load_errors).is_empty()
	assert_bool(reg.has_ability("walking_staff")).is_true()
	assert_object(reg.get_ability("walking_staff")).is_not_null()
	assert_str(reg.get_ability("walking_staff").ability_id).is_equal("walking_staff")


# Non-.tres files (e.g. .gitkeep) are ignored by the scan.
func test_scan_ignores_non_tres() -> void:
	var dir := "%s/abilities" % TMP
	_save_ability(dir, "staff.tres", "staff")
	DirAccess.make_dir_recursive_absolute(dir)
	# drop a non-tres file
	var f := FileAccess.open("%s/.gitkeep" % dir, FileAccess.WRITE)
	f.store_string("")
	f = null

	assert_int(PersistenceService.list_files(dir, "tres").size()).is_equal(1)


# Two resources with the same id are a recorded load error (not silently merged).
func test_duplicate_id_recorded_as_error() -> void:
	var dir := "%s/abilities" % TMP
	_save_ability(dir, "a.tres", "dup")
	_save_ability(dir, "b.tres", "dup")

	var reg = _registry()
	reg._index_into(reg._abilities, dir, "ability_id")

	assert_int(reg.load_errors.size()).is_equal(1)
	assert_str(reg.load_errors[0]).contains("duplicate id 'dup'")


# Missing content returns null / false, not an error.
func test_lookup_missing_returns_null() -> void:
	var reg = _registry()
	assert_object(reg.get_ability("nope")).is_null()
	assert_bool(reg.has_ability("nope")).is_false()
	assert_object(reg.get_enemy("nope")).is_null()


# Handler ids are collected across abilities, omen cards, enemy intents, companions.
func test_collect_handler_ids_across_content() -> void:
	var reg = _registry()

	var ability := AbilityData.new()
	ability.ability_id = "throw_rock"
	ability.handlers.assign([_handler("deal_damage")])
	reg._abilities["throw_rock"] = ability

	var card := OmenCardData.new()
	card.card_id = "burning"
	card.handlers.assign([_handler("apply_status")])
	reg._omen_cards["burning"] = card

	var enemy := EnemyData.new()
	enemy.enemy_id = "witness"
	var intent := IntentWeight.new()
	intent.handlers.assign([_handler("apply_mending_by_burden_tier")])
	enemy.intent_weights.assign([intent])
	reg._enemies["witness"] = enemy

	var ids: PackedStringArray = reg.collect_handler_ids()
	assert_bool("deal_damage" in ids).is_true()
	assert_bool("apply_status" in ids).is_true()
	assert_bool("apply_mending_by_burden_tier" in ids).is_true()


# find_unresolved_handlers flags handler ids absent from the known set.
# @Spec: LLD-ARCH-005
func test_find_unresolved_handlers() -> void:
	var reg = _registry()
	var ability := AbilityData.new()
	ability.ability_id = "x"
	ability.handlers.assign([_handler("deal_damage"), _handler("made_up_handler")])
	reg._abilities["x"] = ability

	# All known -> none unresolved.
	assert_array(reg.find_unresolved_handlers(["deal_damage", "made_up_handler"])).is_empty()
	# Missing one -> it is reported.
	var unresolved: PackedStringArray = reg.find_unresolved_handlers(["deal_damage"])
	assert_array(unresolved).is_equal(PackedStringArray(["made_up_handler"]))


func _handler(id: String) -> HandlerConfig:
	var h := HandlerConfig.new()
	h.handler_id = id
	return h
