## MODIFIED Requirements

### Requirement: [LLD-ENEMIES-002] Enemy Families
Enemies SHALL be grouped into families sharing a damage type, omen identity, and vulnerability logic. Floor 3 presents the entry tier of each family.

**Normal enemies** — appear in pre-elite and post-elite combat rooms; encounter count per enemy is fixed and authoritative (individual requirements repeat these counts for local reference):

| Family | Enemy | Pre-elite count | Post-elite count |
|---|---|---|---|
| Undead | Skeleton | 1 | 2 |
| Undead | Zombie | 1 | 2 |
| Beast | Plague Rat | 3 | 3 |
| Beast | Wolf | 2 | 3 |
| Elemental | Fire Elemental | 1 | 2 |
| Elemental | Ice Elemental | 1 | 2 |
| Fanatic | Low HP Fanatic | 1 | 2 |
| Fanatic | High HP Fanatic | 1 | 2 |

`[OPEN·MVP3]` Buff Totem and Absorption Totem are Fanatic-family support entities that appear alongside Fanatics, not as standalone encounters. Their encounter pairing rules are deferred to the Fanatic design pass.

**Elite enemies** — appear in the elite gate room only; one per run:

| Family | Enemy | Encounter |
|---|---|---|
| Beast | Bear | 1 (solo) |
| Elemental | Lightning Elemental | 1 (two-phase: 18 HP → 2 Sparks at 6 HP each) |

Undead and Fanatic families do not have a dedicated Floor 3 elite by design.

#### Scenario: Normal enemy encounter count — pre-elite
- **WHEN** the player enters a pre-elite combat room and the drawn enemy is a Skeleton
- **THEN** exactly 1 Skeleton is present (per the pre-elite count in the Normal Enemies table)

#### Scenario: Normal enemy encounter count — post-elite
- **WHEN** the player enters a post-elite combat room and the drawn enemy is a Wolf
- **THEN** exactly 3 Wolves are present (per the post-elite count in the Normal Enemies table)

#### Scenario: Elite enemy drawn once per floor
- **WHEN** the elite gate room is reached on Floor 3
- **THEN** one elite enemy from the Elite Enemies table is drawn; no normal enemy appears in this room

---

### Requirement: [LLD-ENEMIES-009] Floor 3 Encounter Structure
Floor 3 encounter composition SHALL follow this structure:

| Phase | Rooms | Draw source |
|---|---|---|
| Opening | 1–3 | Normal Enemies table (LLD-ENEMIES-002) — pre-elite count per enemy |
| Companion | 4 | Worn Map trigger — no combat |
| Elite gate | 5 | Elite Enemies table (LLD-ENEMIES-002) — one elite enemy |
| Post-elite | 6–9 | Normal Enemies table (LLD-ENEMIES-002) — post-elite count per enemy |
| Boss | — | The Judge (LLD-ENEMIES-010) |

A standard Floor 3 Pilgrim run yields 5 loot choices (4 standard + 1 elite) before the Judge.

Encounter sizes (number of enemies per room) are determined by the pre-elite and post-elite counts in LLD-ENEMIES-002. The tables in LLD-ENEMIES-002 are authoritative; individual enemy requirements repeat counts for local reference only.

#### Scenario: Post-elite encounter escalation
- **WHEN** the player completes the elite encounter on Floor 3
- **THEN** all subsequent standard rooms draw from the post-elite count column in LLD-ENEMIES-002

#### Scenario: Elite gate uses Elite Enemies table
- **WHEN** the elite gate room is reached
- **THEN** the encounter is drawn from the Elite Enemies table in LLD-ENEMIES-002; no normal enemy is drawn for this room

---

### Requirement: [LLD-ENEMIES-016] Floor 3 Enemy — Lightning Elemental
**Family:** Elemental. **Elite** (see LLD-ENEMIES-002 Elite Enemies table). **Tags:** `elemental`, `elemental_lightning` (both phases — Sparks inherit the same tags). Shared family omen card: see `LLD-OMEN-CARD-013` (Elemental Synergy — Lightning).
**HP (Phase 1):** 18. **Resistance:** Lightning ×0.5. **Vulnerability:** None.

`[OPEN·MVP3]` `[OPEN·MVP2]` Door symbol to be designed in a UI/art direction session.

**Encounter:** Elite gate only; 1 Lightning Elemental per run (see LLD-ENEMIES-002 Elite Enemies table).

**Two-phase:** Lightning Elemental reaches 0 HP → `resolve_enemy_death` processes `on_death_summons` and spawns two `lightning_spark` enemies (see `LLD-ARCH-018`). The Sparks start at `turns_alive: 1`; their `spark_dormant` intent is forced by a `turn_number:1` conditional, so the enemy side takes no action on the split turn. Lightning Elemental's omen contributions are removed from the deck on death per `HLD-OMEN-006`.

**Omen contributions (Phase 1 only):** `elemental_synergy_lightning` (Elemental Synergy — Lightning) ×1, `LLD-OMEN-CARD-002` (Shocked) ×1.

