## Context

Three issues surfaced from a 30-seed headless benchmark (invincible random Pilgrim, items force-fed via DebugHooks) run pre-MVP2:

1. **Battered Sword** (score 57, normal pool) matched **Iron Maul** (score 70, elite) at 8.80 vs 8.81 TPR — a 4-point scoring gap produced 0% real performance gap.
2. **Rope Flail** (score 42, AoE normal) was the weakest weapon at 10.97 TPR, only 4% faster than no weapon at all.
3. **Spiked Chain** (score 74, AoE elite) outperformed Iron Maul (70) by 15% TPR despite a 4-point lower score, suggesting the AoE scoring multiplier (1.5×) systematically undersells AoE value.

All three fixes are purely numerical: two `.tres` data files and one scoring formula update.

## Goals / Non-Goals

**Goals:**
- Battered Sword total score lands at the normal-pool reference (49), matching its intended power tier.
- Rope Flail becomes a competitive normal-pool weapon with a score meaningfully above reference.
- AoE scoring multiplier corrected so future AoE items get accurate starting scores.
- All existing score assertions in `test_item_scores.gd` updated to match new values.

**Non-Goals:**
- Changing Battered Sword's per-hit damage, damage type, or identity.
- Rebalancing elemental weapons (separate concern; deliberate deferral).
- Adding or removing any items from drop pools.
- Changing the Consumable scale or any consumable item values.

## Decisions

**Battered Sword charges: 8 → 6**
6 charges × 3.5 multiplier × 14 per-use = 49.0 — exactly the normal-pool reference point. Choosing 7 would land at 7 × 3.8 × 14 = 52.6 (still above ref); 6 is the cleanest landing that enforces the design intent.

**Rope Flail damage: 4 → 5 per hit**
5 damage gives (5 × 2.0 × 1.75) × 3.5 = 61 under the revised AoE multiplier. This places it above reference (49) at a level appropriate for an AoE normal drop, without matching elite-tier damage (6/hit for Spiked Chain). Choosing 6 would push score to ~74, matching Spiked Chain's old score and blurring the normal/elite boundary.

**AoE scope modifier: 1.5× → 1.75×**
The benchmark showed AoE outperforming equal-score single-target weapons by ~15%. Applying that correction: 1.5 × 1.15 ≈ 1.725, rounded to 1.75. This is also the clean midpoint between 1.5 and 2.0, and it rests on the same 50% second-target frequency assumption — merely correcting for observed encounter density. The rationale note in LLD-IR-005 is updated to reflect this.

## Risks / Trade-offs

**Spiked Chain score 74 → 86** — The AoE multiplier change re-scores Spiked Chain upward with no data file change. Its new score (86) is below Smoldering Brand / Glacial Brand (89) and well below Arc Wand (108), which looks correct. No functional impact since scores drive trade/memory-fragment generation, which is MVP2+ anyway. `[OPEN·MVP2]`

**Battered Sword is now reference-tier, not above it** — The Hedge Knight's starting weapon drops from 57 → 49. This slightly weakens the Hedge Knight's early-floor advantage; acceptable since it was the intent of the design (normal-drop weapon at normal-drop power).

**Rope Flail at 61 is above reference** — AoE normal weapons are now measurably stronger than single-target normal weapons (61 vs 41–49). This is the correct outcome — AoE should reward multi-enemy encounters. If playtesting shows it feels too strong, the precedent for an AoE premium is now established in the formula.
