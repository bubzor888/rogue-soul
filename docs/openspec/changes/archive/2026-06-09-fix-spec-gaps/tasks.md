## 1. Fix Structural Headers in HLD Specs

- [x] 1.1 Prepend `## Purpose` and `## Requirements` headers to `openspec/specs/hld-companion-system/spec.md`
- [x] 1.2 Prepend `## Purpose` and `## Requirements` headers to `openspec/specs/hld-run-structure/spec.md`
- [x] 1.3 Prepend `## Purpose` and `## Requirements` headers to `openspec/specs/hld-vessel-system/spec.md`
- [x] 1.4 Prepend `## Purpose` and `## Requirements` headers to `openspec/specs/hld-game-concept/spec.md`

## 2. Create hld-item-system Spec

- [x] 2.1 Create `openspec/specs/hld-item-system/spec.md` with `## Purpose` and `## Requirements` headers
- [x] 2.2 Add `HLD-ITEMS-001` — No inventory cap at MVP
- [x] 2.3 Add `HLD-ITEMS-002` — Floor-bound item flag (removed at transition with player notification; visible in inventory)
- [x] 2.4 Add `HLD-ITEMS-003` — Encounter-countdown item system (counter visible; decrements on all non-boss encounters; replaces a room slot on zero; acquirable only when enough encounters remain)
- [x] 2.5 Add cross-reference from `LLD-ITEMS-009` (Loaf of Bread) to `HLD-ITEMS-002`
- [x] 2.6 Add cross-reference from `LLD-ITEMS-004` (Worn Map) to `HLD-ITEMS-003`

## 3. Add Floor Transition Requirement to hld-run-structure

- [x] 3.1 Add `HLD-RUN-006` to `openspec/specs/hld-run-structure/spec.md` — floor transition: full HP restore, temporary companion departs, bound companion persists; no mid-floor HP restore from rooms

## 4. Create hld-narrative Spec

- [x] 4.1 Create `openspec/specs/hld-narrative/spec.md` with `## Purpose` and `## Requirements` headers
- [x] 4.2 Add `HLD-NAR-001` — Soul and Solace (soul seeks Solace across lifetimes; erosion model; instinct not memory)
- [x] 4.3 Add `HLD-NAR-002` — The guardian judges need, not moral worthiness; Pilgrim passes most easily; `[OPEN·MVP1]` for dialogue
- [x] 4.4 Add `HLD-NAR-003` — Floor atmosphere degrades toward Solace; enemy visual clarity scales with tier on final floor; gate always clear; `[OPEN·MVP1]` for visual direction

## 5. Create lld-narrative Spec

- [x] 5.1 Create `openspec/specs/lld-narrative/spec.md` with `## Purpose` and `## Requirements` headers
- [x] 5.2 Add `LLD-NAR-001` — Guardian dialogue per vessel `[OPEN·MVP1]`
- [x] 5.3 Add `LLD-NAR-002` — Branch endings `[OPEN·MVP2]`
- [x] 5.4 Add `LLD-NAR-003` — Vessel lore fragments `[OPEN·MVP1]`
- [x] 5.5 Add `LLD-NAR-004` — Floor 2 lore content (The Blurred Deep / The Unmarked Edge) `[OPEN·MVP3]`

## 6. Archive

- [x] 6.1 Archive `fix-spec-gaps` change
