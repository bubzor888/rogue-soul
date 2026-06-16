## Context

The vessel spec was written early with inline item details and references to design docs that are now being superseded by the OpenSpec system. The `HLD-VESSEL-005` item slot requirement was removed; the inline item descriptions duplicate `lld-items` content; and Read the Road was designed in full in the vessel doc but never carried into the spec.

Read the Road is a passive shared between the Pilgrim and the Drifter. The narrative logic: the Drifter is an earlier, less eroded version of the same soul — if the Pilgrim retains the instinct to read a road, the Drifter (who is more intact) has it too. The Hedge Knight is a separate erosion path (solo) and his ability set is still `[OPEN]`.

## Goals / Non-Goals

**Goals:**
- All three vessel requirements are free of `docs/` references.
- LLD-VESSELS-001 is self-contained: links to LLD-ITEMS-004 for items, no stale HLD ref, full Read the Road and Good as New definitions.
- LLD-VESSELS-002 has the Read the Road passive.
- No inline ability design remains as `[OPEN]` for the Pilgrim.

**Non-Goals:**
- Defining the Drifter's or Hedge Knight's full ability set — those remain `[OPEN]` beyond the shared passive.
- Adding narrative flavor text — that will go in dedicated narrative lld specs.
- Changing any mechanic or value.

## Decisions

### Read the Road: exact definition from vessel_pilgrim.md

> At the start of every combat, before the first omen cycle begins, look at the top 3 cards of the omen deck. Any number of them may be sent to the bottom of the deck. The remaining cards stay on top in their original order. Triggers automatically — no action required.

Action bucket: Passive.

### Good as New charges: 1 per floor

The vessel doc specifies "Charges: 1, replenished at floor start." The current spec says "single use per run (or per floor — see vessel doc)." Resolve the ambiguity: 1 charge, replenished at floor start.

### Starting items: link to LLD-ITEMS-004

Rather than duplicating item stats inline, the vessel spec links to `LLD-ITEMS-004` which owns the canonical starting item definitions. The scenario in LLD-VESSELS-001 can reference the ability's key behavior without re-listing stats.
