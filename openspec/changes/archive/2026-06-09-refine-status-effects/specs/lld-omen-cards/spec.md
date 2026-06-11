## MODIFIED Requirements

### Requirement: [LLD-OMEN-CARD-001] Burning (Whole-Side Overall Omen)
The Burning omen card SHALL apply the Burning status to all units on the target side. Each unit takes flat fire damage per tick for the cycle duration (see `HLD-COMBAT-006` for per-tick value framework).

Mirrors the Fire Bomb consumable (single-target individual omen). Whole-side values may differ from single-target values and are tuned independently.

**On enemy side:** all enemies take fire DoT. Pairs with Smoldering Brand or Ember Shard (`LLD-ITEMS-006`, `LLD-ITEMS-005`). Combine with Combustible Oil for Vulnerable (Fire) if the fire combo payoff is wanted.
**On player side (forced):** player takes fire DoT. Cleared per-unit by Ointment.

`[OPEN·MVP1]` Whole-side Burning tick damage value (first pass: 5/tick).

#### Scenario: Whole-side Burning on enemies
- **WHEN** the Burning omen card is played to the enemy side and there are two enemies
- **THEN** both enemies gain the Burning status for the cycle; no Vulnerable is co-applied
