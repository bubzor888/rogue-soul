## Purpose
Defines the layout, information hierarchy, and interaction rules for the combat screen — the primary player-facing screen during an encounter. Covers enemy formation arrangements, per-unit information stacks, vessel and companion display, the top bar, and the action bar.

## Requirements

## ADDED Requirements

### Requirement: [UI-COMBAT-001] Enemy Formation Patterns
The combat screen SHALL arrange enemies in fixed positional patterns based on encounter count: a single enemy is centered in the enemy area; two enemies are placed side-by-side at horizontal positions 28% and 72% of screen width; three enemies form a triangle with one back-center unit (higher and slightly smaller to read as further away) and two front units at 20% and 80% horizontal.

#### Scenario: Single enemy centered
- **WHEN** an encounter has one enemy
- **THEN** the enemy is positioned centered horizontally in the enemy area band

#### Scenario: Two enemies side-by-side
- **WHEN** an encounter has two enemies
- **THEN** the enemies are placed at 28% and 72% horizontal positions, vertically centered in the enemy area band (midpoint ≈27% of screen height)

#### Scenario: Three enemies triangle
- **WHEN** an encounter has three enemies
- **THEN** one enemy occupies the back-center position (≈18% vertical) and two enemies occupy front positions at 20% and 80% horizontal (≈36% vertical); the back unit is rendered slightly smaller

### Requirement: [UI-COMBAT-002] Formation Layouts Are Independent
The 1-enemy and 2-enemy formations SHALL be vertically centered within the same overall enemy area band that the 3-enemy triangle occupies (approximately 7%–47% of screen height, midpoint ≈27%), NOT positioned at the triangle's specific back-row or front-row heights. The 2-enemy horizontal spacing (28%/72%) is independently tuned and SHALL NOT be assumed to match the triangle's front-pair spacing (20%/80%).

#### Scenario: Two-enemy formation uses its own horizontal spacing
- **WHEN** a 2-enemy encounter is displayed
- **THEN** enemies are at 28%/72% horizontal — not at the triangle's front-row 20%/80%

#### Scenario: Solo enemy not at triangle row heights
- **WHEN** a 1-enemy encounter is displayed
- **THEN** the enemy is vertically centered at the enemy area midpoint, not at the triangle back-row (18%) or front-row (36%) heights

### Requirement: [UI-COMBAT-003] Per-Enemy Information Stack
Each enemy unit SHALL render as a self-contained vertical stack in this top-to-bottom order: (1) intent indicator, (2) sprite, (3) HP bar (horizontal, directly beneath sprite), (4) status row (icon chips with overflow treatment). Enemy cell width is 26% of screen width across all formation sizes.

#### Scenario: Intent displayed above sprite
- **WHEN** an enemy has a declared intent for the current turn
- **THEN** the intent indicator is the topmost element in the enemy stack, closest to the sprite

#### Scenario: HP bar horizontal under sprite
- **WHEN** an enemy is displayed
- **THEN** a horizontal HP bar appears directly beneath the sprite (not a side-mounted vertical bar)

#### Scenario: Status overflow
- **WHEN** an enemy has more status icons than fit in a single row
- **THEN** the row shows as many icons as fit and appends an overflow badge (e.g. "+2 more")

### Requirement: [UI-COMBAT-004] Vessel Information Stack
The vessel's information stack SHALL mirror the enemy stack minus the intent element: (1) sprite, (2) HP bar (horizontal, directly beneath sprite), (3) status row. The vessel does not display an intent indicator.

#### Scenario: Vessel stack order
- **WHEN** the vessel is displayed
- **THEN** the order is sprite → HP bar → status row, with no intent element above the sprite

### Requirement: [UI-COMBAT-005] Companion Display
Companions SHALL have no HP bar and no status row. Companions are displayed in the same horizontal row as the vessel (vertically aligned with it, not positioned behind it), sized slightly larger than the initial prototype values, and positioned inward from screen edges so they read as flanking the vessel rather than stranded near the edge.

#### Scenario: Companion has no HP or status
- **WHEN** a companion is displayed in combat
- **THEN** no HP bar and no status row appears on the companion unit

#### Scenario: Companions flank the vessel
- **WHEN** one or more companions accompany the vessel
- **THEN** companions are horizontally adjacent to the vessel, pulled inward from screen edges

### Requirement: [UI-COMBAT-006] Top Bar
The combat screen top bar SHALL contain: an omen draw countdown badge in the top-left corner (e.g. "Omen draw in: 2"), and a placeholder global menu affordance in the top-right corner for visual symmetry. Floor progression UI SHALL NOT appear on the combat screen.

#### Scenario: Omen countdown shown
- **WHEN** the combat screen is active
- **THEN** the omen draw countdown is visible in the top-left corner

#### Scenario: Floor progression absent
- **WHEN** the combat screen is active
- **THEN** no floor progression indicator is present on the screen

### Requirement: [UI-COMBAT-007] Action Bar Layout
The action bar SHALL render three action buckets per HLD-COMBAT-004 — Action (mandatory), Support (optional), and Consumable (optional) — as: one large circle for the Action bucket, centered between two flanking rectangles (Support left, Consumable right). The circle's bottom edge aligns with the rectangles' bottom edge. The circle's height is sized so that 35% of its height extends above the rectangles' top edge (rectangle height = 65% of circle diameter). Each rectangle's inner edge is flush with the circle's outer edge, defining the hit-box boundary.

#### Scenario: Action button is a centered circle
- **WHEN** the action bar is displayed
- **THEN** the Action bucket renders as a circle centered between the Support and Consumable rectangles

#### Scenario: Circle geometry
- **WHEN** the action bar is rendered
- **THEN** the circle's bottom aligns with the rectangles' bottom, and 35% of the circle's height protrudes above the rectangles' top

### Requirement: [UI-COMBAT-008] Action Bar State Transitions
Once the Action bucket is resolved, the Action circle SHALL relabel to "End Turn" (same circle, label/visual state change only — no new button). Support and Consumable buttons SHALL visually grey out once used. Ending the turn always requires an explicit tap with no auto-advance, even if all buckets are resolved or unused.

#### Scenario: Action resolved → End Turn relabel
- **WHEN** the player resolves the Action bucket
- **THEN** the Action circle changes its label/state to "End Turn" without introducing a new button or changing the circle geometry

#### Scenario: Used bucket greyed out
- **WHEN** a Support or Consumable bucket has been used this turn
- **THEN** that bucket's button appears visually greyed out

#### Scenario: No auto-advance
- **WHEN** all action buckets are resolved or the player chooses not to use optional buckets
- **THEN** the turn does NOT advance automatically; the player must tap End Turn explicitly
