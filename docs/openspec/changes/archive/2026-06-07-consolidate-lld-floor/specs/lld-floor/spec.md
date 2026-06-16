## ADDED Requirements

### Requirement: [LLD-FLOOR-STRUCT-001] Floor 3 Room Count
Floor 3 — The Threshold — SHALL contain exactly 9 rooms before the Judge. This structure is consistent across all vessel tiers. Enemy difficulty scales per vessel tier; the floor layout does not change.

#### Scenario: 9 rooms before Judge
- **WHEN** Floor 3 is generated for any vessel
- **THEN** the player navigates exactly 9 rooms before the Judge encounter

---

### Requirement: [LLD-FLOOR-STRUCT-002] Run Length Target
A Floor 3 run SHALL target approximately 30 minutes for an average-speed player.

**Time breakdown (Pilgrim, tier 1):**

| Element | Count | Estimated time |
|---|---|---|
| Standard combats | 4 | ~12 min |
| Elite combat | 1 | ~4 min |
| Judge boss | 1 | ~6 min |
| Post-combat loot choices | 5 | ~2.5 min |
| Non-combat rooms | 2–3 | ~2–3 min |
| Navigation (door choices) | 9 | ~3 min |
| **Total** | | **~30 min** |

**Combat duration assumption:** Standard combat 3–5 turns (~2–3 min). Two omen cycles typical. Elite combat 4–6 turns (~4 min).

#### Scenario: Run length variance
- **WHEN** a player makes different door choices (e.g. more non-combat rooms)
- **THEN** run length varies naturally — skipping combat shortens the run; choosing extra combat lengthens it

---

### Requirement: [LLD-FLOOR-STRUCT-004] Difficulty Target
The Pilgrim (tier 1) Floor 3 run SHALL be beatable by an StS-familiar player in 3–5 attempts.

**Attempt progression intent:**
- Attempt 1: Probable death, learns the Judge exists
- Attempts 2–3: Better resource management, Judge pattern becoming readable
- Attempts 4–5: Realistic completion window

#### Scenario: Judge is learnable not random
- **WHEN** a player faces the Judge after multiple attempts
- **THEN** the Judge's mechanics should feel readable and skill-testable — not random

---

### Requirement: [LLD-FLOOR-STRUCT-005] Consistent Floor Across Tiers
Floor 3 structure (9 rooms, encounter pattern, forced beats) SHALL be the same for all vessel tiers. Enemy difficulty (HP, damage) scales per vessel tier; the layout system does not.

#### Scenario: Same structure for Tier 2 vessel
- **WHEN** a Tier 2 vessel (Drifter, Hedge Knight) plays Floor 3
- **THEN** the same 9-room structure and forced beats apply; enemies have higher HP and damage relative to Tier 1

---

### Requirement: [LLD-FLOOR-STRUCT-006] Nine-Room Layout
Floor 3 SHALL be structured as exactly 9 rooms in the following fixed sequence: 4 pre-elite rooms, then the Elite Gate (1 room — see `LLD-FLOOR-BEATS-004`), then 4 post-elite rooms, then the Judge. The counter-based generation system (see `LLD-FLOOR-PATT-001`) operates within this sequence; it does not change the sequence.

#### Scenario: Pre-elite phase length
- **WHEN** Floor 3 is generated
- **THEN** rooms 1–4 are pre-elite rooms; no Elite Gate can appear before room 4 is complete

#### Scenario: Post-elite phase length
- **WHEN** the player completes the Elite Gate
- **THEN** exactly 4 rooms remain before the Judge encounter

---

### Requirement: [LLD-FLOOR-PATT-001] Counter-Based Generation System
Floor 3 room generation SHALL use two counters to constrain room type availability rather than a fixed room sequence:
- **Combats taken** — increments each time the player completes a combat room
- **Events taken** — increments each time the player completes a non-combat room

These counters enforce the floor's required beats invisibly. The player never sees the counters; constraints feel like the natural shape of the floor rather than a rails system.

#### Scenario: Counter increments on completion
- **WHEN** the player completes any combat room
- **THEN** the combats-taken counter increments by 1

#### Scenario: Both doors can be combat
- **WHEN** the pattern system determines the player must take a combat
- **THEN** both doors show combat encounters with different enemy identities — the player chooses which fight, not whether to fight

---

### Requirement: [LLD-FLOOR-PATT-002] No Guaranteed Rest Room
There SHALL be no guaranteed rest or recovery room anywhere on Floor 3. Healing is only available if the player encounters a Wandering Soul through normal generation. Resource management across the full floor is the intended pressure.

