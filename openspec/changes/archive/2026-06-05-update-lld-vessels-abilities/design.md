## Context

The vessel docs have confirmed ability designs for both vessels. The pattern established by LLD-VESSELS-001 (Pilgrim) is: base stats, starting items link, passive, active, `[OPEN]` placeholders for unresolved elements. The Ferret companion is a bound companion with a passive effect (Scavenge) and an omen card contribution — both should be captured, with the omen card remaining `[OPEN]` as it depends on the full omen card list.

## Goals / Non-Goals

**Goals:**
- LLD-VESSELS-002 has HP, Ferret companion description, Hardy active, Read the Road passive (already present), floor 2/3 `[OPEN]`, and a link to LLD-ITEMS-009.
- LLD-VESSELS-003 has HP, Last Stand passive, Charge active with `[OPEN]` charge count, floor 2/3 `[OPEN]`, and a link to LLD-ITEMS-010.
- No item details are duplicated from lld-items.

**Non-Goals:**
- Defining floor 2 and floor 3 abilities — post-MVP1 playtesting.
- Defining Hardy-clearable flags per status — requires full status system design.
- Defining the Ferret's loot table or omen card — separate concerns.

## Decisions

### Ferret: companion description in vessel spec, mechanics in companion/omen specs

The Ferret's Scavenge passive (bonus loot at combat end) and omen card are relevant to the vessel spec at a summary level. Full loot table composition and omen card effect belong in their respective LLD specs. The vessel spec describes what the Ferret does from the player's perspective.

### Hardy: `[OPEN]` clearable flag list

The doc explicitly flags which debuffs Hardy clears as `[OPEN]` pending status system design. The spec captures the rule ("clears one Hardy-clearable debuff") without listing specific clearable statuses.

### Charge: charges `[OPEN]`

The doc says "to be tuned during playtesting." The spec captures the mechanic and flags the count.

### Read the Road: already present on LLD-VESSELS-002

The passive was added in the previous change. No change needed — only the active (Hardy) and companion section are being added.
