## Why

The Zombie's second omen contribution has been `[OPEN·MVP1]` since the enemy was defined. Closing it requires establishing a consistent model for how enemies contribute cards beyond their family-specific card — which is also currently undocumented in the HLD.

## What Changes

- **Define the two-tier omen contribution model**: family card (1 copy per enemy instance) + type card (1 copy per enemy type present, regardless of count). This becomes the documented rule in HLD.
- **Zombie**: Gains `Emboldened (Physical)` ×1 as its type card. Closes `[OPEN·MVP1]`.
- **Skeleton**: Existing `Emboldened (Physical)` contribution is reclassified as the type card (1 total); `Grave Knit` is confirmed as the per-instance family card.
- **Plague Rat, Wolf, Bear**: Each gains `Exposed` ×1 as their Beast type card.
- **Low HP Fanatic, High HP Fanatic**: Each gains `Mending` ×1 as their Fanatic type card.
- **Elementals**: No change — their two existing contributions already map cleanly to the new model.
- **Buff Totem, Absorption Totem**: No change — Totems are excluded from both contribution tiers.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `hld-omen-system`: Add requirement for the two-tier enemy omen contribution model (per-instance family card + per-type extra card).
- `lld-enemies`: Update omen contribution lines for Skeleton, Zombie, Plague Rat, Wolf, Bear, Low HP Fanatic, High HP Fanatic to reflect the two-tier model.

## Impact

- Affects `CombatResolver.assemble_omen_deck()` — the deck assembly logic must distinguish per-instance vs per-type contributions when building the combat deck.
- No change to the omen cycle, draw, or resolution logic.
