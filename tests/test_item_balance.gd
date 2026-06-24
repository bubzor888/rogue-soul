# Balance benchmark — forces one weapon into the first loot slot per run with an
# invincible random agent, then measures average turns-per-room. Used pre-MVP2 to
# sanity-check whether LLD-IR-011 scores correlate with in-run performance.
#
# Results are printed to stdout for human review; the test only hard-asserts a soft
# sanity check (arc_wand beats baseline). All values are expected to shift with
# real UI playtesting — this is a headless pre-screen only.
# @Spec: LLD-ARCH-014, LLD-IR-011, SCOPE-001
extends GdUnitTestSuite

const SignalBusScript = preload("res://src/infrastructure/signal_bus.gd")
const SEEDS := 30

# Weapons benchmarked — keyed by item_id, value = LLD-IR-011 score.
# "" = baseline (Walking Staff starting weapon only, all loot declined).
const WEAPONS := {
	"": 0,
	"cracked_cudgel": 41,
	"rope_flail": 42,
	"battered_sword": 57,
	"ember_shard": 39,
	"iron_maul": 70,
	"spiked_chain": 74,
	"soldiers_blade": 85,
	"smoldering_brand": 89,
	"glacial_brand": 89,
	"arc_wand": 108,
}

# Consumables benchmarked against baseline (added as second item; no weapon change).
# The random agent won't use them optimally, so the signal is weak — watch the
# variance rather than the absolute TPR.
const CONSUMABLES := {
	"fire_bomb": 14,
	"combustible_oil": 17,
	"hardening_resin": 12,
	"frost_shard": 12,
	"brittle_charm": 18,
	"fulminating_powder": 16,
	"poultice": 13,
}


func after_test() -> void:
	GameConfig.DEBUG = false


# --- Weapon benchmark -----------------------------------------------------------

# Each weapon gets SEEDS invincible runs. The forced weapon is picked up at the
# first loot opportunity; all subsequent loot is declined. Prints a sorted
# turns-per-room table, then soft-asserts arc_wand beats baseline.
func test_weapon_balance_benchmark() -> void:
	GameConfig.DEBUG = true
	var bus: Node = auto_free(SignalBusScript.new())
	var results: Array = []

	for item_id in WEAPONS:
		var total_turns := 0
		var total_rooms := 0
		for seed in range(SEEDS):
			var r := _run_with_forced_item(seed, item_id, bus)
			total_turns += r["turns"]
			total_rooms += r["rooms"]
		var avg_tpr := float(total_turns) / maxf(float(total_rooms), 1.0)
		results.append({
			"item_id": item_id if item_id != "" else "(baseline)",
			"score": WEAPONS[item_id],
			"avg_tpr": avg_tpr,
			"total_rooms": total_rooms,
		})

	results.sort_custom(func(a, b): return float(a["avg_tpr"]) < float(b["avg_tpr"]))

	print("\n=== WEAPON BALANCE BENCHMARK (%d seeds) ===" % SEEDS)
	print("%-24s %6s %8s   %s" % ["Item", "Score", "AvgTPR", "Notes"])
	print("--------------------------------------------------------------")
	for r in results:
		var flag := ""
		if r["score"] == 57:
			flag = "[REVIEW normal]"
		elif r["score"] == 108:
			flag = "[REVIEW elite]"
		print("%-24s %6d %8.2f   %s" % [r["item_id"], r["score"], r["avg_tpr"], flag])
	print("(TPR = turns per room; lower = kills faster = stronger)")

	# Soft sanity: the highest-scored item (arc_wand 108) should out-damage baseline.
	var baseline_tpr := 0.0
	var arc_tpr := 0.0
	for r in results:
		if r["item_id"] == "(baseline)":
			baseline_tpr = r["avg_tpr"]
		elif r["item_id"] == "arc_wand":
			arc_tpr = r["avg_tpr"]
	assert_float(arc_tpr) \
		.override_failure_message("arc_wand (score 108) TPR %.2f should be < baseline %.2f" \
			% [arc_tpr, baseline_tpr]) \
		.is_less(baseline_tpr)


# --- Consumable benchmark -------------------------------------------------------

# Same setup but the forced item is a consumable alongside the starting Walking Staff.
# Consumable signal is weaker (random agent rarely uses them at the right moment)
# but shows whether they provide meaningful throughput or healing at all.
func test_consumable_balance_benchmark() -> void:
	GameConfig.DEBUG = true
	var bus: Node = auto_free(SignalBusScript.new())
	var results: Array = []

	# Baseline: Walking Staff only.
	var base_turns := 0
	var base_rooms := 0
	for seed in range(SEEDS):
		var r := _run_with_forced_item(seed, "", bus)
		base_turns += r["turns"]
		base_rooms += r["rooms"]
	var base_tpr := float(base_turns) / maxf(float(base_rooms), 1.0)
	results.append({"item_id": "(baseline)", "score": 0, "avg_tpr": base_tpr})

	for item_id in CONSUMABLES:
		var total_turns := 0
		var total_rooms := 0
		for seed in range(SEEDS):
			var r := _run_with_forced_item(seed, item_id, bus)
			total_turns += r["turns"]
			total_rooms += r["rooms"]
		var avg_tpr := float(total_turns) / maxf(float(total_rooms), 1.0)
		results.append({"item_id": item_id, "score": CONSUMABLES[item_id], "avg_tpr": avg_tpr})

	results.sort_custom(func(a, b): return float(a["avg_tpr"]) < float(b["avg_tpr"]))

	print("\n=== CONSUMABLE BALANCE BENCHMARK (%d seeds) ===" % SEEDS)
	print("%-24s %6s %8s" % ["Item", "Score", "AvgTPR"])
	print("------------------------------------------")
	for r in results:
		print("%-24s %6d %8.2f" % [r["item_id"], r["score"], r["avg_tpr"]])
	print("(Note: random agent uses consumables suboptimally; look for large outliers)")


# --- Core helper ----------------------------------------------------------------

# Run one seed with `item_id` forced as the ONLY first loot pick; all other loot
# declined. The player is kept alive via DebugHooks. Returns {turns, rooms}.
func _run_with_forced_item(seed: int, item_id: String, bus: Node) -> Dictionary:
	var ai_rng := RandomNumberGenerator.new()
	ai_rng.seed = seed
	RNGService.seed_run(seed)

	var rc := RunController.new()
	rc.configure(RNGService, ContentRegistry, bus)
	rc.start_run(seed, "pilgrim")

	var item_given := false
	var guard := 0
	while not rc.is_finished() and guard < 1_000_000:
		guard += 1
		DebugHooks.keep_player_alive(rc.game_state)

		if rc.game_state.run_phase == GameState.RunPhase.LOOT_SELECTION:
			if not item_given and item_id != "":
				DebugHooks.force_loot_offers(rc.game_state, [item_id])
				rc.submit_action({"type": "CHOOSE_LOOT", "item_id": item_id})
				item_given = true
			else:
				rc.submit_action({"type": "DECLINE_LOOT"})
		else:
			var actions := rc.get_legal_actions()
			if not actions.is_empty():
				rc.submit_action(actions[ai_rng.randi_range(0, actions.size() - 1)])

	var nav := rc.game_state.navigation_state if rc.game_state != null else null
	var rooms := nav.rooms_completed_this_floor if nav != null else 0
	var result := {"turns": rc.turn_count, "rooms": rooms}
	rc.free()
	return result
