## MODIFIED Requirements

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
