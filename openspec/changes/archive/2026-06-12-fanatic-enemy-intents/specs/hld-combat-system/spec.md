## ADDED Requirements

### Requirement: [HLD-COMBAT-019] Max-Wins Status Reapplication
Applying Hardened or Emboldened to a target that already has an active instance of the same status (same `string_param` for Emboldened) SHALL keep whichever instance has the higher magnitude; a lower-magnitude or equal-magnitude application has no effect.

This rule applies to: **Hardened** and **Emboldened** (both Physical and elemental variants). It does NOT apply to Burning, Poisoned, or Bleed (magnitude-additive per `HLD-COMBAT-018`) or Chilled (idempotent per `HLD-COMBAT-015`).

#### Scenario: Max-wins — lower magnitude application has no effect
- **WHEN** Emboldened (Physical, magnitude 2) is applied to a target that already has Emboldened (Physical) with magnitude 3
- **THEN** the existing StatusInstance with magnitude 3 is unchanged; the incoming application has no effect

#### Scenario: Max-wins — higher magnitude application upgrades
- **WHEN** Emboldened (Physical, magnitude 3) is applied to a target that already has Emboldened (Physical) with magnitude 2
- **THEN** the existing StatusInstance's magnitude is updated to 3

#### Scenario: Max-wins — equal magnitude application has no effect
- **WHEN** Hardened (magnitude 3) is applied to a target that already has Hardened with magnitude 3
- **THEN** the existing StatusInstance is unchanged; this covers the common Totem case where the same magnitude is re-applied each turn

#### Scenario: Max-wins does not apply to magnitude-additive statuses
- **WHEN** Burning, Poisoned, or Bleed is applied to a target that already has an active StatusInstance of the same status
- **THEN** magnitude-additive rules apply (see `HLD-COMBAT-018`), not max-wins; the magnitudes are summed
