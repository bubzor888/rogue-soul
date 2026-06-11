## Why

The current offensive status roster has Burning (flat damage per tick) and Poisoned (escalating damage per tick). Bleed adds a third offensive pattern: front-loaded decaying damage. Where Poison rewards surviving to later ticks, Bleed rewards applying large stacks early and kills efficiently if the target can't clear it. This creates a meaningful strategic split between status types.

## What Changes

- Add **Bleed** to the status table in `HLD-COMBAT-006` with its decaying-stack mechanic: at each omen tick, the target takes physical damage equal to current stacks, then stacks are halved (floor). Bleed clears at omen reset like all statuses, and also clears early if stacks would halve to 0.
- Update `StatusInstance.magnitude` description in `LLD-ARCH-017` to explicitly cover Bleed stacks (alongside its existing use for Chilled accumulation).

## Capabilities

### New Capabilities

*(none)*

### Modified Capabilities

- `hld-combat-system`: MODIFIED `HLD-COMBAT-006` — add Bleed row to status table, add decay mechanic scenarios.
- `lld-technical-architecture`: MODIFIED `LLD-ARCH-017` — generalize `StatusInstance.magnitude` description to cover all stack-based statuses.

## Impact

- `openspec/specs/hld-combat-system/spec.md` — HLD-COMBAT-006 updated
- `openspec/specs/lld-technical-architecture/spec.md` — StatusInstance.magnitude description updated
- No code changes in this change (spec-only)
