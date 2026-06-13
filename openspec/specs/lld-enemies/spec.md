## Purpose
Defines all Floor 3 enemies — their stats, intents, omen contributions, family tags, and encounter structure.
## Requirements
### Requirement: [LLD-ENEMIES-001] Enemy Design Philosophy
Every enemy SHALL simultaneously serve three purposes: (1) a combat threat with a learnable mechanic, (2) an omen deck contributor that shapes combat feel, and (3) the entry tier of a family that scales across floors. Not every enemy requires an elemental vulnerability — behavioural mechanics (pack dynamics, absorption, on-death effects) are equally valid design.

#### Scenario: Enemy family scaling
- **WHEN** the player encounters a Skeleton on Floor 3 and later a Bone Warrior on a mid floor
- **THEN** both share the same fire vulnerability, omen contribution type, and combat identity — only stats increase

---

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

### Requirement: [LLD-ENEMIES-004] Floor 3 Enemy — Skeleton
**Family:** Undead. **Tags:** `undead`. Shared family omen card: see `LLD-OMEN-CARD-011` (Grave Knit).
**HP:** 12. **Vulnerability:** Fire (×1.5 fire damage, see `HLD-COMBAT-007`).

`[OPEN·MVP2]` Door symbol for Skeleton combat encounters to be designed in a UI/art direction session.

**Intents (see `HLD-COMBAT-009`, `HLD-COMBAT-016`):**

| Intent ID | Weight | Damage | Max consecutive | Effect |
|---|---|---|---|---|
| `strike` | 70% | 4–6 physical | 2 | Deals damage |
| `chill_touch` | 30% | — | 2 | Applies Chilled to the player (see `HLD-COMBAT-015`) |

**Omen contributions (see `HLD-OMEN-006`):**
- **Family card:** `LLD-OMEN-CARD-011` (Grave Knit) ×1 per Skeleton
- **Type card:** `LLD-OMEN-CARD-004` (Emboldened Physical) ×1 (total, regardless of Skeleton count)

**Kill references** (assumes Strike every turn; actual turns vary as Chill Touch deals no damage):
- Throw Rock (3 dmg): 4–5 turns
- Walking Staff (6 dmg): 2–3 turns
- Fire Bomb at 2 ticks (10 fire × 1.5 = 15): 1 turn — one-shot regardless of intent

#### Scenario: Skeleton fire one-shot
- **WHEN** the player applies Fire Bomb to a Skeleton and the timer is 2 ticks (typical)
- **THEN** the Skeleton takes 15 fire damage total and dies (HP: 12)

#### Scenario: Skeleton Strike
- **WHEN** the Skeleton's intent resolves to Strike
- **THEN** the Skeleton deals 4–6 physical damage to the player

#### Scenario: Skeleton Chill Touch — Chilled not yet active
- **WHEN** the Skeleton's intent resolves to Chill Touch and the player does not have Chilled
- **THEN** Chilled is applied to the player; no damage is dealt

#### Scenario: Skeleton Chill Touch — Chilled already active
- **WHEN** the Skeleton's intent resolves to Chill Touch and the player already has Chilled
- **THEN** no change occurs; the intent still does not deal damage (see `HLD-COMBAT-015`)

---

### Requirement: [LLD-ENEMIES-005] Floor 3 Enemy — Zombie
**Family:** Undead. **Tags:** `undead`. Shared family omen card: see `LLD-OMEN-CARD-011` (Grave Knit).
**HP:** 16. **Vulnerability:** Physical (×1.5 with Brittle Charm only, per `HLD-COMBAT-005`).

`[OPEN·MVP2]` Door symbol for Zombie combat encounters to be designed in a UI/art direction session.

**Intents (see `HLD-COMBAT-009`, `HLD-COMBAT-014`, `HLD-COMBAT-016`):**

| Intent ID | Weight | Damage | Max consecutive | Effect |
|---|---|---|---|---|
| `swipe` | 40% | 2–4 physical | 2 | Deals damage |
| `slam` | 40% | 5–7 physical (release only) | 1 | Charge→Release: charge turn telegraphs, no damage; release deals 5–7 physical |
| `shamble` | 20% | — | 2 | No action |



**Omen contributions (see `HLD-OMEN-006`):**
- **Family card:** `LLD-OMEN-CARD-011` (Grave Knit) ×1 per Zombie
- **Type card:** `LLD-OMEN-CARD-004` (Emboldened Physical) ×1 (total, regardless of Zombie count)

