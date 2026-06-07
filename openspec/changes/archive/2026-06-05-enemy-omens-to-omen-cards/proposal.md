## Why

Omen card definitions are split across two specs: `lld-omen-cards` holds cards available from floor pools, vessels, and items, while `lld-enemies` holds the Grave Knit, Thick Hide, Elemental Synergy, and Sacred Ground definitions as shared family properties. All omen cards should have their canonical definition in `lld-omen-cards` — it is the single source of truth for card effects. Enemy requirements should reference those definitions rather than re-define them.

## What Changes

- **lld-omen-cards**: Add LLD-OMEN-CARD-011 (Grave Knit), LLD-OMEN-CARD-012 (Thick Hide), LLD-OMEN-CARD-013 (Elemental Synergy), LLD-OMEN-CARD-014 (Sacred Ground). Update LLD-OMEN-CARD-001 (Burning), 002 (Shocked), 003 (Chilled), 004 (Emboldened Physical) to note which enemies contribute them.
- **lld-enemies**: Remove LLD-ENEMIES-003 (Grave Knit), 011 (Thick Hide), 012 (Elemental Synergy), 013 (Sacred Ground) — definitions now live in lld-omen-cards. Update each enemy's omen contributions section to reference LLD-OMEN-CARD IDs instead of inline descriptions. Update shared property notes in each family header to reference the omen-card spec.

## Capabilities

### New Capabilities

_(none)_

### Modified Capabilities

- `lld-omen-cards`: Add 4 new enemy omen card requirements; annotate 4 existing ones with source enemies.
- `lld-enemies`: Remove 4 shared-property requirements; update omen contribution references.

## Impact

- Both spec files, text changes only — no mechanic changes.
