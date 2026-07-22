# @Spec: UI-COMBAT-003
#
# HPBar — a thin ProgressBar wrapper. set_hp maps current/max onto the bar.
class_name HPBar
extends ProgressBar

func set_hp(current: int, maximum: int) -> void:
	max_value = maxi(maximum, 1)
	value = clampi(current, 0, maxi(maximum, 1))
