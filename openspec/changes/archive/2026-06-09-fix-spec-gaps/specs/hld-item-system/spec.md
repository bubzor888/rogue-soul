## MODIFIED Requirements

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
