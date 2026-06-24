## Purpose
Defines the compositional scoring system used to assign relative values to all items in the game. Scores are used by the Wandering Soul trade generation system and Memory Fragment Category A/C scenario design to determine fair and unfair trade pairings. Items are scored on two independent scales — Durability and Consumable — which are not directly comparable.
## Requirements
### Requirement: [LLD-IR-001] Two Independent Scales
All items SHALL belong to exactly one scoring scale. The two scales are not directly comparable and SHALL NOT share a conversion ratio.

| Scale | Item types | Reference point |
|---|---|---|
| **Durability** | Attack (Durability), Support (Durability) | Score 49 — see `LLD-IR-008` |
| **Consumable** | Consumable | Score 14 — see `LLD-IR-008` |

Support (Durability) items sit on the Durability scale because they compete directly with weapons as loot rewards.

Trades SHALL pair items from the same scale. Cross-category trades (Durability item for Consumable) are designer-authored exceptions, not formula-generated (see `HLD-ITEMS-010`).

#### Scenario: Support item on Durability scale
- **WHEN** a support durability item's score is needed for trade generation
- **THEN** it is compared against the Durability scale reference point (49), not the Consumable reference

#### Scenario: No cross-scale formula
- **WHEN** the trade generation system pairs items
- **THEN** it never uses a conversion ratio between Durability and Consumable scores; cross-category trades are hand-authored

---

### Requirement: [LLD-IR-002] Scoring Principles
Item scores SHALL be calculated compositionally. Each item's score SHALL be the sum of its property scores, with each property scored independently.

Scores SHALL reflect **competent play value** — how much the item is worth when used at a reasonably optimised time, not at its ceiling and not at its floor. Specific baseline assumptions:

- Status consumables are scored as though paired with a relevant attack on the same turn. The default paired action is Throw Rock (score 6) unless the consumable is explicitly designed for a specific weapon.
- Branching items (different effects depending on target state) are scored as the average of their branches, each scored independently.
- Healing is scored as damage negated. Excess healing beyond the current HP deficit is not counted.
- Timer-2 is the statistical baseline for all status scores. The omen timer distribution is 25% / 50% / 25% for values 1 / 2 / 3; timer-2 is the most probable outcome.
- Structural and passive items whose value is not expressible through damage, healing, charges, or status properties receive manually assigned scores. Manual scores are recorded with rationale in `LLD-IR-011`.

All current scores are pre-playtest placeholders expressing correct relative relationships. Absolute values are expected to shift during playtesting.

#### Scenario: Compositional scoring
- **WHEN** an item deals damage and applies a status
- **THEN** its score is the sum of the damage score and the status score (before applying the charges multiplier)

#### Scenario: Branching average
- **WHEN** an item has two branches depending on target state
- **THEN** each branch is scored independently and the scores are averaged

---

### Requirement: [LLD-IR-003] Property Score Table
The following property scores SHALL apply per use (one charge). All values are per-use before the charges multiplier (`LLD-IR-004`) is applied.

| Property | Score | Notes |
|---|---|---|
| Damage (physical) | 2 per damage unit | Baseline damage type |
| Damage (elemental) | 2.4 per damage unit | 1.2× premium over physical |
| Healing | 2 per HP restored | Same scale as damage; no over-heal |

**Damage unit reference:**

| Source | Damage | Per-use score (single target, 1 charge) |
|---|---|---|
| Throw Rock (default strike — always free, never an item) | 3 | 6 |
| Normal drop weapon baseline | 7 | 14 |
| Elite drop weapon baseline | 9 | 18 |

The Throw Rock value (score 6) is the floor. Any item scoring below 6 per use provides less value per use than the free default strike and requires design justification.

#### Scenario: Physical vs elemental damage score
- **WHEN** scoring two weapons with identical damage values, one physical and one elemental
- **THEN** the elemental weapon's per-use score is 1.2× the physical weapon's per-use score

