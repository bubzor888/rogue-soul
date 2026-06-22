# @Spec: LLD-ARCH-005
#
# AbilityContext — the shared, mutable context threaded through a handler chain
# (Chain of Responsibility). Handlers read and mutate it left-to-right. Domain
# layer: holds GameState and plain values only, no Node/autoload references.
class_name AbilityContext
extends RefCounted

## The state being mutated by the chain.
var game_state: GameState = null

## Acting unit's id (vessel or enemy instance_id); "" if not applicable.
var source_id: String = ""

## Target unit's id; "" if not applicable.
var target_id: String = ""

## Parameters of the handler currently executing (set per HandlerConfig by the
## pipeline before each handler runs).
var params: Dictionary = {}

## Effects recorded by handlers (e.g. damage dealt) for the resolver to act on /
## emit. Each entry is a plain Dictionary.
var results: Array = []

## Injected dependencies for handlers that need them (set by CombatResolver when it
## builds the context). `content` is the ContentRegistry-style provider
## (get_enemy/get_ability/…); `rng` is the RNGService instance. Both may be null
## for handlers that don't need them.
var content = null
var rng = null


func _init(p_game_state: GameState = null, p_source_id: String = "", p_target_id: String = "") -> void:
	game_state = p_game_state
	source_id = p_source_id
	target_id = p_target_id
