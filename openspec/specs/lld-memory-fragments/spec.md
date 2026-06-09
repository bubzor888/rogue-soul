## Purpose
Floor-specific data for the Memory Fragment system — category weights and scenario/companion pools per floor. System mechanics are defined in `hld-memory-fragments`.
## Requirements
### Requirement: [LLD-MF-007] Floor 3 Category Weights
The Memory Fragment category draw on Floor 3 SHALL use the following weights: **40% Category A / 40% Companion Encounter / 20% Category C**. See `HLD-MF-002` for the draw mechanic.

`[OPEN·MVP1]` Companion Encounter weighting to be tuned if the Worn Map companion beat (`LLD-FLOOR-BEATS-003`) makes companion offers too frequent on the floor.

#### Scenario: Category C is least common
- **WHEN** Memory Fragment categories are drawn across multiple runs on Floor 3
- **THEN** Category C appears roughly half as often as Category A or Companion Encounter

### Requirement: [LLD-MF-008] Category A Scenario Pool (Floor 3)
`[OPEN·MVP1]` The Category A (Fair Trade) scenario pool for Floor 3 SHALL be defined before MVP1. Recommended starting size: 4 distinct scenarios. Each scenario specifies both options with exact costs and rewards at tier parity. See `HLD-MF-003` for the category mechanic.

#### Scenario: [OPEN·MVP1] Category A pool defined
- **WHEN** Category A scenarios are written for Floor 3
- **THEN** each scenario specifies both options with exact HP and item costs/rewards at tier parity, and any locked vessel hint if applicable

---

### Requirement: [LLD-MF-009] Companion Encounter Pool (Floor 3)
`[OPEN·MVP1]` The Companion Encounter pool for Floor 3 SHALL be defined during a companion design session. The pool specifies the available temporary companions, their passive effects, omen cards, and flavour text introductions. See `HLD-MF-004` for the category mechanic and `LLD-FLOOR-PATT-003` for the companion cap.

#### Scenario: [OPEN·MVP1] Companion pool defined
- **WHEN** the Companion Encounter pool is written for Floor 3
- **THEN** each companion specifies: flavour text introduction, passive ability, omen card contribution, and any locked vessel hint if applicable

---

### Requirement: [LLD-MF-010] Category C Scenario Pool (Floor 3)
`[OPEN·MVP1]` The Category C (Unfair Trade) scenario pool for Floor 3 SHALL be defined before MVP1. Recommended starting size: 2 distinct scenarios. Each scenario specifies both options with exact costs and rewards, confirming Option 2's cost is always lower than Option 1's price. See `HLD-MF-005` for the category mechanic.

#### Scenario: [OPEN·MVP1] Category C pool defined
- **WHEN** Category C scenarios are written for Floor 3
- **THEN** each scenario specifies both options with exact HP and item costs/rewards, and confirms that Option 2's cost is lower than Option 1's price

