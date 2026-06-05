## Context

This is a spec language cleanup, not a mechanic change. All three edits move absolute/specific detail out of HLD and either into LLD (where it already exists) or discard stale content.

## Goals / Non-Goals

**Goals:**
- HLD-COMBAT-010 describes the cleanse mechanic (category-based clearing) without naming specific items.
- HLD-COMBAT-011 describes the default strike guarantee (always available, no durability cost) without a damage number.
- The stale back-row open item is removed.

**Non-Goals:**
- No LLD changes — Ointment/Amethyst details already live in LLD-ITEMS-001.
- No mechanic changes — same rules, cleaner language.

## Decisions

### HLD-COMBAT-010: mechanic over items

The requirement should state *what the cleanse mechanic does* (clears status effects by category; categories are distinct so no single item clears everything) rather than listing which items exist. Scenarios become abstract: "a cleanse consumable targeting offensive statuses" rather than "an Ointment."

### HLD-COMBAT-011: guarantee over value

The requirement should state two guarantees: (1) a default strike is always available regardless of resources, and (2) it does not consume item durability. The damage value is a balance number — LLD's job.

### Back-row open item: close as resolved

The decision was made when HLD-COMBAT-002/003 were removed: row-based mechanics are gone. No standalone back-row damage reduction requirement was added. The open item can be deleted as resolved (answer: no).

## Risks / Trade-offs

- **Risk**: HLD-COMBAT-010 loses the concrete example of two cleanse categories.
  → Acceptable: LLD-ITEMS-001 is the canonical reference; the HLD only needs to establish that categories exist and are distinct.