---

### Requirement: [LLD-IR-004] Charges Multiplier
The charges multiplier SHALL be applied to a durability item's per-use score to produce its total score. The multiplier is dampened — later charges are worth less than earlier ones to reflect the reliability discount of charges that may not be used before the item is replaced or the run ends.

| Charges | Multiplier |
|---|---|
| 1 | 1.0× |
| 2 | 1.7× |
| 3 | 2.3× |
| 4 | 2.8× |
| 5 | 3.2× |
| 6 | 3.5× |
| 7 | 3.8× |
| 8 | 4.1× |
| 9 | 4.4× |
| 10 | 4.7× |
| Each charge beyond 10 | +0.2× |

The charges multiplier does NOT apply to the Consumable scale. Consumable items always score at 1.0× (single use).

#### Scenario: Charges multiplier applied to durability item
- **WHEN** calculating the total score of a 6-charge weapon with per-use score 14
- **THEN** the total score is 14 × 3.5 = 49

#### Scenario: Charges multiplier not applied to consumables
- **WHEN** calculating the score of a consumable
- **THEN** the charges multiplier is not used; the total score equals the per-use score

---

### Requirement: [LLD-IR-005] Scope Modifiers
Scope modifiers SHALL be applied to the per-use score before the charges multiplier. They apply to both scales.

| Scope | Modifier | Notes |
|---|---|---|
| Single target | 1.0× | Baseline |
| +1 target (arc / chain) | See below | Secondary hit scored separately at ×0.5 |
| AoE (all enemies) | 1.75× | Scored at 2-enemy average; discounted for single-enemy encounters |

**+1 target (arc / chain) method:**
The primary hit is scored at single-target (1.0×). The secondary hit is scored at ×0.5 of its own damage contribution:

```
secondary_score = secondary_damage × damage_type_rate × 0.5
per_use_score   = primary_score + secondary_score
```

The 0.5 multiplier rests on the same frequency assumption as the AoE modifier: encounters have a second valid target approximately 50% of the time. If floor design confirms a different ratio, both modifiers should be revised together.

**AoE rationale:** Scoring at 1.75× rather than 2× accounts for single-enemy encounters where AoE provides no advantage over single target. The 1.75× value was calibrated from pre-MVP2 headless benchmarks: AoE weapons outperformed equal-score single-target weapons by ~15%, correcting the previous 1.5× multiplier upward.

#### Scenario: AoE scope applied
- **WHEN** scoring an AoE weapon with 4 physical damage per hit
- **THEN** per-use score = 4 × 2.0 × 1.75 = 14 (not 4 × 2.0 × 2.0 = 16)

#### Scenario: Arc secondary hit scored at 0.5
- **WHEN** scoring a weapon with 9 primary lightning damage and a 4-damage lightning arc
- **THEN** per-use score = (9 × 2.4) + (4 × 2.4 × 0.5) = 21.6 + 4.8 = 26.4

---

### Requirement: [LLD-IR-006] Status Effect Base Scores
Status effects SHALL be scored at timer-2 as the statistical baseline. Per-tick statuses are scored across 2 ticks. Shift-triggered statuses are scored as the value of one free attack turn enabled or negated at timer-2.

Scores are per-application (one use on one target).

