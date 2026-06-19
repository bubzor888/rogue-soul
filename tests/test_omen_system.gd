# Tests for CombatResolver omen machinery (T5.4): deck assembly (four sources +
# two-tier enemy contribution), timer distribution (25/50/25 via COMBAT),
# cycle draw + reshuffle, CHOOSE_OMEN resolution (sides/timer/deferred Vulnerable/
# played-card application with tag filter + magnitude + Repent), and two-tier
# enemy card removal.
# @Spec: HLD-COMBAT-008, HLD-OMEN-001..-006, LLD-OMEN-MECH-008, -009, LLD-ARCH-019, LLD-ARCH-024
extends GdUnitTestSuite


# --- Stubs ------------------------------------------------------------------

class StubContent:
	var vessels: Dictionary = {}
	var abilities: Dictionary = {}
	var enemies: Dictionary = {}
	var omen_cards: Dictionary = {}
	func get_vessel(id: String):
		return vessels.get(id, null)
	func get_ability(id: String):
		return abilities.get(id, null)
	func get_enemy(id: String):
		return enemies.get(id, null)
	func get_omen_card(id: String):
		return omen_cards.get(id, null)


# Scriptable RNG: pops the next value from `queue` for each randi_range call;
# falls back to `default` when the queue is empty.
class StubRng:
	var queue: Array = []
	var default: int = 0
	func randi_range(_stream: int, _a: int, _b: int) -> int:
		if queue.is_empty():
			return default
		return queue.pop_front()


# --- Builders ---------------------------------------------------------------

func _enemy_data(id: String, contributions: Array, tags: Array = []) -> EnemyData:
	var e := EnemyData.new()
	e.enemy_id = id
	e.omen_contributions.assign(contributions)
	e.enemy_tags.assign(tags)
	return e


func _omen_card(id: String, status_id: String = "", magnitude: int = 0, requires_tag: String = "") -> OmenCardData:
	var c := OmenCardData.new()
	c.card_id = id
	c.status_id = status_id
	c.status_magnitude = magnitude
	c.requires_tag = requires_tag
	return c


func _gs_with_enemies(content: StubContent, enemy_specs: Array) -> GameState:
	# enemy_specs: Array of { enemy_id, instance_id, hp }.
	var gs := GameState.new()
	gs.vessel_state = VesselState.new()
	gs.vessel_state.vessel_id = "pilgrim"
	gs.vessel_state.hp = 20
	gs.vessel_state.max_hp = 30
	gs.combat_state = CombatState.new()
	gs.combat_state.omen_deck = OmenDeckState.new()
	var enemies: Array[EnemyState] = []
	for spec in enemy_specs:
		var e := EnemyState.new()
		e.enemy_id = spec["enemy_id"]
		e.instance_id = spec["instance_id"]
		e.hp = spec.get("hp", 10)
		e.max_hp = 10
		enemies.append(e)
	gs.combat_state.enemies.assign(enemies)
	return gs


func _resolver(content: StubContent, rng = null, pipeline = null) -> CombatResolver:
	return CombatResolver.new(rng, content, pipeline)


func _count_card(entries: Array, card_id: String) -> int:
	var n := 0
	for entry in entries:
		if entry["card_id"] == card_id:
			n += 1
	return n


func _count_timer(entries: Array, timer_value: int) -> int:
	var n := 0
	for entry in entries:
		if entry["timer_value"] == timer_value:
			n += 1
	return n


func _statuses(unit) -> Array:
	return unit.active_statuses


# --- Deck assembly: four sources + two-tier enemy contribution --------------

# Two enemies of the same type → family card added twice (per instance),
# type card added once (per type). Source ids merged in.
func test_assemble_two_tier_same_type() -> void:
	var content := StubContent.new()
	content.enemies["rat"] = _enemy_data("rat", ["thick_hide", "exposed"])
	var gs := _gs_with_enemies(content, [
		{"enemy_id": "rat", "instance_id": "rat_0"},
		{"enemy_id": "rat", "instance_id": "rat_1"},
	])
	_resolver(content, StubRng.new()).assemble_omen_deck(["stillness", "floor_card"], gs)
	var pile := gs.combat_state.omen_deck.draw_pile
	assert_int(_count_card(pile, "thick_hide")).is_equal(2)  # Tier 1: per instance
	assert_int(_count_card(pile, "exposed")).is_equal(1)     # Tier 2: per type
	assert_int(_count_card(pile, "stillness")).is_equal(1)
	assert_int(_count_card(pile, "floor_card")).is_equal(1)


