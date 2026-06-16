## MODIFIED Requirements

### Requirement: [HLD-COMBAT-006] Status Effects
Status effects SHALL be applied as individual StatusInstances on a specific target. They clear at the next omen reset. Duration is determined by the timer card drawn (1–3 turns). See `HLD-COMBAT-008` for omen mechanics.

**Status trigger types:** Statuses are either **per-tick** (`trigger: "tick"`) — effect fires on every omen tick while active — or **shift-triggered** (`trigger: "shift"`) — effect fires once at the omen shift when the status expires and does nothing on intermediate ticks.

**Balancing assumption:** Assume 2 ticks as the typical case when setting all per-tick values.

| Status | Trigger | Type | Primary effect |
|---|---|---|---|
| Burning | Per-tick | Offensive | Flat fire damage per tick |
| Shocked | Shift-triggered | Offensive | At omen shift: sets is_stunned on the target — Action bucket blocked for their next turn; Support and Consumable buckets remain available |
| Exposed | Shift-triggered | Offensive | At omen shift: applies Vulnerable (Physical) to the target with `remaining_ticks` equal to the next omen cycle's timer value |
| Chilled | Per-tick | Offensive+Defensive | Creeping flat damage reduction per tick (amounts defined by omen card) |
| Poisoned | Per-tick | Offensive | Escalating poison damage (triples each tick); no vulnerability |
| Bleed | Per-tick | Offensive | Decaying physical damage per tick: deals damage equal to current stacks, then stacks halve (floor); clears when stacks reach 0 |
| Mending | Per-tick | Defensive | Heals X HP per tick |
| Hardened | Per-tick | Defensive | Absorbs up to X incoming damage per tick; resets each tick |
| Vulnerable (Fire) | Passive | Offensive | Amplifies all fire damage dealt to target by ×1.5 (see `HLD-COMBAT-007`) |
| Vulnerable (Lightning) | Passive | Offensive | Amplifies all lightning damage dealt to target by ×1.5 (see `HLD-COMBAT-007`) |
| Vulnerable (Ice) | Passive | Offensive | Amplifies all ice damage dealt to target by ×1.5 (see `HLD-COMBAT-007`) |
| Vulnerable (Physical) | Passive | Offensive | Amplifies all physical damage dealt to target by ×1.5 (see `HLD-COMBAT-007`) |
| Emboldened (Physical) | Passive | Offensive | Adds flat bonus to target's outgoing physical damage per hit (value defined in LLD) |
| Emboldened (Fire) | Passive | Offensive | Multiplies target's outgoing fire damage by ×1.5 |
| Emboldened (Lightning) | Passive | Offensive | Multiplies target's outgoing lightning damage by ×1.5 |
| Emboldened (Ice) | Passive | Offensive | Multiplies target's outgoing ice damage by ×1.5 |
| Frenzied | Passive | Offensive | Composite: unit simultaneously has Vulnerable (Physical) (incoming ×1.5) and Emboldened (Physical) (outgoing flat bonus); applied as one status |

Elemental statuses (Burning, Chilled) do **not** co-apply a Vulnerable status. Vulnerable must be applied separately via a dedicated item (see `HLD-COMBAT-007`) or via the Exposed shift trigger.

#### Scenario: Burning tick damage
- **WHEN** a unit has the Burning status and an omen tick occurs
- **THEN** the unit takes flat fire damage (amount defined in LLD)

#### Scenario: Shocked stun — Action bucket blocked only
- **WHEN** a unit has the Shocked status and the omen shift occurs
- **THEN** that unit's Action bucket is blocked for their next turn; Support and Consumable buckets remain available

#### Scenario: Exposed fires at shift — Vulnerable deferred to next cycle
- **WHEN** a unit has the Exposed status and the omen shift occurs
- **THEN** Vulnerable (Physical) is applied to that unit with remaining_ticks equal to the next omen cycle's timer value; the Exposed status is then cleared

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

#### Scenario: Emboldened (Physical) flat damage bonus
- **WHEN** a unit has Emboldened (Physical) and makes a physical attack
- **THEN** the attack deals additional flat physical damage (value defined in LLD) on top of base damage

#### Scenario: Emboldened (Fire) multiplier
- **WHEN** a unit has Emboldened (Fire) and deals fire damage
- **THEN** the fire damage is multiplied by ×1.5

#### Scenario: Frenzied — both sides simultaneously
- **WHEN** a unit has the Frenzied status and makes a physical attack
- **THEN** the attack gains the Emboldened (Physical) flat bonus; incoming physical attacks against that unit are amplified by ×1.5 via Vulnerable (Physical)

#### Scenario: Frenzied — single status, single clear
- **WHEN** a unit with the Frenzied status is cleansed of Frenzied
- **THEN** both the Vulnerable (Physical) and Emboldened (Physical) effects are removed simultaneously; they do not need to be cleared separately
