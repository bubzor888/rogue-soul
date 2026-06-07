## Why

Three requirements in `lld-door-system` are too specific or too narrow in scope:

- `LLD-FLOOR-DOOR-001` hard-codes the Worn Map as the only exception to the two-door rule, when the rule should be generalised to "any item that dictates otherwise"
- `LLD-FLOOR-DOOR-003` describes all non-combat rooms as showing a single symbol with no distinction — it should acknowledge that Memory Fragment and Wandering Soul rooms are visually distinguishable from each other, while subcategories within Memory Fragments remain hidden
- `LLD-FLOOR-DOOR-004` is narrowly written as a "Forced-Combat Both-Doors Rule", but the real mechanic is about pool exhaustion: when any room type is capped out, remaining options fill from other types — which can naturally result in two doors of the same type

## What Changes

- **MODIFIED** `LLD-FLOOR-DOOR-001`: generalise the single-door exception — "any item that forces a single-door beat" with `LLD-FLOOR-BEATS-003` cited as an example
- **MODIFIED** `LLD-FLOOR-DOOR-003`: add that different non-combat room types are visually distinct from each other (e.g. Memory Fragment vs Wandering Soul have different symbols), but subcategory content within a type is hidden
- **MODIFIED** `LLD-FLOOR-DOOR-004`: rewrite from "Forced-Combat Both-Doors Rule" to a general pool-exhaustion rule — when a room type is capped, it is removed from the pool; remaining generation may produce two doors of the same type

## Capabilities

### New Capabilities

_(none)_

### Modified Capabilities

- `lld-door-system`: three requirement updates as described above

## Impact

- `lld-door-system/spec.md` only
