## Context

`hld-combat-system` currently ties elemental statuses (Burning, Shocked, Chilled) to automatic Vulnerable co-application. This was a shorthand for "elemental attacks are strong," but it removes the design space of applying Vulnerable as a deliberate choice. The Chilled percentage reduction (10%/20%/30%) was also hardcoded in HLD when it belongs as a data value on the omen card. And the Vulnerable + Resistance interaction has never been specified.

## Goals / Non-Goals

**Goals:**
- Remove elemental status auto-vulnerability across HLD and all LLD specs that reference it
- Change Chilled to state "flat, increasing reduction per tick; amounts defined by omen card"
- Add resistance-cancellation rule to HLD-COMBAT-007

**Non-Goals:**
- No changes to the Poisoned mechanic
- No changes to Mending or Hardened
- No changes to the Chilled stun mechanic — only the damage reduction model changes
- No changes to items that directly apply Vulnerable (Combustible Oil, Brittle Charm, Frost Shard, Fulminating Powder) — those are unaffected

## Decisions

### Chilled flat amounts are `[OPEN·MVP1]` in LLD-OMEN-CARD-003
The HLD only specifies the pattern: flat reduction, increases per tick, amounts on the card. The specific values (e.g. 2/4/6 damage reduction per tick) live in the LLD card definition and are calibration-time decisions. This is consistent with how Burning tick damage is handled (also an LLD value).

### Resistance + Vulnerable = ×1.0 (cancel out)
The rule is: if a unit has both Vulnerable (X) and Resistance (X) to the same damage type, they cancel — the unit takes normal damage. This is the cleanest and most intuitive interaction. The alternative (vulnerable overrides resistance, or they stack multiplicatively) would make resistance worthless whenever the player holds a Vulnerable item.

### Fire Bomb drops its Vulnerable co-application
Fire Bomb becomes purely a DoT applicator. Players who want both Burning and Vulnerable (Fire) on an enemy now need to use both Fire Bomb and Combustible Oil. This makes Combustible Oil a real decision rather than a fallback redundancy.

### lld-omen-cards updates are required
LLD-OMEN-CARD-001, 002, 003 all currently describe their effects as including a Vulnerable co-application. These must be updated to match the new HLD. The Chilled card (003) also needs the percentage language replaced with flat reduction language.

### lld-items — only Fire Bomb affected
Of the consumables in LLD-ITEMS-007/008, only Fire Bomb explicitly states "co-applies Vulnerable (Fire)." The others (Combustible Oil, Brittle Charm, etc.) already apply Vulnerable directly without riding on a status co-application, so they are unchanged.
