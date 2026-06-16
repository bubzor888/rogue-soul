## Context

The project has ~10 design documents in `docs/` covering narrative, game design, technical architecture, items, enemies, vessels, omens, encounters, and testing. These are well-written prose with embedded decisions, but there is no single-source-of-truth system — the same decision can be referenced or partially restated in multiple files, and there is no requirement numbering scheme.

## Goals / Non-Goals

**Goals:**
- Every confirmed design decision lives in exactly one spec requirement with a stable ID
- All cross-references use the requirement ID (e.g. `HLD-COMBAT-003`), not restatement
- Two tiers: HLD (mechanics, structure, architecture) and LLD (specific content: items, vessels, enemies)
- Open questions from the docs are preserved as `[OPEN]` requirements
- The existing `docs/` files are preserved unchanged as historical reference

**Non-Goals:**
- Rewriting or editing the existing `docs/` prose
- Implementing any game code
- Resolving any open questions during this conversion (they carry forward as-is)
- Creating specs for roadmap / post-MVP items not yet confirmed as decisions

## Decisions

### Requirement ID Scheme

Format: `[TIER-AREA-NNN]` embedded in the requirement name.

| Tier | Areas |
|---|---|
| HLD | `CONCEPT`, `RUN`, `COMBAT`, `VESSEL`, `COMPANION`, `META`, `ARCH`, `PLATFORM` |
| LLD | `VESSELS`, `ABILITIES`, `ITEMS`, `ENEMIES`, `EVENTS` |

Example: `### Requirement: [HLD-COMBAT-001] Turn-Based Only`

IDs are stable once assigned — they do not renumber if requirements are added or removed. New requirements append to the end of a section with the next available number.

### Two-Tier Split

**HLD specs** contain decisions about *how the game works* — mechanics, rules, philosophy, architecture. These are stable and rarely change.

**LLD specs** contain *what exists in the game* — specific vessel stats, item values, enemy HP, encounter tables. These are expected to grow and change more frequently as content is designed.

Cross-tier references are allowed and expected: an LLD item spec may reference `HLD-COMBAT-005` (damage type rules) rather than restating the rule.

### Source of Truth After Conversion

Once these specs are synced to `openspec/specs/`, the specs are authoritative. The `docs/` folder becomes an archive. If a decision changes, the spec is updated — not the docs.

### Open Questions

Open questions from the docs (marked `[OPEN]`) become `[OPEN]` requirements with no scenarios. They are listed at the end of their relevant spec section. They cannot be implemented until resolved.

## Risks / Trade-offs

- **Large initial scope** → Mitigated by splitting into HLD pass (this change) and LLD pass (follow-on change). LLD specs are stubs until the second pass fills them.
- **Scenario writing for game design is less natural than for software** → Scenarios describe player-observable outcomes ("WHEN player uses fire weapon against Burning enemy, THEN damage is ×1.5"). They serve as testability anchors for the AI implementation agent.
- **IDs become stale if not maintained** → Accepted. The convention is append-only numbering; IDs are never reused.
