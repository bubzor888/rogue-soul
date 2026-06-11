## Purpose
Defines all items available in the game: their categories, durability rules, damage baselines, floor-specific drop pools, and starting loadouts per vessel.
## Requirements
### Requirement: [LLD-ITEMS-001] Item Categories
> Canonical category rules defined in `HLD-ITEMS-004`. This requirement provides Floor 3 context and scenarios.

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
> Canonical durability rules defined in `HLD-ITEMS-005`. This requirement provides Floor 3 context and scenarios.

Durability items SHALL decrement charges according to their category:

- **Attack (Durability)**: loses 1 charge each time it is used in an attack action.
- **Support (Durability)**: loses 1 charge per encounter (once on room entry, regardless of turns).

Both break at zero charges if `breaks_at_zero: true`.

#### Scenario: Attack item per-use decrement
- **WHEN** a weapon with 6 charges is used 3 times across 2 combats
- **THEN** it has 3 charges remaining, regardless of how many combats occurred

#### Scenario: Support item per-encounter decrement
- **WHEN** a support durability item with 3 charges is carried through 3 rooms
- **THEN** it has 0 charges remaining and breaks, regardless of whether it was activated in those rooms

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

**Walking Staff** — Attack (Durability), Physical, damage: 6, charges: 6. Effect chain: `deal_damage { base_damage: 6, damage_type: physical }`.

**Spoiled Potion** — Consumable. Effect chain: `apply_status { status_id: "poisoned" }`. Applies Poisoned (see `HLD-COMBAT-006` for escalating damage mechanic; starting value X = 2).

**Worn Map** — Support (Durability), charges: 3, breaks_at_zero: true. Decrements 1 charge per encounter. Break effect: forces the next room to be a temporary companion encounter (Memory Fragment). Removed from inventory after triggering. Implements the encounter-countdown item system (see `HLD-ITEMS-003`).

#### Scenario: Walking Staff damage
- **WHEN** the Pilgrim uses the Walking Staff against an enemy
- **THEN** the enemy takes 6 physical damage (unmodified)

#### Scenario: Worn Map trigger
- **WHEN** the Worn Map's charges reach 0 (after 3 encounters)
- **THEN** the next room is replaced with a temporary companion encounter and the Worn Map is removed from inventory

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
| Fire Bomb | Applies Burning (5 fire damage/tick; see `HLD-COMBAT-006`) to one enemy |
| Ointment | Clears Burning or Poisoned from one target (see `LLD-ITEMS-001` for cleanse category rules) |
| Combustible Oil | Applies Vulnerable (Fire) ×1.5 to one enemy (see `HLD-COMBAT-007`); if target already Burning → flat fire damage burst instead (6 fire damage) |
| Hardening Resin | Applies Hardened to player (X = 3 damage absorbed/tick; see `HLD-COMBAT-006` for full effect) |

#### Scenario: Fire Bomb typical damage
- **WHEN** a player uses Fire Bomb and the timer card is 2 (typical)
- **THEN** the target takes 10 fire damage total (5/tick × 2 ticks)

#### Scenario: Combustible Oil branching
- **WHEN** a player uses Combustible Oil against a non-Burning enemy
- **THEN** the enemy gains Vulnerable (Fire) — no DoT applied

#### Scenario: Combustible Oil vs Burning enemy
- **WHEN** a player uses Combustible Oil against a Burning enemy
- **THEN** the enemy takes 6 flat fire damage; no additional vulnerability stacking

### Requirement: [LLD-ITEMS-008] Floor 3 Consumable Drop Pool — Elite Tier
The following consumables SHALL be in the elite drop pool for Floor 3:

| Item | Effect |
|---|---|
| Poultice | Applies Mending to player (X = 3 HP healed/tick; see `HLD-COMBAT-006` for full effect) |
| Brittle Charm | Applies Vulnerable (Physical) ×1.5 to one enemy (see `HLD-COMBAT-007`) |
| Frost Shard | Applies Chilled to one enemy (see `HLD-COMBAT-006` for damage reduction and Vulnerable (Ice) effect) |
| Fulminating Powder | Applies Shocked to one enemy (see `HLD-COMBAT-006` for stun timing) |

#### Scenario: Brittle Charm physical amplification
- **WHEN** a player applies Brittle Charm to an enemy and then uses a physical weapon
- **THEN** the weapon's physical damage is multiplied by ×1.5