| Status | Base Score | Trigger | Rationale |
|---|---|---|---|
| Vulnerable (Physical) | 12 | Passive | Amplifies default damage type; almost always relevant; persists for full cycle |
| Shocked | 10 | Shift | One free attack turn enabled at timer-2; delayed but reliable |
| Exposed | 10 | Shift | Delivers Vulnerable (Physical) after a cycle delay; highly relevant given physical is the default damage type |
| Poisoned | 9 | Per-tick | Escalating DoT; 2 ticks at timer-2 produce strong total damage with no vulnerability dependency |
| Burning | 8 | Per-tick | Flat fire DoT across 2 ticks at timer-2; fire-specific so requires elemental commitment for full combo value |
| Emboldened (Physical) | 8 | Passive | Significant flat bonus to outgoing physical damage; lasts until omen cycle changes |
| Bleed | 7 | Per-tick | Decaying DoT; timer-2 produces less total damage than Burning due to halving mechanic; physical only |
| Mending | 7 | Per-tick | 2 ticks of healing at timer-2; scored as damage negated |
| Vulnerable (Elemental) | 7 | Passive | Same mechanic as Vulnerable (Physical) but three separate types (Fire / Lightning / Ice) lower average relevance per type |
| Chilled | 6 | Per-tick | Damage reduction, not damage dealing; defensive utility with indirect offensive value |
| Hardened | 6 | Per-tick | Per-tick absorption that resets each tick; reliable but ceiling lower than Mending at timer-2 |
| Emboldened (Elemental) | 5 | Passive | Elemental damage multiplier; requires matching element commitment |
| Frenzied | 5 | Passive | Double-edged; risky to apply to player side |
| Type Convert | 4 | Passive | Situational; typically a penalty when it lands on player side |

Emboldened (Physical) and Emboldened (Elemental) are currently sourced from enemies and the omen system, not items. Scores are included for future item design reference.

#### Scenario: Timer-2 baseline for per-tick status
- **WHEN** scoring a per-tick status (Poisoned, Burning, Bleed, Mending, Chilled, Hardened)
- **THEN** the score reflects 2 ticks of the effect, not 1 or 3

#### Scenario: Vulnerable (Physical) scores higher than Vulnerable (Elemental)
- **WHEN** comparing Vulnerable (Physical) and Vulnerable (Fire) as item properties
- **THEN** Vulnerable (Physical) scores 12 and Vulnerable (Fire) scores 7; the gap reflects lower average relevance of element-specific types

---

### Requirement: [LLD-IR-007] Scoring Methods
Items SHALL be scored using one of the following methods. The method used for each item is recorded in `LLD-IR-011`.

**Method 1 — Damage item (Attack Durability):**
```
Score = (damage_per_hit × damage_type_rate × scope_modifier) × charges_multiplier
```

**Method 2 — Status consumable:**
```
Score = status_base_score + paired_action_score
```
Paired action defaults to Throw Rock (6). Substitute the weapon's per-use score if the consumable is designed for a specific weapon.

**Method 3 — Branching item:**
Score each branch independently (using the appropriate method), average the results, then add paired action score if consumable.

**Method 4 — Multi-effect item:**
```
Score = (sum_of_all_property_scores × scope_modifier) × charges_multiplier
```

**Method 5 — Healing consumable:**
```
Score = (HP_restored × 2) + paired_action_score
```

**Method 6 — Support durability item (scorable status):**
```
Score = status_base_score × charges_multiplier
```
Use when the support item's effect is expressible as a status application per encounter.

**Method 7 — Structural / passive item (manual):**
Score is manually assigned. The assigned score and rationale are recorded in `LLD-IR-011`. Manual scores are benchmarked against the relevant scale reference point (`LLD-IR-008`).

#### Scenario: Method 1 example — Walking Staff
- **WHEN** scoring the Walking Staff (6 physical, single target, 6 charges)
- **THEN** per-use score = 6 × 2.0 × 1.0 = 12; total score = 12 × 3.5 = 42

#### Scenario: Method 2 example — Fire Bomb
- **WHEN** scoring Fire Bomb (applies Burning, single use)
- **THEN** score = Burning (8) + Throw Rock (6) = 14

#### Scenario: Method 3 example — Combustible Oil
- **WHEN** scoring Combustible Oil (branching: Vulnerable Fire vs fire damage burst)
- **THEN** Branch A (not Burning): Vulnerable (Fire) = 7; Branch B (Burning): 6 fire damage × 2.4 = 14.4; average = (7 + 14.4) / 2 = 10.7 → 11; total = 11 + 6 = 17

