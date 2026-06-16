## Why

`lld-floor-structure` and `lld-encounter-patterns` describe two halves of the same system — floor layout and room generation — but live in separate specs, forcing cross-references and duplicated context. Consolidating them into a single `lld-floor` spec eliminates redundancy and makes the full floor design readable in one place.

## What Changes

- **NEW** `openspec/specs/lld-floor/spec.md` — unified spec containing all `LLD-FLOOR-STRUCT-*`, `LLD-FLOOR-PATT-*`, and `LLD-FLOOR-BEATS-*` requirements
- **REMOVED** `LLD-FLOOR-STRUCT-003` (Room Type Distribution) — its guidance is already captured more precisely by the encounter caps in `LLD-FLOOR-PATT-003`; removing the duplicate prevents conflicting values
- **NEW** `LLD-FLOOR-STRUCT-006` — explicitly names the 9-room layout as 4 pre-elite rooms → Elite Gate → 4 post-elite rooms
- **DELETED** `openspec/specs/lld-floor-structure/` — content migrated to `lld-floor`
- **DELETED** `openspec/specs/lld-encounter-patterns/` — content migrated to `lld-floor`
- Any cross-references to `lld-floor-structure` or `lld-encounter-patterns` in other specs updated to reference `lld-floor`

## Capabilities

### New Capabilities

- `lld-floor`: Unified floor design spec — structure, room generation pattern, encounter caps, and forced beats in a single document

### Modified Capabilities

- `lld-floor-structure`: **DELETED** — all requirements migrated to `lld-floor`
- `lld-encounter-patterns`: **DELETED** — all requirements migrated to `lld-floor`

## Impact

- `lld-enemies` references `lld-encounter-patterns` indirectly (via `LLD-FLOOR-PATT-003` companion cap) — no requirement ID changes, so no spec edits needed
- `lld-elite-gate` references `LLD-FLOOR-BEATS-004` — requirement ID unchanged, no edits needed
- `lld-items` references `LLD-FLOOR-BEATS-003` (Worn Map beat) — requirement ID unchanged, no edits needed
- All requirement IDs (`LLD-FLOOR-STRUCT-*`, `LLD-FLOOR-PATT-*`, `LLD-FLOOR-BEATS-*`) are preserved; only the containing spec file changes
