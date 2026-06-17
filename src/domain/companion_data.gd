# @Spec: LLD-ARCH-018, LLD-ARCH-006
#
# CompanionData — schema for a companion (temporary or bound). Defines its omen
# contributions, trigger behaviour, granted ability, and departure rule. Pure
# data Resource (Domain layer).
class_name CompanionData
extends Resource

@export var companion_id: String = ""

@export var display_name: String = ""

## Card IDs added while the companion is active.
@export var omen_contributions: Array[String] = []

## Trigger type ID: "turn_end" | "vessel_death_intercept".
@export var trigger: String = ""

## Executed via AbilityPipeline on trigger.
@export var handlers: Array[HandlerConfig] = []

## ability_id of the active ability granted to the vessel; "" if none.
@export var granted_ability_id: String = ""

## Starting value for CompanionState.companion_timer; 0 = not used.
@export var initial_timer: int = 0

## "ability_used" | "timer_exhausted" | "intercept_triggered" | "after_boss_only".
@export var departure_trigger: String = ""
