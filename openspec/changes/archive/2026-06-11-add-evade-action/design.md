## Context

Evade is a spec-only change. The mechanic adds a miss-chance layer to the combat resolution pipeline and a per-round state flag on both VesselState and EnemyState. No GDScript is written here.

## Goals / Non-Goals

**Goals:**
- Define Evade fully at HLD so any future enemy or item that references it has a stable contract.
- Scope the `is_evading` flag cleanly as a runtime turn state (not a status effect).
- Specify the durability preservation rule precisely enough to implement without ambiguity.

**Non-Goals:**
- Designing specific enemy intents that use Evade (those are added per enemy family in lld-enemies).
- Implementing CombatResolver changes (future implementation change).
- Any UI/visual design for the evade indicator.

## Decisions

### D1 — Evade fills the Action bucket, not a new bucket

**Decision:** Evade is one of the options for the Action bucket (renamed from Attack bucket). Support and Consumable buckets are unchanged and remain available on an Evade turn.

**Rationale:** Evade is a meaningful offensive sacrifice, not an additional free action. Placing it in the Action bucket preserves the existing turn structure — the player still makes exactly one "primary" commitment per turn.

### D2 — `is_evading` is a per-turn runtime flag, not a status effect

**Decision:** Evade is tracked as `is_evading: bool` on `VesselState` and `EnemyState`, not as a `StatusInstance` entry. It resets to false at the start of the unit's next turn.

**Rationale:** Status effects in `HLD-COMBAT-006` have omen-cycle timers and clear at omen reset. Evade lasts exactly 1 round regardless of the omen cycle — making it a status would require a special-case timer of 1 that bypasses the normal omen duration mechanic. A plain boolean flag is simpler, testable, and doesn't pollute the status system with a non-status concept.

### D3 — Miss rolls per hit, not per attack

**Decision:** For multi-hit attacks (e.g. Bear's Double Swipe), each individual hit rolls the 35% miss chance independently.

**Rationale:** A single roll per multi-hit attack would make evade disproportionately strong against multi-hit enemies (35% chance to avoid ALL damage). Independent rolls produce fairer expected values and more interesting variance — you might dodge one swipe but eat the other.

### D4 — Miss blocks both damage and status application

**Decision:** A miss cancels the entire effect of that hit: no damage dealt and no status applied. The attack did not connect.

**Rationale:** Allowing status to land on a miss would create an inconsistent model — "you dodged the attack but still got chilled." Conceptually a miss means no contact; the effect never resolves.

### D5 — Durability preservation: weapon charges only, all-targets rule

**Decision:** When a player attacks an evading enemy and misses, weapon item charges (items with `breaks_at_zero: true`) are NOT consumed. Consumables are always consumed regardless of miss. If a weapon targets multiple enemies and at least one hit connects (non-evading enemy or a non-miss roll), the charge IS consumed.

**Rationale:** Consumables are "thrown" — they leave the player's possession regardless of whether they connect. Weapons are wielded — if the swing doesn't land against any target, the weapon isn't "used up." The all-targets rule prevents exploiting multi-target weapons against a single evading enemy to get free uses.

### D6 — Companion attacks respect evade; companion beneficial effects do not

**Decision:** Companion actions that deal damage or apply status to an evading enemy are subject to the 35% miss roll. Companion actions that benefit the player (heals, intercepts, buffs) are unaffected by the player's own `is_evading` state.

**Rationale:** Evade is a defensive posture against incoming harm, not a general disruption field. A companion healing the player while they're evading makes no physical sense to block. A companion attacking an evading enemy logically faces the same miss chance as the player.

## Risks / Trade-offs

- **Evade is unlimited** — a unit could evade every turn indefinitely. This is intentional: the full Action bucket cost (no damage that turn) is the natural limiter. Neither side can evade AND deal damage simultaneously.
- **35% miss chance is fixed** — no items or abilities currently modify it. If future content needs a "guaranteed hit" mechanic, it would need to check and override `is_evading`. That's a future concern; for now the rate is a constant.
- **is_evading reset timing** — the flag must reset at the start of the unit's *own* next turn, not at the start of the opponent's turn. CombatResolver must clear it in the right phase to avoid off-by-one bugs (e.g. evading carrying over an extra round).