**Kill references** (assumes all Swipe turns; actual turns vary):
- Walking Staff (6 dmg): 3–8 turns
- With Brittle Charm (6 × 1.5 = 9 dmg): 2–6 turns

#### Scenario: Zombie Swipe
- **WHEN** the Zombie's intent resolves to Swipe
- **THEN** the Zombie deals 2–4 physical damage to the player

#### Scenario: Zombie Slam — charge turn
- **WHEN** the Zombie's intent resolves to Slam
- **THEN** on this turn the Zombie telegraphs the incoming Slam but deals no damage; the player has one full turn of counterplay

#### Scenario: Zombie Slam — release turn
- **WHEN** the Zombie completed a Slam charge on the previous turn and is alive and un-stunned
- **THEN** the Slam fires unconditionally and deals 5–7 physical damage

#### Scenario: Zombie Slam — kill during charge
- **WHEN** the player kills the Zombie during the Slam charge turn
- **THEN** the release never fires; combat ends normally

#### Scenario: Zombie Shamble
- **WHEN** the Zombie's intent resolves to Shamble
- **THEN** the Zombie takes no action; the player takes no damage from this enemy this turn

#### Scenario: Zombie physical vulnerability activation
- **WHEN** the player uses Brittle Charm on a Zombie and then attacks with a physical weapon
- **THEN** the weapon's damage is multiplied by ×1.5

#### Scenario: Zombie Slam cannot repeat immediately
- **WHEN** the Zombie just completed a Slam (charge + release) and rolls its next intent
- **THEN** if the roll produces Slam again it is re-rolled until a different intent is selected (max_consecutive: 1)

---

### Requirement: [LLD-ENEMIES-006] Floor 3 Enemy — Plague Rat
**Family:** Beast. **Tags:** `beast`. Shared family omen card: see `LLD-OMEN-CARD-012` (Thick Hide).
**HP:** 3 per rat. **Encounter:** Always 3 simultaneously in pre-elite.
**Immunity:** Poisoned. **No vulnerability.**

`[OPEN·MVP2]` Door symbol for Plague Rat combat encounters to be designed in a UI/art direction session.

**On death:** Each rat death applies or advances the Poisoned individual omen on the player (+2 to current Poisoned value; starts at 2 if none active).

**Intents (see `HLD-COMBAT-009`, `HLD-COMBAT-016`):**

| Intent ID | Weight | Damage | Max consecutive | Effect |
|---|---|---|---|---|
| `bite` | 70% | 1–3 physical | 2 | Deals damage |
| `evade` | 30% | — | 2 | Evade (is_evade: true) |

**Omen contributions (see `HLD-OMEN-006`):**
- **Family card:** `LLD-OMEN-CARD-012` (Thick Hide) ×1 per rat (3 total)
- **Type card:** `LLD-OMEN-CARD-019` (Exposed) ×1 (total, regardless of rat count)

#### Scenario: Pack group size
- **WHEN** Plague Rats appear in a pre-elite encounter
- **THEN** exactly 3 Plague Rats are present

#### Scenario: On-death poison escalation
- **WHEN** the player kills a Plague Rat
- **THEN** the Poisoned omen value increases by 2; if not yet active, a new Poisoned omen starts at value 2

#### Scenario: Plague Rat bite
- **WHEN** a Plague Rat's intent resolves to Bite
- **THEN** the rat deals 1–3 physical damage to the player; with all 3 rats alive, total enemy-side damage this turn is 3–9 if all bite

#### Scenario: Plague Rat evade
- **WHEN** a Plague Rat's intent resolves to Evade
- **THEN** the rat sets is_evading = true; any player attack targeting that rat this turn has a 35% miss chance

---

### Requirement: [LLD-ENEMIES-007] Floor 3 Enemy — Wolf
**Family:** Beast. **Tags:** `beast`. Shared family omen card: see `LLD-OMEN-CARD-012` (Thick Hide).
**HP:** 6. **Attack:** 4–6 physical (pack: 2+ wolves alive); 2–4 physical (lone: last wolf alive). **Encounter:** 2 Wolves pre-elite, 3 Wolves post-elite. **No vulnerability.**

`[OPEN·MVP2]` Door symbol for Wolf combat encounters to be designed in a UI/art direction session.

**Intents (see `HLD-COMBAT-009`, `HLD-COMBAT-016`, `LLD-ARCH-018`):**

