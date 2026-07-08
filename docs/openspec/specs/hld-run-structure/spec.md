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

---

### Requirement: [HLD-DOOR-001] Two-Door Choice
Between each room the player SHALL face a two-door choice. Each door displays the identity of the encounter behind it. The player always chooses between two identified options — unless an item explicitly forces a single-door beat (e.g. the Worn Map companion beat, see `LLD-FLOOR-BEATS-003`).

#### Scenario: Two options always shown
- **WHEN** the player completes a room and no item forces a single-door beat
- **THEN** exactly two doors are presented with their encounter identities shown before the player commits

#### Scenario: Item forces single-door exception
- **WHEN** the player has an item that triggers a forced single-door beat
- **THEN** only one door is presented for that room; the player enters without a choice

### Requirement: [HLD-DOOR-002] Combat Doors — Full Enemy Identity
Combat doors SHALL display the full enemy identity before the player commits. This is the exact enemy type — not a symbol, hint, or category.

Knowledge gained across attempts is a core part of the difficulty curve. A player on their fourth run knows which enemies are dangerous, which pair badly with their current items, and which can be handled efficiently.

#### Scenario: Enemy identity on combat door
- **WHEN** a combat room is behind a door
- **THEN** the door shows the specific enemy type (e.g. "Skeleton", "Zombie") before the player selects it

#### Scenario: Soul Codex reference
- **WHEN** the player has encountered an enemy before (recorded in Soul Codex, per `HLD-META-002`)
- **THEN** the Codex in-run bonus is available for that enemy; the door display helps the player recognise when their Codex knowledge applies

---

### Requirement: [HLD-DOOR-003] Non-Combat Doors — Symbol Only
Non-combat room types SHALL be shown by symbol on the door. Different non-combat types use distinct symbols (e.g. Memory Fragment and Wandering Soul are visually distinguishable from each other). The specific content within a room — which memory fragment outcome, which trade offers, which subcategory — is NOT revealed until the player enters.

#### Scenario: Non-combat type visible, content hidden
- **WHEN** a Memory Fragment is behind a door
- **THEN** the door shows the Memory Fragment symbol (`HLD-RUN-002`); whether it is Category A, B, or C is not disclosed

#### Scenario: Different non-combat types are distinguishable
- **WHEN** one door shows a Memory Fragment and another shows a Wandering Soul
- **THEN** each door displays a distinct symbol so the player can tell the types apart before committing

---

### Requirement: [HLD-DOOR-004] Pool Exhaustion Both-Doors Rule
When the encounter generation system removes a room type from the available pool, the exhausted type SHALL NOT appear behind either door. The remaining doors are filled from whatever types are still in the pool — which may result in both doors showing the same room type.

#### Scenario: Both doors same type after exhaustion
- **WHEN** a room type reaches its segment cap and is removed from the pool
- **THEN** neither door shows that type; if only one type remains available, both doors show that type with different specific content (e.g. two different enemy identities for combat rooms)

#### Scenario: Both doors combat after non-combat exhaustion
- **WHEN** all non-combat encounter types have reached their caps for the current segment
- **THEN** both doors show combat encounters with different enemy identities

---

### Requirement: [HLD-DOOR-005] Non-Combat Symbol Visual Language
Non-combat door symbols SHALL use a consistent visual language confirmed in a UI/art direction session. `[OPEN·MVP2]` Visual language unresolved — to be confirmed before MVP2. See `HLD-RUN-002` for the full symbol table.

#### Scenario: Symbol design
- **WHEN** non-combat symbols are designed
- **THEN** each symbol is distinct, instantly readable, and thematically consistent with the purgatory visual language

---

### Requirement: [HLD-RUN-007] Item Burden Score
The run state SHALL track a persistent integer measuring the soul's accumulated burden from items carried. This score persists across floors with no reset and is initialized at run start from the vessel's starting loadout.

**Accumulation rules:**

| Event | Delta |
|---|---|
| Run starts — per starting item in vessel loadout | +1 |
| Any item acquired during the run | +2 |
| Any item fully spent (consumable used, durability exhausted to 0, or item discarded) | −1 |

Starting items are valued at +1 rather than +2 so that shedding a starting item yields net zero — the soul arrived with it and released it entirely, leaving no burden. A floor-acquired item that is fully spent yields net +1.

The score is not directly visible to the player as a number. Its effects are communicated through encounter behavior and narrative framing at key thresholds. Systems that consume this score (such as boss encounters) define their own tier brackets and behavior in LLD.

#### Scenario: Score initialized from starting items
- **WHEN** a run begins with a vessel that has 2 starting items
- **THEN** the burden score is initialized to 2 (1 per starting item)

#### Scenario: Item acquired increases score
- **WHEN** the player takes any item from a loot choice, trade, or other acquisition during the run
- **THEN** the burden score increases by 2

#### Scenario: Item fully spent decreases score
- **WHEN** a consumable is used, a durability item is exhausted to 0 charges, or an item is discarded via an encounter effect
- **THEN** the burden score decreases by 1

#### Scenario: Starting item shed yields net zero
- **WHEN** a vessel's starting item (initialized at +1) is fully spent or discarded
- **THEN** the burden score decreases by 1; the net contribution of that item across the run is 0

#### Scenario: Score persists across floors
- **WHEN** the player completes a floor and transitions to the next
- **THEN** the burden score carries forward unchanged; no reset occurs

