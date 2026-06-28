## Purpose
Defines the complete MVP2 sprite art asset catalogue: source dimensions, scale convention, file format, transparency requirements, naming conventions, and Godot import settings. This spec is the single authoritative reference for anyone creating or importing art assets for the UI.

## Requirements

## ADDED Requirements

### Requirement: [UI-ART-001] Format and Transparency
All sprite assets SHALL be delivered as PNG files with a transparent (alpha) background. JPEG and other lossy formats SHALL NOT be used for sprites. The transparent background is required for Godot to composite sprites correctly over game backgrounds.

#### Scenario: Sprite has transparent background
- **WHEN** a sprite asset is imported into Godot
- **THEN** pixels outside the sprite silhouette are fully transparent (alpha = 0), not filled with white, black, or any colour

#### Scenario: No JPEG sprites
- **WHEN** a new sprite asset is added to the project
- **THEN** the file is a .png, not a .jpg or .jpeg

### Requirement: [UI-ART-002] Integer Scale Convention
All sprite assets SHALL be designed at a source size and displayed at exactly 2× that size in the MVP2 mobile viewport (390×844px design resolution). This 2× integer scaling SHALL be applied consistently across all asset categories — mixing scale factors within one build is not permitted.

PC builds MAY display the same source assets at 3× or 4× integer scale without producing new source files; pixel art scales cleanly to any integer multiple.

#### Scenario: 2× display on mobile
- **WHEN** a sprite asset is placed in the MVP2 mobile viewport
- **THEN** it is rendered at exactly twice its source pixel dimensions (e.g. a 32×32 source displays at 64×64)

#### Scenario: Same sources used on PC
- **WHEN** the game is built for PC
- **THEN** the same PNG source files are used, scaled to a higher integer multiple (3× or 4×), with no new source art required

### Requirement: [UI-ART-003] Godot Import Settings
All sprite assets SHALL be imported in Godot with filter mode set to **Nearest** (not Linear or any other interpolation). Linear interpolation blurs pixel boundaries and destroys the pixel-art aesthetic at any scale.

#### Scenario: Nearest-neighbour filtering applied
- **WHEN** a PNG sprite is imported into Godot
- **THEN** its `Texture2D` import preset uses filter mode Nearest, not Linear

### Requirement: [UI-ART-004] UI Icon Assets — Source Dimensions
UI icon source sizes vary by category based on display context and minimum tool constraints:

- **Damage type icons** — 32×32 source (displayed at 64×64 at 2×). One per damage type (Physical, Fire, Lightning, Ice). Silhouettes must be distinct without colour per `UI-GLOBAL-003`. File naming: `icon_dmg_physical.png`, `icon_dmg_fire.png`, `icon_dmg_lightning.png`, `icon_dmg_ice.png`.
- **Status effect icons** — 16×16 source (displayed at 32×32 at 2×). One per status used in MVP2 encounters (at minimum: Burning, Poisoned, Chilled, Shocked, Vulnerable, Hardened, Fortified, Mending, Emboldened). Must be small enough to display 3–4 icons in a row within a 100px enemy cell. File naming: `icon_status_<status_id>.png` (e.g. `icon_status_burning.png`).
- **Intent icons** — 32×32 source (displayed at 64×64 at 2×). One per enemy intent type used in MVP2 (at minimum: attack, heavy attack, multi-hit, defend, charge, status). File naming: `icon_intent_<type>.png` (e.g. `icon_intent_attack.png`).

#### Scenario: Status icon source size is 16×16
- **WHEN** a status effect icon is created
- **THEN** the source PNG is exactly 16×16 pixels

#### Scenario: Damage type and intent icon source size is 32×32
- **WHEN** a damage type or intent icon is created
- **THEN** the source PNG is exactly 32×32 pixels

#### Scenario: Damage type icons are silhouette-distinct
- **WHEN** the four damage type icons are displayed without colour
- **THEN** each icon's silhouette is unambiguously different from the other three (per `UI-GLOBAL-003`)

### Requirement: [UI-ART-005] Character Sprite Assets — Source Dimensions
Character sprites SHALL be created at the following source dimensions:

| Asset category | Source size | Displayed at (2×) |
|---|---|---|
| Normal enemy sprites | 32×32 px | 64×64 px |
| Elite enemy sprites | 48×48 px | 96×96 px |
| Vessel sprite (Pilgrim, MVP2) | 48×48 px | 96×96 px |
| Companion sprites | 32×32 px | 64×64 px |

File naming: `enemy_<enemy_id>.png`, `vessel_<vessel_id>.png`, `companion_<companion_id>.png` (e.g. `enemy_plague_rat.png`, `vessel_pilgrim.png`).

#### Scenario: Normal enemy fits in 26% cell
- **WHEN** a normal enemy sprite (32×32 source, 64×64 displayed) is placed inside a 26% enemy cell (~100px wide in a 390px viewport)
- **THEN** the sprite fits within the cell with room for the HP bar and status row below it

#### Scenario: Elite sprite is visually larger than normal
- **WHEN** an elite enemy sprite (48×48 source, 96×96 displayed) is placed alongside a normal enemy sprite
- **THEN** the elite appears noticeably larger, signalling increased threat

### Requirement: [UI-ART-006] Loot Screen Placeholder Image
A single shared loot screen image SHALL be created for MVP2. This image is category-agnostic (see `UI-LOOT-003`) and serves as a placeholder until final art is produced. Source size SHALL be 200×80px (displayed at 400×160px at 2×), spanning approximately the full content width above the offer cards. File naming: `loot_reward_placeholder.png`.

#### Scenario: Loot image spans full content width
- **WHEN** the loot screen image is placed in the loot screen layout
- **THEN** it spans the full content width (approximately 390px) and is height-capped to remain a supporting visual, not the dominant element

### Requirement: [UI-ART-007] Asset Directory Structure
All art assets SHALL be stored under `res://assets/art/` using the following subdirectory structure:

```
res://assets/art/
  icons/
    dmg/          ← damage type icons
    status/       ← status effect icons
    intent/       ← intent icons
  characters/
    enemies/      ← enemy sprites
    vessels/      ← vessel sprites
    companions/   ← companion sprites
  ui/
    loot/         ← loot screen images
```

#### Scenario: Asset in correct directory
- **WHEN** a new art asset is added to the project
- **THEN** it is placed in the subdirectory matching its category, not in the project root or a flat assets folder
