## Why

`lld-vessels` has several issues to clean up: doc references to `docs/vessels/` should be removed (narrative LLD specs will replace them later); `LLD-VESSELS-001` references the removed `HLD-VESSEL-005` item slot requirement; starting items are listed inline rather than linked to `lld-items`; the Pilgrim's passive is still marked `[OPEN]` even though Read the Road is fully designed in `vessel_pilgrim.md`; and the Drifter section is missing the Read the Road passive entirely.

## What Changes

- **LLD-VESSELS-001 (Pilgrim)**:
  - Remove the `docs/vessels/vessel_pilgrim.md` narrative reference.
  - Remove `Item slots: see HLD-VESSEL-005` (that requirement was removed).
  - Replace inline starting item list with a link to `LLD-ITEMS-004`.
  - Replace `[OPEN]` passive with the Read the Road ability definition (from `vessel_pilgrim.md` section 3).
  - Clarify Good as New charges: 1, replenished at floor start.

- **LLD-VESSELS-002 (Drifter)**:
  - Remove the `docs/vessels/vessel_drifter.md` narrative reference.
  - Add Read the Road as a passive (shared with the Pilgrim — it persists across the erosion path).

- **LLD-VESSELS-003 (Hedge Knight)**:
  - Remove the `docs/vessels/vessel_hedge_knight.md` narrative reference.

## Capabilities

### New Capabilities

_(none)_

### Modified Capabilities

- `lld-vessels`: Update LLD-VESSELS-001, LLD-VESSELS-002, LLD-VESSELS-003.

## Impact

- `openspec/specs/lld-vessels/spec.md` — spec text only.
- Narrative content for vessels will be captured in dedicated lld-vessel-narrative specs in a future change.
