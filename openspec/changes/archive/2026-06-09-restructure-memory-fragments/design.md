## Context

The Memory Fragment system has a clear HLD/LLD split that the original spec didn't respect:
- The *mechanic* (symbol consistency, weighted category draw, what each category structure means) is HLD — it applies to all floors
- The *content* (specific pool weights for a floor, actual scenario instances, specific companion identities) is LLD — it's floor-specific data

## Goals / Non-Goals

**Goals:**
- Extract rules into `hld-memory-fragments` with clean HLD IDs (HLD-MF-001 through HLD-MF-005)
- Rewrite `lld-memory-fragments` as four flat data requirements: weights + one pool requirement per category
- Rename "Category B" → "Companion Encounter" everywhere in both specs
- Each LLD pool requirement is independently `[OPEN·MVP1]` — scenarios can be filled in separately

**Non-Goals:**
- Writing actual scenario content (still deferred)
- Changing any game mechanics — this is a structural reorganisation only

## Decisions

**Separate pool requirements per category:** Gives each category's content its own traceability and can be marked done independently. A single "pool" requirement with three subcategories inside it conflates three distinct content tasks.

**Weights stay in LLD:** The 40/40/20 split is a specific floor-tunable value, not a rule. The HLD says "categories have weights"; the LLD says what those weights are for Floor 3.

**"Companion Encounter" replaces "Category B":** The label Category B has no meaning outside the document. Companion Encounter immediately communicates what the category does.

**ID remapping:**

| Old LLD ID | New location | New ID |
|---|---|---|
| LLD-MF-001 (symbol rule) | hld-memory-fragments | HLD-MF-001 |
| LLD-MF-002 (category draw) | hld-memory-fragments | HLD-MF-002 |
| LLD-MF-003 (Category A mechanic) | hld-memory-fragments | HLD-MF-003 |
| LLD-MF-004 (Category B mechanic) | hld-memory-fragments | HLD-MF-004 |
| LLD-MF-005 (Category C mechanic) | hld-memory-fragments | HLD-MF-005 |
| LLD-MF-006 (combined pool) | lld-memory-fragments (split) | LLD-MF-001–004 |
