## MODIFIED Requirements

### Requirement: [HLD-COMBAT-010] Cleanse
The game SHALL support cleanse consumables that clear status effects by category. Cleanse items cover distinct status categories — no single item clears all statuses. The specific items and their category assignments are defined in `LLD-ITEMS-001`.

#### Scenario: Cleanse is category-scoped
- **WHEN** a player uses a cleanse consumable
- **THEN** only the status effects belonging to that item's category are cleared; statuses in other categories remain

#### Scenario: No universal cleanse
- **WHEN** the player has one cleanse consumable
- **THEN** they cannot clear all status effect categories in a single use

---

### Requirement: [HLD-COMBAT-011] Default Strike
Every vessel SHALL have access to a default strike that is always available with no charges and does not consume item durability. It serves as the guaranteed fallback for the Attack bucket.

#### Scenario: Always available
- **WHEN** a vessel has zero item charges remaining
- **THEN** the default strike is still available as a combat action

#### Scenario: No durability cost
- **WHEN** a vessel uses the default strike
- **THEN** no item durability is consumed

## REMOVED Requirements

_(none — the back-row open item in the Open Items section is removed as a stale note, not a formal requirement)_