#### Scenario: Fulminating Powder stun value
- **WHEN** Fulminating Powder is applied and the timer card drawn is 1 (shortest)
- **THEN** the stun occurs quickly — low timer cards are more valuable when Shocked is active (see HLD-COMBAT-006)

---

### Requirement: [LLD-ITEMS-009] Starting Items — The Drifter
The Drifter SHALL start every run with these three items (defined per `LLD-VESSELS-002`):

**Pocket of Sand** — Consumable, single use. Effect: Escape the current combat immediately with no rewards. Cannot be used in elite or boss encounters.

**Loaf of Bread** — Consumable, single use, floor-bound (removed at floor transition if unused; see `HLD-ITEMS-002`). Effect: Restores HP to the vessel. `[OPEN·MVP3]` heal amount to be set during playtesting relative to typical incoming damage per encounter.

**Lucky Paw** — Support (Durability), charges: 2, breaks_at_zero: true. Decrements 1 charge per encounter (per `LLD-ITEMS-002`). Effect: At the start of each combat while charges remain, applies the **Evasive** buff — a `[OPEN·MVP3]` % chance to dodge incoming physical attacks for that combat. Does not apply to elemental or magical damage types.

#### Scenario: Pocket of Sand — escape
- **WHEN** the player uses Pocket of Sand in a standard combat
- **THEN** the combat ends immediately; no post-combat rewards are awarded and the item is consumed

#### Scenario: Pocket of Sand — boss restriction
- **WHEN** the player attempts to use Pocket of Sand in an elite or boss encounter
- **THEN** the item cannot be activated

#### Scenario: Loaf of Bread — floor-bound
- **WHEN** the Drifter transitions from floor 2 to floor 3 with an unused Loaf of Bread
- **THEN** the Loaf of Bread is removed from inventory

#### Scenario: Lucky Paw — evasion applies at combat start
- **WHEN** a combat begins and the Lucky Paw has at least 1 charge remaining
- **THEN** the Evasive buff is applied before the first action; a physical attack has a chance to be dodged

---

### Requirement: [LLD-ITEMS-010] Starting Items — The Hedge Knight
The Hedge Knight SHALL start every run with these three items (defined per `LLD-VESSELS-003`):

**Battered Sword** — Attack (Durability), Physical. Stats: see `LLD-ITEMS-005` for base damage (7) and charge range (8–10). `[OPEN·MVP3]` exact starting charge count to be confirmed during playtesting.

**Iron Pendant** — Support (Durability), charges: 2, breaks_at_zero: true. Decrements 1 charge per encounter (per `LLD-ITEMS-002`). Effect: Replace the player's currently active fate omen with **Fortified** (take half damage from all attacks this omen cycle). The replaced omen is discarded. Fortified remains active for the rest of the current omen cycle. The Fortified omen is never placed in the fate deck — it only exists through pendant use. `[OPEN·MVP3]` exact damage reduction fraction and edge cases to be confirmed during playtesting.

**Cheap Flask** — Consumable, single use. Effect: Applies a combat buff to the vessel for the current encounter. `[OPEN·MVP3]` specific buff effect to be defined once the status effect system is fully designed.

#### Scenario: Iron Pendant — omen replacement
- **WHEN** the player activates the Iron Pendant
- **THEN** the currently active fate omen on the player's side is replaced by Fortified and the original omen is discarded

#### Scenario: Iron Pendant — Fortified not in deck
- **WHEN** the fate deck is assembled for any combat
- **THEN** the Fortified omen card is never included; it can only appear via Iron Pendant activation

#### Scenario: Battered Sword — normal drop equivalent
- **WHEN** the Hedge Knight uses the Battered Sword
- **THEN** it deals physical damage matching the normal-tier drop weapon standard (see `LLD-ITEMS-005`)

---

### Requirement: [LLD-ITEMS-011] Item Tier List
`[OPEN·MVP1]` All items in the game SHALL be assigned a tier value. The tier list is used by the Wandering Soul trade generation system to enforce tier-fair pairings (see `HLD-WS-006`) and by loot pool selection to distinguish normal-tier from elite-tier drops (see `HLD-COMBAT-012`, `HLD-COMBAT-013`).

#### Scenario: [OPEN·MVP1] Item tier list defined
- **WHEN** the item tier list is written
- **THEN** every item in `lld-items` has an assigned tier; the tier values are used by trade generation and loot pool systems at runtime

