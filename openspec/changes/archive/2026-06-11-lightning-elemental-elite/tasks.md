## 1. Spec Updates — LLD Enemies

- [x] 1.1 Sync LLD-ENEMIES-002 (Enemy Families) into `openspec/specs/lld-enemies/spec.md` — replace single "Floor 3 members" table with separate Normal Enemies (pre/post-elite counts) and Elite Enemies tables
- [x] 1.2 Sync LLD-ENEMIES-009 (Floor 3 Encounter Structure) into `openspec/specs/lld-enemies/spec.md` — update phase table to reference LLD-ENEMIES-002 tables; remove inline Beast exception columns
- [x] 1.3 Sync LLD-ENEMIES-016 (Lightning Elemental) into `openspec/specs/lld-enemies/spec.md` — add elite designation, Phase 1 escalating intent table with conditionals, Phase 2 Lightning Spark entity with intent table and conditionals, updated scenarios

## 2. Spec Updates — LLD Technical Architecture

- [x] 2.1 Sync LLD-ARCH-018 (Data Resource Schemas) into `openspec/specs/lld-technical-architecture/spec.md` — add `on_death_summons: Array[String]` to EnemyData; update IntentConditional `condition` field notes to define per-enemy `turn_number` semantics (`turns_alive` counter); add `weight: 0` note to IntentWeight; add new scenarios for `turn_number` per-enemy and `on_death_summons`

## 3. Archive

- [ ] 3.1 Run `/opsx:archive` to merge delta specs into main specs and archive this change
