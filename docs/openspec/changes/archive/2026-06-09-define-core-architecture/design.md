## Context

The existing `lld-technical-architecture` spec defines the skeleton of the architecture — layers, patterns, autoloads, naming conventions — but leaves the core runtime objects undefined. Before any implementation can begin, three questions must be answerable from the spec alone:

1. What is in GameState? (Needed by ActionInjector, CombatResolver, SaveManager, AIPlayerAgent)
2. What resource schema does the pipeline read? (Needed by AbilityPipeline, all registries)
3. Who orchestrates run phases and when? (Needed by ChargeManager, ScreenManager, SaveManager)

This change answers all three, plus fixes the SignalBus layer violation and two minor correctness issues.

## Goals / Non-Goals

**Goals:**
- Define every domain entity type needed for MVP1
- Define the data resource schemas that registries load from disk
- Define RunController's phases, signals, and save trigger points
- Define CombatResolver's interface and enemy intent model
- Fix SignalBus layer classification
- Fix EventLog storage path

**Non-Goals:**
- No HLD design decisions — all game rules remain in hld-combat-system and friends
- No content definitions — specific enemies, items, vessels remain in their LLD specs
- No code — spec definitions only
- Companion HP / targetability (confirmed: companions are untargetable, no HP field needed)

## Decisions

**SignalBus → Infrastructure (not Application)**
SignalBus is a passive message relay with no game logic. Domain code must emit on it (LLD-ARCH-009). Placing it in Application creates a layer violation: Domain → Application. Moving it to Infrastructure resolves this cleanly — Infrastructure is exactly for passive services that all layers may use.

**RunController as Application non-autoload**
RunController is per-run state, not global singleton state. An autoload lives for the entire application session; a run can end and restart without restarting the application. RunController is instantiated when a run begins (under a `GameScene` node) and freed when it ends. ScreenManager and SaveManager connect to its SignalBus emissions, not to it directly — so they never hold a reference to it.

**GameState as a flat Resource tree, not a single monolithic class**
GameState is composed of typed sub-Resources (VesselState, CombatState, etc.) rather than inlining all fields. This keeps each sub-type independently unit-testable and makes partial-state cloning cheap (clone only CombatState for AI branching within a fight).

**EnemyData intent model: weighted random with conditional override**
Conditionals (e.g. `"hp_below_percent:50" → defend`) are evaluated first. If any condition matches, that intent is selected deterministically — no RNG roll. If no condition matches, a weighted random roll against the COMBAT stream selects from `intent_weights`. This gives designers full control (pure conditional = scripted pattern; pure weights = random; mix = conditional fallback). The `current_intent` field in EnemyState is set at the start of each enemy turn and stored in state — this is what the UI telegraphs (HLD-COMBAT-009).

**ItemData = AbilityData**
Items and abilities use the same `AbilityData` resource schema. The distinction (item vs ability) is entirely where the registry places them: abilities live in `ability_states` on `VesselState`, items live in `inventory` on `GameState`. AbilityPipeline processes both identically. This avoids a redundant `ItemData` schema.

**CompanionData uses same handler chain as AbilityData**
Companions act automatically at `"turn_end"` via the same AbilityPipeline. They have no HP and are not targetable (confirmed). CompanionData is a slim wrapper: companion_id, omen_contributions, a trigger event string, and a handler chain. This reuses the existing pipeline without special-casing.

**Save triggers via SignalBus, not direct SaveManager calls**
RunController emits `save_requested(SaveType)` on SignalBus. SaveManager handles it. This keeps RunController free of any knowledge of how or where saves are stored. `SaveType` enum: `BACKGROUND` (after door choice, silent) and `CHECKPOINT` (after floor completion, player-visible resume/restart option on next load).

**EventLog path: `user://logs/` not `playtests/`**
`playtests/` is a project-relative directory used for human-authored playtest note files committed to version control. The automated event log is a user-generated runtime artifact and must use `user://`, which is writable in exported builds on all platforms.

## Risks / Trade-offs

- **Risk: Dictionary params in HandlerConfig is untyped** → Startup validation (LLD-ARCH-005) catches unknown handler_ids; param validation is the handler's responsibility at runtime. Acceptable for MVP scale.
- **Risk: OmenCycleState with -1 sentinel for "not yet chosen"** → Alternative is nullable sub-resource, but that adds null checks everywhere. Sentinel integer is simpler in GDScript. Document the convention clearly.
- **Risk: CompanionData trigger string is loosely typed** → Trigger IDs are defined as constants in ReplenishEvents (LLD-ARCH-011). Companion triggers reuse that same constant set. Startup validation can check them.
