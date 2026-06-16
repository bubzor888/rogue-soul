## Why

`docs/soul_protocol_testing.md` contains well-reasoned, confirmed architecture decisions for testability (headless execution, seeded RNG, event logging, debug mode, unit testing framework) that are not captured in any spec. Implementors reading only the specs would miss foundational constraints — the EventLog has no requirements beyond being listed as an autoload, RNG has no seed formula or `randf()` ban, and GdUnit4 has no formal requirement at all.

## What Changes

- **Enhance LLD-ARCH-002** (Headless Execution): add that rendering nodes check the flag at `_ready()` and that the game loop/domain layer MUST NOT check the flag
- **Enhance LLD-ARCH-004** (GameState Immutability): add explicit JSON serialisation requirement — GameState SHALL be fully serialisable to/from JSON at any point during a run
- **Enhance LLD-ARCH-008** (RNG Streams): add derived seed formula (`base_seed + stream_index`), explicit `randf()` global ban, seed injectable at run start, seed recorded to run log on run end
- **Add LLD-ARCH-013** (Event Log): newline-delimited JSON format, minimum field schema, in-memory buffer, checkpoint flush policy, RNG roll logging debug-gated, seed recorded on run end
- **Add LLD-ARCH-014** (Debug Mode): single-flag rule (`GameConfig.DEBUG`), never commented-out code, no separate debug build, per-system debug feature catalogue
- **Add LLD-ARCH-015** (Unit Testing): GdUnit4 v6.1.x as the mandated framework, what is covered (RNG, combat resolver, event log, serialiser, action injector), what is explicitly excluded (scenes, UI, audio), test directory organisation

## Capabilities

### New Capabilities

None — all changes are to an existing capability.

### Modified Capabilities

- `lld-technical-architecture`: enhance LLD-ARCH-002, LLD-ARCH-004, LLD-ARCH-008; add LLD-ARCH-013, LLD-ARCH-014, LLD-ARCH-015

## Impact

- `openspec/specs/lld-technical-architecture/spec.md`: all changes land here
- No code changes — this is a spec-only change capturing already-confirmed decisions from `docs/soul_protocol_testing.md`
- Source of truth for this change: `docs/soul_protocol_testing.md` sections 2–7, 9
