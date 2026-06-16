## Context

`soul_protocol_game_design.md` section 1 defines the confirmed action economy (three buckets: Attack, Support, Consumable). Section 1 also confirms companion actions are automatic with no player AP cost. The melee/ranged row-targeting distinction was a design from an earlier version that has been dropped — the game design doc makes no mention of it.

## Goals / Non-Goals

**Goals:**
- Remove the two stale row-targeting requirements cleanly with rationale
- Replace the `[OPEN]` action economy with the confirmed three-bucket system
- Capture companion automatic action rule (from game design doc section 1.5)

**Non-Goals:**
- Redesigning row mechanics entirely — rows may still exist for other purposes (e.g. back row damage reduction) but the melee/ranged targeting distinction is what's being removed
- Updating `lld-abilities` to remove `force_row` handler — flagged as a follow-on

## Decisions

### What to do with row positioning
The row system still exists in the codebase design (UnitState has a `row` field per HLD-ARCH). But the *targeting rules* based on rows (melee can only hit front row) are removed. Back row damage reduction may still be a design intent — this change only removes the targeting restriction and the pre-combat setup screen. If back row damage reduction is also confirmed removed, that's a separate change.

### Action economy — three buckets
The confirmed model from the game design doc:
- **Attack bucket:** 1 per turn, mandatory. Filled by attack ability OR attack item OR Default Strike (in that preference order).
- **Support bucket:** 1 per turn, optional, free. Non-attack abilities.
- **Consumable bucket:** 1 per turn, optional, free. Single-use non-attack items.
- **Companion actions:** Automatic at end of player turn — no AP cost.

This resolves T-2 from the open technical decisions list in `hld-technical-architecture`.

## Risks / Trade-offs

- **Back row damage reduction** — the original HLD-COMBAT-002 included "units in back row receive reduced physical damage." This may still be a live design decision. Since the game design doc doesn't mention it, this change removes the entire requirement. If back row damage reduction is confirmed separately, a new requirement should be added.
