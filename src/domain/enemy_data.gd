# @Spec: LLD-ARCH-018, LLD-ARCH-006
#
# EnemyData — schema for an enemy archetype. Combines stats, omen contributions,
# and the intent engine inputs (weighted pool + conditionals) plus on-death
# consequences. Pure data Resource (Domain layer).
class_name EnemyData
extends Resource

@export var enemy_id: String = ""

@export var display_name: String = ""

@export var max_hp: int = 0

## Damage type ID shared by all damage intents of this enemy.
@export var damage_type: String = ""

## Damage type IDs this enemy resists (x0.5).
@export var resistances: Array[String] = []

## Tags used by omen card filtering/effects, e.g. ["undead"], ["beast"].
@export var enemy_tags: Array[String] = []

## Card IDs added to the deck while this enemy is alive.
@export var omen_contributions: Array[String] = []

## Weighted random intent pool (evaluated if no conditional matches, or restricted
## by a matching conditional's intent_ids).
@export var intent_weights: Array[IntentWeight] = []

## Conditionals evaluated first; first match short-circuits the roll.
@export var intent_conditionals: Array[IntentConditional] = []

## Enemy IDs to spawn via resolve_enemy_summon when this enemy dies (each starts
## fresh with turns_alive: 1). [] = no on-death spawn.
@export var on_death_summons: Array[String] = []

## Colon-encoded status applied to the player when this enemy dies; "" = none.
## remaining_ticks is set to the omen cycle's remaining ticks at death.
@export var on_death_apply_to_player: String = ""

## Magnitude for the on_death_apply_to_player status; stacking per HLD-COMBAT-018.
@export var on_death_apply_magnitude: int = 0
