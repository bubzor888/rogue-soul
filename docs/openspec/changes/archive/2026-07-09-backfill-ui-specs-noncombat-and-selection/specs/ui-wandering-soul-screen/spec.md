## ADDED Requirements

### Requirement: [UI-WS-001] Merchant Presence
The Wandering Soul room screen SHALL show a ghost hamburger menu placeholder in the top-right corner, reused verbatim from the combat and room-select screens, and the merchant's sprite paired with a speech bubble, both centered in the open space above the trade offer cards so the background shows around them. The speech bubble SHALL use a pointed tail (rendered as a CSS triangle) directed at the merchant sprite, and its text SHALL carry both the room's flavour line and the "take any, all, or none" rule (per `HLD-WS-001`) — no separate heading duplicates this instruction elsewhere on screen.

#### Scenario: Merchant and bubble centered above the cards
- **WHEN** the Wandering Soul room screen is displayed
- **THEN** the merchant sprite and its speech bubble appear centered in the space above the trade offer cards, not anchored to a screen edge

#### Scenario: Bubble carries both flavour and the trading rule
- **WHEN** the Wandering Soul room screen is displayed
- **THEN** the speech bubble's text includes both a flavour line and a statement that offers may be taken any, all, or none; no separate heading element repeats the trading rule

### Requirement: [UI-WS-002] Independent Trade Offer Cards
The Wandering Soul room screen SHALL present 2–3 trade offer cards below the merchant, per `HLD-WS-001`. Each card SHALL fully reveal both sides of its trade (give and receive, including multi-item "give" sides where a trade costs more than one item — see `HLD-WS-002`) and SHALL be tap-to-accept independently of the other cards; accepting one offer SHALL NOT affect the availability of the others. The HP-for-item offer guaranteed by `HLD-WS-003` SHALL carry a note distinguishing it as always-present.

#### Scenario: Cards are independently acceptable
- **WHEN** the player accepts one trade offer card
- **THEN** the remaining offer cards remain available to accept or decline independently; nothing about them changes as a result

#### Scenario: Multi-item give side is supported
- **WHEN** an offer's cost is more than one item (e.g. consumables-for-item, per `HLD-WS-002`)
- **THEN** the card's give side shows each cost item individually, not merged into a single slot

### Requirement: [UI-WS-003] Done Trading Control
A "Done trading" bar SHALL appear at the bottom of the screen, below the offer cards. This is not a binary "leave both" control like the loot screen's decline bar (see `UI-LOOT-007`) — because Wandering Soul offers are accepted independently rather than presented as a mutually exclusive pair, this control simply closes the room; any offers the player did not accept are lost with no further consequence.

#### Scenario: Done trading closes the room regardless of prior accepts
- **WHEN** the player taps "Done trading" after having accepted zero, some, or all of the offer cards
- **THEN** the room closes; any unaccepted offers are lost, and no additional confirmation step is required
