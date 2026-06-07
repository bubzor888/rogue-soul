## 1. Update lld-abilities

- [x] 1.1 Remove LLD-ABILITIES-001 (Ability Handler Library)
- [x] 1.2 Remove LLD-ABILITIES-002 (Handler Naming Convention)
- [x] 1.3 Replace LLD-ABILITIES-004 — remove `attack_type: MELEE`, remove row-based scenario, update handler chain to `deal_damage { base_damage: 3, damage_type: physical }`

## 2. Update lld-technical-architecture

- [x] 2.1 Append LLD-ARCH-012 (Handler Naming Convention) to `openspec/specs/lld-technical-architecture/spec.md`

## 3. Verify

- [x] 3.1 Confirm no `force_row`, `summon_unit`, or row-modifier references remain in lld-abilities
- [x] 3.2 Confirm no `attack_type` or row-based scenario remains in LLD-ABILITIES-004
- [x] 3.3 Confirm LLD-ARCH-012 is present and references LLD-ARCH-005

## 4. Archive

- [x] 4.1 Run `/opsx:archive` once steps 1–3 are complete
