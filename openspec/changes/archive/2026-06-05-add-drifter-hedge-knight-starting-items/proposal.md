## Why

`lld-items` has a requirement for the Pilgrim's starting items (LLD-ITEMS-004) but nothing for the Drifter or the Hedge Knight. Both vessels have fully documented starting items in their vessel design docs. Adding them to `lld-items` gives those items a canonical spec home and allows `lld-vessels` to reference them by ID.

## What Changes

- **LLD-ITEMS-009 (Drifter Starting Items)**: Pocket of Sand (escape consumable), Loaf of Bread (floor-bound heal consumable), Lucky Paw (support durability, combat-start Evasive buff). Source: `vessel_drifter.md` section 4.
- **LLD-ITEMS-010 (Hedge Knight Starting Items)**: Battered Sword (attack durability, references `LLD-ITEMS-005` for base stats), Iron Pendant (support durability, replaces active fate omen with Fortified), Cheap Flask (consumable buff, `[OPEN]`). Source: `vessel_hedge_knight.md` section 4.

## Capabilities

### New Capabilities

_(none)_

### Modified Capabilities

- `lld-items`: Add LLD-ITEMS-009 and LLD-ITEMS-010 as new requirements.

## Impact

- `openspec/specs/lld-items/spec.md` — two new requirements appended.
- `lld-vessels` will reference these requirements in a follow-on update to LLD-VESSELS-002 and LLD-VESSELS-003.
