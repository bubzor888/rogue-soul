## 1. Sync Specs to Main openspec/specs/

- [x] 1.1 Run `/opsx:sync` to promote all change specs from `openspec/changes/convert-docs-to-openspec/specs/` to `openspec/specs/`
- [x] 1.2 Verify 13 spec folders are present in `openspec/specs/` (8 HLD + 5 LLD)
- [x] 1.3 Confirm each spec file contains its requirement IDs and at least one scenario per requirement

## 2. Review and Spot-Check HLD Specs

- [x] 2.1 Review `hld-game-concept/spec.md` — verify all 5 requirements match docs intent
- [x] 2.2 Review `hld-run-structure/spec.md` — verify door symbol table and floor depth rules are accurate
- [x] 2.3 Review `hld-combat-system/spec.md` — verify damage type table, status effect values, and loot choice rule
- [x] 2.4 Review `hld-vessel-system/spec.md` — verify solo archetype and unlock condition requirements
- [x] 2.5 Review `hld-companion-system/spec.md` — verify two-tier system and row independence
- [x] 2.6 Review `hld-meta-progression/spec.md` — removed; deferred to later design stage
- [x] 2.7 Review `hld-technical-architecture/spec.md` — converted to lld-technical-architecture; open technical decisions section removed (T-2 through T-10 deferred to later review)
- [x] 2.8 Review `hld-platform-constraints/spec.md` — converted to lld-platform-constraints; row references removed from layout

## 3. Review and Spot-Check LLD Specs

- [ ] 3.1 Review `lld-vessels/spec.md` — verify Pilgrim starting items and Good as New behaviour
- [ ] 3.2 Review `lld-abilities/spec.md` — verify handler ID table matches tech arch docs
- [ ] 3.3 Review `lld-items/spec.md` — verify all weapon/consumable stats match `docs/detailed design/soul_protocol_items.md`
- [ ] 3.4 Review `lld-enemies/spec.md` — verify Skeleton/Zombie HP, damage, and vulnerability values; verify encounter structure table
- [ ] 3.5 Review `lld-room-events/spec.md` — verify Memory Fragment, Wandering Soul, Rest, and Anomaly room rules

## 4. Review Floor Design Specs (from convert-floor-design-to-spec)

- [ ] 4.1 Review `lld-floor-structure/spec.md` — verify LLD-FLOOR-STRUCT-001 through LLD-FLOOR-STRUCT-005 match `soul_protocol_floor_encounter_design.md` sections 1–3; confirm 9 rooms + Judge, 30-min target, and 3–5 attempt difficulty calibration are present
- [ ] 4.2 Review `lld-encounter-patterns/spec.md` — verify counter-based generation system and caps; confirm forced beats match section 6; confirm Combat Lock threshold is `[OPEN]`; confirm Worn Map beat cross-references `LLD-ITEMS-004`
- [ ] 4.3 Review `lld-door-system/spec.md` — verify LLD-FLOOR-DOOR-001 through LLD-FLOOR-DOOR-005 match section 5; confirm full enemy identity on combat doors; confirm symbol-only rule on non-combat doors

## 5. Review Non-Combat Encounter Specs (from convert-noncombat-encounters-to-spec)

- [ ] 5.1 Review `lld-memory-fragments/spec.md` — verify three categories (A/B/C) and pool weights (40/40/20) match `soul_protocol_noncombat_encounters.md` section 3
- [ ] 5.2 Review `lld-wandering-soul/spec.md` — verify 2–3 offers, HP-for-item guarantee, no currency, tier fairness, no companion offers, and post-elite guarantee match section 4
- [ ] 5.3 Review `lld-elite-gate/spec.md` — verify two-door structure (elite vs Anomaly), rewards, post-fight heal, and no-heal-elsewhere rule match section 6
- [ ] 5.4 Review `lld-room-events/spec.md` MODIFIED requirements — confirm Rest removed from MVP Floor 3 pool and Anomaly scoped to Elite Gate only
- [ ] 5.5 Note that Memory Fragment scenario writing (8–10 scenarios) is flagged as a follow-on content task
- [ ] 5.6 Note that temporary companion pool (Floor 3) is blocked on companion design session — follow-on when ready
- [ ] 5.7 Note that all HP values in non-combat encounters are blocked on vessel HP pool design

## 6. Review Omen Specs (from convert-omens-to-spec)

- [ ] 6.1 Review `lld-omen-mechanics/spec.md` — verify LLD-OMEN-MECH-001 through LLD-OMEN-MECH-009 match `soul_protocol_omens.md` sections 2–4; confirm deck size framework (16–18 solo, 20–24 multi-enemy), reshuffle rule, and `[OPEN]` items for number distribution and fixed vs random number
- [ ] 6.2 Review `lld-omen-cards/spec.md` — verify LLD-OMEN-CARD-001 through LLD-OMEN-CARD-007 match confirmed cards in section 6; confirm Stillness (Pilgrim null card, 2 copies), Fortified (Hedge Knight Iron Pendant), and Floor 3 pool requirement marked `[OPEN]`
- [ ] 6.3 Verify `hld-combat-system` HLD-COMBAT-008 references `lld-omen-mechanics` and `lld-omen-cards` — confirmed already in sync

## 7. Identify and Log Missing Content

- [ ] 7.1 Note any confirmed decisions in `docs/` that did not make it into a spec and create follow-on tasks
- [ ] 7.2 Identify which `[OPEN]` requirements in specs have enough info in docs to be resolved now vs. genuinely deferred
- [x] 7.3 Create a follow-on change proposal for omens spec conversion (`docs/detailed design/soul_protocol_omens.md`)
- [x] 7.4 Create a follow-on change proposal for non-combat encounters spec conversion (`docs/detailed design/soul_protocol_noncombat_encounters.md`)
- [x] 7.5 Create a follow-on change proposal for floor encounter design spec (`docs/detailed design/soul_protocol_floor_encounter_design.md`)

## 8. Archive the Change

- [ ] 8.1 Run `/opsx:archive` to archive the `convert-docs-to-openspec` change once all reviews are complete
