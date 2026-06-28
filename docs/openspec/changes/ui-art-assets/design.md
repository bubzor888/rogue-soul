## Context

MVP2 UI controls (`DamageTypeBadge`, `StatusChip`, `EnemyUnit`, etc.) will load sprites from known paths. Without a defined asset catalogue and directory structure, asset paths are ad-hoc and the Godot import pipeline has no consistent settings to enforce. This design doc captures the key decisions so the art creation workflow and Godot setup align from the start.

Tool context: Pixellab (AI pixel art generator) is the planned creation tool. Assets are generated as PNG and imported directly into Godot. Transparent backgrounds may need to be removed/added manually if the generator doesn't support alpha export natively.

## Goals / Non-Goals

**Goals:**
- Define a consistent 2× integer scale for all MVP2 mobile assets
- Define source dimensions for each asset category so Pixellab requests are unambiguous
- Define the Godot directory structure and import setting (Nearest filter) for all sprites
- Ensure the same source assets work for a future PC build at 3× or 4×

**Non-Goals:**
- Final art style direction — Pixellab generations are acceptable as placeholder art for MVP2
- Animation frames — all MVP2 sprites are static; animated sprites are out of scope
- Audio assets — separate concern

## Decisions

### Decision: 2× scale, 390×844 design viewport
The game is designed at 390×844px logical resolution (iPhone 14 baseline) and scaled to other devices by Godot's stretch mode. At this resolution, 2× integer scaling gives source sizes (16px, 32px, 48px) that are large enough to author readable pixel art but small enough to keep file sizes minimal.

**Alternative considered:** 3× scale with a smaller logical viewport (e.g. 320×568). Rejected because 390px is closer to current mainstream phone widths and avoids awkward scaling on modern devices.

### Decision: Nearest-neighbour filter enforced at import
Godot's default import filter is Linear, which blurs pixel art. Setting Nearest at import time is a one-time project-level decision that must be applied to every PNG — easiest enforced by creating a shared `.import` preset or setting the project default. Forgetting this on a single sprite produces visually inconsistent results that are easy to miss until final review.

### Decision: Flat filename convention, deep directory structure
Asset files use descriptive flat names (`icon_dmg_fire.png`, `enemy_plague_rat.png`) rather than generic names (`fire.png`, `rat.png`). This avoids collisions when multiple asset categories are searched in the Godot FileSystem panel and makes path-based loading in `DamageTypeBadge` and `StatusChip` unambiguous.

## Risks / Trade-offs

- **Pixellab alpha export** → If Pixellab doesn't export with transparency, backgrounds must be removed manually (e.g. in Aseprite or an online tool). Low effort per sprite but adds a step to the art workflow.
- **48×48 elite sprites in 26% cell** → At 2× (96px display) an elite sprite slightly exceeds the 100px cell width at 390px viewport. Acceptable for elites since they appear solo or as one of two enemies — no three-elite formations exist per `LLD-ENEMIES-002`. Monitor in Godot layout; may need a small scale-down or cell width exception for elite sprites.
- **Placeholder art in MVP2** → Pixellab generations may vary in style consistency. Acceptable for MVP2 functionality validation; cohesive art is a post-MVP2 concern.

## Open Questions

- **Godot import preset workflow** — set Nearest globally via Project Settings (`rendering/textures/default_filters/use_nearest_mipmap_filter`) or per-asset via `.import` files? Global setting is simpler but may affect non-pixel-art assets added later.
- **Loot image final dimensions** — 200×80 source is a placeholder estimate; revisit once the loot screen is built in Godot and the actual available height is measured.
