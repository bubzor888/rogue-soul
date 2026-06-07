## Why

`lld-enemies` is missing the Elemental and Fanatic families entirely, the family table has stale mid/late-floor columns, none of the enemy requirements mention their family, and none have a door symbol placeholder. The beast family stats were marked `[OPEN]` but are now fully documented in `soul_protocol_enemies.md`. This change brings the spec current.

## What Changes

- **LLD-ENEMIES-002 (Families table)**: Remove mid-floor and late-floor columns; keep Floor 3 column only. Fill in Elemental and Fanatic Floor 3 members. Remove both scenarios.
- **LLD-ENEMIES-003 (Grave Knit)**: Note it as Undead family shared property (heading clarification only).
- **LLD-ENEMIES-004 (Skeleton)** and **LLD-ENEMIES-005 (Zombie)**: Add `Family: Undead` and `[OPEN·MVP2]` door symbol.
- **LLD-ENEMIES-006 (Plague Rat)**, **007 (Wolf)**, **008 (Bear)**: Replace `[OPEN]` with confirmed stats from `soul_protocol_enemies.md`; add `Family: Beast`; add `[OPEN·MVP2]` door symbol.
- **LLD-ENEMIES-011 (Thick Hide)**: New — Shared Beast Property, analogous to Grave Knit.
- **LLD-ENEMIES-012 (Elemental Synergy)**: New — Shared Elemental Property omen card.
- **LLD-ENEMIES-013 (Sacred Ground)**: New — Fanatic-only omen card.
- **LLD-ENEMIES-014–016**: Fire Elemental, Ice Elemental, Lightning Elemental (two-phase with Sparks).
- **LLD-ENEMIES-017–020**: Low HP Fanatic, High HP Fanatic, Buff Totem, Absorption Totem.

## Capabilities

### New Capabilities

_(none)_

### Modified Capabilities

- `lld-enemies`: Update LLD-ENEMIES-002, 004–008; add LLD-ENEMIES-011–020.

## Impact

- `openspec/specs/lld-enemies/spec.md` — spec-text only.
- Source: `docs/detailed design/soul_protocol_enemies.md` sections 2–5.
