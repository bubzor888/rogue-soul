## Context

This is a spec-accuracy fix, not a feature. Two specs describe the Pilgrim's item burden initialization and disagree:

- `LLD-ITEMS-004` (source of truth for vessel content): the Pilgrim starts with **three** items — Walking Staff, Spoiled Potion, Worn Map.
- `LLD-ARCH-017` (one scenario): asserts the Pilgrim "has 1 starting item: Walking Staff" → `item_burden_score` initialized to 1.
- `HLD-RUN-007` (the rule): burden initializes at **+1 per starting item**. Its accumulation table and generic 2-item illustration scenario are correct and need no change.

No game code exists yet, so there is no runtime behavior to migrate — only the spec text is wrong. A design doc is included because the build order requires it; the change itself needs no architecture.

## Goals / Non-Goals

**Goals:**
- Make `LLD-ARCH-017`'s burden-init scenario internally consistent with `LLD-ITEMS-004` and `HLD-RUN-007` (Pilgrim: 3 starting items → burden 3).

**Non-Goals:**
- No change to the burden accumulation rule, the +1/+2/−1 deltas, or any other scenario.
- No change to `HLD-RUN-007` (already correct).
- No change to `LLD-ITEMS-004` (the authoritative source; already correct at 3 items).
- No code, no balance, no new requirements.

## Decisions

**Decision: Treat `LLD-ITEMS-004` as the source of truth and correct `LLD-ARCH-017`.**
- Rationale: `LLD-ITEMS-004` is the dedicated vessel-content requirement defining starting loadouts; `LLD-ARCH-017`'s mention is an illustrative scenario for the burden field. The scenario is the outlier, so it is the one corrected. The rule in `HLD-RUN-007` (+1 per item) makes the arithmetic unambiguous: 3 items → 3.
- Alternative considered: change `LLD-ITEMS-004` to 1 starting item. Rejected — it would contradict the Walking Staff / Spoiled Potion / Worn Map content used throughout `lld-items`, `lld-floor` (Worn Map beat), and MVP1 scope, cascading far more breakage.

## Risks / Trade-offs

- [Risk] The MODIFIED delta reproduces the entire large `LLD-ARCH-017` block; a transcription error could silently alter an unrelated scenario. → Mitigation: the delta was copied verbatim from the live spec with only the single burden-init scenario edited; verify with `openspec diff` / a line diff before archiving.
- [Trade-off] None of substance — this is a text correction with no behavioral surface.
