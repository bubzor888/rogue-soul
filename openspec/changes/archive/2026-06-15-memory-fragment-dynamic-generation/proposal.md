## Why

LLD-MF-008 and LLD-MF-010 currently require hand-authored scenario pools for Memory Fragment Category A and Category C trades, but the item ranking system (lld-item-ranking) now provides everything needed to generate fair and unfair trades at runtime. The static pool approach creates ongoing authoring burden with no design benefit — the narrative wrapper is decoupled from the trade contents and deferred to MVP2 anyway.

## What Changes

- **LLD-MF-008** (Category A scenario pool): Replace the static hand-authored scenario pool requirement with dynamic generation rules driven by item ranking scores. The ±20% fair trade tolerance from LLD-IR-010 determines valid pairings at runtime.
- **LLD-MF-010** (Category C scenario pool): Replace the static hand-authored scenario pool requirement with inventory-aware dynamic generation rules. Category C looks at the player's current inventory, selects an item, and generates an unfair Option 1 and a cut-your-losses Option 2 using the 50%+ unfair threshold from LLD-IR-010.
- Both `[OPEN·MVP1]` tags on LLD-MF-008 and LLD-MF-010 are resolved — the generation rules replace the scenario definitions.
- Narrative context for Memory Fragment trades (the "why" behind the moment) remains decoupled from trade contents and is deferred to MVP2.

## Capabilities

### New Capabilities

None. This change modifies existing Memory Fragment behaviour only.

### Modified Capabilities

- `lld-memory-fragments`: LLD-MF-008 and LLD-MF-010 requirements change from static scenario pools to dynamic generation rules referencing lld-item-ranking.

## Impact

- **lld-memory-fragments spec**: LLD-MF-008 and LLD-MF-010 rewritten.
- **Memory Fragment system (code)**: The encounter generator must implement runtime pairing logic using item scores rather than sampling from a fixed pool.
- **lld-item-ranking**: No changes — LLD-IR-010 and LLD-IR-011 are the source of truth consumed by the generator. Cross-references added where needed.
- **hld-memory-fragments**: No requirement changes — HLD-MF-003 and HLD-MF-005 already describe the mechanic abstractly without assuming static pools.
