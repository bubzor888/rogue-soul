## Context

This change is purely a naming and traceability fix. No behaviour, code, or data changes. The two durability subtypes were already defined implicitly in HLD-ITEMS-004's action-bucket table and HLD-ITEMS-005's decrement rules, but lacked a dedicated canonical requirement with player-facing label names. UI specs were using "weapon" and "support item" as informal shorthand with no formal cross-reference.

## Goals / Non-Goals

**Goals:**
- Give the Attack/Support durability distinction a single canonical home (HLD-ITEMS-012)
- Establish "weapon" and "support item" as the official player-facing UI labels
- Add cross-references from UI-LOOT-002, UI-LOOT-004, and UI-LOOT-006 to HLD-ITEMS-012

**Non-Goals:**
- No changes to action bucket assignment, decrement rules, or any game behaviour
- No changes to LLD item definitions or data files
- No code changes of any kind

## Decisions

This change adds HLD-ITEMS-012 as a new requirement rather than modifying HLD-ITEMS-004, because HLD-ITEMS-004 is about action bucket assignment (a gameplay rule) while the new requirement is about player-facing terminology (a UI convention). Keeping them separate preserves the HLD/UI boundary.

## Risks / Trade-offs

No risks — spec-only change, fully idempotent.
