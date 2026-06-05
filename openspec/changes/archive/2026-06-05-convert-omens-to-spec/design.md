## Context

The omen system sits at the intersection of combat mechanics (CombatResolver), status effects (already in `hld-combat-system`), and UI (the omen deck display in CombatScene). Its mechanics are fully confirmed in v0.2 of the omens doc with only specific numeric values left open.

## Goals / Non-Goals

**Goals:**
- All confirmed omen mechanics captured as numbered requirements
- All confirmed omen cards captured with their full effects
- Open questions (deck sizes, card number distribution, floor pool contents, Emboldened values) carried as `[OPEN]` requirements
- `HLD-COMBAT-008` stub replaced with a real reference

**Non-Goals:**
- Resolving any open questions
- Designing Floor 3's omen pool (which is entirely `[OPEN]`)
- Designing enemy-specific omen contributions (already in `lld-enemies` as `[OPEN]`)

## Decisions

### Requirement ID Scheme
- `lld-omen-mechanics`: `LLD-OMEN-MECH-001` onwards
- `lld-omen-cards`: `LLD-OMEN-CARD-001` onwards

### Relationship to hld-combat-system
Status effects (Burning, Shocked, etc.) and their per-tick values live in `HLD-COMBAT-006`. The omen *system* (how cards are drawn, applied, and cycled) lives in `lld-omen-mechanics`. Omen *cards* (what a specific card does when played) live in `lld-omen-cards`. This separation avoids circular references.

## Risks / Trade-offs

- **Many open questions** — the Floor 3 omen pool and card number distribution are entirely undesigned. Specs will have `[OPEN]` requirements for these; they must be resolved before the omen deck can be implemented.
- **Numeric values** — some confirmed values (Emboldened bonus amounts) are first-pass placeholders. They are spec'd as confirmed first-pass values with `[OPEN]` tuning notes.
