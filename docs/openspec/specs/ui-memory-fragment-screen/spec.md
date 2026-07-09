## Purpose
Defines the layout and interaction rules for the three Memory Fragment room content screens (Category A, Companion Encounter, Category C), reached after the player chooses a Memory Fragment door on the room-select screen (see `ui-room-select-screen`).

## Requirements

### Requirement: [UI-MF-001] Shared Layout Shell
Every Memory Fragment room content screen (reached after the door is chosen on the room-select screen — see `ui-room-select-screen`) SHALL share a common layout shell regardless of which category was drawn (see `HLD-MF-002`): a ghost hamburger menu placeholder in the top-right corner, reused verbatim from the combat and room-select screens; a scene stage centered in the space above the choice controls, currently rendered as a blank placeholder box reserved for future fragment art with a flavour-text caption below it; and the category's choice controls anchored to the bottom of the screen.

#### Scenario: Menu ghost matches other screens
- **WHEN** any Memory Fragment room screen is displayed
- **THEN** the same ghost hamburger menu placeholder used on the combat and room-select screens appears in the top-right corner

#### Scenario: Scene stage is blank pending art
- **WHEN** any Memory Fragment room screen is displayed
- **THEN** the scene stage area shows an empty placeholder box (no character or unique art) with a flavour-text line below it, centered in the space above the choice controls

### Requirement: [UI-MF-002] Category A — Fair Trade Layout
The Category A (Fair Trade) screen SHALL present one fully-revealed trade card showing the give side and receive side (each with an icon and item/HP name), tap-anywhere-on-card to accept, per `HLD-MF-003`. Below the card, a "walk away" bar SHALL be shown as a lighter-weight control (not a second co-equal card), representing the no-cost, no-reward option.

#### Scenario: Trade card shows both sides
- **WHEN** the Category A screen is displayed
- **THEN** the give item/cost and the receive item/reward are both fully visible before the player commits to anything

#### Scenario: Walk away is always available
- **WHEN** the Category A screen is displayed
- **THEN** a "walk away" control is present below the trade card, distinct in weight from the card itself

### Requirement: [UI-MF-003] Companion Encounter Layout
The Companion Encounter screen SHALL NOT use the blank scene-stage treatment described in `UI-MF-001`. Instead it SHALL show a dedicated presence card, centered on screen, containing the companion's sprite, its name, and flavour text only — no passive effect, granted ability, or omen contribution is disclosed, per `HLD-MF-004`. Below the presence card, a single accept control (e.g. "It settles in") SHALL be shown; this is the only control on the screen, since companion encounters are mandatory and cannot be declined. No swap, keep-current-companion, or comparison-of-two-companions state SHALL be presented on this screen — the one-companion-encounter-per-floor guarantee holds by construction (see `LLD-FLOOR-BEATS-003`), so a situation requiring a swap choice cannot arise.

#### Scenario: Presence card shows flavour only
- **WHEN** the Companion Encounter screen is displayed
- **THEN** the companion's sprite, name, and flavour text are shown; no mechanical detail about the companion's ability or effects is displayed

#### Scenario: Single mandatory accept control
- **WHEN** the Companion Encounter screen is displayed
- **THEN** exactly one control is present (accept); there is no decline option and no second companion shown for comparison

### Requirement: [UI-MF-004] Category C — Unfair Trade Layout
The Category C (Unfair Trade) screen SHALL present two cost-bearing option cards, per `HLD-MF-005`: Option 1 ("take the deal") showing both a give side and a receive side, and Option 2 ("cut your losses") showing only a give/loss side with no receive side. A note SHALL be shown stating that walking away is not available on this screen, and no walk-away control SHALL be present anywhere on the screen.

#### Scenario: Option 2 has no receive side
- **WHEN** the Category C screen is displayed
- **THEN** Option 2's card shows only what is lost, with no corresponding reward shown

#### Scenario: No walk-away control present
- **WHEN** the Category C screen is displayed
- **THEN** no walk-away or decline control exists anywhere on the screen; a "walking away is not available" note is shown instead
