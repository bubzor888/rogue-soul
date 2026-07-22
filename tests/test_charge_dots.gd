# @Spec: UI-COMBAT-009, UI-LOOT-004
extends GdUnitTestSuite

# UI-COMBAT-009: spent charges are a bare red X, placed BEFORE remaining dots (left=used).
func test_spent_before_remaining() -> void:
	var marks := ChargeDots.marks(1, 3)  # remaining=1, max=3 -> 2 spent, 1 remaining
	assert_array(marks).is_equal(["spent", "spent", "dot"])

func test_full_is_all_dots() -> void:
	assert_array(ChargeDots.marks(3, 3)).is_equal(["dot", "dot", "dot"])

func test_unlimited_is_empty_marks() -> void:
	assert_array(ChargeDots.marks(-1, -1)).is_empty()  # unlimited sentinel -> caller renders the word
