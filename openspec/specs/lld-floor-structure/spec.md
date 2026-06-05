
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

### Requirement: [LLD-FLOOR-STRUCT-003] Room Type Distribution
Floor 3 SHALL target 50–75% combat rooms. Typical composition:

| Room type | Count | Notes |
|---|---|---|
| Standard combat | 4 | Core encounter type |
| Elite combat | 1 | Forced as one option at the Elite Gate (`LLD-FLOOR-BEATS-004`) |
| Temporary companion | 1 | Guaranteed — triggered by Worn Map (`LLD-FLOOR-BEATS-003`) |
| Non-combat events | 2–3 | Memory Fragment and Wandering Soul — varies by player choice |

Exact non-combat count varies within the pattern system constraints (see `lld-encounter-patterns`).

#### Scenario: Combat majority
- **WHEN** a Floor 3 run is completed
- **THEN** combat rooms (standard + elite) represent at least 50% and no more than 75% of the 9 rooms

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
Floor 3 structure (9 rooms, encounter pattern, forced beats) is the same for all vessel tiers. Enemy difficulty (HP, damage) scales per vessel tier; the layout system does not.

#### Scenario: Same structure for Tier 2 vessel
- **WHEN** a Tier 2 vessel (Drifter, Hedge Knight) plays Floor 3
- **THEN** the same 9-room structure and forced beats apply; enemies have higher HP and damage relative to Tier 1
