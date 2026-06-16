## MODIFIED Requirements

### Requirement: [LLD-ITEMS-007] Floor 3 Consumable Drop Pool — Normal Tier
The following consumables SHALL be in the normal drop pool for Floor 3:

| Item | Effect |
|---|---|
| Fire Bomb | Applies Burning (5 fire damage/tick; see `HLD-COMBAT-006`) to one enemy |
| Ointment | Clears Burning or Poisoned from one target (see `LLD-ITEMS-001` for cleanse category rules) |
| Combustible Oil | Applies Vulnerable (Fire) ×1.5 to one enemy (see `HLD-COMBAT-007`); if target already Burning → flat fire damage burst instead (`[OPEN·MVP1]` value: first pass 6) |
| Hardening Resin | Applies Hardened to player (X = 3 damage absorbed/tick; see `HLD-COMBAT-006` for full effect) |

#### Scenario: Fire Bomb typical damage
- **WHEN** a player uses Fire Bomb and the timer card is 2 (typical)
- **THEN** the target takes 10 fire damage total (5/tick × 2 ticks)

#### Scenario: Combustible Oil branching
- **WHEN** a player uses Combustible Oil against a non-Burning enemy
- **THEN** the enemy gains Vulnerable (Fire) — no DoT applied

#### Scenario: Combustible Oil vs Burning enemy
- **WHEN** a player uses Combustible Oil against a Burning enemy
- **THEN** the enemy takes flat fire damage burst (value TBD); no additional vulnerability stacking
