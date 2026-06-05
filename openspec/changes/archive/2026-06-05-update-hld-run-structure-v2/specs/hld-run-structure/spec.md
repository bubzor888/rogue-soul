## MODIFIED Requirements

### Requirement: [HLD-RUN-004] Boss Structure
Every run SHALL end with the Judge as the final boss on the last floor. The Judge is the guardian at the threshold of Solace — the same encounter regardless of which vessel is played. Bosses on non-final floors (present in Tier 2 and Tier 3 runs) are vessel-dependent and defined in LLD.

#### Scenario: Judge is always the final boss
- **WHEN** a player reaches the last floor of their run
- **THEN** the final boss is the Judge, regardless of which vessel was chosen

#### Scenario: Intermediate bosses vary by vessel
- **WHEN** a Tier 2 or Tier 3 vessel completes a non-final floor
- **THEN** the floor boss is determined by the vessel's path, as defined in LLD

## REMOVED Requirements

### Requirement: [HLD-RUN-003] Floor Depth Choice
**Reason**: Floor depth is not a player choice — it is determined by the vessel's tier (Tier 1 = 1 floor, Tier 2 = 2 floors, Tier 3 = 3 floors), fully specified in HLD-VESSEL-007. Maintaining this requirement separately would create two sources of truth.
**Migration**: None required. Remove any pre-run depth selection UI or logic; depth is derived from the selected vessel.
