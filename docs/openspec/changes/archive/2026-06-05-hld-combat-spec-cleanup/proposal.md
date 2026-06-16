## Why

Following the HLD value-abstraction convention established in `abstract-hld-combat-values`, three remaining violations in `hld-combat-system` need to be cleaned up: HLD-COMBAT-010 names specific items (Ointment, Amethyst) that belong in LLD, HLD-COMBAT-011 names a specific base damage value (3), and an open item about back row damage reduction is stale since the row system was removed.

## What Changes

- **HLD-COMBAT-010 (Cleanse)**: Restate as a mechanic rule — the system SHALL support cleanse consumables that clear status effects by category. Remove the item table (Ointment/Amethyst) and item-specific scenarios; those details live in LLD-ITEMS-001 which already exists. Keep the concept that cleanse items cover distinct status categories.
- **HLD-COMBAT-011 (Default Strike)**: Remove "Base damage: 3" and the balancing reference sentence. Add that the default strike does not consume item durability. Value lives in LLD.
- **Open Items**: Remove the `[OPEN] Back Row Damage Reduction` entry — the row system is gone and this decision has been resolved (no).

## Capabilities

### New Capabilities

_(none)_

### Modified Capabilities

- `hld-combat-system`: Update HLD-COMBAT-010, HLD-COMBAT-011, and remove the stale back-row open item.

## Impact

- `openspec/specs/hld-combat-system/spec.md` — spec text changes only, no code impact.
- LLD-ITEMS-001 already carries the Ointment/Amethyst details; no LLD changes needed.
