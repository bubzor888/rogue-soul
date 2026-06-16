## MODIFIED Requirements

### Requirement: [HLD-OMEN-002] Timer Card and Status Effect Interaction
For **per-tick** status effects (Burning, Poisoned, Chilled, Mending, Hardened — see `HLD-COMBAT-006`), a higher timer card (3) is generally desirable — more ticks means more total value. For **shift-triggered** effects (Shocked, Exposed), a lower timer card (1) is desirable — the shift fires sooner, delivering the stun or the Vulnerable (Physical) faster. This creates different strategic priorities depending on what is active.

#### Scenario: High timer with Burning
- **WHEN** Burning is active and the timer card is 3
- **THEN** the Burning status ticks 3 times (total 15 fire damage base), making high timer cards more valuable in fire setups

#### Scenario: Low timer with Shocked
- **WHEN** Shocked is active and the timer card is 1
- **THEN** the stun triggers after 1 turn — making low timer cards actively desirable when Shocked is active

#### Scenario: Low timer with Exposed
- **WHEN** Exposed is active on the enemy side and the timer card is 1
- **THEN** the omen shift fires after 1 turn; Vulnerable (Physical) is applied to the affected units at the start of the next cycle — a short Exposed cycle delivers the vulnerability faster

---

### Requirement: [HLD-OMEN-005] Omen Application Model
When an omen card is applied to a side, each eligible unit on that side receives its own individual StatusInstance. There is no shared whole-side state — every unit tracks its own status independently. Killing a unit removes only that unit's StatusInstances. Cleansing a unit removes only that unit's StatusInstances.

**Tag-conditional application:** Some omen cards specify a tag requirement. When such a card is applied, only units whose `enemy_tags` include the required tag receive a StatusInstance. Units that do not match receive nothing. If the card is steered to the player side and the player is not tagged, no effect is applied — this is always safe for the player with family-specific cards (e.g. Grave Knit, Thick Hide).

**Individual omens** from consumables, abilities, or enemy actions target one specific unit directly and follow the same StatusInstance model.

**Duration:** All status effects — whether sourced from omen cards or from individual actions — clear at the omen reset (when `remaining_ticks` reaches 0). Individual omens applied mid-cycle clear at the *next* reset; they do not persist into the following cycle.

#### Scenario: Omen card applies per-unit
- **WHEN** a Burning omen card is played to the enemy side and two enemies are present
- **THEN** each enemy receives its own Burning StatusInstance; killing one enemy removes only that enemy's StatusInstance; the other enemy's Burning is unaffected

#### Scenario: Tag-conditional card skips non-matching units
- **WHEN** Grave Knit is played to a side containing one Skeleton (tagged "undead") and one Plague Rat (tagged "beast")
- **THEN** only the Skeleton receives a Mending StatusInstance; the Plague Rat receives nothing

#### Scenario: Family card steered to player side — safe
- **WHEN** the player steers Grave Knit to their own side
- **THEN** no StatusInstance is applied (the player is not tagged "undead"); the enemy side does not receive healing that cycle

#### Scenario: Cleanse is unit-local
- **WHEN** the player uses a cleanse item targeting one enemy
- **THEN** only that enemy's matching StatusInstances are removed; all other units retain their statuses unchanged

#### Scenario: Individual omen does not affect whole side
- **WHEN** a player uses Fire Bomb (individual omen) against one enemy
- **THEN** only that specific enemy gains Burning — other enemies on the same side are unaffected
