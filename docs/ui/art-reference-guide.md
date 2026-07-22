# Soul Protocol — Art Reference Guide

## Purpose

This document captures reference art direction for Soul Protocol's pixel art style, organized by category. It exists to guide Mark's own art attempts, AI art generation prompts, and Godot-native tooling (backgrounds/scenes) toward a consistent visual target. This is a living reference document, not a final asset spec — categories will be filled in across multiple sessions.

## Overall Style Baseline

✓ **Pixel density**: Classic 16-bit chunky (SNES-era, Octopath Traveler-adjacent) — not high-detail (Dead Cells/Blasphemous), not painterly HD-2D, not chibi.

✓ **Palette/mood**: Dark, desaturated base with vibrant/saturated accent colors used deliberately (lighting, magic, damage, emphasis) rather than uniformly.

---

## Category: Background Art

### Floor 3 (MVP2 focus)

✓ **Setting**: Amorphous purgatory — not a concrete location. Hints of trees, caves, and crypts emerge from fog rather than being fully rendered environments.

✓ **Base treatment**: Dark, desaturated foundation across all variations (cool neutrals — stone grays, faded blues/greens).

✓ **Variation mechanism**: Randomized "hint type" per encounter/room rather than random accent-color rolls. Three hint types, each carrying its own accent naturally:
- **Forest hint** → sickly green / pale gold accents (dead leaves, filtered light)
- **Cave hint** → blue/violet accents (crystal glow, damp stone)
- **Crypt hint** → warm accents (torchlight, candle-orange, dried-blood red)

