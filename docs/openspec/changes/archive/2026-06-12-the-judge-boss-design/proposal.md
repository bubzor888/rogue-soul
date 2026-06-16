## Why

The Judge (LLD-ENEMIES-010) is currently a placeholder — the boss of Floor 3 is marked `[OPEN·MVP1]` with no mechanics, stats, or narrative framing defined. Without it, the floor has no ending and the core narrative premise (the guardian who judges need, not worthiness) has no mechanical expression.

## What Changes

- **New**: The Judge boss encounter — a multi-entity fight consisting of The Judge plus two passive Witnesses (Witness of Mercy, Witness of Vengeance)
- **New**: A whole-run item burden score that tracks what the player is "holding" and drives witness behavior at the boss
- **New**: The Repent omen card — a Judge-contributed card that lets the player shed items mid-fight in exchange for healing
- **New**: `HLD-RUN-007` — the item burden score accumulation mechanic: starting items score +1, any item taken scores +2, any item fully spent scores −1; tracked across the whole run with no floor reset
- **Modified**: `LLD-ENEMIES-010` — fills in The Judge's stats, intents, phase transition, tier brackets, and witness structure
- **Modified**: `lld-omen-cards` — adds the Repent omen card definition

## Capabilities

### New Capabilities

_(none — burden score accumulation is a new HLD-RUN requirement, not a new capability spec)_

### Modified Capabilities

- `hld-run-structure`: HLD-RUN-007 added — item burden score accumulation rules (whole-run tracking, +2/−1/+1 formula)
- `lld-enemies`: LLD-ENEMIES-010 fully defined; LLD-ENEMIES-021 (Witness of Mercy) and LLD-ENEMIES-022 (Witness of Vengeance) added
- `lld-omen-cards`: LLD-OMEN-CARD-020 (Repent) added

## Impact

- `hld-run-structure/spec.md` — HLD-RUN-007 added
- `lld-enemies/spec.md` — LLD-ENEMIES-010 filled in; LLD-ENEMIES-021 and LLD-ENEMIES-022 added
- `lld-omen-cards/spec.md` — LLD-OMEN-CARD-020 added
- No changes to `lld-technical-architecture` in this change (deferred to a follow-on change)
- Item pickup and spend events across the whole run must feed the burden score tracker — affects any system that handles item acquisition and consumption
