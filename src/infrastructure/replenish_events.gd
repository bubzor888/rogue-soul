# @Spec: LLD-ARCH-016, LLD-ARCH-011
#
# ReplenishEvents — string constants for the charge-replenishment events fired by
# RunController to ChargeManager (LLD-ARCH-016). Content `.tres` files list these
# raw strings in their `replenish_triggers`; code references the constants to
# avoid typos. Pure constants, no dependencies (Infrastructure layer).
class_name ReplenishEvents
extends RefCounted

## On entering any room with an encounter (combat or non-combat).
const ENCOUNTER_START := "encounter_start"

## On leaving any encounter.
const ENCOUNTER_END := "encounter_end"

## At the beginning of each floor.
const FLOOR_START := "floor_start"

## At floor transition (after boss defeated, before HP restore).
const FLOOR_END := "floor_end"
