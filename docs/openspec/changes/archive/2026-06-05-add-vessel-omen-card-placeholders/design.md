## Context

Vessel omen cards are contributed by the vessel itself to every combat in a run (like Pilgrim's Stillness). Item omen cards are contributed by specific items when carried (like Fortified from the Iron Pendant). The Hedge Knight currently has one item card entry (Fortified) but no vessel card entry — the vessel itself needs a separate omen card placeholder. The Drifter's Ferret omen card is referenced in lld-vessels as `[OPEN]` but has no home in lld-omen-cards.

## Goals / Non-Goals

**Goals:**
- LLD-OMEN-CARD-009 is a clearly labelled `[OPEN]` placeholder distinguishing the Hedge Knight's vessel card from the Iron Pendant item card.
- LLD-OMEN-CARD-010 is a clearly labelled `[OPEN]` placeholder for the Ferret omen card cross-referencing LLD-VESSELS-002.

**Non-Goals:**
- Designing the actual effects — those depend on vessel balance sessions.
- Adding Drifter's own vessel card (distinct from Ferret) — the Drifter's vessel contribution to the deck is the Ferret card; no separate vessel card is mentioned in the vessel doc.

## Decisions

### Hedge Knight vessel card vs. Iron Pendant card — two distinct cards

The Iron Pendant injects Fortified via an item omen mechanism when activated. The Hedge Knight vessel card is a persistent deck contribution (present every combat regardless of item use). These are different in kind — one is reactive/item-triggered, the other is always in the deck. The placeholder must make this distinction explicit.

### Ferret card: beneficial on player side, inert on enemy side

This rule is already stated in LLD-VESSELS-002 and should be restated in the omen card spec for completeness — it's a card mechanic constraint, not just flavour.