---

**Phase 1 Intents (see `HLD-COMBAT-009`, `HLD-COMBAT-016`):**

The Lightning Elemental has only one attack — an escalating lightning strike. Damage increases each turn, making speed critical.

| Intent ID | Weight | Damage | Effect |
|---|---|---|---|
| `lightning_surge_1` | — | 1–3 lightning | Forced on turn 1 via conditional |
| `lightning_surge_2` | — | 3–6 lightning | Forced on turn 2 via conditional |
| `lightning_surge_3` | — | 6–9 lightning | Forced on turn 3 via conditional |
| `lightning_surge_4` | 100% | 9–12 lightning | Default from turn 4 onward |

**Phase 1 intent conditionals:**

| Condition | intent_id (forced) |
|---|---|
| `turn_number:1` | `lightning_surge_1` |
| `turn_number:2` | `lightning_surge_2` |
| `turn_number:3` | `lightning_surge_3` |

`[OPEN·MVP1]` Phase 1 damage ranges and escalation pacing to be validated in playtesting.

---

**Phase 2 — Lightning Spark** (`enemy_id: "lightning_spark"`)

**Tags:** `elemental`, `elemental_lightning`. **HP:** 6. **Resistance:** Lightning ×0.5. **Vulnerability:** None.

Two Sparks are spawned simultaneously when the Lightning Elemental dies. Each Spark is an independent enemy with its own HP, intent selection, and per-enemy `turn_number` counter starting at 1.

**Omen contributions:** None — no new cards are added to the deck when Sparks spawn. The Phase 1 omen deck composition persists through Phase 2 (per `HLD-OMEN-006`).

**Spark intents (see `HLD-COMBAT-009`, `HLD-COMBAT-016`):**

| Intent ID | Weight | Damage | Effect |
|---|---|---|---|
| `spark_dormant` | — | — | No action (forced on turn_number:1 via conditional) |
| `spark_surge_1` | — | 1–2 lightning | Forced on turn_number:2 via conditional |
| `spark_surge_2` | — | 2–4 lightning | Forced on turn_number:3 via conditional |
| `spark_surge_3` | 100% | 3–5 lightning | Default from turn_number:4 onward |

**Spark intent conditionals:**

| Condition | intent_id (forced) |
|---|---|
| `turn_number:1` | `spark_dormant` |
| `turn_number:2` | `spark_surge_1` |
| `turn_number:3` | `spark_surge_2` |

`[OPEN·MVP1]` Spark damage ranges to be validated in playtesting.

---

#### Scenario: Two-phase transition
- **WHEN** the Lightning Elemental reaches 0 HP
- **THEN** combat does not end; `resolve_enemy_death` processes `on_death_summons` and spawns two `lightning_spark` enemies; both Sparks start at `turn_number:1` and resolve `spark_dormant`; the enemy side deals no damage on the split turn

#### Scenario: Sparks inherit no new omen cards
- **WHEN** the Lightning Elemental splits into Sparks
- **THEN** no new omen cards are added to the deck; the Elemental's contributions are removed per HLD-OMEN-006; the Phase 1 deck persists through Phase 2

#### Scenario: Resource management across phases
- **WHEN** the player transitions to Phase 2
- **THEN** all charges, consumables, and HP carry over unchanged

#### Scenario: Phase 1 turn 1 — minimum threat
- **WHEN** it is the Lightning Elemental's first turn (turn_number:1)
- **THEN** the `lightning_surge_1` conditional matches; 1–3 lightning damage is dealt; the player has 3 turns to kill Phase 1 before damage becomes dangerous

#### Scenario: Phase 1 escalation — turn 4+
- **WHEN** the Lightning Elemental survives to turn 4 or beyond
- **THEN** no `turn_number` conditional matches; `lightning_surge_4` is selected from the default pool; 9–12 lightning damage is dealt

#### Scenario: Spark dormant on spawn turn
- **WHEN** two Lightning Sparks are spawned (each with turn_number:1)
- **THEN** both Sparks resolve `spark_dormant`; no damage is dealt on the spawn turn; the player gets a free action window to begin killing Sparks before they activate

#### Scenario: Spark escalation — both alive at turn 4+
- **WHEN** both Sparks survive to turn 4 of their own existence (their personal turn_number:4)
- **THEN** each resolves `spark_surge_3` (3–5 lightning per Spark); combined threat is 6–10 lightning if both land

#### Scenario: Kill one Spark early — pressure reduced
- **WHEN** the player kills one Spark before it reaches turn_number:4
- **THEN** only the surviving Spark escalates; maximum Phase 2 damage is 3–5 per turn rather than 6–10

#### Scenario: Elemental Synergy (Lightning) converts player attacks
- **WHEN** Elemental Synergy (Lightning) is active on the player side against a Lightning Elemental or Spark
- **THEN** the player receives a `type_convert` StatusInstance with `string_param: "lightning"`; a physical weapon's damage is converted to lightning type; the Lightning Elemental's or Spark's lightning resistance (×0.5) applies
