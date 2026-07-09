## Purpose
Defines the layout, information hierarchy, and interaction rules for the combat screen — the primary player-facing screen during an encounter. Covers enemy formation arrangements, per-unit information stacks, vessel and companion display, the top bar, and the action bar.

## Requirements

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

### Requirement: [UI-COMBAT-009] Action Bucket Item Selection
Tapping any action bucket (Action, Support, or Consumable) SHALL open a selection sheet listing every option currently usable in that bucket. For the Action bucket this is Default Strike (see `HLD-COMBAT-011`) plus every owned weapon. For the Support bucket this is every owned support item plus any vessel support ability. For the Consumable bucket this is every owned consumable.

The sheet SHALL slide up from the bottom and sit over a dimmed version of the combat scene, at a fixed height tall enough to cover the vessel sprite. This height does not grow or shrink with the number of items in the list. Each row in the list SHALL show: a leading icon, the item's name, a one-line summary of its effect (damage and type, or effect description), and a charge readout — either the word "unlimited" (Default Strike) or a row of small circular dots, one per charge.

Spent charges SHALL be rendered as a plain red "X" glyph (not a shaded or greyed-out dot) in place of the dot entirely, not layered inside one. Spent-charge indicators SHALL appear before (to the left of) remaining-charge dots, so the row reads left-to-right as depletion order — the charges a player has already used are the leftmost marks, the charges still available are the rightmost.

The sheet header SHALL include a "cancel" affordance that returns to the default action-bar state without committing any selection.

#### Scenario: Sheet opens over dimmed scene
- **WHEN** the player taps the Action, Support, or Consumable bucket
- **THEN** a selection sheet slides up from the bottom, covering the vessel sprite, while the combat scene above it is shown dimmed

#### Scenario: Row shows charges as dots with red-X spent marks
- **WHEN** an owned weapon with some charges already spent is shown in the selection sheet
- **THEN** each spent charge is rendered as a bare red X (no circle), positioned to the left of the remaining circular charge dots

#### Scenario: Unlimited option has no charge dots
- **WHEN** Default Strike is shown in the Action bucket's selection sheet
- **THEN** its charge readout displays the word "unlimited" instead of any dots

#### Scenario: Cancel returns to default state
- **WHEN** the player taps "cancel" in the selection sheet header
- **THEN** the sheet closes and the action bar returns to its default (nothing selected) state

### Requirement: [UI-COMBAT-010] Selection Sheet Scroll Behavior
When the number of items in a selection sheet's list exceeds the sheet's fixed height, the list SHALL scroll internally rather than the sheet growing taller. A fade-out gradient SHALL appear at the bottom edge of the list whenever there is more content below the visible area, and a thin scrollbar affordance SHALL be visible during scrolling, since this is a touch list rather than a mouse-hover context.

#### Scenario: List scrolls without growing the sheet
- **WHEN** a bucket has more owned items than fit within the selection sheet's fixed height
- **THEN** the item list scrolls internally; the sheet itself remains at its fixed height

#### Scenario: Bottom fade cues more content
- **WHEN** the item list has content below the currently visible rows
- **THEN** a gradient fade appears at the bottom edge of the list, signalling more items are available by scrolling

### Requirement: [UI-COMBAT-011] Target Selection
After the player taps an item or ability in the selection sheet that requires a target, the sheet SHALL NOT close. It remains open at the same fixed height, and the tapped row becomes visually distinguished as the committed selection (a distinct border and background colour, a checkmark, and a one-line prompt such as "tap an enemy above to attack"). Simultaneously, every currently valid target in the combat scene above the sheet SHALL display a highlighted ring and a "tap to target" label, making the scene interactive while the sheet stays visible for the player to change their mind.

Validity of a target is determined by the chosen item/ability's targeting rule, not by any property of the potential target being excluded from consideration. As of this spec, no game mechanic removes an enemy from being a valid target — the Evade action affects the attacker's hit chance, not the defender's targetability — so under current rules every alive enemy is always shown as a valid, highlighted target. This requirement describes the highlighting mechanism generally so that a future targeting restriction (should one be added) only needs to change which targets qualify, not how a qualifying target is presented.

#### Scenario: Selected row stays visible with a prompt
- **WHEN** the player taps a single-target weapon in the Action selection sheet
- **THEN** the sheet stays open at its same height, that row is shown with a distinct highlighted style and a prompt to tap a target, and the other rows remain available to switch to

#### Scenario: All enemies highlighted as targets today
- **WHEN** the player has selected a single-target item and no targeting-restricting effect is active
- **THEN** every alive enemy in the scene displays the highlighted targeting ring and "tap to target" label
