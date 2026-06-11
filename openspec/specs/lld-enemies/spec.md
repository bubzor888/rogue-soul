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

| Family | Floor 3 members |
|---|---|
| Undead | Skeleton, Zombie |
| Beast | Plague Rat, Wolf, Bear |
| Elemental | Fire Elemental, Ice Elemental, Lightning Elemental |
| Fanatic | Low HP Fanatic, High HP Fanatic, Buff Totem, Absorption Totem |

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

`[OPEN·MVP1]` Slam release damage range (5–7) to be validated in playtesting.

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

`[OPEN·MVP1]` Swipe per-hit damage range (3–5) to be validated in playtesting.

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

| Phase | Rooms | Default encounter | Beast exception |
|---|---|---|---|
| Opening | 1–3 | 1 enemy | 2 Wolves or 3 Plague Rats |
| Companion | 4 | Worn Map trigger — no combat | — |
| Elite gate | 5 | Single elite enemy | — |
| Post-elite | 6–9 | 2 enemies | 3 Wolves |
| Boss | — | The Judge | — |

A standard Floor 3 Pilgrim run yields 5 loot choices (4 standard + 1 elite) before the Judge.

#### Scenario: Post-elite encounter escalation
- **WHEN** the player completes the elite encounter on Floor 3
- **THEN** all subsequent standard rooms contain 2 enemies (or the beast exception count)

---

### Requirement: [LLD-ENEMIES-010] Floor 3 Boss — The Judge
`[OPEN·MVP1]` The Judge stats, mechanics, omen contributions, and narrative framing to be defined in a dedicated boss design session. The Judge is the guardian whose judgment the soul must pass — failing means rebirth (run ends), passing means the soul advances toward Solace.

#### Scenario: Boss placement
- **WHEN** the player completes all rooms on Floor 3
- **THEN** The Judge is the final encounter

#### Scenario: [OPEN·MVP1] Judge mechanics
- **WHEN** The Judge is designed
- **THEN** its mechanics MUST reference the soul's goal (Solace) narratively and present a genuine mechanical challenge tuned for one floor of preparation

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

`[OPEN·MVP1]` Kindle magnitude value (2) and fire_strike damage range (4–6) to be validated in playtesting.

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

`[OPEN·MVP1]` Frost Bolt damage range (3–5) and Glacial Mark weight (40%) to be validated in playtesting.

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
**Family:** Elemental. **Tags:** `elemental`, `elemental_lightning` (both phases — Sparks inherit the same tags). Shared family omen card: see `LLD-OMEN-CARD-013` (Elemental Synergy — Lightning).
**HP (Phase 1):** 18. **HP (Phase 2):** Two Sparks at 6 HP each.
**Attack (Phase 1):** 6 lightning per turn. **Attack (Phase 2):** 2 × 2 lightning each (4 total).
**Resistance:** Lightning ×0.5 (both phases). **Vulnerability:** None.

`[OPEN·MVP3]` `[OPEN·MVP2]` Door symbol to be designed in a UI/art direction session.

**Encounter:** 1 Lightning Elemental post-elite only.

**Two-phase:** Reaches 0 HP → splits into two Sparks (dead turn for enemy side). Sparks contribute no new omen cards.

**Omen contributions (Phase 1 only):** `elemental_synergy_lightning` (Elemental Synergy — Lightning) ×1, `LLD-OMEN-CARD-002` (Shocked) ×1.

#### Scenario: Two-phase transition
- **WHEN** the Lightning Elemental reaches 0 HP
- **THEN** combat does not end; two Sparks appear; the enemy side takes no action on the transition turn

#### Scenario: Sparks inherit no new omen cards
- **WHEN** the Lightning Elemental splits into Sparks
- **THEN** no new omen cards are added; the Phase 1 deck persists through Phase 2

#### Scenario: Resource management across phases
- **WHEN** the player transitions to Phase 2
- **THEN** all charges, consumables, and HP carry over unchanged

---

