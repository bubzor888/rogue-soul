## MODIFIED Requirements

### Requirement: [LLD-ARCH-017] GameState and Domain Entities

**NavigationState** — add one field:

| Field | Type | Notes |
|---|---|---|
| `companion_offered_this_floor` | bool | True once any companion encounter has fired this floor (Worn Map or MF); blocks further companion draws from MF pool |

**CompanionState** — add two fields:

| Field | Type | Notes |
|---|---|---|
| `companion_timer` | int | Generic countdown for companions with a budget (e.g. Shadow's 20 HP drain limit). Starting value copied from `CompanionData.initial_timer` at companion activation. -1 = not used by this companion. Decremented by CombatResolver when the companion's timer-consuming effect fires. Companion departs when this reaches 0. |
| `companion_context` | Dictionary | Companion-specific runtime state not covered by the standard fields (e.g. Shadow's `{ "current_target_instance_id": "wolf_0" }`). Read and written by the companion's handler chain. |

---

### Requirement: [LLD-ARCH-018] Data Resource Schemas

**CompanionData** — add two fields:

| Field | Type | Notes |
|---|---|---|
| `granted_ability_id` | String | ability_id of the active ability granted to the vessel while this companion is active. Empty string if this companion grants no active ability. Loaded from AbilityRegistry at startup. |
| `initial_timer` | int | Starting value for `CompanionState.companion_timer`. 0 = this companion does not use the timer. |

**`departure_trigger`** field added to CompanionData:

| Field | Type | Notes |
|---|---|---|
| `departure_trigger` | String | The condition that causes the companion to depart. Values: `"ability_used"` (departs when granted ability is used), `"timer_exhausted"` (departs when companion_timer reaches 0), `"intercept_triggered"` (departs after vessel_death_intercept fires), `"after_boss_only"` (no mid-floor condition; departs only at floor transition). |

---

### Requirement: [LLD-ARCH-019] CombatResolver

**`get_legal_combat_actions` — companion granted ability injection:**
If an active companion (bound or temporary) has a non-empty `granted_ability_id`, the corresponding AbilityData is included in legal actions. The ability uses its configured `action_bucket`. Companions with `departure_trigger: "ability_used"` depart when this action is resolved.

**`vessel_death_intercept` hook:**
Before emitting `unit_died` for the vessel, CombatResolver SHALL check whether an active companion has `trigger == "vessel_death_intercept"`. If found:
1. Run the companion's handler chain (e.g. restore vessel HP to 5)
2. Depart the companion (set `temporary_companion` or `bound_companion` to null in GameState)
3. Do NOT emit `unit_died`; the damage event resolves normally with the vessel alive at restored HP

This check is synchronous in the damage resolution path — not signal-driven. It runs regardless of what reduced the vessel to 0 HP (direct attack, status tick, companion drain, etc.).

**`resolve_companion_trigger` — timer decrement:**
When a `"turn_end"` companion fires and its handler chain includes a timer-consuming effect, CombatResolver decrements `CompanionState.companion_timer` by the amount consumed (capped at actual effect — e.g. if enemy has only 1 HP, only 1 is drained and only 1 is subtracted from the timer). After decrement, if `companion_timer <= 0` and `departure_trigger == "timer_exhausted"`, the companion departs.

#### Scenario: Companion granted ability in legal actions
- **WHEN** the vessel has an active companion with `granted_ability_id: "raven_mark"`
- **THEN** `get_legal_combat_actions()` includes the Raven Mark ability action; it uses the Support bucket

#### Scenario: vessel_death_intercept fires on status tick death
- **WHEN** Burning tick damage reduces the vessel to 0 HP while The Life Mote is active
- **THEN** the intercept fires, vessel HP is set to 5, Life Mote departs, `unit_died` is NOT emitted

#### Scenario: Shadow timer depletes and companion departs mid-fight
- **WHEN** The Shadow's `companion_timer` reaches 0 during a turn_end drain
- **THEN** The Shadow departs immediately; it does not wait for the fight to end
