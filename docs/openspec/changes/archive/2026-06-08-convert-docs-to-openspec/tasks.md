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

- [x] 3.1 Review `lld-vessels/spec.md` — verify Pilgrim starting items and Good as New behaviour
- [x] 3.2 Review `lld-abilities/spec.md` — verify handler ID table matches tech arch docs
- [x] 3.3 Review `lld-items/spec.md` — verify all weapon/consumable stats match `docs/detailed design/soul_protocol_items.md`
- [x] 3.4 Review `lld-enemies/spec.md` — verify Skeleton/Zombie HP, damage, and vulnerability values; verify encounter structure table
- [x] 3.5 Review `lld-room-events/spec.md` — spec deleted; Memory Fragment and Wandering Soul moved to lld-encounter-patterns; Anomaly in lld-elite-gate; Rest removed from design

## 4. Review Floor Design Specs (from convert-floor-design-to-spec)

- [x] 4.1 Review `lld-floor-structure/spec.md` — consolidated into `lld-floor/spec.md`; STRUCT-001–006 verified; STRUCT-003 removed (superseded by PATT-003); STRUCT-006 added (9-room layout explicit)
- [x] 4.2 Review `lld-encounter-patterns/spec.md` — consolidated into `lld-floor/spec.md`; counter system, caps, Combat Lock `[OPEN·MVP1]`, and Worn Map cross-reference all present; caps table updated (Standard Combat added, Temporary Companion removed); BEATS-004 updated (elite vs standard choice); BEATS-006 added (rest on elite path)
- [x] 4.3 Review `lld-door-system/spec.md` — DOOR-001–005 verified; DOOR-001 generalised (item-driven single-door exception, not Worn Map specific); DOOR-003 updated (distinct symbols per non-combat type; subcategory content still hidden); DOOR-004 rewritten as Pool Exhaustion Both-Doors Rule (general pool mechanism, not combat-specific)

## 5. Review Non-Combat Encounter Specs (from convert-noncombat-encounters-to-spec)

- [x] 5.1 Review `lld-memory-fragments/spec.md` — restructured: mechanics moved to new `hld-memory-fragments` (HLD-MF-001–005); Category B renamed Companion Encounter; LLD now holds 4 separate requirements: Floor 3 weights (LLD-MF-007: 40/40/20), Category A pool (LLD-MF-008), Companion Encounter pool (LLD-MF-009), Category C pool (LLD-MF-010) — all `[OPEN·MVP1]`
- [x] 5.2 Review `lld-wandering-soul/spec.md` — restructured: all 8 LLD-WS-* requirements promoted to new `hld-wandering-soul` as HLD-WS-001–008; `lld-wandering-soul` deleted (no LLD-specific content needed); `LLD-ITEMS-011` added for item tier list `[OPEN·MVP1]`; `LLD-FLOOR-PATT-005` cross-reference updated to `hld-wandering-soul`
- [x] 5.3 Review `lld-elite-gate/spec.md` — spec deleted entirely; structure superseded by `LLD-FLOOR-BEATS-004`; reward model migrated to `HLD-COMBAT-013` (elite-tier loot pools); post-fight heal superseded by `LLD-FLOOR-BEATS-006`
- [x] 5.4 Review `lld-room-events/spec.md` — spec deleted in earlier session (consolidate-room-events); Rest removed from design; Anomaly no longer exists at Elite Gate per `LLD-FLOOR-BEATS-004` update
- [x] 5.5 Note that Memory Fragment scenario writing (8–10 scenarios) is flagged as a follow-on content task
- [x] 5.6 Note that temporary companion pool (Floor 3) is blocked on companion design session — follow-on when ready
- [x] 5.7 Note that all HP values in non-combat encounters are blocked on vessel HP pool design

## 6. Review Omen Specs (from convert-omens-to-spec)

- [x] 6.1 Review `lld-omen-mechanics/spec.md` — verify LLD-OMEN-MECH-001 through LLD-OMEN-MECH-009 match `soul_protocol_omens.md` sections 2–4; confirm deck size framework (16–18 solo, 20–24 multi-enemy), reshuffle rule, and `[OPEN]` items for number distribution and fixed vs random number
- [x] 6.2 Review `lld-omen-cards/spec.md` — verify LLD-OMEN-CARD-001 through LLD-OMEN-CARD-007 match confirmed cards in section 6; confirm Stillness (Pilgrim null card, 2 copies), Fortified (Hedge Knight Iron Pendant), and Floor 3 pool requirement marked `[OPEN]`
- [x] 6.3 Verify `hld-combat-system` HLD-COMBAT-008 references `lld-omen-mechanics` and `lld-omen-cards` — confirmed already in sync

## 7. Identify and Log Missing Content

- [x] 7.1 Note any confirmed decisions in `docs/` that did not make it into a spec and create follow-on tasks — deferred to follow-on proposal
- [x] 7.2 Identify which `[OPEN]` requirements in specs have enough info in docs to be resolved now vs. genuinely deferred — deferred to follow-on proposal
- [x] 7.3 Create a follow-on change proposal for omens spec conversion (`docs/detailed design/soul_protocol_omens.md`)
- [x] 7.4 Create a follow-on change proposal for non-combat encounters spec conversion (`docs/detailed design/soul_protocol_noncombat_encounters.md`)
- [x] 7.5 Create a follow-on change proposal for floor encounter design spec (`docs/detailed design/soul_protocol_floor_encounter_design.md`)

## 8. Archive the Change

- [x] 8.1 Run `/opsx:archive` to archive the `convert-docs-to-openspec` change once all reviews are complete
