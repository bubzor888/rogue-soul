## Purpose
Defines all omen cards in the game — vessel cards, item cards, floor pool cards, and enemy cards — along with deck size calibration and card number design open questions.
## Requirements
### Requirement: [LLD-OMEN-CARD-001] Burning (Whole-Side Overall Omen)
The Burning omen card SHALL apply the Burning status to all units on the target side. Each unit takes flat fire damage per tick for the cycle duration (see `HLD-COMBAT-006` for per-tick value framework).

Mirrors the Fire Bomb consumable (single-target individual omen). Whole-side values may differ from single-target values and are tuned independently.

**On enemy side:** all enemies take fire DoT. Pairs with Smoldering Brand or Ember Shard (`LLD-ITEMS-006`, `LLD-ITEMS-005`). Combine with Combustible Oil for Vulnerable (Fire) if the fire combo payoff is wanted.
**On player side (forced):** player takes fire DoT. Cleared per-unit by Ointment.

Whole-side Burning tick damage: **5 fire damage per tick**.

#### Scenario: Whole-side Burning on enemies
- **WHEN** the Burning omen card is played to the enemy side and there are two enemies
- **THEN** both enemies gain the Burning status for the cycle; no Vulnerable is co-applied

### Requirement: [LLD-OMEN-CARD-002] Shocked (Whole-Side Overall Omen)
The Shocked omen card SHALL apply the Shocked status to all units on the target side. At the omen shift, all units on that side skip their next action.

Mirrors Fulminating Powder (single-target). Low timer cards are valuable when Shocked is active — faster stun payoff across the whole side.

**On enemy side:** all enemies stunned at the shift. Combine with Fulminating Powder for Vulnerable (Lightning) if desired.
**On player side (forced):** player will be stunned at the shift. Cleared by Amethyst.

#### Scenario: Whole-side Shocked stun
- **WHEN** the Shocked omen card is played to the enemy side with two enemies present
- **THEN** both enemies skip their next action at the omen shift; no Vulnerable is co-applied

---

### Requirement: [LLD-OMEN-CARD-003] Chilled (Whole-Side Overall Omen)
The Chilled omen card SHALL apply the Chilled status to all units on the target side. Each unit deals reduced flat damage per tick — the reduction increases each tick but can never reduce damage to zero. Particularly effective against multi-enemy encounters — damage reduction applies across all attackers simultaneously.

**On enemy side:** all enemies deal less damage each tick. Pairs with Glacial Brand.
**On player side (forced):** player deals reduced damage. Cleared by Amethyst.

Whole-side Chilled flat damage reduction: **2 per hit on tick 1, 4 per hit on tick 2**.

#### Scenario: Whole-side Chilled vs multi-enemy
- **WHEN** the Chilled omen card is played to the enemy side with two enemies
- **THEN** both enemies deal reduced flat damage each tick; reduction increases per tick; no Vulnerable is co-applied

---

### Requirement: [LLD-OMEN-CARD-004] Emboldened (Physical) (Whole-Side Overall Omen)
The Emboldened (Physical) omen card SHALL add a flat bonus to all physical damage dealt by units on the target side for the cycle duration. Expressed as a flat bonus (not percentage) because physical damage is the most common type and a percentage would be too broadly powerful.

**On enemy side:** player's physical weapons deal more damage per hit. Always relevant since physical is the default damage type.
**On player side (forced):** enemies deal more physical damage per hit.

Source: confirmed as a Skeleton omen contribution (`LLD-ENEMIES-004`).

Flat physical damage bonus: **+2 per hit**.

#### Scenario: Physical damage bonus
- **WHEN** Emboldened (Physical) is active on the player side
- **THEN** every physical damage hit by the player deals the confirmed flat bonus additional damage

---

### Requirement: [LLD-OMEN-CARD-005] Emboldened (Elemental) (Whole-Side Overall Omen)
The Emboldened (Elemental) omen card SHALL add a percentage increase to all damage of a specific elemental type dealt by units on the target side. Expressed as a percentage (not flat) because elemental damage is more situational.

