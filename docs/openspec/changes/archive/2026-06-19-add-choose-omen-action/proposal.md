## Why

`HLD-OMEN-001` requires that each combat cycle the **player chooses one of three
drawn omen cards and a side** to apply it to (one of the remaining two is applied
randomly to the other side; the third becomes the cycle timer). `OmenCycleState`
already has the fields for this (`player_choice_index`, `random_assignment_index`,
`sides_assigned`), but the MVP1 action set (`LLD-ARCH-003`) has **no action** to
express that choice. Building the omen system (T5.4) surfaced the gap: a headless
MVP1 run is driven entirely by `ActionInjector.get_legal_actions()`, so the AI
needs a legal action to make (or the engine to auto-resolve) the omen choice.
Resolving it as an explicit action keeps the choice inside the uniform
action/ActionInjector model rather than as a hidden side effect.

## What Changes

- Add a `CHOOSE_OMEN` command to `LLD-ARCH-003`:
  `{ "type": "CHOOSE_OMEN", "card_index": 0..2, "side": "player"|"enemy" }`.
- `LLD-ARCH-019` `get_legal_combat_actions()` gains an **omen-choice gating
  branch** (priority: `read_the_road_active` → omen-choice → `pending_repent_slots`
  → standard). While a choice is pending it returns only `CHOOSE_OMEN` actions —
  one per `card_index` × `side`.
- `LLD-ARCH-019` `resolve_player_action()` gains `CHOOSE_OMEN` handling: set the
  player's card/side, randomly assign one of the other two cards to the opposite
  side (COMBAT stream), make the leftover card the timer, then apply the deferred
  Vulnerable (with the now-known timer) and the two played cards.
- `LLD-ARCH-019` `resolve_omen_cycle_start()` is restructured: it fires shifts,
  clears, draws 3 cards, **records pending-Vulnerable unit ids**, and pauses for
  the choice — it no longer applies steps 4–5 inline (those move to `CHOOSE_OMEN`,
  because the new cycle timer is the leftover card and is unknown until the choice).
- `LLD-ARCH-017` `CombatState` gains a `pending_vulnerable_units: Array[String]`
  field so the Exposed shift's deferred Vulnerable survives the choice pause.
- No behaviour change to any non-omen action.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `lld-technical-architecture`: `LLD-ARCH-003` (new action), `LLD-ARCH-019`
  (gating + resolver flow), `LLD-ARCH-017` (CombatState field).

## Impact

- Specs: `docs/openspec/specs/lld-technical-architecture/spec.md` — `LLD-ARCH-003`,
  `LLD-ARCH-019`, `LLD-ARCH-017`.
- Code (implemented in T5.4): `CombatResolver.get_legal_combat_actions`,
  `resolve_player_action`, `resolve_omen_cycle_start`; `CombatState` schema +
  serialisation; the omen draw/apply machinery.
- AIPlayerAgent (T7.1) gets `CHOOSE_OMEN` for free via `get_legal_actions()`.
