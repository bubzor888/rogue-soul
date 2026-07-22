# @Spec: UI-COMBAT-003
extends GdUnitTestSuite

# UI-COMBAT-003: show as many icons as fit, then an overflow badge "+N more".
func test_overflow_splits_visible_and_badge() -> void:
	var r := StatusRow.layout(["burning", "poisoned", "chilled", "shocked", "exposed"], 3)
	assert_array(r["visible"]).is_equal(["burning", "poisoned", "chilled"])
	assert_int(r["overflow"]).is_equal(2)

func test_no_overflow_when_within_cap() -> void:
	var r := StatusRow.layout(["burning", "poisoned"], 3)
	assert_array(r["visible"]).is_equal(["burning", "poisoned"])
	assert_int(r["overflow"]).is_equal(0)