### Requirement: [LLD-ENEMIES-017] Floor 3 Enemy — Low HP Fanatic
**Family:** Fanatic. **Tags:** `fanatic`. Fanatic omen card: see `LLD-OMEN-CARD-014` (Sacred Ground).
**HP:** 8. **Attack:** 4 physical per turn. **No vulnerability. No special mechanic.**

`[OPEN·MVP3]` `[OPEN·MVP2]` Door symbol and final name to be confirmed. "Low HP Fanatic" is the design reference name.

**Omen contributions (see `HLD-OMEN-006`):**
- **Family card:** `LLD-OMEN-CARD-014` (Sacred Ground) ×1 per Low HP Fanatic
- **Type card:** `LLD-OMEN-CARD-010` (Mending) ×1 (total, regardless of Low HP Fanatic count)

#### Scenario: Low HP Fanatic kill speed
- **WHEN** the player uses a Walking Staff (6 damage) against a Low HP Fanatic
- **THEN** the Fanatic dies in 2 hits; it attacks once before dying (4 damage taken)

---

### Requirement: [LLD-ENEMIES-018] Floor 3 Enemy — High HP Fanatic
**Family:** Fanatic. **Tags:** `fanatic`. Fanatic omen card: see `LLD-OMEN-CARD-014` (Sacred Ground).
**HP:** 12. **Attack:** 3 physical per turn. **No vulnerability. No special mechanic.**

`[OPEN·MVP3]` `[OPEN·MVP2]` Door symbol and final name to be confirmed. "High HP Fanatic" is the design reference name.

**Omen contributions (see `HLD-OMEN-006`):**
- **Family card:** `LLD-OMEN-CARD-014` (Sacred Ground) ×1 per High HP Fanatic
- **Type card:** `LLD-OMEN-CARD-010` (Mending) ×1 (total, regardless of High HP Fanatic count)

#### Scenario: High HP Fanatic with Absorption Totem
- **WHEN** an Absorption Totem is active and the player attacks a High HP Fanatic with Walking Staff
- **THEN** the Fanatic takes 3 effective damage per hit (6 - 3 absorption); 4 hits to kill instead of 2

---

### Requirement: [LLD-ENEMIES-019] Floor 3 Support Entity — Buff Totem
**Family:** Fanatic. **Tags:** `fanatic`. Totems do not contribute Sacred Ground (see `LLD-OMEN-CARD-014`).
**HP:** 6. **Attack:** None. **No vulnerability.**
**Aura (always-on):** All Fanatics on this side deal +2 damage per turn while alive. The Totem does not benefit from its own aura.

`[OPEN·MVP3]` `[OPEN·MVP2]` Door symbol and final name to be confirmed. "Buff Totem" is the design reference name.

**Omen contribution:** None.

#### Scenario: Buff Totem aura applies to all Fanatics
- **WHEN** a Buff Totem is alive on the enemy side
- **THEN** all Fanatics on that side deal +2 damage per turn

#### Scenario: Buff Totem kill removes aura
- **WHEN** the Buff Totem is killed
- **THEN** the +2 damage aura immediately ends; all surviving Fanatics revert to base damage

---

### Requirement: [LLD-ENEMIES-020] Floor 3 Support Entity — Absorption Totem
**Family:** Fanatic. **Tags:** `fanatic`. Totems do not contribute Sacred Ground (see `LLD-OMEN-CARD-014`).
**HP:** 10. **Attack:** None. **No vulnerability.**
**Aura (always-on):** All Fanatics on this side absorb 3 damage per hit while alive. The Totem does not benefit from its own aura.

`[OPEN·MVP3]` `[OPEN·MVP2]` Door symbol and final name to be confirmed. "Absorption Totem" is the design reference name.

**Omen contribution:** None.

#### Scenario: Absorption aura renders Throw Rock useless
- **WHEN** an Absorption Totem is alive and the player attacks a Fanatic with Throw Rock (3 damage)
- **THEN** the Fanatic takes 0 effective damage (3 - 3 = 0)

#### Scenario: Totem takes full damage
- **WHEN** the player attacks the Absorption Totem directly
- **THEN** the Totem takes full damage — the absorption aura does not protect the Totem itself

