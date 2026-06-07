## Why

Two small precision gaps in `lld-floor`:
1. `LLD-FLOOR-BEATS-004` (Elite Gate) says "rooms 5–6 range" — vague placement that should be pinned to room 5 now that `LLD-FLOOR-STRUCT-006` explicitly defines the 4+1+4 layout.
2. `LLD-FLOOR-PATT-003` (Encounter Caps) has a Temporary Companion row that duplicates information already fully defined in `LLD-FLOOR-BEATS-003` (Worn Map). The table also lacks a Standard Combat cap, which is the core encounter type.

## What Changes

- **MODIFIED** `LLD-FLOOR-BEATS-004`: "rooms 5–6 range" → "room 5 (always)"; the two-door choice is now **elite combat vs standard combat** (not Anomaly — that was an earlier design); choosing the standard combat counts toward the floor's overall standard combat total but does not belong to the pre-elite or post-elite buckets
- **ADDED** `LLD-FLOOR-BEATS-006`: If the player chose the **elite combat** door at room 5, room 6 SHALL be a guaranteed rest encounter — the only rest room on the floor; if the player chose the standard combat door, room 6 is drawn from the normal post-elite pool
- **MODIFIED** `LLD-FLOOR-PATT-002`: Update to note the single rest exception at room 6 (elite path)
- **MODIFIED** `LLD-FLOOR-PATT-003`: Remove the Temporary Companion row (already covered by `LLD-FLOOR-BEATS-003`); add a Standard Combat row (2–3 pre-elite, 1–2 post-elite, max 5)

## Capabilities

### New Capabilities

_(none)_

### Modified Capabilities

- `lld-floor`: `LLD-FLOOR-BEATS-004` pinned to room 5 with updated door choice (elite vs standard); new `LLD-FLOOR-BEATS-006` rest-on-elite rule; `LLD-FLOOR-PATT-002` updated to note the single rest exception; `LLD-FLOOR-PATT-003` encounter caps table updated

## Impact

- `lld-floor/spec.md` only — no downstream spec cross-references change
