# @Spec: LLD-ARCH-009, LLD-ARCH-007
#
# SignalBus — Infrastructure autoload. The global, cross-cutting event bus.
# Domain/Application code emits here; Presentation connects here; neither side
# knows the other exists (LLD-ARCH-009).
#
# Signals ONLY — no logic, no state. Registered as an autoload in project.godot
# (no `class_name`, to avoid colliding with the autoload global).
#
# Dependency note (LLD-ARCH-001): Infrastructure may depend on NOTHING. Several
# payloads are conceptually domain types — RunPhase / SaveType enums, CombatState
# — but typing the signal parameters as those domain classes would make this
# Infrastructure file import the Domain layer, which is forbidden. So enum
# payloads are typed `int` (their underlying type) and CombatState is typed
# `Resource` (its built-in base). The emitting domain code passes the real types;
# the looser declarations here keep the bus dependency-free.
extends Node

## Run / phase lifecycle (emitter: RunController) -----------------------------

# new_phase / old_phase are RunPhase enum values (see GameState, LLD-ARCH-017).
signal phase_changed(new_phase: int, old_phase: int)

# save_type is a SaveType enum value (BACKGROUND / CHECKPOINT — see SaveManager).
signal save_requested(save_type: int)

## Combat lifecycle -----------------------------------------------------------

# combat_state is a CombatState Resource (LLD-ARCH-017). Emitter: RunController.
signal combat_started(combat_state: Resource)

# outcome is "victory" | "defeat". Emitter: RunController.
signal combat_ended(outcome: String)

# Emitter: CombatResolver.
signal turn_started(turn_number: int)

# action / result are serialisable Dictionaries. Emitter: CombatResolver.
signal action_resolved(action: Dictionary, result: Dictionary)

## Combat effects (emitter: CombatResolver) -----------------------------------

signal damage_dealt(source_id: String, target_id: String, amount: int, type: String)

signal status_applied(unit_id: String, status_id: String, ticks: int)

signal status_cleared(unit_id: String, status_id: String)

signal unit_died(unit_id: String)

## Omens (emitter: CombatResolver) --------------------------------------------

signal omen_drawn(cards: Array[String])

# side identifies which face of the card applied (e.g. player vs enemy).
signal omen_applied(card_id: String, side: String)

## Items ----------------------------------------------------------------------

# item_broken: charge exhaustion destroyed the item. Emitter: ActionInjector.
signal item_broken(item_id: String, slot_index: int)

# item_discarded: player deliberately discarded via Repent. Emitter: CombatResolver.
# Distinct from item_broken — see LLD-ARCH-009. Both decrement burden by 1.
signal item_discarded(item_id: String, slot_index: int)

# Emitter: RunController.
signal item_acquired(item_id: String)

## Navigation (emitter: RunController) ----------------------------------------

signal room_entered(room_type: String, encounter_id: String)

signal floor_transitioned(from_floor: int, to_floor: int)
