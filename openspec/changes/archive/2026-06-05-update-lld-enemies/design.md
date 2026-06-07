## Context

The enemy spec was written in two passes — undead and beast families — but the elemental and fanatic families were marked `[OPEN]` and never filled in. The `soul_protocol_enemies.md` doc is now at v0.4 with both families fully defined. The beast stats were also marked `[OPEN]` despite being confirmed in the doc.

The family table in LLD-ENEMIES-002 has mid/late-floor columns that only contain TBDs — these create noise without adding value and should be deferred until those floors are designed.

Each enemy needs a family label so implementers know which shared property applies to it, and a door symbol `[OPEN·MVP2]` so that the art direction task is tracked.

## Goals / Non-Goals

**Goals:**
- All Floor 3 enemies are specified with stats, family, shared property references, omen contributions, and a door symbol `[OPEN·MVP2]`.
- Elemental and Fanatic families are fully represented in the spec.
- Beast enemy stats are filled from the doc.
- LLD-ENEMIES-002 is clean: Floor 3 column only, no scenarios.

**Non-Goals:**
- Defining mid/late-floor enemies — deferred.
- Designing the door symbols — those stay `[OPEN·MVP2]`.
- Changing encounter structure (LLD-ENEMIES-009) — no changes needed.

## Decisions

### Elemental and Fanatic: MVP3

Both families are connected to tier 2/3 vessel origins. Their encounter structure and omen cards contribute to Floor 3, but they are not required for the headless MVP1 Pilgrim run (undead enemies cover that scope). Tagging new requirements `[OPEN·MVP3]` where tuning is needed.

### Beast stats: fill from doc

The doc has confirmed values (Plague Rat HP: 3, on-death poison mechanic; Wolf HP: 6, pack mechanic; Bear HP: 22, sleeping round). These are confirmed decisions in the doc — filling them in removes unnecessary `[OPEN]` tags.

### Thick Hide: separate requirement (LLD-ENEMIES-011)

Mirroring the Grave Knit pattern — shared family properties get their own requirement so they can be cross-referenced cleanly from each enemy requirement.

### Elemental Synergy and Sacred Ground: separate requirements

Same pattern — Elemental Synergy is shared by all elementals; Sacred Ground is Fanatic-contributed. Both are complex enough to deserve their own requirements rather than being inline in each enemy.

### Totems: enemy requirements, not companion requirements

Totems are combat entities with HP — they are enemies in the technical sense (they occupy enemy slots, take damage, have HP). They have no attack and no vulnerability, which is noted clearly. They belong in lld-enemies.
