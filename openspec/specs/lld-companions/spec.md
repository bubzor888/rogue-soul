## Purpose
Defines all companions in the game — temporary and bound — as LLD data entries. Each entry specifies the companion's mechanics, trigger, granted ability (if any), omen contributions, departure condition, and flavour text introduction. System mechanics are defined in `hld-companion-system`.
## Requirements
### Requirement: [LLD-COMP-001] The Raven (Floor 3 Temporary Companion)
**Type:** Temporary. **Source:** Floor 3 companion pool (`LLD-MF-009`). **Duration:** Until the Raven Mark ability is used, then departs immediately. If the ability is never used, departs after the floor boss.

**Granted ability — Raven Mark:**
- `action_bucket: "support"` — does not consume the Attack bucket
- `max_charges: 1`, `breaks_at_zero: false` (the companion departs rather than the ability breaking)
- **Target:** One non-elite, non-boss living enemy
- **Effect:** Apply the `"death_mark"` status to the target. The Death Mark status triggers at the next omen shift — the marked enemy dies instantly at that moment regardless of remaining HP.
- On use: The Raven departs immediately (before the omen shift occurs).

**Death Mark status behaviour:**
- Applied directly to `EnemyState.active_statuses` (not added to the omen deck)
- Resolves at the omen shift (same timing hook as Shocked stun, per `HLD-COMBAT-006`)
- The mark persists through healing — if the enemy is healed (e.g. by Grave Knit) after being marked, the mark still fires at the omen shift
- If the marked enemy is killed by other means before the omen shift, the Death Mark evaporates; no secondary effect
- Cannot be applied to elite enemies or the floor boss
- Cannot be cleansed (it is not a debuff; it is an execution scheduled to occur)

**Omen contributions:** None.

**Departure condition:** `"ability_used"` — departs the moment Raven Mark is used.

**Flavour text (offer):** *"A dark shape lands on your shoulder. It watches the road ahead with sharp, knowing eyes — waiting for you to point it somewhere."*

#### Scenario: Raven Mark kills at omen shift
- **WHEN** the player uses Raven Mark on an enemy and the omen shift occurs
- **THEN** the marked enemy dies instantly; The Raven has already departed

#### Scenario: Raven departs on use, not on kill
- **WHEN** the player uses Raven Mark
- **THEN** The Raven departs immediately; the Death Mark on the enemy persists until the omen shift regardless of the companion being gone

#### Scenario: Mark evaporates on early kill
- **WHEN** the player kills the marked enemy through normal damage before the omen shift
- **THEN** the Death Mark evaporates with no further effect; the Raven does not re-trigger

#### Scenario: Mark cannot target elite or boss
- **WHEN** the player uses Raven Mark
- **THEN** elite enemies and the floor boss are not valid targets; `get_legal_combat_actions()` filters them from the targetable set for this ability

#### Scenario: Raven unused before boss
- **WHEN** the floor boss is defeated and the player never used Raven Mark
- **THEN** The Raven departs at the floor transition; the unused ability has no effect

---

### Requirement: [LLD-COMP-002] The Shadow (Floor 3 Temporary Companion)
**Type:** Temporary. **Source:** Floor 3 companion pool (`LLD-MF-009`). **Duration:** Until cumulative drain total reaches 20 HP, then departs immediately (may be mid-combat). If the total is never reached, departs after the floor boss.

**Passive ability — Vampiric Drain:**
- `trigger: "turn_end"` — fires at the end of the player's turn, before enemy turns
- **Effect:** The Shadow drains 2 HP from its current target enemy. If the target has only 1 HP, it drains 1 HP (and kills them). The amount drained (1 or 2) is subtracted from `companion_timer`.
- **Target selection:** On activation, a random living enemy is selected and stored in `companion_context.current_target_instance_id`. The Shadow stays on that target until the target dies. On target death: if other living enemies remain, a new random target is selected immediately and stored in `companion_context`. If no living enemies remain, the ability does nothing that turn.
- **Departure sequence:** After each drain resolves → update companion_timer → if companion_timer ≤ 0, depart immediately. If drain killed the target and timer > 0 and other enemies remain, pick new random target.

**Initial timer:** `initial_timer: 20` on CompanionData. `CompanionState.companion_timer` starts at 20 and counts down.

**Omen contributions:** None.

**Departure condition:** `"timer_exhausted"` — departs when `companion_timer` reaches 0.

**Flavour text (offer):** *"Something cold and weightless settles beside you. You cannot see it clearly, but you sense it is hungry."*

#### Scenario: Shadow drains target each turn
- **WHEN** the player ends their turn and The Shadow is active with a living target
- **THEN** the target loses 2 HP (or 1 HP if only 1 remains); that amount is subtracted from companion_timer

#### Scenario: Shadow switches target on kill
- **WHEN** The Shadow's drain kills its current target and other living enemies remain
- **THEN** a new random living enemy is selected and stored in companion_context; draining continues next turn

#### Scenario: Shadow departs when timer exhausted
- **WHEN** companion_timer reaches 0 after a drain
- **THEN** The Shadow departs immediately, even if combat is ongoing

#### Scenario: Shadow drains only actual HP dealt
- **WHEN** The Shadow's target has 1 HP remaining
- **THEN** The Shadow drains 1 HP (killing the target); only 1 is subtracted from companion_timer, not 2

#### Scenario: Shadow does nothing when no living enemies
- **WHEN** The Shadow's turn_end trigger fires and all enemies are dead
- **THEN** no drain occurs; companion_timer is unchanged

---

### Requirement: [LLD-COMP-003] The Life Mote (Floor 3 Temporary Companion)
**Type:** Temporary. **Source:** Floor 3 companion pool (`LLD-MF-009`). **Duration:** Until the vessel's HP reaches 0 and the intercept fires. If this never occurs, departs after the floor boss.

**Passive ability — Vital Intercept:**
- `trigger: "vessel_death_intercept"` — fires synchronously when the vessel's HP reaches 0, before `unit_died` is emitted (see `HLD-COMPANION-003`)
- **Effect:** Restore the vessel's HP to 5. The Life Mote then departs immediately.
- **Activation source:** Fires regardless of what caused the vessel to reach 0 HP — direct attack, status effect tick (Burning, Poisoned), or any other HP-reducing effect.
- After the intercept fires, the vessel is alive at 5 HP; combat continues normally.

**Omen contributions:** None.

**Departure condition:** `"intercept_triggered"` — departs the moment the revive fires.

**Flavour text (offer):** *"A soft light drifts close, hovering just at the edge of sight. It asks nothing. It simply stays."*

#### Scenario: Life Mote prevents death from direct attack
- **WHEN** an enemy attack would reduce the vessel to 0 HP and The Life Mote is active
- **THEN** the intercept fires; vessel HP is set to 5; The Life Mote departs; `unit_died` is NOT emitted; combat continues

#### Scenario: Life Mote prevents death from status tick
- **WHEN** a Burning tick reduces the vessel to 0 HP and The Life Mote is active
- **THEN** the intercept fires; vessel HP is set to 5; The Life Mote departs

#### Scenario: Life Mote unused — departs after boss
- **WHEN** the floor boss is defeated and the vessel never reached 0 HP while The Life Mote was active
- **THEN** The Life Mote departs at the floor transition; it did not need to act

#### Scenario: Life Mote fires only once
- **WHEN** The Life Mote fires and the vessel later reaches 0 HP again in the same run
- **THEN** no intercept occurs — The Life Mote is already gone; the vessel dies normally
