## Context

`lld-wandering-soul` is a pure rules document. The trade structure, offer types, HP guarantee, tier fairness rule, companion exclusion, and post-elite guarantee are all mechanics that apply regardless of which floor or vessel is being played. No floor-specific data exists.

## Goals / Non-Goals

**Goals:**
- Promote all 8 LLD-WS-* requirements to HLD-WS-* with no content changes
- Delete the LLD spec entirely
- Add LLD-ITEMS-011 as `[OPEN·MVP1]` to `lld-items` — a tier list for all items, needed to constrain Wandering Soul trade pairing
- Update the `LLD-FLOOR-PATT-005` cross-reference from `lld-wandering-soul` → `hld-wandering-soul`

**Non-Goals:**
- Changing any mechanics
- Defining actual tier assignments (that's the content of LLD-ITEMS-011, deferred to MVP1)

## Decisions

**No LLD replacement:** Unlike Memory Fragments, there is no floor-specific pool data for the Wandering Soul. The encounter generates dynamically from the player's inventory and floor item pools. The tier list (`LLD-ITEMS-011`) is the only LLD input.

**LLD-ITEMS-011 at MVP1 (not MVP2):** The original LLD-WS-006 tagged this `[OPEN·MVP2]`, but the tier list is needed for Wandering Soul trade generation to work correctly — which is an MVP1 system. Promoting to MVP1.

**ID mapping:**

| Old ID | New ID |
|---|---|
| LLD-WS-001 | HLD-WS-001 |
| LLD-WS-002 | HLD-WS-002 |
| LLD-WS-003 | HLD-WS-003 |
| LLD-WS-004 | HLD-WS-004 |
| LLD-WS-005 | HLD-WS-005 |
| LLD-WS-006 | HLD-WS-006 |
| LLD-WS-007 | HLD-WS-007 |
| LLD-WS-008 | HLD-WS-008 |
