## Why

Pre-MVP2 headless benchmark runs (30 seeds, invincible random agent) revealed three concrete balance problems: Battered Sword performs identically to elite-tier Iron Maul despite being a normal-pool drop, Rope Flail is barely faster than the baseline (no weapon at all), and the AoE scope multiplier in the scoring formula is empirically too low — Spiked Chain outperforms Iron Maul by 15% despite only a 4-point score gap.

## What Changes

- **Battered Sword charges 8 → 6**: reduces the weapon's effective charge count so its total score drops from 57 to ~49 (reference level), bringing it in line with normal-pool expectations without changing its per-hit damage or identity.
- **Rope Flail damage 4 → 5 per hit**: AoE weapon was the weakest item tested, only 4% faster than the no-weapon baseline; a 1-damage bump raises its score from 42 to ~52 and gives it meaningful combat presence.
- **AoE scope modifier 1.5× → 1.75×**: the benchmark showed AoE weapons outperforming their theoretical scores by ~15%; revising the multiplier upstream corrects all existing AoE item scores (Rope Flail, Spiked Chain) and gives future AoE items accurate starting points.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `lld-items`: Battered Sword charge count and Rope Flail damage value are LLD item definitions — requirements change.
- `lld-item-ranking`: AoE scope modifier value, and the derived scores for Rope Flail and Spiked Chain, are defined in `LLD-IR-005` and `LLD-IR-011` — requirements change.

## Impact

- `data/items/battered_sword.tres`: `max_charges` 8 → 6
- `data/items/rope_flail.tres`: `base_damage` 4 → 5
- `docs/openspec/specs/lld-item-ranking/spec.md`: AoE modifier table and score table updated
- `docs/openspec/specs/lld-items/spec.md`: Battered Sword and Rope Flail rows in drop pool tables updated
- `tests/test_item_scores.gd`: pinned score constants updated to match new calculated values
- `tests/test_item_balance.gd`: benchmark script remains as a regression tool (no logic changes needed)
