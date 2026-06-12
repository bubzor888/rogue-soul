## Context

The Elemental family (Fire, Ice, Lightning Elemental) currently has no designated elite, leaving an asymmetry with the Beast family (which has Bear as a clearly-separated elite). The encounter table in LLD-ENEMIES-002 lists all three Elementals together as "Floor 3 members," making it unclear which are normal and which is the elite. LLD-ENEMIES-016 (Lightning Elemental) exists but has only a narrative attack description — no intents, no escalation, and no formal elite status.

The existing intent infrastructure (`IntentConditional`, `turn_number` condition) is almost sufficient to express escalating attacks and dormant first turns for spawned enemies — the only gap is that `turn_number` is currently undocumented as to whether it's global (CombatState) or per-enemy.

## Goals / Non-Goals

**Goals:**
- Formally designate the Lightning Elemental as the Elemental family elite (parallel to Bear / Beast)
- Define escalating single-attack intent for Phase 1 and Spark phase 2 enemy
- Restructure LLD-ENEMIES-002 into separate Normal and Elite tables with encounter counts
- Simplify LLD-ENEMIES-009 to reference those tables
- Clarify that `turn_number` in IntentConditional is per-enemy, enabling spawned Sparks to use `turn_number:1` for their dormant first turn
- Add `on_death_summons` to EnemyData for the Phase 1 → Phase 2 split mechanic

**Non-Goals:**
- No code changes (docs-only, consistent with prior elemental intent work)
- No elite for Undead or Fanatic families (by design — noted explicitly)
- No new omen cards (Lightning Elemental already has Elemental Synergy — Lightning and Shocked)
- No changes to Fanatic encounter structure (deferred to MVP3 design pass)

## Decisions

### 1. Escalating single attack over Charge→Release
Bear uses Charge→Release — a two-turn pattern with an explicit setup beat. Lightning Elemental uses pure escalation — one attack every turn, growing each turn. These are mechanically distinct patterns: Bear rewards counterplay on the charge turn; Lightning Elemental creates a race. Both are equally valid but feel different.

### 2. Per-enemy `turn_number` semantics
`turn_number:N` references each enemy's own turn counter (`turns_alive: int` on EnemyState), not the global combat round. For enemies that enter at combat start this is equivalent. For mid-combat summons (Sparks) this diverges — a Spark spawned on global turn 3 still sees `turn_number:1` on its first action.

This avoids adding a new condition type (`just_spawned`, `turns_alive_equals`). The existing `turn_number` conditional handles it correctly once the semantics are clarified. The `turns_alive` field needs to be added to EnemyState in LLD-ARCH-017 when implemented (not done in this docs-only pass).

### 3. `on_death_summons` for phase transition
The Wolf's Howl intent uses `summon_enemy_id` (intent-triggered spawn). Lightning Elemental's phase transition happens on death, not on an intent. A new `on_death_summons: Array[String]` field on EnemyData gives `resolve_enemy_death` a data-driven way to spawn the Sparks — no Lightning-Elemental-specific code paths.

### 4. Separate Normal / Elite tables in LLD-ENEMIES-002
The single "Floor 3 members" column made it impossible to scan encounter composition without reading every individual requirement. Two tables (Normal with pre/post-elite counts, Elite) make the structure immediately readable. Individual requirements repeat their own counts for local context; the tables are authoritative.

### 5. Spark as a separate EnemyData resource
Sparks share tags with Phase 1 (`elemental`, `elemental_lightning`) but are distinct enemies with different HP and intents. A separate `lightning_spark` EnemyData resource is the correct LLD pattern — it keeps Phase 1 and Phase 2 fully independent and allows each to be tuned separately.

## Risks / Trade-offs

- **Damage values need playtesting** — Phase 1 escalation (1–3 → 3–6 → 6–9 → 9–12) and Spark escalation (1–2 → 2–4 → 3–5) are initial estimates. All ranges are tagged `[OPEN·MVP1]`.
- **`turns_alive` not added to LLD-ARCH-017 in this pass** — the field is defined by reference in LLD-ARCH-018's IntentConditional note. When implementing, `turns_alive: int` needs to be added to EnemyState in LLD-ARCH-017 and incremented at the start of each enemy's turn in `resolve_enemy_turns`.
- **Undead/Fanatic have no elite** — correct by design. If this changes, it requires a new change proposal.
- **Fanatic Totem encounters** — Buff Totem and Absorption Totem aren't represented in the Normal Enemies table (they pair with Fanatics, not standalone). Tagged `[OPEN·MVP3]` for the Fanatic design pass.
