## MODIFIED Requirements

### Requirement: [LLD-OMEN-CARD-001] Burning (Whole-Side Overall Omen)
The Burning omen card SHALL apply the Burning status to all units on the target side. Each unit takes flat fire damage per tick for the cycle duration (see `HLD-COMBAT-006` for per-tick value framework). The StatusInstance is created with `magnitude: 5` (the card's `status_magnitude` value — see `LLD-ARCH-018`).

Mirrors the Fire Bomb consumable (single-target individual omen). Whole-side values may differ from single-target values and are tuned independently.

**On enemy side:** all enemies take fire DoT. Pairs with Smoldering Brand or Ember Shard (`LLD-ITEMS-006`, `LLD-ITEMS-005`). Combine with Combustible Oil for Vulnerable (Fire) if the fire combo payoff is wanted.
**On player side (forced):** player takes fire DoT. Cleared per-unit by Ointment.

Whole-side Burning tick damage: **5 fire damage per tick** (`status_magnitude: 5`).

#### Scenario: Whole-side Burning on enemies
- **WHEN** the Burning omen card is played to the enemy side and there are two enemies
- **THEN** both enemies gain a Burning StatusInstance with magnitude 5 for the cycle; no Vulnerable is co-applied

#### Scenario: Burning omen card stacks with existing Burning
- **WHEN** the Burning omen card fires on a target that already has an active Burning StatusInstance (e.g. from a prior Fire Elemental Kindle intent)
- **THEN** per `HLD-COMBAT-018`, the existing Burning StatusInstance's magnitude is incremented by 5; remaining_ticks is unchanged