| Intent ID | Weight | Damage | Max consecutive | Effect |
|---|---|---|---|---|
| `bite_pack` | 50% | 4–6 physical | — | Deals pack damage (available when 2+ wolves alive) |
| `bite_lone` | 50% | 2–4 physical | — | Deals lone damage (available when last wolf alive) |
| `evade` | 50% | — | — | Evade (is_evade: true; available when 2+ wolves alive) |
| `howl` | 50% | — | 1 | Summons one Wolf (summon_enemy_id: `"wolf"`; available when last wolf alive) |

**Intent conditionals:**

| Condition | intent_ids (pool restriction) |
|---|---|
| `ally_count_above:0` | `["bite_pack", "evade"]` — 50/50 between these two |
| `ally_count_equals:0` | `["bite_lone", "howl"]` — 50/50 between these two |

**Omen contributions (see `HLD-OMEN-006`):**
- **Family card:** `LLD-OMEN-CARD-012` (Thick Hide) ×1 per wolf instance (including summoned wolves)
- **Type card:** `LLD-OMEN-CARD-019` (Exposed) ×1 (total, regardless of wolf count)

#### Scenario: Pack damage threshold
- **WHEN** 2 or more Wolves are alive
- **THEN** each Wolf rolls from the `[bite_pack, evade]` pool; attacking wolves deal 4–6 physical damage each

#### Scenario: Pack damage drops when one wolf dies
- **WHEN** the player kills one wolf, leaving a single wolf alive
- **THEN** the surviving wolf now rolls from the `[bite_lone, howl]` pool; its attacks deal 2–4 physical damage

#### Scenario: Wolf pack encounter size
- **WHEN** Wolves appear pre-elite
- **THEN** 2 Wolves are present; post-elite, 3 Wolves are present

#### Scenario: Pack wolf evade
- **WHEN** 2 or more Wolves are alive and a Wolf's intent resolves to Evade
- **THEN** the wolf sets is_evading = true; the player's attack against that wolf this turn has a 35% miss chance

#### Scenario: Last wolf howls — summon
- **WHEN** exactly 1 Wolf is alive and its intent resolves to Howl
- **THEN** a new Wolf (6 HP, fresh instance) is added to combat; one Thick Hide card is injected into the omen deck draw pile; the pack condition (ally_count_above:0) is now met for both wolves

#### Scenario: Howl max_consecutive prevents back-to-back summons
- **WHEN** a Wolf just used Howl and is the last wolf alive again on its next turn
- **THEN** Howl is excluded from the pool due to max_consecutive: 1; the wolf is forced to select bite_lone this turn before Howl becomes available again

#### Scenario: Summoned wolf removed on death
- **WHEN** a summoned Wolf dies
- **THEN** its Thick Hide family card copy is removed from the draw pile and discard pile immediately, per HLD-OMEN-006 Tier 1 rules

---

### Requirement: [LLD-ENEMIES-008] Floor 3 Enemy — Bear
**Family:** Beast. **Tags:** `beast`. Shared family omen card: see `LLD-OMEN-CARD-012` (Thick Hide).
**HP:** 22. **Encounter:** 1 Bear — elite only. **No vulnerability.**

`[OPEN·MVP2]` Door symbol for Bear combat encounters to be designed in a UI/art direction session.

**Sleeping — Round 1:** Bear does not act on round 1. The `sleeping` intent is forced by an IntentConditional on `turn_number:1`.

**Intents (see `HLD-COMBAT-009`, `HLD-COMBAT-016`, `LLD-ARCH-018`):**

| Intent ID | Weight | Damage | hit_count | Max consecutive | Effect |
|---|---|---|---|---|---|
| `sleeping` | — | — | — | 1 | No action (forced turn 1 only via conditional) |
| `bite` | 40% | 4–6 physical | 1 | — | Deals damage |
| `swipe` | 40% | 3–5 physical | 2 | — | Two independent hits, each rolling 3–5 physical |
| `frenzy` | 20% | — | — | 1 | Applies Frenzied to self (status_apply: `"frenzied"`, status_target: `"self"`) |



**Intent conditionals:**

| Condition | intent_id (forced) |
|---|---|
| `turn_number:1` | `sleeping` |

**Omen contributions (see `HLD-OMEN-006`):**
- **Family card:** `LLD-OMEN-CARD-012` (Thick Hide) ×1
- **Type card:** `LLD-OMEN-CARD-019` (Exposed) ×1

