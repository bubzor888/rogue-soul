# @Spec: LLD-ARCH-008
#
# RNGService — Infrastructure autoload. The single source of randomness for a
# run. All randomness flows through named streams here; `randf()`/`randi()` are
# NEVER called directly anywhere else in the codebase (LLD-ARCH-008).
#
# Registered as an autoload in project.godot (no `class_name`, to avoid colliding
# with the autoload global). Consumers that need dependency injection (e.g.
# CombatResolver, LLD-ARCH-019) `preload` this script for typing and are handed
# the singleton or a fresh instance.
#
# Determinism: each stream is its own RandomNumberGenerator seeded
# `base_seed + stream_index`. A single base seed therefore fully determines a
# run, and adding a roll on one stream never shifts another stream's sequence.
extends Node

## The named streams. The enum value IS the stream index used in the derived
## seed formula `base_seed + index`, so order is significant and stable.
enum Stream {
	NAVIGATION = 0,  # Room sequence generation
	COMBAT = 1,      # Hit rolls, damage variance, enemy intent selection
	LOOT = 2,        # Item drops, loot table rolls
	EVENTS = 3,      # Non-combat event outcomes, Memory Fragment content
}

# The base seed of the current run. Readable so it can be recorded (LLD-ARCH-008
# seed I/O) without exposing the per-stream generators.
var base_seed: int = 0

# One RandomNumberGenerator per Stream, indexed by the enum value.
var _streams: Array[RandomNumberGenerator] = []

# Per-stream roll counter — supports the debug RNG stream monitor (LLD-ARCH-014)
# and makes cross-stream contamination diagnosable.
var _call_counts: PackedInt32Array = PackedInt32Array()


func _init() -> void:
	# Build the generators up front so the service is always usable; seed_run()
	# (or the default seed 0 here) makes every stream deterministic from creation.
	_streams.resize(Stream.size())
	_call_counts.resize(Stream.size())
	for i in Stream.size():
		_streams[i] = RandomNumberGenerator.new()
	_apply_seed(0)


# Seed (or re-seed) every stream from a single base seed. Call at run start to
# reproduce a prior run. @Spec: LLD-ARCH-008
func seed_run(p_base_seed: int) -> void:
	base_seed = p_base_seed
	_apply_seed(p_base_seed)


# Derived-seed formula: stream `i` is seeded `base_seed + i`. Resets each
# generator's state and the call counters. @Spec: LLD-ARCH-008
func _apply_seed(p_base_seed: int) -> void:
	for i in _streams.size():
		_streams[i].seed = p_base_seed + i
		_call_counts[i] = 0


# Primary API: a float in [0, 1) from the given stream. @Spec: LLD-ARCH-008
func roll(stream: Stream) -> float:
	_call_counts[stream] += 1
	return _streams[stream].randf()


# A float in [from, to] from the given stream. @Spec: LLD-ARCH-008
func roll_range(stream: Stream, from: float, to: float) -> float:
	_call_counts[stream] += 1
	return _streams[stream].randf_range(from, to)


# An int in [from, to] (inclusive) from the given stream. @Spec: LLD-ARCH-008
func randi_range(stream: Stream, from: int, to: int) -> int:
	_call_counts[stream] += 1
	return _streams[stream].randi_range(from, to)


# Number of rolls drawn from a stream since the last seed_run — for the debug
# monitor (LLD-ARCH-014). @Spec: LLD-ARCH-008
func get_call_count(stream: Stream) -> int:
	return _call_counts[stream]
