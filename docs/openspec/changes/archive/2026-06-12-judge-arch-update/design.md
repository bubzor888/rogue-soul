## Context

The Judge boss (LLD-ENEMIES-010) and its two Witnesses (LLD-ENEMIES-021, 022) were fully specced in the `2026-06-12-the-judge-boss-design` change, which explicitly deferred `lld-technical-architecture` updates. Several mechanics introduced by that change have no current schema support:

- **Item burden score** (HLD-RUN-007): A whole-run integer with no field in GameState.
- **Witness intents with tier-based magnitude**: `testify_mercy` and `testify_vengeance` apply statuses whose magnitude is determined at resolution time by the current burden score tier — not expressible with the existing static `status_magnitude` field on IntentWeight.
- **Repent card interactive discard** (LLD-OMEN-CARD-020): When Repent fires on the player side with items in inventory, the omen cycle must pause and the player must choose which item to discard. No existing action type or CombatState sub-state covers this.
- **On-death status consequences**: Killing a Witness applies a status to the player (Vulnerable or Frenzied). The Plague Rat's on-death Poison application (LLD-ENEMIES-006) is also in the spec but has no schema field. The current EnemyData has `on_death_summons` (spawn enemies) but no analog for status application.
- **`hp_percent_lte:N` condition**: The Judge uses this condition form for its Pass Judgment phase; only `hp_below_percent:N` (strict less-than) is currently listed in IntentConditional.

All changes in this design are additive schema extensions or CombatResolver method additions. No existing behavior changes.

## Goals / Non-Goals

**Goals:**
- Add `item_burden_score` to GameState so burden score is part of serialisable run state
- Add `pending_repent_slots` to CombatState so Repent's interactive pause is expressed in immutable state (not side-channel)
- Add `REPENT_DISCARD` action type so AIPlayerAgent and UI both route through ActionInjector cleanly
- Add `handlers` to IntentWeight so tier-based magnitude can use the existing AbilityPipeline / HandlerConfig pattern
- Add `on_death_apply_to_player` + `on_death_apply_magnitude` to EnemyData so all on-death status effects are data-driven
- Add `hp_percent_lte:N` to IntentConditional supported forms
- Update CombatResolver interface to cover all new flows

**Non-Goals:**
- Implementing any handler (e.g., `apply_mending_by_burden_tier`) — handlers are content; this change defines the schema that hosts them
- Implementing Repent discard UI — presentation layer concern
- Any other boss or enemy content
- HLD changes — burden score accumulation rules are already in HLD-RUN-007

## Decisions

### Repent pause modeled in GameState, not as a separate RunPhase

**Decision:** Repent's interactive discard pause is expressed as `pending_repent_slots: Array[int]` on CombatState, not as a new RunPhase enum value.

**Why:** Adding a RunPhase (e.g., `REPENT_CHOICE`) would require SignalBus.phase_changed emissions, ScreenManager handling, and SaveManager checkpoint logic for a sub-state that only occurs within a single card's resolution. Embedding it in CombatState keeps it within the existing COMBAT phase envelope. The presentation layer detects the pending choice by calling `get_legal_combat_actions()` — when only `REPENT_DISCARD` actions are returned, it shows the discard UI. The AI agent works identically with no special casing.

**Alternative considered:** New `REPENT_CHOICE` RunPhase. Rejected — disproportionate complexity for a single card mechanic.

### `handlers` on IntentWeight (not a new tier_magnitudes field)

**Decision:** Add `handlers: Array[HandlerConfig]` to IntentWeight, consistent with AbilityData, OmenCardData, and CompanionData.

**Why:** The witnesses' tier-based magnitude is a specific instance of "intent effect that cannot be expressed with static fields." A general `handlers` field costs nothing extra and keeps the pattern consistent. A bespoke `burden_tier_magnitudes: Array[int]` field would work only for Judge-class enemies and would not compose with future novel effects.

**Alternative considered:** Special-case burden tier logic in CombatResolver directly (check enemy tags). Rejected — violates the HLD/LLD boundary; CombatResolver must not know specific enemies by name or tag.

### On-death status uses remaining ticks from current cycle

**Decision:** `on_death_apply_to_player` StatusInstances get `remaining_ticks` equal to the current omen cycle's remaining ticks at the moment of death resolution.

**Why:** This is the same rule the spec already defines for Witness kill consequences and the Plague Rat's Poison. It ties the penalty duration to the cycle rhythm, making it predictable (the player can see when the cycle ends). The alternative — a fixed tick count in EnemyData — would be arbitrary and decouple the effect from the omen system.

### `item_discarded` is a separate signal from `item_broken`

**Decision:** Add `item_discarded(item_id: String, slot_index: int)` as a distinct SignalBus signal rather than repurposing `item_broken`.

**Why:** `item_broken` is emitted by ActionInjector when charge exhaustion destroys an item. Repent discards are driven by CombatResolver. They are semantically different events — one is attrition, one is a deliberate player choice. EventLog should log them under different event names. Burden score update logic listening to both signals would also need to distinguish them.

### Burden score updated synchronously in GameState, no dedicated signal

**Decision:** `item_burden_score` is updated directly in GameState by whichever component handles the triggering event (RunController at loot selection and run start, ActionInjector at item break, CombatResolver at Repent discard). No dedicated `burden_score_changed` signal is added.

**Why:** The score is already part of GameState, which is logged via EventLog on every meaningful event. Adding a separate signal would duplicate information already present in the state diff logged by `action_resolved`, `item_acquired`, `item_broken`, and `item_discarded`. The presentation layer has no reason to observe the score directly (it's not shown as a number per HLD-RUN-007).

## Risks / Trade-offs

**`pending_repent_slots` makes `get_legal_combat_actions()` return zero non-Repent actions** → Any caller that expects at least Default Strike always available must handle the Repent pending case. `get_legal_combat_actions()` already has the "always at least one action" guarantee; this guarantee holds (REPENT_DISCARD actions fill the slot), but the character of the returned set changes entirely. Mitigation: spec the guarantee clearly in LLD-ARCH-019.

**IntentWeight `handlers` field is unused by all existing enemies** → Unused fields add complexity to EnemyData `.tres` authoring. Mitigation: field defaults to `[]`; existing content files need no changes.

**`on_death_apply_to_player` with remaining_ticks from current cycle can be 0 if called at cycle boundary** → If an enemy dies on the exact turn the omen cycle ends, remaining_ticks is 0, and the applied status would expire immediately. Mitigation: resolve_enemy_death is called before resolve_omen_cycle_start in the turn order; the cycle is still active when death is processed; remaining_ticks should always be ≥ 1 at this point. Flag as edge case to validate in playtesting.

## Open Questions

- `[OPEN·MVP1]` Exact ordering of `resolve_enemy_death` and `resolve_omen_cycle_start` within a turn — confirm that death always resolves before cycle end to ensure on-death status remaining_ticks > 0.
- `[OPEN·MVP1]` Hardened absorption vs. min-1 clamp interaction (flagged in LLD-ENEMIES-020) — already tracked but not resolved; on-death Hardened absorption edge case is separate from this change.