# Two enemies of different types each contribute their own type card.
func test_assemble_two_tier_distinct_types() -> void:
	var content := StubContent.new()
	content.enemies["skeleton"] = _enemy_data("skeleton", ["grave_knit", "emboldened_physical"])
	content.enemies["zombie"] = _enemy_data("zombie", ["rot", "emboldened_physical"])
	var gs := _gs_with_enemies(content, [
		{"enemy_id": "skeleton", "instance_id": "skeleton_0"},
		{"enemy_id": "zombie", "instance_id": "zombie_0"},
	])
	_resolver(content, StubRng.new()).assemble_omen_deck([], gs)
	var pile := gs.combat_state.omen_deck.draw_pile
	assert_int(_count_card(pile, "emboldened_physical")).is_equal(2)  # one per type
	assert_int(_count_card(pile, "grave_knit")).is_equal(1)
	assert_int(_count_card(pile, "rot")).is_equal(1)


# An enemy with only a family card (no type card) contributes just the family card.
func test_assemble_family_only_no_type_card() -> void:
	var content := StubContent.new()
	content.enemies["wolf"] = _enemy_data("wolf", ["thick_hide"])
	var gs := _gs_with_enemies(content, [{"enemy_id": "wolf", "instance_id": "wolf_0"}])
	_resolver(content, StubRng.new()).assemble_omen_deck([], gs)
	assert_int(gs.combat_state.omen_deck.draw_pile.size()).is_equal(1)
	assert_int(_count_card(gs.combat_state.omen_deck.draw_pile, "thick_hide")).is_equal(1)


# --- Timer distribution (25/50/25) ------------------------------------------

# A 4-card deck splits 1/2/1 across timer values 1/2/3 (nearest whole-number).
func test_timer_distribution_quarter_half_quarter() -> void:
	var content := StubContent.new()
	var gs := _gs_with_enemies(content, [])
	_resolver(content, StubRng.new()).assemble_omen_deck(["a", "b", "c", "d"], gs)
	var pile := gs.combat_state.omen_deck.draw_pile
	assert_int(pile.size()).is_equal(4)
	assert_int(_count_timer(pile, 1)).is_equal(1)
	assert_int(_count_timer(pile, 2)).is_equal(2)
	assert_int(_count_timer(pile, 3)).is_equal(1)
	# Every card carries a timer in {1,2,3}.
	for entry in pile:
		assert_bool(entry["timer_value"] in [1, 2, 3]).is_true()


# --- Cycle draw + reshuffle -------------------------------------------------

# resolve_omen_cycle_start draws 3 into a fresh cycle, pausing (sides_assigned false).
func test_cycle_start_draws_three_and_pauses() -> void:
	var content := StubContent.new()
	var gs := _gs_with_enemies(content, [])
	var deck := gs.combat_state.omen_deck
	deck.draw_pile.assign([
		{"card_id": "a", "timer_value": 1},
		{"card_id": "b", "timer_value": 2},
		{"card_id": "c", "timer_value": 3},
		{"card_id": "d", "timer_value": 2},
	])
	_resolver(content, StubRng.new()).resolve_omen_cycle_start(gs)
	var cycle := gs.combat_state.current_cycle
	assert_object(cycle).is_not_null()
	assert_int(cycle.drawn_cards.size()).is_equal(3)
	assert_bool(cycle.sides_assigned).is_false()
	assert_int(cycle.player_choice_index).is_equal(-1)
	assert_int(deck.draw_pile.size()).is_equal(1)  # 4 − 3 drawn


# When the draw pile has fewer than 3, the discard pile is reshuffled back in first.
func test_cycle_start_reshuffles_when_depleted() -> void:
	var content := StubContent.new()
	var gs := _gs_with_enemies(content, [])
	var deck := gs.combat_state.omen_deck
	deck.draw_pile.assign([{"card_id": "a", "timer_value": 1}])
	deck.discard_pile.assign([
		{"card_id": "b", "timer_value": 2},
		{"card_id": "c", "timer_value": 3},
		{"card_id": "d", "timer_value": 2},
	])
	_resolver(content, StubRng.new()).resolve_omen_cycle_start(gs)
	var cycle := gs.combat_state.current_cycle
	assert_int(cycle.drawn_cards.size()).is_equal(3)  # reshuffle made 4 available
	assert_int(deck.discard_pile.size()).is_equal(0)  # discard folded into draw


