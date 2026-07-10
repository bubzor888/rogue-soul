## ADDED Requirements

### Requirement: [UI-ART-008] Item Identity Icon Assets — Source Dimensions
Item identity icons SHALL be created at 32×32 source (displayed at 64×64 at 2×), matching the display size convention used for damage type and intent icons. These are generic category icons, not unique per-item art: one icon per item category (weapon, support, consumable) plus one for Default Strike (the always-available free attack — see `HLD-COMBAT-011`). They appear as the leading identity icon on loot cards (`UI-LOOT-004`/`-005`/`-006`), Wandering Soul and Memory Fragment trade offer cards (`UI-WS-002`, `UI-MF-002`/`-004`), and rows in the combat action-bucket selection sheet (`UI-COMBAT-009`).

Item identity icons SHALL use a white background with the category abbreviation rendered in colored text, matching the visual convention already established for intent icons (`UI-ART-004`). File naming: `icon_item_<category>.png` (e.g. `icon_item_weapon.png`, `icon_item_support.png`, `icon_item_consumable.png`, `icon_item_default_strike.png`).

#### Scenario: Item identity icon source size is 32×32
- **WHEN** an item identity icon is created
- **THEN** the source PNG is exactly 32×32 pixels

#### Scenario: One icon per category, not per item
- **WHEN** a weapon card, trade offer card, or action-select row is displayed for any weapon
- **THEN** the same `icon_item_weapon.png` is shown regardless of which specific weapon it is; no unique per-item icon is required

#### Scenario: Default Strike has its own icon
- **WHEN** Default Strike is shown in the combat action-select sheet
- **THEN** it uses `icon_item_default_strike.png`, distinct from the weapon category icon, since it is not an inventory item

### Requirement: [UI-ART-009] Wandering Soul Character Sprite — Source Dimensions
The Wandering Soul character sprite SHALL be created at 48×48 source (displayed at 96×96 at 2×), matching the elite enemy / vessel sprite tier defined in `UI-ART-005`. Unlike the sprites in `UI-ART-005`, the Wandering Soul never appears inside a combat encounter — it is shown only on its own room screen (`UI-WS-001`), centered above the trade offer cards alongside its speech bubble. File naming: `wandering_soul.png`.

#### Scenario: Wandering Soul sprite source size is 48×48
- **WHEN** the Wandering Soul character sprite is created
- **THEN** the source PNG is exactly 48×48 pixels, matching the elite/vessel sprite tier

#### Scenario: Wandering Soul sprite is not a combat asset
- **WHEN** the Wandering Soul sprite is placed in the game
- **THEN** it appears only on the Wandering Soul room screen, never as a combat participant sprite

## MODIFIED Requirements

### Requirement: [UI-ART-007] Asset Directory Structure
All art assets SHALL be stored under `res://assets/art/` using the following subdirectory structure:

```
res://assets/art/
  icons/
    dmg/          ← damage type icons
    status/       ← status effect icons
    intent/       ← intent icons
    item/         ← item identity icons (weapon/support/consumable/default strike)
  characters/
    enemies/      ← enemy sprites
    vessels/      ← vessel sprites
    companions/   ← companion sprites
    wandering_soul/ ← Wandering Soul merchant sprite
  ui/
    loot/         ← loot screen images
```

#### Scenario: Asset in correct directory
- **WHEN** a new art asset is added to the project
- **THEN** it is placed in the subdirectory matching its category, not in the project root or a flat assets folder
