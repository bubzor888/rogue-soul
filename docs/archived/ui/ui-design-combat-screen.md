## Soul Protocol — UI Design: Combat Screen
### v0.1 · June 2026 · Solo Developer

> **Purpose:** This document records UI/wireframe decisions for the Floor 3
> combat screen — formation layout, per-unit information stacking, and
> the action bar — reached during a mobile wireframing session. This is a
> pre-OpenSpec design document: decisions are recorded as rationale, not
> as formal Requirement/Scenario blocks. Conversion to a formal spec is a
> separate step.
>
> Confirmed decisions are marked **`✓`**. Open items are marked **`[OPEN]`**.
> Working HTML wireframes exist alongside this doc, one per enemy count:
> `combat-wireframe-1enemy.html`, `combat-wireframe-2enemy.html`,
> `combat-wireframe-3enemy.html` (plus corresponding `.png` screenshots).

---

## 1. Scope

This pass covers only the **3-enemy formation, default turn state** for
Floor 3 combat. Per `LLD-ENEMIES-002`, 3 simultaneous enemies is the current
ceiling on Floor 3 (Plague Rats = 3, Wolves cap at 3 post-elite, Bear and
Lightning Elemental are solo). A 4-enemy layout was explicitly **not**
designed — see Open Items.

---

## 2. Enemy Formation

> **✓ Decision:** Enemies arrange by count using fixed patterns: 1 =
> centered; 2 = side-by-side, roughly 1/3 in from each edge; 3 = triangle
> (one back-centered, two front side-by-side). The triangle's back unit
> is positioned higher and slightly smaller than the front pair to read
> as "further away."

### Per-enemy info stack (top to bottom)

> **✓ Decision:** Each enemy is a self-contained vertical stack, in this
> order:
> 1. **Intent** — closest to the sprite, most prominent. Reacted to *this
>    turn*; the highest-priority information on the unit.
> 2. **Sprite**
> 3. **HP bar** — horizontal, directly under the sprite (not a side-mounted
>    vertical bar — tried and rejected; see Open Items / history below).
> 4. **Status row** — small icon chips below HP, with an overflow ("+2 more")
>    treatment once a row fills up.
>
> **Rationale:** Intent is the "react now" layer; status is the "ambient
> state" layer. Putting intent closest to the sprite and status furthest
> keeps the reaction-priority order legible at a glance. A side-mounted
> vertical HP bar was tested first and rejected — it ate too much lateral
> space per enemy when 2–3 are on screen simultaneously in portrait mode.

### 1- and 2-enemy formations — standalone, not inherited from the triangle

> **✓ Decision:** The 1-enemy (solo) and 2-enemy (side-by-side) formations
> are **vertically centered within the same overall "enemy area" band**
> that the 3-enemy triangle occupies as a whole (≈7%–47% of screen height,
> midpoint ≈27%) — not positioned at either of the triangle's two sub-rows
> (back row 18%, front row 36%). A solo enemy sits dead-center in that
> band; a pair sits at that same vertical midpoint, side-by-side.
>
> **This is a deliberate distinction:** the 2-enemy formation's horizontal
> spacing (**28%/72%**) is tighter than — and independent from — the
> triangle's front-pair spacing (20%/80%). The triangle's front pair was
> tuned as part of a 3-unit composition that also has to make room for the
> back unit above it; the standalone pair has no such constraint and reads
> better closer together. Initial test at 20%/80% (matching the triangle's
> front row) looked oddly gapped once isolated as a 2-unit encounter and
> was tightened. **Do not assume the 2-enemy formation is simply "the
> triangle's front row minus the back unit"** — it's an independently
> tuned layout that happens to share enemy-cell sizing (26% width) with
> the other two formations, nothing more.

---

## 3. Vessel & Companions