# --- CHOOSE_OMEN resolution -------------------------------------------------

func _pending_cycle(gs: GameState, timers: Array) -> void:
	var cycle := OmenCycleState.new()
	var cards: Array[Dictionary] = []
	var names := ["c0", "c1", "c2"]
	for i in timers.size():
		cards.append({"card_id": names[i], "timer_value": timers[i]})
	cycle.drawn_cards.assign(cards)
	cycle.sides_assigned = false
	gs.combat_state.current_cycle = cycle


# Player picks index 0; the random pick selects one of {1,2}; the remaining index
# is the timer. With rng→0 the random pick is index 1, so index 2 is the timer (3).
func test_choose_omen_assigns_sides_and_timer() -> void:
	var content := StubContent.new()
	content.omen_cards["c0"] = _omen_card("c0")  # no status
	content.omen_cards["c1"] = _omen_card("c1")
	var gs := _gs_with_enemies(content, [{"enemy_id": "rat", "instance_id": "rat_0"}])
	_pending_cycle(gs, [1, 2, 3])
	var rng := StubRng.new()  # default 0 → picks others[0] = index 1
	_resolver(content, rng).resolve_choose_omen({"card_index": 0, "side": "enemy"}, gs)
	var cycle := gs.combat_state.current_cycle
	assert_bool(cycle.sides_assigned).is_true()
	assert_int(cycle.player_choice_index).is_equal(0)
	assert_int(cycle.random_assignment_index).is_equal(1)
	assert_int(cycle.timer_index).is_equal(2)


# A Burning card chosen to the enemy side applies Burning to every living enemy.
func test_choose_omen_applies_card_to_target_side() -> void:
	var content := StubContent.new()
	content.omen_cards["c0"] = _omen_card("c0", "burning", 5)
	content.omen_cards["c1"] = _omen_card("c1")
	content.enemies["rat"] = _enemy_data("rat", [])
	var gs := _gs_with_enemies(content, [
		{"enemy_id": "rat", "instance_id": "rat_0"},
		{"enemy_id": "rat", "instance_id": "rat_1"},
	])
	_pending_cycle(gs, [2, 1, 3])
	_resolver(content, StubRng.new()).resolve_choose_omen({"card_index": 0, "side": "enemy"}, gs)
	for enemy in gs.combat_state.enemies:
		assert_int(_statuses(enemy).size()).is_equal(1)
		assert_str(_statuses(enemy)[0].status_id).is_equal("burning")
		assert_int(_statuses(enemy)[0].magnitude).is_equal(5)
		assert_int(_statuses(enemy)[0].remaining_ticks).is_equal(3)  # leftover timer


# A tag-conditional card only affects matching units on the side.
func test_choose_omen_tag_filter_skips_non_matching() -> void:
	var content := StubContent.new()
	content.omen_cards["c0"] = _omen_card("c0", "mending", 4, "undead")
	content.omen_cards["c1"] = _omen_card("c1")
	content.enemies["skeleton"] = _enemy_data("skeleton", [], ["undead"])
	content.enemies["rat"] = _enemy_data("rat", [], ["beast"])
	var gs := _gs_with_enemies(content, [
		{"enemy_id": "skeleton", "instance_id": "skeleton_0"},
		{"enemy_id": "rat", "instance_id": "rat_0"},
	])
	_pending_cycle(gs, [2, 1, 3])
	_resolver(content, StubRng.new()).resolve_choose_omen({"card_index": 0, "side": "enemy"}, gs)
	var skeleton := gs.combat_state.enemies[0]
	var rat := gs.combat_state.enemies[1]
	assert_int(_statuses(skeleton).size()).is_equal(1)  # undead matched
	assert_int(_statuses(rat).size()).is_equal(0)        # beast skipped


# Family card steered to the player side is safe — the player is never tagged.
func test_choose_omen_family_card_to_player_is_safe() -> void:
	var content := StubContent.new()
	content.omen_cards["c0"] = _omen_card("c0", "mending", 4, "undead")
	content.omen_cards["c1"] = _omen_card("c1")
	var gs := _gs_with_enemies(content, [{"enemy_id": "rat", "instance_id": "rat_0"}])
	_pending_cycle(gs, [2, 1, 3])
	_resolver(content, StubRng.new()).resolve_choose_omen({"card_index": 0, "side": "player"}, gs)
	assert_int(_statuses(gs.vessel_state).size()).is_equal(0)


