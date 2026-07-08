## Why

`HLD-MF-004` (Companion Encounter) currently documents a "swap" fallback: if a
companion encounter fires while the player already holds a temporary
companion, they choose between keeping the current one or accepting the new
one. This case is a spec artifact, not an intended mechanic — the floor is
supposed to guarantee exactly one companion offer per run, and the swap
clause only exists to paper over a generation-order loophole: a random
Memory Fragment draw could offer a companion before the fixed Worn Map beat
(`LLD-FLOOR-BEATS-003`, room 4) fires, and the Worn Map beat currently
triggers unconditionally regardless of whether a companion was already
offered. The fix is to close that loophole at the source — exclude the
Companion Encounter category from Memory Fragment generation for the entire
time an unfired Worn Map is held — rather than resolve it with a
player-facing swap choice that shouldn't exist.

## What Changes

- **BREAKING**: Remove the companion-swap rule from `HLD-MF-004` — the
  paragraph describing the keep-or-swap choice, and the "Companion swap
  choice" scenario. Companion encounters remain mandatory-accept with no
  swap case to handle.
- Add a proactive exclusion rule to `LLD-FLOOR-BEATS-003`: while the player
  holds an unfired Worn Map, Memory Fragment generation SHALL exclude the
  Companion Encounter category from the draw pool. This is in addition to
  the existing after-the-fact exclusion (which applies once a companion has
  already been offered from any source). Together these guarantee only one
  companion offer per floor by construction — the swap scenario becomes
  unreachable rather than handled.

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `hld-memory-fragments`: `HLD-MF-004` loses the companion-swap paragraph
  and scenario.
- `lld-floor`: `LLD-FLOOR-BEATS-003` gains a proactive pool-exclusion rule
  covering the period before the Worn Map beat fires, closing the ordering
  loophole that made a swap reachable.

## Impact

- No code fix required today. `companion_offered_this_floor`
  (`navigation_state.gd`) and its after-the-fact set (`run_controller.gd`,
  T6.6) already exist and are unaffected — the swap fallback itself was
  never implemented, since no Memory Fragment generator exists yet to have
  coded it.
- Forward-looking debt: whoever implements the MVP2 Memory Fragment
  generator (`HLD-MF-002` category draw) must exclude the Companion
  Encounter category whenever the player holds an unfired Worn Map, not
  only after `companion_offered_this_floor` is true. Tracked in
  `docs/implementation-plan.md` Appendix B — Technical Debt so it isn't
  lost before that task is picked up.
