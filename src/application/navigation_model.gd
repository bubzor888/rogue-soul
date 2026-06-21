# @Spec: HLD-RUN-005, LLD-FLOOR-STRUCT-006
#
# NavigationModel — generates the door-by-door navigation choices for a floor from
# a data-driven FloorProfile (HLD-RUN-005). Application layer (operates on
# GameState + the injected NAVIGATION rng; no scene tree). All room composition
# lives in the FloorProfile, so a new floor needs no code change here.
#
# The fixed nine-room layout (LLD-FLOOR-STRUCT-006) is enforced positionally: the
# Elite Gate is always the profile's `elite_gate_room()`; the boss (Judge) follows
# the last room. Between rooms the player faces a two-door choice (HLD-DOOR-001),
# each door carrying its encounter identity (HLD-DOOR-002).
#
# MVP1 scope: only combat (and the Elite Gate's elite door) is generated — Memory
# Fragment / Wandering Soul and their segment caps are MVP2. With combat the only
# pooled type, the pool-exhaustion rule (HLD-DOOR-004) manifests as "both doors are
# combat", with distinct enemy identities when the normal pool has ≥2 types. The
# Worn Map single-door companion beat (room 4) is layered on in T6.6.
#
# The rng is injected (matching CombatResolver/ChargeManager) so the Domain stays
# testable; it must expose randi_range(stream, a, b) and is driven on the
# NAVIGATION stream (LLD-ARCH-008). RunController supplies RNGService at run time.
class_name NavigationModel
extends RefCounted

## RNGService.Stream.NAVIGATION — held as a const so the model never touches the
## RNGService autoload global directly (matches CombatResolver's STREAM_COMBAT).
const STREAM_NAVIGATION := 0

const ROOM_COMBAT := "combat"
const ROOM_ELITE_COMBAT := "elite_combat"

var _rng


func _init(rng = null) -> void:
	_rng = rng


# The door choice for the room the player is about to enter (1-based room number =
# rooms_completed + 1). Returns an empty array once all rooms are complete — the
# boss (Judge) follows with no door choice (LLD-FLOOR-BEATS-005).
# @Spec: HLD-DOOR-001, HLD-DOOR-002, HLD-DOOR-004, LLD-FLOOR-STRUCT-006, LLD-FLOOR-BEATS-004, LLD-FLOOR-BEATS-005, LLD-ARCH-008
func generate_doors(game_state: GameState, profile: FloorProfile) -> Array:
	var next_room := game_state.navigation_state.rooms_completed_this_floor + 1
	if next_room > profile.total_rooms():
		return []  # boss next — no choice
	if next_room == profile.elite_gate_room():
		return _elite_gate_doors(next_room, profile)
	return _combat_doors(next_room, profile)


# True once every navigable room is complete and only the boss remains.
# @Spec: HLD-RUN-004, LLD-FLOOR-BEATS-005
func is_boss_next(game_state: GameState, profile: FloorProfile) -> bool:
	return game_state.navigation_state.rooms_completed_this_floor >= profile.total_rooms()


## --- Door builders ----------------------------------------------------------

# Two standard combat doors with distinct enemy identities (HLD-DOOR-002). When the
# normal pool has only one type, both doors show it (HLD-DOOR-004).
func _combat_doors(room: int, profile: FloorProfile) -> Array:
	var ids := _two_distinct_from(profile.normal_enemy_pool)
	return [
		_make_door(ROOM_COMBAT, ids[0], profile.floor_number, room, 0),
		_make_door(ROOM_COMBAT, ids[1], profile.floor_number, room, 1),
	]


# The Elite Gate (LLD-FLOOR-BEATS-004): one elite-combat door + one standard combat
# door. Always door 0 = elite, door 1 = standard.
func _elite_gate_doors(room: int, profile: FloorProfile) -> Array:
	return [
		_make_door(ROOM_ELITE_COMBAT, _pick_one(profile.elite_enemy_pool), profile.floor_number, room, 0),
		_make_door(ROOM_COMBAT, _pick_one(profile.normal_enemy_pool), profile.floor_number, room, 1),
	]


func _make_door(room_type: String, encounter_id: String, floor_number: int, room: int, door_index: int) -> DoorData:
	var d := DoorData.new()
	d.room_type = room_type
	d.encounter_id = encounter_id
	d.room_id = "f%d_r%d_d%d" % [floor_number, room, door_index]
	return d


## --- Pool selection (NAVIGATION stream) -------------------------------------

# Two enemy ids from the pool: distinct when the pool has ≥2 entries; the same when
# it has exactly one (HLD-DOOR-004); empty strings for an empty pool (defensive).
func _two_distinct_from(pool: Array) -> Array:
	if pool.is_empty():
		return ["", ""]
	if pool.size() == 1:
		return [pool[0], pool[0]]
	var i := _roll(0, pool.size() - 1)
	var j := _roll(0, pool.size() - 2)  # pick from the remaining, then skip past i
	if j >= i:
		j += 1
	return [pool[i], pool[j]]


func _pick_one(pool: Array) -> String:
	if pool.is_empty():
		return ""
	return pool[_roll(0, pool.size() - 1)]


func _roll(a: int, b: int) -> int:
	if _rng == null or b <= a:
		return a
	return _rng.randi_range(STREAM_NAVIGATION, a, b)
