## MODIFIED Requirements

### Requirement: [HLD-RUN-006] Floor Transition
At the end of each floor (after the floor boss is defeated), the following SHALL occur before the next floor begins:
- The vessel's HP is fully restored to maximum
- Any active temporary companion departs — they do not carry to the next floor
- The bound companion (if present) persists unchanged into the next floor

There is no mid-floor HP restoration from room events. All mid-floor healing comes from items used in combat (see `hld-item-system`).

#### Scenario: Full HP restore at transition
- **WHEN** the player defeats the floor boss and transitions to the next floor
- **THEN** the vessel's HP is set to its maximum value before the next floor begins

#### Scenario: Temporary companion departs
- **WHEN** the player defeats the floor boss
- **THEN** any active temporary companion departs; their omen card is removed from the fate deck for the next floor

#### Scenario: Bound companion persists
- **WHEN** the player transitions between floors
- **THEN** a vessel's bound companion remains active and their omen card stays in the fate deck
