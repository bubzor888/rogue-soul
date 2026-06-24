## MODIFIED Requirements

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
