## ADDED Requirements

### Requirement: [LLD-FLOOR-DOOR-001] Two-Door Choice
Between each room the player SHALL face a two-door choice. Each door displays the identity of the encounter behind it. The player always chooses between two identified options — they are never forced into a single door except during the Worn Map companion beat (see `LLD-FLOOR-BEATS-003`).

#### Scenario: Two options always shown
- **WHEN** the player completes a room
- **THEN** exactly two doors are presented with their encounter identities shown before the player commits

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
Non-combat room types SHALL be shown by symbol on the door. The specific content within (which memory fragment outcome, which trade offers) is NOT revealed until the player enters.

#### Scenario: Non-combat content hidden
- **WHEN** a Memory Fragment is behind a door
- **THEN** the door shows the Memory Fragment symbol (`HLD-RUN-002`); whether it is Category A, B, or C is not disclosed

---

### Requirement: [LLD-FLOOR-DOOR-004] Forced-Combat Both-Doors Rule
When the encounter pattern system (`LLD-FLOOR-PATT-001`) determines the player must take a combat, both doors SHALL show combat encounters. The two enemy identities MUST differ from each other so the player has a meaningful choice within the constraint.

#### Scenario: Two distinct combat options
- **WHEN** Combat Lock triggers and both doors show combat
- **THEN** the two doors show different enemy types; the player still makes a meaningful choice about which fight to take

---

### Requirement: [LLD-FLOOR-DOOR-005] Non-Combat Symbol Visual Language
`[OPEN]` The visual language for non-combat door symbols is unresolved — to be confirmed in a UI/art direction session. See `HLD-RUN-002` for the full symbol table.

#### Scenario: [OPEN] Symbol design
- **WHEN** non-combat symbols are designed
- **THEN** each symbol is distinct, instantly readable, and thematically consistent with the purgatory visual language
