## MODIFIED Requirements

### Requirement: [HLD-ITEMS-004] Item Categories and Action Buckets
Items SHALL belong to one of three functional categories determining their action bucket:

| Category | Action bucket | Limiting factor |
|---|---|---|
| Attack (Durability) | Attack — occupies the attack action | Charge count; breaks at zero |
| Support (Durability) | Support — free action, does not consume attack | Charge count; breaks at zero |
| Consumable | Consumable — free action, does not consume attack | Single use (max_charges: 1, breaks_at_zero: true) |

A player may use one Support or Consumable item without spending their attack action. Using an Attack item constitutes the player's attack for that turn.

#### Scenario: Support item does not consume attack
- **WHEN** a player uses a Support item on their turn
- **THEN** they can still use an Attack item or ability in the same turn

#### Scenario: Attack item is the turn's attack
- **WHEN** a player uses an Attack item
- **THEN** that item's damage resolves as the attack action; no separate ability attack can be made that turn
