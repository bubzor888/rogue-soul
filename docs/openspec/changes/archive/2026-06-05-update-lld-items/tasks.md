## 1. Update Main Spec

- [x] 1.1 Replace LLD-ITEMS-002 with split decrement rule (attack: per use; support: per encounter)
- [x] 1.2 Replace LLD-ITEMS-004 Walking Staff effect chain (`deal_damage` + `damage_type: physical`; remove `attack_type: MELEE`)
- [x] 1.3 Replace LLD-ITEMS-004 Worn Map description (Support Durability, break effect, not counter trigger)
- [x] 1.4 Replace LLD-ITEMS-004 Walking Staff scenario — remove "front-row enemy" reference
- [x] 1.5 Replace LLD-ITEMS-004 Spoiled Potion — add HLD-COMBAT-006 reference and starting X value
- [x] 1.6 Replace LLD-ITEMS-007 table — Fire Bomb and Hardening Resin cite HLD-COMBAT-006 and specify X values
- [x] 1.7 Replace LLD-ITEMS-008 table — Poultice, Frost Shard, Fulminating Powder cite HLD-COMBAT-006

## 2. Verify

- [x] 2.1 Confirm no `attack_type: melee` or `attack_type: MELEE` remains anywhere in lld-items
- [x] 2.2 Confirm no front/back row references remain
- [x] 2.3 Confirm every status-applying item has a `HLD-COMBAT-006` reference
- [x] 2.4 Confirm Worn Map is classified as Support (Durability) with a break trigger

## 3. Archive

- [x] 3.1 Run `/opsx:archive` once steps 1–2 are complete
