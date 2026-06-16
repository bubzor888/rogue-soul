## MODIFIED Requirements

### Requirement: [HLD-COMBAT-006] Status Effects
Status effects SHALL be applied as individual omens on a specific target. They clear at the next omen reset. Duration is determined by the timer card drawn (1–3 turns). See `HLD-COMBAT-008` for omen mechanics.

**Balancing assumption:** Assume 2 ticks as the typical case when setting all per-tick values.

| Status | Type | Primary effect |
|---|---|---|
| Burning | Per-turn / Offensive | Flat fire damage per tick; grants Vulnerable (Fire) |
| Shocked | Omen-triggered / Offensive | Grants Vulnerable (Lightning); stuns at omen shift |
| Chilled | Per-turn / Offensive+Defensive | Creeping damage reduction per tick (10%/20%/30%); grants Vulnerable (Ice) |
| Poisoned | Per-turn / Offensive | Escalating poison damage (triples each tick); no vulnerability |
| Mending | Per-turn / Defensive | Heals X HP per tick |
| Hardened | Per-turn / Defensive | Absorbs up to X incoming damage per tick; resets each tick |

#### Scenario: Burning tick damage
- **WHEN** a unit has the Burning status and an omen tick occurs
- **THEN** the unit takes fire damage and is Vulnerable (Fire) ×1.5

#### Scenario: Shocked stun timing
- **WHEN** a unit has the Shocked status and the omen shift occurs
- **THEN** that unit skips their next action

#### Scenario: Chilled damage reduction
- **WHEN** a unit has the Chilled status for 2 ticks
- **THEN** they deal 10% less damage on the first tick and 20% less on the second

#### Scenario: Poison escalation mechanic
- **WHEN** a unit has the Poisoned status and an omen tick occurs
- **THEN** the unit takes damage equal to the current poison value, and the poison value is tripled for the next tick

#### Scenario: Poison starting value is LLD
- **WHEN** the Poisoned status is applied
- **THEN** the starting poison value and any external modifications to it are defined in the LLD (e.g., 2→6→18 is one possible tuning, not a fixed rule)