#### Scenario: No forced recovery
- **WHEN** Floor 3 is generated
- **THEN** no rest or mending room is inserted at any fixed position; healing depends on what room types the player encounters

---

### Requirement: [LLD-FLOOR-PATT-003] Non-Combat Encounter Caps
Non-combat encounter types SHALL be capped per floor segment (pre-elite and post-elite) to shape pacing:

| Encounter type | Pre-elite cap | Post-elite cap | Floor total |
|---|---|---|---|
| Memory Fragment | 1–2 | 1–2 | Max 3 |
| Wandering Soul | 0–1 | Exactly 1 | 1–2 |
| Temporary companion | 1 across all sources | — | Max 1 |

Once an encounter type reaches its cap for a segment, it is removed from the generation pool for that segment.

#### Scenario: Memory Fragment cap reached
- **WHEN** the player has completed 2 Memory Fragments in the pre-elite phase
- **THEN** no further Memory Fragment doors appear in the pre-elite phase

---

### Requirement: [LLD-FLOOR-PATT-004] Memory Fragment Room Type
Memory Fragment rooms SHALL present a narrative/lore event in which the soul recovers a piece of its own history. Room content is seeded from `EncounterFactory` using the room's seed_offset. Full design: see `lld-memory-fragments`.

#### Scenario: Memory Fragment room is non-combat
- **WHEN** the player enters a Memory Fragment room
- **THEN** no combat occurs; the player engages with a narrative/lore event

---

### Requirement: [LLD-FLOOR-PATT-005] Wandering Soul Room Type
Wandering Soul rooms SHALL present a trading opportunity — a lost spirit that remembers what it had in life. The player may trade items from the floor's item pools. Full design: see `lld-wandering-soul`.

#### Scenario: Wandering Soul room is non-combat
- **WHEN** the player enters a Wandering Soul room
- **THEN** no combat occurs; the player is presented with trade options from the floor's item pools

---

### Requirement: [LLD-FLOOR-BEATS-001] Beat 1 — Opening (Rooms 1–2)
The first two rooms SHALL have no counter constraints applied. Any room type may appear behind either door. Full player agency at the start of the run.

#### Scenario: Opening rooms unconstrained
- **WHEN** generating rooms 1 and 2
- **THEN** all room types in their respective pools are available; no combat lock applies

---

### Requirement: [LLD-FLOOR-BEATS-002] Beat 2 — Combat Lock
When the player has taken 2 or more event rooms with fewer than 2 combats completed, both doors SHALL show combat encounters. The player chooses which fight, not whether to fight.

`[OPEN·MVP1]` Exact counter thresholds (currently: ≥2 events, <2 combats) to be tuned during playtesting.

#### Scenario: Combat Lock triggers
- **WHEN** the player has completed 2 non-combat rooms and only 0–1 combat rooms
- **THEN** both door options are combat encounters with different enemy identities

---

### Requirement: [LLD-FLOOR-BEATS-003] Beat 3 — Worn Map Companion (Room 4)
The Worn Map starting item (see `LLD-ITEMS-004`) counts down across encounter types. After 3 encounters, room 4 SHALL become a temporary companion encounter. The two-door choice is replaced by a single door for this room only. The Worn Map is removed from inventory after triggering.

Companion identity is drawn from the Floor 3 temporary companion pool.

`[OPEN·MVP1]` Temporary companion pool for Floor 3 to be defined during companion design session.

#### Scenario: Room 4 forced companion
- **WHEN** the player has completed exactly 3 encounters of any type
- **THEN** the next room (room 4) is a companion encounter regardless of player door choices up to that point

#### Scenario: Worn Map removal
- **WHEN** the companion encounter resolves
- **THEN** the Worn Map is removed from the player's inventory

---

### Requirement: [LLD-FLOOR-BEATS-004] Beat 4 — Elite Gate (Rooms 5–6 Range)
One door SHALL show an elite combat encounter; the other door SHALL show an Anomaly encounter. This is a forced structural beat — not drawn from the general pool. Full design in `lld-elite-gate`.

#### Scenario: Elite Gate placement
- **WHEN** the floor reaches the rooms 5–6 range with the combat counter and event counter in the appropriate state
- **THEN** the two-door choice presents elite combat vs Anomaly — regardless of what the player has built

---

### Requirement: [LLD-FLOOR-BEATS-005] The Judge (Final Encounter)
The Judge SHALL appear as the final encounter after all 9 rooms are complete. He is the same entity across all vessel tiers; difficulty scales with tier. Full design deferred — see `LLD-ENEMIES-010`.

#### Scenario: Judge always at end
- **WHEN** the player completes room 9
- **THEN** the Judge encounter begins immediately with no door choice
