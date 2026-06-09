## ADDED Requirements

### Requirement: [HLD-COMPANION-001] Two-Tier Companion System
The game SHALL support two companion types: Bound (persistent within a run, tied to specific vessel archetypes) and Summoned (conjured via expendable items, tactical burst allies).

| Type | Description | On Death |
|---|---|---|
| Bound | Comes with specific vessel archetypes. Persistent relationship tied to vessel lore. Travels the whole run. | Genuine loss — emotionally meaningful, run is weakened |
| Summoned | Conjured via expendable items. Echoes of defeated souls or wandering spirits. | Expected — pure resource management, no grief |

#### Scenario: Bound companion death weight
- **WHEN** a bound companion dies
- **THEN** the loss is permanent for the run and the run is mechanically weakened (not just a resource lost)

#### Scenario: Summoned companion death
- **WHEN** a summoned companion dies
- **THEN** the player loses the resource cost; no additional narrative consequence

---

### Requirement: [HLD-COMPANION-002] Companion HP and Death
Companions SHALL have their own HP pool and can die permanently within a run. There is no auto-revive.

#### Scenario: Companion takes damage
- **WHEN** a combat ability or enemy targets a companion
- **THEN** the companion's HP is reduced; if it reaches zero the companion dies and is removed for the rest of the run

---

### Requirement: [HLD-COMPANION-003] Bound Companion Revival
Exactly one expensive revival path SHALL exist for bound companions. Revival MUST be possible, rare, and cost something meaningful. The exact mechanism is unresolved.

#### Scenario: [OPEN] Revival mechanism
- **WHEN** the revival mechanism is designed
- **THEN** it MUST be accessible in-run, must be rare (not guaranteed), and must cost a meaningful resource (candidate: rare item drop, specific encounter event, sacrifice of vessel HP)

---

### Requirement: [HLD-COMPANION-004] Bound + Summoned Simultaneously
`[OPEN]` Whether a vessel with a bound companion can also have a summoned companion active at the same time is unresolved. This affects `GameState.summoned_companions` max size and whether the summon action is legal when a bound companion is alive.

#### Scenario: [OPEN] Simultaneous companion presence
- **WHEN** a vessel has an active bound companion
- **THEN** it must be decided whether summoning is permitted

---

### Requirement: [HLD-COMPANION-005] Row Assignment
Each companion has an independent row position (see `HLD-COMBAT-002`). Companion row is stored on UnitState within CombatState and on GameState.default_rows between combats — NOT on CompanionState.

#### Scenario: Companion row independence
- **WHEN** the bound companion is in the front row
- **THEN** the vessel may simultaneously be in the back row
