## 1. Update Main Spec

- [x] 1.1 Replace LLD-ABILITIES-003 — add Type: Action, Bucket: Support, Charges: 1/floor; add no-effect-on-single-use scenario
- [x] 1.2 Replace LLD-ABILITIES-004 — add Type: Action, Bucket: Attack, Charges: none
- [x] 1.3 Append LLD-ABILITIES-005 (Read the Road — Pilgrim Passive)
- [x] 1.4 Append LLD-ABILITIES-006 (Hardy — Drifter Active, Support bucket)
- [x] 1.5 Append LLD-ABILITIES-007 (Last Stand — Hedge Knight Passive)
- [x] 1.6 Append LLD-ABILITIES-008 (Charge — Hedge Knight Active, Support bucket)

## 2. Verify

- [x] 2.1 Confirm every ability requirement has an explicit Type and, if Action, a Bucket with HLD-COMBAT-004 reference
- [x] 2.2 Confirm Read the Road is Passive with `[OPEN·MVP1]` handler chain
- [x] 2.3 Confirm Hardy and Charge are `[OPEN·MVP3]`
- [x] 2.4 Confirm Last Stand + Charge ×3 scenario is present in LLD-ABILITIES-008

## 3. Archive

- [x] 3.1 Run `/opsx:archive` once steps 1–2 are complete
