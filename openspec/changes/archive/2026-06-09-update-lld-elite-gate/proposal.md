## Why

`lld-elite-gate` is entirely superseded: its structure requirements duplicate `LLD-FLOOR-BEATS-004`, its Anomaly door content is stale, and its HP restore is replaced by `LLD-FLOOR-BEATS-006`. The one unique thing it owned — the elite reward tier distinction — belongs in `hld-combat-system` alongside `HLD-COMBAT-012` (post-combat loot), not in a floor-specific spec.

## What Changes

- **DELETED** `openspec/specs/lld-elite-gate/` — entire spec removed; all requirements either superseded or migrated
- **ADDED** `HLD-COMBAT-013` (Elite Combat Rewards) to `hld-combat-system` — establishes that elite combats follow the same two-option loot format as `HLD-COMBAT-012` but draw from elite-tier pools; standard combats draw from normal-tier pools; pool definitions are an LLD concern

## Capabilities

### New Capabilities

_(none)_

### Modified Capabilities

- `hld-combat-system`: new `HLD-COMBAT-013` added — elite vs standard loot tier distinction
- `lld-elite-gate`: **DELETED** — all content either superseded or migrated to `hld-combat-system`

## Impact

- Any cross-references to `lld-elite-gate` in other specs should be checked; the floor beats spec (`LLD-FLOOR-BEATS-004`, `LLD-FLOOR-BEATS-006`) already owns the structural details
