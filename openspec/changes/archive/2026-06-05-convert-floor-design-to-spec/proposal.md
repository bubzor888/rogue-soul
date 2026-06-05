## Why

The floor and encounter design document defines how rooms are generated, how the floor is paced, what the forced beats are, and how the two-door system works. This is the `NavigationModel` and `EncounterFactory` spec — nothing in those modules can be implemented without it. It was deferred from the initial OpenSpec pass and needs to be converted before any floor generation code is written.

## What Changes

- Create `lld-floor-structure` spec: Floor 3 composition (9 rooms + Judge), run length target, room type distribution, difficulty target
- Create `lld-encounter-patterns` spec: counter-based generation system, forced beats (Opening, Combat Lock, Worn Map companion, Elite Gate), no guaranteed rest
- Create `lld-door-system` spec: two-door choice every room, combat doors show full enemy identity, non-combat doors show symbol only, forced-combat both-doors rule

## Capabilities

### New Capabilities
- `lld-floor-structure`: Floor 3 room count, run length, composition targets, difficulty calibration
- `lld-encounter-patterns`: Encounter pattern system (counter-based), four forced beats, cap structure
- `lld-door-system`: Door display rules, combat identity disclosure, forced-combat rule

### Modified Capabilities
- None (no existing specs conflict with this content)

## Impact

- No game code (spec-only change)
- `lld-floor-structure`, `lld-encounter-patterns`, and `lld-door-system` are prerequisites for implementing `NavigationModel.generate_floor()` and `EncounterFactory` room content methods
