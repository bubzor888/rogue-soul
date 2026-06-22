# @Spec: LLD-ARCH-020
#
# RunResult — the immutable summary an AIPlayerAgent returns from a completed run
# (LLD-ARCH-020). It is the comparison unit for the headless determinism gate
# (T7.2): two runs of the same seed must produce equal RunResults.
class_name RunResult
extends RefCounted

var seed: int = 0
var vessel_id: String = ""
var floors_completed: int = 0
var outcome: String = ""          # "death" | "completion"
var turn_count: int = 0


# Field-by-field equality — the determinism gate compares whole results.
# @Spec: LLD-ARCH-020
func equals(other: RunResult) -> bool:
	return other != null \
		and seed == other.seed \
		and vessel_id == other.vessel_id \
		and floors_completed == other.floors_completed \
		and outcome == other.outcome \
		and turn_count == other.turn_count


func to_dict() -> Dictionary:
	return {
		"seed": seed,
		"vessel_id": vessel_id,
		"floors_completed": floors_completed,
		"outcome": outcome,
		"turn_count": turn_count,
	}
