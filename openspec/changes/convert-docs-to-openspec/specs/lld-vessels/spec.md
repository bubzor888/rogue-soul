## ADDED Requirements

### Requirement: [LLD-VESSELS-001] The Pilgrim
The Pilgrim is the default starting vessel — the most eroded form of the soul. He is elderly, traveling on foot, on a pilgrimage he cannot fully explain. He has no companion. Full narrative and ability detail in `docs/vessels/vessel_pilgrim.md`.

**Base stats:** HP: 24. Item slots: see `HLD-VESSEL-005`.

**Starting items:** Walking Staff (Attack, 6 damage, 6 charges, Physical), Spoiled Potion (Consumable, applies Poisoned), Worn Map (Non-combat, triggers companion encounter after 3 encounters).

**Active ability — Good as New:** Resets one durability item to maximum charges. Valid targets include weapons, support items, and Amethysts. Single use per run (or per floor — see vessel doc).

**Passive:** `[OPEN]` Pilgrim passive ability to be confirmed.

#### Scenario: Good as New — weapon reset
- **WHEN** the player uses Good as New on a weapon with 1 charge remaining
- **THEN** that weapon's charges are restored to its maximum

#### Scenario: Good as New — Amethyst valid target
- **WHEN** the player uses Good as New
- **THEN** an Amethyst is a valid target (not just weapons)

---

### Requirement: [LLD-VESSELS-002] The Drifter
The Drifter is a vessel representing an earlier, less eroded soul state. Full narrative and ability detail in `docs/vessels/vessel_drifter.md`. `[OPEN]` Stats, abilities, companion assignment, and unlock condition to be confirmed.

#### Scenario: [OPEN] Drifter ability design
- **WHEN** the Drifter is implemented
- **THEN** their abilities and companion situation must be defined in a vessel design session

---

### Requirement: [LLD-VESSELS-003] The Hedge Knight
The Hedge Knight is a vessel representing a combat-focused soul state, carrying a sword as their primary identity. Full narrative and ability detail in `docs/vessels/vessel_hedge_knight.md`. `[OPEN]` Stats, abilities, companion assignment, and unlock condition to be confirmed.

#### Scenario: Hedge Knight weapon familiarity
- **WHEN** the Hedge Knight finds a sword-type drop weapon
- **THEN** a narrative or mechanical recognition is triggered (e.g. "familiar" response in lore)

#### Scenario: [OPEN] Hedge Knight ability design
- **WHEN** the Hedge Knight is implemented
- **THEN** their full ability set must be defined in a vessel design session
