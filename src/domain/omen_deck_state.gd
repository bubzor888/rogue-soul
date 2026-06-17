# @Spec: LLD-ARCH-017, LLD-ARCH-004
#
# OmenDeckState — the omen draw/discard piles. Each entry is
# { card_id: String, timer_value: int }. Timer values are assigned once at deck
# assembly and preserved across reshuffle (the discard pile keeps them).
class_name OmenDeckState
extends Resource

@export var draw_pile: Array[Dictionary] = []
@export var discard_pile: Array[Dictionary] = []


func to_json() -> Dictionary:
	return {
		"draw_pile": Serde.dicts_dup(draw_pile),
		"discard_pile": Serde.dicts_dup(discard_pile),
	}


static func from_json(data: Dictionary) -> OmenDeckState:
	var d := OmenDeckState.new()
	d.draw_pile.assign(Serde.omen_entries(data.get("draw_pile", [])))
	d.discard_pile.assign(Serde.omen_entries(data.get("discard_pile", [])))
	return d
