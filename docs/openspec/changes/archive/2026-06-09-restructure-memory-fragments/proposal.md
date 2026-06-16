## Why

`lld-memory-fragments` currently mixes HLD rules (the category mechanic, category structures, symbol rule) with LLD content (specific scenario pools). Requirements 001–005 describe *how the system works* — that's HLD. The LLD should focus on *what's in the pools* for specific floors.

Additionally, "Category B" is a placeholder label — renaming it "Companion Encounter" makes its purpose self-documenting.

## What Changes

- **NEW** `openspec/specs/hld-memory-fragments/spec.md` — absorbs LLD-MF-001 through LLD-MF-005 as HLD requirements:
  - HLD-MF-001: Single door symbol regardless of category
  - HLD-MF-002: Three-category weighted draw system
  - HLD-MF-003: Category A mechanic (fair trade with walk-away option)
  - HLD-MF-004: Companion Encounter mechanic (formerly Category B — renamed)
  - HLD-MF-005: Category C mechanic (mandatory unfair trade)

- **REWRITTEN** `openspec/specs/lld-memory-fragments/spec.md` — LLD-MF-001 through LLD-MF-006 replaced with floor-specific data requirements:
  - LLD-MF-001: Floor 3 category weights (40% A / 40% Companion Encounter / 20% C)
  - LLD-MF-002: Category A scenario pool (Floor 3)
  - LLD-MF-003: Companion Encounter pool (Floor 3)
  - LLD-MF-004: Category C scenario pool (Floor 3)

## Capabilities

### New Capabilities

- `hld-memory-fragments`: New HLD spec — Memory Fragment system mechanics (symbol rule, category draw, three category structures)

### Modified Capabilities

- `lld-memory-fragments`: Fully rewritten — old mechanic requirements removed, replaced with three separate floor-specific pool requirements plus a weights requirement

## Impact

- `lld-floor` references `lld-memory-fragments` for room type detail (`LLD-FLOOR-PATT-004`) — no change needed (still valid)
- `lld-floor` also references `LLD-FLOOR-PATT-003` companion cap for Category B — rename to Companion Encounter in that note
