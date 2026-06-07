## REMOVED Requirements

### Requirement: [LLD-ABILITIES-001] Ability Handler Library
**Reason**: The handler table contains stale entries (`force_row`, `summon_unit`, row-modifier references) that no longer reflect the current design. The full handler library will be redefined in a dedicated session once the LLD pass is complete.
**Migration**: None required yet. `[OPEN·MVP1]` Handler library to be defined before implementation begins.

---

### Requirement: [LLD-ABILITIES-002] Handler Naming Convention
**Reason**: This is a code architecture rule, not an ability design spec. Moved to `lld-technical-architecture` as LLD-ARCH-012.
**Migration**: See `LLD-ARCH-012` for the canonical definition.

## MODIFIED Requirements

### Requirement: [LLD-ABILITIES-004] Default Strike — Throw Rock
All vessels SHALL have a Throw Rock default strike with handler chain: `deal_damage { base_damage: 3, damage_type: physical }`. No charges; always usable. See `HLD-COMBAT-011` for the HLD-level default strike requirement.

#### Scenario: Throw Rock damage
- **WHEN** Throw Rock is used against an enemy
- **THEN** the enemy takes 3 physical damage (subject to vulnerability modifiers per `HLD-COMBAT-007`)
