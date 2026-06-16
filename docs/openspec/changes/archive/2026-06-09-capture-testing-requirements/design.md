## Context

`docs/soul_protocol_testing.md` is a well-developed companion document (v0.2, May 2026) recording confirmed architecture decisions for testability. The decisions were made deliberately and are marked as foundational in the doc. The spec system is the source of truth for implementation; anything only in the testing doc is invisible to an implementor reading only the specs.

This change is a transcription exercise, not a design exercise. All decisions have already been made — the goal is fidelity in capturing them, not re-litigating them.

## Goals / Non-Goals

**Goals:**
- Faithfully capture every confirmed decision from `docs/soul_protocol_testing.md` sections 2–7 and 9 into `lld-technical-architecture`
- Preserve the exact rationale from the testing doc in spec scenarios and notes
- Close the gap between what is specified and what the codebase must actually do

**Non-Goals:**
- No new design decisions — all choices are already confirmed in the testing doc
- Implementation order (testing doc section 10) is not a spec requirement — it belongs in tasks or a README
- Playtest process (section 8) is a dev practice, not a system requirement — it stays in the testing doc
- UI presentation of seeds is explicitly deferred — the requirement is seed output + injectable input only

## Decisions

All decisions pre-confirmed in `docs/soul_protocol_testing.md`. Transcribed faithfully:

**LLD-ARCH-002 enhancement:** The rendering/UI layer checks `GameConfig.HEADLESS` at `_ready()` and skips instantiation. The domain layer (game loop, combat resolver, RNG, event log) MUST NOT check this flag. This enforces the separation: headless is a presentation concern, not a logic concern.

**LLD-ARCH-004 enhancement:** GameState JSON round-trip is required for AI simulation (state branching, scenario inspection) and save/load. Already implied by the save format decision (LLD-ARCH-010) but not explicitly required on GameState itself.

**LLD-ARCH-008 enhancements:** Three additions:
1. Derived seed formula: `base_seed + stream_index` — simple, single base seed fully determines a run
2. Global `randf()` ban — enforced by convention and code review; contamination is caught by the stream monitor
3. Seed I/O: injectable at run start (for reproducibility), recorded to EventLog on run end (for bug recovery)

**LLD-ARCH-013 (new — Event Log):** The EventLog is the primary diagnostic tool across playtesting, AI simulation, and bug reports. Newline-delimited JSON (not a JSON array) allows incremental write and partial read. In-memory buffer reduces I/O overhead on mobile; checkpoint flushes (floor transitions, boss completions, run end) bound data loss to one floor's events on crash. RNG raw rolls are debug-gated to keep simulation output actionable.

**LLD-ARCH-014 (new — Debug Mode):** Single flag in GameConfig, never conditional compilation or commented code. All debug UI nodes self-destruct at `_ready()` when flag is false. No separate build required — the tested artifact is always the release build.

**LLD-ARCH-015 (new — Unit Testing):** GdUnit4 v6.1.x selected over GUT (less active for Godot 4, weaker CI integration). Tests cover pure logic systems only — scene composition, UI layout, audio, and game feel are explicitly out of scope. Top-level `tests/` directory, one file per system.

## Risks / Trade-offs

- **Risk: Testing doc diverges from spec over time** → The spec is now the source of truth; the testing doc becomes a historical record. If testing decisions change, update the spec (not the testing doc).
- **Risk: GdUnit4 version drift** → Version is pinned at v6.1.x in LLD-ARCH-015. Any upgrade requires re-validation against Godot 4.6.x and a spec update.
- **Risk: EventLog buffer loss on crash** → Accepted trade-off: buffer is flushed at floor transitions so crash data loss is bounded to the current floor. Any run is reproducible from its seed anyway.
