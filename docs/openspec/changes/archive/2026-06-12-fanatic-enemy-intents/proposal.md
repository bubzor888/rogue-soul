## Why

The Fanatic family enemies (Low HP Fanatic, High HP Fanatic, Buff Totem, Absorption Totem) have placeholder narrative attack descriptions rather than formal intent tables. The Totem "aura" mechanic is modelled as an always-on passive effect — this doesn't fit the intent system and creates an inconsistency with every other enemy. Converting Totems to intent-based status application and formalising Fanatic intents gives the family proper mechanical identity.

## What Changes

- **New HLD rule (HLD-COMBAT-019):** Max-wins reapplication for Hardened and Emboldened — when reapplied to a target already carrying the same status, the higher magnitude is kept; the lower-magnitude application has no effect
- **LLD-ARCH-018:** Add `"allies"` as a valid `status_target` value — applies the status to all living enemies on the enemy side except the caster; required for Totem buffing intents
- **LLD-ENEMIES-017 (Low HP Fanatic):** Replace narrative attack with intent table: `strike` 60% (3–5 physical), `taunt` 20% (applies Frenzied to player), `evade` 20%
- **LLD-ENEMIES-018 (High HP Fanatic):** Same intent structure: `strike` 60% (2–4 physical), `taunt` 20% (applies Frenzied to player), `evade` 20%
- **LLD-ENEMIES-019 (Buff Totem):** Replace "aura" mechanic with single intent `embolden_allies` (100% — applies Emboldened (Physical) magnitude 2 to all allies via `status_target: "allies"`); Totem no longer needs to die to remove the buff — status decays at end of current omen cycle
- **LLD-ENEMIES-020 (Absorption Totem):** Replace "aura" mechanic with single intent `harden_allies` (100% — applies Hardened magnitude 3 to all allies via `status_target: "allies"`); same decay model as Buff Totem

## Capabilities

### New Capabilities

- None

### Modified Capabilities

- `hld-combat-system`: New HLD-COMBAT-019 requirement — max-wins reapplication rule for Hardened and Emboldened
- `lld-technical-architecture`: LLD-ARCH-018 — add `"allies"` value to IntentWeight `status_target`
- `lld-enemies`: LLD-ENEMIES-017, -018, -019, -020 — Fanatic and Totem intent tables

## Impact

- `openspec/specs/hld-combat-system/spec.md` — new requirement HLD-COMBAT-019
- `openspec/specs/lld-technical-architecture/spec.md` — LLD-ARCH-018 `status_target` update + new scenarios
- `openspec/specs/lld-enemies/spec.md` — four modified enemy requirements
- No code changes in this pass (docs-only)
