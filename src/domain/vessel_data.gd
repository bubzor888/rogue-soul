# @Spec: LLD-ARCH-018, LLD-ARCH-006
#
# VesselData — schema for a playable vessel: stats plus references (by id) to its
# abilities, starting items, bound companion, and omen contributions. Pure data
# Resource (Domain layer); referenced content is resolved via the registries.
class_name VesselData
extends Resource

@export var vessel_id: String = ""

@export var display_name: String = ""

@export var max_hp: int = 0

## ability_id of the vessel's default strike ability.
@export var default_strike_id: String = ""

## ability_ids (loaded from AbilityRegistry).
@export var ability_ids: Array[String] = []

## ability_ids of starting items (loaded from ItemRegistry).
@export var starting_item_ids: Array[String] = []

## Empty string if no bound companion.
@export var bound_companion_id: String = ""

## Card IDs contributed to the omen deck every combat.
@export var omen_contributions: Array[String] = []
