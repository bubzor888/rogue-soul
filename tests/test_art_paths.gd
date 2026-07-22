# @Spec: UI-ART-007, UI-GLOBAL-003, UI-ROOM-002
extends GdUnitTestSuite

func test_status_icon_resolves() -> void:
	assert_str(ArtPaths.status_icon("burning")).is_equal("res://assets/art/icons/status/icon_status_burning.png")

func test_damage_icon_resolves() -> void:
	assert_str(ArtPaths.damage_icon("fire")).is_equal("res://assets/art/icons/dmg/icon_dmg_fire.png")

func test_intent_icon_resolves() -> void:
	assert_str(ArtPaths.intent_icon("heavy_attack")).is_equal("res://assets/art/icons/intent/icon_intent_heavy_attack.png")

# An unmapped intent (no bespoke icon) falls back to the generic attack intent icon.
func test_intent_icon_unknown_falls_back_to_attack() -> void:
	assert_str(ArtPaths.intent_icon("strike")).is_equal("res://assets/art/icons/intent/icon_intent_attack.png")

func test_item_category_icon_resolves() -> void:
	assert_str(ArtPaths.item_icon("weapon")).is_equal("res://assets/art/icons/item/icon_item_weapon.png")

func test_enemy_sprite_resolves() -> void:
	assert_str(ArtPaths.enemy_sprite("plague_rat")).is_equal("res://assets/art/characters/enemies/enemy_plague_rat.png")

func test_vessel_sprite_resolves() -> void:
	assert_str(ArtPaths.vessel_sprite("pilgrim")).is_equal("res://assets/art/characters/vessels/vessel_pilgrim.png")

# UI-ROOM-002: unmapped combat door symbol falls back to the placeholder, no crash.
func test_door_symbol_falls_back_to_placeholder() -> void:
	assert_str(ArtPaths.door_symbol("no_such_enemy")).is_equal(ArtPaths.DOOR_SYMBOL_PLACEHOLDER)

# Colon-encoded status without a per-param icon falls back to the base status icon.
func test_status_icon_colon_param_falls_back_to_base() -> void:
	assert_str(ArtPaths.status_icon("emboldened:physical")).is_equal("res://assets/art/icons/status/icon_status_emboldened.png")
	assert_str(ArtPaths.status_icon("vulnerable:ice")).is_equal("res://assets/art/icons/status/icon_status_vulnerable.png")

# type_convert has per-parameter icons on disk, so the parameter variant is used.
func test_status_icon_type_convert_uses_param_variant() -> void:
	assert_str(ArtPaths.status_icon("type_convert:fire")).is_equal("res://assets/art/icons/status/icon_status_type_convert_fire.png")

func test_damage_type_tint_physical_is_neutral_not_red() -> void:
	# UI-GLOBAL-003: Physical is neutral gray (~#2b333c), never red.
	assert_object(ArtPaths.damage_tint("physical")).is_equal(Color("2b333c"))
	assert_object(ArtPaths.damage_tint("fire")).is_equal(Color("cf3b2e"))