# The deferred Vulnerable (from an Exposed shift) is applied with the new timer.
func test_choose_omen_applies_deferred_vulnerable() -> void:
	var content := StubContent.new()
	content.omen_cards["c0"] = _omen_card("c0")
	content.omen_cards["c1"] = _omen_card("c1")
	var gs := _gs_with_enemies(content, [{"enemy_id": "rat", "instance_id": "rat_0"}])
	gs.combat_state.pending_vulnerable_units.assign(["rat_0"])
	_pending_cycle(gs, [1, 2, 3])
	# player picks 0; rng→0 picks index 1 random; leftover index 2 timer = 3.
	_resolver(content, StubRng.new()).resolve_choose_omen({"card_index": 0, "side": "enemy"}, gs)
	var rat := gs.combat_state.enemies[0]
	var found := false
	for s in _statuses(rat):
		if s.status_id == "vulnerable" and s.string_param == "physical":
			found = true
			assert_int(s.remaining_ticks).is_equal(3)
	assert_bool(found).is_true()
	assert_int(gs.combat_state.pending_vulnerable_units.size()).is_equal(0)  # cleared


# Invalid CHOOSE_OMEN (no pending choice) leaves the state unchanged.
func test_choose_omen_invalid_returns_unchanged() -> void:
	var content := StubContent.new()
	var gs := _gs_with_enemies(content, [{"enemy_id": "rat", "instance_id": "rat_0"}])
	gs.combat_state.current_cycle = null
	_resolver(content, StubRng.new()).resolve_choose_omen({"card_index": 0, "side": "enemy"}, gs)
	assert_object(gs.combat_state.current_cycle).is_null()


func test_choose_omen_out_of_range_returns_unchanged() -> void:
	var content := StubContent.new()
	var gs := _gs_with_enemies(content, [{"enemy_id": "rat", "instance_id": "rat_0"}])
	_pending_cycle(gs, [1, 2, 3])
	_resolver(content, StubRng.new()).resolve_choose_omen({"card_index": 9, "side": "enemy"}, gs)
	assert_bool(gs.combat_state.current_cycle.sides_assigned).is_false()  # not resolved


# --- Repent special handling ------------------------------------------------

# Repent to the player side with 0 items heals 5 HP and keeps processing.
func test_repent_zero_items_heals_five() -> void:
	var content := StubContent.new()
	content.omen_cards["repent"] = _omen_card("repent")
	content.omen_cards["c1"] = _omen_card("c1")
	var gs := _gs_with_enemies(content, [{"enemy_id": "rat", "instance_id": "rat_0"}])
	gs.vessel_state.hp = 20
	gs.inventory.assign([])
	_pending_cycle(gs, [2, 1, 3])
	# repent is card index 0 ("c0" name) — override its id to "repent".
	gs.combat_state.current_cycle.drawn_cards[0]["card_id"] = "repent"
	_resolver(content, StubRng.new()).resolve_choose_omen({"card_index": 0, "side": "player"}, gs)
	assert_int(gs.vessel_state.hp).is_equal(25)
	assert_int(gs.combat_state.pending_repent_slots.size()).is_equal(0)


# Repent with 1 item sets pending_repent_slots to that slot and halts.
func test_repent_one_item_sets_pending_slot() -> void:
	var content := StubContent.new()
	content.omen_cards["repent"] = _omen_card("repent")
	content.omen_cards["c1"] = _omen_card("c1", "burning", 3)
	var gs := _gs_with_enemies(content, [{"enemy_id": "rat", "instance_id": "rat_0"}])
	var item := ItemInstance.new()
	item.item_id = "walking_staff"
	gs.inventory.assign([item])
	_pending_cycle(gs, [2, 1, 3])
	gs.combat_state.current_cycle.drawn_cards[0]["card_id"] = "repent"
	_resolver(content, StubRng.new()).resolve_choose_omen({"card_index": 0, "side": "player"}, gs)
	assert_array(gs.combat_state.pending_repent_slots).is_equal([0])
	assert_bool(gs.combat_state.current_cycle.sides_assigned).is_true()
	# Halt: the random/opposite card was not applied to the enemy.
	assert_int(_statuses(gs.combat_state.enemies[0]).size()).is_equal(0)


