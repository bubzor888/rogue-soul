# @Spec: LLD-ABILITIES-005, LLD-ARCH-019
#
# PeekOmenDeckHandler ("peek_omen_deck") — the Read the Road effect. Sets
# combat_state.read_the_road_active so that get_legal_combat_actions() returns
# only READ_THE_ROAD_COMMIT until the player commits (T5.1/T5.6). No params.
class_name PeekOmenDeckHandler
extends AbilityHandler


func apply(ctx: AbilityContext) -> void:
	if ctx.game_state.combat_state != null:
		ctx.game_state.combat_state.read_the_road_active = true
