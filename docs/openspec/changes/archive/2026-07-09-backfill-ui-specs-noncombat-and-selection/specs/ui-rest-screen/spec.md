## ADDED Requirements

### Requirement: [UI-REST-001] Rest Room Layout
The Rest room screen (the guaranteed post-elite rest encounter defined in `LLD-FLOOR-BEATS-006`) SHALL show: a ghost hamburger menu placeholder in the top-right corner, reused verbatim from the combat and room-select screens; no character sprite of any kind, since this room has no associated character; a single centered card containing flavour text and a heal-amount callout; and one action bar reading "Keep going..." as the sole control on the screen. There is no door or category choice on this screen — Rest is a single guaranteed beat, not a draw.

The heal-amount callout is a required visual element of the card. Its numeric value is not specified by this requirement — the amount the Rest room restores remains open per `LLD-FLOOR-BEATS-006`/`HLD-RUN-006`, and this screen SHALL display whatever value the underlying rule eventually resolves to.

#### Scenario: No character sprite
- **WHEN** the Rest room screen is displayed
- **THEN** no vessel, companion, enemy, or other character sprite appears anywhere on screen

#### Scenario: Single action, no choice
- **WHEN** the Rest room screen is displayed
- **THEN** exactly one control ("Keep going...") is present; there is no second option and no door choice

#### Scenario: Heal amount is shown, value not fixed by this spec
- **WHEN** the Rest room screen is displayed
- **THEN** a heal-amount callout is visible on the card; the specific number displayed is whatever `LLD-FLOOR-BEATS-006` eventually defines, not a value fixed by this UI requirement
