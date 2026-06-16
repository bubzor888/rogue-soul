## MODIFIED Requirements

### Requirement: [HLD-COMBAT-006] Status Effects
Status effects SHALL be applied as individual omens on a specific target. They clear at the next omen reset. Duration is determined by the timer card drawn (1–3 turns). See `HLD-COMBAT-008` for omen mechanics.

**Balancing assumption:** Assume 2 ticks as the typical case when setting all per-tick values.

| Status | Type | Primary effect |
|---|---|---|
| Burning | Per-turn / Offensive | Flat fire damage per tick |
| Shocked | Omen-triggered / Offensive | Stuns at omen shift |
| Chilled | Per-turn / Offensive+Defensive | Creeping flat damage reduction per tick (amounts defined by omen card) |
| Poisoned | Per-turn / Offensive | Escalating poison damage (triples each tick); no vulnerability |
| Bleed | Per-turn / Offensive | Decaying physical damage per tick: deals damage equal to current stacks, then stacks halve (floor); clears when stacks reach 0 |
| Mending | Per-turn / Defensive | Heals X HP per tick |
| Hardened | Per-turn / Defensive | Absorbs up to X incoming damage per tick; resets each tick |
| Vulnerable (Fire) | Offensive | Amplifies all fire damage dealt to target by ×1.5 (see `HLD-COMBAT-007`) |
| Vulnerable (Lightning) | Offensive | Amplifies all lightning damage dealt to target by ×1.5 (see `HLD-COMBAT-007`) |
| Vulnerable (Ice) | Offensive | Amplifies all ice damage dealt to target by ×1.5 (see `HLD-COMBAT-007`) |
| Vulnerable (Physical) | Offensive | Amplifies all physical damage dealt to target by ×1.5 (see `HLD-COMBAT-007`) |

Elemental statuses (Burning, Shocked, Chilled) do **not** co-apply a Vulnerable status. Vulnerable must be applied separately via a dedicated item (see `HLD-COMBAT-007`).

#### Scenario: Burning tick damage
- **WHEN** a unit has the Burning status and an omen tick occurs
- **THEN** the unit takes flat fire damage (amount defined in LLD)

#### Scenario: Shocked stun timing
- **WHEN** a unit has the Shocked status and the omen shift occurs
- **THEN** that unit skips their next action

#### Scenario: Chilled flat damage reduction
- **WHEN** a unit has the Chilled status
- **THEN** they deal less damage each turn; the reduction is a flat value that increases each tick (amounts defined by the omen card); the reduction can never reduce damage to zero

#### Scenario: Poison escalation mechanic
- **WHEN** a unit has the Poisoned status and an omen tick occurs
- **THEN** the unit takes damage equal to the current poison value, and the poison value is tripled for the next tick

#### Scenario: Poison starting value is LLD
- **WHEN** the Poisoned status is applied
- **THEN** the starting poison value and any external modifications to it are defined in the LLD (e.g., 2→6→18 is one possible tuning, not a fixed rule)

#### Scenario: Bleed tick — damage then decay
- **WHEN** a unit has the Bleed status and an omen tick occurs
- **THEN** the unit takes physical damage equal to the current Bleed stacks, then the stacks are reduced to floor(stacks / 2)

#### Scenario: Bleed clears when stacks reach zero
- **WHEN** a Bleed tick reduces the stacks to 0 (i.e. stacks were 1 before the tick: floor(1/2) = 0)
- **THEN** the unit takes 1 physical damage and the Bleed status clears immediately

#### Scenario: Bleed decay sequence
- **WHEN** a unit has Bleed applied with 5 stacks
- **THEN** over three ticks it deals 5 damage (→2 stacks), then 2 damage (→1 stack), then 1 damage and clears

#### Scenario: Bleed clears at omen reset
- **WHEN** the omen cycle resets
- **THEN** any active Bleed status on any unit is cleared, regardless of remaining stacks
