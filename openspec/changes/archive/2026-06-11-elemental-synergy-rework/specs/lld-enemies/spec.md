## Modified Requirements

### MODIFIED: [LLD-ENEMIES-014] Floor 3 Enemy — Fire Elemental

**Family:** Elemental. **Tags:** `elemental`, `elemental_fire`. Shared family omen card: see `LLD-OMEN-CARD-013` (Elemental Synergy — Fire). Resistance/vulnerability table: see `LLD-OMEN-CARD-013`.
**HP:** 14. **Attack:** 5 fire damage per turn. **Resistance:** Fire ×0.5. **Vulnerability:** Ice ×1.5.

`[OPEN·MVP3]` `[OPEN·MVP2]` Door symbol to be designed in a UI/art direction session.

**Encounter:** 1 Fire Elemental pre-elite; 2 Fire Elementals post-elite.

**Omen contributions:** `elemental_synergy_fire` (Elemental Synergy — Fire) ×1, `LLD-OMEN-CARD-001` (Burning) ×1.

#### Scenario: Fire Elemental ice vulnerability
- **WHEN** the player attacks a Fire Elemental with an ice weapon while Chilled is active on the elemental
- **THEN** the ice weapon deals ×1.5 damage

#### Scenario: Elemental Synergy (Fire) converts ice weapon to fire
- **WHEN** Elemental Synergy (Fire) is active on the player side against a Fire Elemental
- **THEN** the player receives a Type Convert StatusInstance with string_param `"fire"`; the player's ice weapon deals fire damage instead; the Fire Elemental's fire resistance (×0.5) applies

---

### MODIFIED: [LLD-ENEMIES-015] Floor 3 Enemy — Ice Elemental

**Family:** Elemental. **Tags:** `elemental`, `elemental_ice`. Shared family omen card: see `LLD-OMEN-CARD-013` (Elemental Synergy — Ice).
**HP:** 14. **Attack:** 4 ice damage per turn + applies Chilled to the player on each hit. **Resistance:** Ice ×0.5. **Vulnerability:** Fire ×1.5.

`[OPEN·MVP3]` `[OPEN·MVP2]` Door symbol to be designed in a UI/art direction session.

**Encounter:** 1 Ice Elemental pre-elite; 2 Ice Elementals post-elite.

**Omen contributions:** `elemental_synergy_ice` (Elemental Synergy — Ice) ×1, `LLD-OMEN-CARD-003` (Chilled) ×1.

#### Scenario: Chilled application on hit
- **WHEN** the Ice Elemental attacks the player
- **THEN** the player takes ice damage and the Chilled status is applied

#### Scenario: Self-created vulnerability
- **WHEN** the Ice Elemental has Chilled the player and then attacks again
- **THEN** the ice damage benefits from the player's Vulnerable (Ice) — a Vulnerable StatusInstance with string_param `"ice"` — at ×1.5

---

### MODIFIED: [LLD-ENEMIES-016] Floor 3 Enemy — Lightning Elemental

**Family:** Elemental. **Tags:** `elemental`, `elemental_lightning` (both phases — Sparks inherit the same tags). Shared family omen card: see `LLD-OMEN-CARD-013` (Elemental Synergy — Lightning).
**HP (Phase 1):** 18. **HP (Phase 2):** Two Sparks at 6 HP each.
**Attack (Phase 1):** 6 lightning per turn. **Attack (Phase 2):** 2 × 2 lightning each (4 total).
**Resistance:** Lightning ×0.5 (both phases). **Vulnerability:** None.

`[OPEN·MVP3]` `[OPEN·MVP2]` Door symbol to be designed in a UI/art direction session.

**Encounter:** 1 Lightning Elemental post-elite only.

**Two-phase:** Reaches 0 HP → splits into two Sparks (dead turn for enemy side). Sparks contribute no new omen cards.

**Omen contributions (Phase 1 only):** `elemental_synergy_lightning` (Elemental Synergy — Lightning) ×1, `LLD-OMEN-CARD-002` (Shocked) ×1.

#### Scenario: Two-phase transition
- **WHEN** the Lightning Elemental reaches 0 HP
- **THEN** combat does not end; two Sparks appear; the enemy side takes no action on the transition turn

#### Scenario: Sparks inherit no new omen cards
- **WHEN** the Lightning Elemental splits into Sparks
- **THEN** no new omen cards are added; the Phase 1 deck persists through Phase 2

#### Scenario: Resource management across phases
- **WHEN** the player transitions to Phase 2
- **THEN** all charges, consumables, and HP carry over unchanged
