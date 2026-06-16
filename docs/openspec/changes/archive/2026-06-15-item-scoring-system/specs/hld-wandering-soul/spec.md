## MODIFIED Requirements

### Requirement: [HLD-WS-006] Trade Score Fairness
Item-for-item trades SHALL pair items from the same scoring scale within the score tolerance window. A strong item is offered for a strong item; a weak item for a weak item. The player should never look at a trade and feel they are being robbed.

**Fair trade rule:** The score gap between the two items SHALL NOT exceed 20% of the higher-scored item. See `LLD-IR-010` for the exact formula and `LLD-IR-011` for all item scores.

Both items in the trade must come from the same scale (Durability or Consumable). Cross-category pairings (durability item for consumable) are designer-authored exceptions, not generated (see `HLD-ITEMS-010`).

#### Scenario: Same-scale fair pairing
- **WHEN** an item-for-item trade is generated
- **THEN** both items are from the same scoring scale and their scores fall within the ±20% tolerance window of the higher-scored item

#### Scenario: Cross-category trade is manual
- **WHEN** a Wandering Soul encounter includes a durability item offered in exchange for a consumable
- **THEN** that trade was manually authored; the score tolerance formula was not applied to determine fairness
