## ADDED Requirements

### Requirement: [HLD-COMBAT-018] Magnitude-Additive Status Reapplication
Applying a magnitude-based status to a target that already has an active instance of that status SHALL increment the existing instance's `magnitude` by the new application's magnitude value, rather than creating a new StatusInstance or having no effect.

This rule applies to: **Burning**, **Poisoned**, and **Bleed**. It does NOT apply to Chilled, which is explicitly idempotent (see `HLD-COMBAT-015`).

**Burning:** reapplication adds to the fire damage dealt per tick.
**Poisoned:** reapplication adds to the current poison damage value (before the tripling escalation applies on that tick).
**Bleed:** reapplication adds to the current stack count.

The status's `remaining_ticks` is NOT changed by a reapplication — only `magnitude` is affected. The existing timer continues on its original schedule.

#### Scenario: Burning magnitude stacks on reapplication
- **WHEN** Burning with magnitude 2 is applied to a target that already has an active Burning StatusInstance with magnitude 3
- **THEN** the existing Burning StatusInstance's magnitude becomes 5; no new StatusInstance is created; remaining_ticks is unchanged

#### Scenario: Burning first application sets magnitude normally
- **WHEN** Burning is applied to a target that has no active Burning StatusInstance
- **THEN** a new Burning StatusInstance is created with the application's magnitude value and remaining_ticks from the omen timer

#### Scenario: Poisoned magnitude stacks on reapplication
- **WHEN** Poisoned with magnitude 2 is applied to a target that already has an active Poisoned StatusInstance with magnitude 6
- **THEN** the existing Poisoned StatusInstance's magnitude becomes 8; remaining_ticks is unchanged; the tripling escalation on the next tick will use 8 as the base

#### Scenario: Bleed stacks add on reapplication
- **WHEN** Bleed with magnitude 3 is applied to a target that already has an active Bleed StatusInstance with magnitude 4
- **THEN** the existing Bleed StatusInstance's magnitude becomes 7; the decay sequence resumes from 7 on the next tick

#### Scenario: Chilled reapplication remains idempotent
- **WHEN** Chilled is applied to a target that already has an active Chilled StatusInstance
- **THEN** no change occurs — Chilled is governed by `HLD-COMBAT-015`, not this rule
