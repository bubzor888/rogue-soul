## 1. Spec Updates — HLD

- [x] 1.1 Sync HLD-COMBAT-018 (Magnitude-Additive Status Reapplication) into `openspec/specs/hld-combat-system/spec.md`

## 2. Spec Updates — LLD Architecture

- [x] 2.1 Sync LLD-ARCH-018 (Data Resource Schemas) into `openspec/specs/lld-technical-architecture/spec.md` — add `status_magnitude` field to IntentWeight and OmenCardData tables
- [x] 2.2 Sync LLD-ARCH-019 (CombatResolver) into `openspec/specs/lld-technical-architecture/spec.md` — update step 7c and step 5 prose + new magnitude-stacking scenarios

## 3. Spec Updates — LLD Enemies

- [x] 3.1 Sync LLD-ENEMIES-014 (Fire Elemental) into `openspec/specs/lld-enemies/spec.md` — replace narrative Attack description with intent table; add Kindle scenarios
- [x] 3.2 Sync LLD-ENEMIES-015 (Ice Elemental) into `openspec/specs/lld-enemies/spec.md` — replace narrative Attack description with intent table; replace broken "self-created vulnerability" scenario with correct Glacial Mark scenarios

## 4. Spec Updates — LLD Omen Cards

- [x] 4.1 Sync LLD-OMEN-CARD-001 (Burning) into `openspec/specs/lld-omen-cards/spec.md` — formalise `status_magnitude: 5` and add stacking scenario

## 5. Archive

- [x] 5.1 Run `/opsx:archive` to merge delta specs into main specs and archive this change
