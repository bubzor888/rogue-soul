## ADDED Requirements

### Requirement: [HLD-ITEMS-012] Durability Item Subtypes
Durability items SHALL be classified into two named subtypes that determine their action bucket and decrement behaviour:

- **Attack (Durability)**: items that occupy the Attack action bucket; one charge consumed per use. In player-facing UI contexts, Attack (Durability) items SHALL be labelled **weapons**.
- **Support (Durability)**: items that occupy the Support action bucket; one charge consumed per encounter entered, regardless of activation. In player-facing UI contexts, Support (Durability) items SHALL be labelled **support items**.

See `HLD-ITEMS-004` for action bucket rules and `HLD-ITEMS-005` for decrement rules. This requirement provides the canonical subtype names and player-facing labels referenced by UI specs.

#### Scenario: Attack (Durability) item labelled as weapon in UI
- **WHEN** an Attack (Durability) item is displayed in any player-facing UI (loot screen, inventory, count strips)
- **THEN** it is referred to as a "weapon", not as "Attack (Durability)"

#### Scenario: Support (Durability) item labelled as support item in UI
- **WHEN** a Support (Durability) item is displayed in any player-facing UI
- **THEN** it is referred to as a "support item", not as "Support (Durability)"
