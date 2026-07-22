# @Spec: UI-GLOBAL-001
extends GdUnitTestSuite

# "Apply Poisoned" -> the keyword is bolded and carries its status icon path.
func test_effect_line_bolds_keyword_with_icon() -> void:
	var seg := DisplayText.effect_line("Apply", "Poisoned", "poisoned")
	assert_str(seg["bbcode"]).is_equal("Apply [b]Poisoned[/b]")
	assert_array(seg["icons"]).is_equal([ArtPaths.status_icon("poisoned")])

# UI-LOOT-006: self-target uses "Gain", enemy-target uses "Apply" — the verb is caller-chosen,
# DisplayText just formats whatever verb it is handed.
func test_gain_verb_passthrough() -> void:
	var seg := DisplayText.effect_line("Gain", "Fortified", "fortified")
	assert_str(seg["bbcode"]).is_equal("Gain [b]Fortified[/b]")

func test_no_keyword_produces_plain_text_no_icons() -> void:
	var seg := DisplayText.plain("Drains 1 charge per room")
	assert_str(seg["bbcode"]).is_equal("Drains 1 charge per room")
	assert_array(seg["icons"]).is_empty()
