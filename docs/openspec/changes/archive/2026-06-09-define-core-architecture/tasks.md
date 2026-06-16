## Tasks

### Spec Fixes

- [x] **ARCH-007 SignalBus layer fix** — In `openspec/specs/lld-technical-architecture/spec.md`, update `LLD-ARCH-007` Autoloads table: move SignalBus from Application layer to Infrastructure layer. Add the RunController note ("RunController is NOT an autoload. It is an Application-layer node instantiated per run and freed when it ends").
- [x] **ARCH-009 SignalBus decoupling fix** — In `openspec/specs/lld-technical-architecture/spec.md`, update `LLD-ARCH-009` to reference SignalBus as Infrastructure (not Application). Replace the current 2-signal stub table with the full MVP1 signal catalogue (16 signals as defined in the delta spec).
- [x] **ARCH-013 EventLog path fix** — In `openspec/specs/lld-technical-architecture/spec.md`, update `LLD-ARCH-013` to change storage path from `playtests/` to `user://logs/`. Add the clarifying note that `user://` is writable in all build configurations including exports.

### New Requirements

- [x] **Add ARCH-016 RunController** — Append `LLD-ARCH-016` (RunController) to `openspec/specs/lld-technical-architecture/spec.md`. Covers: RunPhase enum, replenishment event IDs, save trigger types, SignalBus emissions, and lifecycle (instantiated per run, freed at RUN_END).
- [x] **Add ARCH-017 GameState and Domain Entities** — Append `LLD-ARCH-017` (GameState and Domain Entities) to `openspec/specs/lld-technical-architecture/spec.md`. Covers: GameState fields, VesselState, AbilityState, ItemInstance, StatusInstance, CompanionState, NavigationState, DoorData, CombatState, EnemyState, OmenDeckState, OmenCycleState.
- [x] **Add ARCH-018 Data Resource Schemas** — Append `LLD-ARCH-018` (Data Resource Schemas) to `openspec/specs/lld-technical-architecture/spec.md`. Covers: AbilityData, HandlerConfig, VesselData, EnemyData (with IntentWeight and IntentConditional), CompanionData.
- [x] **Add ARCH-019 CombatResolver** — Append `LLD-ARCH-019` (CombatResolver) to `openspec/specs/lld-technical-architecture/spec.md`. Covers: RefCounted class in `src/domain/`, full interface, dependency injection, damage resolution order.
- [x] **Add ARCH-020 AIPlayerAgent** — Append `LLD-ARCH-020` (AIPlayerAgent) to `openspec/specs/lld-technical-architecture/spec.md`. Covers: RefCounted class in `src/application/`, Random strategy, RunResult record, separate RNG from game streams.

### Cleanup

- [x] **Remove stale T-2 follow-on note** — In `openspec/specs/hld-combat-system/spec.md`, delete the `### [FOLLOW-ON] Resolve T-2 in hld-technical-architecture` block from the Open Items section. T-2 (action economy) was resolved by HLD-COMBAT-004; the note is obsolete.
