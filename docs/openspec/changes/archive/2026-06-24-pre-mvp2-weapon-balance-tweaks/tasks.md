## 1. Data File Updates

- [x] 1.1 In `data/items/battered_sword.tres` set `max_charges` from `8` to `6`
- [x] 1.2 In `data/items/rope_flail.tres` set `base_damage` in the `deal_damage` handler params from `4` to `5`
- [x] 1.3 In `data/items/battered_sword.tres` set `score` from `57` to `49`
- [x] 1.4 In `data/items/rope_flail.tres` set `score` from `42` to `61`

## 2. Spiked Chain Score Update

- [x] 2.1 In `data/items/spiked_chain.tres` set `score` from `74` to `86` (re-scored from AoE multiplier change; no other data change)

## 3. Test Assertions

- [x] 3.1 In `tests/test_item_scores.gd` update `ITEM_SCORES` constants: `"battered_sword": 49`, `"rope_flail": 61`, `"spiked_chain": 86`
- [x] 3.2 Run `test_item_scores.gd` and confirm all assertions pass

## 4. Verification

- [x] 4.1 Run the full test suite and confirm no regressions
- [x] 4.2 Re-run `tests/test_item_balance.gd` benchmark and confirm battered_sword TPR is closer to iron_maul but not better, rope_flail TPR improves meaningfully, and spiked_chain remains clearly stronger than iron_maul
