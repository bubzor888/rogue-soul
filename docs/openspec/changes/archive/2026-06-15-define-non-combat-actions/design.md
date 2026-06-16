## Context

`LLD-ARCH-003` defines the action command pattern but only covers six action types: `USE_ABILITY`, `USE_ITEM`, `END_TURN`, `CHOOSE_DOOR`, `REPENT_DISCARD`, and `READ_THE_ROAD_COMMIT`. The game loop has three additional phases — `NON_COMBAT_EVENT`, `LOOT_SELECTION` — that `get_legal_actions()` must handle. Without defined action types, `AIPlayerAgent` cannot make decisions in these phases and the headless loop cannot complete a run.

Additionally, the arch spec doesn't define how post-combat loot pool selection works (which pool, how many options, normal vs elite tier) or where in-flight trade/loot offers are stored in `GameState`. And the Death Mark shift ordering needs a single sentence to prevent ambiguity during implementation.

## Goals / Non-Goals

**Goals:**
- Define all missing non-combat action types with the same rigor as existing combat actions (payload, legal conditions, resolution rules)
- Add `LootGenerator` to mirror `TradeGenerator` — a single class owns loot offer construction
- Extend `NavigationState` to hold in-flight offers so `GameState` is fully self-contained and serialisable at any point
- Clarify Death Mark fires before other shift-trigger statuses at Step 1 of `resolve_omen_cycle_start`

**Non-Goals:**
- Defining loot table weights or drop rates (those follow from item pools in `lld-items`)
- Defining the rest room's HP restoration value (`[OPEN·MVP2]` per vessel HP tuning)
- Any UI presentation of non-combat events

## Decisions

**Companion encounter has no action type — RunController processes it automatically.** HLD-MF-004 makes companion encounters mandatory with no swap possible on Floor 3. RunController transitions from `NON_COMBAT_EVENT` to `NAVIGATION` after applying the companion; `get_legal_actions()` never returns a companion choice action.

**Rest room has no action type — it fires automatically on room entry.** RunController applies the HP restoration when entering the rest room and transitions immediately to `NAVIGATION`. No player decision needed.

**Category C uses `ACCEPT_OPTION_1` / `ACCEPT_OPTION_2` rather than `ACCEPT_TRADE`.** The two-option structure with no walk-away is semantically different from Cat A / Wandering Soul trades (which have `DECLINE_TRADE`). Separate action types make `get_legal_actions()` unambiguous about what's legal.

**Offers stored in `NavigationState`, not a new `EventState`.** Adding `event_offers`, `event_type`, and `loot_offers` to `NavigationState` keeps `GameState` a single flat hierarchy. A separate `EventState` sub-resource would be another null-checked optional alongside `CombatState` — unnecessary complexity for what are small arrays.

**`LootGenerator` is a new Application-layer class parallel to `TradeGenerator`.** It encapsulates pool selection (normal vs elite), item drawing via LOOT stream, and the two-offer array construction. Keeping it separate from `TradeGenerator` preserves the single-responsibility boundary.

**Death Mark fires first in the shift status sequence.** The order is: `death_mark` → `shocked` → `exposed`. This means enemies die before stun or vulnerability is applied in the same shift cycle. Captured as `LLD-ARCH-023` (ADDED, not MODIFIED on LLD-ARCH-019) to avoid copying the entire large requirement block.

## Risks / Trade-offs

[Rest HP value is undefined] `[OPEN·MVP2]` — rest room applies HP restoration but the amount is not yet set. RunController must handle a sentinel value (0 or -1) that means "placeholder — do not apply HP yet." This is acceptable for MVP1 headless since the AIPlayerAgent's win/loss outcome doesn't depend on the exact HP restored.

[Loot offers may contain duplicates] If a pool has only one item entry, `LootGenerator` may draw the same item_id twice. The player sees two identical options but can only take one — this is acceptable and avoids complexity. The pool sizes in `lld-items` make this unlikely in practice.
