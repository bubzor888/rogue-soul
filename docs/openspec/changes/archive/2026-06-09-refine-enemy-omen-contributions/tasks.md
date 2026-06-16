## 1. HLD Update

- [x] 1.1 Add `HLD-OMEN-003` (Two-Tier Enemy Omen Contribution Model) to `openspec/specs/hld-omen-system/spec.md`

## 2. LLD-ENEMIES Undead Family

- [x] 2.1 Update `LLD-ENEMIES-004` (Skeleton) — split contributions into family card (Grave Knit ×1 per Skeleton) and type card (Emboldened Physical ×1)
- [x] 2.2 Update `LLD-ENEMIES-005` (Zombie) — add Emboldened Physical ×1 as type card; remove `[OPEN·MVP1]` tag

## 3. LLD-ENEMIES Beast Family

- [x] 3.1 Update `LLD-ENEMIES-006` (Plague Rat) — add Exposed ×1 as type card
- [x] 3.2 Update `LLD-ENEMIES-007` (Wolf) — add Exposed ×1 as type card
- [x] 3.3 Update `LLD-ENEMIES-008` (Bear) — add Exposed ×1 as type card

## 4. LLD-ENEMIES Fanatic Family

- [x] 4.1 Update `LLD-ENEMIES-017` (Low HP Fanatic) — add Mending ×1 as type card
- [x] 4.2 Update `LLD-ENEMIES-018` (High HP Fanatic) — add Mending ×1 as type card

## 5. Architecture Update

- [x] 5.1 Update `LLD-ARCH-019` `resolve_enemy_death()` in `openspec/specs/lld-technical-architecture/spec.md` — note that type card removal fires when the last enemy of that type dies, not on each individual death
