## 1. Spec sync

- [x] 1.1 Apply the `hld-memory-fragments` delta: `HLD-MF-004` loses the companion-swap paragraph and the "Companion swap choice" scenario; the "One companion encounter per floor" paragraph gains the sentence explaining the guarantee now holds by construction via `LLD-FLOOR-BEATS-003`.
- [x] 1.2 Apply the `lld-floor` delta: `LLD-FLOOR-BEATS-003` gains the proactive exclusion paragraph and its "Worn Map blocks companion draws before it fires" scenario.
- [x] 1.3 Grep the full spec tree for any other reference to "swap" tied to companions (e.g. `lld-companions`, `hld-companion-system`) and confirm none exist — this change assumes the swap concept was only ever documented in `HLD-MF-004`. Confirmed: only other "swap" hits are `hld-run-structure` (floor profile swap) and `hld-wandering-soul` ("direct swap" trade wording), both unrelated.

## 2. Verification

- [ ] 2.1 Re-read `HLD-MF-004` and `LLD-FLOOR-BEATS-003` after archive and confirm the "one companion encounter per floor" guarantee is now stated as a structural fact (Memory Fragment never draws Companion Encounter while an unfired Worn Map is held or after any companion has been offered), not as a player-facing fallback.
- [x] 2.2 Confirm `openspec validate` (or equivalent archive-time strict validation) passes on both modified specs. Ran `openspec validate remove-companion-swap` — valid.

## 3. Archive

- [ ] 3.1 Run `/opsx:archive` once the above is verified, to fold these deltas into `docs/openspec/specs/hld-memory-fragments/spec.md` and `docs/openspec/specs/lld-floor/spec.md`.
