## 1. Update hld-combat-system

- [x] 1.1 In HLD-COMBAT-005: remove "or by Burning/Shocked/Chilled status" from the Fire, Lightning, Ice notes — Vulnerable is now applied by items only
- [x] 1.2 In HLD-COMBAT-006: remove the "Co-applies" column from the status table; add a clarifying sentence that elemental statuses do NOT co-apply Vulnerable
- [x] 1.3 In HLD-COMBAT-006: change Chilled description from "Creeping damage reduction per tick (10%/20%/30%)" to "Creeping flat damage reduction per tick (amounts defined by omen card)"
- [x] 1.4 In HLD-COMBAT-006: remove the "Burning co-applies Vulnerable" scenario; update the "Chilled damage reduction" scenario to reflect flat reduction
- [x] 1.5 In HLD-COMBAT-007: remove the "elemental statuses as a co-application" bullet from the Vulnerable sources list
- [x] 1.6 In HLD-COMBAT-007: add the resistance-cancellation rule — if a unit has both Resistance (×0.5) and Vulnerable (×1.5) to the same type, they cancel (net ×1.0)
- [x] 1.7 In HLD-COMBAT-007: add a scenario demonstrating resistance + vulnerable cancellation
- [x] 1.8 In HLD-COMBAT-007: remove the `[OPEN·MVP1]` co-application timing note (no longer relevant)

## 2. Update lld-omen-cards

- [x] 2.1 In LLD-OMEN-CARD-001 (Burning): remove "is Vulnerable (Fire) ×1.5 for the cycle duration" from the effect description and scenarios
- [x] 2.2 In LLD-OMEN-CARD-002 (Shocked): remove "Vulnerable (Lightning) ×1.5" from the effect description and scenarios
- [x] 2.3 In LLD-OMEN-CARD-003 (Chilled): remove "Vulnerable (Ice) ×1.5"; change "percentage" language to "flat reduction" with amounts marked `[OPEN·MVP1]`; update scenarios

## 3. Update lld-items

- [x] 3.1 In LLD-ITEMS-007 (Fire Bomb): remove "co-applies Vulnerable (Fire) (see `HLD-COMBAT-007`)" — Fire Bomb now only applies Burning

## 4. Remove source pool references from lld-omen-cards

- [x] 4.1 In LLD-OMEN-CARD-001 (Burning): remove "Source pool (floor, enemy, or vessel) to be confirmed" from the open item
- [x] 4.2 In LLD-OMEN-CARD-002 (Shocked): remove "Source pool (floor, enemy, or vessel) to be confirmed" open item entirely
- [x] 4.3 In LLD-OMEN-CARD-003 (Chilled): remove "Source pool to be confirmed" from the open item
- [x] 4.4 In LLD-OMEN-CARD-005 (Emboldened Elemental): remove "Card-to-source-pool assignment (floor vs enemy) to be confirmed during omen deck design" from the open item
- [x] 4.5 In LLD-OMEN-CARD-008: rework the requirement as "Floor 3 Default Omen Deck" — the canonical list of ambient cards present every combat on Floor 3; add an explicit note that enemy contributions are defined per-enemy in `lld-enemies`; keep the `[OPEN·MVP1]` design constraints for the card list itself
- [x] 4.6 In LLD-OMEN-CARD-011 (Grave Knit): remove "Source pool confirmation (enemy only, not floor)" — replace with a pointer to `lld-enemies` for which enemies contribute this card