#### Scenario: Bear solo encounter
- **WHEN** a Bear encounter occurs
- **THEN** exactly one Bear is present

#### Scenario: Bear sleeping round
- **WHEN** combat begins against the Bear
- **THEN** the player takes their first action freely; the Bear does not attack until round 2

#### Scenario: Bear bite
- **WHEN** the Bear's intent resolves to Bite
- **THEN** the Bear deals 4–6 physical damage in a single hit

#### Scenario: Bear swipe — two independent hits
- **WHEN** the Bear's intent resolves to Swipe
- **THEN** the Bear makes 2 separate damage rolls of 3–5 physical each; each roll is independently subject to the evasion miss chance if the player is evading; total damage is 6–10 if both land

#### Scenario: Bear swipe — player evading
- **WHEN** the Bear resolves Swipe and the player is evading
- **THEN** each of the 2 hits independently rolls a 35% miss chance; it is possible for 0, 1, or 2 hits to land

#### Scenario: Bear frenzy — self application
- **WHEN** the Bear's intent resolves to Frenzy
- **THEN** the Frenzied status (Vulnerable Physical + Emboldened Physical; see HLD-COMBAT-006) is applied to the Bear itself; no damage is dealt this turn

#### Scenario: Bear frenzy — risk/reward
- **WHEN** the Bear has Frenzied active and its next intent is Bite or Swipe
- **THEN** the Bear's physical damage benefits from Emboldened (Physical) flat bonus; the Bear also takes ×1.5 physical damage from the player's physical attacks for the duration of the status

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

### Requirement: [LLD-ENEMIES-010] Floor 3 Boss — The Judge
The Judge is the guardian at the threshold of Solace. It judges need, not worthiness (see HLD-NAR-002). The fight consists of three entities: The Judge (center) and two passive Witnesses (Witness of Mercy, Witness of Vengeance — see LLD-ENEMIES-021 and LLD-ENEMIES-022). The fight ends when The Judge dies. The Witnesses are optional kills whose effects scale with the player's burden score tier (see HLD-RUN-007 for score accumulation rules; tier brackets defined below).

**Tags:** `judge`. **HP:** 30. **All damage type:** Physical.

`[OPEN·MVP2]` Vessel-specific Judge dialogue to be written in lld-narrative (per HLD-NAR-002).
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

### Requirement: [LLD-ENEMIES-021] Judge Witness — Witness of Mercy
The Witness of Mercy is a passive support entity that sustains The Judge through healing. It never attacks the player. Its Mending magnitude scales with the player's burden score tier (see LLD-ENEMIES-010 tier bracket table).

**Family:** Judge. **Tags:** `judge_witness`. **HP:** 10. **No vulnerability.**


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

---

### Requirement: [LLD-ENEMIES-014] Floor 3 Enemy — Fire Elemental
**Family:** Elemental. **Tags:** `elemental`, `elemental_fire`. Shared family omen card: see `LLD-OMEN-CARD-013` (Elemental Synergy — Fire). Resistance/vulnerability table: see `LLD-OMEN-CARD-013`.
**HP:** 14. **Resistance:** Fire ×0.5. **Vulnerability:** Ice ×1.5.

`[OPEN·MVP3]` `[OPEN·MVP2]` Door symbol to be designed in a UI/art direction session.

**Encounter:** 1 Fire Elemental pre-elite; 2 Fire Elementals post-elite.

**Omen contributions:** `elemental_synergy_fire` (Elemental Synergy — Fire) ×1, `LLD-OMEN-CARD-001` (Burning) ×1.

**Intents (see `HLD-COMBAT-009`, `HLD-COMBAT-016`, `HLD-COMBAT-018`):**

| Intent ID | Weight | Damage | Max consecutive | Effect |
|---|---|---|---|---|
| `fire_strike` | 50% | 4–6 fire | 2 | Deals fire damage |
| `kindle` | 50% | — | 2 | Applies Burning (magnitude 2) to player; if Burning already active, increments existing magnitude by 2 (see `HLD-COMBAT-018`) |



**Kill references** (assumes fire_strike every turn):
- Walking Staff (6 dmg): 3–4 turns (fire damage, no inherent vulnerability unless Combustible Oil used)
- Glacial Brand or ice weapon (×1.5 vs ice vulnerability): 2 turns

#### Scenario: Fire Elemental fire_strike
- **WHEN** the Fire Elemental's intent resolves to Fire Strike
- **THEN** the Fire Elemental deals 4–6 fire damage to the player

