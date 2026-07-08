## MODIFIED Requirements

### Requirement: [HLD-RUN-006] Floor Transition
At the end of each floor (after the floor boss is defeated), the following SHALL occur before the next floor begins:
- The vessel's HP is fully restored to maximum
- Any active temporary companion departs — they do not carry to the next floor
- The bound companion (if present) persists unchanged into the next floor

There is no mid-floor HP restoration from room events, with exactly one exception: the guaranteed post-elite Rest room (see `LLD-FLOOR-BEATS-006`), which restores HP mid-floor as its entire purpose. Outside that one room, all mid-floor healing comes from items used in combat (see `hld-item-system`) or from trades accepted at a Wandering Soul (see `hld-wandering-soul`) — neither of which is a passive room-event heal; both require the player to spend something to receive HP.

#### Scenario: Full HP restore at transition
- **WHEN** the player defeats the floor boss and transitions to the next floor
- **THEN** the vessel's HP is set to its maximum value before the next floor begins

#### Scenario: Temporary companion departs
- **WHEN** the player defeats the floor boss
- **THEN** any active temporary companion departs; their omen card is removed from the fate deck for the next floor

#### Scenario: Bound companion persists
- **WHEN** the player transitions between floors
- **THEN** a vessel's bound companion remains active and their omen card stays in the fate deck

#### Scenario: Rest room is the sole room-event heal
- **WHEN** the player enters any room event other than the post-elite Rest room
- **THEN** no HP is restored purely by entering that room; mid-floor healing still requires combat items or an accepted Wandering Soul trade
