## Why

HLD specs should describe mechanics and rules, not specific tuned values — those belong in LLD. A few concrete numbers have crept into `hld-combat-system` (poison tick damage, mending HP, hardened absorption), making the HLD harder to maintain and potentially misleading about what is fixed vs. tunable. This change establishes a clear convention and cleans up the existing violations.

## What Changes

- Establish a convention in `design.md`: HLD specs may use relative values (×1.5, 10%, X per tick) as illustrative examples, but must not hard-code absolute numeric values — those belong in LLD.
- Update `HLD-COMBAT-006` (Status Effects):
  - **Poisoned**: describe the escalating-multiply mechanic (each tick the current value is dealt as damage, then tripled) rather than naming the sequence 2→6→18. Clarify that starting value and external additions to the value are LLD concerns.
  - **Mending**: replace "heals 3 HP per tick" with "heals X HP per tick".
  - **Hardened**: replace "absorbs up to 3 incoming damage per tick" with "absorbs up to X incoming damage per tick".

## Capabilities

### New Capabilities

_(none)_

### Modified Capabilities

- `hld-combat-system`: Update HLD-COMBAT-006 status effect descriptions to remove hard-coded absolute values; describe the Poisoned escalation mechanic abstractly.

## Impact

- `openspec/specs/hld-combat-system/spec.md` — spec text changes only, no code impact.
- `design.md` for this change will codify the HLD value-abstraction convention for future reference.
