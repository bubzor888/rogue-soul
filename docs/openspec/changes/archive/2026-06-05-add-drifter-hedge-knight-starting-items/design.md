## Context

The Pilgrim pattern (LLD-ITEMS-004) sets the standard: one requirement per vessel, listing each starting item with its category, effect chain, and key properties. Open values are flagged with `[OPEN]`. Items that also appear in the drop pools reference those requirements rather than duplicating stats.

## Goals / Non-Goals

**Goals:**
- LLD-ITEMS-009 captures the Drifter's three starting items faithfully from `vessel_drifter.md` section 4.
- LLD-ITEMS-010 captures the Hedge Knight's three starting items faithfully from `vessel_hedge_knight.md` section 4.
- Open values (Loaf of Bread heal, Cheap Flask buff, Battered Sword exact charges, Charge count, dodge chance) are preserved as `[OPEN]`.

**Non-Goals:**
- Updating `lld-vessels` to reference these requirements — that is a follow-on.
- Defining the Ferret's loot table or omen card — those are companion/omen concerns.
- Resolving any `[OPEN]` items — those await playtesting.

## Decisions

### Lucky Paw: Support (Durability), per-encounter decrement

The vessel doc says "decrements by 1 charge per combat." Under LLD-ITEMS-002, Support (Durability) items decrement per encounter. Combat rooms are encounters. These are the same thing — the spec uses the standard support decrement rule.

### Battered Sword: references LLD-ITEMS-005

The Battered Sword appears in the Floor 3 normal drop pool (LLD-ITEMS-005) with stats: Physical, 7 damage, 8–10 charges. The Hedge Knight's starting Battered Sword is the same item — the doc notes damage is "higher than the Walking Staff" and charges are "fewer than the Walking Staff." Both are consistent with 7 damage / 8–10 charges. The spec references LLD-ITEMS-005 as the canonical stat source and notes charges to be confirmed during playtesting.

### Iron Pendant: Fortified omen is not in the fate deck

The doc is explicit: "The Fortified omen exists only through pendant use — it is never in the fate deck." This is a key rule to capture in the spec. The pendant's action bucket in the doc is "Utility" which maps to the Support bucket in the item system.

### Loaf of Bread: floor-bound flag

The vessel doc specifies a floor-bound flag — the Loaf of Bread is removed at floor transition if unused. This must be captured in the spec since the Drifter plays two floors.
