# @Spec: UI-ART-007, UI-GLOBAL-003, UI-ROOM-002
#
# ArtPaths — the single data-driven table mapping content ids to on-disk asset paths
# and damage types to their UI-GLOBAL-003 tint. It is the ONLY place the UI knows a
# folder layout; view-models/views call these helpers instead of hardcoding paths.
# Static-only (no state); lives in Presentation. No gameplay branch keys off an id —
# unknown ids resolve to a placeholder, never a code path (LLD-ARCH-005).
class_name ArtPaths
extends RefCounted

const _STATUS := "res://assets/art/icons/status/icon_status_%s.png"
const _DMG := "res://assets/art/icons/dmg/icon_dmg_%s.png"
const _INTENT := "res://assets/art/icons/intent/icon_intent_%s.png"
const _ITEM := "res://assets/art/icons/item/icon_item_%s.png"
const _ENEMY := "res://assets/art/characters/enemies/enemy_%s.png"
const _VESSEL := "res://assets/art/characters/vessels/vessel_%s.png"
const _COMPANION := "res://assets/art/characters/companions/companion_%s.png"
const LOOT_PLACEHOLDER := "res://assets/art/ui/loot/loot_reward_placeholder.png"

# UI-ROOM-002: per-enemy combat door symbols are deferred to an art session; until the
# real assets land, every combat door resolves to this placeholder. Populate DOOR_SYMBOLS
# (enemy_id -> path) when the art arrives — a data-only change, no view edit.
const DOOR_SYMBOL_PLACEHOLDER := "res://assets/art/ui/loot/loot_reward_placeholder.png"
const DOOR_SYMBOLS: Dictionary = {}  # e.g. {"plague_rat": "res://assets/art/ui/doors/door_plague_rat.png"}

# UI-GLOBAL-003 tints. Physical is neutral gray so red belongs exclusively to Fire.
const _DMG_TINT := {
	"physical": "2b333c", "fire": "cf3b2e", "lightning": "c9a24a", "ice": "5b86b3",
}

# @Spec: UI-ART-004
# Statuses may be colon-encoded (e.g. "emboldened:physical", "type_convert:fire"); the
# ":" splits status_id from its string_param (same convention CombatResolver uses). Some
# statuses have a per-parameter icon (type_convert_fire); most share one base icon
# (emboldened, vulnerable). Prefer the parameter variant if it exists on disk, else the base.
static func status_icon(status_id: String) -> String:
	if ":" in status_id:
		var parts := status_id.split(":")
		var variant := _STATUS % ("%s_%s" % [parts[0], parts[1]])
		return variant if ResourceLoader.exists(variant) else _STATUS % parts[0]
	return _STATUS % status_id
static func damage_icon(damage_type: String) -> String: return _DMG % damage_type

# Enemy intent ids (e.g. "strike") may not each have a bespoke icon; fall back to the
# generic attack intent icon rather than a broken load for any unmapped intent.
const _INTENT_FALLBACK := "res://assets/art/icons/intent/icon_intent_attack.png"
static func intent_icon(intent_type: String) -> String:
	var p := _INTENT % intent_type
	return p if ResourceLoader.exists(p) else _INTENT_FALLBACK
static func item_icon(category: String) -> String: return _ITEM % category
static func enemy_sprite(enemy_id: String) -> String: return _ENEMY % enemy_id
static func vessel_sprite(vessel_id: String) -> String: return _VESSEL % vessel_id
static func companion_sprite(companion_id: String) -> String: return _COMPANION % companion_id

# @Spec: UI-ROOM-002
static func door_symbol(enemy_id: String) -> String:
	return str(DOOR_SYMBOLS.get(enemy_id, DOOR_SYMBOL_PLACEHOLDER))

# @Spec: UI-GLOBAL-003
static func damage_tint(damage_type: String) -> Color:
	return Color(str(_DMG_TINT.get(damage_type, "2b333c")))
