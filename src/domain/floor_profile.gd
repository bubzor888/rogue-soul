# @Spec: HLD-RUN-005, LLD-FLOOR-STRUCT-006
#
# FloorProfile — data-driven floor composition (HLD-RUN-005). A content Resource
# (Domain layer, like AbilityData/EnemyData) loaded from `data/floors/*.tres` by
# ContentRegistry and read by NavigationModel/LootGenerator. Room ratios, mandatory
# placements (Elite Gate, boss), and the enemy/loot pools live here so a new floor
# is a new `.tres` — no NavigationModel code change (HLD-RUN-005).
#
# The fixed nine-room layout (LLD-FLOOR-STRUCT-006) is expressed as the segment
# sizes: `pre_elite_rooms` rooms, then the Elite Gate (1 room), then
# `post_elite_rooms` rooms, then the boss. Floor 3 is 4 / Elite Gate / 4 / Judge.
#
# Like other content schemas this is loaded from `.tres` and never serialised into
# a save (it is re-resolved by id), so it has no to_json/from_json.
class_name FloorProfile
extends Resource

## Unique content id (the index key, e.g. "floor_3").
@export var floor_id: String = ""

## The floor number this profile applies to (NavigationModel resolves by number).
@export var floor_number: int = 0

## Rooms before the Elite Gate (LLD-FLOOR-STRUCT-006: 4 for Floor 3).
@export var pre_elite_rooms: int = 0

## Rooms after the Elite Gate, before the boss (LLD-FLOOR-STRUCT-006: 4 for Floor 3).
@export var post_elite_rooms: int = 0

## The final encounter of the floor (LLD-FLOOR-BEATS-005: "the_judge" for Floor 3).
@export var boss_enemy_id: String = ""

## enemy_ids for standard combat doors (the normal enemy pool, LLD-ENEMIES-003).
@export var normal_enemy_pool: Array[String] = []

## enemy_ids for the Elite Gate's elite door (the elite pool, LLD-FLOOR-ELITE-001).
@export var elite_enemy_pool: Array[String] = []


# Total navigable rooms before the boss: pre-elite + the Elite Gate + post-elite
# (LLD-FLOOR-STRUCT-006). @Spec: LLD-FLOOR-STRUCT-001, LLD-FLOOR-STRUCT-006
func total_rooms() -> int:
	return pre_elite_rooms + 1 + post_elite_rooms


# The 1-based room number of the Elite Gate (LLD-FLOOR-BEATS-004: room 5 on Floor 3).
# @Spec: LLD-FLOOR-BEATS-004
func elite_gate_room() -> int:
	return pre_elite_rooms + 1
