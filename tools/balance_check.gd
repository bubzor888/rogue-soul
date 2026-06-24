#!/usr/bin/env -S godot -s
# Standalone headless balance benchmark.
# Run: godot --headless --path <project_root> -s res://tools/balance_check.gd
#
# Prints a turns-per-room table for each weapon and consumable, comparing
# LLD-IR-011 scores against actual in-run performance with an invincible
# random-play Pilgrim.
extends SceneTree

const SignalBusScript = preload("res://src/infrastructure/signal_bus.gd")
const SEEDS := 30

# Weapons under test: item_id -> LLD-IR-011 score ("" = baseline, no forced item)
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

# Consumables under test (added as free item alongside starting Walking Staff)
const CONSUMABLES := {
	"fire_bomb": 14,
	"combustible_oil": 17,
	"hardening_resin": 12,
	"frost_shard": 12,
	"brittle_charm": 18,
	"fulminating_powder": 16,
	"poultice": 13,
	"ointment": 10,
}


func _initialize() -> void:
	# Godot autoloads are not wired in script mode — bootstrap the needed ones.
	GameConfig.DEBUG = true

	print("")
	print("=".repeat(60))
	print("  ITEM BALANCE BENCHMARK  (%d seeds per item)" % SEEDS)
	print("=".repeat(60))

	_run_weapon_benchmark()
	_run_consumable_benchmark()

	GameConfig.DEBUG = false
	quit(0)


func _run_weapon_benchmark() -> void:
	print("")
	print("--- WEAPONS (turns-per-room; lower = kills faster) ---")
	print("%-24s  %5s  %7s" % ["Item", "Score", "AvgTPR"])
	print("-".repeat(42))

	var results: Array = []
	for item_id in WEAPONS:
		var total_turns := 0
		var total_rooms := 0
		for seed in range(SEEDS):
			var r := _run_with_forced_item(seed, item_id)
			total_turns += r["turns"]
			total_rooms += r["rooms"]
		var avg_tpr := float(total_turns) / maxf(float(total_rooms), 1.0)
		results.append({
			"item_id": item_id if item_id != "" else "(baseline)",
			"score": WEAPONS[item_id],
			"avg_tpr": avg_tpr,
		})

	results.sort_custom(func(a, b): return a["avg_tpr"] < b["avg_tpr"])
	for r in results:
		var tag := ""
		if r["score"] == 57:
			tag = "  <-- [REVIEW] normal pool"
		elif r["score"] == 108:
			tag = "  <-- [REVIEW] elite"
		print("%-24s  %5d  %7.2f%s" % [r["item_id"], r["score"], r["avg_tpr"], tag])


func _run_consumable_benchmark() -> void:
	print("")
	print("--- CONSUMABLES (added alongside Walking Staff) ---")
	print("%-24s  %5s  %7s" % ["Item", "Score", "AvgTPR"])
	print("-".repeat(42))

	# Shared baseline (cached from weapon benchmark would be cleaner, but run it
	# again to keep functions independent; 30 seeds is fast).
	var base_total_turns := 0
	var base_total_rooms := 0
	for seed in range(SEEDS):
		var r := _run_with_forced_item(seed, "")
		base_total_turns += r["turns"]
		base_total_rooms += r["rooms"]
	var base_tpr := float(base_total_turns) / maxf(float(base_total_rooms), 1.0)

	var results: Array = [{"item_id": "(baseline)", "score": 0, "avg_tpr": base_tpr}]
	for item_id in CONSUMABLES:
		var total_turns := 0
		var total_rooms := 0
		for seed in range(SEEDS):
			var r := _run_with_forced_item(seed, item_id)
			total_turns += r["turns"]
			total_rooms += r["rooms"]
		var avg_tpr := float(total_turns) / maxf(float(total_rooms), 1.0)
		results.append({"item_id": item_id, "score": CONSUMABLES[item_id], "avg_tpr": avg_tpr})

	results.sort_custom(func(a, b): return a["avg_tpr"] < b["avg_tpr"])
	for r in results:
		print("%-24s  %5d  %7.2f" % [r["item_id"], r["score"], r["avg_tpr"]])
	print("")
	print("(Note: random agent rarely uses consumables optimally —")
	print(" look for outliers, not precise ordering)")


# Run one seed with `item_id` forced as the first (and only) loot pick;
# keep_player_alive so the run always completes. Returns {turns, rooms}.
func _run_with_forced_item(seed: int, item_id: String) -> Dictionary:
	var ai_rng := RandomNumberGenerator.new()
	ai_rng.seed = seed
	RNGService.seed_run(seed)

	var bus := SignalBusScript.new()
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
	bus.free()
	return result
