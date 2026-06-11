## MODIFIED Requirements

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

### Requirement: [LLD-OMEN-CARD-015] Vulnerable (Fire) (Whole-Side Overall Omen)
The Vulnerable (Fire) omen card SHALL apply the Vulnerable (Fire) status to all units on the target side for the cycle duration. Every fire damage hit against any affected unit is multiplied by ×1.5 (see `HLD-COMBAT-007` for Vulnerable rules including non-stacking and resistance cancellation).

**On enemy side:** all enemies become vulnerable to fire attacks. Pairs with any fire weapon (Ember Shard, Smoldering Brand) and fire consumables (Fire Bomb, Combustible Oil).
**On player side (forced):** player takes increased fire damage. Particularly dangerous on floors with Fire Elementals.

`[OPEN·MVP1]` Confirm Vulnerable (Fire) omen card number value (first pass: 2).

#### Scenario: Whole-side fire vulnerability
- **WHEN** Vulnerable (Fire) is played to the enemy side with two enemies present
- **THEN** both enemies gain Vulnerable (Fire) for the cycle duration; all fire damage against them is ×1.5

#### Scenario: Non-stacking with item Vulnerable
- **WHEN** Combustible Oil has already applied Vulnerable (Fire) to one enemy and then Vulnerable (Fire) omen card is played to the enemy side
- **THEN** that enemy's fire multiplier remains ×1.5 (not ×2.25) — Vulnerable does not stack (see `HLD-COMBAT-007`)

### Requirement: [LLD-OMEN-CARD-016] Vulnerable (Lightning) (Whole-Side Overall Omen)
The Vulnerable (Lightning) omen card SHALL apply the Vulnerable (Lightning) status to all units on the target side for the cycle duration. Every lightning damage hit against any affected unit is multiplied by ×1.5 (see `HLD-COMBAT-007`).

**On enemy side:** all enemies become vulnerable to lightning attacks. Pairs with Spark Rod, Arc Wand, Fulminating Powder.
**On player side (forced):** player takes increased lightning damage.

`[OPEN·MVP1]` Confirm Vulnerable (Lightning) omen card number value (first pass: 2).

#### Scenario: Whole-side lightning vulnerability
- **WHEN** Vulnerable (Lightning) is played to the enemy side
- **THEN** all enemies on that side gain Vulnerable (Lightning) for the cycle; lightning damage against them is ×1.5

#### Scenario: Lightning Elemental resistance cancellation
- **WHEN** Vulnerable (Lightning) is played to the enemy side and a Lightning Elemental is present
- **THEN** the Lightning Elemental has both Resistance (Lightning ×0.5) and Vulnerable (Lightning ×1.5) — they cancel out; it takes normal lightning damage (×1.0) per `HLD-COMBAT-007`

### Requirement: [LLD-OMEN-CARD-017] Vulnerable (Ice) (Whole-Side Overall Omen)
The Vulnerable (Ice) omen card SHALL apply the Vulnerable (Ice) status to all units on the target side for the cycle duration. Every ice damage hit against any affected unit is multiplied by ×1.5 (see `HLD-COMBAT-007`).

**On enemy side:** all enemies become vulnerable to ice attacks. Pairs with Frost Sliver, Glacial Brand, Frost Shard.
**On player side (forced):** player takes increased ice damage.

`[OPEN·MVP1]` Confirm Vulnerable (Ice) omen card number value (first pass: 2).

#### Scenario: Whole-side ice vulnerability
- **WHEN** Vulnerable (Ice) is played to the enemy side
- **THEN** all enemies on that side gain Vulnerable (Ice) for the cycle; ice damage against them is ×1.5

### Requirement: [LLD-OMEN-CARD-018] Mending (Whole-Side Overall Omen)
The Mending omen card SHALL apply the Mending status to all units on the target side. Each unit heals X HP per tick for the cycle duration (see `HLD-COMBAT-006` for the Mending status mechanic).

**On player side:** player heals each tick — valuable recovery, especially after a costly prior cycle.
**On enemy side (forced):** all enemies heal each tick — extends fights and can undo damage dealt in the current cycle.

`[OPEN·MVP1]` Whole-side Mending heal value per tick (first pass: match single-target Poultice value once set in LLD-ITEMS-008).

#### Scenario: Whole-side Mending on player side
- **WHEN** the Mending omen card is played to the player side
- **THEN** the player heals X HP per tick for the cycle duration

#### Scenario: Mending on enemy side creates urgency
- **WHEN** Mending is played to the enemy side with two enemies present
- **THEN** both enemies heal X HP per tick; the player must deal net damage faster than the heal rate to make progress

### Requirement: [LLD-OMEN-CARD-019] Exposed (Whole-Side Overall Omen)
The Exposed omen card SHALL apply the Exposed status to all units on the target side. At the omen shift, all units on that side become Vulnerable (Physical) for the **next** omen cycle — the vulnerability takes effect at the start of the following cycle, not the current one.

Exposed triggers at the omen shift like Shocked, but instead of stunning, it applies a delayed Vulnerable (Physical) debuff. Low timer cards increase urgency — faster shift means faster Vulnerable (Physical) payoff.

**On enemy side:** enemies become Vulnerable (Physical) next cycle. Pair with a physical weapon in the following cycle for maximum impact.
**On player side (forced):** player will be Vulnerable (Physical) next cycle — incoming physical attacks hit harder for a full cycle.

`[OPEN·MVP1]` Confirm Exposed card number value (first pass: 2).

#### Scenario: Exposed triggers at shift
- **WHEN** Exposed is active on the enemy side and the omen shift occurs
- **THEN** all enemies on that side gain Vulnerable (Physical) ×1.5; that vulnerability is active for the entirety of the next omen cycle

#### Scenario: Exposed + physical weapon follow-up
- **WHEN** Exposed is played to the enemy side on cycle N and the timer card is 1
- **THEN** enemies gain Vulnerable (Physical) after 1 turn; in cycle N+1 all physical attacks against them deal ×1.5 damage

#### Scenario: Exposed non-stacking with Brittle Charm
- **WHEN** Exposed triggers on an enemy that already has Vulnerable (Physical) from Brittle Charm
- **THEN** the physical multiplier remains ×1.5 — two sources of the same Vulnerable do not stack (see `HLD-COMBAT-007`)
