## Why

A docs-to-spec gap audit identified missing HLD mechanics, a dangling spec reference, four specs with broken structure (missing `## Purpose` / `## Requirements` headers), and two narrative spec placeholders needed for later design work. These gaps mean the spec system is incomplete and archive operations will fail on affected specs.

## What Changes

- Add `## Purpose` and `## Requirements` headers to four HLD specs missing them (`hld-companion-system`, `hld-run-structure`, `hld-vessel-system`, `hld-game-concept`)
- Add `HLD-RUN-006`: floor transition restores full vessel HP; temporary companions depart
- Create new `hld-item-system` spec with three requirements: no inventory cap at MVP (`HLD-ITEMS-001`), floor-bound item flag system (`HLD-ITEMS-002`), and encounter-countdown item system (`HLD-ITEMS-003`)
- Create `hld-narrative` placeholder spec with confirmed decisions about Solace, the guardian, and floor atmosphere — all deferred narrative details stubbed as `[OPEN]`
- Create `lld-narrative` placeholder spec with vessel lore, dialogue, and ending stubs — all `[OPEN·MVP1]` or later

## Capabilities

### New Capabilities
- `hld-item-system`: HLD rules for item inventory constraints (no cap), floor-bound flag (destroyed at transition with player notification), and encounter-countdown items (visible counter, replaces a room slot on zero)
- `hld-narrative`: Confirmed narrative decisions — soul/Solace premise, guardian judges need not moral worthiness, floor atmosphere degrades toward threshold — with deferred content stubbed as `[OPEN]`
- `lld-narrative`: Floor-specific and vessel-specific narrative content — lore fragments, guardian dialogue per vessel, branch endings — all `[OPEN]` placeholders

### Modified Capabilities
- `hld-run-structure`: Add `HLD-RUN-006` — floor transition mechanics (HP restore, temporary companion departure)
- `hld-companion-system`: Add `## Purpose` / `## Requirements` structural headers
- `hld-vessel-system`: Add `## Purpose` / `## Requirements` structural headers
- `hld-game-concept`: Add `## Purpose` / `## Requirements` structural headers

## Impact

Spec-only change. No code impact. Fixes archive-blocking structural issues on four specs and captures confirmed design decisions that currently exist only in `docs/`.
