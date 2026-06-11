## Purpose
Defines the two-tier companion system — bound companions (persistent for the run, tied to specific vessels) and temporary companions (floor-scoped, sourced from non-combat events) — including the companion limit, replacement rules, and automatic action model.
## Requirements
### Requirement: [HLD-COMPANION-001] Two-Tier Companion System
The game SHALL support two companion types: Bound (persistent for the whole run, tied to specific vessel archetypes) and Temporary (found in Memory Fragment rooms or via starting item beats, floor-scoped).

| Type | Source | Duration | Action model |
|---|---|---|---|
| Bound | Comes with specific vessel archetypes. Persistent relationship tied to vessel lore. | Entire run | Passive — acts automatically each turn without player input; may also grant the player an active ability |
| Temporary | Discovered in Memory Fragment rooms or triggered by starting item beats (e.g. Worn Map). Echoes of wandering spirits. | Until their departure condition is met, or after the floor boss if the condition was never triggered | Passive — acts automatically on trigger without player input; may also grant the player an active ability |

**Temporary companion departure model:** Each temporary companion has a specific departure condition (e.g. ability used, timer exhausted, revive triggered). When that condition is met the companion departs immediately — this may happen mid-combat or mid-floor. If the condition is never triggered before the boss is defeated, the companion departs at the floor transition.

#### Scenario: Bound companion persists
- **WHEN** a vessel with a bound companion completes a floor
- **THEN** the bound companion carries over to the next floor unchanged

#### Scenario: Temporary companion departs on condition
- **WHEN** a temporary companion's departure condition is met mid-combat
- **THEN** the companion departs immediately; it does not wait for the fight or floor to end

#### Scenario: Temporary companion departs after boss if unused
- **WHEN** the floor boss is defeated and a temporary companion's departure condition was never triggered
- **THEN** the companion departs at the floor transition

#### Scenario: Companion may grant an active ability
- **WHEN** a companion with a granted ability is active
- **THEN** that ability appears in the player's legal combat actions; using it consumes the grant (the ability is removed from legal actions after use)

### Requirement: [HLD-COMPANION-003] Companion Trigger Types
Companions SHALL support the following trigger types. Each type defines when the companion's handler chain fires relative to the combat loop.

| Trigger ID | When it fires | Notes |
|---|---|---|
| `"turn_end"` | End of the player's turn, before enemy turns | Standard passive trigger; fires every turn the companion is active |
| `"vessel_death_intercept"` | Synchronously when the vessel's HP reaches 0, before `unit_died` is emitted | One-time intercept; if the companion's handler chain resolves, `unit_died` is NOT emitted for that damage event |

The `"vessel_death_intercept"` trigger is checked by CombatResolver as a synchronous first-class step in the damage resolution path (see `LLD-ARCH-019`). It is not signal-driven. If an active companion has this trigger and the vessel reaches 0 HP, the handler chain runs and may restore HP — preventing death. The companion then departs.

#### Scenario: turn_end companion fires before enemies
- **WHEN** the player ends their turn
- **THEN** all active companions with `trigger == "turn_end"` fire their handler chains in sequence, then enemy turns resolve

#### Scenario: vessel_death_intercept prevents death
- **WHEN** the vessel takes damage that would reduce HP to 0 and an active companion has `trigger == "vessel_death_intercept"`
- **THEN** the companion's handler chain runs (e.g. restores HP to 5); `unit_died` is NOT emitted; the companion departs immediately after

---

### Requirement: [HLD-COMPANION-004] Temporary Companion Limit
The player SHALL have at most one temporary companion active at a time. If the player encounters a second temporary companion while one is already active, they MUST choose which to keep. The unchosen companion does not join.

#### Scenario: Replacement choice
- **WHEN** the player discovers a temporary companion and already has one active
- **THEN** they are presented with a choice: keep the current companion or replace it with the new one

#### Scenario: One at a time enforced
- **WHEN** the player chooses a new temporary companion
- **THEN** the previous temporary companion immediately departs

