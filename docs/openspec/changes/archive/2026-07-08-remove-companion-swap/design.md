## Context

`HLD-MF-004` guarantees one companion offer per floor and names two sources
that can produce that offer: a Memory Fragment Companion Encounter draw, or
the fixed Worn Map beat at room 4 (`LLD-FLOOR-BEATS-003`). The one-per-floor
guarantee is currently enforced *after the fact*: once either source has
fired, the Companion Encounter category is removed from the Memory Fragment
pool for the rest of the floor. That leaves a window — rooms 1–3, before the
Worn Map beat can fire — where a Memory Fragment could still draw Companion
Encounter and offer a companion. The Worn Map beat then fires unconditionally
at room 4 regardless of what happened earlier, producing a second offer.
`HLD-MF-004`'s swap paragraph exists solely to give the player something to
do in that second-offer case. This is a spec-completeness patch for a bug in
the generation order, not an intended piece of player-facing design.

## Goals / Non-Goals

**Goals:**
- Make "at most one companion offer per floor" true by construction, not by
  handling a second offer gracefully.
- Remove the swap mechanic from `HLD-MF-004` entirely — companion
  encounters stay mandatory-accept, full stop.
- Close the ordering loophole in `LLD-FLOOR-BEATS-003` so the Worn Map beat
  can never fire after a Memory Fragment has already granted a companion.

**Non-Goals:**
- Not changing anything about companion mechanics, departure conditions, or
  flavour text (`lld-companions`).
- Not changing the Worn Map's 3-encounter counter or its removal-on-trigger
  behavior — only adding a pool-exclusion condition ahead of it.
- Not touching Category A/C Memory Fragment generation.

## Decisions

**Exclude Companion Encounter from the Memory Fragment pool for the entire
time an unfired Worn Map is held, not just after a companion has been
offered.**

Today the exclusion condition is effectively `companion_offered_this_floor`.
This change adds a second, independent condition: `player holds an unfired
Worn Map`. Either condition excludes the category. Since the Worn Map is a
guaranteed future companion source, there's never a reason for Memory
Fragment to also roll one while the Worn Map is still live — doing so is
exactly the redundant-offer case the swap clause was invented to handle.

Alternative considered: keep the swap clause and just accept the
double-offer as a rare, harmless edge case. Rejected — the user's read is
that the one-companion-per-floor guarantee should hold structurally, and a
player-facing "choose which companion to keep" moment undercuts the
intended weight of the companion encounter beat.

Alternative considered: make the Worn Map beat check
`companion_offered_this_floor` and skip itself (refund/no-op) if a Memory
Fragment already granted a companion, rather than excluding the category
upstream. Rejected — this would mean the Worn Map sometimes fizzles with no
payoff for the player after 3 encounters of countdown, which is worse
player experience than simply never letting the conflict arise.

## Risks / Trade-offs

- **[Risk]** A future implementation could implement the Worn Map's
  3-encounter counter and the Memory Fragment category draw as
  independently-owned systems that don't share the necessary inventory
  check. → **Mitigation**: `LLD-FLOOR-BEATS-003`'s new requirement text
  states the exclusion explicitly as a Memory Fragment generation
  precondition, so it's visible from either system's spec.
- **[Risk]** None to existing runtime code — MVP2 has no engine
  implementation of Memory Fragment generation or the Worn Map beat yet, so
  this is a pre-implementation correction with no migration surface.

## Open Questions

None — this is a straightforward spec correction with no unresolved design
decisions.
