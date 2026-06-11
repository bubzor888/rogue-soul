## Why

`lld-technical-architecture` defines several systems by name (RunController, CombatResolver, SignalBus, HandlerConfig, AIPlayerAgent) but leaves their structure, interfaces, and domain entity model entirely undefined. These are load-bearing abstractions for MVP1 — nothing in the headless game loop can be implemented without them. Additionally, SignalBus is misclassified as Application layer while Domain code is required to emit on it, a direct layer violation.

## What Changes

- **Fix LLD-ARCH-007**: Move SignalBus from Application → Infrastructure; add clarification that RunController is Application layer but NOT an autoload
- **Fix LLD-ARCH-009**: Update SignalBus layer reference; replace 2-signal stub with full MVP1-relevant signal list
- **Fix LLD-ARCH-013**: Correct EventLog storage path from `playtests/` (read-only in exports) to `user://logs/`
- **Add LLD-ARCH-016**: RunController — run phases, replenishment event IDs, save trigger points, SignalBus emissions
- **Add LLD-ARCH-017**: GameState and Domain Entities — full field tree for GameState and all sub-types (VesselState, EnemyState, ItemInstance, StatusInstance, CompanionState, CombatState, OmenDeckState, OmenCycleState, NavigationState)
- **Add LLD-ARCH-018**: Data Resource Schemas — the `.tres` file schemas that registries load from disk: AbilityData, HandlerConfig, VesselData, EnemyData (including weighted intent + conditional model), CompanionData
- **Add LLD-ARCH-019**: CombatResolver — Domain layer class, full interface definition, enemy intent resolution model
- **Add LLD-ARCH-020**: AIPlayerAgent — Random strategy for MVP1, interface, RunResult record
- **Remove follow-on note** in `hld-combat-system` about T-2: the T-2 reference is stale (T-2 action economy is closed by HLD-COMBAT-004 and the action command pattern; no ARCH requirement contains an open T-2 item)

## Capabilities

### New Capabilities

None — all changes are to existing capabilities.

### Modified Capabilities

- `lld-technical-architecture`: 3 fixes + 5 new requirements (ARCH-016 through ARCH-020)
- `hld-combat-system`: remove stale T-2 follow-on note from Open Items section

## Impact

- `openspec/specs/lld-technical-architecture/spec.md` — primary target
- `openspec/specs/hld-combat-system/spec.md` — cleanup only (stale follow-on note removal)
- No code changes — spec-only; these requirements are prerequisites for implementation, not implementation itself
