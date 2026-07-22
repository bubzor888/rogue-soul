# @Spec: UI-COMBAT-003, UI-GLOBAL-002
#
# StatusRow — an HBox of status icons with an overflow "+N more" badge. The layout
# split (which ids are visible vs counted as overflow) is a tested static so the
# rule is headless-verifiable; render() is the thin node builder (manual-verified).
# No tooltips are attached (UI-GLOBAL-002).
class_name StatusRow
extends HBoxContainer

const MAX_VISIBLE_DEFAULT := 4

# Split status ids into the visible prefix and an overflow count for the "+N more" badge.
static func layout(status_ids: Array, max_visible: int) -> Dictionary:
	if status_ids.size() <= max_visible:
		return {"visible": status_ids.duplicate(), "overflow": 0}
	return {"visible": status_ids.slice(0, max_visible), "overflow": status_ids.size() - max_visible}

# Clears children, adds a TextureRect per visible id, appends a "+N more" Label on overflow.
func render(status_ids: Array, max_visible: int = MAX_VISIBLE_DEFAULT) -> void:
	for c in get_children():
		c.queue_free()
	var result := layout(status_ids, max_visible)
	for sid in result["visible"]:
		var icon := TextureRect.new()
		icon.texture = load(ArtPaths.status_icon(str(sid)))
		icon.custom_minimum_size = Vector2(20, 20)
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE  # no tooltip (UI-GLOBAL-002)
		add_child(icon)
	if int(result["overflow"]) > 0:
		var badge := Label.new()
		badge.text = "+%d more" % int(result["overflow"])
		add_child(badge)
