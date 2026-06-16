## MODIFIED Requirements

### Requirement: [LLD-ENEMIES-010] Floor 3 Boss — The Judge
The Judge is the guardian at the threshold of Solace. It judges need, not worthiness (see HLD-NAR-002). The fight consists of three entities: The Judge (center) and two passive Witnesses (Witness of Mercy, Witness of Vengeance — see LLD-ENEMIES-021 and LLD-ENEMIES-022). The fight ends when The Judge dies. The Witnesses are optional kills whose effects scale with the player's burden score tier (see HLD-RUN-007 for score accumulation rules; tier brackets defined below).

**Tags:** `judge`. **HP:** 30. **All damage type:** Physical.

`[OPEN·MVP1]` All stat values to be validated in playtesting.
`[OPEN·MVP1]` Vessel-specific Judge dialogue to be written in lld-narrative (per HLD-NAR-002).
`[OPEN·MVP2]` Visual and audio design for Judge encounter to be defined in a UI/art direction session.

**Burden score tier brackets (see HLD-RUN-007):**

| Tier | Score range | Meaning |
|---|---|---|
| Low | 0–7 | Stripped bare — need is undeniable |
| Medium | 8–13 | Carrying something — judgment is mixed |
| High | 14+ | Burdened — testimony weighs against the soul |

**Omen contributions (see HLD-OMEN-006):**
- **Repent** (see LLD-OMEN-CARD-020) ×3 — Judge's only omen contribution; not subject to the standard Tier 1 / Tier 2 family/type model

**Intents (above 30% HP threshold; see HLD-COMBAT-009, HLD-COMBAT-016):**

| Intent ID | Weight | Damage | Max consecutive | Effect |
|---|---|---|---|---|
| `strike` | 50% | 3–5 physical | 2 | Deals damage |
| `suffer` | 30% | — | 2 | Applies Bleed (magnitude +3) to player (see HLD-COMBAT-006, HLD-COMBAT-018) |
| `ponder` | 20% | — | 1 | Evade (is_evade: true) |

**Intent conditional — Pass Judgment phase (≤30% HP; see HLD-COMBAT-014):**

| Condition | Intent ID (forced) | Damage | Effect |
|---|---|---|---|
| `hp_percent_lte:30` | `pass_judgment` | 5–7 physical (release only) | Charge→Release: charge turn telegraphs, no damage; release deals 5–7 physical |

When the `hp_percent_lte:30` condition is met, `pass_judgment` is the only available intent. The weighted random pool (`strike`, `suffer`, `ponder`) is no longer used.

`[OPEN·MVP1]` Damage ranges, intent weights, and Pass Judgment threshold to be validated in playtesting.

#### Scenario: Boss placement
- **WHEN** the player completes all 9 rooms on Floor 3
- **THEN** The Judge encounter begins; both Witnesses spawn simultaneously with The Judge

#### Scenario: Judge is the only required kill
- **WHEN** The Judge's HP reaches 0
- **THEN** the encounter ends regardless of whether either Witness is still alive

#### Scenario: Judge strike
- **WHEN** The Judge's intent resolves to Strike
- **THEN** The Judge deals 3–5 physical damage to the player

#### Scenario: Judge suffer — Bleed applied
- **WHEN** The Judge's intent resolves to Suffer and the player does not have Bleed active
- **THEN** a Bleed StatusInstance with magnitude 3 is applied to the player

#### Scenario: Judge suffer — Bleed stacks on reapplication
- **WHEN** The Judge's intent resolves to Suffer and the player already has an active Bleed StatusInstance
- **THEN** the existing Bleed magnitude increases by 3 (per HLD-COMBAT-018); no new StatusInstance is created

#### Scenario: Judge ponder
- **WHEN** The Judge's intent resolves to Ponder
- **THEN** The Judge sets is_evading = true; player attacks against The Judge this turn have a 35% miss chance; Bleed ticks on The Judge still resolve normally at the omen shift

#### Scenario: Ponder cannot repeat back-to-back
- **WHEN** The Judge resolved Ponder on the previous turn
- **THEN** Ponder is excluded from the pool due to max_consecutive: 1; Strike or Suffer is selected this turn

