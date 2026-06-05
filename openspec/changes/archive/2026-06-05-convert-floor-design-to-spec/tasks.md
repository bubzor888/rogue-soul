## 1. Sync Specs to Main openspec/specs/

- [x] 1.1 Run `/opsx:sync` to promote all specs from this change to `openspec/specs/`
- [x] 1.2 Verify `lld-floor-structure/`, `lld-encounter-patterns/`, `lld-door-system/` exist in `openspec/specs/`

## 2. Review Floor Structure Spec

- [x] 2.1 Verify `LLD-FLOOR-STRUCT-001` through `LLD-FLOOR-STRUCT-005` match `soul_protocol_floor_encounter_design.md` sections 1–3 — **moved to convert-docs-to-openspec**
- [x] 2.2 Confirm 9 rooms + Judge, 30-min target, and 3–5 attempt difficulty calibration are all present — **moved to convert-docs-to-openspec**

## 3. Review Encounter Patterns Spec

- [x] 3.1 Verify `LLD-FLOOR-PATT-001` through `LLD-FLOOR-PATT-003` capture the counter-based system and caps correctly — **moved to convert-docs-to-openspec**
- [x] 3.2 Verify all four forced beats match section 6 of the doc — **moved to convert-docs-to-openspec**
- [x] 3.3 Confirm Combat Lock threshold is marked `[OPEN]` for playtesting — **moved to convert-docs-to-openspec**
- [x] 3.4 Confirm Worn Map companion beat cross-references `LLD-ITEMS-004` and companion pool is `[OPEN]` — **moved to convert-docs-to-openspec**

## 4. Review Door System Spec

- [x] 4.1 Verify `LLD-FLOOR-DOOR-001` through `LLD-FLOOR-DOOR-005` match section 5 of the doc — **moved to convert-docs-to-openspec**
- [x] 4.2 Confirm full enemy identity on combat doors is captured as a confirmed decision (not `[OPEN]`) — **moved to convert-docs-to-openspec**
- [x] 4.3 Confirm symbol-only rule on non-combat doors is captured — **moved to convert-docs-to-openspec**

## 5. Archive

- [x] 5.1 Run `/opsx:archive` once review is complete
