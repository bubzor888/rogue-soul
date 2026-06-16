## 1. Apply the spec correction

- [x] 1.1 In `openspec/specs/lld-technical-architecture/spec.md`, update the `LLD-ARCH-017` scenario "item_burden_score initialized at run start": change the WHEN to "a Pilgrim run begins (Pilgrim has 3 starting items: Walking Staff, Spoiled Potion, Worn Map — see `LLD-ITEMS-004`)" and the THEN to "`game_state.item_burden_score` is initialized to 3 (1 per starting item per HLD-RUN-007)".
- [x] 1.2 Confirm no other scenario in `LLD-ARCH-017` was altered (diff the requirement block against the pre-change version — only the burden-init scenario changes).

## 2. Verify consistency across specs

- [x] 2.1 Confirm `HLD-RUN-007` is unchanged and still states +1 per starting item (its generic 2-item illustration scenario remains correct).
- [x] 2.2 Confirm `LLD-ITEMS-004` still lists exactly three Pilgrim starting items (Walking Staff, Spoiled Potion, Worn Map) — the source of truth; no edit needed.
- [x] 2.3 Grep the specs for any other "1 starting item" / Pilgrim burden assertions to ensure none remain inconsistent.

## 3. Sync downstream plan reference

- [x] 3.1 In `docs/implementation-plan.md`, update the T8.2 and Appendix A flags to note the contradiction is resolved: Pilgrim burden init = 3 (per `LLD-ITEMS-004` / corrected `LLD-ARCH-017`).