# Repent with 2+ items selects two distinct slots via the COMBAT stream.
func test_repent_two_items_picks_two_slots() -> void:
	var content := StubContent.new()
	content.omen_cards["repent"] = _omen_card("repent")
	content.omen_cards["c1"] = _omen_card("c1")
	var gs := _gs_with_enemies(content, [{"enemy_id": "rat", "instance_id": "rat_0"}])
	var i0 := ItemInstance.new(); i0.item_id = "a"
	var i1 := ItemInstance.new(); i1.item_id = "b"
	var i2 := ItemInstance.new(); i2.item_id = "c"
	gs.inventory.assign([i0, i1, i2])
	_pending_cycle(gs, [2, 1, 3])
	gs.combat_state.current_cycle.drawn_cards[0]["card_id"] = "repent"
	var rng := StubRng.new()
	rng.queue = [0, 0]  # pick pool[0] (slot 0), then pool[0] of the remaining (slot 1)
	_resolver(content, rng).resolve_choose_omen({"card_index": 0, "side": "player"}, gs)
	assert_int(gs.combat_state.pending_repent_slots.size()).is_equal(2)
	# Two distinct slots.
	var slots := gs.combat_state.pending_repent_slots
	assert_bool(slots[0] != slots[1]).is_true()


# --- Two-tier enemy card removal (HLD-OMEN-006) -----------------------------

# One of two same-type enemies dies: one family card removed; type card stays.
func test_remove_family_card_keeps_type_card_while_type_alive() -> void:
	var content := StubContent.new()
	content.enemies["rat"] = _enemy_data("rat", ["thick_hide", "exposed"])
	var gs := _gs_with_enemies(content, [
		{"enemy_id": "rat", "instance_id": "rat_0", "hp": 0},  # dead
		{"enemy_id": "rat", "instance_id": "rat_1", "hp": 5},  # alive
	])
	gs.combat_state.omen_deck.draw_pile.assign([
		{"card_id": "thick_hide", "timer_value": 1},
		{"card_id": "thick_hide", "timer_value": 2},
		{"card_id": "exposed", "timer_value": 1},
	])
	_resolver(content, StubRng.new()).remove_enemy_omen_cards("rat_0", gs)
	var pile := gs.combat_state.omen_deck.draw_pile
	assert_int(_count_card(pile, "thick_hide")).is_equal(1)  # one copy removed
	assert_int(_count_card(pile, "exposed")).is_equal(1)     # type card kept


# The last enemy of a type dies: its family card and the type card are both removed.
func test_remove_type_card_when_last_of_type_dies() -> void:
	var content := StubContent.new()
	content.enemies["rat"] = _enemy_data("rat", ["thick_hide", "exposed"])
	var gs := _gs_with_enemies(content, [
		{"enemy_id": "rat", "instance_id": "rat_0", "hp": 0},  # last rat, dead
	])
	gs.combat_state.omen_deck.draw_pile.assign([
		{"card_id": "thick_hide", "timer_value": 1},
		{"card_id": "exposed", "timer_value": 1},
	])
	gs.combat_state.omen_deck.discard_pile.assign([])
	_resolver(content, StubRng.new()).remove_enemy_omen_cards("rat_0", gs)
	var pile := gs.combat_state.omen_deck.draw_pile
	assert_int(_count_card(pile, "thick_hide")).is_equal(0)
	assert_int(_count_card(pile, "exposed")).is_equal(0)


# A family card copy is removed from the discard pile when it isn't in the draw pile.
func test_remove_family_card_from_discard_pile() -> void:
	var content := StubContent.new()
	content.enemies["rat"] = _enemy_data("rat", ["thick_hide"])
	var gs := _gs_with_enemies(content, [{"enemy_id": "rat", "instance_id": "rat_0", "hp": 0}])
	gs.combat_state.omen_deck.draw_pile.assign([])
	gs.combat_state.omen_deck.discard_pile.assign([{"card_id": "thick_hide", "timer_value": 2}])
	_resolver(content, StubRng.new()).remove_enemy_omen_cards("rat_0", gs)
	assert_int(_count_card(gs.combat_state.omen_deck.discard_pile, "thick_hide")).is_equal(0)
