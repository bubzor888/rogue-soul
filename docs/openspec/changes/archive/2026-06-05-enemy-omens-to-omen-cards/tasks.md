## 1. Update lld-omen-cards

- [x] 1.1 Update LLD-OMEN-CARD-001 (Burning) — remove source back-reference; definition only
- [x] 1.2 Update LLD-OMEN-CARD-002 (Shocked) — remove source back-reference; definition only
- [x] 1.3 Update LLD-OMEN-CARD-003 (Chilled) — remove source back-reference; definition only
- [x] 1.4 Update LLD-OMEN-CARD-004 (Emboldened Physical) — remove source back-reference; definition only
- [x] 1.5 Append LLD-OMEN-CARD-011 (Grave Knit — Undead enemy card)
- [x] 1.6 Append LLD-OMEN-CARD-012 (Thick Hide — Beast enemy card)
- [x] 1.7 Append LLD-OMEN-CARD-013 (Elemental Synergy — Elemental enemy card)
- [x] 1.8 Append LLD-OMEN-CARD-014 (Sacred Ground — Fanatic enemy card)

## 2. Update lld-enemies

- [x] 2.1 Remove LLD-ENEMIES-003 (Grave Knit) — definition now in LLD-OMEN-CARD-011
- [x] 2.2 Remove LLD-ENEMIES-011 (Thick Hide) — definition now in LLD-OMEN-CARD-012
- [x] 2.3 Remove LLD-ENEMIES-012 (Elemental Synergy) — definition now in LLD-OMEN-CARD-013
- [x] 2.4 Remove LLD-ENEMIES-013 (Sacred Ground) — definition now in LLD-OMEN-CARD-014
- [x] 2.5 Update LLD-ENEMIES-004–008: replace inline omen contribution descriptions with LLD-OMEN-CARD references
- [x] 2.6 Update LLD-ENEMIES-014–020: replace inline omen contribution descriptions with LLD-OMEN-CARD references

## 3. Verify

- [x] 3.1 Confirm lld-omen-cards has 14 requirements (001–014) with no back-references to enemy requirements; confirm lld-enemies has no inline omen card effect definitions
- [x] 3.2 Confirm every enemy's omen contributions list uses `LLD-OMEN-CARD-XXX` IDs
- [x] 3.3 Confirm LLD-ENEMIES-003, 011, 012, 013 are gone

## 4. Archive

- [x] 4.1 Run `/opsx:archive` once steps 1–3 are complete
