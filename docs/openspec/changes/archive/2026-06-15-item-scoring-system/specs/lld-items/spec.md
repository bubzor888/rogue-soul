## MODIFIED Requirements

### Requirement: [LLD-ITEMS-005] Floor 3 Durability Drop Pool — Normal Tier
The following durability items SHALL be in the normal drop pool for Floor 3:

| Item | Category | Type | Damage | Charges | Property |
|---|---|---|---|---|---|
| Cracked Cudgel | Attack | Physical | 9 | 3 | High burst |
| Rope Flail | Attack | Physical | 4/hit | 6 | Hits all enemies |
| Battered Sword | Attack | Physical | 7 | 8 | — |
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

#### Scenario: Battered Sword charge count
- **WHEN** the Hedge Knight's starting Battered Sword appears in the normal drop pool
- **THEN** it has 8 charges (matching the Hedge Knight starting item definition in `LLD-ITEMS-010`)

---

### Requirement: [LLD-ITEMS-006] Floor 3 Durability Drop Pool — Elite Tier
The following durability items SHALL be in the elite drop pool for Floor 3:

| Item | Category | Type | Damage | Charges | Property |
|---|---|---|---|---|---|
| Iron Maul | Attack | Physical | 10 | 6 | High burst |
| Spiked Chain | Attack | Physical | 6/hit | 8 | Hits all enemies |
| Soldier's Blade | Attack | Physical | 9 | 10 | — |
| Smoldering Brand | Attack | Fire | 9 | 8 | — |
| Arc Wand | Attack | Lightning | 9 + 4 arc | 8 | Arcs to one additional enemy |
| Glacial Brand | Attack | Ice | 9 | 8 | — |
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
| Frost Shard | Applies Chilled to one enemy (see `HLD-COMBAT-006` for damage reduction effect) |

#### Scenario: Fire Bomb typical damage
- **WHEN** a player uses Fire Bomb and the timer card is 2 (typical)
- **THEN** the target takes 10 fire damage total (5/tick × 2 ticks)

#### Scenario: Combustible Oil branching
- **WHEN** a player uses Combustible Oil against a non-Burning enemy
- **THEN** the enemy gains Vulnerable (Fire) — no DoT applied

#### Scenario: Combustible Oil vs Burning enemy
- **WHEN** a player uses Combustible Oil against a Burning enemy
- **THEN** the enemy takes 6 flat fire damage; no additional vulnerability stacking

#### Scenario: Frost Shard applies Chilled only
- **WHEN** a player uses Frost Shard on an enemy
- **THEN** the enemy gains Chilled (damage reduction effect per `HLD-COMBAT-006`); no Vulnerable (Ice) is applied

---

### Requirement: [LLD-ITEMS-008] Floor 3 Consumable Drop Pool — Elite Tier
The following consumables SHALL be in the elite drop pool for Floor 3:

| Item | Effect |
|---|---|
| Poultice | Applies Mending to player (X = 3 HP healed/tick; see `HLD-COMBAT-006` for full effect) |
| Brittle Charm | Applies Vulnerable (Physical) ×1.5 to one enemy (see `HLD-COMBAT-007`) |
| Fulminating Powder | Applies Shocked to one enemy (see `HLD-COMBAT-006` for stun timing) |

#### Scenario: Brittle Charm physical amplification
- **WHEN** a player applies Brittle Charm to an enemy and then uses a physical weapon
- **THEN** the weapon's physical damage is multiplied by ×1.5

#### Scenario: Fulminating Powder stun value
- **WHEN** Fulminating Powder is applied and the timer card drawn is 1 (shortest)
- **THEN** the stun occurs quickly — low timer cards are more valuable when Shocked is active (see HLD-COMBAT-006)

---

### Requirement: [LLD-ITEMS-010] Starting Items — The Hedge Knight
The Hedge Knight SHALL start every run with these three items (defined per `LLD-VESSELS-003`):

**Battered Sword** — Attack (Durability), Physical, damage: 7, charges: 8. Effect chain: `deal_damage { base_damage: 7, damage_type: physical }`.

**Iron Pendant** — Support (Durability), charges: 2, breaks_at_zero: true. Decrements 1 charge per encounter (per `LLD-ITEMS-002`). Effect: Replace the player's currently active fate omen with **Fortified** (take half damage from all attacks this omen cycle). The replaced omen is discarded. Fortified remains active for the rest of the current omen cycle. The Fortified omen is never placed in the fate deck — it only exists through pendant use. `[OPEN·MVP3]` exact damage reduction fraction and edge cases to be confirmed during playtesting.

**Cheap Flask** — Consumable, single use. Effect: Applies **Emboldened (Physical)** to the vessel — a +2 flat bonus to all outgoing physical damage. The buff lasts until the current omen cycle changes (1–3 rounds depending on the omen timer). The vessel may still attack on the same turn.

#### Scenario: Iron Pendant — omen replacement
- **WHEN** the player activates the Iron Pendant
- **THEN** the currently active fate omen on the player's side is replaced by Fortified and the original omen is discarded

#### Scenario: Iron Pendant — Fortified not in deck
- **WHEN** the fate deck is assembled for any combat
- **THEN** the Fortified omen card is never included; it can only appear via Iron Pendant activation

#### Scenario: Battered Sword — charge count
- **WHEN** the Hedge Knight starts a run
- **THEN** the Battered Sword has exactly 8 charges

#### Scenario: Cheap Flask — Emboldened Physical applied
- **WHEN** the Hedge Knight uses the Cheap Flask
- **THEN** the vessel gains Emboldened (Physical) +2 for the current omen cycle; physical attacks deal +2 damage while the buff is active

#### Scenario: Cheap Flask — buff duration
- **WHEN** the omen cycle changes after the Cheap Flask was used
- **THEN** the Emboldened (Physical) buff expires

---

### Requirement: [LLD-ITEMS-011] Item Score Table
> **Superseded by `LLD-IR-011` in `lld-item-ranking`.** The item scoring system is defined in full in the `lld-item-ranking` spec. All items have scores recorded in `LLD-IR-011`. This requirement is retained for cross-reference only.

The item score table in `LLD-IR-011` is used by the Wandering Soul trade generation system to enforce score-fair pairings (see `HLD-WS-006`, `HLD-ITEMS-009`) and by Memory Fragment scenario design to determine fair and unfair trade values (see `HLD-MF-003`, `HLD-MF-005`).

#### Scenario: Score table used for trade generation
- **WHEN** the Wandering Soul system generates an item-for-item trade
- **THEN** it reads item scores from `LLD-IR-011` and applies the tolerance formula in `LLD-IR-010`
