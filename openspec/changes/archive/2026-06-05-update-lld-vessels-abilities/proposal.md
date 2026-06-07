## Why

LLD-VESSELS-002 (Drifter) and LLD-VESSELS-003 (Hedge Knight) still have `[OPEN]` placeholders for their ability sets. Both vessel docs are complete enough to capture their confirmed abilities. Starting items now reference `lld-items` correctly — the vessel requirements should not repeat item details, only link.

## What Changes

- **LLD-VESSELS-002 (Drifter)**: Add base stats (HP: 28), bound companion (The Ferret with Scavenge passive), Hardy active ability (3 charges/floor, clears Hardy-clearable debuffs). Floor 2 and 3 abilities remain `[OPEN]`. Starting items reference `LLD-ITEMS-009` (already added in previous change — keep the link, remove the inline description).
- **LLD-VESSELS-003 (Hedge Knight)**: Add base stats (HP: 32), Last Stand passive (1.5× damage below 25% HP), Charge active (doubles next attack damage, charges `[OPEN]`). Floor 2 and 3 abilities remain `[OPEN]`. Starting items reference `LLD-ITEMS-010`.

## Capabilities

### New Capabilities

_(none)_

### Modified Capabilities

- `lld-vessels`: Update LLD-VESSELS-002 and LLD-VESSELS-003.

## Impact

- `openspec/specs/lld-vessels/spec.md` — spec text only.
- Source: `docs/vessels/vessel_drifter.md` sections 2–4 and `docs/vessels/vessel_hedge_knight.md` sections 2–4.
