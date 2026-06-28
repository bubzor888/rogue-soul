## 1. Godot Project Setup

- [ ] 1.1 Create asset directory structure under `res://assets/art/` (icons/dmg, icons/status, icons/intent, characters/enemies, characters/vessels, characters/companions, ui/loot) — implements `UI-ART-007`
- [ ] 1.2 Set Godot texture filter default to Nearest (Project Settings → Rendering → Textures → Default Filters, or apply per-asset import preset) — implements `UI-ART-003`

## 2. Damage Type Icons (32×32 source)

- [ ] 2.1 Generate `icon_dmg_physical.png` at 32×32 — diamond / solid geometry silhouette, gray tint (~#2b333c on #f0f1f3) — implements `UI-ART-004`, `UI-GLOBAL-003`
- [ ] 2.2 Generate `icon_dmg_fire.png` at 32×32 — triangle / flame silhouette, red tint (~#cf3b2e on #fceceb)
- [ ] 2.3 Generate `icon_dmg_lightning.png` at 32×32 — spark / bolt silhouette, gold tint (~#c9a24a on #fbf7e8)
- [ ] 2.4 Generate `icon_dmg_ice.png` at 32×32 — snowflake / crystal silhouette, blue tint (~#5b86b3 on #eef3f9)
- [ ] 2.5 Verify all four have transparent backgrounds and are silhouette-distinct without colour — implements `UI-ART-001`, `UI-GLOBAL-003`
- [ ] 2.6 Import all four into `res://assets/art/icons/dmg/` with Nearest filter confirmed

## 3. Status Effect Icons (16×16 source)

- [ ] 3.1 Create status icons at 16×16 for all MVP2 statuses: Burning, Poisoned, Chilled, Shocked, Vulnerable, Hardened, Fortified, Mending, Emboldened — file naming `icon_status_<id>.png` — implements `UI-ART-004`
- [ ] 3.2 Verify transparent backgrounds and that 3–4 icons fit side-by-side in a ~100px enemy cell at 2× display — implements `UI-ART-001`, `UI-ART-004`
- [ ] 3.3 Import all into `res://assets/art/icons/status/` with Nearest filter confirmed

## 4. Intent Icons (32×32 source)

- [ ] 4.1 Generate intent icons at 32×32 for all MVP2 intent types: attack, heavy attack, multi-hit, defend, charge, status-apply — file naming `icon_intent_<type>.png` — implements `UI-ART-004`
- [ ] 4.2 Verify transparent backgrounds — implements `UI-ART-001`
- [ ] 4.3 Import all into `res://assets/art/icons/intent/` with Nearest filter confirmed

## 5. Enemy Sprites

- [ ] 5.1 Generate or draw normal enemy sprites at 32×32 source for all Floor 3 normal enemies (Plague Rat, Wolf, etc.) — file naming `enemy_<id>.png` — implements `UI-ART-005`
- [ ] 5.2 Generate or draw elite enemy sprites at 48×48 source (Bear, Lightning Elemental) — implements `UI-ART-005`
- [ ] 5.3 Verify transparent backgrounds on all enemy sprites — implements `UI-ART-001`
- [ ] 5.4 Import all into `res://assets/art/characters/enemies/` with Nearest filter confirmed
- [ ] 5.5 Verify 48×48 elite sprites display acceptably within the combat screen layout (may slightly exceed 26% cell — monitor in Godot) — implements `UI-ART-005`

## 6. Vessel and Companion Sprites

- [ ] 6.1 Generate or draw Pilgrim vessel sprite at 48×48 source — file naming `vessel_pilgrim.png` — implements `UI-ART-005`
- [ ] 6.2 Generate or draw companion sprite(s) at 32×32 source for any MVP2 companions — file naming `companion_<id>.png` — implements `UI-ART-005`
- [ ] 6.3 Verify transparent backgrounds — implements `UI-ART-001`
- [ ] 6.4 Import into `res://assets/art/characters/vessels/` and `companions/` with Nearest filter confirmed

## 7. Loot Screen Placeholder Image

- [ ] 7.1 Generate or draw loot reward placeholder image at 200×80 source — file naming `loot_reward_placeholder.png` — implements `UI-ART-006`
- [ ] 7.2 Import into `res://assets/art/ui/loot/` with Nearest filter confirmed
- [ ] 7.3 Verify image spans full content width and remains height-capped in the loot screen layout — implements `UI-LOOT-003`
