## Purpose
Defines HLD rules for the item system — inventory size constraints, item lifecycle flags (floor-bound, encounter-countdown), how flagged items are communicated to the player, and the two-scale scoring model used for trade fairness.
## Requirements
### Requirement: [HLD-ITEMS-001] No Inventory Cap at MVP
The item inventory SHALL have no hard cap at MVP. The natural limiting factors are acquisition rate (items are found, not bought) and item charge counts (durability items eventually break). A cap MAY be introduced post-MVP once playtest data reveals whether inventory size becomes a UI or balance problem.

#### Scenario: No forced discard on pickup
- **WHEN** the player acquires an item from a loot choice or trade
- **THEN** the item is added to inventory regardless of how many items are already held

#### Scenario: Natural depletion limits inventory
- **WHEN** a durability item reaches zero charges
- **THEN** it breaks and is removed from inventory — the floor's acquisition rate, not a cap, determines practical inventory size

---

### Requirement: [HLD-ITEMS-002] Floor-Bound Item Flag
Items MAY carry a floor-bound flag. A floor-bound item SHALL be removed from the player's inventory at the floor transition if it has not been used before that point. The player SHALL be able to identify floor-bound items in inventory so they know which items expire at the transition. Removal is automatic and accompanied by a visible notification — the player is never silently surprised by a loss.

#### Scenario: Floor-bound item expires at transition
- **WHEN** the player completes a floor boss and transitions to the next floor with a floor-bound item still in inventory
- **THEN** the floor-bound item is removed and a notification informs the player of the loss

#### Scenario: Floor-bound item visible in inventory
- **WHEN** the player views their inventory during a run
- **THEN** any floor-bound items are visually marked as floor-bound — distinct from items that carry across floors

#### Scenario: Floor-bound item used before transition
- **WHEN** the player uses a floor-bound item before the floor transition
- **THEN** the item is consumed normally; no expiry notification occurs

---

### Requirement: [HLD-ITEMS-003] Encounter-Countdown Item System
Items MAY carry an encounter-countdown flag with a starting counter value. An encounter-countdown item SHALL:
- Decrement its counter by 1 after every completed encounter (combat, rest, non-combat — all types count; the Judge/boss encounter slot never triggers the counter)
- Replace the next regular encounter room with a specific triggered encounter when the counter reaches zero, rather than adding an extra room — total floor room count stays fixed
- Be removed from inventory after triggering
- Be acquirable only when enough non-boss encounters remain on the floor for the counter to reach zero naturally — this constraint is enforced at acquisition time, not at trigger time
- Display its current counter value visibly in inventory so the player can track when their triggered encounter will arrive

#### Scenario: Counter decrements on all encounter types
- **WHEN** the player completes any room (combat, rest, Memory Fragment, Wandering Soul)
- **THEN** the encounter-countdown item's counter decrements by 1

#### Scenario: Boss encounter does not decrement counter
- **WHEN** the player completes the floor boss encounter
- **THEN** no encounter-countdown item is triggered; boss slots are never replaced

#### Scenario: Counter reaching zero replaces next room
- **WHEN** an encounter-countdown item's counter reaches zero
- **THEN** the next room slot becomes the item's triggered encounter; the item is removed from inventory; no extra room is added to the floor

#### Scenario: Counter visible in inventory
- **WHEN** the player holds an encounter-countdown item
- **THEN** the current counter value is displayed on the item in inventory

---

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

### Requirement: [HLD-ITEMS-005] Durability Decrement Rules
Durability items SHALL decrement charges according to their category:

- **Attack (Durability)**: loses 1 charge each time it is used in an attack action
- **Support (Durability)**: loses 1 charge per encounter (once on room entry, regardless of turns taken or whether the item was activated)

Both break at zero charges if `breaks_at_zero: true`.

#### Scenario: Attack item per-use decrement
- **WHEN** a weapon with 6 charges is used 3 times across 2 combats
- **THEN** it has 3 charges remaining, regardless of how many combats occurred

#### Scenario: Support item per-encounter decrement
- **WHEN** a support durability item with 3 charges is carried through 3 rooms
- **THEN** it has 0 charges remaining and breaks, regardless of whether it was activated in those rooms

### Requirement: [HLD-ITEMS-006] Two Independent Item Scoring Scales
Items SHALL be valued on one of two independent scoring scales — Durability or Consumable — determined by their category. The two scales SHALL NOT be converted to a common scale at runtime. Trades and scenarios pair items from the same scale; cross-category pairings are designer-authored exceptions.

