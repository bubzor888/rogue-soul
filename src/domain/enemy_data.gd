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

## Damage type IDs this enemy is innately vulnerable to (x1.5). Innate vulnerability
## is an additional source to the item-applied Vulnerable status (HLD-COMBAT-007):
## both produce x1.5, do not double-stack, and cancel with same-type resistance.
@export var vulnerabilities: Array[String] = []

## Tags used by omen card filtering/effects, e.g. ["undead"], ["beast"].
@export var enemy_tags: Array[String] = []

## How many copies of this enemy spawn in a pre-elite / post-elite combat room
## (LLD-ENEMIES-002, authoritative per-enemy counts). Elite-gate and boss encounters
## spawn 1 (elites are solo; the boss composition is handled separately). Defaults 1.
@export var pre_elite_count: int = 1
@export var post_elite_count: int = 1

## Card IDs added to the deck while this enemy is alive, via the two-tier model
## (HLD-OMEN-006): index 0 = family card (per instance), index 1 = type card (once
## per type).
@export var omen_contributions: Array[String] = []

## Card IDs injected verbatim (once per instance) bypassing the two-tier family/type
## model — a fixed contribution unique to an encounter. The Judge uses this for its
## 3 Repent cards (LLD-OMEN-CARD-020). [] = none.
@export var direct_omen_contributions: Array[String] = []

## Other enemy IDs spawned alongside this enemy when it is the encounter primary
## (mixed composition, e.g. The Judge spawns its two Witnesses). One of each, after
## the primary. [] = none.
@export var accompanied_by: Array[String] = []

## When true, this enemy's death ends combat in victory regardless of other living
## enemies — it is the only required kill (the Judge; LLD-ENEMIES-010). Default false
## (every enemy must die to win).
@export var ends_combat_on_death: bool = false

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
