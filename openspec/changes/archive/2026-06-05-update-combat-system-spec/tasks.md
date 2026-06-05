## 1. Sync to Main Specs

- [ ] 1.1 Run `/opsx:sync` to merge this delta into `openspec/specs/hld-combat-system/spec.md`
- [ ] 1.2 Verify HLD-COMBAT-002 and HLD-COMBAT-003 are removed from the main spec
- [ ] 1.3 Verify HLD-COMBAT-004 now describes the three-bucket system (not the `[OPEN]` AP pool question)

## 2. Confirm Back Row Damage Reduction

- [ ] 2.1 Decide: is "back row units receive reduced physical damage" still a live design decision?
- [ ] 2.2 If yes — create a new `/opsx:propose` to add it back as a standalone requirement (separate from targeting rules)
- [ ] 2.3 If no — no action needed; the removal is complete

## 3. Follow-On: Remove force_row from lld-abilities

- [ ] 3.1 Create a follow-on `/opsx:propose` to remove `force_row` from the `LLD-ABILITIES-001` handler table in `lld-abilities` (it was tied to the row-targeting system that no longer exists)

## 4. Resolve T-2 in hld-technical-architecture

- [ ] 4.1 Create a follow-on `/opsx:propose` to update `HLD-ARCH-012` — remove T-2 (action economy) from the open decisions list since it is now resolved by this change

## 5. Archive

- [ ] 5.1 Run `/opsx:archive` once steps 1–2 are complete
