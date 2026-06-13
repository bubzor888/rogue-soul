## ADDED Requirements

### Requirement: [HLD-RUN-007] Item Burden Score
The run state SHALL track a persistent integer measuring the soul's accumulated burden from items carried. This score persists across floors with no reset and is initialized at run start from the vessel's starting loadout.

**Accumulation rules:**

| Event | Delta |
|---|---|
| Run starts — per starting item in vessel loadout | +1 |
| Any item acquired during the run | +2 |
| Any item fully spent (consumable used, durability exhausted to 0, or item discarded) | −1 |

Starting items are valued at +1 rather than +2 so that shedding a starting item yields net zero — the soul arrived with it and released it entirely, leaving no burden. A floor-acquired item that is fully spent yields net +1.

The score is not directly visible to the player as a number. Its effects are communicated through encounter behavior and narrative framing at key thresholds. Systems that consume this score (such as boss encounters) define their own tier brackets and behavior in LLD.

#### Scenario: Score initialized from starting items
- **WHEN** a run begins with a vessel that has 2 starting items
- **THEN** the burden score is initialized to 2 (1 per starting item)

#### Scenario: Item acquired increases score
- **WHEN** the player takes any item from a loot choice, trade, or other acquisition during the run
- **THEN** the burden score increases by 2

#### Scenario: Item fully spent decreases score
- **WHEN** a consumable is used, a durability item is exhausted to 0 charges, or an item is discarded via an encounter effect
- **THEN** the burden score decreases by 1

#### Scenario: Starting item shed yields net zero
- **WHEN** a vessel's starting item (initialized at +1) is fully spent or discarded
- **THEN** the burden score decreases by 1; the net contribution of that item across the run is 0

#### Scenario: Score persists across floors
- **WHEN** the player completes a floor and transitions to the next
- **THEN** the burden score carries forward unchanged; no reset occurs