#### Scenario: Fire Elemental Kindle — no Burning active
- **WHEN** the Fire Elemental's intent resolves to Kindle and the player does not have an active Burning StatusInstance
- **THEN** a new Burning StatusInstance is applied to the player with magnitude 2 and remaining_ticks from the current omen timer; no damage is dealt this turn

#### Scenario: Fire Elemental Kindle — Burning already active
- **WHEN** the Fire Elemental's intent resolves to Kindle and the player already has an active Burning StatusInstance
- **THEN** the existing Burning StatusInstance's magnitude is incremented by 2 (per `HLD-COMBAT-018`); remaining_ticks is unchanged; no new StatusInstance is created; no damage is dealt this turn

#### Scenario: Kindle escalation over multiple turns
- **WHEN** the Fire Elemental uses Kindle on turn 1 (magnitude becomes 2) and again on turn 3 (magnitude becomes 4)
- **THEN** on the omen tick between those turns the player takes 2 fire damage; after the second Kindle the player takes 4 fire damage per tick

#### Scenario: Fire Elemental ice vulnerability
- **WHEN** the player attacks a Fire Elemental with an ice weapon
- **THEN** the ice weapon deals ×1.5 damage

#### Scenario: Elemental Synergy (Fire) converts ice weapon to fire
- **WHEN** Elemental Synergy (Fire) is active on the player side against a Fire Elemental
- **THEN** the player receives a Type Convert StatusInstance with string_param `"fire"`; the player's ice weapon deals fire damage instead; the Fire Elemental's fire resistance (×0.5) applies

---

### Requirement: [LLD-ENEMIES-015] Floor 3 Enemy — Ice Elemental
**Family:** Elemental. **Tags:** `elemental`, `elemental_ice`. Shared family omen card: see `LLD-OMEN-CARD-013` (Elemental Synergy — Ice).
**HP:** 14. **Resistance:** Ice ×0.5. **Vulnerability:** Fire ×1.5.

`[OPEN·MVP3]` `[OPEN·MVP2]` Door symbol to be designed in a UI/art direction session.

**Encounter:** 1 Ice Elemental pre-elite; 2 Ice Elementals post-elite.

**Omen contributions:** `elemental_synergy_ice` (Elemental Synergy — Ice) ×1, `LLD-OMEN-CARD-003` (Chilled) ×1.

**Intents (see `HLD-COMBAT-009`, `HLD-COMBAT-016`):**

| Intent ID | Weight | Damage | Max consecutive | Effect |
|---|---|---|---|---|
| `frost_bolt` | 60% | 3–5 ice | 2 | Deals ice damage |
| `glacial_mark` | 40% | — | 1 | Applies `"vulnerable:ice"` to player; no damage |



**Kill references** (assumes frost_bolt every turn):
- Walking Staff (6 physical): 3 turns (no vulnerability match)
- Fire Bomb at 2 ticks (10 fire × 1.5 = 15): 1 turn — one-shot regardless of intent

#### Scenario: Ice Elemental Frost Bolt — no Vulnerable active
- **WHEN** the Ice Elemental's intent resolves to Frost Bolt and the player does not have Vulnerable (Ice) active
- **THEN** the Ice Elemental deals 3–5 ice damage to the player

#### Scenario: Ice Elemental Frost Bolt — Vulnerable (Ice) active
- **WHEN** the Ice Elemental's intent resolves to Frost Bolt and the player has an active `"vulnerable:ice"` StatusInstance
- **THEN** the Ice Elemental deals 3–5 ice damage amplified by ×1.5 (per `HLD-COMBAT-007`); effective damage range 4–7 (rounded down)

#### Scenario: Ice Elemental Glacial Mark — not yet marked
- **WHEN** the Ice Elemental's intent resolves to Glacial Mark and the player does not have Vulnerable (Ice) active
- **THEN** a `"vulnerable:ice"` StatusInstance is applied to the player with remaining_ticks from the current omen timer; no damage is dealt this turn

#### Scenario: Ice Elemental Glacial Mark — already marked
- **WHEN** the Ice Elemental's intent resolves to Glacial Mark and the player already has an active `"vulnerable:ice"` StatusInstance
- **THEN** no change occurs (Vulnerable does not stack per `HLD-COMBAT-007`); no damage is dealt; the intent is effectively wasted

