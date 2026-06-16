## Why

Three targeted design decisions tighten the status effect model:

1. **No auto-vulnerability from elemental statuses.** Burning, Shocked, and Chilled co-applying Vulnerable was compressing damage math — every elemental hit automatically got a ×1.5 rider. Decoupling them makes Vulnerable a deliberate item choice, not a free bonus baked into every elemental application.

2. **Chilled uses flat damage reduction, not percentage.** Percentage-based reduction scaled oddly with high-damage enemies. Flat reduction is simpler to tune and lets each omen card specify the exact amounts (still increasing per tick — but the numbers live in the card, not the HLD rule).

3. **Vulnerable + Resistance cancel out.** Without an explicit rule, the interaction between vulnerability and resistance was undefined. The intended behaviour is that they neutralise each other (net ×1.0), which needs to be stated in the spec.

## What Changes

- **HLD-COMBAT-006**: Remove "Co-applies" column entries for Burning, Shocked, and Chilled; remove the co-application paragraph; update the Chilled description from percentage-based to flat reduction (amounts in LLD); update affected scenarios
- **HLD-COMBAT-007**: Remove the "elemental statuses as a co-application" bullet from the sources list; add the resistance-cancellation rule; remove the now-stale `[OPEN·MVP1]` co-application timing note
- **HLD-COMBAT-005**: Update Fire/Lightning/Ice notes — remove references to elemental statuses as Vulnerable sources
- **LLD-OMEN-CARD-001 (Burning)**: Remove Vulnerable (Fire) ×1.5 from effect description and scenarios
- **LLD-OMEN-CARD-002 (Shocked)**: Remove Vulnerable (Lightning) ×1.5 from effect description and scenarios
- **LLD-OMEN-CARD-003 (Chilled)**: Remove Vulnerable (Ice) ×1.5; change percentage reduction to flat reduction (amounts `[OPEN·MVP1]`); update scenarios
- **LLD-ITEMS-007 (Fire Bomb)**: Remove "co-applies Vulnerable (Fire)" — Fire Bomb only applies Burning now
- **LLD-OMEN-CARD-001, 002, 003, 005, 011**: Remove all "source pool to be confirmed" open items — card origin belongs at the deck composition level, not per-card
- **LLD-OMEN-CARD-008**: Rework from "Floor 3 omen pool is entirely undesigned" to a proper "Floor 3 Default Omen Deck" requirement that is the canonical place for listing which ambient cards are present every combat on Floor 3; add an explicit note that enemy omen contributions are defined in `lld-enemies` per enemy

## Capabilities

### New Capabilities

*(none)*

### Modified Capabilities

- `hld-combat-system`: HLD-COMBAT-005 (Damage Types), HLD-COMBAT-006 (Status Effects), HLD-COMBAT-007 (Vulnerability) — removing elemental Vulnerable co-application, changing Chilled to flat, adding resistance-cancellation rule
- `lld-omen-cards`: LLD-OMEN-CARD-001, 002, 003 (remove vulnerability + source pool), LLD-OMEN-CARD-005 (remove source pool), LLD-OMEN-CARD-008 (rework as "Floor 3 Default Omen Deck"), LLD-OMEN-CARD-011 (remove source pool)
- `lld-items`: LLD-ITEMS-007 — Fire Bomb no longer co-applies Vulnerable (Fire)

## Impact

- Combat tuning: players can no longer get ×1.5 fire/lightning/ice damage "for free" by applying an elemental status — Vulnerable must now be applied separately via a dedicated item
- Combustible Oil, Brittle Charm, Frost Shard, Fulminating Powder (direct Vulnerable applicators) become more meaningful choices
- Chilled damage reduction numbers are now fully in LLD card definitions — HLD only states the pattern (flat, increasing per tick)
- Resistance + Vulnerable interaction is now explicitly neutral (×1.0) — relevant for Fire/Ice/Lightning Elemental encounters
- Omen card requirements are cleaner — no per-card "source pool TBD" noise; LLD-OMEN-CARD-008 is the single place to look for Floor 3 ambient deck composition; lld-enemies is the single place for enemy contributions
