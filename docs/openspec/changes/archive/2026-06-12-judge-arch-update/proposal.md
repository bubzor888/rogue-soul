## Why

The Judge boss design (archived `2026-06-12-the-judge-boss-design`) deferred all `lld-technical-architecture` changes to a follow-on change. The Judge introduces four mechanics that have no current architectural expression: a whole-run item burden score, tier-scaled witness intents, on-death status consequences for killed enemies, and an interactive item-discard choice when the Repent omen card fires on the player side.

## What Changes

- **New**: `item_burden_score: int` field on GameState — whole-run tracking of the soul's accumulated item burden (see HLD-RUN-007)
- **New**: `pending_repent_slots: Array[int]` field on CombatState — tracks which item slots are revealed and awaiting player discard choice when Repent fires
- **New**: `REPENT_DISCARD` action type in the action command pattern — the only legal action when a Repent choice is pending
- **New**: `item_discarded` signal on SignalBus — emitted by CombatResolver when Repent causes an item discard; distinct from `item_broken` (charge exhaustion via ActionInjector)
- **New**: `on_death_apply_to_player: String` and `on_death_apply_magnitude: int` fields on EnemyData — colon-encoded status applied to player when this enemy dies; remaining_ticks equals current cycle's remaining ticks; covers Witness kill consequences and Plague Rat's on-death Poison (pre-existing gap)
- **New**: `handlers: Array[HandlerConfig]` field on IntentWeight — enables intents whose effect cannot be expressed as a static `status_magnitude` (Witness intents scale by burden score tier at resolution time)
- **New**: `hp_percent_lte:N` condition form on IntentConditional — the Judge's Pass Judgment phase requires ≤30% HP (less-than-or-equal); only `hp_below_percent:N` (strict less-than) currently exists
- **Modified**: CombatResolver `get_legal_combat_actions`, `resolve_player_action`, `resolve_omen_cycle_start`, and `resolve_enemy_death` — updated to handle the new mechanics above

## Capabilities

### New Capabilities

_(none — all changes are extensions to existing `lld-technical-architecture` requirements)_

### Modified Capabilities

- `lld-technical-architecture`: Multiple requirement updates across LLD-ARCH-003, LLD-ARCH-009, LLD-ARCH-017, LLD-ARCH-018, and LLD-ARCH-019

## Impact

- `lld-technical-architecture/spec.md` — modified requirements in five LLD-ARCH requirements
- Implementation: GameState, CombatState, EnemyData, IntentWeight, IntentConditional resource schemas; CombatResolver methods; ActionInjector legal action set; SignalBus signal catalogue; RunController burden score initialization and update hooks
