## MODIFIED Requirements

### Requirement: [LLD-OMEN-CARD-001] Burning (Whole-Side Overall Omen)
The Burning omen card SHALL apply the Burning status to all units on the target side. Each unit takes flat fire damage per tick and is Vulnerable (Fire) ×1.5 for the cycle duration (see `HLD-COMBAT-006` for per-tick values).

Mirrors the Fire Bomb consumable (single-target individual omen). Whole-side values may differ from single-target values and are tuned independently.

**On enemy side:** all enemies take fire DoT and are Vulnerable (Fire). Pairs strongly with Smoldering Brand or Ember Shard (`LLD-ITEMS-006`, `LLD-ITEMS-005`).
**On player side (forced):** player takes fire DoT and is Vulnerable (Fire). Cleared per-unit by Ointment.

`[OPEN·MVP1]` Whole-side Burning tick damage value (first pass: 5/tick, matching single-target). Source pool (floor, enemy, or vessel) to be confirmed.

#### Scenario: Whole-side Burning on enemies
- **WHEN** the Burning omen card is played to the enemy side and there are two enemies
- **THEN** both enemies gain the Burning status and are Vulnerable (Fire) ×1.5 for the cycle

---

### Requirement: [LLD-OMEN-CARD-002] Shocked (Whole-Side Overall Omen)
The Shocked omen card SHALL apply the Shocked status to all units on the target side. All units on that side are Vulnerable (Lightning) ×1.5. At the omen shift, all units on that side skip their next action.

Mirrors Fulminating Powder (single-target). Low timer cards are valuable when Shocked is active — faster stun payoff across the whole side.

**On enemy side:** all enemies stunned at the shift and vulnerable to lightning. Extremely powerful with Arc Wand equipped — both primary and arc target benefit from the vulnerability.
**On player side (forced):** player is Vulnerable (Lightning) and will be stunned. Cleared by Amethyst.

`[OPEN·MVP1]` Source pool (floor, enemy, or vessel) to be confirmed.

#### Scenario: Whole-side Shocked stun
- **WHEN** the Shocked omen card is played to the enemy side with two enemies present
- **THEN** both enemies are Vulnerable (Lightning) ×1.5 and both skip their next action at the omen shift

---

### Requirement: [LLD-OMEN-CARD-003] Chilled (Whole-Side Overall Omen)
The Chilled omen card SHALL apply the Chilled status to all units on the target side. Each unit deals reduced damage per tick (creeping, never to zero) and is Vulnerable (Ice) ×1.5 for the cycle duration.

Mirrors Frost Shard (single-target). Particularly effective against multi-enemy encounters — damage reduction applies across all attackers simultaneously.

**On enemy side:** all enemies deal less damage each tick and are vulnerable to ice. Pairs with Glacial Brand.
**On player side (forced):** player deals reduced damage and is Vulnerable (Ice). Cleared by Amethyst.

`[OPEN·MVP1]` Whole-side Chilled reduction values (first pass: 10%/20%/30% per tick, matching single-target). Source pool to be confirmed.

#### Scenario: Whole-side Chilled vs multi-enemy
- **WHEN** the Chilled omen card is played to the enemy side with two enemies
- **THEN** both enemies deal 10% less damage on tick 1 and 20% less on tick 2 (typical 2-tick cycle)

---

### Requirement: [LLD-OMEN-CARD-004] Emboldened (Physical) (Whole-Side Overall Omen)
The Emboldened (Physical) omen card SHALL add a flat bonus to all physical damage dealt by units on the target side for the cycle duration. Expressed as a flat bonus (not percentage) because physical damage is the most common type and a percentage would be too broadly powerful.

**On enemy side:** player's physical weapons deal more damage per hit. Always relevant since physical is the default damage type.
**On player side (forced):** enemies deal more physical damage per hit.

`[OPEN·MVP1]` Flat bonus value (e.g. +2 per hit) to be set once all weapon damage values are established.

