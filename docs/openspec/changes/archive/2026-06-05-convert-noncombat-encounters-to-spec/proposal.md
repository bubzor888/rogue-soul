## Why

Non-combat encounter design is fully documented (v0.5) in `docs/detailed design/soul_protocol_noncombat_encounters.md` but was not converted in the initial OpenSpec pass. These encounters — Memory Fragment, Wandering Soul, and the Elite Gate — are the texture of the run between fights. They need single-source-of-truth requirements before any encounter generation code is written.

## What Changes

- Create `lld-memory-fragments` spec: three outcome categories (A: fair trade/optional, B: companion gateway, C: unfair trade/mandatory), pool weighting (40/40/20), door symbol rule, scenario structure
- Create `lld-wandering-soul` spec: 2–3 simultaneous fully-revealed trade offers, HP-for-item always present, no currency, item tier fairness
- Create `lld-elite-gate` spec: elite vs standard door choice, post-fight fixed heal on elite, full enemy identity on both doors
- Update `lld-room-events` MODIFIED requirements: `LLD-EVENTS-002` (Wandering Soul) and `LLD-EVENTS-003` (Rest/Mending) need corrections based on this doc — Rest has been removed from MVP and is no longer a room type; Anomaly has been consolidated into Memory Fragment at this floor

## Capabilities

### New Capabilities
- `lld-memory-fragments`: Outcome categories, pool weights, door symbol, scenario mechanics, trade structure
- `lld-wandering-soul`: Trade offer structure, HP-for-item guarantee, no-currency rule, tier fairness
- `lld-elite-gate`: Two-door structure, rewards, post-fight heal, design intent per door

### Modified Capabilities
- `lld-room-events`: Correct `LLD-EVENTS-003` (Rest removed from MVP), add note that Anomaly is now the elite gate pairing at this floor level, not a general pool room

## Impact

- No game code (spec-only change)
- `lld-memory-fragments`, `lld-wandering-soul`, and `lld-elite-gate` are prerequisites for implementing `EncounterFactory` non-combat methods
- `lld-room-events` correction prevents implementing a Rest room that does not exist at MVP Floor 3
