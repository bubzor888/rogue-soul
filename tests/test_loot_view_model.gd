# @Spec: UI-LOOT-002, UI-LOOT-004, UI-LOOT-005, UI-LOOT-006
extends GdUnitTestSuite

class FakeContent:
	var _by_id: Dictionary
	func _init(by_id: Dictionary) -> void: _by_id = by_id
	func get_ability(id: String): return _by_id.get(id)

# Damage/type live in a deal_damage HandlerConfig, never on AbilityData directly.
func _weapon(dmg: int, dtype: String) -> AbilityData:
	var a := AbilityData.new()
	a.action_bucket = "attack"
	a.display_name = "Test Weapon"
	var h := HandlerConfig.new()
	h.handler_id = "deal_damage"
	h.params = {"base_damage": dmg, "damage_type": dtype}
	a.handlers.assign([h])
	return a

func _support() -> AbilityData:
	var a := AbilityData.new()
	a.action_bucket = "support"
	a.display_name = "Test Charm"
	return a

func _gs_with_offers(offers: Array, inventory: Array) -> GameState:
	var gs := GameState.new()
	gs.navigation_state = NavigationState.new()
	gs.navigation_state.loot_offers.assign(offers)
	gs.inventory.assign(inventory)
	return gs

func test_count_strip_tallies_by_bucket() -> void:
	var content := FakeContent.new({
		"axe": _weapon(8, "physical"),
		"charm": _support(),
	})
	var w := ItemInstance.new(); w.item_id = "axe"
	var s := ItemInstance.new(); s.item_id = "charm"
	var gs := _gs_with_offers([], [w, s, null])
	var vm := LootViewModel.new(gs, [], content)
	var strip := vm.count_strip()
	assert_int(strip["weapons"]).is_equal(1)
	assert_int(strip["support"]).is_equal(1)
	assert_int(strip["consumables"]).is_equal(0)

func test_offer_card_pairs_with_choose_loot_action() -> void:
	var content := FakeContent.new({"axe": _weapon(8, "physical")})
	var gs := _gs_with_offers(["axe"], [null, null, null])
	var legal := [{"type": "CHOOSE_LOOT", "item_id": "axe"}, {"type": "DECLINE_LOOT"}]
	var vm := LootViewModel.new(gs, legal, content)
	var cards := vm.offer_cards()
	assert_int(cards.size()).is_equal(1)
	assert_str(cards[0]["kind"]).is_equal("weapon")
	assert_int(cards[0]["damage"]).is_equal(8)
	assert_str(cards[0]["damage_type"]).is_equal("physical")
	assert_dict(cards[0]["action"]).is_equal({"type": "CHOOSE_LOOT", "item_id": "axe"})

func test_decline_action_exposed() -> void:
	var gs := _gs_with_offers([], [])
	var vm := LootViewModel.new(gs, [{"type": "DECLINE_LOOT"}], FakeContent.new({}))
	assert_dict(vm.decline_action()).is_equal({"type": "DECLINE_LOOT"})
