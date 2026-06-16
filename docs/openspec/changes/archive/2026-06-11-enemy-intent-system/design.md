## Context

This change is spec-only. No GDScript is written here — the design decisions captured here inform a future implementation change. The intent system is a foundational combat mechanic that all current and future enemies depend on, so the rules need to be settled at HLD before any enemy data is authored.

## Goals / Non-Goals

**Goals:**
- Settle the HLD rules for intent selection so future enemy entries can reference them without re-explaining the mechanic.
- Establish enemy damage variance and the player-flat asymmetry as a deliberate design principle.
- Add `EnemyInstance` runtime field requirements to the arch doc so the implementation change has clear guidance.
- Land the Skeleton and Zombie as the first two complete enemy entries with intent tables and damage ranges.

**Non-Goals:**
- Implementing any GDScript (future change).
- Designing intents for any enemy beyond Skeleton and Zombie (those will be added in subsequent changes as each enemy family is designed).
- Designing intent triggers for Skeleton or Zombie (neither has any).

## Decisions

### D1 — Weighted random with re-roll on streak cap, not weight re-normalization

**Decision:** When an enemy hits its consecutive intent cap, the engine re-rolls until a different intent comes up, rather than removing the capped intent from the pool and re-normalizing the remaining weights.

**Rationale:** Re-roll is simpler to implement and understand. With 2–3 intents per enemy, re-roll resolves in at most one or two retries in practice. Re-normalizing weights would require a temporary weight table per roll, adds complexity, and subtly changes the relative probability distribution of non-capped intents in a way that is harder to reason about at spec time.

**Alternative considered:** Re-normalize remaining weights. Rejected — adds implementation complexity with no perceptible gameplay difference at 2–3 intents.

### D2 — Enemy damage is a range, player damage is flat

**Decision:** All enemy damage intents specify a min–max range (e.g. 4–6 physical). Player weapon damage is always a flat value.

**Rationale:** Enemy variance creates urgency and read-the-room decisions (prioritise the enemy hitting harder). Player flatness enables precise resource planning ("I need exactly 2 Walking Staff hits to kill this"). This asymmetry is intentional — the player's side should feel controlled and predictable; the enemy's side should feel alive and reactive.

**Alternative considered:** Variance on both sides. Rejected — player variance makes resource math unreliable and erodes the satisfaction of clean kill plans.

### D3 — Charge→Release cancel on kill or stun

**Decision:** If a charging enemy is killed or Shocked during the charge turn, the release never fires. The charge is simply discarded.

**Rationale:** This is the core counterplay of the Charge→Release pattern. The charge turn exists specifically to give the player a window. If a stun or kill during that window didn't cancel the release, the mechanic would feel unfair.

### D4 — Streak tracking is per-instance runtime state, not data

**Decision:** `last_intent_id` and `intent_streak` are runtime fields on `EnemyInstance`, not part of the enemy data resource.

**Rationale:** These values are transient combat state — they reset at the start of every new encounter. Putting them in the data file would conflate authored content with runtime bookkeeping. The max streak limit per intent IS authored data (it belongs in the enemy's intent table definition).

## Risks / Trade-offs

- **Damage ranges change kill reference math** → Kill references in LLD-ENEMIES are now ranges, not exact turn counts. Acceptable — they were always approximations anyway. Updated in this change for Skeleton and Zombie.
- **Re-roll could theoretically loop** → With 2 intents at 50/50 and a cap of 1, a re-roll always succeeds on the first retry. With 3 intents it resolves faster. No infinite loop risk at current enemy sizes.
- **Slam consecutive limit (max 1) changes Zombie's expected damage** → Back-to-back Slams are prevented. This slightly lowers Zombie's burst ceiling but keeps the encounter from feeling like repeated punishment.

## Open Questions

- `[OPEN·MVP1]` Should trigger overrides be able to force a *sequence* of intents (e.g. "always Slam after a Shamble")? Current design only overrides the current turn's roll. Sequences would require a queued-intent field in addition to streak tracking.
