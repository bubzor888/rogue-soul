## Context

This is a spec-only change. No GDScript is written here.

The omen system currently models whole-side effects (Burning applied to "all enemies") as global flags rather than per-unit StatusInstances. This diverges from how individual omens (Fire Bomb, ability-applied statuses) are tracked. The cleanse system (`HLD-COMBAT-010`) operates on StatusInstances — so any omen card effect that isn't a StatusInstance is invisible to cleanse. StatusInstance is also the natural unit for display, per-unit death cleanup, and future enemy-specific interactions.

Additionally, several omen card effects lack corresponding entries in `HLD-COMBAT-006`: Emboldened variants, Exposed, and Shocked's shift-trigger mechanic are defined only in LLD omen card requirements without a canonical status definition at HLD.

## Goals / Non-Goals

**Goals:**
- Define a single tracking model for all ongoing combat effects: the StatusInstance
- Give Shocked and Exposed proper shift-triggered status semantics
- Add Emboldened (all variants) and Frenzied as formal status definitions
- Add tag-conditional status application to OmenCardData to support family omens (Grave Knit, Thick Hide)
- Clarify that `is_stunned` blocks only the Action bucket, preserving Support/Consumable agency

**Non-Goals:**
- Changing omen cycle timing, deck assembly, or the three-card draw mechanic
- Designing specific omen card values (those remain in LLD)
- Implementing CombatResolver changes in code
- Changing any other enemy or item specs (those come in the beast intents change)

## Decisions

### D1 — `trigger: "tick" | "shift"` on StatusInstance

**Decision:** Add `trigger: String` to StatusInstance. `"tick"` (default): effect fires on every omen tick while `remaining_ticks > 0`. `"shift"`: effect fires once when `remaining_ticks` hits 0 (at omen shift), then the status clears with the rest of the cycle's statuses.

**Rationale:** `remaining_ticks` already controls duration for both types — the only distinction is when the effect resolves. A single field on the existing type is simpler than a parallel data structure or a separate status category. Most statuses are `"tick"`; only Shocked and Exposed are `"shift"`.

**Alternative considered:** Separate `ShiftStatusInstance` subtype. Rejected — adds a second class with near-identical fields for only two statuses.

### D2 — Shocked sets `is_stunned: bool` rather than being consumed in-place

**Decision:** When the Shocked shift-trigger fires, it sets `is_stunned = true` on the target unit. `is_stunned` is a turn-level boolean (like `is_evading`) that CombatResolver resets after skipping the unit's Action bucket.

**Rationale:** The stun effect spans the boundary between omen shift and the next combat turn. A StatusInstance with `remaining_ticks` is the wrong model for "skip the next turn's action" — there's no tick to fire on. A boolean flag, reset after use, is the same pattern established for `is_evading` and is symmetrically cleanable (a future cleanse item could set it to false before the turn fires).

**Regarding Action bucket only:** `is_stunned` blocks the Action bucket exclusively. Support and Consumable buckets remain available. This preserves the player's ability to cleanse status effects or use consumables while stunned — a meaningful counterplay window, consistent with how Evade also targets only the Action bucket.

### D3 — Exposed as a shift-triggered status; Vulnerable (Physical) gets next cycle's timer

**Decision:** The Exposed omen card applies an Exposed StatusInstance (`trigger: "shift"`) to each eligible unit at draw time. At omen shift, the Exposed status fires and applies Vulnerable (Physical) to the same target with `remaining_ticks` equal to the next omen cycle's timer value. Exposed then clears with the rest of the current cycle's statuses.

**Rationale:** The timer value of the next draw is determined as part of the same omen shift resolution — draw 3 new cards, assign timer from the leftover card. Vulnerable (Physical) is created after the new timer is known, so it receives the exact cycle duration. This is the semantically correct "Vulnerable lasts the next full cycle" without approximation or a special flag.

**Why a StatusInstance for Exposed itself:** Without an Exposed StatusInstance on the unit, there is nothing to display, nothing to cleanse, and no per-unit record of the pending shift effect. The omen card in `OmenCycleState.drawn_cards` is not unit-local; the StatusInstance is.

### D4 — OmenCardData gains `requires_tag: String`

**Decision:** Add `requires_tag: String` to OmenCardData. Empty string means "apply to all units on the target side." A tag value (e.g. `"undead"`, `"beast"`) means "apply only to units whose `enemy_tags` array contains that value."

**Rationale:** Family omen cards (Grave Knit → Mending for undead; Thick Hide → Hardened for beasts) currently have bespoke per-card handling. A single tag filter field removes all family-specific code paths. The engine checks the tag; if no match, no StatusInstance is created for that unit. No other omen card schema changes are needed.

### D5 — Emboldened (Physical) stays flat; Emboldened (Elemental) stays ×1.5

**Decision:** Emboldened (Physical) as a status grants a flat outgoing physical damage bonus (value defined in LLD, currently +2). Emboldened (Elemental variants) grant a ×1.5 outgoing elemental damage multiplier. These match the existing omen card definitions in `LLD-OMEN-CARD-004` and `LLD-OMEN-CARD-005` — no value changes.

**Rationale:** Physical damage is the most common type; a percentage buff would be too broadly powerful. Elemental is situational; a multiplier rewards dedicated elemental builds. The asymmetry is intentional and already established in the LLD.

**Placement in damage resolution order:** Emboldened multipliers apply at step 3 (buff modifiers, alongside Charged), but only when the attacker has Emboldened for the matching damage type. Flat physical bonus applies at step 1 (added to base damage before any multipliers).

### D6 — Frenzied as a composite status

**Decision:** Frenzied is a single named status that simultaneously applies Vulnerable (Physical) to incoming damage AND Emboldened (Physical) to outgoing damage for the affected unit. It is not two separate statuses.

**Rationale:** `status_apply` on IntentWeight is a single String. A composite status avoids needing an Array field for the sole case where one intent applies two effects. Frenzied also has clear thematic identity — the name conveys both sides of the trade. Future content can reuse it anywhere a reckless self-buff/self-debuff trade is appropriate.

## Risks / Trade-offs

- **Exposed Vulnerable timing depends on new draw order.** If the omen shift resolution order changes in future, the Vulnerable application timing could slip. The spec must be explicit that Vulnerable is applied *after* the new cycle's timer is determined, *before* new on-draw statuses are applied. → Captured in LLD-ARCH-019 shift resolution sequence.
- **Whole-side semantics still exist at the application layer.** "Apply to all units on the side" remains the omen card's delivery model — what changes is that each unit gets its own StatusInstance. The spec must clearly say this is N separate StatusInstances, not one shared one. → Addressed in HLD-OMEN-005 revision.
- **`requires_tag` only filters enemies.** The player vessel doesn't have `enemy_tags`. If a family omen is misplayed to the player side, `requires_tag` would prevent any status being applied. This is correct behaviour (a Grave Knit played to the player side does nothing — the player isn't undead), but it should be explicit in the spec. → Called out in LLD-ARCH-018 notes.
