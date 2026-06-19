## ADDED Requirements

### Requirement: [LLD-ARCH-024] Omen Choice Action
The player's omen-card choice (`HLD-OMEN-001` — pick one of the three drawn cards and a side) SHALL be expressed as a first-class `CHOOSE_OMEN` action submitted through `ActionInjector`, not as a hidden engine side effect. This makes the choice drivable by the AI (MVP1) and the UI (MVP2) through the same `get_legal_actions()` / `submit_action()` path as all other decisions.

**Action command** (extends the `LLD-ARCH-003` command set):

```
{ "type": "CHOOSE_OMEN", "card_index": N, "side": "player" | "enemy" }
```

`card_index` is an index (0–2) into `OmenCycleState.drawn_cards`; `side` is the side the chosen card is applied to.

**State** (extends the `LLD-ARCH-017` `CombatState`): `CombatState` SHALL have a `pending_vulnerable_units: Array[String]` field (default `[]`). The Exposed shift trigger writes the affected unit ids here at cycle start; `CHOOSE_OMEN` consumes and clears it. The field exists because `GameState` MUST remain JSON-serialisable between the cycle draw and the choice (the deferred Vulnerable cannot be applied until the new cycle timer is known, which is only after the choice).

**Gating** (extends `LLD-ARCH-019` `get_legal_combat_actions()`): the priority-ordered gating becomes:
1. `combat_state.read_the_road_active` → only `READ_THE_ROAD_COMMIT`.
2. **Omen choice pending** — `combat_state.current_cycle != null` and `current_cycle.sides_assigned == false` → only `CHOOSE_OMEN` actions, one per `card_index` (0–2) × `side` (`"player"`, `"enemy"`). At least one action is always returned.
3. `combat_state.pending_repent_slots` non-empty → only `REPENT_DISCARD` actions.
4. Otherwise the standard action set.

Omen choice precedes Repent because `pending_repent_slots` is only set *during* the played-card application that `CHOOSE_OMEN` triggers (Repent steered to the player side), so the two gates never compete at the same instant.

**Resolution** (extends `LLD-ARCH-019` `resolve_player_action()`): on a `CHOOSE_OMEN` action:
- Validate `current_cycle` exists and `sides_assigned == false`; `card_index` in `[0, drawn_cards.size()-1]`; `side` in `{"player","enemy"}`. On any failure, log an error and return state unchanged (per `LLD-ARCH-003`).
- Set `current_cycle.player_choice_index = card_index` and record the chosen side.
- Randomly select one of the other two indices via the COMBAT stream as `random_assignment_index`; it is applied to the opposite side.
- The remaining index becomes `timer_index`; the new cycle timer is `drawn_cards[timer_index].timer_value`.
- Apply the deferred Vulnerable: for each unit id in `combat_state.pending_vulnerable_units`, apply `"vulnerable:physical"` with `remaining_ticks = new cycle timer` (this is `resolve_omen_cycle_start` Step 4, deferred until the timer is known); then clear `pending_vulnerable_units`.
- Apply the two played cards (the existing `resolve_omen_cycle_start` Step 5: tag filtering, magnitude rules, `OmenCardData.handlers`, Type Convert replacement, and Repent special handling).
- Set `current_cycle.sides_assigned = true`.

**Cycle-start restructure** (modifies `LLD-ARCH-019` `resolve_omen_cycle_start()`): it SHALL fire shift-triggered statuses (`LLD-ARCH-023`), clear expired statuses, draw 3 cards into a new `OmenCycleState` (with `player_choice_index = -1`, `sides_assigned = false`), record the Exposed-marked unit ids into `combat_state.pending_vulnerable_units`, and then return — pausing for the `CHOOSE_OMEN` action. Steps 4 (deferred Vulnerable) and 5 (apply played cards) are no longer performed inline; they move to `CHOOSE_OMEN` resolution because the new cycle timer is the leftover card and is unknown until the choice.

#### Scenario: Omen choice pending returns only CHOOSE_OMEN actions
- **WHEN** `combat_state.current_cycle` is non-null with `sides_assigned == false` and `read_the_road_active` is false
- **THEN** `get_legal_combat_actions()` returns only `CHOOSE_OMEN` actions — one per `card_index` (0–2) and `side` (`"player"`, `"enemy"`) — and no standard or Repent actions

#### Scenario: read_the_road_active takes priority over omen choice
- **WHEN** both `read_the_road_active` is true and an omen choice is pending
- **THEN** `get_legal_combat_actions()` returns only `READ_THE_ROAD_COMMIT`

#### Scenario: CHOOSE_OMEN assigns sides and derives the timer
- **WHEN** the player submits `CHOOSE_OMEN` with `card_index: 1, side: "enemy"` and `drawn_cards` has three entries
- **THEN** `player_choice_index` is 1 (applied to the enemy side); one of indices `{0, 2}` is chosen via the COMBAT stream as `random_assignment_index` (applied to the player side); the remaining index becomes `timer_index`; the new cycle timer is that card's `timer_value`; `sides_assigned` is set to true

#### Scenario: Deferred Vulnerable applied with the new cycle timer
- **WHEN** an Exposed status fired at cycle start (recording a unit in `pending_vulnerable_units`) and the player then submits `CHOOSE_OMEN`
- **THEN** a `"vulnerable:physical"` StatusInstance is applied to that unit with `remaining_ticks` equal to the new cycle timer; `pending_vulnerable_units` is cleared

#### Scenario: Invalid CHOOSE_OMEN leaves state unchanged
- **WHEN** `submit_action()` receives a `CHOOSE_OMEN` with `card_index` out of range or when no omen choice is pending
- **THEN** an error is logged and the GameState is returned unchanged; no exception is raised
