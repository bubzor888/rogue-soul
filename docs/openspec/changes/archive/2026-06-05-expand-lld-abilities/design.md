## Context

`HLD-COMBAT-004` defines three action buckets (Attack, Support, Consumable) and the passive model (automatic, no bucket consumed). Every ability in the game is either passive (triggers automatically) or active (occupies one of the three buckets). The LLD should make this explicit per ability so that implementation knows which bucket to check when resolving actions.

Vessel abilities are currently only described in `lld-vessels` — high-level summaries without handler chain detail. Defining them in `lld-abilities` gives them the same structure as Throw Rock and Good as New: type, bucket, charges, handler chain (or a placeholder if the chain is `[OPEN]`).

## Goals / Non-Goals

**Goals:**
- Every ability requirement in lld-abilities has an explicit type (Passive / Action) and, if Action, an explicit bucket (Attack / Support) with a reference to `HLD-COMBAT-004`.
- Pilgrim, Drifter, and Hedge Knight abilities each have a requirement in lld-abilities.
- Vessel ability requirements in lld-vessels can reference these LLD requirements.

**Non-Goals:**
- Defining handler chains for abilities whose handlers don't exist yet — those stay `[OPEN]`.
- Defining floor 2/3 abilities for Drifter and Hedge Knight — those remain `[OPEN]` in lld-vessels.
- Resolving Hardy-clearable flag list — that's a separate `[OPEN·MVP3]`.

## Decisions

### Ability structure: type + bucket + charges + handler chain

Each requirement follows this pattern:
- **Type:** Passive or Action
- **Bucket (if Action):** Attack, Support, or Consumable (per `HLD-COMBAT-004`)
- **Charges:** Number and replenishment trigger, or "passive — no charges"
- **Handler chain:** concrete chain or `[OPEN]` placeholder

### Read the Road: passive, no handler chain yet

The effect (view top 3 omen deck cards, send any to the bottom) touches the omen deck before the first cycle. This requires an omen manipulation handler that doesn't yet exist. The chain is `[OPEN·MVP1]` — it must be defined before MVP1.

### Hardy: Support bucket

Hardy clears a debuff — a protective/utility action. It does not occupy the Attack bucket, consistent with the vessel doc's "Utility — free, does not consume the attack action."

### Charge: Support bucket

Charge doubles the next attack but does not itself deal damage — it modifies the next attack action. It occupies the Support bucket. Per the vessel doc: "Utility — free, does not consume the attack action."

### Last Stand: passive, no charges

Always active when the HP condition is met. No trigger chain needed — it's a passive modifier checked at damage resolution time.