The purpose of the scoring system is to enable automated fair and unfair trade generation (Wandering Soul, Memory Fragment Category A and C) without requiring manual tier assignment for every item. Scores emerge compositionally from item properties.

See `LLD-IR-001` for scale definitions and reference points.

#### Scenario: Same-scale trade pairing
- **WHEN** the Wandering Soul system generates an item-for-item trade
- **THEN** both sides of the trade are drawn from the same scoring scale

#### Scenario: Cross-scale trade is designer-authored
- **WHEN** a Wandering Soul encounter or Memory Fragment includes a trade mixing a durability item with a consumable
- **THEN** that trade was manually authored by the designer, not generated by the scoring formula

---

### Requirement: [HLD-ITEMS-007] Compositional Item Scoring
Item value SHALL be calculated compositionally: an item's score is the sum of its independently scored properties, adjusted by scope and charges modifiers. A new item with shared properties automatically inherits consistent values without requiring manual re-evaluation of existing items.

See `LLD-IR-002` through `LLD-IR-007` for the full formula and scoring methods.

#### Scenario: Shared property inherits consistent value
- **WHEN** two different items both apply Vulnerable (Physical)
- **THEN** both items' scores include the same Vulnerable (Physical) base score contribution, without manual adjustment

---

### Requirement: [HLD-ITEMS-008] Competent Play Scoring Baseline
All item scores SHALL reflect **competent play value** — how much the item is worth when used at a reasonably optimised time, not at its theoretical ceiling and not at its floor. This baseline ensures scores remain stable across run variation and produce useful trade comparisons.

The competent play assumption means: status consumables are scored paired with a relevant attack; branching items are scored as the average of their branches; healing is scored assuming no over-heal; timer-2 is used as the statistical baseline for status durations.

See `LLD-IR-002` for the full competent-play scoring principles.

#### Scenario: Status consumable scored with paired action
- **WHEN** scoring a consumable that applies a status
- **THEN** the score includes the value of both the status and the attack the player makes on the same turn (defaulting to Throw Rock if no specific pairing is defined)

---

### Requirement: [HLD-ITEMS-009] Item Score Trade Fairness Tolerance
Same-category item-for-item trades SHALL be evaluated against a defined score tolerance window. A trade is considered **fair** when the score gap between the two items is no greater than 20% of the higher-scored item.

This tolerance applies to both Wandering Soul item-for-item trades and Memory Fragment Category A fair-trade scenarios.

See `LLD-IR-010` for the exact formula and Category C unfair trade threshold.

#### Scenario: Fair trade within tolerance
- **WHEN** two durability items with scores 40 and 49 are paired in a trade
- **THEN** the gap (9) is 18% of 49, which is within the ±20% tolerance — the trade is fair

#### Scenario: Unfair trade outside tolerance
- **WHEN** two durability items with scores 20 and 49 are paired in a trade
- **THEN** the gap (29) is 59% of 49, which exceeds the ±20% tolerance — the trade is not considered fair

---

### Requirement: [HLD-ITEMS-010] Cross-Category Trade Policy
Trades that exchange a durability item for a consumable (or vice versa) are cross-category trades. The scoring system defines no conversion ratio between the two scales. Cross-category trades SHALL be manually authored and playtested rather than generated by the formula.

Cross-category trades are permitted in Wandering Soul encounters and Memory Fragment scenarios but must be hand-designed.

#### Scenario: Cross-category trade requires manual authoring
- **WHEN** a Wandering Soul encounter offers a durability item in exchange for giving up a consumable
- **THEN** that trade was designed manually; the scoring formula was not used to determine fairness

---

### Requirement: [HLD-ITEMS-011] HP Conversion Concept
Item scores SHALL translate to HP values for item-for-HP and HP-for-item trades. The translation uses bucket tables — one per scale — so that players can intuitively understand that a stronger item is worth more HP.

HP amounts within each bucket are `[OPEN·MVP2]` pending vessel HP pool data and playtesting. See `LLD-IR-009` for the full bucket definitions.

#### Scenario: Item score determines HP offer
- **WHEN** the Wandering Soul generates an item-for-HP trade
- **THEN** the HP offered is drawn from the bucket corresponding to the item's score on its scale

---

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
