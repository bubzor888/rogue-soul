# @Spec: LLD-ARCH-004, LLD-ARCH-017
#
# Serde — static JSON (de)serialisation helpers shared by GameState and its
# sub-Resources. Keeps to_json/from_json terse and consistent. Never instantiated.
#
# from_json helpers defensively cast numbers to int: in-memory Dictionary
# round-trips keep ints, but values that have passed through JSON text
# (JSON.parse_string) arrive as floats — casting makes both paths identical.
class_name Serde
extends RefCounted


# A Resource's to_json(), or null if the resource is null.
static func to_json_or_null(r) -> Variant:
	return null if r == null else r.to_json()


# Reconstruct a single sub-resource via its static from_json (a Callable),
# preserving null.
static func obj_from_json(data: Variant, ctor: Callable) -> Variant:
	return null if data == null else ctor.call(data)


# Serialise an array of (possibly null) resources, preserving null slots.
static func res_array_to_json(arr: Array) -> Array:
	var out: Array = []
	for r in arr:
		out.append(null if r == null else r.to_json())
	return out


# Reconstruct an array of (possibly null) resources via a ctor Callable.
# Returns an untyped Array — assign() it into the typed field.
static func res_array_from_json(data: Variant, ctor: Callable) -> Array:
	var out: Array = []
	if data == null:
		return out
	for d in data:
		out.append(null if d == null else ctor.call(d))
	return out


# Deep-duplicate an array of Dictionaries (free-form payloads, trade offers, ...).
static func dicts_dup(arr: Variant) -> Array:
	var out: Array = []
	if arr == null:
		return out
	for d in arr:
		out.append((d as Dictionary).duplicate(true))
	return out


# Normalise an array of omen-deck entries to { card_id: String, timer_value: int }.
static func omen_entries(arr: Variant) -> Array:
	var out: Array = []
	if arr == null:
		return out
	for e in arr:
		var d := e as Dictionary
		out.append({"card_id": str(d.get("card_id", "")), "timer_value": int(d.get("timer_value", 0))})
	return out


static func int_array(arr: Variant) -> Array:
	var out: Array = []
	if arr == null:
		return out
	for x in arr:
		out.append(int(x))
	return out


static func str_array(arr: Variant) -> Array:
	var out: Array = []
	if arr == null:
		return out
	for x in arr:
		out.append(str(x))
	return out


# Copy a Dictionary, casting all values to int (e.g. room-type -> count maps).
static func int_dict(d: Variant) -> Dictionary:
	var out: Dictionary = {}
	if d == null:
		return out
	for k in d:
		out[k] = int((d as Dictionary)[k])
	return out
