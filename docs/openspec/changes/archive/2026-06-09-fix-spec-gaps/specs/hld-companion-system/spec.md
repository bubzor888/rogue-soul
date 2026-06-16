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
