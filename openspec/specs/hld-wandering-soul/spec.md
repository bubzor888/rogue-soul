## Purpose
Defines the Wandering Soul room mechanic — trade offer structure, available trade types, HP guarantees, tier fairness, companion exclusion, and the post-elite generation guarantee.
## Requirements
### Requirement: [HLD-WS-001] Trade Offer Structure
The Wandering Soul SHALL present 2–3 trade offers simultaneously. All offers are fully revealed (both sides of every trade) before the player commits to anything. The player may accept any, all, or none.

#### Scenario: All offers visible before commitment
- **WHEN** the player enters a Wandering Soul room
- **THEN** all 2–3 trade offers are fully shown simultaneously; the player can evaluate all before accepting any

### Requirement: [HLD-WS-002] Available Trade Types
The following trade types SHALL be available:

| Offer type | Give | Receive |
|---|---|---|
| Item-for-item | A current inventory item | A different item (revealed) |
| Item-for-HP | A current inventory item | HP restoration (amount shown) |
| Consumable(s)-for-item | One or more consumables | A main item (revealed) |
| HP-for-item | A small HP cost | An item (revealed) |

#### Scenario: Trade accepted
- **WHEN** the player accepts a trade offer
- **THEN** the give side is removed from their inventory/HP and the receive side is added

#### Scenario: No trade taken
- **WHEN** the player declines all offers
- **THEN** their inventory and HP are unchanged; they exit the room with nothing gained or lost

---

### Requirement: [HLD-WS-003] HP-for-Item Always Present
The HP-for-item trade SHALL always be present as one of the 2–3 offers in every Wandering Soul encounter. A depleted player always has the option to spend health for something useful.

`[OPEN·MVP2]` HP cost values for all HP-based trades to be set once vessel HP pools are established.

#### Scenario: HP-for-item guaranteed
- **WHEN** a Wandering Soul encounter is generated
- **THEN** at least one of the offers is HP-for-item; this offer is never absent

---

### Requirement: [HLD-WS-004] Item-for-HP as Primary Healing Path
The Item-for-HP trade SHALL be the primary non-combat healing path. The HP restoration is meaningful — not a token top-up. The cost is real: the item is gone and the build is weaker for it.

`[OPEN·MVP2]` HP restoration values to be set once vessel HP pools are confirmed. Design intent: enough to matter to a damaged player, not enough to make selling items a default strategy.

#### Scenario: Meaningful HP restoration
- **WHEN** the player accepts an item-for-HP trade while at low HP
- **THEN** the HP restored is significant relative to max HP — not a token amount

---

### Requirement: [HLD-WS-005] No Currency
There is no currency in the game. All Wandering Soul trades SHALL be direct exchanges — item, consumable, or HP on each side. There is nothing to accumulate between encounters.

#### Scenario: No gold or currency
- **WHEN** the player interacts with a Wandering Soul
- **THEN** no currency token is gained, spent, or tracked; every transaction is a direct swap

---

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

---

### Requirement: [HLD-WS-007] No Companion Offers
Temporary companions are sourced exclusively from Memory Fragments and the Worn Map starting item. The Wandering Soul SHALL never offer a companion.

#### Scenario: Wandering Soul is trade-only
- **WHEN** a Wandering Soul encounter is generated
- **THEN** all 2–3 offers are item/HP trades only; no companion offer is generated

---

### Requirement: [HLD-WS-008] Post-Elite Guarantee
If the post-elite Wandering Soul cap has not been met naturally by the encounter slot immediately before the Judge, a Wandering Soul SHALL be guaranteed as one of the two door options at that slot. The guarantee is not communicated to the player — it is a discoverable pattern earned through play.

#### Scenario: Guaranteed pre-Judge Wandering Soul
- **WHEN** the player has not encountered a Wandering Soul in the post-elite phase
- **THEN** the final pre-Judge room slot always offers a Wandering Soul as one of two door options

#### Scenario: Guarantee does not collapse choice
- **WHEN** the Wandering Soul guarantee triggers
- **THEN** the player still chooses between the Wandering Soul and a combat encounter — it is not a single forced door

