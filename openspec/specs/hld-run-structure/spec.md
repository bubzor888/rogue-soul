## Purpose
Defines the run navigation model — corridor door-by-door movement, door symbols, floor depth, boss structure, room composition, and floor transition mechanics.
## Requirements
### Requirement: [HLD-RUN-001] Corridor Navigation
The player SHALL move through purgatory door by door. At each threshold they can see the symbol on the current door (the room they are about to enter) and the two doors beyond it. No further look-ahead. No top-down map.

#### Scenario: Visibility rule
- **WHEN** the player is at any room
- **THEN** they can see the current room symbol and exactly two choices ahead — no more

#### Scenario: No backtracking
- **WHEN** the player chooses a door
- **THEN** there is no mechanism to return to a previously visited room

---

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

#### Scenario: [OPEN·MVP2] Symbol visual language
- **WHEN** symbols are implemented
- **THEN** exact visual design to be decided in a UI/art direction session

---

### Requirement: [HLD-RUN-004] Boss Structure
Every run SHALL end with the Judge as the final boss on the last floor. The Judge is the guardian at the threshold of Solace — the same encounter regardless of which vessel is played. Bosses on non-final floors (present in Tier 2 and Tier 3 runs) are vessel-dependent and defined in LLD.

#### Scenario: Judge is always the final boss
- **WHEN** a player reaches the last floor of their run
- **THEN** the final boss is the Judge, regardless of which vessel was chosen

#### Scenario: Intermediate bosses vary by vessel
- **WHEN** a Tier 2 or Tier 3 vessel completes a non-final floor
- **THEN** the floor boss is determined by the vessel's path, as defined in LLD

---

### Requirement: [HLD-RUN-005] Room Composition
Floor room type ratios and mandatory placements (e.g. always end with Boss) SHALL be defined in data-driven FloorProfile resources, not hardcoded in NavigationModel. Different floor numbers load different profiles.

#### Scenario: Floor profile swap
- **WHEN** a new floor is added
- **THEN** adding a new FloorProfile resource is sufficient — no NavigationModel code change is required

---

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

