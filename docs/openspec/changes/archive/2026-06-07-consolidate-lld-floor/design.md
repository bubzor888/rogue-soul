## Context

Two specs currently cover different facets of floor design:
- `lld-floor-structure` — room count, run length, difficulty target, tier consistency
- `lld-encounter-patterns` — counter-based generation, encounter caps, forced beats

Both are referenced by downstream specs (`lld-enemies`, `lld-elite-gate`, `lld-items`) using stable requirement IDs (`LLD-FLOOR-STRUCT-*`, `LLD-FLOOR-PATT-*`, `LLD-FLOOR-BEATS-*`). The split creates cross-references within the same concern and makes the full floor design hard to read in one sitting.

## Goals / Non-Goals

**Goals:**
- Single `lld-floor/spec.md` containing all floor design requirements in logical reading order (structure → pattern rules → beats)
- Remove `LLD-FLOOR-STRUCT-003` (Room Type Distribution) — superseded by `LLD-FLOOR-PATT-003` encounter caps
- Add `LLD-FLOOR-STRUCT-006` naming the 9-room layout explicitly (4 pre-elite → Elite Gate → 4 post-elite)
- All existing requirement IDs remain unchanged — zero impact to downstream cross-references

**Non-Goals:**
- Changing any mechanics or values
- Touching `lld-enemies`, `lld-elite-gate`, `lld-items`, or any other spec (IDs are stable)
- Redesigning the floor

## Decisions

**Merge order within the unified spec:** Structure requirements first (`LLD-FLOOR-STRUCT-*`), then pattern rules (`LLD-FLOOR-PATT-*`), then beats (`LLD-FLOOR-BEATS-*`). This mirrors the natural reading progression — understand the shape of the floor before the generation rules, then the forced moments.

**Remove `LLD-FLOOR-STRUCT-003` without migration:** The 50–75% combat room distribution table is already derivable from `LLD-FLOOR-PATT-003` (encounter caps) and `LLD-FLOOR-BEATS-*` (forced beat counts). Keeping it risks conflicting values if caps change. No migration needed — the information isn't lost, it's expressed more precisely elsewhere.

**New `LLD-FLOOR-STRUCT-006`:** The 9-room breakdown (4 pre-elite + elite gate + 4 post-elite) is implied by `LLD-FLOOR-BEATS-004` but never stated explicitly as a structural fact. Making it a first-class requirement gives implementers a clear contract for the room sequence generator.

## Risks / Trade-offs

[Stale cross-references] Any prose in docs or comments that says "see `lld-floor-structure`" or "see `lld-encounter-patterns`" will become stale. → The spec system uses requirement IDs, not file paths, for cross-references; prose in `docs/` is not authoritative, so this risk is low.

[LLD-FLOOR-STRUCT-003 removal] A future designer might re-add a room distribution constraint if they don't know it was removed. → `LLD-FLOOR-PATT-003` is more precise and will surface naturally during floor design work.
