# @Spec: LLD-ARCH-016
#
# Guard: every presentation screen/component scene must LOAD and INSTANTIATE with its
# script attached. This catches GDScript parse errors (e.g. bad `:=` type inference)
# that the view-model unit tests miss because they never load the view scripts. A parse
# error detaches the script, so the instance loses its expected methods — asserted here.
# Bare instantiate() does not call _ready(), so no run/content is needed and nothing
# renders; the scene is freed immediately.
extends GdUnitTestSuite

func _instantiate(path: String) -> Node:
	var scene = load(path)
	assert_object(scene).is_not_null()
	var inst = scene.instantiate()
	assert_object(inst).is_not_null()
	return inst

func test_screens_instantiate_with_bind() -> void:
	for path in [
		"res://src/presentation/screens/room_select.tscn",
		"res://src/presentation/screens/loot.tscn",
		"res://src/presentation/screens/combat.tscn",
	]:
		var inst := _instantiate(path)
		# bind(run, content) is the uniform screen entry point — present only if the
		# script parsed and attached.
		assert_bool(inst.has_method("bind")).override_failure_message("%s failed to parse/attach its script" % path).is_true()
		inst.free()

func test_main_and_components_instantiate() -> void:
	for path in [
		"res://src/presentation/screens/main.tscn",
		"res://src/presentation/components/hp_bar.tscn",
		"res://src/presentation/components/status_row.tscn",
		"res://src/presentation/components/charge_dots.tscn",
		"res://src/presentation/components/damage_type_icon.tscn",
		"res://src/presentation/components/ghost_menu.tscn",
	]:
		var inst := _instantiate(path)
		inst.free()