Separate cards exist for each confirmed element: Fire, Lightning, Ice.

**On enemy side:** player's attacks of that element hit harder. High value when the matching elemental weapon is equipped.
**On player side (forced):** enemies deal increased damage of that type. Particularly dangerous if the player is already Vulnerable to that element.

Elemental damage bonus multiplier: **×1.5** (same as Vulnerability — stacks multiplicatively with Vulnerable when the element matches, per `HLD-COMBAT-007`).

#### Scenario: Elemental bonus stacks with vulnerability
- **WHEN** Emboldened (Fire) is active on the player side and an enemy has Vulnerable (Fire) applied via Combustible Oil
- **THEN** the elemental bonus and the vulnerability multiplier both apply — the combined effect is intentional and represents the fire combo payoff

---

### Requirement: [LLD-OMEN-CARD-006] Stillness (Vessel Card — Pilgrim)
The Stillness omen card SHALL do nothing when played on either side. Its number still functions as a timer card if it is the leftover draw. The Pilgrim contributes 2 copies of Stillness to the omen deck — present in every combat on a Pilgrim run.

**Design rationale:** Stillness dilutes the deck — any specific effect is slightly less likely in a Pilgrim run. Drawing Stillness is safe: the player can apply it to themselves with no consequence, or use it as their chosen card to guarantee the random card lands on the enemy side without fear of what follows. Thematically: the Pilgrim arrives at the Threshold having shed everything; his contribution to the omen field is absence.

The Pilgrim contributes exactly **2 copies** of Stillness to the omen deck every combat.

#### Scenario: Stillness on player side
- **WHEN** the player plays Stillness to their own side
- **THEN** nothing happens — no status, no damage, no effect

#### Scenario: Stillness as timer card
- **WHEN** Stillness is the leftover card
- **THEN** its number sets the cycle duration normally; the null effect applies only when played on a side

#### Scenario: Stillness as safe choice
- **WHEN** two unfavourable cards and one Stillness are drawn
- **THEN** the player can choose Stillness for their side to guarantee the random card hits the enemy side without also applying an adverse effect to themselves

---

### Requirement: [LLD-OMEN-CARD-007] Fortified (Item Card — Hedge Knight Iron Pendant)
The Fortified omen card SHALL reduce incoming damage for all units on the target side for the cycle duration. Added to the omen deck by the Hedge Knight's Iron Pendant starting item — present in every combat on a Hedge Knight run.

**On player side:** player takes less damage. The intended application — Iron Pendant is designed to push Fortified toward the player side.
**On enemy side (forced):** enemies take less damage — reduces the Knight's offensive output for the cycle.

`[OPEN·MVP3]` Fortified damage reduction value to be set during Hedge Knight vessel design. Full Iron Pendant interaction documented in `docs/vessels/vessel_hedge_knight.md`.

#### Scenario: Fortified on player side
- **WHEN** Fortified is active on the player side
- **THEN** the player takes the confirmed reduced amount of incoming damage from all sources

---

### Requirement: [LLD-OMEN-CARD-008] Floor 3 Default Omen Deck
The Floor 3 ambient omen cards — present in every combat on that floor regardless of which enemies appear — SHALL consist of the following 12 cards, shuffled into the omen deck at combat start alongside vessel cards, item cards, and enemy cards (see `HLD-OMEN-004`):

| Card | Count |
|---|---|
| Burning | 1 |
| Shocked | 1 |
| Chilled | 1 |
| Vulnerable (Fire) | 1 |
| Vulnerable (Lightning) | 1 |
| Vulnerable (Ice) | 1 |
| Emboldened (Fire) | 1 |
| Emboldened (Lightning) | 1 |
| Emboldened (Ice) | 1 |
| Mending | 1 |
| Emboldened (Physical) | 1 |
| Exposed | 1 |

