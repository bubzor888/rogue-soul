## 1. Schema

- [ ] 1.1 Add `pending_vulnerable_units: Array[String]` (default `[]`) to
      `src/domain/combat_state.gd` with `to_json`/`from_json` (assign via
      `Serde.str_array`); update `tests/test_game_state.gd` round-trip coverage.

## 2. Resolver — gating & resolution (T5.4)

- [ ] 2.1 Add the omen-choice gating branch to
      `CombatResolver.get_legal_combat_actions` (priority: read_the_road →
      omen-choice → repent → standard); returns one `CHOOSE_OMEN` per
      `card_index` × `side`.
- [ ] 2.2 Implement `CHOOSE_OMEN` handling in `resolve_player_action`: validate;
      set choice + side; random-assign one of the other two via COMBAT; leftover →
      timer; apply deferred Vulnerable with the new timer; apply the two played
      cards (step 5); set `sides_assigned`.
- [ ] 2.3 Restructure `resolve_omen_cycle_start` to fire shifts, clear, draw 3,
      record pending-Vulnerable unit ids, and pause (no inline step 4/5).

## 3. Verify

- [ ] 3.1 Unit-test the gating priority, CHOOSE_OMEN side/timer derivation,
      deferred-Vulnerable application, and invalid-action safety (extends
      `tests/test_combat_resolver.gd`). Full suite green headless.
