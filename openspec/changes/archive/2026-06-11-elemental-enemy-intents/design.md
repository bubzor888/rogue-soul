## Context

Fire Elemental and Ice Elemental are fully specced enemies in terms of stats, resistances, and omen contributions but have no intent tables. They are targeted as MVP3 normal enemies. Before their intents can be implemented, a schema gap must be closed: magnitude-based statuses (Burning, Poisoned, Bleed) have no formal field in IntentWeight or OmenCardData to specify the magnitude value at application time — the values were prose-only or implied. The Fire Elemental's `kindle` intent specifically requires a stacking Burning mechanic that depends on this field being present.

## Goals / Non-Goals

**Goals:**
- Add full intent tables for Fire Elemental and Ice Elemental so their `.tres` data files can be authored and their combat behaviour implemented
- Formalise `status_magnitude: int` on IntentWeight and OmenCardData, fixing the pre-existing schema gap for Burning, Poisoned, and Bleed
- Add HLD-COMBAT-018: Burning, Poisoned, and Bleed are magnitude-additive on reapplication (distinct from Chilled's idempotency rule)
- Update CombatResolver to use `status_magnitude` when creating StatusInstances and to handle magnitude stacking

**Non-Goals:**
- Lightning Elemental intents (separate change)
- New enemy data files for Poisoned or Bleed sources — existing data files are updated only when authored; the schema addition is backward compatible (defaults 0)
- Balance tuning of the intent weights or damage ranges — values are first-pass and flagged for playtesting

## Decisions

### Decision 1: `status_magnitude` as a new schema field vs. colon-encoding

**Chosen:** new `status_magnitude: int` field on IntentWeight and OmenCardData.

**Alternative considered:** extend the colon-encoding convention (e.g. `"burning:2"` splits to status_id: "burning", string_param: "2"), using the string_param as the magnitude value.

**Why rejected:** `string_param` is already semantically reserved for type qualifiers on parameterized statuses (Vulnerable, Emboldened, Type Convert). Repurposing it for magnitude would create an ambiguous dual meaning and would require CombatResolver to conditionally interpret `string_param` as either a type qualifier or a numeric string depending on the status_id. A dedicated `status_magnitude: int` is unambiguous and trivially defaults to 0 for all existing intents and cards.

### Decision 2: Magnitude-additive rule scoped to Burning, Poisoned, Bleed only

**Chosen:** HLD-COMBAT-018 names these three statuses explicitly as magnitude-additive. All other statuses use their existing reapplication rules (Chilled = idempotent; Shocked/Vulnerable/etc. = new StatusInstance or idempotent per existing rules).

**Why:** Each magnitude-using status has a distinct tick behaviour. Hardened resets each tick (magnitude is re-evaluated, not accumulated). Mending is a heal per tick (stacking would be overpowered and undesirable). Making the rule explicit and named prevents unintended stacking on future statuses that happen to use `magnitude` for internal bookkeeping.

### Decision 3: Ice Elemental uses Vulnerable (Ice) setup intent, not Chilled

**Chosen:** `glacial_mark` applies `"vulnerable:ice"` to the player; no Chilled application in intents.

**Why:** The Ice Elemental already contributes a Chilled omen card to the deck — ambient Chill pressure comes from the omen system. A second Chilled source on the intents would be redundant (idempotent per HLD-COMBAT-015) and duplicates the Skeleton's identity. Vulnerable (Ice) creates a distinct setup-payoff loop: `glacial_mark` sets up ×1.5 amplification for the next `frost_bolt`, teaching the player to prioritize killing the Ice Elemental during a mark turn.

### Decision 4: Fire Elemental `kindle` magnitude 2; Burning omen card magnitude 5

**Chosen:** Kindle increments by 2 per use; the omen card starts at 5.

**Why:** Kindle at 2 means the Fire Elemental needs 2–3 uninterrupted Kindle turns to reach threatening DoT levels (4–6 fire/tick), giving the player agency. At magnitude 2 a single Kindle turn followed by an omen Burning card brings the player to 7 fire/tick — threatening but survivable for one tick. The 5 vs 2 asymmetry means the omen card is the "big burst" source and Kindle is the escalation source; both are independently dangerous and dangerously combinable.

## Risks / Trade-offs

- [Risk: Burning stacking is untuned] The Kindle magnitude values (2 per use) are first-pass. Two Fire Elementals post-elite with simultaneous Kindle uses could stack Burning very fast. → Mitigation: mark values `[OPEN·MVP1]` for playtesting validation.

- [Risk: backward compatibility of status_magnitude] All existing `.tres` IntentWeight and OmenCardData instances that don't set `status_magnitude` will default to 0. A magnitude of 0 on a Burning StatusInstance would mean 0 fire damage per tick — effectively a no-op. → Mitigation: document clearly in the schema that `status_magnitude` is required when `status_apply` targets a magnitude-based status; startup validation (LLD-ARCH-005) should warn if a magnitude-based status_apply has status_magnitude == 0.

- [Trade-off: max_consecutive: 1 on glacial_mark] This prevents two marks in a row but means a mark can be "wasted" on a turn where the player already has Vulnerable (Ice). The trade-off is accepted — the wasted turn is rare and the max_consecutive constraint already exists for intent balance.

## Open Questions

- `[OPEN·MVP1]` Kindle magnitude value (currently 2) and Fire Elemental damage range (4–6) to be validated in playtesting.
- `[OPEN·MVP1]` Ice Elemental Frost Bolt damage range (3–5) and glacial_mark weight (40%) to be validated in playtesting.
- Should `status_magnitude == 0` on a magnitude-based `status_apply` be a startup validation error, or silently allowed (creates a status with 0 effect)? Leaning toward a startup warning since 0-magnitude Burning is always a data authoring error.
