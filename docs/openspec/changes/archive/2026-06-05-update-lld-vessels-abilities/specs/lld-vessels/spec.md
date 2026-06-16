## MODIFIED Requirements

### Requirement: [LLD-VESSELS-002] The Drifter
The Drifter is a vessel representing an earlier, less eroded soul state — the companion path Tier 2 vessel.

**Base stats:** HP: 28.

**Bound companion:** The Ferret. The Ferret cannot be targeted, has no HP, and cannot be lost. It is simply present.

**Ferret passive — Scavenge:** At the start of each combat, the Ferret identifies a target and begins working. At the end of combat, a bonus item is added to the reward screen alongside the standard two post-combat drops — it is always taken, no choice required. The item is drawn from a consumable-weighted loot table with a rare chance of a weapon or support item; charges or durability may already be partially depleted. Loot table scales with encounter difficulty (standard, elite, boss). `[OPEN]` Loot table composition, scaling ratios, and partial charge depletion ranges to be defined during encounter design.

**Ferret omen card:** The Ferret contributes one omen card to the fate deck. When this card appears in a cycle it triggers a beneficial effect for the Drifter; the card is inert on the enemy side. `[OPEN]` Ferret omen card effect to be defined once the full omen card list is designed.

**Active ability — Hardy:** Clear one Hardy-clearable debuff or status effect from the vessel. Hardy covers conditions the vessel could plausibly shake off through resilience (weakness, vulnerability, slow, and similar); it does not cover conditions that would not respond to endurance. Charges: 3, replenished at floor start. `[OPEN]` Hardy-clearable flag to be assigned to each debuff and status effect once the status effect system is fully designed.

**Starting items:** See `LLD-ITEMS-009`.

#### Scenario: Ferret Scavenge — bonus loot
- **WHEN** a combat encounter ends
- **THEN** a bonus item from the Ferret's loot table is added to the reward screen and automatically taken

#### Scenario: Hardy — clears debuff
- **WHEN** the player uses Hardy while the vessel has a Hardy-clearable debuff
- **THEN** one such debuff is removed from the vessel

---

### Requirement: [LLD-VESSELS-003] The Hedge Knight
The Hedge Knight is a vessel representing a combat-focused, solo soul state — the solo path Tier 2 vessel. No bound companion.

**Base stats:** HP: 32.

**Passive — Last Stand:** While the vessel's HP is below 25% of their maximum, all attacks deal ×1.5 damage. No charges. Always active when the condition is met.

**Active ability — Charge:** Double the damage of the next attack. The buff is consumed on the next attack whether it hits or misses. `[OPEN]` Charge count to be set during playtesting once typical floor encounter count is established.

**Starting items:** See `LLD-ITEMS-010`.

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
