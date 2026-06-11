## Modified Requirements

### MODIFIED: [HLD-COMBAT-006] Status Effects

Status effects SHALL be applied as individual StatusInstances on a specific target. They clear at the next omen reset. Duration is determined by the timer card drawn (1–3 turns). See `HLD-COMBAT-008` for omen mechanics.

**Status trigger types:** Statuses are either **per-tick** (`trigger: "tick"`) — effect fires on every omen tick while active — or **shift-triggered** (`trigger: "shift"`) — effect fires once at the omen shift when the status expires and does nothing on intermediate ticks.

**Parameterized statuses:** Some statuses carry a type qualifier in `string_param` on the StatusInstance (see `LLD-ARCH-017`). The type determines which damage type the effect applies to; the `status_id` identifies the effect category.

**Balancing assumption:** Assume 2 ticks as the typical case when setting all per-tick values.

| Status | Trigger | Type | Primary effect |
|---|---|---|---|
| Burning | Per-tick | Offensive | Flat fire damage per tick |
| Shocked | Shift-triggered | Offensive | At omen shift: sets is_stunned on the target — Action bucket blocked for their next turn; Support and Consumable buckets remain available |
| Exposed | Shift-triggered | Offensive | At omen shift: applies a `"vulnerable:physical"` StatusInstance to the target with `remaining_ticks` equal to the next omen cycle's timer value |
| Chilled | Per-tick | Offensive+Defensive | Creeping flat damage reduction per tick (amounts defined by omen card) |
| Poisoned | Per-tick | Offensive | Escalating poison damage (triples each tick); no vulnerability |
| Bleed | Per-tick | Offensive | Decaying physical damage per tick: deals damage equal to current stacks, then stacks halve (floor); clears when stacks reach 0 |
| Mending | Per-tick | Defensive | Heals X HP per tick |
| Hardened | Per-tick | Defensive | Absorbs up to X incoming damage per tick; resets each tick |
| Vulnerable | Passive | Offensive | Amplifies all damage of the specified type dealt to target by ×1.5 (see `HLD-COMBAT-007`); type carried in `string_param` on the StatusInstance (e.g. `"fire"`, `"physical"`, `"ice"`, `"lightning"`) |
| Type Convert | Passive | Offensive | Converts all outgoing damage from the unit to the type in `string_param`; only one instance active at a time — a new application replaces the existing one; clears at omen reset like all statuses |
| Emboldened | Passive | Offensive | Type carried in `string_param`. **Physical:** adds flat bonus to target's outgoing physical damage per hit (value defined in LLD). **Elemental (fire/lightning/ice):** multiplies target's outgoing damage of that type by ×1.5. |
| Frenzied | Passive | Offensive | Composite: unit simultaneously has `"vulnerable:physical"` effect (incoming ×1.5) and `"emboldened:physical"` effect (outgoing flat bonus); applied as one status |

Elemental statuses (Burning, Chilled) do **not** co-apply a Vulnerable status. Vulnerable must be applied separately via a dedicated item (see `HLD-COMBAT-007`) or via the Exposed shift trigger.

#### Scenario: Burning tick damage
- **WHEN** a unit has the Burning status and an omen tick occurs
- **THEN** the unit takes flat fire damage (amount defined in LLD)

#### Scenario: Shocked stun — Action bucket blocked only
- **WHEN** a unit has the Shocked status and the omen shift occurs
- **THEN** that unit's Action bucket is blocked for their next turn; Support and Consumable buckets remain available

#### Scenario: Exposed fires at shift — Vulnerable deferred to next cycle
- **WHEN** a unit has the Exposed status and the omen shift occurs
- **THEN** a `"vulnerable:physical"` StatusInstance is applied to that unit with remaining_ticks equal to the next omen cycle's timer value; the Exposed status is then cleared

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
- **WHEN** a unit has Emboldened with `string_param: "physical"` and makes a physical attack
- **THEN** the attack deals additional flat physical damage (value defined in LLD) on top of base damage

#### Scenario: Emboldened (Fire) multiplier
- **WHEN** a unit has Emboldened with `string_param: "fire"` and deals fire damage
- **THEN** the fire damage is multiplied by ×1.5

#### Scenario: Frenzied — both sides simultaneously
- **WHEN** a unit has the Frenzied status and makes a physical attack
- **THEN** the attack gains the `"emboldened:physical"` flat bonus; incoming physical attacks against that unit are amplified by ×1.5 via the `"vulnerable:physical"` effect

#### Scenario: Frenzied — single status, single clear
- **WHEN** a unit with the Frenzied status is cleansed of Frenzied
- **THEN** both the `"vulnerable:physical"` and `"emboldened:physical"` effects are removed simultaneously; they do not need to be cleared separately

#### Scenario: Type Convert — player side
- **WHEN** a Type Convert StatusInstance with `string_param: "fire"` is active on the player
- **THEN** all player attack damage is treated as fire damage; resistance and vulnerability checks at steps 5 and 6 use fire as the type

#### Scenario: Type Convert replacement
- **WHEN** the player already has Type Convert (fire) active and receives a Type Convert (ice) StatusInstance
- **THEN** the fire StatusInstance is replaced; the player's attacks now deal ice damage
