
### Requirement: [LLD-ITEMS-001] Item Categories
Items SHALL belong to one of three functional categories determining their action bucket:

| Category | Action bucket | Limiting factor |
|---|---|---|
| Attack (Durability) | Attack — occupies the attack action | Charge count; breaks at zero |
| Support (Durability) | Support — free action, does not consume attack | Charge count; breaks at zero |
| Consumable | Consumable — free action, does not consume attack | Single use (max_charges: 1, breaks_at_zero: true) |

#### Scenario: Support item does not consume attack
- **WHEN** a player uses a Support item on their turn
- **THEN** they can still use an Attack item or ability in the same turn

---

### Requirement: [LLD-ITEMS-002] Durability Decrement
Durability items SHALL decrement by 1 charge per use — not per combat. A weapon used twice in one combat loses 2 charges.

#### Scenario: Per-use decrement
- **WHEN** a weapon with 6 charges is used 3 times across 2 combats
- **THEN** it has 3 charges remaining, regardless of how many combats occurred

---

### Requirement: [LLD-ITEMS-003] Damage Baseline
All item damage values SHALL be set relative to the following reference:

| Source | Damage per hit |
|---|---|
| Throw Rock (default strike) | 3 |
| Walking Staff (Pilgrim starting weapon) | 6 |
| Normal drop weapons | 7 |
| Elite drop weapons | 9 |
| Burst weapons (Cracked Cudgel / Iron Maul) | 9 / 10 |
| AoE weapons (Rope Flail / Spiked Chain) | 4 / 6 per target |

#### Scenario: Normal drop vs starting weapon
- **WHEN** a player picks up a normal drop weapon
- **THEN** it MUST deal more damage per hit than the Walking Staff (7 > 6)

---

### Requirement: [LLD-ITEMS-004] Floor 3 Starting Items — The Pilgrim
The Pilgrim SHALL start every run with these three items (defined per `LLD-VESSELS-001`):

**Walking Staff** — Attack (Durability), Physical, damage: 6, charges: 6. Effect chain: `deal_physical_damage { base_damage: 6, attack_type: MELEE }`.

**Spoiled Potion** — Consumable, Poison. Effect chain: `apply_status { status_id: "poisoned" }`.

**Worn Map** — Non-combat item. Counts down across encounters (counter: 3, decrements every encounter type). After 3 encounters, replaces the next room slot with a temporary companion encounter. Removed from inventory after triggering.

#### Scenario: Walking Staff damage
- **WHEN** the Pilgrim uses the Walking Staff against a front-row enemy
- **THEN** the enemy takes 6 physical damage (unmodified)

#### Scenario: Worn Map trigger
- **WHEN** the Worn Map counter reaches 0
- **THEN** the next room is replaced with a companion encounter and the Worn Map is removed from inventory

---

### Requirement: [LLD-ITEMS-005] Floor 3 Durability Drop Pool — Normal Tier
The following durability items SHALL be in the normal drop pool for Floor 3:

| Item | Category | Type | Damage | Charges | Property |
|---|---|---|---|---|---|
| Cracked Cudgel | Attack | Physical | 9 | 3 | High burst |
| Rope Flail | Attack | Physical | 4/hit | 6 | Hits all enemies |
| Battered Sword | Attack | Physical | 7 | 8–10 | — |
| Ember Shard | Attack | Fire | 7 | 3 | — |
| Spark Rod | Attack | Lightning | 7 | 3 | — |
| Frost Sliver | Attack | Ice | 7 | 3 | — |
| Small Amethyst | Support | — | — | 1 | Clears Shocked, Chilled, Vulnerable (Physical) |

#### Scenario: Rope Flail multi-target
- **WHEN** the player uses the Rope Flail against two enemies
- **THEN** both enemies take 4 physical damage simultaneously from a single charge

#### Scenario: Ember Shard vs Burning enemy
- **WHEN** the player uses Ember Shard against an enemy with the Burning status
- **THEN** the enemy takes 7 × 1.5 = ~11 fire damage (rounded per HLD-COMBAT-007)

---

### Requirement: [LLD-ITEMS-006] Floor 3 Durability Drop Pool — Elite Tier
The following durability items SHALL be in the elite drop pool for Floor 3:

| Item | Category | Type | Damage | Charges | Property |
|---|---|---|---|---|---|
| Iron Maul | Attack | Physical | 10 | 6 | High burst |
| Spiked Chain | Attack | Physical | 6/hit | 8 | Hits all enemies |
| Soldier's Blade | Attack | Physical | 9 | 10–12 | — |
| Smoldering Brand | Attack | Fire | 9 | 8 | — |
| Arc Wand | Attack | Lightning | 9 + 4 arc | 8 | Arcs to one additional enemy |
| Glacial Brand | Attack | Ice | 9 | 8+ | — |
| Medium Amethyst | Support | — | — | 2 | Clears Shocked, Chilled, Vulnerable (Physical) per charge |

#### Scenario: Arc Wand arc damage
- **WHEN** the player uses the Arc Wand against a primary target with a second enemy present
- **THEN** the primary takes 9 lightning damage and a second enemy takes 4 lightning damage from the arc

#### Scenario: Arc Wand with Shocked targets
- **WHEN** both enemies are Shocked and the player uses Arc Wand
- **THEN** primary takes 9 × 1.5 = ~14 lightning damage; arc target takes 4 × 1.5 = 6 lightning damage

---

### Requirement: [LLD-ITEMS-007] Floor 3 Consumable Drop Pool — Normal Tier
The following consumables SHALL be in the normal drop pool for Floor 3:

| Item | Effect |
|---|---|
| Fire Bomb | Applies Burning to one enemy (see HLD-COMBAT-006 for tick values) |
| Ointment | Clears Burning or Poisoned from one target |
| Combustible Oil | If target not Burning → Vulnerable (Fire) ×1.5; if target already Burning → flat fire damage burst (`[OPEN]` value: first pass 6) |
| Hardening Resin | Applies Hardened to player (absorbs 3 damage/tick) |

#### Scenario: Fire Bomb typical damage
- **WHEN** a player uses Fire Bomb and the timer card is 2 (typical)
- **THEN** the target takes 10 fire damage total (5/tick × 2 ticks) and is Vulnerable (Fire) ×1.5

#### Scenario: Combustible Oil branching
- **WHEN** a player uses Combustible Oil against a non-Burning enemy
- **THEN** the enemy gains Vulnerable (Fire) — no DoT applied

#### Scenario: Combustible Oil vs Burning enemy
- **WHEN** a player uses Combustible Oil against a Burning enemy
- **THEN** the enemy takes flat fire damage burst (value TBD); no additional vulnerability stacking

---

### Requirement: [LLD-ITEMS-008] Floor 3 Consumable Drop Pool — Elite Tier
The following consumables SHALL be in the elite drop pool for Floor 3:

| Item | Effect |
|---|---|
| Poultice | Applies Mending to player (heals 3 HP/tick) |
| Brittle Charm | Applies Vulnerable (Physical) ×1.5 to one enemy |
| Frost Shard | Applies Chilled to one enemy |
| Fulminating Powder | Applies Shocked to one enemy |

#### Scenario: Brittle Charm physical amplification
- **WHEN** a player applies Brittle Charm to an enemy and then uses a physical weapon
- **THEN** the weapon's physical damage is multiplied by ×1.5

#### Scenario: Fulminating Powder stun value
- **WHEN** Fulminating Powder is applied and the timer card drawn is 1 (shortest)
- **THEN** the stun occurs quickly — low timer cards are more valuable when Shocked is active (see HLD-COMBAT-006)
