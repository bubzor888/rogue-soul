# @Spec: LLD-ARCH-022
#
# LootGenerator — builds the two-item post-combat loot offer for the LOOT_SELECTION
# phase (LLD-ARCH-022). Application layer, RefCounted. It selects one durability and
# one consumable item from the floor's tier-appropriate pools (normal after standard
# combat, elite after elite combat — HLD-COMBAT-012/-013), using the LOOT RNG stream
# only. It does NOT mutate GameState — it returns an Array of item_ids that
# RunController stores in NavigationState.loot_offers.
#
# Dependencies are injected (matching NavigationModel/CombatResolver): the LOOT rng
# and a `content` provider (ContentRegistry-style get_floor_by_number) to resolve
# the current floor's FloorProfile. No autoload/scene-tree access.
class_name LootGenerator
extends RefCounted

## RNGService.Stream.LOOT — held as a const so the generator never touches the
## RNGService autoload global directly (matches NavigationModel's STREAM_NAVIGATION).
const STREAM_LOOT := 2

var _rng
var _content


func _init(rng = null, content = null) -> void:
	_rng = rng
	_content = content


# Two item_ids — one durability, one consumable — from the tier's pools. `elite`
# selects the elite pools (LLD-ITEMS-006/-008) over the normal pools
# (LLD-ITEMS-005/-007). Empty-pool fallbacks: if one pool is empty both draws come
# from the other (distinct when it has ≥2 items); if both are empty returns [].
# @Spec: LLD-ARCH-022, HLD-COMBAT-012, HLD-COMBAT-013, LLD-ARCH-008
func generate_loot_offers(game_state: GameState, elite: bool) -> Array:
	var profile: FloorProfile = null
	if _content != null:
		profile = _content.get_floor_by_number(game_state.floor_number)
	if profile == null:
		return []

	var durability := profile.elite_durability_pool if elite else profile.normal_durability_pool
	var consumable := profile.elite_consumable_pool if elite else profile.normal_consumable_pool
	return _build_offers(durability, consumable)


# One durability + one consumable; fall back to a single non-empty pool, or [] when
# both are empty.
func _build_offers(durability: Array, consumable: Array) -> Array:
	var dur_empty := durability.is_empty()
	var con_empty := consumable.is_empty()
	if dur_empty and con_empty:
		return []
	if dur_empty:
		return _two_distinct_from(consumable)
	if con_empty:
		return _two_distinct_from(durability)
	return [_pick_one(durability), _pick_one(consumable)]


# Two ids from a single pool: distinct when the pool has ≥2 entries, the same when
# it has exactly one (mirrors NavigationModel's distinct-pick; no retry loop).
func _two_distinct_from(pool: Array) -> Array:
	if pool.size() == 1:
		return [pool[0], pool[0]]
	var i := _roll(0, pool.size() - 1)
	var j := _roll(0, pool.size() - 2)
	if j >= i:
		j += 1
	return [pool[i], pool[j]]


func _pick_one(pool: Array) -> String:
	return pool[_roll(0, pool.size() - 1)]


func _roll(a: int, b: int) -> int:
	if _rng == null or b <= a:
		return a
	return _rng.randi_range(STREAM_LOOT, a, b)
