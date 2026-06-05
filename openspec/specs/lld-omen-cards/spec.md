
### Requirement: [LLD-OMEN-CARD-001] Burning (Whole-Side Overall Omen)
The Burning omen card SHALL apply the Burning status to all units on the target side. Each unit takes flat fire damage per tick and is Vulnerable (Fire) ×1.5 for the cycle duration (see `HLD-COMBAT-006` for per-tick values).

Mirrors the Fire Bomb consumable (single-target individual omen). Whole-side values may differ from single-target values and are tuned independently.

**On enemy side:** all enemies take fire DoT and are Vulnerable (Fire). Pairs strongly with Smoldering Brand or Ember Shard (`LLD-ITEMS-006`, `LLD-ITEMS-005`).
**On player side (forced):** player takes fire DoT and is Vulnerable (Fire). Cleared per-unit by Ointment.

`[OPEN]` Whole-side Burning tick damage value (first pass: 5/tick, matching single-target). Source pool (floor, enemy, or vessel) to be confirmed.

#### Scenario: Whole-side Burning on enemies
- **WHEN** the Burning omen card is played to the enemy side and there are two enemies
- **THEN** both enemies gain the Burning status and are Vulnerable (Fire) ×1.5 for the cycle

---

### Requirement: [LLD-OMEN-CARD-002] Shocked (Whole-Side Overall Omen)
The Shocked omen card SHALL apply the Shocked status to all units on the target side. All units on that side are Vulnerable (Lightning) ×1.5. At the omen shift, all units on that side skip their next action.

Mirrors Fulminating Powder (single-target). Low timer cards are valuable when Shocked is active — faster stun payoff across the whole side.

**On enemy side:** all enemies stunned at the shift and vulnerable to lightning. Extremely powerful with Arc Wand equipped — both primary and arc target benefit from the vulnerability.
**On player side (forced):** player is Vulnerable (Lightning) and will be stunned. Cleared by Amethyst.

`[OPEN]` Source pool (floor, enemy, or vessel) to be confirmed.

#### Scenario: Whole-side Shocked stun
- **WHEN** the Shocked omen card is played to the enemy side with two enemies present
- **THEN** both enemies are Vulnerable (Lightning) ×1.5 and both skip their next action at the omen shift

---

### Requirement: [LLD-OMEN-CARD-003] Chilled (Whole-Side Overall Omen)
The Chilled omen card SHALL apply the Chilled status to all units on the target side. Each unit deals reduced damage per tick (creeping, never to zero) and is Vulnerable (Ice) ×1.5 for the cycle duration.

Mirrors Frost Shard (single-target). Particularly effective against multi-enemy encounters — damage reduction applies across all attackers simultaneously.

**On enemy side:** all enemies deal less damage each tick and are vulnerable to ice. Pairs with Glacial Brand.
**On player side (forced):** player deals reduced damage and is Vulnerable (Ice). Cleared by Amethyst.

`[OPEN]` Whole-side Chilled reduction values (first pass: 10%/20%/30% per tick, matching single-target). Source pool to be confirmed.

#### Scenario: Whole-side Chilled vs multi-enemy
- **WHEN** the Chilled omen card is played to the enemy side with two enemies
- **THEN** both enemies deal 10% less damage on tick 1 and 20% less on tick 2 (typical 2-tick cycle)

---

### Requirement: [LLD-OMEN-CARD-004] Emboldened (Physical) (Whole-Side Overall Omen)
The Emboldened (Physical) omen card SHALL add a flat bonus to all physical damage dealt by units on the target side for the cycle duration. Expressed as a flat bonus (not percentage) because physical damage is the most common type and a percentage would be too broadly powerful.

**On enemy side:** player's physical weapons deal more damage per hit. Always relevant since physical is the default damage type.
**On player side (forced):** enemies deal more physical damage per hit.

Source: confirmed as a Skeleton omen contribution (`LLD-ENEMIES-004`).

`[OPEN]` Flat bonus value (e.g. +2 per hit) to be set once all weapon damage values are established.

#### Scenario: Physical damage bonus
- **WHEN** Emboldened (Physical) is active on the player side
- **THEN** every physical damage hit by the player deals the confirmed flat bonus additional damage

---

### Requirement: [LLD-OMEN-CARD-005] Emboldened (Elemental) (Whole-Side Overall Omen)
The Emboldened (Elemental) omen card SHALL add a percentage increase to all damage of a specific elemental type dealt by units on the target side. Expressed as a percentage (not flat) because elemental damage is more situational.

Separate cards exist for each confirmed element: Fire, Lightning, Ice.

**On enemy side:** player's attacks of that element hit harder. High value when the matching elemental weapon is equipped.
**On player side (forced):** enemies deal increased damage of that type. Particularly dangerous if the player is already Vulnerable to that element.

`[OPEN]` Emboldened (Elemental) percentage value to be set. Card-to-source-pool assignment (floor vs enemy) to be confirmed during omen deck design.

#### Scenario: Elemental bonus stacks with vulnerability
- **WHEN** Emboldened (Fire) is active on the player side and an enemy has Burning status (Vulnerable Fire ×1.5)
- **THEN** the elemental bonus and the vulnerability multiplier both apply — the combined effect is intentional and represents the fire combo payoff

---

### Requirement: [LLD-OMEN-CARD-006] Stillness (Vessel Card — Pilgrim)
The Stillness omen card SHALL do nothing when played on either side. Its number still functions as a timer card if it is the leftover draw. The Pilgrim contributes 2 copies of Stillness to the omen deck — present in every combat on a Pilgrim run.

**Design rationale:** Stillness dilutes the deck — any specific effect is slightly less likely in a Pilgrim run. Drawing Stillness is safe: the player can apply it to themselves with no consequence, or use it as their chosen card to guarantee the random card lands on the enemy side without fear of what follows. Thematically: the Pilgrim arrives at the Threshold having shed everything; his contribution to the omen field is absence.

`[OPEN]` Stillness copy count (first pass: 2) to be confirmed once deck sizes are established.

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

`[OPEN]` Fortified damage reduction value to be set during Hedge Knight vessel design. Full Iron Pendant interaction documented in `docs/vessels/vessel_hedge_knight.md`.

#### Scenario: Fortified on player side
- **WHEN** Fortified is active on the player side
- **THEN** the player takes the confirmed reduced amount of incoming damage from all sources

---

### Requirement: [LLD-OMEN-CARD-008] Floor 3 Omen Pool
`[OPEN]` The ambient omen cards contributed by Floor 3 — The Threshold — to every combat on that floor are entirely undesigned. Design constraints:
- Should reflect the liminal, half-formed atmosphere of the Threshold
- Should not be so hostile that every draw is a threat — the floor pool sets baseline difficulty before enemy cards are added
- Should include a mix of card numbers (1s, 2s, 3s) for varied cycle lengths
- Likely includes at least one each of Burning, Chilled, Emboldened (Physical) to introduce all systems early
- Target ~10 cards total

#### Scenario: [OPEN] Floor pool design
- **WHEN** Floor 3 omen pool is designed
- **THEN** each card in the pool is added to this spec with its effect, count, and number distribution
