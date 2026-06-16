## MODIFIED Requirements

### Requirement: [HLD-DOOR-001] Two-Door Choice
Between each room the player SHALL face a two-door choice. Each door displays the identity of the encounter behind it. The player always chooses between two identified options — unless an item explicitly forces a single-door beat (e.g. the Worn Map companion beat, see `LLD-FLOOR-BEATS-003`).

#### Scenario: Two options always shown
- **WHEN** the player completes a room and no item forces a single-door beat
- **THEN** exactly two doors are presented with their encounter identities shown before the player commits

#### Scenario: Item forces single-door exception
- **WHEN** the player has an item that triggers a forced single-door beat
- **THEN** only one door is presented for that room; the player enters without a choice
