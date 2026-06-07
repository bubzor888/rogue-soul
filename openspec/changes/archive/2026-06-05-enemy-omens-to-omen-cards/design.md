## Context

The omen system is the primary mechanic of every combat. Having card definitions spread across specs makes it hard to reason about the full deck. `lld-omen-cards` should be the complete catalogue — a reader should be able to understand every possible card effect by reading one spec.

The four family shared properties (Grave Knit, Thick Hide, Elemental Synergy, Sacred Ground) are first-class omen cards. The reason they ended up in lld-enemies was that they were introduced alongside the family definitions. Moving them doesn't change their mechanics — it just relocates the definition.

## Goals / Non-Goals

**Goals:**
- `lld-omen-cards` contains the canonical definition for all 14 omen cards (001–014).
- `lld-enemies` family shared property requirements (003, 011, 012, 013) are removed; replaced by a single line referencing the omen-card requirement.
- Each enemy's "Omen contributions" section lists `LLD-OMEN-CARD-XXX` IDs with copy count and a brief label — no inline effect definitions.

**Non-Goals:**
- Changing any card effect — mechanics are unchanged.
- Restructuring lld-omen-cards beyond adding 4 requirements and annotating 4 existing ones.

## Decisions

### Enemy omen contributions: ID + count only

After moving definitions to lld-omen-cards, enemy requirements should not repeat effect text. The format becomes:

```
**Omen contributions:** `LLD-OMEN-CARD-004` (Emboldened Physical) ×1, `LLD-OMEN-CARD-011` (Grave Knit) ×1
```

Brief label in parentheses for readability; the full definition lives in lld-omen-cards.

### LLD-ENEMIES-003, 011, 012, 013: removed, not replaced

These requirements defined shared family properties but now the card spec holds that. The family header in each enemy requirement still says "see `LLD-OMEN-CARD-XXX` for [card name]" — that's sufficient. A standalone shared-property requirement in lld-enemies would duplicate the omen-card requirement.

### Existing omen cards 001–004: add source annotation

LLD-OMEN-CARD-004 already notes "Source: confirmed as a Skeleton omen contribution." Making this consistent for 001 (Burning → Fire Elemental), 002 (Shocked → Lightning Elemental), and 003 (Chilled → Ice Elemental) gives implementers the full picture from the omen-card side.
