## Why

The current action economy forces the player (and enemies) to always deal damage on the Action bucket. Adding Evade gives both sides a meaningful defensive option — sacrificing offense for a 35% incoming miss chance that round. This creates counterplay opportunities around enemy telegraphing and durability management, and enables a new class of enemy intents.

## What Changes

- **Rename "Attack bucket" → "Action bucket"** in `HLD-COMBAT-004`. Evade is a new peer option alongside attack ability, attack item, and Default Strike. Support and Consumable buckets are unchanged and still available on an Evade turn.
- **Add `HLD-COMBAT-017` (Evade)** — new requirement defining the mechanic: 1-round duration, 35% miss chance per incoming hit, independent roll per hit on multi-hit attacks, miss also blocks status application, durability preservation on full-miss, companion interaction rules.
- **Update `LLD-ARCH-017`** — add `is_evading: bool` to both `VesselState` and `EnemyState`.
- **Update `LLD-ARCH-019`** — add miss roll logic to `resolve_player_action` (for attacks against evading enemies) and `resolve_enemy_turns` (for attacks against an evading vessel); add charge-preservation check; add Evade to `get_legal_combat_actions`.

## Capabilities

### New Capabilities

*(none — Evade extends existing systems)*

### Modified Capabilities

- `hld-combat-system`: MODIFIED `HLD-COMBAT-004` (Action bucket rename + Evade as option); ADDED `HLD-COMBAT-017` (Evade mechanic).
- `lld-technical-architecture`: MODIFIED `LLD-ARCH-017` (`is_evading` fields); MODIFIED `LLD-ARCH-019` (miss rolls, charge preservation, legal actions).

## Impact

- `openspec/specs/hld-combat-system/spec.md`
- `openspec/specs/lld-technical-architecture/spec.md`
- Spec-only change; no GDScript written here.
