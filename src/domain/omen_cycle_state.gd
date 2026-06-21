# @Spec: LLD-ARCH-017, LLD-ARCH-004
#
# OmenCycleState — the three drawn cards for the current omen cycle and how their
# sides are being assigned (player choice / random / timer card).
class_name OmenCycleState
extends Resource

## Exactly 3 entries, same { card_id, timer_value } format as the deck.
@export var drawn_cards: Array[Dictionary] = []

## -1 = not yet chosen.
@export var player_choice_index: int = -1

## -1 = not yet assigned.
@export var random_assignment_index: int = -1

## Index into drawn_cards for the timer card; -1 = not yet assigned.
@export var timer_index: int = -1

@export var sides_assigned: bool = false

## Turns remaining in this cycle before the next draw — set to the timer card's
## value when sides are assigned (resolve_choose_omen) and decremented once per omen
## tick. At 0 the cycle expires and resolve_omen_cycle_start draws the next cycle.
## This is the precise mid-cycle countdown the T5.5 note deferred to orchestration.
@export var ticks_remaining: int = 0


func to_json() -> Dictionary:
	return {
		"drawn_cards": Serde.dicts_dup(drawn_cards),
		"player_choice_index": player_choice_index,
		"random_assignment_index": random_assignment_index,
		"timer_index": timer_index,
		"sides_assigned": sides_assigned,
		"ticks_remaining": ticks_remaining,
	}


static func from_json(data: Dictionary) -> OmenCycleState:
	var c := OmenCycleState.new()
	c.drawn_cards.assign(Serde.omen_entries(data.get("drawn_cards", [])))
	c.player_choice_index = int(data.get("player_choice_index", -1))
	c.random_assignment_index = int(data.get("random_assignment_index", -1))
	c.timer_index = int(data.get("timer_index", -1))
	c.sides_assigned = bool(data.get("sides_assigned", false))
	c.ticks_remaining = int(data.get("ticks_remaining", 0))
	return c
