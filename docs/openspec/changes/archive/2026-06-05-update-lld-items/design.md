## Context

`lld-items` was written with a unified "per use" decrement rule, which was appropriate when all durability items were attack items. Support durability items (like Amethysts, Worn Map) are used differently — they're not consumed per attack, they're active per encounter. The Worn Map in particular is a passive item that tracks encounter count and fires on depletion, which fits the support durability model cleanly.

The `attack_type: MELEE` field on Walking Staff was a design artifact from when row position gated targeting. With rows removed, the meaningful distinction is damage type (physical, fire, etc.) and delivery mechanism (direct damage), not melee vs. ranged.

Status items in LLD-ITEMS-007/008 referenced HLD-COMBAT-006 inconsistently — some noted to "see HLD-COMBAT-006 for tick values" without specifying the values, and some (Hardening Resin, Poultice) gave absolute values inline without the cross-reference. The consistent pattern is: cite HLD-COMBAT-006 for the effect mechanic, then give the LLD value (`X = N`) where applicable.

## Goals / Non-Goals

**Goals:**
- LLD-ITEMS-002 clearly distinguishes attack vs. support decrement timing.
- Walking Staff uses `deal_damage` + `damage_type: physical`; no melee/ranged distinction.
- Worn Map is a Support (Durability) item; its effect is a break trigger, not a counter trigger.
- All status-applying items cite HLD-COMBAT-006 and specify X values.
- No row references remain.

**Non-Goals:**
- Changing any damage values, charge counts, or item names.
- Updating LLD-ITEMS-005/006 tables (no row references found there; status effect values in those tables are already correctly framed as item properties, not HLD references).
- Changing the Amethyst items — they don't apply a status, they clear one; no HLD-COMBAT-006 link needed.

## Decisions

### Support decrement: per encounter

"Per encounter" means once per room entered, regardless of how many turns occurred in that room. The Worn Map with 3 charges depletes after 3 encounters of any type — combat, non-combat, or boss. This matches the intent: it counts experiences, not attacks.

### Worn Map: break trigger, not counter trigger

The original spec described Worn Map as triggering "after 3 encounters." Under the support durability model this is the same as "when charges reach 0 and breaks_at_zero: true" — the effect is the break effect. This unifies it with the item system's existing `breaks_at_zero` mechanism rather than requiring a custom counter.

### Status values: cite HLD-COMBAT-006 + specify X

The HLD defines the mechanic ("Burning deals flat fire damage per tick"); the LLD defines the value. Items that apply Burning should say: "Applies Burning (5 fire damage/tick; see HLD-COMBAT-006 for full effect)". Items that apply Hardened or Mending should say: "Applies Hardened (X=3; see HLD-COMBAT-006)" — the X is resolved here in LLD.

## Risks / Trade-offs

- **Risk**: Worn Map's break trigger doesn't fire mid-combat if the last charge depletes during combat.
  → Intended: support items decrement per encounter (on room entry), not during combat. The Worn Map fires between rooms, which is the correct design intent.