#### Scenario: Glacial Mark max_consecutive prevents back-to-back marks
- **WHEN** the Ice Elemental just resolved Glacial Mark and rolls its next intent
- **THEN** Glacial Mark is excluded from the pool due to max_consecutive: 1; Frost Bolt is forced this turn before Glacial Mark becomes available again

#### Scenario: Ice Elemental setup–payoff sequence
- **WHEN** the Ice Elemental uses Glacial Mark on turn 1 and Frost Bolt on turn 2
- **THEN** the Frost Bolt on turn 2 deals ×1.5 ice damage (4–7 effective); the player took no damage on turn 1 but is punished for not killing the elemental

#### Scenario: Elemental Synergy (Ice) converts player attacks
- **WHEN** Elemental Synergy (Ice) is active on the player side
- **THEN** the player receives a `type_convert` StatusInstance with `string_param: "ice"`; a fire weapon's fire advantage against the Ice Elemental disappears — damage deals ice type and hits the ×0.5 resistance instead

---

### Requirement: [LLD-ENEMIES-016] Floor 3 Enemy — Lightning Elemental
**Family:** Elemental. **Elite** (see LLD-ENEMIES-002 Elite Enemies table). **Tags:** `elemental`, `elemental_lightning` (both phases — Sparks inherit the same tags). Shared family omen card: see `LLD-OMEN-CARD-013` (Elemental Synergy — Lightning).
**HP (Phase 1):** 18. **Resistance:** Lightning ×0.5. **Vulnerability:** None.

`[OPEN·MVP3]` `[OPEN·MVP2]` Door symbol to be designed in a UI/art direction session.

**Encounter:** Elite gate only; 1 Lightning Elemental per run (see LLD-ENEMIES-002 Elite Enemies table).

**Two-phase:** Lightning Elemental reaches 0 HP → `resolve_enemy_death` processes `on_death_summons` and spawns two `lightning_spark` enemies (see `LLD-ARCH-018`, `LLD-ARCH-019`). The Sparks start at `turns_alive: 1`; their `spark_dormant` intent is forced by a `turn_number:1` conditional, so the enemy side takes no action on the split turn. Lightning Elemental's omen contributions are removed from the deck on death per `HLD-OMEN-006`.

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

---

### Requirement: [LLD-ENEMIES-017] Floor 3 Enemy — Low HP Fanatic
The Low HP Fanatic SHALL use the intent table below for all combat actions.
**Family:** Fanatic. **Tags:** `fanatic`. Fanatic omen card: see `LLD-OMEN-CARD-014` (Sacred Ground).
**HP:** 8. **No vulnerability.**

`[OPEN·MVP3]` `[OPEN·MVP2]` Door symbol and final name to be confirmed. "Low HP Fanatic" is the design reference name.

**Omen contributions (see `HLD-OMEN-006`):**
- **Family card:** `LLD-OMEN-CARD-014` (Sacred Ground) ×1 per Low HP Fanatic
- **Type card:** `LLD-OMEN-CARD-010` (Mending) ×1 (total, regardless of Low HP Fanatic count)

**Intents (see `HLD-COMBAT-009`, `HLD-COMBAT-016`):**

| Intent ID | Weight | Damage | Max consecutive | Effect |
|---|---|---|---|---|
| `strike` | 60% | 3–5 physical | 2 | Deals damage |
| `taunt` | 20% | — | 2 | Applies Frenzied to the player (status_apply: `"frenzied"`, status_target: `"player"`, status_magnitude: 2) |
| `evade` | 20% | — | 2 | Evade (is_evade: true) |



**Kill references** (assumes strike every turn):
- Walking Staff (6 dmg): 2 hits
- With Hardened (3) from Absorption Totem (6 − 3 = 3 effective): 3 hits

#### Scenario: Low HP Fanatic strike
- **WHEN** the Low HP Fanatic's intent resolves to Strike
- **THEN** the Fanatic deals 3–5 physical damage to the player

#### Scenario: Low HP Fanatic taunt — Frenzied applied
- **WHEN** the Low HP Fanatic's intent resolves to Taunt and the player does not have Frenzied active
- **THEN** a Frenzied StatusInstance with magnitude 2 is applied to the player (Vulnerable Physical + Emboldened Physical effects); no damage is dealt

#### Scenario: Low HP Fanatic taunt — Frenzied already active, max-wins
- **WHEN** the Low HP Fanatic's intent resolves to Taunt and the player already has Frenzied active with magnitude ≥ 2
- **THEN** no change occurs (max-wins, see `HLD-COMBAT-019`); if existing magnitude were < 2, it would update to 2

