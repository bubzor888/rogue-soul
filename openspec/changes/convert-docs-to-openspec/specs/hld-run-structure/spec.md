## ADDED Requirements

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

| Room Type | Function |
|---|---|
| Combat | Standard enemy encounter |
| Elite Combat | Harder fight, better reward (same symbol with a warning glyph) |
| Rest / Mending | Heal vessel or restore companion |
| Memory Fragment | Narrative/lore event — soul recovers a piece of its history |
| Wandering Soul | Merchant equivalent — trade items with a lost spirit |
| Anomaly | Unknown — corrupted or unreadable symbol, risk/reward |
| Echo Chamber | Encounter with a remnant of a past vessel or enemy |
| Boss / Threshold | Floor exit encounter — always at end of a floor |

#### Scenario: Symbol legibility
- **WHEN** a door symbol is displayed
- **THEN** the player can identify the room type without reading any text label

#### Scenario: [OPEN] Symbol visual language
- **WHEN** symbols are implemented
- **THEN** exact visual design to be decided in a UI/art direction session

---

### Requirement: [HLD-RUN-003] Floor Depth Choice
Before each run the player SHALL choose how many floors they will descend: 1, 2, or 3. This choice is locked in at run start and cannot be changed mid-run.

| Depth | Duration | Meta reward |
|---|---|---|
| 1 floor | 10–15 min | Modest |
| 2 floors | 20–25 min | Medium |
| 3 floors | 30–45 min | Best + completion bonus |

#### Scenario: Commitment is locked
- **WHEN** a player selects depth 3 and dies on floor 2
- **THEN** they receive no completion bonus; the consequence of the upfront choice is enforced

#### Scenario: Depth reward differential
- **WHEN** a deeper run is completed
- **THEN** meta rewards MUST be proportionally greater, including a completion bonus not available on shorter runs

---

### Requirement: [HLD-RUN-004] Boss Structure
Each floor SHALL end with a boss encounter. Floors that are not the final floor of the chosen depth end with a mini-boss (guardian or echo). Only the final floor of the chosen depth has a true boss.

#### Scenario: 1-floor run boss
- **WHEN** the player chooses depth 1
- **THEN** the single floor's boss is a full encounter tuned for one floor of preparation

#### Scenario: 3-floor run mini-bosses
- **WHEN** the player chooses depth 3
- **THEN** floors 1 and 2 end with mini-bosses; only floor 3 ends with the true boss

---

### Requirement: [HLD-RUN-005] Room Composition
Floor room type ratios and mandatory placements (e.g. always end with Boss) SHALL be defined in data-driven FloorProfile resources, not hardcoded in NavigationModel. Different floor numbers load different profiles.

#### Scenario: Floor profile swap
- **WHEN** a new floor is added
- **THEN** adding a new FloorProfile resource is sufficient — no NavigationModel code change is required
