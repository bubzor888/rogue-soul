## Context

The omen cycle (`HLD-OMEN-001`) is interactive: the player picks 1 of 3 drawn
cards and a side. MVP1 is a headless run driven by `ActionInjector.get_legal_
actions()`, but no action exists for the choice, and `resolve_omen_cycle_start`
step 5 ("apply the two played cards") presupposes the choice already happened.
There is also an ordering coupling: the new cycle's **timer** is the leftover
(third) card, which is only known *after* the choice — yet the Exposed shift's
**deferred Vulnerable** (`resolve_omen_cycle_start` step 4) needs that timer.

## Goals / Non-Goals

**Goals:**
- Express the omen choice as a first-class action so the AI (and later UI) drive it
  through the same `get_legal_actions()` / `submit_action()` path as everything else.
- Make the choice → timer → deferred-Vulnerable → apply ordering explicit and
  correct.
- Keep `GameState` JSON-serialisable across the choice pause.

**Non-Goals:**
- No omen-choice *UI* (MVP2). No change to the random-assignment or timer
  distribution rules. No change to non-omen actions.

## Decisions

- **Action shape:** `{ "type": "CHOOSE_OMEN", "card_index": 0..2, "side":
  "player"|"enemy" }`. `card_index` indexes `OmenCycleState.drawn_cards`; `side` is
  where the chosen card is applied.
- **Gating priority** (first match wins): `read_the_road_active` (combat setup) →
  **omen-choice** (`current_cycle != null and not sides_assigned`) → `pending_
  repent_slots` → standard. Omen-choice precedes Repent because Repent can only fire
  *during* the played-card application that the choice triggers. The omen-choice
  branch returns one `CHOOSE_OMEN` per `card_index` (0..2) × `side`
  (player/enemy) = 6 actions; always ≥1.
- **Split cycle-start vs choice:** `resolve_omen_cycle_start` fires shifts
  (`LLD-ARCH-023`), clears expired, draws 3 cards (`player_choice_index = -1`,
  `sides_assigned = false`), and records pending-Vulnerable unit ids — then stops.
  `CHOOSE_OMEN` completes the cycle: assign sides, derive `timer_index` (the
  leftover) and the cycle timer, apply deferred Vulnerable with that timer, apply
  the two played cards (step 5: tag filter, magnitude, handlers, type_convert
  replacement, Repent special handling), set `sides_assigned = true`.
- **Persist pending-Vulnerable across the pause:** add `CombatState.pending_
  vulnerable_units: Array[String]` (default `[]`). The Exposed shift writes unit
  ids here; `CHOOSE_OMEN` consumes and clears it. A new field (not a transient) is
  required because `GameState` must round-trip to JSON at any point, including
  between the draw and the choice.

## Risks / Trade-offs

- **One more schema field.** `CombatState.pending_vulnerable_units` adds to the
  serialiser (T2.2). Accepted: it is the minimal state needed to defer Vulnerable
  correctly, and it is a plain `Array[String]` (trivially serialisable).
- **Gating-order subtlety.** Placing omen-choice above Repent must hold even if a
  future card sets Repent at cycle start; current rules set Repent only during the
  post-choice application, so the order is safe. Documented so it isn't reordered.
- **AI picks uniformly.** The MVP1 random AI will choose omen cards/sides
  uniformly; that is acceptable for the determinism gate (T7.2) and is exactly the
  behaviour a strategic agent would later refine.
