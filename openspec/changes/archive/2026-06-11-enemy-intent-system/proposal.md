## Why

Enemies currently have flat damage values and no decision model — each enemy acts as a single-action automaton with no turn-to-turn variation and no counterplay signal. This change establishes the HLD rules for how enemies choose actions, introduces variable enemy damage ranges (with flat player damage as a deliberate asymmetry), and applies the first two intent tables to the Skeleton and Zombie.

## What Changes

- Add HLD-COMBAT rules for the enemy intent system: weighted random selection, trigger overrides, Charge→Release multi-turn pattern, consecutive intent limiting via re-roll, enemy damage variance, and Chilled idempotency.
- Add a runtime field note to the technical architecture: `EnemyInstance` requires `last_intent_id` and `intent_streak` fields to support consecutive intent limiting.
- Add `**Intents:**` sections to `LLD-ENEMIES-004` (Skeleton) and `LLD-ENEMIES-005` (Zombie) with their settled intent tables and damage ranges.
- Update Skeleton and Zombie kill reference scenarios to reflect that enemies no longer attack every turn.

## Capabilities

### New Capabilities

*(none — all content goes into existing specs)*

### Modified Capabilities

- `hld-combat-system`: Add enemy intent selection rules (HLD-COMBAT-009 expansion), Charge→Release pattern, consecutive limiting, enemy damage variance asymmetry, and Chilled idempotency.
- `lld-technical-architecture`: Add `EnemyInstance` runtime fields note for intent streak tracking.
- `lld-enemies`: Add intent tables to Skeleton (`LLD-ENEMIES-004`) and Zombie (`LLD-ENEMIES-005`), and update their damage values to ranges.

## Impact

- `openspec/specs/hld-combat-system/spec.md` — new and modified requirements
- `openspec/specs/lld-technical-architecture/spec.md` — implementation note on `EnemyInstance`
- `openspec/specs/lld-enemies/spec.md` — Skeleton and Zombie entries updated
- No code changes in this change (spec-only)
