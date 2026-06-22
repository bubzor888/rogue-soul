# Tests for the restore_item_charges handler (Good as New, LLD-ABILITIES-003 /
# LLD-VESSELS-001). It refills one item's durability to its max. A target_slot may
# be given (true player choice, MVP2 UI); without one it auto-targets the most
# depleted eligible item so the headless random agent exercises a meaningful effect.
# Single-use items are never affected.
# @Spec: LLD-ABILITIES-003, LLD-VESSELS-001
extends GdUnitTestSuite


class StubContent:
	var abilities: Dictionary = {}
	func get_ability(id: String): return abilities.get(id, null)


func _item(id: String, remaining: int) -> ItemInstance:
	var it := ItemInstance.new()
	it.item_id = id
	it.remaining_charges = remaining
	return it


func _ability(id: String, max_charges: int) -> AbilityData:
	var a := AbilityData.new()
	a.ability_id = id
	a.max_charges = max_charges
	return a


# A vessel carrying: staff (durability 6, depleted to 2), amethyst (durability 3,
# depleted to 1), poultice (single-use, 1).
func _gs() -> GameState:
	var gs := GameState.new()
	gs.vessel_state = VesselState.new()
	gs.inventory.assign([_item("staff", 2), _item("amethyst", 1), _item("poultice", 1)])
	return gs


func _content() -> StubContent:
	var c := StubContent.new()
	c.abilities["staff"] = _ability("staff", 6)
	c.abilities["amethyst"] = _ability("amethyst", 3)
	c.abilities["poultice"] = _ability("poultice", 1)
	return c


func _ctx(gs: GameState, content, params: Dictionary) -> AbilityContext:
	var ctx := AbilityContext.new(gs, "player", "")
	ctx.content = content
	ctx.params = params
	return ctx


# --- targeted ---------------------------------------------------------------

func test_target_slot_restores_that_item_to_max() -> void:
	var gs := _gs()
	RestoreItemChargesHandler.new().apply(_ctx(gs, _content(), {"target_slot": 0}))
	assert_int(gs.inventory[0].remaining_charges).is_equal(6)   # staff refilled
	assert_int(gs.inventory[1].remaining_charges).is_equal(1)   # amethyst untouched


func test_target_slot_on_single_use_has_no_effect() -> void:
	var gs := _gs()
	RestoreItemChargesHandler.new().apply(_ctx(gs, _content(), {"target_slot": 2}))
	assert_int(gs.inventory[2].remaining_charges).is_equal(1)   # poultice unchanged


# --- auto-target (no slot given) --------------------------------------------

func test_auto_targets_most_depleted_eligible_item() -> void:
	var gs := _gs()
	# staff is 2/6 (missing 4); amethyst is 1/3 (missing 2). staff is more depleted.
	RestoreItemChargesHandler.new().apply(_ctx(gs, _content(), {}))
	assert_int(gs.inventory[0].remaining_charges).is_equal(6)   # staff refilled
	assert_int(gs.inventory[1].remaining_charges).is_equal(1)   # only one item restored


func test_auto_target_skips_single_use_and_full_items() -> void:
	var gs := GameState.new()
	gs.vessel_state = VesselState.new()
	# Only a full multi-charge item and a depleted single-use item present.
	gs.inventory.assign([_item("staff", 6), _item("poultice", 0)])
	RestoreItemChargesHandler.new().apply(_ctx(gs, _content(), {}))
	assert_int(gs.inventory[0].remaining_charges).is_equal(6)   # already full, unchanged
	assert_int(gs.inventory[1].remaining_charges).is_equal(0)   # single-use, never restored


func test_no_eligible_item_is_noop() -> void:
	var gs := GameState.new()
	gs.vessel_state = VesselState.new()
	gs.inventory.assign([_item("poultice", 1), null])
	RestoreItemChargesHandler.new().apply(_ctx(gs, _content(), {}))
	assert_int(gs.inventory[0].remaining_charges).is_equal(1)   # nothing eligible → no-op