#### Scenario: Frenzied makes player hits stronger and incoming hits hurt more
- **WHEN** the player has Frenzied active and attacks with a physical weapon while a Fanatic attacks them
- **THEN** the player's physical weapon gains the Emboldened (Physical) flat bonus (magnitude 2); the Fanatic's physical attack is amplified by ×1.5 due to the Vulnerable (Physical) effect

#### Scenario: Frenzied and standalone Emboldened (Physical) coexist
- **WHEN** the player has both a Frenzied StatusInstance and a standalone Emboldened (Physical) StatusInstance active simultaneously
- **THEN** both apply their flat bonuses independently; the combined effect is intentional

#### Scenario: Low HP Fanatic evade
- **WHEN** the Low HP Fanatic's intent resolves to Evade
- **THEN** the Fanatic sets is_evading = true; any player attack targeting that Fanatic this turn has a 35% miss chance

---

### Requirement: [LLD-ENEMIES-018] Floor 3 Enemy — High HP Fanatic
The High HP Fanatic SHALL use the intent table below for all combat actions.
**Family:** Fanatic. **Tags:** `fanatic`. Fanatic omen card: see `LLD-OMEN-CARD-014` (Sacred Ground).
**HP:** 12. **No vulnerability.**

`[OPEN·MVP3]` `[OPEN·MVP2]` Door symbol and final name to be confirmed. "High HP Fanatic" is the design reference name.

**Omen contributions (see `HLD-OMEN-006`):**
- **Family card:** `LLD-OMEN-CARD-014` (Sacred Ground) ×1 per High HP Fanatic
- **Type card:** `LLD-OMEN-CARD-010` (Mending) ×1 (total, regardless of High HP Fanatic count)

**Intents (see `HLD-COMBAT-009`, `HLD-COMBAT-016`):**

| Intent ID | Weight | Damage | Max consecutive | Effect |
|---|---|---|---|---|
| `strike` | 60% | 2–4 physical | 2 | Deals damage |
| `taunt` | 20% | — | 2 | Applies Frenzied to the player (status_apply: `"frenzied"`, status_target: `"player"`, status_magnitude: 2) |
| `evade` | 20% | — | 2 | Evade (is_evade: true) |



**Kill references** (assumes strike every turn):
- Walking Staff (6 dmg): 2 hits
- With Hardened (3) from Absorption Totem (6 − 3 = 3 effective): 4 hits

#### Scenario: High HP Fanatic strike
- **WHEN** the High HP Fanatic's intent resolves to Strike
- **THEN** the Fanatic deals 2–4 physical damage to the player

#### Scenario: High HP Fanatic taunt — Frenzied applied
- **WHEN** the High HP Fanatic's intent resolves to Taunt and the player does not have Frenzied active
- **THEN** a Frenzied StatusInstance with magnitude 2 is applied to the player; no damage is dealt

#### Scenario: High HP Fanatic taunt — Frenzied already active, max-wins
- **WHEN** the High HP Fanatic's intent resolves to Taunt and the player already has Frenzied active with magnitude ≥ 2
- **THEN** no change occurs (max-wins, see `HLD-COMBAT-019`)

#### Scenario: High HP Fanatic evade
- **WHEN** the High HP Fanatic's intent resolves to Evade
- **THEN** the Fanatic sets is_evading = true; any player attack targeting that Fanatic this turn has a 35% miss chance

#### Scenario: High HP Fanatic with Absorption Totem
- **WHEN** an Absorption Totem has applied Hardened (3) to the High HP Fanatic and the player attacks with Walking Staff (6 dmg)
- **THEN** the Fanatic absorbs 3 damage from Hardened; effective damage per hit is 3; 4 hits to kill instead of 2

---

### Requirement: [LLD-ENEMIES-019] Floor 3 Support Entity — Buff Totem
The Buff Totem SHALL apply `embolden_allies` to all living Fanatics on the enemy side each turn.
**Family:** Fanatic. **Tags:** `fanatic`. Totems do not contribute Sacred Ground (see `LLD-OMEN-CARD-014`).
**HP:** 6. **No vulnerability.**

`[OPEN·MVP3]` `[OPEN·MVP2]` Door symbol and final name to be confirmed. "Buff Totem" is the design reference name.

**Omen contribution:** None.

**Intent (see `HLD-COMBAT-009`, `HLD-COMBAT-019`):**

