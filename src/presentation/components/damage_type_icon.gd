# @Spec: UI-GLOBAL-003
#
# DamageTypeIcon — a TextureRect that renders a damage type as its icon (shape) plus
# its UI-GLOBAL-003 tint (colour), a redundant encoding so type reads without relying
# on colour alone. Physical is neutral gray; red is reserved for Fire.
class_name DamageTypeIcon
extends TextureRect

func set_type(damage_type: String) -> void:
	texture = load(ArtPaths.damage_icon(damage_type))
	self_modulate = ArtPaths.damage_tint(damage_type)
