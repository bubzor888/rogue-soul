## MODIFIED Requirements

### Requirement: [LLD-MF-008] Category A Trade Generation (Floor 3)
Category A (Fair Trade) encounters on Floor 3 SHALL generate their trade offer at runtime using item ranking scores from `LLD-IR-011`. No hand-authored scenario pool is required. The generator SHALL produce a trade pair that satisfies the ±20% fair tolerance defined in `LLD-IR-010`.

Both sides of the trade SHALL come from the same scoring scale (Durability or Consumable). Valid trade forms are:
- Item-for-item: one item from the player's inventory paired with one item from the floor drop pool at matching score range
- Item-for-HP: player item converted to HP using the bucket table from `LLD-IR-009`
- HP-for-item: a fair HP cost to receive an item from the floor drop pool

The narrative context explaining why the trade is offered is decoupled from trade contents and is a MVP2 concern. The generator produces only the mechanical trade; the UI layer wraps it in flavour text.

See `HLD-MF-003` for the category mechanic (both options revealed, walk away available).

#### Scenario: Fair item-for-item trade generated
- **WHEN** the Category A generator runs and both the player inventory and floor drop pool contain items on the same scale
- **THEN** the generator selects a player item and a pool item whose scores satisfy `|score_A - score_B| ≤ 0.20 × max(score_A, score_B)` per `LLD-IR-010`

#### Scenario: Item-for-HP trade generated
- **WHEN** the Category A generator produces an item-for-HP offer
- **THEN** the HP restoration amount is determined by the player item's score bucket per `LLD-IR-009`

#### Scenario: No valid pairing available
- **WHEN** the generator cannot find a same-scale pair within tolerance (e.g. player has only one item and it has no pool counterpart in range)
- **THEN** the generator falls back to an item-for-HP trade using the player's highest-scored item

---

### Requirement: [LLD-MF-010] Category C Trade Generation (Floor 3)
Category C (Unfair Trade) encounters on Floor 3 SHALL generate their two-option structure at runtime using item ranking scores from `LLD-IR-011`. No hand-authored scenario pool is required. The generator SHALL be inventory-aware — it reads the player's current inventory to select the cost item for Option 1, making the cost feel personally relevant.

**Option 1 — Bad deal:** The generator selects an item from the player's inventory as the cost. The reward offered SHALL score no more than `cost_score ÷ 1.7` (i.e. the cost exceeds the reward by at least 50% above the fair tolerance window, per `LLD-IR-010`). The reward is drawn from the floor drop pool.

**Option 2 — Cut your losses:** The generator selects a loss for the player (HP or a lower-valued item) whose cost is strictly less than Option 1's cost. Option 2 must be genuinely tempting — if it is obviously inferior to Option 1, the generator SHALL reselect.

The narrative context explaining the fragment's "grip" on the player is decoupled from trade contents and is a MVP2 concern.

See `HLD-MF-005` for the category mechanic (no walk-away, both options cost something, Option 2 must be tempting).

#### Scenario: Inventory-aware Option 1 cost selection
- **WHEN** a Category C encounter is generated
- **THEN** the generator reads the player's current inventory and selects the Option 1 cost item from it, not from a fixed scenario list

#### Scenario: Option 1 reward is unfair
- **WHEN** the generator assigns the Option 1 reward
- **THEN** the reward's score SHALL satisfy `reward_score ≤ cost_score ÷ 1.7`, confirming the cost exceeds the reward by at least 50% above the ±20% fair tolerance window

#### Scenario: Option 2 is strictly cheaper than Option 1
- **WHEN** the generator assigns Option 2
- **THEN** Option 2's cost (in HP or item score) SHALL be strictly less than Option 1's cost, making it a real strategic alternative

#### Scenario: Player has only one item
- **WHEN** the generator runs and the player has exactly one item in inventory
- **THEN** Option 1 uses that item as the cost; Option 2 uses an HP loss as the cut-your-losses cost
