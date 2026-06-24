## Purpose
Defines the playable vessels — their stats, abilities, bound companions, starting items, and omen contributions.

## Requirements

### Requirement: [LLD-VESSELS-001] The Pilgrim
The Pilgrim SHALL be the default starting vessel — the most eroded form of the soul. He is elderly, traveling on foot, on a pilgrimage he cannot fully explain. He has no companion.

**Base stats:** HP: 24.

**Starting items:** See `LLD-ITEMS-004`.

**Vessel omen card:** See `LLD-OMEN-CARD-006`.

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
The Drifter SHALL be a vessel representing an earlier, less eroded soul state — the companion path Tier 2 vessel.

**Base stats:** HP: 28.

**Bound companion:** The Ferret. The Ferret cannot be targeted, has no HP, and cannot be lost. It is simply present.

**Ferret passive — Scavenge:** At the start of each combat, the Ferret identifies a target and begins working. At the end of combat, a bonus item is added to the reward screen alongside the standard two post-combat drops — it is always taken, no choice required. The item is drawn from a consumable-weighted loot table with a rare chance of a weapon or support item; charges or durability may already be partially depleted. Loot table scales with encounter difficulty (standard, elite, boss). `[OPEN·MVP3]` Loot table composition, scaling ratios, and partial charge depletion ranges to be defined during encounter design.

**Ferret omen card:** See `LLD-OMEN-CARD-010`.

**Active ability — Hardy:** Clear one Hardy-clearable debuff or status effect from the vessel. Hardy covers conditions the vessel could plausibly shake off through resilience (weakness, vulnerability, slow, and similar); it does not cover conditions that would not respond to endurance. Charges: 3, replenished at floor start. `[OPEN·MVP3]` Hardy-clearable flag to be assigned to each debuff and status effect once the status effect system is fully designed.

**Starting items:** See `LLD-ITEMS-009`.

#### Scenario: Ferret Scavenge — bonus loot
- **WHEN** a combat encounter ends
- **THEN** a bonus item from the Ferret's loot table is added to the reward screen and automatically taken

#### Scenario: Hardy — clears debuff
- **WHEN** the player uses Hardy while the vessel has a Hardy-clearable debuff
- **THEN** one such debuff is removed from the vessel

---

### Requirement: [LLD-VESSELS-003] The Hedge Knight
The Hedge Knight SHALL be a vessel representing a combat-focused, solo soul state — the solo path Tier 2 vessel. No bound companion.

**Base stats:** HP: 32.

**Passive — Last Stand:** While the vessel's HP is below 25% of their maximum, all attacks deal ×1.5 damage. No charges. Always active when the condition is met.

**Active ability — Charge:** Double the damage of the next attack. The buff is consumed on the next attack whether it hits or misses. `[OPEN·MVP3]` Charge count to be set during playtesting once typical floor encounter count is established.

**Starting items:** See `LLD-ITEMS-010`.

**Vessel omen card:** See `LLD-OMEN-CARD-009`.

#### Scenario: Last Stand — damage amplification
- **WHEN** the Hedge Knight's HP is below 25% of maximum and they make an attack
- **THEN** that attack deals ×1.5 damage

#### Scenario: Last Stand + Charge combined
- **WHEN** the Hedge Knight uses Charge while Last Stand is active
- **THEN** the next attack deals ×3 damage (1.5× Last Stand × 2× Charge)

#### Scenario: Charge — buff consumed on miss
- **WHEN** the Hedge Knight uses Charge and the next attack misses
- **THEN** the Charge buff is consumed; no additional doubling on a subsequent attack

#### Scenario: Hedge Knight weapon familiarity
- **WHEN** the Hedge Knight finds a sword-type drop weapon
- **THEN** a narrative or mechanical recognition is triggered (e.g. "familiar" response in lore)