---

### Requirement: [LLD-IR-008] Abstract Reference Items
Two abstract items SHALL serve as calibration anchors for the scoring system. No real item needs to match either score exactly; they are design benchmarks.

**Durability Reference — Score 49:**

| Property | Value |
|---|---|
| Damage per hit | 7 (physical) |
| Scope | Single target |
| Charges | 6 |
| Score | (7 × 2.0 × 1.0) × 3.5 = **49** |

Items scoring significantly below 49 are weak relative to a normal drop weapon. Items scoring significantly above 49 are strong. Support durability items are expected to score below 49 — their utility compensates for lower raw score. Elite weapons are expected to score significantly above 49.

**Consumable Reference — Score 14:**

| Property | Value |
|---|---|
| Status applied | Mid-tier status (base score 7) |
| Paired action | Throw Rock (score 6) |
| Score | 7 + 6 = **14** |

Consumables scoring below 14 are weak relative to the average. Consumables scoring above 14 are strong. The current consumable pool runs roughly 10–20.

#### Scenario: Reference point as benchmark
- **WHEN** evaluating whether a new item is balanced for normal or elite placement
- **THEN** the item's score is compared against the relevant reference point; a durability item scoring 70+ is a strong elite candidate; one scoring below 35 is notably weak

---

### Requirement: [LLD-IR-009] HP Conversion
Items can be traded for HP (or HP for items) in Wandering Soul encounters. Item scores SHALL translate to HP trade values using the following bucket tables. Two separate tables exist — one per scale.

HP amounts are `[OPEN·MVP2]` — values are set once vessel HP pools and average incoming damage per encounter are established through playtesting. Bucket thresholds may also shift once real item scores are validated.

**Durability Scale — HP Conversion:**

| Durability Score | HP Trade Value |
|---|---|
| 1–25 | Low HP `[OPEN·MVP2]` |
| 26–49 | Medium HP `[OPEN·MVP2]` |
| 50–75 | High HP `[OPEN·MVP2]` |
| 76–100 | Very High HP `[OPEN·MVP2]` |
| 101+ | Maximum HP `[OPEN·MVP2]` |

**Consumable Scale — HP Conversion:**

| Consumable Score | HP Trade Value |
|---|---|
| 1–10 | Low HP `[OPEN·MVP2]` |
| 11–14 | Medium HP `[OPEN·MVP2]` |
| 15–18 | High HP `[OPEN·MVP2]` |
| 19+ | Very High HP `[OPEN·MVP2]` |

HP conversion is vessel-agnostic at MVP. All vessels use the same conversion tables. Per-vessel HP tuning may be introduced post-MVP if playtesting reveals significant differences in how HP trades feel between vessels.

#### Scenario: Durability item-for-HP trade
- **WHEN** the player trades a durability item with score 42 for HP
- **THEN** the HP restoration uses the 26–49 bucket (Medium HP)

#### Scenario: Consumable item-for-HP trade
- **WHEN** the player trades a consumable with score 18 for HP
- **THEN** the HP restoration uses the 15–18 bucket (High HP)

---

### Requirement: [LLD-IR-010] Trade Fairness Tolerance
Trade fairness tolerance SHALL apply independently within each scale. Cross-category trades are not subject to this formula (see `HLD-ITEMS-010`).

**Same-category fair trade (±20%):**
Two items are considered a fair trade when the score gap is no greater than 20% of the higher-scored item.

```
fair = |score_A - score_B| ≤ 0.20 × max(score_A, score_B)
```

**Category C unfair trade (50%+ above fair window):**
A Category C Memory Fragment scenario presents Option 1 at a price that is at least 50% above what the player receives in return. If the fair tolerance is ±20%, Option 1's cost should be at least 70% above the reward's score.

