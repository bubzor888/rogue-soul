# @Spec: UI-GLOBAL-001
#
# DisplayText — shared formatting for status-keyword grammar. Returns a structured
# segment { "bbcode": String, "icons": Array[String] }: the bbcode string bolds each
# status keyword; `icons` lists the status-icon path for each keyword in order, for the
# view to render inline immediately before the bold word. No tooltip is ever attached
# (UI-GLOBAL-002). Static-only, headless-testable.
class_name DisplayText
extends RefCounted

# verb + bold status keyword preceded by its combat status icon (UI-GLOBAL-001).
static func effect_line(verb: String, keyword: String, status_id: String) -> Dictionary:
	return {"bbcode": "%s [b]%s[/b]" % [verb, keyword], "icons": [ArtPaths.status_icon(status_id)]}

static func plain(text: String) -> Dictionary:
	return {"bbcode": text, "icons": []}
