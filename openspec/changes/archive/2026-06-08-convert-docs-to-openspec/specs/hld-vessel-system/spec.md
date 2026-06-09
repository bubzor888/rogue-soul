## ADDED Requirements

### Requirement: [HLD-VESSEL-001] Vessel as Class
The vessel the soul inhabits each run IS the class system. Vessels are chosen before the run from the pool the soul has unlocked. Each vessel has a fixed set of base abilities that do not change during the run.

#### Scenario: No in-run class building
- **WHEN** the player is mid-run
- **THEN** the vessel's base abilities cannot be changed, replaced, or upgraded

#### Scenario: Variable layer
- **WHEN** the player builds their loadout
- **THEN** variability comes from the item inventory and companion — not from the vessel's fixed abilities

---

### Requirement: [HLD-VESSEL-002] Vessel Identity
A vessel is a recently-deceased person, not a class archetype. Their circumstances at death define their capabilities. Each vessel has a name, lore, and a specific set of abilities reflecting who they were in life.

#### Scenario: Vessel is a person
- **WHEN** a vessel is presented in the selection screen
- **THEN** the vessel has a name, a cause of death, and a lore fragment — not just a class label

---

### Requirement: [HLD-VESSEL-003] Vessel Unlock Conditions
Vessels SHALL be unlocked by experience conditions (what the soul has lived), not by currency. Each vessel has a defined unlock condition evaluated against run history.

#### Scenario: Experience-gated unlock
- **WHEN** a player meets a vessel's unlock condition (e.g. completing a run, dying in a specific way)
- **THEN** the vessel becomes available in the selection pool without any currency transaction

---

### Requirement: [HLD-VESSEL-004] MVP Vessel Count
`[OPEN]` Minimum 3 vessels ship with MVP. Suggested: one vessel with a bound companion, one without, one with summoning focus. Specific unlock conditions per vessel require a dedicated vessel design session.

#### Scenario: [OPEN] Vessel count at MVP
- **WHEN** MVP ships
- **THEN** at least 3 vessels are available (one unlocked by default; others unlocked by conditions)

---

### Requirement: [HLD-VESSEL-005] Item Slot Count
Each vessel definition SHALL specify its item slot count (`item_slot_count`). A global `MAX_ITEM_SLOTS` constant defines the ceiling. See `HLD-ARCH-004` (T-4).

#### Scenario: [OPEN] Item slot configuration
- **WHEN** vessel data is defined
- **THEN** `item_slot_count` is set per vessel and may vary between vessels

---

### Requirement: [HLD-VESSEL-006] Solo Vessel Archetype
A vessel with no bound companion SHALL be a valid archetype with compensating advantages — not a punishment. Compensating advantages may include additional item slots, stronger summoning abilities, or passives that only apply when unaccompanied.

#### Scenario: Solo vessel parity
- **WHEN** a player selects a solo vessel
- **THEN** the vessel has compensating advantages that make it a different playstyle, not a strictly harder one

---

### Requirement: [HLD-VESSEL-007] Vessel Narrative Tree
The three MVP vessels (Pilgrim, Drifter, Hedge Knight) SHALL be narrative endpoints representing different degrees of soul erosion, not progression tiers. The Pilgrim is the most eroded. The soul's history is revealed through their lore fragments. Full vessel narrative design in `docs/soul_protocol_narrative.md`.

#### Scenario: Narrative connection
- **WHEN** a player reads vessel lore fragments
- **THEN** the fragments collectively suggest the soul's history across multiple lifetimes
