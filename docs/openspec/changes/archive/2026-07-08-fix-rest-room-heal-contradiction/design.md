## Context

`HLD-RUN-006` was written before the Rest room existed in the spec set — its
"no mid-floor HP restoration from room events" line was true when the only
non-combat healing path was Wandering Soul trades (which are player-initiated
item/HP exchanges, not passive room-event healing) and combat items. The
Rest room (`LLD-FLOOR-BEATS-006`, `LLD-FLOOR-PATT-002`) was added later as a
guaranteed room-event heal, conditional on taking the elite combat door, and
nobody went back to update `HLD-RUN-006`'s blanket statement.

## Goals / Non-Goals

**Goals:**
- Make `HLD-RUN-006` and the Rest room requirements consistent with each
  other.
- Preserve the original rule's intent (resource pressure — healing is scarce
  and mostly earned through the elite fight, not handed out) by scoping the
  exception as narrowly as possible: exactly one room, exactly one
  condition.

**Non-Goals:**
- Not setting the Rest room's heal amount — still `[OPEN]`.
- Not changing Wandering Soul, combat-item healing, or floor-transition
  full-heal behavior.

## Decisions

**Add a single named exception to `HLD-RUN-006` rather than removing the
"no mid-floor restoration" rule.** The rule is still true in spirit — combat
items and the one conditional Rest room are the only heal sources; nothing
else changed. Rewriting the whole rule away would lose the resource-pressure
intent the original sentence was protecting.

Alternative considered: move the "no room-event healing" rule out of
`HLD-RUN-006` entirely and into `lld-floor` where the Rest room is defined,
since that's the capability that actually owns the exception. Rejected —
`HLD-RUN-006` is the natural place for "what happens mid-floor" as a
cross-cutting HLD rule, and `LLD-FLOOR-BEATS-006` already exists as the LLD
detail; duplicating or relocating the top-level rule adds indirection without
benefit.

## Risks / Trade-offs

- **[Risk]** None — spec-only correction, no code exists yet for floor
  transitions or the Rest room to have implemented the contradiction.
- **[Risk]** The Rest room heal amount remains unset. → **Mitigation**:
  already tracked as an open item in `LLD-FLOOR-BEATS-006`; not this
  change's job to resolve, but worth a reminder when that room is
  implemented (see Appendix B — Technical Debt in
  `docs/implementation-plan.md` if it's still open then).

## Open Questions

None for this change. The Rest room heal amount is a separate open question
owned by `LLD-FLOOR-BEATS-006`.
