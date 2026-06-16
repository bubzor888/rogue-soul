## MODIFIED Requirements

### Requirement: [HLD-COMPANION-001] Two-Tier Companion System
The game SHALL support two companion types: Bound (persistent for the whole run, tied to specific vessel archetypes) and Temporary (found in Memory Fragment rooms, floor-scoped).

| Type | Source | Duration | Action model |
|---|---|---|---|
| Bound | Comes with specific vessel archetypes. Persistent relationship tied to vessel lore. | Entire run | Passive — acts automatically each turn without player input |
| Temporary | Discovered in Memory Fragment rooms. Echoes of wandering spirits. | Until end of current floor (including floor boss) | Passive — acts automatically each turn without player input |

#### Scenario: Bound companion persists
- **WHEN** a vessel with a bound companion completes a floor
- **THEN** the bound companion carries over to the next floor unchanged

#### Scenario: Temporary companion departs at floor end
- **WHEN** the player clears the floor boss
- **THEN** any active temporary companion departs; it does not carry over to the next floor

#### Scenario: Companion acts automatically
- **WHEN** the player ends their turn
- **THEN** any active companions resolve their automatic actions without player input

---

### Requirement: [HLD-COMPANION-004] Temporary Companion Limit
The player SHALL have at most one temporary companion active at a time. If the player encounters a second temporary companion while one is already active, they MUST choose which to keep. The unchosen companion does not join.

#### Scenario: Replacement choice
- **WHEN** the player discovers a temporary companion and already has one active
- **THEN** they are presented with a choice: keep the current companion or replace it with the new one

#### Scenario: One at a time enforced
- **WHEN** the player chooses a new temporary companion
- **THEN** the previous temporary companion immediately departs

## REMOVED Requirements

### Requirement: [HLD-COMPANION-002] Companion HP and Death
**Reason**: Bound companions no longer have an HP pool or can die. Temporary companions depart at floor end rather than dying. The HP/death model has been removed from the companion system entirely.
**Migration**: Remove companion HP tracking from CombatState and GameState. Remove any targeting logic that treats companions as damageable units.

---

### Requirement: [HLD-COMPANION-003] Bound Companion Revival
**Reason**: Revival is no longer needed — bound companions cannot die.
**Migration**: Remove any revival mechanic, item, or encounter event tied to bound companion revival.

---

### Requirement: [HLD-COMPANION-005] Row Assignment
**Reason**: The row system (HLD-COMBAT-002/003) was removed. Companion row assignment no longer has any purpose.
**Migration**: Remove companion row storage from UnitState and GameState.default_rows.
