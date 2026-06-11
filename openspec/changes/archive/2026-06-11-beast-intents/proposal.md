## Why

Beast enemies (Plague Rat, Wolf, Bear) have stats, tags, and omen contributions defined but no intent tables — all three are tagged `[OPEN·MVP1]`. Wolves additionally require two schema extensions: a conditional pool selector (to express two distinct 50/50 distributions based on pack size) and a summon mechanism (for the Howl intent that spawns a fresh wolf). Bear Swipe is a two-hit intent that also needs a `hit_count` field.

## What Changes

- Add full intent tables to Plague Rat (`LLD-ENEMIES-006`), Wolf (`LLD-ENEMIES-007`), and Bear (`LLD-ENEMIES-008`); remove `[OPEN·MVP1]` intent stubs
- Extend `IntentConditional` with optional `intent_ids: Array[String]` — when non-empty, the random roll is restricted to only those intents from the weight pool; first-match short-circuit and single-`intent_id` forced selection are unaffected
- Extend `IntentWeight` with `summon_enemy_id: String` (empty = no summon) and `hit_count: int` (default 1, for multi-hit intents like Bear Swipe)
- Add mid-combat summon corollary to `HLD-OMEN-006` Tier 1: an enemy spawned via `summon_enemy_id` injects their family card copy into the draw pile immediately; it is removed on death following normal Tier 1 rules

## Capabilities

### New Capabilities

*(none)*

### Modified Capabilities

- `lld-enemies` — full intent tables for LLD-ENEMIES-006 (Plague Rat), LLD-ENEMIES-007 (Wolf), LLD-ENEMIES-008 (Bear)
- `lld-technical-architecture` — IntentConditional `intent_ids` field; IntentWeight `summon_enemy_id` and `hit_count` fields (LLD-ARCH-018); CombatResolver resolve_enemy_turns handling for all three (LLD-ARCH-019)
- `hld-omen-system` — HLD-OMEN-006 mid-combat summon corollary

## Impact

- `CombatResolver.resolve_enemy_turns` must handle: `intent_ids` pool filtering when a conditional matches; `summon_enemy_id` enemy spawning and omen deck injection; `hit_count > 1` multi-hit damage rolls
- `assemble_omen_deck` and `resolve_enemy_death` are unchanged — the summon path re-uses existing deck injection/removal logic
- No changes to undead, elemental, or fanatic enemy entries
- All schema additions are additive (new optional fields with zero/empty defaults)
