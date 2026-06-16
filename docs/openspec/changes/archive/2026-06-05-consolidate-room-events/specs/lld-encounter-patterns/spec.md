## ADDED Requirements

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
