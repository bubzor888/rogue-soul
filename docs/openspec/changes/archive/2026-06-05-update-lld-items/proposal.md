## Why

Several details in `lld-items` need updating to match evolved design decisions: the durability decrement rule doesn't distinguish between attack and support items; the Pilgrim's Walking Staff uses stale `attack_type: melee` terminology; the Worn Map is miscategorised as a non-combat item rather than a support durability item with a break effect; row references remain from the removed row system; and items that apply status effects don't consistently link back to HLD-COMBAT-006 or specify the LLD values for any `X` placeholders.

## What Changes

- **LLD-ITEMS-002 (Durability Decrement)**: Split the decrement rule by item category — attack durability items lose 1 charge per use (each attack); support durability items lose 1 charge per encounter.
- **LLD-ITEMS-004 (Pilgrim Starting Items)**:
  - Walking Staff: Replace `attack_type: MELEE` with `deal_damage { damage_type: physical }` terminology. Remove "front-row enemy" from scenario.
  - Worn Map: Reclassify as Support (Durability). Charges decrement per encounter (per the new support rule). Effect triggers on break: forces the next room to be a temporary companion encounter. Removed from inventory after triggering.
- **LLD-ITEMS-007 / LLD-ITEMS-008**: Where items apply a status effect, add a reference to `HLD-COMBAT-006` for the effect definition, and specify the LLD value wherever `X` is used (Burning tick damage, Hardened absorption, Mending heal).
- Remove all remaining front/back row references from the document.

## Capabilities

### New Capabilities

_(none)_

### Modified Capabilities

- `lld-items`: Update LLD-ITEMS-002, LLD-ITEMS-004, LLD-ITEMS-007, LLD-ITEMS-008.

## Impact

- `openspec/specs/lld-items/spec.md` — spec text only, no code impact.
- The Worn Map reclassification aligns with the support item decrement rule and the updated companion system (temporary companions found in Memory Fragment rooms).