| Intent ID | Weight | Damage | Max consecutive | Effect |
|---|---|---|---|---|
| `embolden_allies` | 100% | — | — | Applies Emboldened (Physical, magnitude 2) to all living Fanatics on this side (status_apply: `"emboldened:physical"`, status_target: `"allies"`, status_magnitude: 2); Totem itself excluded |



When the Buff Totem is killed it no longer re-applies `embolden_allies` each turn. Emboldened (Physical) already active on Fanatics persists until the current omen cycle ends. Priority: kill the Totem before the next omen cycle to remove the buff.

#### Scenario: Buff Totem embolden_allies — Fanatic gains Emboldened
- **WHEN** the Buff Totem's intent resolves to Embolden Allies
- **THEN** all living Fanatics on the enemy side (excluding the Totem) receive Emboldened (Physical, magnitude 2); the Buff Totem itself does not receive the status

#### Scenario: Buff Totem re-apply — max-wins, no change at equal magnitude
- **WHEN** the Buff Totem applies Emboldened (Physical, magnitude 2) to a Fanatic that already has Emboldened (Physical) with magnitude 2
- **THEN** no change occurs (max-wins, see `HLD-COMBAT-019`); the existing StatusInstance is unchanged

#### Scenario: Emboldened (Physical) increases Fanatic strike damage
- **WHEN** a Fanatic with Emboldened (Physical, magnitude 2) active resolves Strike
- **THEN** the flat bonus (+2) is added to the strike's physical damage (Low HP Fanatic 3–5 becomes 5–7; High HP Fanatic 2–4 becomes 4–6)

#### Scenario: Buff Totem death — buff lingers until omen cycle ends
- **WHEN** the Buff Totem is killed mid-cycle while Fanatics have Emboldened (Physical) active
- **THEN** the Emboldened (Physical) on surviving Fanatics remains until the omen cycle ends; the Totem no longer re-applies it on subsequent turns

---

### Requirement: [LLD-ENEMIES-020] Floor 3 Support Entity — Absorption Totem
The Absorption Totem SHALL apply `harden_allies` to all living Fanatics on the enemy side each turn.
**Family:** Fanatic. **Tags:** `fanatic`. Totems do not contribute Sacred Ground (see `LLD-OMEN-CARD-014`).
**HP:** 10. **No vulnerability.**

`[OPEN·MVP3]` `[OPEN·MVP2]` Door symbol and final name to be confirmed. "Absorption Totem" is the design reference name.

**Omen contribution:** None.

**Intent (see `HLD-COMBAT-009`, `HLD-COMBAT-019`):**

| Intent ID | Weight | Damage | Max consecutive | Effect |
|---|---|---|---|---|
| `harden_allies` | 100% | — | — | Applies Hardened (magnitude 3) to all living Fanatics on this side (status_apply: `"hardened"`, status_target: `"allies"`, status_magnitude: 3); Totem itself excluded |

When the Absorption Totem is killed it no longer re-applies `harden_allies` each turn. Hardened already active on Fanatics persists until the current omen cycle ends. Priority: kill the Totem before the next omen cycle to remove the buff.



#### Scenario: Absorption Totem harden_allies — Fanatic gains Hardened
- **WHEN** the Absorption Totem's intent resolves to Harden Allies
- **THEN** all living Fanatics on the enemy side (excluding the Totem) receive Hardened (magnitude 3); the Absorption Totem itself does not receive the status

#### Scenario: Hardened absorbs Throw Rock completely
- **WHEN** an Absorption Totem has applied Hardened (3) to a Fanatic and the player attacks with Throw Rock (3 damage)
- **THEN** the Fanatic absorbs all 3 damage; effective damage is 0 (Hardened absorption resolves before the min-1 clamp)

#### Scenario: Hardened partially absorbs Walking Staff
- **WHEN** a Fanatic has Hardened (3) active and the player attacks with Walking Staff (6 damage)
- **THEN** the Fanatic absorbs 3 damage; effective damage is 3

#### Scenario: Absorption Totem death — buff lingers until omen cycle ends
- **WHEN** the Absorption Totem is killed mid-cycle while Fanatics have Hardened active
- **THEN** the Hardened on surviving Fanatics remains until the omen cycle ends; the Totem no longer re-applies it on subsequent turns

#### Scenario: Totem takes full damage from player
- **WHEN** the player attacks the Absorption Totem directly
- **THEN** the Totem takes full damage — it is excluded from its own harden_allies intent (status_target: "allies" excludes the caster)

