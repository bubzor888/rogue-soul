## MODIFIED Requirements

### Requirement: [LLD-ITEMS-011] Item Tier List
`[OPEN·MVP1]` All items in the game SHALL be assigned a tier value. The tier list is used by the Wandering Soul trade generation system to enforce tier-fair pairings (see `HLD-WS-006`) and by loot pool selection to distinguish normal-tier from elite-tier drops (see `HLD-COMBAT-012`, `HLD-COMBAT-013`).

#### Scenario: [OPEN·MVP1] Item tier list defined
- **WHEN** the item tier list is written
- **THEN** every item in `lld-items` has an assigned tier; the tier values are used by trade generation and loot pool systems at runtime
