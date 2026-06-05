## MODIFIED Requirements

### Requirement: [HLD-RUN-002] Door Symbols
Each room type SHALL have a distinct symbol visible on its door before the player enters. Symbols MUST be instantly readable, thematically consistent with purgatory's visual language, and not derivative of Slay the Spire's iconography.

| Room Type | Symbol function |
|---|---|
| Combat | Encounter-specific symbol — identifies the enemy or encounter the player will face |
| Elite Combat | Encounter-specific symbol with an added warning glyph — harder fight, better reward |
| Memory Fragment | Signals a narrative/lore event |
| Wandering Soul | Signals a trade opportunity |
| Boss / Threshold | Floor exit encounter — always at end of a floor |

#### Scenario: Symbol legibility
- **WHEN** a door symbol is displayed
- **THEN** the player can identify the room type without reading any text label

#### Scenario: Combat symbol identifies encounter
- **WHEN** a combat door symbol is displayed
- **THEN** the player can identify the specific enemy or encounter type before entering

#### Scenario: [OPEN] Symbol visual language
- **WHEN** symbols are implemented
- **THEN** exact visual design to be decided in a UI/art direction session
