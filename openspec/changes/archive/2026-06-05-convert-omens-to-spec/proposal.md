## Why

The omen system is a confirmed core mechanic governing all combat in Soul Protocol — it controls how status effects are applied, how long they last, and how the battlefield shifts each turn. The design is fully documented in `docs/detailed design/soul_protocol_omens.md` but was deferred from the initial OpenSpec conversion. Before any combat implementation begins, this system needs single-source-of-truth specs with requirement IDs.

## What Changes

- Create `lld-omen-mechanics` spec: the omen cycle (draw 3, player chooses 1, random applies 1, last sets timer), deck assembly, reshuffle, overall vs. individual omen distinction
- Create `lld-omen-cards` spec: all confirmed omen cards (Burning, Shocked, Chilled, Emboldened Physical/Elemental, Stillness, Fortified) with their whole-side vs. individual behaviours
- Extend `hld-combat-system` with a MODIFIED requirement for `HLD-COMBAT-008` (Omen System) — currently a stub pointing to this conversion
- Open questions from the doc carried forward as `[OPEN]` requirements

## Capabilities

### New Capabilities
- `lld-omen-mechanics`: Omen cycle mechanics, deck assembly, card anatomy, overall vs individual omens, reshuffle rule, deck size framework
- `lld-omen-cards`: All confirmed omen cards with effects, sources, and Floor 3 pool context

### Modified Capabilities
- `hld-combat-system`: Replace `HLD-COMBAT-008` stub with a reference to `lld-omen-mechanics` requirements

## Impact

- No game code (spec-only change)
- `lld-omen-mechanics` and `lld-omen-cards` become prerequisites for implementing CombatResolver and the CombatScene omen UI
- Existing `hld-combat-system` spec gets a minor update to `HLD-COMBAT-008`