#### Scenario: Pass Judgment phase entry
- **WHEN** The Judge's HP drops to 30% or below (~9 HP)
- **THEN** the normal intent pool is replaced; The Judge exclusively uses pass_judgment for the remainder of the fight

#### Scenario: Pass Judgment — charge turn
- **WHEN** The Judge is in the Pass Judgment phase and selects pass_judgment
- **THEN** on the charge turn The Judge telegraphs the incoming strike; no damage is dealt; the player has one full turn of counterplay

#### Scenario: Pass Judgment — release turn
- **WHEN** The Judge completed a pass_judgment charge on the previous turn and is alive and un-stunned
- **THEN** the release fires unconditionally dealing 5–7 physical damage to the player

#### Scenario: Pilgrim passes most easily (HLD-NAR-002)
- **WHEN** a Pilgrim reaches The Judge with a Low tier burden score (0–7)
- **THEN** the Witnesses apply their effects at Low tier magnitudes; the Judge encounter is at its least demanding configuration

#### Scenario: Burdened soul faces harder judgment
- **WHEN** a player reaches The Judge with a High tier burden score (14+)
- **THEN** the Witnesses apply their effects at High tier magnitudes; the Judge encounter is at its most demanding configuration

---

## ADDED Requirements

### Requirement: [LLD-ENEMIES-021] Judge Witness — Witness of Mercy
The Witness of Mercy is a passive support entity that sustains The Judge through healing. It never attacks the player. Its Mending magnitude scales with the player's burden score tier (see LLD-ENEMIES-010 tier bracket table).

**Family:** Judge. **Tags:** `judge_witness`. **HP:** 10. **No vulnerability.**

`[OPEN·MVP1]` Mending magnitudes to be validated in playtesting.
`[OPEN·MVP2]` Visual design to be defined in a UI/art direction session.

**Omen contributions:** None.

**Intent (see HLD-COMBAT-009):**

| Intent ID | Weight | Effect |
|---|---|---|
| `testify_mercy` | 100% | Applies Mending to The Judge at magnitude determined by current burden score tier |

**Mending magnitude by tier:**

| Tier | Mending magnitude applied to Judge |
|---|---|
| Low (0–7) | 1 HP/tick |
| Medium (8–13) | 3 HP/tick |
| High (14+) | 5 HP/tick |

The tier is evaluated at the moment `testify_mercy` resolves each turn. Max-wins rules (HLD-COMBAT-019) apply: a lower-magnitude Mending re-application does not overwrite a higher-magnitude active instance until the omen shift clears it. If the player spends items mid-fight and drops a tier, the Witness uses the new tier on its next turn — but the already-applied higher Mending persists until the omen shift.

**Kill consequence:** When the Witness of Mercy dies, a `"vulnerable:physical"` StatusInstance is applied to the player with `remaining_ticks` equal to the current omen cycle's remaining ticks. This Vulnerable persists until the next omen shift.

#### Scenario: Witness of Mercy heals Judge — High tier
- **WHEN** the Witness of Mercy resolves testify_mercy and the burden score is 14 or above
- **THEN** a Mending StatusInstance with magnitude 5 is applied to The Judge; The Judge heals 5 HP per omen tick

#### Scenario: Witness of Mercy heals Judge — Medium tier
- **WHEN** the Witness of Mercy resolves testify_mercy and the burden score is 8–13
- **THEN** a Mending StatusInstance with magnitude 3 is applied to The Judge

#### Scenario: Witness of Mercy heals Judge — Low tier
- **WHEN** the Witness of Mercy resolves testify_mercy and the burden score is 0–7
- **THEN** a Mending StatusInstance with magnitude 1 is applied to The Judge

#### Scenario: Mending max-wins prevents downgrade mid-cycle
- **WHEN** the Witness of Mercy applied Mending 5 (High tier) and the score drops to Medium before the Witness's next turn
- **THEN** on the next testify_mercy, the Mending 3 application loses to the existing Mending 5 instance (max-wins, HLD-COMBAT-019); the higher magnitude persists until the omen shift