This keeps Floor 3 visually unified (same base, same fog treatment) while still producing perceptible variety, and ties accent color to *narrative content* (what's dissolving into view) rather than an arbitrary palette swap.

### Reference images pulled
- Momodora gothic pixel backgrounds — flat pixel-art layering, gothic desaturated-with-accent palette (closest structural match)
- Sundered — saturated dark hybrid, useful for accent intensity but noisier than desired
- "Dark Pixel Art Wallpapers" / atmospheric night-scene pixel art — strong match for the dark base + saturated accent combination
- Misty/mystic forest pixel art (Craiyon-generated and stock references) — good match for the fog/silhouette/ambiguity target
- Octopath Traveler — useful for composition/lighting only; its HD-2D painterly backgrounds are NOT the pixel-density target

### [OPEN]
- Exact fog-layering/parallax technique in Godot (not yet discussed)
- Number of variations beyond the three hint types (e.g., do hint types combine, or is it strictly one-per-room?)
- Whether other floors reuse the fog/hint-type system with different base palettes, or use a fully distinct approach

### AI Generation Approach

✓ **Pipeline decision**: Full-scene single-image generation struggled to produce genuine ambiguity (generators tend to resolve fog into a coherent, complete scene). Switched to an **asset-sheet approach**: generate isolated architectural/natural elements on a flat extraction background, then composite sparse pieces onto a dark fog base in Godot — letting empty/foggy space do the "amorphous" work rather than asking the generator to fake it.

✓ **Palette-in-prompt caveat**: AI generators loosely follow palette/mood language in a prompt but don't reliably hit exact hex values — expect drift, off-palette shading, and anti-aliasing the model adds on its own. True consistency comes from a **post-generation palette-snap pass** (color quantization to a fixed defined palette), not from the prompt alone.

#### Prompt: Crypt hint — asset sheet
```
16-bit pixel art asset sheet, SNES-era chunky pixel density.
A collection of separate crypt architectural elements laid out individually, not composed into one scene: a broken stone archway, a cracked tomb slab, a crumbling stone pillar, a pile of loose rubble, a wrought iron gate fragment, a weathered stone wall section.
Each element isolated with clear edges, no overlapping, no background scenery connecting them.
Flat neutral gray background behind each element for easy extraction.
Dark stone palette — muted grays and faded blue-green undertones, with sparse warm red/orange accent details (moss, rust, dried blood streaks) on select pieces only.
Flat pixel art shading, hard edges, no gradients, no anti-aliasing.
```
Result: strong hit — clean isolated pieces, good palette. Locked as the reference approach for the other hint types.

#### Prompt: Forest hint — asset sheet
```
16-bit pixel art asset sheet, SNES-era chunky pixel density.
A collection of separate dead-forest architectural/natural elements laid out individually, not composed into one scene: a skeletal bare tree trunk, a cluster of twisted dead branches, a tangle of exposed roots, a fallen dead log, a patch of withered undergrowth, a cracked hollow stump.
Each element isolated with clear edges, no overlapping, no background scenery connecting them.
Flat neutral gray background behind each element for easy extraction.
Dark, desaturated palette — muted grays and faded blue-green undertones, with sparse sickly pale green and faded gold accent details (dying moss, filtered light) on select pieces only.
Flat pixel art shading, hard edges, no gradients, no anti-aliasing.
```

#### Prompt: Cave hint — asset sheet (v1, rejected)
```
16-bit pixel art asset sheet, SNES-era chunky pixel density.
A collection of separate cave/cavern elements laid out individually, not composed into one scene: a jagged rock outcropping, a cluster of stalactites, a cluster of stalagmites, a cracked cave wall section, a pile of loose stone rubble, a narrow rock archway.
Each element isolated with clear edges, no overlapping, no background scenery connecting them.
Flat neutral gray background behind each element for easy extraction.
Dark, desaturated palette — muted grays and faded blue-green undertones, with sparse cold blue and violet accent details (crystal glow, damp shimmer) on select pieces only.
Flat pixel art shading, hard edges, no gradients, no anti-aliasing.
```
Result: generator defaulted to exterior icy mountain peaks rather than cave interior — "cave" alone wasn't enough disambiguation.

#### Prompt: Cave hint — interior structure (v2, corrected)
```
16-bit pixel art asset sheet, SNES-era chunky pixel density.
A collection of separate UNDERGROUND CAVE INTERIOR structure pieces, viewed from inside the cave, not exterior mountain or landscape shots: a rough cave wall section with natural rock texture, a cave floor section with uneven stone, a narrow rock tunnel opening leading into darkness, a cluster of ceiling stalactites hanging down, a cluster of floor stalagmites, a cracked rock archway/passage, a small underground pool of still water, a cave wall section with embedded glowing crystal cluster.
Each element isolated with clear edges, no overlapping, no other scenery connecting them.
Flat neutral gray background behind each element for easy extraction.
This is the inside of an enclosed underground cavern, not an outdoor mountain, cliff, or peak — emphasize enclosed rock surfaces (walls, ceiling, floor) rather than jagged exterior peaks silhouetted against sky.
Dark, desaturated stone palette — muted grays and deep blue-violet undertones, with sparing vibrant cyan/violet accent glow limited to crystal clusters and damp reflective surfaces.
Flat pixel art shading, hard edges, no gradients, no anti-aliasing.
```
Key fix over v1: explicit "viewed from inside," interior-only piece list, and a direct negative instruction against exterior peaks/cliffs/sky.

### Tier 3 Origin Floor Prompts (early exploration, post-MVP content)

✓ **Vessel-to-environment mapping confirmed**: Paladin = crypt, Battle Wizard = tower, Shaman = plains, Ranger = forest. Note: Ranger's tier 3 forest floor needs to read as visually distinct from Floor 3's amorphous "forest hint" — Ranger's should be fully grounded/resolved, not foggy.

#### Prompt: Battle Wizard tower — props/set dressing (v1)
```
16-bit pixel art asset sheet, SNES-era chunky pixel density.
A collection of separate arcane wizard tower elements laid out individually, not composed into one scene: a spiral stone staircase fragment, a tall arched window with leaded glass, a bookshelf packed with tomes, a glowing arcane rune circle on stone flooring, a cluster of alchemical bottles and vials, a floating/suspended crystal orb, a stone gargoyle statue fragment, a wrought iron candelabra.
Each element isolated with clear edges, no overlapping, no background scenery connecting them.
Flat neutral gray background behind each element for easy extraction.
Dark, desaturated stone/wood palette — muted grays and deep blue-purple undertones, with vibrant saturated accent details: arcane violet/cyan glow (runes, crystals, magic effects) as the primary accent, sparing warm gold on candlelight only.
Flat pixel art shading, hard edges, no gradients, no anti-aliasing.
```
Result: good props/set dressing, but no architectural structure — needed a follow-up prompt for the room shell itself.

#### Prompt: Battle Wizard tower — interior structure (v2)
```
16-bit pixel art asset sheet, SNES-era chunky pixel density.
A collection of separate wizard tower INTERIOR architectural structure pieces laid out individually, not composed into one scene: a curved stone wall section following the tower's circular shape, a stone floor tile section, a wooden ceiling beam/rafter section, a tall narrow interior support column, a stone archway doorway (interior facing), a circular window recess built into a curved wall, a raised stone platform/dais section, a wall section with built-in alcove/niche.
Each element isolated with clear edges, no overlapping, no other scenery connecting them.
Flat neutral gray background behind each element for easy extraction.
Emphasize the curved/circular nature of tower interior walls, distinct from flat rectangular room walls.
Dark, desaturated stone/wood palette — muted grays and deep blue-purple undertones, with sparing vibrant violet/cyan accent glow limited to seams, cracks, or embedded rune lines in the stone itself.
Flat pixel art shading, hard edges, no gradients, no anti-aliasing.
```

#### Prompt: Shaman plains — asset sheet
```
16-bit pixel art asset sheet, SNES-era chunky pixel density.
A collection of separate open-plains elements laid out individually, not composed into one scene: a cluster of tall swaying grass, a weathered wooden fence post, a lone windswept tree, a scattering of wildflowers, a worn dirt path fragment, a cluster of standing stones, a distant rolling hill silhouette, a simple wooden cart wheel.
Each element isolated with clear edges, no overlapping, no background scenery connecting them.
Flat neutral gray background behind each element for easy extraction.
Dark, desaturated palette — muted grays and faded warm brown/tan undertones, with vibrant saturated accent details: earthy gold and warm amber (sunset light, dry grass) as the primary accent, sparing cool teal on sky/distance elements only.
Flat pixel art shading, hard edges, no gradients, no anti-aliasing.
```

#### [OPEN]
- Ranger tier 3 forest floor prompt not yet drafted
- Post-generation extraction/cleanup workflow (background removal, edge cleanup) not yet finalized
- Compositing test (placing pieces onto fog base at varying opacity/depth) not yet run

---

## Category: Vessel / Enemy Sprites

✓ **View conventions** (two distinct perspectives, tied to scene type):
- **Combat screen**: Flat top-down back view — character seen dead-on from behind (back of head, shoulders, pack/cloak, legs), matching classic top-down RPG back-facing sprites (Zelda/Stardew-style convention). This was corrected from an earlier isometric/Hades-style back-angle reference, which was rejected as unnecessarily complex to produce and animate consistently.
- **Memory Fragment / merchant scenes**: Side profile, with more visible facial/front detail than the combat view allows.

✓ **Proportions**: Final Fantasy-style grounded proportions (~2.5–3 heads tall) — explicitly NOT chibi (rejected an oversized-head/tiny-body anime-boy reference sheet). Color blocking (armor/clothing color) does significant work distinguishing vessels at a glance, similar to classic FF class sprite conventions.

### Pilgrim (most-eroded endpoint vessel)

✓ **"Worn down" quality reads via**: Posture + visible damage (combination confirmed):
- Hunched silhouette, uneven/asymmetric posture (shoulders rounded forward, head tilted down) — contrasts with upright/alert reference sprites
- 2–3 visible "gap" patches in robe/cloak — darker or void-toned interior showing through torn fabric, breaking up the silhouette
- Ragged, uneven hem (vs. a clean-cut reference hem)

✓ **View-specific detail**:
- **Combat (back view)**: Damage patches + hunched posture carry the full read; no face needed.
- **Side-profile (Memory Fragment/merchant)**: Hood remains up (maintaining mystery/erosion theme), but face is partially visible — pale/gaunt features or glowing/pale eyes, rather than full facial rendering.

### Reference images pulled
- "Neophyte mage in tattered robes, seen from behind" (Craiyon) — closest match for torn/patched robe silhouette
- "Undead sorcerer, gaunt body wrapped in torn ancient robes" — reference for damage-as-silhouette-gap technique
- "Shadow hooded character, visible eyes" — reference for side-profile hood-up-but-face-partially-visible treatment
- FF-style overworld sprite sheet (user-provided) — locked proportion/color-blocking reference
- Top-down 4-directional sprite sheet, BACK row specifically (user-provided) — locked combat view reference
- Octopath/Chained Echoes/Dragon Quest battle screens — reviewed and rejected as reference; these are side-view battler conventions, not the back-view perspective needed here

### [OPEN]
- Pilgrim's specific color palette (still needs definition against the FF-style color-blocking approach)
- Exact damage patch placement/count finalized against a real sprite mockup
- Hedge Knight and Drifter vessel-specific references (not yet started)

### Prompt: Pilgrim — combat back-view sprite
```
16-bit pixel art character sprite, SNES-era chunky pixel density, Final Fantasy-style grounded proportions (roughly 2.5 to 3 heads tall, not chibi).
Flat top-down back view — character seen directly from behind, facing away from camera: back of hooded head, shoulders, back of robe, legs visible. No face visible in this view.
A worn, eroded pilgrim figure wrapped in a long tattered hooded robe.
Hunched posture — shoulders rounded forward, head tilted slightly down, asymmetric stance suggesting exhaustion rather than an upright, alert pose.
The robe shows visible damage: 2 to 3 torn gap patches breaking up the fabric silhouette, revealing darker interior/shadow beneath rather than skin or bone.
Ragged, uneven hem at the bottom of the robe, frayed rather than clean-cut.
Simple, flat color blocking for the robe (single dominant desaturated tone — muted gray, faded brown, or dull green), minimal detail beyond silhouette and damage patches.
Dark, desaturated color palette overall, no bright or saturated colors on the character itself.
Flat pixel art shading, hard edges, no gradients, no anti-aliasing.
Isolated character on a flat neutral background, standing pose, no scenery.
```

Side-profile variant (Memory Fragment/merchant scenes) not yet drafted — would need hood-up-but-face-partially-visible treatment per the view-specific detail above.

---

## Category: Wandering Soul

No prior design document defines the Wandering Soul's visual appearance (`hld-wandering-soul.md` covers trade mechanics only) — this is original visual design work, not derived from an existing spec.

✓ **Concept**: A soul without a vessel — no body, just a dark purple flame visible where a face would be, wrapped in a well-kept (not tattered/eroded) hooded cloak, befitting its role as a trading merchant rather than an eroded wanderer.

✓ **Framing**: Shoulders-up portrait, front-facing directly toward camera — distinct from both the combat back-view and the side-profile Memory Fragment convention, since this is a dedicated trade-screen portrait.

✓ **Hood/cloak color**: Same solid color across hood and body/shoulders — no color break between hood and torso.

✓ **Flame**: Dark purple with a lighter violet accent core for depth; large enough to fill nearly the entire hood opening. Generated as a static shape for the base portrait — flicker/motion to be handled via separate generated variants (different flame silhouettes) faked as an idle animation in Godot, rather than true frame-by-frame animation.

### Prompt: Wandering Soul — portrait (v1)
```
16-bit pixel art character portrait, SNES-era chunky pixel density, Final Fantasy-style proportions.
Shoulders-up portrait, front-facing directly toward the camera, centered.
A hooded cloaked figure — the cloak is well-kept and intact, not tattered or damaged, befitting a traveling merchant rather than an eroded wanderer.
Where a face should be, instead show a dark purple flame — the flame is the entire visible "face," no eyes, no facial features, just flame filling the hood's shadowed opening.
The flame is a solid, static shape for this pass — no flicker or motion implied, a single clean silhouette of dark purple flame with a slightly lighter purple/violet accent core for depth.
Cloak color: dark, desaturated neutral tone (charcoal, deep brown, or muted slate) consistent with the game's dark base palette, contrasting against the vibrant purple flame.
Flat pixel art shading, hard edges, no gradients, no anti-aliasing.
Isolated portrait on a flat neutral background, no scenery.
```
Result: good first pass, but hood and body read as two different colors, and the flame was too small within the hood.

### Prompt: Wandering Soul — portrait (v2, locked)
```
16-bit pixel art character portrait, SNES-era chunky pixel density, Final Fantasy-style proportions.
Shoulders-up portrait, front-facing directly toward the camera, centered.
A hooded cloaked figure — the cloak is well-kept and intact, not tattered or damaged, befitting a traveling merchant rather than an eroded wanderer.
The hood and the cloak/body are the exact same solid color — no color break between hood and shoulders/torso, reading as one continuous garment.
Where a face should be, instead show a dark purple flame that fills nearly the entire hood opening — the flame should be large, taking up almost all of the visible space inside the hood, leaving only a thin dark edge of hood fabric visible around it.
The flame is a solid, static shape for this pass — no flicker or motion implied, a single clean silhouette of dark purple flame with a slightly lighter purple/violet accent core for depth.
Cloak color: dark, desaturated neutral tone (charcoal, deep brown, or muted slate) consistent with the game's dark base palette, contrasting against the vibrant purple flame.
Flat pixel art shading, hard edges, no gradients, no anti-aliasing.
Isolated portrait on a flat neutral background, no scenery.
```
Result: confirmed good — locked as the base reference portrait.

### [OPEN]
- Flame flicker/idle animation variants not yet generated
- Full-body treatment (if ever needed beyond the portrait) undesigned

---

## Category: Icons / Status Effects

Not yet started.

---

*Document version 2 — reference research and AI generation prompt library, not a final asset spec. Update as additional categories and vessels are covered in future sessions.*

*v1: Initial reference research — Floor 3 background direction, vessel sprite view/proportion conventions, Pilgrim silhouette/damage treatment.*
*v2: Added AI generation pipeline notes (asset-sheet approach, palette-snap caveat) and locked prompts for Floor 3 hint types (crypt, forest, cave — including a rejected cave v1 and corrected v2), tier 3 origin floor exploration (Battle Wizard tower props + structure, Shaman plains), Pilgrim combat sprite, and a new Wandering Soul category (concept, portrait prompt v1 and locked v2).*