> **✓ Decision:** The vessel's info stack mirrors the enemy stack minus
> intent (the vessel doesn't telegraph its own action): **sprite → HP
> (horizontal, under sprite) → status row (below HP)**. This was
> initially built status-above-sprite and corrected for consistency with
> the enemy pattern.

> **✓ Decision:** Companions have no HP bar and no status row (per the
> combat design — companions have no HP). They sit in the same row as the
> vessel (vertically centered with it, not positioned "behind" it), sized
> slightly larger than initial test values, and pulled inward from the
> screen edges — close enough to read as flanking the vessel, not stranded
> near the screen edge.

---

## 4. Top Bar

> **✓ Decision:** Omen draw countdown lives in the **top-left corner** as
> a small badge (e.g. "Omen draw in: 2"). A ghost/placeholder hamburger
> menu occupies the top-right corner for visual symmetry, anticipating a
> future global game menu — not yet a functional element.

> **✓ Decision:** Floor progression UI is **removed from the combat
> screen entirely**. It will live on a different screen (door-select)
> and/or be accessible via the global menu, where it can be more
> prominent than it could ever be as a combat HUD element. See Open Items.

---

## 5. Action Bar

> **✓ Decision:** Three action buckets per `HLD-COMBAT-004` — **Action**
> (mandatory), **Support** (optional), **Consumable** (optional) — render
> as three buttons along the bottom: Support and Consumable as rectangles,
> Action as a **larger circle, centered between them**, so the mandatory
> action is reachable with either thumb regardless of handedness.

> **✓ Decision — circle/rectangle geometry:**
> - The circle's **bottom edge aligns with the rectangles' bottom edge**.
> - The circle's height is sized so that **35% of its height pokes above**
>   the rectangles' top edge (i.e. rectangle height = 65% of circle
>   diameter, bottoms aligned).
> - Rectangle width is set so each rectangle's **inner edge touches the
>   circle's outer edge** — flush, not overlapping. This defines the
>   *clickable hit-box* boundary only.
> - The visual "cutting into the side" feel (circle appearing to overlap
>   the rectangles) is explicitly **deferred to sprite/final art**, not
>   solved via hit-box geometry.

> **✓ Decision:** Once the Action bucket resolves, the same circle
> **relabels to "End Turn"** rather than introducing a separate button —
> it stays a circle, only its label/visual state changes. Support and
> Consumable buttons visually grey out once used, so the player can see
> at a glance which buckets are still open.

> **✓ Decision:** Ending the turn always requires an **explicit tap** —
> no auto-advance, even once all buckets are spent or were never going to
> be used. Flagged as a possible settings toggle (auto-end-turn) post-MVP,
> not at MVP.

---

## 6. Open Items

- **`[OPEN]`** Floor progression UI — exact treatment on the door-select
  screen and/or global menu not yet designed.
- **`[OPEN]`** Lightning Elemental phase transition (`LLD-ENEMIES-016`):
  the live 1-enemy → 2-Spark reflow mid-combat — snap or animated
  transition? Not yet decided; flagged during formation discussion.
- **`[OPEN]`** 4-enemy formation pattern — not designed. Current Floor 3
  spec ceiling is 3 simultaneous enemies; revisit only if a future
  encounter actually needs 4.
- **`[OPEN]`** Enemy sizing is held constant (26% cell width) across all
  three formations (1/2/3-enemy). Floor 3's only solo encounters are the
  two elites (Bear, Lightning Elemental — `LLD-ENEMIES-002`); whether a
  lone elite should get a visually larger sprite than a same-size normal
  enemy, or whether consistent sizing is preferable so players read size
  as fixed and HP/intent as the only threat signal, is unresolved.
- **`[OPEN]`** End Turn visual state for the circle — confirmed it stays a
  circle with a relabel, but the specific visual treatment (color/fill
  change, icon swap, etc.) is undesigned.
- **`[OPEN]`** Omen draw overlay (the 3-card draw/choice interaction
  itself), targeting flow (cancel affordance), and the action-list popup
  (scrollable, since no inventory cap exists per `HLD-ITEMS-001`) are all
  separate UI states not yet wireframed.

---

*Soul Protocol UI Design — Combat Screen v0.2*
*v0.1: Initial wireframe session. 3-enemy triangle formation, per-unit info
stack order, vessel/companion layout, top bar, and action bar geometry
(circle + bookending rectangles, End Turn relabel) confirmed. Floor
progression removed from combat screen. Several follow-on UI states
flagged as open.*
*v0.2: Added standalone 1-enemy and 2-enemy formations, both vertically
centered in the same enemy-area band the triangle occupies (≈27%
midpoint) rather than reusing the triangle's back/front row positions.
2-enemy horizontal spacing (28%/72%) confirmed independently of — and
tighter than — the triangle's front-pair spacing (20%/80%). Open question
logged on whether solo elites warrant larger sprites than normal enemies.*
*Next: Omen draw overlay, targeting flow, action-list popup, End Turn
visual state.*