#### Scenario: Physical damage bonus
- **WHEN** Emboldened (Physical) is active on the player side
- **THEN** every physical damage hit by the player deals the confirmed flat bonus additional damage

## ADDED Requirements

### Requirement: [LLD-OMEN-CARD-011] Grave Knit (Enemy Card — Undead)
The Grave Knit omen card SHALL heal all undead units on the target side for X HP per tick (per-turn omen, clears at omen reset). Does nothing when applied to the player — the player is not undead.

**On enemy side:** undead enemies heal each tick — must be managed or absorbed.
**On player side:** no effect — safe to absorb.

`[OPEN·MVP1]` Grave Knit heal value per tick (first pass: 5 HP). Source pool confirmation (enemy only, not floor).

#### Scenario: Grave Knit heals undead on enemy side
- **WHEN** Grave Knit is played to the enemy side and undead enemies are present
- **THEN** each undead enemy on that side heals X HP per tick for the cycle duration

#### Scenario: Grave Knit player side — safe
- **WHEN** the player steers Grave Knit to their own side
- **THEN** no healing occurs; the enemy side does not receive healing that cycle

---

### Requirement: [LLD-OMEN-CARD-012] Thick Hide (Enemy Card — Beast)
The Thick Hide omen card SHALL reduce incoming damage to all beasts on the target side by 3 per hit (per-turn omen, clears at omen reset). Does nothing when applied to the player — the player has no Thick Hide property.

**On beast side:** each incoming hit to any beast is reduced by 3 — breaks weapon kill thresholds and dramatically extends fights.
**On player side:** no effect — safe to absorb.

#### Scenario: Thick Hide absorption on beast side
- **WHEN** Thick Hide is active on the beast side
- **THEN** each incoming hit to any beast is reduced by 3 damage before applying HP reduction

#### Scenario: Thick Hide player side — safe
- **WHEN** the player steers Thick Hide to their own side
- **THEN** no effect occurs; the beasts do not receive the buff

---

### Requirement: [LLD-OMEN-CARD-013] Elemental Synergy (Enemy Card — Elemental)
The Elemental Synergy omen card SHALL convert all attacks from the target side to the contributing elemental's damage type for the omen cycle.

**On elemental side:** elementals already deal their type — no change. Safe for the player to play here.
**On player side:** all player attacks convert to the elemental's type. The elemental resists that type (×0.5). Any opposing-element advantage (e.g. ice weapon vs. Fire Elemental) flips to a resistance penalty.

Elemental resistances and vulnerabilities:

| Elemental | Resistance | Vulnerability |
|---|---|---|
| Fire Elemental | Fire ×0.5 | Ice ×1.5 |
| Ice Elemental | Ice ×0.5 | Fire ×1.5 |
| Lightning Elemental | Lightning ×0.5 | None |

#### Scenario: Elemental Synergy converts player attacks
- **WHEN** Elemental Synergy is active on the player side
- **THEN** all player attacks deal the elemental's damage type; if the player was using the opposing-element weapon for a ×1.5 advantage, that weapon now deals the resisted type at ×0.5

---

### Requirement: [LLD-OMEN-CARD-014] Sacred Ground (Enemy Card — Fanatic)
The Sacred Ground omen card SHALL double the effect of all active Totem auras on the target side for the omen cycle. Does nothing when applied to the player — the player has no Totem auras.

**On Fanatic/Totem side:** Totem aura effects are doubled (e.g. Absorption Totem 3 → 6 absorption per hit; Buff Totem +2 → +4 per hit).
**On player side:** no effect — safe to absorb.

When the Totem is killed, Sacred Ground becomes completely inert — it has no aura to double and does nothing on either side.

#### Scenario: Sacred Ground doubles Absorption Totem
- **WHEN** Sacred Ground is active on the Fanatic side and an Absorption Totem is alive
- **THEN** Fanatics absorb 6 damage per hit instead of 3

#### Scenario: Sacred Ground inert after Totem death
- **WHEN** Sacred Ground is drawn after the Totem has been killed
- **THEN** the card has no effect on either side
