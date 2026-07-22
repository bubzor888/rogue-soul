# @Spec: UI-OMEN-003, UI-OMEN-004, UI-OMEN-008
extends GdUnitTestSuite

class _FakeOmenContent:
	func get_omen_card(id: String) -> OmenCardData:
		var c := OmenCardData.new()
		c.card_id = id
		c.display_name = id.capitalize()
		c.status_id = "burning"
		c.status_magnitude = 3
		return c

func _cycle_with_cards(cards: Array) -> GameState:
	var gs := GameState.new()
	gs.combat_state = CombatState.new()
	gs.combat_state.current_cycle = OmenCycleState.new()
	gs.combat_state.current_cycle.drawn_cards.assign(cards)
	return gs

# UI-OMEN-003: every drawn card shows both an effect box and a duration (number) box.
func test_three_cards_have_effect_and_duration_boxes() -> void:
	var gs := _cycle_with_cards([
		{"card_id": "burning_omen", "timer_value": 3},
		{"card_id": "chill_omen", "timer_value": 5},
		{"card_id": "spark_omen", "timer_value": 2},
	])
	var vm := OmenOverlayViewModel.new(gs, [], _FakeOmenContent.new())
	var cards := vm.cards()
	assert_int(cards.size()).is_equal(3)
	assert_int(cards[0]["duration"]).is_equal(3)
	assert_bool(cards[0].has("effect_icon")).is_true()

# UI-OMEN-004: each card exposes its two CHOOSE_OMEN actions (one per side), paired for the flow.
func test_card_pairs_both_side_actions() -> void:
	var gs := _cycle_with_cards([{"card_id": "burning_omen", "timer_value": 3}])
	var legal := [
		{"type": "CHOOSE_OMEN", "card_index": 0, "side": "enemy"},
		{"type": "CHOOSE_OMEN", "card_index": 0, "side": "player"},
	]
	var vm := OmenOverlayViewModel.new(gs, legal, _FakeOmenContent.new())
	var sides := vm.side_actions(0)
	assert_dict(sides["enemy"]).is_equal({"type": "CHOOSE_OMEN", "card_index": 0, "side": "enemy"})
	assert_dict(sides["player"]).is_equal({"type": "CHOOSE_OMEN", "card_index": 0, "side": "player"})
