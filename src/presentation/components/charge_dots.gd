# @Spec: UI-COMBAT-009, UI-LOOT-004
#
# ChargeDots — an HBox showing an item/ability's remaining charges left→right in
# depletion order: spent charges (bare red "X") first, remaining ("dot") after, so
# the leftmost marks read as "already used". marks() is the tested static rule;
# render() is the thin node builder (manual-verified).
class_name ChargeDots
extends HBoxContainer

const UNLIMITED := -1

# Marks left→right in depletion order: spent ("X") first, remaining ("dot") after.
static func marks(remaining: int, max_charges: int) -> Array:
	if remaining == UNLIMITED or max_charges == UNLIMITED:
		return []
	var out: Array = []
	for i in (max_charges - remaining):
		out.append("spent")
	for i in remaining:
		out.append("dot")
	return out

func render(remaining: int, max_charges: int) -> void:
	for c in get_children():
		c.queue_free()
	for m in marks(remaining, max_charges):
		if m == "spent":
			var x := Label.new()
			x.text = "X"
			x.modulate = Color("cf3b2e")  # bare red X (UI-COMBAT-009)
			add_child(x)
		else:
			var dot := ColorRect.new()
			dot.custom_minimum_size = Vector2(8, 8)
			dot.color = Color.WHITE
			add_child(dot)
