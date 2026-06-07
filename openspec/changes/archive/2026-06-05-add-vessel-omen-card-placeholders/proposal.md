## Why

`lld-omen-cards` documents the Pilgrim's vessel card (Stillness) and the Hedge Knight's Iron Pendant item card (Fortified), but has no entries for the Hedge Knight's own vessel omen card or the Drifter's Ferret omen card. The Ferret omen is already referenced as `[OPEN]` in `lld-vessels`. The Hedge Knight's vessel card is distinct from Fortified — the pendant brings Fortified as an item card; the vessel itself contributes a separate omen card. Adding `[OPEN]` placeholder requirements gives both a tracked home in the spec.

## What Changes

- **LLD-OMEN-CARD-009 (Hedge Knight Vessel Card)**: `[OPEN]` placeholder. Notes that this is a vessel omen card separate from LLD-OMEN-CARD-007 (Fortified, which is an item card from the Iron Pendant). Expected to appear in every combat on a Hedge Knight run.
- **LLD-OMEN-CARD-010 (Drifter Vessel Card — The Ferret)**: `[OPEN]` placeholder. Notes that the Ferret contributes one omen card, inert on the enemy side, beneficial effect for the Drifter. References the Ferret's omen card note in `LLD-VESSELS-002`.

## Capabilities

### New Capabilities

_(none)_

### Modified Capabilities

- `lld-omen-cards`: Add LLD-OMEN-CARD-009 and LLD-OMEN-CARD-010.

## Impact

- `openspec/specs/lld-omen-cards/spec.md` — two new `[OPEN]` requirements appended.