#### Scenario: Fair trade determination
- **WHEN** the trade generation system pairs a durability item scoring 40 with one scoring 49
- **THEN** the gap is 9, which is 18% of 49 (< 20%) — this is a fair trade

#### Scenario: Unfair trade determination
- **WHEN** the trade generation system evaluates a pair scoring 20 and 49
- **THEN** the gap is 29, which is 59% of 49 (> 20%) — this is not a fair trade

#### Scenario: Category C price threshold
- **WHEN** a Category C scenario is authored with Option 1 requiring the player to give a durability item scoring 49
- **THEN** the player's reward SHALL score no more than ~29 (49 ÷ 1.7 ≈ 29), making the cost ~70% above fair value

---

### Requirement: [LLD-IR-011] Item Score Table
All items in the game SHALL have an assigned score recorded in this table. Scores are pre-playtest placeholders. Items marked `[REVIEW]` scored notably outside the expected range for their drop pool and should be prioritised for playtesting scrutiny.

**Scoring method key:** D1 = Damage; D2 = Status consumable; D3 = Branching; D4 = Multi-effect; D5 = Healing consumable; D6 = Support (status); D7 = Manual. See `LLD-IR-007`.

---

#### Durability Scale — Starting Items

| Item | Vessel | Method | Calculation | Score | vs Ref (49) |
|---|---|---|---|---|---|
| Walking Staff | Pilgrim | D1 | (6 × 2.0 × 1.0) × 3.5 | 42 | Below — expected for starting weapon |
| Worn Map | Pilgrim | D7 | 3-charge countdown; forces companion encounter; high run value | 28 | Below — utility item, acceptable |
| Battered Sword | Hedge Knight | D1 | (7 × 2.0 × 1.0) × 3.5 | 49 | At ref — tuned to reference after pre-MVP2 benchmark |
| Iron Pendant | Hedge Knight | D7 | Replaces active omen with Fortified; 2 charges; significant defensive swing | 30 | Below — reactive utility, acceptable |
| Lucky Paw | Drifter | D7 | Passive evasion vs physical per combat; 2 encounter charges; pending evasion % `[OPEN·MVP3]` | 18 | Well below — may be undervalued; review once evasion % confirmed |

#### Durability Scale — Normal Drop Pool (Floor 3)

| Item | Method | Calculation | Score | vs Ref (49) |
|---|---|---|---|---|
| Cracked Cudgel | D1 | (9 × 2.0 × 1.0) × 2.3 | 41 | Slightly below — burst trade-off |
| Rope Flail | D1 (AoE) | (5 × 2.0 × 1.75) × 3.5 | 61 | Above ref — AoE premium after multiplier calibration |
| Battered Sword | D1 | (7 × 2.0 × 1.0) × 3.5 | 49 | At ref — tuned to reference after pre-MVP2 benchmark |
| Ember Shard | D1 (elemental) | (7 × 2.4 × 1.0) × 2.3 | 39 | Below — low charge count limits elemental upside |
| Spark Rod | D1 (elemental) | (7 × 2.4 × 1.0) × 2.3 | 39 | Below — same as Ember Shard |
| Frost Sliver | D1 (elemental) | (7 × 2.4 × 1.0) × 2.3 | 39 | Below — same as Ember Shard |
| Small Amethyst | D7 | Clears Shocked / Chilled / Vulnerable (Physical); 1 charge; reactive | 16 | Well below — single charge limits value |

#### Durability Scale — Elite Drop Pool (Floor 3)

