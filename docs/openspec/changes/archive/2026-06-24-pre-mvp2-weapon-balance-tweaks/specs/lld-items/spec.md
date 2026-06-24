## MODIFIED Requirements

### Requirement: [LLD-ITEMS-005] Floor 3 Durability Drop Pool — Normal Tier
The following durability items SHALL be in the normal drop pool for Floor 3:

| Item | Category | Type | Damage | Charges | Property |
|---|---|---|---|---|---|
| Cracked Cudgel | Attack | Physical | 9 | 3 | High burst |
| Rope Flail | Attack | Physical | 5/hit | 6 | Hits all enemies |
| Battered Sword | Attack | Physical | 7 | 6 | — |
| Ember Shard | Attack | Fire | 7 | 3 | — |
| Spark Rod | Attack | Lightning | 7 | 3 | — |
| Frost Sliver | Attack | Ice | 7 | 3 | — |
| Small Amethyst | Support | — | — | 1 | Clears Shocked, Chilled, Vulnerable (Physical) |

#### Scenario: Rope Flail multi-target
- **WHEN** the player uses the Rope Flail against two enemies
- **THEN** both enemies take 5 physical damage simultaneously from a single charge

#### Scenario: Ember Shard vs Burning enemy
- **WHEN** the player uses Ember Shard against an enemy with the Burning status
- **THEN** the enemy takes 7 × 1.5 = ~11 fire damage (rounded per HLD-COMBAT-007)

---

### Requirement: [LLD-ITEMS-010] Starting Items — The Hedge Knight
The Hedge Knight SHALL start every run with these three items (defined per `LLD-VESSELS-003`):

**Battered Sword** — Attack (Durability), Physical, damage: 7, charges: 6. Effect chain: `deal_damage { base_damage: 7, damage_type: physical }`.

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
- **THEN** the Battered Sword has exactly 6 charges

#### Scenario: Cheap Flask — Emboldened Physical applied
- **WHEN** the Hedge Knight uses the Cheap Flask
- **THEN** the vessel gains Emboldened (Physical) +2 for the current omen cycle; physical attacks deal +2 damage while the buff is active

#### Scenario: Cheap Flask — buff duration
- **WHEN** the omen cycle changes after the Cheap Flask was used
- **THEN** the Emboldened (Physical) buff expires
