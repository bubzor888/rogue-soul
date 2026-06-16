## Purpose
Floor-specific data for the Memory Fragment system — category weights and scenario/companion pools per floor. System mechanics are defined in `hld-memory-fragments`.
## Requirements
### Requirement: [LLD-MF-007] Floor 3 Category Weights
The Memory Fragment category draw on Floor 3 SHALL use the following weights: **40% Category A / 40% Companion Encounter / 20% Category C**. See `HLD-MF-002` for the draw mechanic.

#### Scenario: Category C is least common
- **WHEN** Memory Fragment categories are drawn across multiple runs on Floor 3
- **THEN** Category C appears roughly half as often as Category A or Companion Encounter

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

### Requirement: [LLD-MF-009] Companion Encounter Pool (Floor 3)
The Companion Encounter pool for Floor 3 contains three temporary companions. When a companion encounter fires on Floor 3, one companion is drawn at random from this pool using the NAVIGATION RNG stream and offered to the player. See `HLD-MF-004` for the mandatory acceptance rule and one-per-floor limit.

All three companions are defined in `lld-companions` (`LLD-COMP-001`, `LLD-COMP-002`, `LLD-COMP-003`).

| Companion | Key mechanic | Departs when |
|---|---|---|
| The Raven | Grants a one-use active ability: mark one enemy for death at the next omen shift | Ability is used (departs immediately on use) |
| The Shadow | Drains 2 HP/turn from a random enemy; switches target on kill | Cumulative drain total reaches 20 HP |
| The Life Mote | Intercepts vessel death once; revives at 5 HP | Revive triggers |

**Flavour text introductions** (shown to player on offer; no mechanics disclosed):

- **The Raven**: *"A dark shape lands on your shoulder. It watches the road ahead with sharp, knowing eyes — waiting for you to point it somewhere."*
- **The Shadow**: *"Something cold and weightless settles beside you. You cannot see it clearly, but you sense it is hungry."*
- **The Life Mote**: *"A soft light drifts close, hovering just at the edge of sight. It asks nothing. It simply stays."*

#### Scenario: Companion pool draw
- **WHEN** a companion encounter fires on Floor 3
- **THEN** one companion is selected at random from the three pool entries using the NAVIGATION RNG stream; that companion is offered to the player

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

