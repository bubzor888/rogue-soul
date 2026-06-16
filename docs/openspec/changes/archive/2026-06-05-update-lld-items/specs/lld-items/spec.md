## MODIFIED Requirements

### Requirement: [LLD-ITEMS-002] Durability Decrement
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

### Requirement: [LLD-ITEMS-004] Floor 3 Starting Items — The Pilgrim
The Pilgrim SHALL start every run with these three items (defined per `LLD-VESSELS-001`):

**Walking Staff** — Attack (Durability), Physical, damage: 6, charges: 6. Effect chain: `deal_damage { base_damage: 6, damage_type: physical }`.

**Spoiled Potion** — Consumable. Effect chain: `apply_status { status_id: "poisoned" }`. Applies Poisoned (see `HLD-COMBAT-006` for escalating damage mechanic; starting value X = 2).

**Worn Map** — Support (Durability), charges: 3, breaks_at_zero: true. Decrements 1 charge per encounter. Break effect: forces the next room to be a temporary companion encounter (Memory Fragment). Removed from inventory after triggering.

#### Scenario: Walking Staff damage
- **WHEN** the Pilgrim uses the Walking Staff against an enemy
- **THEN** the enemy takes 6 physical damage (unmodified)

#### Scenario: Worn Map trigger
- **WHEN** the Worn Map's charges reach 0 (after 3 encounters)
- **THEN** the next room is replaced with a temporary companion encounter and the Worn Map is removed from inventory

---

### Requirement: [LLD-ITEMS-007] Floor 3 Consumable Drop Pool — Normal Tier
The following consumables SHALL be in the normal drop pool for Floor 3:

| Item | Effect |
|---|---|
| Fire Bomb | Applies Burning (5 fire damage/tick; see `HLD-COMBAT-006`) and co-applies Vulnerable (Fire) (see `HLD-COMBAT-007`) to one enemy |
| Ointment | Clears Burning or Poisoned from one target (see `LLD-ITEMS-001` for cleanse category rules) |
| Combustible Oil | Applies Vulnerable (Fire) ×1.5 to one enemy (see `HLD-COMBAT-007`); if target already Burning → flat fire damage burst instead (`[OPEN]` value: first pass 6) |
| Hardening Resin | Applies Hardened to player (X = 3 damage absorbed/tick; see `HLD-COMBAT-006` for full effect) |

#### Scenario: Fire Bomb typical damage
- **WHEN** a player uses Fire Bomb and the timer card is 2 (typical)
- **THEN** the target takes 10 fire damage total (5/tick × 2 ticks) and has Vulnerable (Fire) applied (co-applied with Burning per `HLD-COMBAT-007`)

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
| Poultice | Applies Mending to player (X = 3 HP healed/tick; see `HLD-COMBAT-006` for full effect) |
| Brittle Charm | Applies Vulnerable (Physical) ×1.5 to one enemy (see `HLD-COMBAT-007`) |
| Frost Shard | Applies Chilled to one enemy (see `HLD-COMBAT-006` for damage reduction and Vulnerable (Ice) effect) |
| Fulminating Powder | Applies Shocked to one enemy (see `HLD-COMBAT-006` for stun timing) |

#### Scenario: Brittle Charm physical amplification
- **WHEN** a player applies Brittle Charm to an enemy and then uses a physical weapon
- **THEN** the weapon's physical damage is multiplied by ×1.5

#### Scenario: Fulminating Powder stun value
- **WHEN** Fulminating Powder is applied and the timer card drawn is 1 (shortest)
- **THEN** the stun occurs quickly — low timer cards are more valuable when Shocked is active (see `HLD-COMBAT-006`)
