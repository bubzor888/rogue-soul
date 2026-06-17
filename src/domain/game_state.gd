# @Spec: LLD-ARCH-017, LLD-ARCH-004
#
# GameState — the root domain Resource holding all run state, composed of typed
# sub-Resources. Treated as immutable by convention (methods return new states).
# Fully JSON-serialisable: no Node/Callable/Object references anywhere.
#
# clone() is implemented via from_json(to_json()) so a clone is guaranteed deeply
# independent and the single serialisation path is exercised on every copy.
class_name GameState
extends Resource

## Run phase state machine (LLD-ARCH-016). run_phase stores the enum value (int).
enum RunPhase {
	NAVIGATION,
	COMBAT,
	LOOT_SELECTION,
	NON_COMBAT_EVENT,
	FLOOR_TRANSITION,
	RUN_END,
}

## Base seed for all RNG streams.
@export var run_seed: int = 0

@export var vessel_state: VesselState = null

## Up to 3 slots; null entries are empty slots.
@export var inventory: Array[ItemInstance] = []

## Null if the vessel has no bound companion.
@export var bound_companion: CompanionState = null

## Null if no temporary companion is active.
@export var temporary_companion: CompanionState = null

## Current floor (3 for MVP1).
@export var floor_number: int = 0

## RunPhase enum value.
@export var run_phase: int = RunPhase.NAVIGATION

@export var navigation_state: NavigationState = null

## Null when not in COMBAT phase.
@export var combat_state: CombatState = null

## Whole-run accumulated item burden (HLD-RUN-007); initialised from vessel
## starting items at run start.
@export var item_burden_score: int = 0


func to_json() -> Dictionary:
	return {
		"run_seed": run_seed,
		"vessel_state": Serde.to_json_or_null(vessel_state),
		"inventory": Serde.res_array_to_json(inventory),
		"bound_companion": Serde.to_json_or_null(bound_companion),
		"temporary_companion": Serde.to_json_or_null(temporary_companion),
		"floor_number": floor_number,
		"run_phase": run_phase,
		"navigation_state": Serde.to_json_or_null(navigation_state),
		"combat_state": Serde.to_json_or_null(combat_state),
		"item_burden_score": item_burden_score,
	}


static func from_json(data: Dictionary) -> GameState:
	var g := GameState.new()
	g.run_seed = int(data.get("run_seed", 0))
	g.vessel_state = Serde.obj_from_json(data.get("vessel_state"), Callable(VesselState, "from_json"))
	g.inventory.assign(Serde.res_array_from_json(data.get("inventory", []), Callable(ItemInstance, "from_json")))
	g.bound_companion = Serde.obj_from_json(data.get("bound_companion"), Callable(CompanionState, "from_json"))
	g.temporary_companion = Serde.obj_from_json(data.get("temporary_companion"), Callable(CompanionState, "from_json"))
	g.floor_number = int(data.get("floor_number", 0))
	g.run_phase = int(data.get("run_phase", RunPhase.NAVIGATION))
	g.navigation_state = Serde.obj_from_json(data.get("navigation_state"), Callable(NavigationState, "from_json"))
	g.combat_state = Serde.obj_from_json(data.get("combat_state"), Callable(CombatState, "from_json"))
	g.item_burden_score = int(data.get("item_burden_score", 0))
	return g


# Deep, independent copy via the serialisation path. @Spec: LLD-ARCH-004
func clone() -> GameState:
	return GameState.from_json(to_json())
