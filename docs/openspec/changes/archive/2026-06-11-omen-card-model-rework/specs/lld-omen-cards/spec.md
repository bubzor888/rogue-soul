## MODIFIED Requirements

### Requirement: [LLD-OMEN-CARD-002] Shocked (Per-Unit Omen)
The Shocked omen card SHALL apply the Shocked status (`trigger: "shift"`) to each eligible unit on the target side as an individual StatusInstance. At the omen shift, each Shocked StatusInstance fires: the stun effect (`is_stunned = true`) is applied to that specific unit, then the StatusInstance clears.

Mirrors Fulminating Powder (single-target). Low timer cards are valuable when Shocked is active — faster stun payoff.

**On enemy side:** each enemy gains its own Shocked StatusInstance; at the omen shift each stunned enemy skips its next action — their Action bucket is blocked. Combine with Fulminating Powder for Vulnerable (Lightning) if desired.
**On player side (forced):** the player gains a Shocked StatusInstance; at the omen shift the player's Action bucket is blocked for their next turn. Support and Consumable buckets remain available. Cleared by Amethyst (clears the StatusInstance before the shift fires).

#### Scenario: Shocked stun — per unit, Action bucket only
- **WHEN** the Shocked omen card is played to the enemy side with two enemies present
- **THEN** each enemy gains its own Shocked StatusInstance; at the omen shift each fires independently — both enemies have is_stunned = true and skip their next Action bucket use; no Vulnerable is co-applied

#### Scenario: Shocked player — cleansable before shift
- **WHEN** the player has a Shocked StatusInstance and uses Amethyst before the omen shift fires
- **THEN** the Shocked StatusInstance is removed; is_stunned is never set; the player's Action bucket remains available

---

### Requirement: [LLD-OMEN-CARD-004] Emboldened (Physical) (Per-Unit Omen)
The Emboldened (Physical) omen card SHALL apply the Emboldened (Physical) status to each unit on the target side as an individual StatusInstance (see `HLD-COMBAT-006` for status definition). Each unit's outgoing physical damage gains the flat bonus while the status is active.

**On enemy side:** the player's physical weapons deal more damage per hit. Always relevant since physical is the default damage type.
**On player side (forced):** enemies deal more physical damage per hit.

Source: confirmed as a Skeleton omen contribution (`LLD-ENEMIES-004`).

Flat physical damage bonus: **+2 per hit** (see `LLD-ARCH-019` damage resolution order step 2 for application).

#### Scenario: Physical damage bonus per unit
- **WHEN** Emboldened (Physical) is active on the player side
- **THEN** every physical damage hit by the player gains the +2 flat bonus; the status is tracked as a StatusInstance and can be cleansed by an appropriate item

---

### Requirement: [LLD-OMEN-CARD-005] Emboldened (Elemental) (Per-Unit Omen)
The Emboldened (Elemental) omen card SHALL apply the matching Emboldened (Elemental) status to each unit on the target side as an individual StatusInstance (see `HLD-COMBAT-006` for status definitions). Each unit's outgoing damage of the matching elemental type is multiplied by ×1.5 while the status is active.

Separate cards exist for each confirmed element: Fire, Lightning, Ice.

**On enemy side:** the player's attacks of that element hit harder. High value when the matching elemental weapon is equipped.
**On player side (forced):** enemies deal increased damage of that type. Particularly dangerous if the player is already Vulnerable to that element.

Elemental damage bonus multiplier: **×1.5** (same as Vulnerability — stacks multiplicatively with Vulnerable when the element matches, per `HLD-COMBAT-007`). Applied at damage resolution step 4 (see `LLD-ARCH-019`).

#### Scenario: Elemental bonus stacks with vulnerability
- **WHEN** Emboldened (Fire) is active on the player side and an enemy has Vulnerable (Fire) applied via Combustible Oil
- **THEN** the elemental bonus (×1.5 outgoing) and the vulnerability multiplier (×1.5 incoming) both apply — the combined effect is intentional and represents the fire combo payoff

---

### Requirement: [LLD-OMEN-CARD-011] Grave Knit (Enemy Card — Undead)
The Grave Knit omen card SHALL apply a Mending StatusInstance to each unit on the target side whose `enemy_tags` contains `"undead"`. Units not tagged `"undead"` receive nothing. The Mending status heals X HP per tick for the cycle duration.

`OmenCardData.requires_tag` for this card: `"undead"`.

**On enemy side:** undead enemies each gain their own Mending StatusInstance and heal per tick — must be managed or absorbed. Non-undead enemies on the same side are unaffected.
**On player side:** no effect — the player is not tagged `"undead"`. Safe to absorb.

