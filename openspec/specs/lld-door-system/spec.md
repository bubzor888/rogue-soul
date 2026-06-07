
## Purpose
Defines how doors between rooms present encounter choices to the player — the two-door selection model, what information is shown on each door type, and how the generation system shapes available options when pool types are exhausted.
## Requirements
### Requirement: [LLD-FLOOR-DOOR-001] Two-Door Choice
Between each room the player SHALL face a two-door choice. Each door displays the identity of the encounter behind it. The player always chooses between two identified options — unless an item explicitly forces a single-door beat (e.g. the Worn Map companion beat, see `LLD-FLOOR-BEATS-003`).

#### Scenario: Two options always shown
- **WHEN** the player completes a room and no item forces a single-door beat
- **THEN** exactly two doors are presented with their encounter identities shown before the player commits

#### Scenario: Item forces single-door exception
- **WHEN** the player has an item that triggers a forced single-door beat
- **THEN** only one door is presented for that room; the player enters without a choice

---

### Requirement: [LLD-FLOOR-DOOR-002] Combat Doors — Full Enemy Identity
Combat doors SHALL display the full enemy identity before the player commits. This is the exact enemy type — not a symbol, hint, or category.

Knowledge gained across attempts is a core part of the difficulty curve. A player on their fourth run knows which enemies are dangerous, which pair badly with their current items, and which can be handled efficiently.

#### Scenario: Enemy identity on combat door
- **WHEN** a combat room is behind a door
- **THEN** the door shows the specific enemy type (e.g. "Skeleton", "Zombie") before the player selects it

#### Scenario: Soul Codex reference
- **WHEN** the player has encountered an enemy before (recorded in Soul Codex, per `HLD-META-002`)
- **THEN** the Codex in-run bonus is available for that enemy; the door display helps the player recognise when their Codex knowledge applies

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

### Requirement: [LLD-FLOOR-DOOR-005] Non-Combat Symbol Visual Language
Non-combat door symbols SHALL use a consistent visual language confirmed in a UI/art direction session. `[OPEN·MVP2]` Visual language unresolved — to be confirmed before MVP2. See `HLD-RUN-002` for the full symbol table.

#### Scenario: [OPEN·MVP2] Symbol design
- **WHEN** non-combat symbols are designed
- **THEN** each symbol is distinct, instantly readable, and thematically consistent with the purgatory visual language

