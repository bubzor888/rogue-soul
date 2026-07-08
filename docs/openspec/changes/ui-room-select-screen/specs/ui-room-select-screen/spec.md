## ADDED Requirements

### Requirement: [UI-ROOM-001] Standard Two-Door Layout
Every room slot on Floor 3, including the elite gate, SHALL present exactly two door options. No room slot SHALL be presented as a forced or single-door choice; "elite" is not a structurally special slot at the UI level — it is one possible option that can appear at a slot, the same as any other encounter type.

#### Scenario: Every slot shows two doors
- **WHEN** the room select screen is displayed for any room slot, including the elite gate
- **THEN** exactly two door options are shown; no slot renders only one door or auto-advances without a choice

### Requirement: [UI-ROOM-002] Door Symbol Taxonomy
Each door SHALL display a symbol identifying its contents according to the following rule set:
- **Combat doors** SHALL use a symbol identifying the specific enemy the player will face (one distinct symbol per enemy entry in the Normal and Elite enemy tables) — not a generic "combat" symbol and not a family-level symbol (e.g. not a shared "Undead" symbol for all undead enemies).
- **Memory Fragment doors** SHALL use a single fixed symbol regardless of which outcome category (fair trade / companion encounter / unfair trade) is behind it.
- **Wandering Soul doors** SHALL use a single fixed symbol, with no visual distinction between a guaranteed pre-Judge appearance and a natural appearance.
- No other room types exist in the door taxonomy beyond combat, Memory Fragment, and Wandering Soul.

`[OPEN·MVP2]` The full enumeration of per-enemy combat door symbols (one asset per Normal and Elite enemy table entry) is deferred to a separate art-direction scoping pass; this requirement confirms the rule, not the asset list.

#### Scenario: Combat door symbol identifies the specific enemy
- **WHEN** a door leads to a combat encounter
- **THEN** the door's symbol is unique to that specific enemy, distinct from the symbol used for any other enemy

#### Scenario: Memory Fragment door symbol is category-agnostic
- **WHEN** a door leads to a Memory Fragment room
- **THEN** the door displays the single fixed Memory Fragment symbol regardless of which outcome category is behind it

#### Scenario: Wandering Soul door symbol does not hint at guarantee status
- **WHEN** a door leads to a Wandering Soul encounter
- **THEN** the door displays the single fixed Wandering Soul symbol, with no visual difference between a guaranteed and a natural appearance

### Requirement: [UI-ROOM-003] Symbol-Only Doors, No Text Label
Doors SHALL display only their symbol, with no text label or caption beneath it (e.g. no "Skeleton" caption under a combat door's symbol). The symbol is the entire decision-making surface for the door; there is no text fallback.

#### Scenario: No caption under any door symbol
- **WHEN** the room select screen is displayed
- **THEN** neither door shows a text label or caption identifying its contents in words

### Requirement: [UI-ROOM-004] Side-by-Side Door Layout
The two doors SHALL be laid out side by side (not stacked vertically), anchored near the top of the screen directly under the heading.

#### Scenario: Doors appear side by side under the heading
- **WHEN** the room select screen is displayed
- **THEN** the two door options are positioned side by side, directly beneath the screen's heading

### Requirement: [UI-ROOM-005] Screen Composition Order
The screen SHALL compose its elements top to bottom in this order: ghost hamburger menu (top-right) → heading → two doors (anchored near the top) → vessel sprite (anchored near the bottom) → segmented floor-progress bar (footer, bottom of screen). A breathing-room gap (roughly two lines of text) SHALL separate the screen's top edge from the heading.

#### Scenario: Elements appear in fixed top-to-bottom order
- **WHEN** the room select screen is displayed
- **THEN** the ghost menu, heading, doors, vessel sprite, and floor-progress bar appear in that top-to-bottom order

#### Scenario: Top breathing room above heading
- **WHEN** the room select screen is displayed
- **THEN** a visible gap separates the top edge of the screen from the heading, roughly equivalent to two lines of text

### Requirement: [UI-ROOM-006] Ghost Hamburger Menu Reused Verbatim
The screen SHALL reuse the same ghost/placeholder hamburger menu element used on the combat screen — same styling, position (top: 3%, right: 4%), glyph (`≡`), opacity (0.4), and "menu" label. The element is not functional pending a future global game menu.

#### Scenario: Ghost menu matches combat screen exactly
- **WHEN** the room select screen and combat screen are compared
- **THEN** the ghost hamburger menu element uses identical styling, position, glyph, opacity, and label on both screens

### Requirement: [UI-ROOM-007] Vessel Sprite Anchors the Bottom
The vessel SHALL be shown standing in the room, anchored near the bottom of the screen, at the same scale used on the combat screen (~26% screen width, ~1:1.2 aspect ratio).

`[OPEN·MVP3]` Final vessel sprite orientation (e.g. third-person from behind) is not yet decided; the layout requirement holds regardless of final orientation.

#### Scenario: Vessel sprite scale matches combat screen
- **WHEN** the room select screen is displayed
- **THEN** the vessel sprite is shown at approximately 26% screen width and a 1:1.2 aspect ratio, positioned near the bottom of the screen

### Requirement: [UI-ROOM-008] Segmented Floor-Progress Bar
A segmented progress bar SHALL appear at the bottom of the screen, with exactly one segment per room in the floor. The bar SHALL NOT be accompanied by a text label (e.g. no "Room 5 of 9" caption); the filled segment count alone conveys progress. The exact room count SHALL be shown — floor progress is not treated as spoiler information, unlike encounter contents.

#### Scenario: One segment per room, no text
- **WHEN** the floor-progress bar is displayed
- **THEN** the number of segments equals the total number of rooms in the floor, filled segments equal rooms completed, and no numeric or text label accompanies the bar

#### Scenario: Progress bar shows real room count
- **WHEN** the floor-progress bar is displayed
- **THEN** the segment count reflects the actual number of rooms in the floor, not an obscured or approximated count
