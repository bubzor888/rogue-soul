## Why

Two requirements in `hld-run-structure` no longer match the current design. HLD-RUN-003 described floor depth as a pre-run player choice with duration estimates — but depth is now determined entirely by the vessel selected, which is already specified in `hld-vessel-system` (HLD-VESSEL-007). HLD-RUN-004 described a generic mini-boss / true boss split without naming the final boss, which has since been decided: all runs end at "the Judge."

## What Changes

- **HLD-RUN-003 (Floor Depth Choice)**: REMOVED. Floor depth is not a player choice — it is a property of the vessel (Tier 1 = 1 floor, Tier 2 = 2 floors, Tier 3 = 3 floors), fully specified in HLD-VESSEL-007. Duplicating it here would create two sources of truth. Duration estimates are also removed.
- **HLD-RUN-004 (Boss Structure)**: Update to name the Judge as the universal final boss on the last floor of every run. Other floor bosses (non-final floors in Tier 2 and 3 runs) are vessel-dependent.

## Capabilities

### New Capabilities

_(none)_

### Modified Capabilities

- `hld-run-structure`: Remove HLD-RUN-003; update HLD-RUN-004 to name the Judge and clarify vessel-dependent intermediate bosses.

## Impact

- `openspec/specs/hld-run-structure/spec.md` — spec text only, no code impact.
- Floor depth is the authoritative domain of `hld-vessel-system` (HLD-VESSEL-007); this change removes the duplicate.
