## MODIFIED Requirements

### Requirement: [LLD-VESSELS-001] The Pilgrim
The Pilgrim is the default starting vessel — the most eroded form of the soul. He is elderly, traveling on foot, on a pilgrimage he cannot fully explain. He has no companion.

**Base stats:** HP: 24.

**Starting items:** See `LLD-ITEMS-004` for the full Pilgrim starting item definitions (Walking Staff, Spoiled Potion, Worn Map).

**Passive — Read the Road:** At the start of every combat, before the first omen cycle begins, look at the top 3 cards of the omen deck. Any number of them may be sent to the bottom of the deck. The remaining cards stay on top in their original order. Triggers automatically — no action required.

**Active ability — Good as New:** Reset the durability of one item to its maximum charge count. Has no effect on single-use items. Valid targets include weapons, support items, and Amethysts. Charges: 1, replenished at floor start.

#### Scenario: Read the Road — combat start
- **WHEN** a combat encounter begins
- **THEN** before the first omen cycle, the player sees the top 3 omen deck cards and may send any of them to the bottom

#### Scenario: Good as New — weapon reset
- **WHEN** the player uses Good as New on a weapon with 1 charge remaining
- **THEN** that weapon's charges are restored to its maximum

#### Scenario: Good as New — Amethyst valid target
- **WHEN** the player uses Good as New
- **THEN** an Amethyst is a valid target (not just weapons)

---

### Requirement: [LLD-VESSELS-002] The Drifter
The Drifter is a vessel representing an earlier, less eroded soul state — the companion path Tier 2 vessel. `[OPEN]` Full stats, active abilities, and companion assignment to be confirmed in a vessel design session.

**Passive — Read the Road:** Shared with the Pilgrim. At the start of every combat, before the first omen cycle begins, look at the top 3 cards of the omen deck. Any number of them may be sent to the bottom of the deck. The remaining cards stay on top in their original order. Triggers automatically — no action required.

#### Scenario: Read the Road — combat start
- **WHEN** a combat encounter begins
- **THEN** before the first omen cycle, the player sees the top 3 omen deck cards and may send any of them to the bottom

#### Scenario: [OPEN] Drifter active ability design
- **WHEN** the Drifter is implemented
- **THEN** their active abilities, companion (Ferret), and starting items must be defined in a vessel design session

---

### Requirement: [LLD-VESSELS-003] The Hedge Knight
The Hedge Knight is a vessel representing a combat-focused, solo soul state — the solo path Tier 2 vessel. `[OPEN]` Stats, abilities, and starting items to be confirmed in a vessel design session.

#### Scenario: Hedge Knight weapon familiarity
- **WHEN** the Hedge Knight finds a sword-type drop weapon
- **THEN** a narrative or mechanical recognition is triggered (e.g. "familiar" response in lore)

#### Scenario: [OPEN] Hedge Knight ability design
- **WHEN** the Hedge Knight is implemented
- **THEN** their full ability set must be defined in a vessel design session
