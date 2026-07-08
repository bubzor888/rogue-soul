## 1. Spec sync

- [x] 1.1 Apply the `hld-run-structure` delta: `HLD-RUN-006` gains the Rest room exception sentence and the "Rest room is the sole room-event heal" scenario.
- [x] 1.2 Grep the spec tree for any other place that repeats or implies "no mid-floor healing" and confirm none contradict the new exception (e.g. `lld-floor`, `hld-item-system`, `hld-wandering-soul`). Only hit was `LLD-FLOOR-PATT-002`'s "healing depends on what room types the player encounters," which is consistent, not contradicting.

## 2. Verification

- [x] 2.1 Re-read `HLD-RUN-006` and `LLD-FLOOR-BEATS-006` after sync and confirm they no longer contradict each other — HLD permits exactly the one exception LLD defines. Confirmed: LLD-FLOOR-BEATS-006's "the only rest room on the floor" matches HLD-RUN-006's "exactly one exception."
- [x] 2.2 Confirm `openspec validate` passes on the modified spec. Ran `openspec validate fix-rest-room-heal-contradiction` — valid.

## 3. Archive

- [x] 3.1 Run `/opsx:archive` once the above is verified, to fold this delta into `docs/openspec/specs/hld-run-structure/spec.md`.