**Total: 12 floor ambient cards.**

Enemy omen card contributions are **not** listed here. Each enemy's omen contributions are defined in `lld-enemies` on that enemy's requirement (e.g. `LLD-ENEMIES-004` for Skeleton, `LLD-ENEMIES-006` for Plague Rat). Enemy cards enter the deck when those enemies are present and are removed when they die.

#### Scenario: Floor deck present in every combat
- **WHEN** any combat begins on Floor 3
- **THEN** all 12 ambient cards are shuffled into the omen deck regardless of which enemies are present

#### Scenario: Enemy cards are separate
- **WHEN** the omen deck is assembled for a Skeleton encounter
- **THEN** the Skeleton's Emboldened (Physical) and Grave Knit cards (see `LLD-ENEMIES-004`) are included from the enemy source — not from this floor pool

#### Scenario: Full deck size is emergent
- **WHEN** a Pilgrim fights two Skeletons on Floor 3
- **THEN** the deck contains: 12 floor cards + vessel cards (Stillness ×2) + enemy cards (per LLD-ENEMIES-004 per Skeleton) — the total is a sum of all contributing sources

---

### Requirement: [LLD-OMEN-CARD-009] Hedge Knight Vessel Card
`[OPEN·MVP3]` The Hedge Knight contributes one omen card to the fate deck as a vessel card — present in every combat on a Hedge Knight run. This is distinct from LLD-OMEN-CARD-007 (Fortified), which is an item card injected by the Iron Pendant on activation.

**Design constraints:**
- Should reflect the Hedge Knight's identity: discipline, endurance, the edge of collapse
- Should complement Last Stand and Charge mechanics without making the kit trivially powerful
- One copy in the deck

`[OPEN·MVP3]` Card effect, number distribution, and interaction with the Last Stand passive to be defined in a Hedge Knight vessel design session.

#### Scenario: [OPEN·MVP3] Hedge Knight vessel card effect
- **WHEN** the Hedge Knight vessel card is drawn during a combat
- **THEN** its effect (to be designed) triggers; distinct from and independent of the Iron Pendant's Fortified card

---

### Requirement: [LLD-OMEN-CARD-010] Drifter Vessel Card — The Ferret
`[OPEN·MVP3]` The Ferret contributes one omen card to the fate deck — present in every combat on a Drifter run (see `LLD-VESSELS-002`). When this card appears in a cycle it triggers a beneficial effect for the Drifter. The card is inert if it lands on the enemy side.

**Known constraints:**
- One copy in the deck
- Beneficial on player side only; inert on enemy side

`[OPEN·MVP3]` Ferret card effect to be defined once the full omen card list is designed and the Drifter's kit is balanced.

#### Scenario: Ferret card on player side
- **WHEN** the Ferret omen card is played to the player side
- **THEN** the beneficial effect (to be designed) triggers for the Drifter

#### Scenario: Ferret card on enemy side (inert)
- **WHEN** the Ferret omen card is randomly placed on the enemy side
- **THEN** nothing happens — the card has no effect on the enemy side

---

### Requirement: [LLD-OMEN-CARD-011] Grave Knit (Enemy Card — Undead)
The Grave Knit omen card SHALL heal all undead units on the target side for X HP per tick (per-turn omen, clears at omen reset). Does nothing when applied to the player — the player is not undead.

**On enemy side:** undead enemies heal each tick — must be managed or absorbed.
**On player side:** no effect — safe to absorb.

Which enemies contribute Grave Knit is defined in `lld-enemies` (see `LLD-ENEMIES-004`, `LLD-ENEMIES-005`).

Grave Knit heal value: **5 HP per tick**.

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

---

### Requirement: [LLD-OMEN-MECH-008] Card Number Distribution
Timer values are assigned to all cards in the assembled deck at the start of each combat using the COMBAT RNG stream, with the following distribution applied across the whole deck:

