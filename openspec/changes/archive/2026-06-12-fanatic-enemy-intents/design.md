## Context

The Fanatic family has four enemy types but none have formal intent tables. LLD-ENEMIES-017/018 (the Fanatics) only list a fixed damage value per turn; LLD-ENEMIES-019/020 (the Totems) use an "always-on aura" framing that doesn't fit the intent system — no other enemy uses a passive aura. This change brings Fanatics in line with the rest of the enemy design by replacing narrative descriptions with intent tables.

The Totem aura → intent conversion is the most architecturally significant part. "Always-on aura" was implemented as a special engine concept; status application via intent is fully general and already implemented.

## Goals / Non-Goals

**Goals:**
- Formalise Fanatic and Totem intent tables (docs-only, consistent with prior passes)
- Introduce HLD-COMBAT-019 (max-wins reapplication) to define how Hardened and Emboldened behave on repeated application
- Add `"allies"` as a valid `status_target` on IntentWeight, enabling Totems to buff adjacent Fanatics without engine special-casing

**Non-Goals:**
- No code changes (docs-only pass)
- No Fanatic encounter structure changes (pairing rules remain `[OPEN·MVP3]`)
- No new omen cards for the Fanatic family
- No Frenzied + Emboldened stacking prevention — both apply if the player achieves it (intentional)

## Decisions

### 1. Totem aura → intent (100% weight)
**Old model:** Always-on passive — engine checks if the Totem is alive and applies an aura modifier to all Fanatics.
**New model:** 100% weight intent each turn — the Totem uses `status_apply` with `status_target: "allies"` to apply Hardened or Emboldened (Physical) each turn.

**Why:** The new model is fully data-driven and requires no engine special-casing. The gameplay feel is identical while alive. The one difference: on Totem death, the status lingers until the omen cycle ends rather than clearing immediately. This creates a short grace period — killing the Totem is still the priority, but the player must kill it *before the next omen cycle* to actually remove the buff, not just before the Totem's next intent. This is an acceptable trade-off and adds a small tactical nuance.

### 2. Max-wins for Hardened / Emboldened
**Why max-wins and not additive?** Hardened is an absorb value (flat damage reduction per hit). Additive stacking would mean two Totems give 6 absorb per hit, which could make Fanatics nearly invulnerable with a low-damage weapon. Max-wins bounds the buff to the strongest active source. Same logic applies to Emboldened — the flat bonus should represent the best active source, not stack unboundedly.

**Why not idempotent?** Idempotent would mean a higher-magnitude source can never upgrade an existing lower one. Max-wins allows an escalating source to upgrade the status, which keeps the design flexible for future content.

### 3. `status_target: "allies"` added to LLD-ARCH-018
A new value rather than a new field, consistent with how `status_target: "self"` was added. CombatResolver applies the status to all living `CombatState.enemies` whose `instance_id` is not the caster's `instance_id`.

### 4. Frenzied applied to the player by Fanatic Taunt
The Fanatic applies `"frenzied"` (status_target: `"player"`) — giving the player Vulnerable (Physical) + Emboldened (Physical). This creates risk/reward: player hits harder but takes more physical damage. If the player also has a standalone Emboldened (Physical) active, both apply (additive flat bonus), making the combined effect very strong but intentional.

## Risks / Trade-offs

- **Totem death grace period** — status lingers until the omen cycle ends, not instantly. Minor strategic difference from the old aura model; should be validated in playtesting.
- **Frenzied + Emboldened coexistence** — can produce a large flat bonus (+4) if both are active. Intentional, but may need to be tuned at MVP3 playtesting.
- **Hardened absorb vs. min-1 damage clamp** — LLD-ARCH-019 step 8 clamps damage to min 1. Does Hardened absorb apply before or after the clamp? Currently undefined — the min-1 clamp should probably apply AFTER Hardened absorption (Throw Rock vs. Hardened(3) = 0, not 1). This is an open interaction to resolve in LLD-ARCH-019 when implementing. `[OPEN·MVP1]`
