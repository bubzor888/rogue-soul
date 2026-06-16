## Context

Bleed is a new offensive status that decays each tick rather than escalating. This change is spec-only. The implementation concern is ensuring the CombatResolver handles the halving correctly and that StatusInstance can store the stack count without schema changes.

## Goals / Non-Goals

**Goals:**
- Define Bleed's full mechanic at HLD level so it can be referenced by any future LLD item or enemy that applies it.
- Reuse the existing `StatusInstance.magnitude` field for Bleed stacks without altering the schema.

**Non-Goals:**
- Defining any specific item, enemy, or omen card that applies Bleed (that is LLD work).
- Implementing CombatResolver changes (future implementation change).

## Decisions

### D1 — `magnitude` reused for Bleed stacks

**Decision:** Bleed stack count is stored in `StatusInstance.magnitude`, the same field used for Chilled's accumulating damage reduction. The field description is generalized to cover any stack-based status.

**Rationale:** Adding a dedicated `stacks` field to StatusInstance would require a schema migration. The `magnitude` field is already semantically correct — it holds a numeric quantity that modulates the status's effect, distinct from `remaining_ticks`. Both Chilled and Bleed use it this way; they just change the value in opposite directions.

### D2 — Halving is floor division, clears at 0

**Decision:** Stack halving is `floor(stacks / 2)`. When this result is 0 (i.e. stacks were 1 before the tick), the status clears immediately — equivalent to a natural drain to zero.

**Rationale:** This makes small-stack Bleed deterministic: 1 stack always clears after dealing 1 damage. Without this rule, 1 stack would halve to 0 but the status entry would remain as a phantom with no effect. Clearing at 0 keeps the state clean.

**Example decay sequence starting at 5 stacks:**

| Tick | Stacks before | Damage dealt | Stacks after |
|---|---|---|---|
| 1 | 5 | 5 physical | 2 (floor(5/2)) |
| 2 | 2 | 2 physical | 1 (floor(2/2)) |
| 3 | 1 | 1 physical | clears (floor(1/2) = 0) |

### D3 — Bleed damage is physical

**Decision:** Bleed deals physical damage.

**Rationale:** Bleed represents a wound — physical damage is the natural type. This means Physical Vulnerability (Brittle Charm) amplifies it, and Physical Resistance would mitigate it, which is intentional.

### D4 — Omen reset still clears Bleed

**Decision:** Bleed clears at omen reset like all other statuses, regardless of remaining stacks.

**Rationale:** Consistency with the rest of the status system. A high-stack Bleed can be cleared by a cleanse item or omen reset before it finishes its natural decay — this is intentional counterplay.

## Risks / Trade-offs

- **Bleed and Poisoned coexisting on the same target** — no interaction defined at HLD; both tick independently. If a target has both Bleed and Poisoned, each resolves separately at omen tick time. No stacking interaction is specified.
- **Bleed damage type enables Vulnerable amplification** — unlike Poisoned (no vulnerability), Bleed is physical and can be amplified by Brittle Charm. This makes Bleed considerably stronger against Brittle-Charmed targets. Worth watching in tuning.
