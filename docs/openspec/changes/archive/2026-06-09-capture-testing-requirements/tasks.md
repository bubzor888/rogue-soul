## 1. Enhance Existing Requirements

- [x] 1.1 Replace `### Requirement: [LLD-ARCH-002] Headless Execution` in `openspec/specs/lld-technical-architecture/spec.md` with the enhanced version: add rendering-layer check-and-free rule, domain-layer MUST NOT check flag rule, and two new scenarios (rendering nodes self-disable; domain never checks headless)
- [x] 1.2 Replace `### Requirement: [LLD-ARCH-004] GameState Immutability` in `openspec/specs/lld-technical-architecture/spec.md` with the enhanced version: add JSON serialisation requirement (`to_json`/`from_json`), round-trip scenario, and mid-run snapshot scenario
- [x] 1.3 Replace `### Requirement: [LLD-ARCH-008] RNG Streams` in `openspec/specs/lld-technical-architecture/spec.md` with the enhanced version: add derived seed formula, `randf()` global ban, seed I/O (injectable at run start, recorded to EventLog on run end), and three new scenarios (stream independence; no direct randf() calls; seed recorded on run end)

## 2. Add New Requirements

- [x] 2.1 Append `### Requirement: [LLD-ARCH-013] Event Log` to `openspec/specs/lld-technical-architecture/spec.md`: newline-delimited JSON format, minimum field schema, event categories table, buffer/flush policy, RNG roll debug-gating, log storage via PersistenceService, and four scenarios
- [x] 2.2 Append `### Requirement: [LLD-ARCH-014] Debug Mode` to `openspec/specs/lld-technical-architecture/spec.md`: single-flag rule, no separate build, debug node lifecycle, per-system feature catalogue table, and three scenarios
- [x] 2.3 Append `### Requirement: [LLD-ARCH-015] Unit Testing` to `openspec/specs/lld-technical-architecture/spec.md`: GdUnit4 v6.1.x mandate, version compatibility note, what-is-tested table, what-is-NOT-tested list, test directory organisation, and four scenarios
