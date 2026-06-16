## Context

Read the Road is the Pilgrim's passive ability: at the start of every combat, the player views the top 3 cards of the assembled omen deck and may send any number of them to the bottom. The remaining cards stay in order on top. The spec has always described the mechanic correctly (LLD-ABILITIES-005) but left the handler chain as `[OPEN·MVP1]` because no handler existed to implement it.

Separately, a sweep of all `[OPEN·MVP1]` tags found that the majority are attached to numeric values with the annotation "to be validated in playtesting." These provide no information beyond what is already universally true — all numbers are subject to playtesting — and clutter the specs with false signals that a design decision is pending.

The `peek_omen_deck` handler name is established in `LLD-ABILITIES-005`. The architecture precedent for interactive player choice mid-flow is established by the `pending_repent_slots` / `REPENT_DISCARD` pattern from `judge-arch-update`.

## Goals / Non-Goals

**Goals:**
- Remove all "unvalidated" `[OPEN·MVP1]` noise tags; leave specs reflecting only genuine open design questions
- Fully specify Read the Road: handler, CombatState field, action type, CombatResolver integration
- Keep the architecture consistent with the established Repent pattern (same pause-via-state-field, same get_legal_combat_actions gating)

**Non-Goals:**
- Implementing the `peek_omen_deck` handler or any game code
- Changing any numeric values — this change makes no gameplay balance decisions
- Addressing other `[OPEN·MVP1]` items (item tier list, MF scenario pools, Hardened/clamp interaction)

## Decisions

### Read the Road modeled as interactive player choice, mirroring Repent

**Decision:** Add `read_the_road_active: bool` to `CombatState` (default `false`). When the `peek_omen_deck` handler fires during `assemble_omen_deck`, it sets this field to `true`. `get_legal_combat_actions()` detects `read_the_road_active == true` and returns a single `READ_THE_ROAD_COMMIT` action. The player (or AIPlayerAgent) submits that action with a `send_to_bottom: Array[int]` parameter listing 0–3 indices from the top of the draw pile to move to the bottom. `resolve_player_action` handles the reorder and clears `read_the_road_active`.

**Why:** The ability requires a player decision before combat begins. The existing `pending_repent_slots` pattern (added in `judge-arch-update`) already handles exactly this pattern: a CombatState boolean/array gates `get_legal_combat_actions()` to return only the resolution action, and `resolve_player_action` handles it. Using the same pattern keeps the architecture consistent and avoids a third mechanism for player choice. The AI handles it with no special-casing — it submits any `READ_THE_ROAD_COMMIT` (e.g., send none to bottom).

**Alternative considered:** A new `RunPhase` (e.g., `READ_THE_ROAD`) — rejected for the same reason as `REPENT_CHOICE` was rejected in `judge-arch-update`: it's disproportionate complexity for a sub-state that exists only within combat setup.

### `READ_THE_ROAD_COMMIT` carries indices, not card IDs

**Decision:** The `send_to_bottom` parameter is an `Array[int]` of indices into the draw pile (0 = top card, 1 = second, 2 = third). The presentation layer (or AI) reads the actual card IDs from `combat_state.omen_deck_state.draw_pile[0..2]` directly; the action carries only which positions to move.

**Why:** Indices are stable within a single commit — the draw pile doesn't change between `read_the_road_active` being set and the commit resolving. Using indices avoids redundantly encoding card identity in the action and keeps `resolve_player_action` simple: iterate indices in descending order, pop each card, append to end of draw pile.

### `peek_omen_deck` sets the active flag, count comes from handler params

**Decision:** Handler ID is `peek_omen_deck`. Params: `{ "count": 3 }`. The handler sets `read_the_road_active = true` on CombatState. The count is stored in params rather than hard-coded in the handler, so a future vessel or item could offer a different peek depth without a new handler.

**Why:** Consistent with how `apply_mending_by_burden_tier` and similar handlers pass context through params. The handler itself is generic; content specificity (3 cards) lives in the data file.

### Cleanup: only line removals, no requirement re-numbering

**Decision:** All "to be validated in playtesting" `[OPEN·MVP1]` lines are deleted in place. The surrounding requirement blocks are otherwise unchanged. The hld-narrative visual direction tag is changed from `[OPEN·MVP1]` to `[OPEN·MVP2]`.

**Why:** These are single-line annotations. No requirement ID changes, no restructuring. The delta specs for cleanup-only files (lld-enemies, lld-omen-cards, lld-floor, lld-memory-fragments, hld-narrative) record exactly what was removed.

## Risks / Trade-offs

**`read_the_road_active` fires at combat start, before any player turn** → The presentation layer must handle this sub-state during the combat setup sequence (between `assemble_omen_deck` and the first omen draw), not during a normal turn. Mitigation: document in LLD-ARCH-019 that `resolve_player_action` can be called during combat setup when `read_the_road_active` is true; the normal turn loop does not advance until the flag is cleared.

**AIPlayerAgent during Read the Road** → The AI always has full draw pile visibility, so it gains nothing from the peek. Its policy (send none, or send a random subset) doesn't need to reflect strategic play — any legal `READ_THE_ROAD_COMMIT` is valid. Mitigation: document that AIPlayerAgent may submit `send_to_bottom: []` (keep all) as a valid degenerate strategy.

**Descending-index splice order in resolve_player_action** → When moving multiple cards to the bottom, indices must be processed in descending order to avoid shifting earlier positions mid-operation. Mitigation: spec the descending-order requirement explicitly in LLD-ARCH-019.
