## Why

The room type roster in HLD-RUN-002 contains room types that have been cut from the design (Rest/Mending, Anomaly, Echo Chamber) and a combat symbol description that is too generic. The table needs to reflect the current room set, and combat doors need to carry encounter-specific information so the player knows what they are walking into. Details on how Memory Fragment and Wandering Soul rooms function are LLD concerns and should not live in the HLD.

## What Changes

- **HLD-RUN-002 (Door Symbols)**: Remove Rest/Mending, Anomaly, and Echo Chamber rows from the symbol table — these room types no longer exist. Update the Combat and Elite Combat rows to describe encounter-specific symbols (the player can identify the specific enemy or encounter from the door). Remove descriptive detail about how Memory Fragment and Wandering Soul rooms work — leave only their symbol function (the HLD need only say a distinct symbol exists; mechanics belong in LLD).

## Capabilities

### New Capabilities

_(none)_

### Modified Capabilities

- `hld-run-structure`: Update HLD-RUN-002 door symbol table and description to reflect the current room set and encounter-specific combat symbols.

## Impact

- `openspec/specs/hld-run-structure/spec.md` — spec text only, no code impact.
- LLD specs for lld-room-events will carry the Memory Fragment and Wandering Soul mechanics (already exists or planned).
