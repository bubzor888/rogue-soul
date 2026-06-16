## MODIFIED Requirements

### Requirement: [LLD-FLOOR-DOOR-001] Two-Door Choice
Between each room the player SHALL face a two-door choice. Each door displays the identity of the encounter behind it. The player always chooses between two identified options — unless an item explicitly forces a single-door beat (e.g. the Worn Map companion beat, see `LLD-FLOOR-BEATS-003`).

#### Scenario: Two options always shown
- **WHEN** the player completes a room and no item forces a single-door beat
- **THEN** exactly two doors are presented with their encounter identities shown before the player commits

#### Scenario: Item forces single-door exception
- **WHEN** the player has an item that triggers a forced single-door beat
- **THEN** only one door is presented for that room; the player enters without a choice

---

### Requirement: [LLD-FLOOR-DOOR-003] Non-Combat Doors — Symbol Only
Non-combat room types SHALL be shown by symbol on the door. Different non-combat types use distinct symbols (e.g. Memory Fragment and Wandering Soul are visually distinguishable from each other). The specific content within a room — which memory fragment outcome, which trade offers, which subcategory — is NOT revealed until the player enters.

#### Scenario: Non-combat type visible, content hidden
- **WHEN** a Memory Fragment is behind a door
- **THEN** the door shows the Memory Fragment symbol (`HLD-RUN-002`); whether it is Category A, B, or C is not disclosed

#### Scenario: Different non-combat types are distinguishable
- **WHEN** one door shows a Memory Fragment and another shows a Wandering Soul
- **THEN** each door displays a distinct symbol so the player can tell the types apart before committing

---

### Requirement: [LLD-FLOOR-DOOR-004] Pool Exhaustion Both-Doors Rule
When the encounter generation system (`LLD-FLOOR-PATT-001`, `LLD-FLOOR-PATT-003`) removes a room type from the available pool, the exhausted type SHALL NOT appear behind either door. The remaining doors are filled from whatever types are still in the pool — which may result in both doors showing the same room type.

#### Scenario: Both doors same type after exhaustion
- **WHEN** a room type reaches its segment cap and is removed from the pool
- **THEN** neither door shows that type; if only one type remains available, both doors show that type with different specific content (e.g. two different enemy identities for combat rooms)

#### Scenario: Both doors combat after non-combat exhaustion
- **WHEN** all non-combat encounter types have reached their caps for the current segment
- **THEN** both doors show combat encounters with different enemy identities
