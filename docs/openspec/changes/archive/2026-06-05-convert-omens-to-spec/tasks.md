## 1. Sync Specs to Main openspec/specs/

- [x] 1.1 Run `/opsx:sync` to promote all specs from this change to `openspec/specs/`
- [x] 1.2 Verify `lld-omen-mechanics/spec.md` and `lld-omen-cards/spec.md` are present in `openspec/specs/`
- [x] 1.3 Verify the MODIFIED `hld-combat-system/spec.md` has been merged — `HLD-COMBAT-008` should now reference `lld-omen-mechanics` instead of being a stub

## 2. Review Omen Mechanics Spec

- [x] 2.1 Verify `LLD-OMEN-MECH-001` through `LLD-OMEN-MECH-009` match `docs/detailed design/soul_protocol_omens.md` sections 2–4
- [x] 2.2 Confirm deck size framework numbers (16–18 solo, 20–24 multi-enemy) are correctly captured
- [x] 2.3 Confirm reshuffle rule is present
- [x] 2.4 Confirm all `[OPEN]` requirements (number distribution, fixed vs random number) match doc open questions

## 3. Review Omen Cards Spec

- [x] 3.1 Verify `LLD-OMEN-CARD-001` through `LLD-OMEN-CARD-007` match confirmed cards in `docs/detailed design/soul_protocol_omens.md` section 6
- [x] 3.2 Confirm Stillness is documented with correct rationale (Pilgrim null card, 2 copies)
- [x] 3.3 Confirm Fortified is tagged to Hedge Knight Iron Pendant correctly
- [x] 3.4 Verify Floor 3 pool requirement `LLD-OMEN-CARD-008` is marked `[OPEN]` with design constraints

## 4. Archive

- [x] 4.1 Run `/opsx:archive` once review is complete
