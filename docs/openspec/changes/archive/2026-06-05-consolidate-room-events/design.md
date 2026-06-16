## Context

`lld-encounter-patterns` already owns the generation logic and cap table for non-combat room types. LLD-FLOOR-PATT-003 lists Memory Fragment and Wandering Soul caps — but there are no requirements defining what those room types are. Adding brief room-type requirements there closes that gap cleanly, and makes `lld-encounter-patterns` the single place to understand Floor 3's non-combat encounter system.

The detailed mechanics for Memory Fragment rooms live in `lld-memory-fragments`; for Wandering Soul rooms in `lld-wandering-soul`. The new lld-encounter-patterns requirements are intentionally brief — they register the room type and point to the detailed spec, following the same pattern as LLD-FLOOR-BEATS-004 pointing to `lld-elite-gate`.

## Goals / Non-Goals

**Goals:**
- `lld-room-events` is gone.
- `lld-encounter-patterns` has LLD-FLOOR-PATT-004 (Memory Fragment) and LLD-FLOOR-PATT-005 (Wandering Soul).
- No content is lost — mechanics already live in the detailed specs.

**Non-Goals:**
- Changing the Memory Fragment or Wandering Soul mechanics — those specs are unchanged.
- Adding the full LLD-EVENTS-001/002 content to encounter-patterns — brief type registration only.