| Timer value | Probability |
|---|---|
| 1 | 25% |
| 2 | 50% |
| 3 | 25% |

With rounding for odd deck sizes, the target is always the nearest whole-number split. CombatResolver assigns values when the deck is first built (before any cards are drawn), stores them in the deck structure (see `LLD-ARCH-017`), and does not re-roll on reshuffle — the values assigned at combat start are fixed for the entire combat.

#### Scenario: Number distribution for a 12-card deck
- **WHEN** a 12-card deck is assembled at combat start
- **THEN** 3 cards receive value 1, 6 cards receive value 2, and 3 cards receive value 3 (assigned via COMBAT RNG stream)

---

### Requirement: [LLD-OMEN-MECH-009] Card Number — Randomised at Combat Start
Card timer values are **randomised at combat start** (not fixed on the card). Each card in the assembled deck is assigned a timer value via the COMBAT RNG stream using the distribution in `LLD-OMEN-MECH-008`. The value is stored with the card entry in `OmenDeckState` (see `LLD-ARCH-017`) and persists for the entire combat — values are not re-rolled when the deck reshuffles.

This means the same card (e.g. Burning) can be a fast cycle (1) or a slow one (3) depending on the run and the combat. Players cannot predict exact timer values, but can observe the current cycle's timer and plan around it.

#### Scenario: Same card, different values across combats
- **WHEN** the player fights two different combat encounters with identical decks
- **THEN** the timer values assigned to each card may differ; a Burning card might be value 2 in one fight and value 1 in the next

---

### Requirement: [LLD-OMEN-CARD-015] Vulnerable (Fire) (Whole-Side Overall Omen)
The Vulnerable (Fire) omen card SHALL apply the Vulnerable (Fire) status to all units on the target side for the cycle duration. Every fire damage hit against any affected unit is multiplied by ×1.5 (see `HLD-COMBAT-007` for Vulnerable rules including non-stacking and resistance cancellation).

**On enemy side:** all enemies become vulnerable to fire attacks. Pairs with any fire weapon (Ember Shard, Smoldering Brand) and fire consumables (Fire Bomb, Combustible Oil).
**On player side (forced):** player takes increased fire damage. Particularly dangerous on floors with Fire Elementals.

Card timer value is assigned at combat start via the randomised distribution (see `LLD-OMEN-MECH-009`).

#### Scenario: Whole-side fire vulnerability
- **WHEN** Vulnerable (Fire) is played to the enemy side with two enemies present
- **THEN** both enemies gain Vulnerable (Fire) for the cycle duration; all fire damage against them is ×1.5

#### Scenario: Non-stacking with item Vulnerable
- **WHEN** Combustible Oil has already applied Vulnerable (Fire) to one enemy and then Vulnerable (Fire) omen card is played to the enemy side
- **THEN** that enemy's fire multiplier remains ×1.5 (not ×2.25) — Vulnerable does not stack (see `HLD-COMBAT-007`)

---

### Requirement: [LLD-OMEN-CARD-016] Vulnerable (Lightning) (Whole-Side Overall Omen)
The Vulnerable (Lightning) omen card SHALL apply the Vulnerable (Lightning) status to all units on the target side for the cycle duration. Every lightning damage hit against any affected unit is multiplied by ×1.5 (see `HLD-COMBAT-007`).

**On enemy side:** all enemies become vulnerable to lightning attacks. Pairs with Spark Rod, Arc Wand, Fulminating Powder.
**On player side (forced):** player takes increased lightning damage.

Card timer value is assigned at combat start via the randomised distribution (see `LLD-OMEN-MECH-009`).

#### Scenario: Whole-side lightning vulnerability
- **WHEN** Vulnerable (Lightning) is played to the enemy side
- **THEN** all enemies on that side gain Vulnerable (Lightning) for the cycle; lightning damage against them is ×1.5

