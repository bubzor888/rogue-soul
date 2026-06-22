# @Spec: LLD-ARCH-018, LLD-ARCH-006
#
# OmenCardData — schema for an omen card. Pure data Resource (Domain layer).
#
# Colon-encoding convention: a parameterized status_id (e.g. "type_convert:fire",
# "vulnerable:lightning", "emboldened:physical") is split on `:` by CombatResolver
# at StatusInstance creation — left → status_id, right → string_param. Plain ids
# (e.g. "burning") are used as-is with string_param "".
class_name OmenCardData
extends Resource

## Unique identifier; matches the filename convention.
@export var card_id: String = ""

## Player-visible name.
@export var display_name: String = ""

## Status ID applied to each eligible unit when the card fires; "" for cards with
## no status effect (e.g. Stillness). Colon-encoded params split by CombatResolver.
@export var status_id: String = ""

## Magnitude for StatusInstances created from status_id (e.g. Burning 5); 0 default;
## additive for magnitude-additive statuses (HLD-COMBAT-018); ignored otherwise.
@export var status_magnitude: int = 0

## "" = apply to all units on the target side; non-empty = only units whose
## enemy_tags contains this value (e.g. "undead", "beast").
@export var requires_tag: String = ""

## For cards with non-standard effects (e.g. Elemental Synergy, Sacred Ground);
## executed in addition to any status_id application.
@export var handlers: Array[HandlerConfig] = []
