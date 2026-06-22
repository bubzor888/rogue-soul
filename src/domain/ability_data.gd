# @Spec: LLD-ARCH-018, LLD-ARCH-006
#
# AbilityData — schema for vessel abilities AND items. Items are abilities with
# `breaks_at_zero: true` (LLD-ARCH-018). Pure data Resource (Domain layer).
#
# Colon-encoding convention: handler params / statuses that carry a parameter use
# a colon (e.g. "type_convert:fire", "vulnerable:lightning", "emboldened:physical").
# CombatResolver splits on `:` at StatusInstance creation — left → status_id,
# right → string_param. Plain ids (e.g. "burning") are used as-is, string_param "".
class_name AbilityData
extends Resource

## Unique identifier; matches the filename convention.
@export var ability_id: String = ""

## Player-visible name.
@export var display_name: String = ""

## "attack" | "support" | "consumable" | "passive".
@export var action_bucket: String = ""

## Max charges; 0 = unlimited (passive, default strike).
@export var max_charges: int = 0

## true for items; false for vessel abilities.
@export var breaks_at_zero: bool = false

## Precomputed item score (LLD-IR-011); 0 for vessel abilities (never traded).
## Authored in the .tres using the LLD-IR formulas; never derived at runtime.
@export var score: int = 0

## Replenishment event IDs (from ReplenishEvents constants).
@export var replenish_triggers: Array[String] = []

## Ordered handler chain; executed left to right.
@export var handlers: Array[HandlerConfig] = []

## Encounter-countdown item (HLD-ITEMS-003): when this (Support durability) item's
## charges reach 0 from the per-encounter decrement, instead of a plain break it
## forces the next room to be `triggered_room_type` and is removed. The Worn Map
## (LLD-ITEMS-004) is the MVP1 instance. Default false = ordinary break behaviour.
@export var is_encounter_countdown: bool = false

## The room type forced when an encounter-countdown item triggers (e.g. "companion"
## for the Worn Map's temporary-companion beat). Empty for non-countdown items.
@export var triggered_room_type: String = ""
