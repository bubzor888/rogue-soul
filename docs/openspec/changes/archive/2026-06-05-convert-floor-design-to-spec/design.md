## Context

The floor encounter design doc (v0.1) covers Floor 3 — The Threshold. It is the structural blueprint for `NavigationModel` and `EncounterFactory`. The key architectural insight: the floor does NOT use a fixed room sequence but instead tracks combat/event counters to enforce pacing invisibly while preserving the appearance of player agency.

## Goals / Non-Goals

**Goals:**
- Floor 3's structure, composition, and pacing system captured as requirements
- Four forced beats documented with their trigger conditions and effects
- Door display rules captured (full identity on combat, symbol-only on non-combat)
- Open questions (counter thresholds, companion pool, Judge mechanics) carried as `[OPEN]`

**Non-Goals:**
- Designing any floor other than Floor 3
- Designing the Judge (flagged as `[OPEN]` — requires a dedicated session)
- Designing the temporary companion pool (companion design session required)

## Decisions

### Requirement ID Scheme
- `lld-floor-structure`: `LLD-FLOOR-STRUCT-001` onwards
- `lld-encounter-patterns`: `LLD-FLOOR-PATT-001` onwards  
- `lld-door-system`: `LLD-FLOOR-DOOR-001` onwards

### Relationship to HLD-RUN specs
`HLD-RUN-001` through `HLD-RUN-005` cover the high-level navigation system (corridor, symbols, depth choice, boss structure, floor profiles). These LLD specs add the Floor 3-specific implementation detail on top of those foundations.

## Risks / Trade-offs

- **Counter thresholds are placeholders** — the Combat Lock trigger (≥2 events, <2 combats) is confirmed as a design but the specific numbers are flagged for playtesting tuning.
- **Judge is entirely undefined** — the boss design is blocked on a dedicated session. The spec will carry this as `[OPEN]`.