#### Scenario: Lightning Elemental resistance cancellation
- **WHEN** Vulnerable (Lightning) is played to the enemy side and a Lightning Elemental is present
- **THEN** the Lightning Elemental has both Resistance (Lightning ×0.5) and Vulnerable (Lightning ×1.5) — they cancel out; it takes normal lightning damage (×1.0) per `HLD-COMBAT-007`

---

### Requirement: [LLD-OMEN-CARD-017] Vulnerable (Ice) (Whole-Side Overall Omen)
The Vulnerable (Ice) omen card SHALL apply the Vulnerable (Ice) status to all units on the target side for the cycle duration. Every ice damage hit against any affected unit is multiplied by ×1.5 (see `HLD-COMBAT-007`).

**On enemy side:** all enemies become vulnerable to ice attacks. Pairs with Frost Sliver, Glacial Brand, Frost Shard.
**On player side (forced):** player takes increased ice damage.

Card timer value is assigned at combat start via the randomised distribution (see `LLD-OMEN-MECH-009`).

#### Scenario: Whole-side ice vulnerability
- **WHEN** Vulnerable (Ice) is played to the enemy side
- **THEN** all enemies on that side gain Vulnerable (Ice) for the cycle; ice damage against them is ×1.5

---

### Requirement: [LLD-OMEN-CARD-018] Mending (Whole-Side Overall Omen)
The Mending omen card SHALL apply the Mending status to all units on the target side. Each unit heals X HP per tick for the cycle duration (see `HLD-COMBAT-006` for the Mending status mechanic).

**On player side:** player heals each tick — valuable recovery, especially after a costly prior cycle.
**On enemy side (forced):** all enemies heal each tick — extends fights and can undo damage dealt in the current cycle.

Whole-side Mending heal value: **3 HP per tick** (matching the single-target Poultice, `LLD-ITEMS-008`).

#### Scenario: Whole-side Mending on player side
- **WHEN** the Mending omen card is played to the player side
- **THEN** the player heals X HP per tick for the cycle duration

#### Scenario: Mending on enemy side creates urgency
- **WHEN** Mending is played to the enemy side with two enemies present
- **THEN** both enemies heal X HP per tick; the player must deal net damage faster than the heal rate to make progress

---

### Requirement: [LLD-OMEN-CARD-019] Exposed (Whole-Side Overall Omen)
The Exposed omen card SHALL apply the Exposed status to all units on the target side. At the omen shift, all units on that side become Vulnerable (Physical) for the **next** omen cycle — the vulnerability takes effect at the start of the following cycle, not the current one.

Exposed triggers at the omen shift like Shocked, but instead of stunning, it applies a delayed Vulnerable (Physical) debuff. Low timer cards increase urgency — faster shift means faster Vulnerable (Physical) payoff.

**On enemy side:** enemies become Vulnerable (Physical) next cycle. Pair with a physical weapon in the following cycle for maximum impact.
**On player side (forced):** player will be Vulnerable (Physical) next cycle — incoming physical attacks hit harder for a full cycle.

Card timer value is assigned at combat start via the randomised distribution (see `LLD-OMEN-MECH-009`).

#### Scenario: Exposed triggers at shift
- **WHEN** Exposed is active on the enemy side and the omen shift occurs
- **THEN** all enemies on that side gain Vulnerable (Physical) ×1.5; that vulnerability is active for the entirety of the next omen cycle

#### Scenario: Exposed + physical weapon follow-up
- **WHEN** Exposed is played to the enemy side on cycle N and the timer card is 1
- **THEN** enemies gain Vulnerable (Physical) after 1 turn; in cycle N+1 all physical attacks against them deal ×1.5 damage

#### Scenario: Exposed non-stacking with Brittle Charm
- **WHEN** Exposed triggers on an enemy that already has Vulnerable (Physical) from Brittle Charm
- **THEN** the physical multiplier remains ×1.5 — two sources of the same Vulnerable do not stack (see `HLD-COMBAT-007`)

