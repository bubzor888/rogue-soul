## Why

MVP2 requires a full UI on desktop/mobile for the combat and loot screens — the two most player-facing screens in a run. This change formalises the wireframe decisions already made into spec requirements, and also corrects a binary→ternary loot-choice drift in `HLD-COMBAT-012` that the current git spec has not yet formalised.

## What Changes

- Introduces three new `ui-` specs covering the combat screen, loot/reward screen, and shared UI conventions (status icons, damage type encoding, visual grammar)
- Updates `hld-combat-system` to reflect that loot is a ternary choice (take durability / take consumable / decline both), replacing the current binary framing in HLD-COMBAT-012 and HLD-COMBAT-013

## Capabilities

### New Capabilities

- `ui-combat-screen`: Enemy formation layouts (1/2/3-enemy), per-unit info stacks (intent/sprite/HP/status), vessel and companion layout, top bar (omen countdown + menu placeholder), and action bar geometry (Action circle + Support/Consumable rectangles, End Turn relabel)
- `ui-loot-screen`: Three-zone portrait layout (inventory count strip / loot image / stacked cards + decline bar), bespoke card layouts for durability-weapon / consumable / support-durability item types, asymmetric commit model (tap-to-take vs. tap-then-confirm decline)
- `ui-global-conventions`: Shared UI vocabulary — inline status icon + bold keyword grammar, damage type encoding (glyph shape + tint), unexplained-symbol philosophy, and portrait layout constraints

### Modified Capabilities

- `hld-combat-system`: HLD-COMBAT-012 and HLD-COMBAT-013 change from binary (take one of two) to ternary (take one, or decline both). "Decline both" is a deliberate strategic option because the floor boss scales with player item count — walking away is sometimes correct, not merely an opt-out.

## Impact

- New Godot scenes/controls: `CombatScreen`, `LootScreen`, and shared UI primitives (status chip, damage type badge, action bar)
- No changes to game engine logic — these specs constrain presentation and interaction only
- The HLD-COMBAT-012 ternary change requires a corresponding update to any loot-delivery code that assumes the player always takes an item
