## Why

`LLD-ARCH-003` defines the action command pattern but only covers combat and navigation actions. The full game loop includes non-combat phases (`NON_COMBAT_EVENT`, `LOOT_SELECTION`) that require their own action types — without these, `get_legal_actions()` has no spec for what it returns outside combat, and `AIPlayerAgent` cannot make any non-combat decision. This is the last spec gap blocking implementation of the headless core loop.

## What Changes

- Extend `LLD-ARCH-003` with action types for trades (Wandering Soul / Memory Fragment), loot selection, and companion acceptance
- Add a `LootGenerator` requirement to `lld-technical-architecture` defining how post-combat loot pool selection works (normal vs elite tier) and what `LOOT_SELECTION` phase offers the player
- Add a `resolve_enemy_death` ordering scenario to `lld-companions` clarifying that Death Mark fires before other shift-trigger statuses at the omen shift
- Add a `NON_COMBAT_EVENT` sub-state requirement clarifying what `get_legal_actions()` returns for each non-combat event type and phase

## Capabilities

### New Capabilities

_(none)_

### Modified Capabilities

- `lld-technical-architecture`: `LLD-ARCH-003` extended with non-combat action types; `LLD-ARCH-017` extended with `NavigationState` event fields; new `LLD-ARCH-022` LootGenerator and `LLD-ARCH-023` Shift Status Resolution Order added

## Impact

- `openspec/specs/lld-technical-architecture/spec.md` — LLD-ARCH-003 and LLD-ARCH-017 modified; LLD-ARCH-022 and LLD-ARCH-023 added
- Direct implementation impact: `ActionInjector`, `RunController`, `AIPlayerAgent`, `LootGenerator` all depend on requirements defined here
