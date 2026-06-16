## Context

HLD-RUN-002 was written when the room type roster was broader. Three room types (Rest/Mending, Anomaly, Echo Chamber) have been cut. The combat symbol description used a generic "standard enemy encounter" note, which undersells the design intent: the player should know what specific encounter awaits, not just that it is "a fight." Memory Fragment and Wandering Soul descriptions in the table edged toward mechanic detail that belongs in LLD.

## Goals / Non-Goals

**Goals:**
- HLD-RUN-002 table reflects exactly the room types that currently exist.
- Combat and Elite Combat symbol entries communicate the encounter-specific intent.
- Memory Fragment and Wandering Soul entries are reduced to symbol-level descriptions only.

**Non-Goals:**
- Defining what the symbols look like visually — that remains an open design decision.
- Specifying how Memory Fragment or Wandering Soul rooms work mechanically — that is LLD.
- Changing any other requirement in hld-run-structure.

## Decisions

### Encounter-specific combat symbols

Combat doors will show a symbol identifying the specific enemy or encounter type (e.g., the player sees a Skeleton symbol, not a generic sword). Elite Combat doors add a warning glyph on top of the encounter-specific symbol. This satisfies the "instantly readable" legibility requirement while giving the player meaningful pre-entry information.

### Memory Fragment and Wandering Soul: symbol-only in HLD

The HLD table should say what a symbol *signals* to the player (e.g., "narrative/lore event", "trade opportunity") without describing room mechanics. The how belongs in `lld-room-events`.

### Removed room types

Rest/Mending, Anomaly, and Echo Chamber are simply removed from the table. No migration or deprecation note is needed — these room types do not exist in the current design.

## Risks / Trade-offs

- **Risk**: Future contributors re-add cut room types without a new proposal.  
  → Acceptable: the change history in the archive documents the removal decision.