Which enemies contribute Grave Knit is defined in `lld-enemies` (see `LLD-ENEMIES-004`, `LLD-ENEMIES-005`).

Grave Knit heal value: **5 HP per tick**.

#### Scenario: Grave Knit heals undead only — mixed side
- **WHEN** Grave Knit is played to a side containing one Skeleton (tagged "undead") and one Plague Rat (tagged "beast")
- **THEN** the Skeleton receives a Mending StatusInstance and heals each tick; the Plague Rat receives nothing

#### Scenario: Grave Knit player side — safe
- **WHEN** the player steers Grave Knit to their own side
- **THEN** no StatusInstance is applied; the player is not tagged "undead"; the enemy side does not receive healing that cycle

---

### Requirement: [LLD-OMEN-CARD-012] Thick Hide (Enemy Card — Beast)
The Thick Hide omen card SHALL apply a Thick Hide StatusInstance to each unit on the target side whose `enemy_tags` contains `"beast"`. Units not tagged `"beast"` receive nothing. The Thick Hide status reduces incoming damage by 3 per hit for the cycle duration.

`OmenCardData.requires_tag` for this card: `"beast"`.

**On beast side:** each beast gains its own Thick Hide StatusInstance; each incoming hit to that beast is reduced by 3 — breaks weapon kill thresholds and dramatically extends fights.
**On player side:** no effect — the player is not tagged `"beast"`. Safe to absorb.

Thick Hide damage reduction per hit: **3**.

#### Scenario: Thick Hide absorption on beast side — per unit
- **WHEN** Thick Hide is active on a side containing two Wolves (both tagged "beast")
- **THEN** each Wolf has its own Thick Hide StatusInstance; each incoming hit to each Wolf is reduced by 3 independently

#### Scenario: Thick Hide player side — safe
- **WHEN** the player steers Thick Hide to their own side
- **THEN** no StatusInstance is applied; the beasts do not receive the defensive buff

---

## ADDED Requirements

### Requirement: [LLD-OMEN-CARD-019] Exposed (Whole-Side Floor Card — Floor 3)
The Exposed omen card SHALL apply the Exposed status (`trigger: "shift"`) to each eligible unit on the target side as an individual StatusInstance. At the omen shift, each Exposed StatusInstance fires: a Vulnerable (Physical) StatusInstance is applied to that unit with `remaining_ticks` equal to the newly drawn cycle's timer value, then the Exposed StatusInstance clears.

The Exposed card is included in the Floor 3 ambient deck (see `LLD-OMEN-CARD-008`). It is not contributed by any specific enemy or vessel.

Low timer cards are desirable when Exposed is active on the enemy side — the omen shift fires sooner, delivering Vulnerable (Physical) to enemies faster (see `HLD-OMEN-002`).

**On enemy side:** each enemy gains a Exposed StatusInstance; at the omen shift each becomes Vulnerable (Physical) for the next full omen cycle. Pairs with any physical weapon — the window of amplified physical damage lasts exactly one cycle.
**On player side (forced):** the player gains a Exposed StatusInstance; at the omen shift the player becomes Vulnerable (Physical) for the next omen cycle. Cleared by Ointment (removes the Exposed StatusInstance before the shift fires, preventing the Vulnerable application entirely).

#### Scenario: Exposed fires at shift — Vulnerable duration matches new cycle
- **WHEN** Exposed is active on the enemy side and the omen shift occurs, drawing a new cycle with timer value 2
- **THEN** each enemy that had an Exposed StatusInstance receives a Vulnerable (Physical) StatusInstance with remaining_ticks = 2; the Exposed StatusInstance is then cleared; the Vulnerable lasts exactly the next omen cycle

#### Scenario: Exposed cleansed before shift — no Vulnerable
- **WHEN** the player has an Exposed StatusInstance and uses Ointment before the omen shift fires
- **THEN** the Exposed StatusInstance is removed; at the omen shift no Vulnerable (Physical) is applied to the player

#### Scenario: Exposed on enemy side pairs with physical weapon
- **WHEN** Exposed fires on the enemy side and the player's equipped weapon deals physical damage
- **THEN** the player's physical attacks hit the Vulnerable (Physical) enemies at ×1.5 for the full duration of the next omen cycle

#### Scenario: Exposed — low timer strategic value
- **WHEN** Exposed is active on the enemy side and the timer card is 1
- **THEN** the omen shift fires after 1 turn; the Vulnerable (Physical) is applied immediately at the next draw, giving the player access to the ×1.5 multiplier window after only one cycle
