## Why

The MVP2 UI implementation (see `ui-combat-and-loot-screens`) depends on sprite assets — damage type icons, status effect icons, intent indicators, enemy/vessel sprites — but no spec exists defining their format, size, or naming conventions. Without this, the asset creation step in `ui-combat-and-loot-screens` task group 1 has no single authoritative reference, and assets created at wrong sizes or inconsistent scales will require rework before they can be used in Godot.

## What Changes

- Introduces a new `ui-art-assets` spec defining the complete MVP2 art asset catalogue: source dimensions, display sizes, file format, scale convention, and file naming
- All sizes are specified for the mobile-first portrait viewport (390×844px design resolution) using 2x integer scaling throughout
- PC compatibility is addressed by design: integer scaling means the same source assets can be displayed at 3× or 4× on PC without producing new source files

## Capabilities

### New Capabilities

- `ui-art-assets`: Defines the MVP2 sprite asset catalogue — source pixel dimensions, 2× integer scale convention, PNG+alpha format requirement, transparent background requirement, and per-category file naming. Covers: damage type icons, status effect icons, intent indicators, normal enemy sprites, elite enemy sprites, vessel sprite, companion sprites, and loot screen placeholder image.

### Modified Capabilities

*(none)*

## Impact

- No code changes — this spec is consumed by the art creation workflow and by Godot resource loading conventions
- Godot asset import settings should match: `Texture2D` import with filter mode **Nearest** (not Linear) to preserve pixel-art sharpness at any scale
- The `DamageTypeBadge`, `StatusChip`, and `EnemyUnit` controls defined in `ui-combat-and-loot-screens` will load assets from paths established by this spec's naming convention