#### Scenario: Score drop crosses tier boundary mid-fight
- **WHEN** the player spends items during the fight and the burden score drops from Medium to Low
- **THEN** on the Witness's next turn it applies Mending 1; existing higher Mending on the Judge persists until the omen shift per max-wins

#### Scenario: Witness of Mercy death — player Vulnerable
- **WHEN** the player kills the Witness of Mercy
- **THEN** a `"vulnerable:physical"` StatusInstance is applied to the player lasting until the next omen shift; The Judge's active Mending is not removed (it clears at the omen shift normally)

#### Scenario: Witness of Mercy death stops healing
- **WHEN** the Witness of Mercy is dead
- **THEN** no further Mending is applied to The Judge from this source; The Judge's active Mending expires at the omen shift and is not renewed

---

### Requirement: [LLD-ENEMIES-022] Judge Witness — Witness of Vengeance
The Witness of Vengeance is a passive support entity that empowers The Judge's strikes. It never attacks the player. Its Emboldened (Physical) magnitude scales with the player's burden score tier (see LLD-ENEMIES-010 tier bracket table).

**Family:** Judge. **Tags:** `judge_witness`. **HP:** 10. **No vulnerability.**

`[OPEN·MVP1]` Emboldened magnitudes to be validated in playtesting.
`[OPEN·MVP2]` Visual design to be defined in a UI/art direction session.

**Omen contributions:** None.

**Intent (see HLD-COMBAT-009, HLD-COMBAT-019):**

| Intent ID | Weight | Effect |
|---|---|---|
| `testify_vengeance` | 100% | Applies Emboldened (Physical) to The Judge at magnitude determined by current burden score tier |

**Emboldened (Physical) flat bonus by tier:**

| Tier | Emboldened (Physical) flat bonus applied to Judge |
|---|---|
| Low (0–7) | +1 per hit |
| Medium (8–13) | +2 per hit |
| High (14+) | +3 per hit |

Max-wins rules (HLD-COMBAT-019) apply to Emboldened (Physical) reapplication.

**Kill consequence:** When the Witness of Vengeance dies, a Frenzied StatusInstance (Vulnerable Physical + Emboldened Physical composite; see HLD-COMBAT-006) is applied to the player with `remaining_ticks` equal to the current omen cycle's remaining ticks.

#### Scenario: Witness of Vengeance buffs Judge — High tier
- **WHEN** the Witness of Vengeance resolves testify_vengeance and the burden score is 14 or above
- **THEN** an Emboldened (Physical) StatusInstance with magnitude 3 is applied to The Judge; The Judge's physical attacks gain +3 flat damage per hit

#### Scenario: Witness of Vengeance buffs Judge — Medium tier
- **WHEN** the Witness of Vengeance resolves testify_vengeance and the burden score is 8–13
- **THEN** an Emboldened (Physical) StatusInstance with magnitude 2 is applied to The Judge

#### Scenario: Witness of Vengeance buffs Judge — Low tier
- **WHEN** the Witness of Vengeance resolves testify_vengeance and the burden score is 0–7
- **THEN** an Emboldened (Physical) StatusInstance with magnitude 1 is applied to The Judge

#### Scenario: Witness of Vengeance death — player Frenzied
- **WHEN** the player kills the Witness of Vengeance
- **THEN** a Frenzied StatusInstance is applied to the player with remaining_ticks equal to the current omen cycle's remaining ticks; the player simultaneously gains Vulnerable (Physical) and Emboldened (Physical) effects for the duration

#### Scenario: Frenzied is double-edged
- **WHEN** the player has Frenzied active after killing the Witness of Vengeance and attacks The Judge with a physical weapon
- **THEN** the player's physical attack gains the Emboldened (Physical) flat bonus; any physical hit from The Judge against the player is amplified by ×1.5 due to Vulnerable (Physical)

#### Scenario: Witness of Vengeance death stops Judge buff
- **WHEN** the Witness of Vengeance is dead
- **THEN** no further Emboldened (Physical) is applied to The Judge; The Judge's active Emboldened expires at the omen shift and is not renewed
