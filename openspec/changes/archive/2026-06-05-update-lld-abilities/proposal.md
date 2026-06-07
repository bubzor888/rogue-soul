## Why

`lld-abilities` was written early and has accumulated several issues. LLD-ABILITIES-001 (the handler library table) contains stale entries (`force_row`, `summon_unit`, `deal_physical_damage` with row modifier) that no longer reflect the current design — rather than patch it piecemeal, it should be removed and revisited once the full LLD pass is complete. LLD-ABILITIES-002 (handler naming convention) is an architectural coding convention, not an ability design spec — it belongs in `lld-technical-architecture`. LLD-ABILITIES-004 still references `attack_type: MELEE` and a row-based scenario, both removed with the row system.

## What Changes

- **LLD-ABILITIES-001 (Ability Handler Library)**: REMOVED. The handler table is stale and will be redefined in a dedicated session once all LLD specs are reviewed. `[OPEN·MVP1]`
- **LLD-ABILITIES-002 (Handler Naming Convention)**: REMOVED from `lld-abilities`. ADDED to `lld-technical-architecture` as LLD-ARCH-012 — it is a code architecture rule, not an ability design rule.
- **LLD-ABILITIES-004 (Default Strike — Throw Rock)**: Remove `attack_type: MELEE` from the handler chain; remove the row-based scenario and the reference to the removed HLD-COMBAT-002.

## Capabilities

### New Capabilities

_(none)_

### Modified Capabilities

- `lld-abilities`: Remove LLD-ABILITIES-001 and LLD-ABILITIES-002; update LLD-ABILITIES-004.
- `lld-technical-architecture`: Add LLD-ARCH-012 (Handler Naming Convention).

## Impact

- `openspec/specs/lld-abilities/spec.md` — remove two requirements, update one.
- `openspec/specs/lld-technical-architecture/spec.md` — one new requirement appended.