| Item | Method | Calculation | Score | vs Ref (49) |
|---|---|---|---|---|
| Iron Maul | D1 | (10 × 2.0 × 1.0) × 3.5 | 70 | Above — expected for elite |
| Spiked Chain | D1 (AoE) | (6 × 2.0 × 1.75) × 4.1 | 86 | Well above — expected for elite AoE |
| Soldier's Blade | D1 | (9 × 2.0 × 1.0) × 4.7 | 85 | Well above — expected for elite |
| Smoldering Brand | D1 (elemental) | (9 × 2.4 × 1.0) × 4.1 | 89 | Well above — expected for elite |
| Arc Wand | D1 (+1 target) | ((9 × 2.4) + (4 × 2.4 × 0.5)) × 4.1 | 108 | Significantly above — premium unique-mechanic elite `[REVIEW]` |
| Glacial Brand | D1 (elemental) | (9 × 2.4 × 1.0) × 4.1 | 89 | Well above — expected for elite |
| Medium Amethyst | D7 | Clears Shocked / Chilled / Vulnerable (Physical); 2 charges; reactive | 28 | Below — reactive utility, acceptable |

---

#### Consumable Scale — Starting Items

| Item | Vessel | Method | Calculation | Score | vs Ref (14) |
|---|---|---|---|---|---|
| Spoiled Potion | Pilgrim | D2 | Poisoned (9) + Throw Rock (6) | 15 | At ref — appropriate |
| Pocket of Sand | Drifter | D7 | Escape combat; prevents death; no rewards; single use | 20 | Above — high unique utility |
| Loaf of Bread | Drifter | D7 (floor-bound) | Floor-bound penalty applied; moderate heal value | 12 | Slightly below — floor-bound limits value |
| Cheap Flask | Hedge Knight | D2 | Emboldened Physical (8) + Throw Rock (6) | 14 | At ref — appropriate |

#### Consumable Scale — Normal Drop Pool (Floor 3)

| Item | Method | Calculation | Score | vs Ref (14) |
|---|---|---|---|---|
| Fire Bomb | D2 | Burning (8) + Throw Rock (6) | 14 | At ref |
| Ointment | D7 | Clears Burning or Poisoned; reactive; value depends on threat | 10 | Below — reactive, acceptable |
| Combustible Oil | D3 | ((Vuln Fire 7 + 6 fire × 2.4) / 2) + 6 = 11 + 6 | 17 | Above ref |
| Hardening Resin | D2 | Hardened (6) + Throw Rock (6) | 12 | Slightly below ref |
| Frost Shard | D2 | Chilled (6) + Throw Rock (6) | 12 | Slightly below ref |

#### Consumable Scale — Elite Drop Pool (Floor 3)

| Item | Method | Calculation | Score | vs Ref (14) |
|---|---|---|---|---|
| Poultice | D5 | Mending (7) + Throw Rock (6) | 13 | At ref — healing items score conservatively |
| Brittle Charm | D2 | Vulnerable Physical (12) + Throw Rock (6) | 18 | Above ref — expected for elite |
| Fulminating Powder | D2 | Shocked (10) + Throw Rock (6) | 16 | Above ref — expected for elite |

#### Scenario: Score lookup for trade generation
- **WHEN** the Wandering Soul trade generation system needs to pair two durability items
- **THEN** it reads scores from this table and applies the tolerance formula in `LLD-IR-010`

#### Scenario: Score lookup for Memory Fragment scenario
- **WHEN** a Category A Memory Fragment scenario is being selected
- **THEN** the system verifies that both sides of the trade fall within the ±20% tolerance using scores from this table

#### Scenario: New item must be scored
- **WHEN** a new item is added to the game
- **THEN** it SHALL receive a score entry in this table before it can appear in trade generation or Memory Fragment scenarios

#### Scenario: AoE item scored with 1.75× modifier
- **WHEN** scoring Rope Flail (5 physical damage per hit, 6 charges, AoE)
- **THEN** per-use score = 5 × 2.0 × 1.75 = 17.5; total score = 17.5 × 3.5 = 61

#### Scenario: Battered Sword at reference score
- **WHEN** scoring Battered Sword (7 physical damage, 6 charges)
- **THEN** total score = (7 × 2.0 × 1.0) × 3.5 = 49 — at the normal-pool reference point
