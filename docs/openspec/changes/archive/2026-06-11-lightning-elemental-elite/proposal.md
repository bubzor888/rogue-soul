## Why

The Elemental family has two normal enemies (Fire and Ice Elemental) but no elite, leaving a gap in the Floor 3 encounter roster. The Lightning Elemental fills that role as a two-phase elite: a high-pressure single attacker that splits into two Sparks on death, rewarding fast kills and punishing slow play.

## What Changes

- Designate the Lightning Elemental as the Elemental family elite (parallel to Bear in the Beast family)
- Add escalating single-attack intent for Lightning Elemental Phase 1 (turns 1–4+): 1–3 → 3–6 → 6–9 → 9–12 lightning damage
- Add Spark (Phase 2) enemy entity: dormant on turn 1 (summoned), then escalating attack 1–2 → 2–4 → 3–5 per Spark
- Restructure LLD-ENEMIES-002 encounter table into separate Normal and Elite sub-tables with pre-elite and post-elite encounter counts for normal enemies
- Update LLD-ENEMIES-009 to reference the new tables instead of embedding enemy lists inline
- Clarify that `turn_number` in IntentConditional is per-enemy (counted from when the enemy was introduced), enabling summoned Sparks to use `turn_number:1` for their dormant first turn

## Capabilities

### New Capabilities

- None

### Modified Capabilities

- `lld-enemies`: LLD-ENEMIES-002 (encounter table restructured into Normal + Elite tables), LLD-ENEMIES-009 (references new tables), LLD-ENEMIES-016 (Lightning Elemental fully defined as elite with Phase 1 escalating intent and Spark entity)
- `lld-technical-architecture`: LLD-ARCH-018 (IntentConditional `turn_number` semantics clarified as per-enemy)

## Impact

- `openspec/specs/lld-enemies/spec.md` — structural and content changes to LLD-ENEMIES-002, -009, -016
- `openspec/specs/lld-technical-architecture/spec.md` — one-line clarification to LLD-ARCH-018 IntentConditional table
- No code changes in this pass (docs-only, consistent with prior elemental enemy intent changes)
