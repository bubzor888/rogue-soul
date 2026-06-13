## Purpose
Floor-specific data for the Memory Fragment system — category weights and scenario/companion pools per floor. System mechanics are defined in `hld-memory-fragments`.
## Requirements
### Requirement: [LLD-MF-007] Floor 3 Category Weights
The Memory Fragment category draw on Floor 3 SHALL use the following weights: **40% Category A / 40% Companion Encounter / 20% Category C**. See `HLD-MF-002` for the draw mechanic.

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
The Companion Encounter pool for Floor 3 contains three temporary companions. When a companion encounter fires on Floor 3, one companion is drawn at random from this pool using the NAVIGATION RNG stream and offered to the player. See `HLD-MF-004` for the mandatory acceptance rule and one-per-floor limit.

All three companions are defined in `lld-companions` (`LLD-COMP-001`, `LLD-COMP-002`, `LLD-COMP-003`).

| Companion | Key mechanic | Departs when |
|---|---|---|
| The Raven | Grants a one-use active ability: mark one enemy for death at the next omen shift | Ability is used (departs immediately on use) |
| The Shadow | Drains 2 HP/turn from a random enemy; switches target on kill | Cumulative drain total reaches 20 HP |
| The Life Mote | Intercepts vessel death once; revives at 5 HP | Revive triggers |

**Flavour text introductions** (shown to player on offer; no mechanics disclosed):

- **The Raven**: *"A dark shape lands on your shoulder. It watches the road ahead with sharp, knowing eyes — waiting for you to point it somewhere."*
- **The Shadow**: *"Something cold and weightless settles beside you. You cannot see it clearly, but you sense it is hungry."*
- **The Life Mote**: *"A soft light drifts close, hovering just at the edge of sight. It asks nothing. It simply stays."*

#### Scenario: Companion pool draw
- **WHEN** a companion encounter fires on Floor 3
- **THEN** one companion is selected at random from the three pool entries using the NAVIGATION RNG stream; that companion is offered to the player

---

### Requirement: [LLD-MF-010] Category C Scenario Pool (Floor 3)
`[OPEN·MVP1]` The Category C (Unfair Trade) scenario pool for Floor 3 SHALL be defined before MVP1. Recommended starting size: 2 distinct scenarios. Each scenario specifies both options with exact costs and rewards, confirming Option 2's cost is always lower than Option 1's price. See `HLD-MF-005` for the category mechanic.

#### Scenario: [OPEN·MVP1] Category C pool defined
- **WHEN** Category C scenarios are written for Floor 3
- **THEN** each scenario specifies both options with exact HP and item costs/rewards, and confirms that Option 2's cost is lower than Option 1's price

