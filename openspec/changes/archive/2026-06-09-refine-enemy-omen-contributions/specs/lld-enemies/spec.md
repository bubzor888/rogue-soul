## MODIFIED Requirements

### Requirement: [LLD-ENEMIES-004] Floor 3 Enemy — Skeleton
**Family:** Undead. Shared family omen card: see `LLD-OMEN-CARD-011` (Grave Knit).
**HP:** 12. **Attack:** 5 physical damage per turn. **Vulnerability:** Fire (×1.5 fire damage, see `HLD-COMBAT-007`).

`[OPEN·MVP2]` Door symbol for Skeleton combat encounters to be designed in a UI/art direction session.

**Omen contributions (see `HLD-OMEN-006`):**
- **Family card:** `LLD-OMEN-CARD-011` (Grave Knit) ×1 per Skeleton
- **Type card:** `LLD-OMEN-CARD-004` (Emboldened Physical) ×1 (total, regardless of Skeleton count)

**Kill references:**
- Throw Rock (3 dmg): 4 turns
- Walking Staff (6 dmg): 2 turns
- Fire Bomb at 2 ticks (10 fire × 1.5 = 15): 1 turn — one-shot

#### Scenario: Skeleton fire one-shot
- **WHEN** the player applies Fire Bomb to a Skeleton and the timer is 2 ticks (typical)
- **THEN** the Skeleton takes 15 fire damage total and dies (HP: 12)

#### Scenario: Skeleton physical pressure
- **WHEN** a Skeleton attacks undefended each turn
- **THEN** the player takes 5 physical damage per turn; a 4-turn kill with Throw Rock results in 20 damage taken

---

### Requirement: [LLD-ENEMIES-005] Floor 3 Enemy — Zombie
**Family:** Undead. Shared family omen card: see `LLD-OMEN-CARD-011` (Grave Knit).
**HP:** 16. **Attack:** 4 physical damage per turn. **Vulnerability:** Physical (×1.5 with Brittle Charm only, per `HLD-COMBAT-005`).

`[OPEN·MVP2]` Door symbol for Zombie combat encounters to be designed in a UI/art direction session.

**Omen contributions (see `HLD-OMEN-006`):**
- **Family card:** `LLD-OMEN-CARD-011` (Grave Knit) ×1 per Zombie
- **Type card:** `LLD-OMEN-CARD-004` (Emboldened Physical) ×1 (total, regardless of Zombie count)

**Kill references:**
- Walking Staff (6 dmg): 3 turns
- With Brittle Charm (6 × 1.5 = 9 dmg): 2 turns

#### Scenario: Zombie physical vulnerability activation
- **WHEN** the player uses Brittle Charm on a Zombie and then attacks with a physical weapon
- **THEN** the weapon's damage is multiplied by ×1.5

#### Scenario: Zombie omen contribution
- **WHEN** a Zombie is present in combat
- **THEN** one copy of Grave Knit is in the deck (family card); one copy of Emboldened Physical is in the deck (type card)

---

### Requirement: [LLD-ENEMIES-006] Floor 3 Enemy — Plague Rat
**Family:** Beast. Shared family omen card: see `LLD-OMEN-CARD-012` (Thick Hide).
**HP:** 3 per rat. **Attack:** 1 physical damage per turn per rat (3 total). **Encounter:** Always 3 simultaneously in pre-elite.
**Immunity:** Poisoned. **No vulnerability.**

`[OPEN·MVP2]` Door symbol for Plague Rat combat encounters to be designed in a UI/art direction session.

**On death:** Each rat death applies or advances the Poisoned individual omen on the player (+2 to current Poisoned value; starts at 2 if none active).

**Omen contributions (see `HLD-OMEN-006`):**
- **Family card:** `LLD-OMEN-CARD-012` (Thick Hide) ×1 per rat (3 total)
- **Type card:** `LLD-OMEN-CARD-019` (Exposed) ×1 (total, regardless of rat count)

#### Scenario: Pack group size
- **WHEN** Plague Rats appear in a pre-elite encounter
- **THEN** exactly 3 Plague Rats are present

#### Scenario: On-death poison escalation
- **WHEN** the player kills a Plague Rat
- **THEN** the Poisoned omen value increases by 2; if not yet active, a new Poisoned omen starts at value 2

---

### Requirement: [LLD-ENEMIES-007] Floor 3 Enemy — Wolf
**Family:** Beast. Shared family omen card: see `LLD-OMEN-CARD-012` (Thick Hide).
**HP:** 6. **Attack:** 3 physical per turn (lone); 5 physical per turn (pack — 2+ wolves alive). **Encounter:** 2 Wolves pre-elite, 3 Wolves post-elite.
**No vulnerability.**

`[OPEN·MVP2]` Door symbol for Wolf combat encounters to be designed in a UI/art direction session.

**Omen contributions (see `HLD-OMEN-006`):**
- **Family card:** `LLD-OMEN-CARD-012` (Thick Hide) ×1 per wolf
- **Type card:** `LLD-OMEN-CARD-019` (Exposed) ×1 (total, regardless of wolf count)

#### Scenario: Pack damage threshold
- **WHEN** 2 or more Wolves are alive
- **THEN** each Wolf deals 5 damage per turn; killing one wolf immediately reduces all surviving wolves to 3 damage per turn

#### Scenario: Wolf pack encounter size
- **WHEN** Wolves appear pre-elite
- **THEN** 2 Wolves are present; post-elite, 3 Wolves are present

---

### Requirement: [LLD-ENEMIES-008] Floor 3 Enemy — Bear
**Family:** Beast. Shared family omen card: see `LLD-OMEN-CARD-012` (Thick Hide).
**HP:** 22. **Attack:** Two swipes of 4 physical damage each (8 total per turn). **Encounter:** 1 Bear — post-elite only. **No vulnerability.**

`[OPEN·MVP2]` Door symbol for Bear combat encounters to be designed in a UI/art direction session.

**Sleeping — Round 1:** Bear does not act on round 1; wakes at start of round 2.

**Omen contributions (see `HLD-OMEN-006`):**
- **Family card:** `LLD-OMEN-CARD-012` (Thick Hide) ×1
- **Type card:** `LLD-OMEN-CARD-019` (Exposed) ×1

#### Scenario: Bear solo encounter
- **WHEN** a Bear encounter occurs
- **THEN** exactly one Bear is present

#### Scenario: Bear sleeping round
- **WHEN** combat begins against the Bear
- **THEN** the player takes their first action freely; the Bear does not attack until round 2

---

### Requirement: [LLD-ENEMIES-017] Floor 3 Enemy — Low HP Fanatic
**Family:** Fanatic. Fanatic omen card: see `LLD-OMEN-CARD-014` (Sacred Ground).
**HP:** 8. **Attack:** 4 physical per turn. **No vulnerability. No special mechanic.**

`[OPEN·MVP3]` `[OPEN·MVP2]` Door symbol and final name to be confirmed. "Low HP Fanatic" is the design reference name.

**Omen contributions (see `HLD-OMEN-006`):**
- **Family card:** `LLD-OMEN-CARD-014` (Sacred Ground) ×1 per Low HP Fanatic
- **Type card:** `LLD-OMEN-CARD-010` (Mending) ×1 (total, regardless of Low HP Fanatic count)

#### Scenario: Low HP Fanatic kill speed
- **WHEN** the player uses a Walking Staff (6 damage) against a Low HP Fanatic
- **THEN** the Fanatic dies in 2 hits; it attacks once before dying (4 damage taken)

---

### Requirement: [LLD-ENEMIES-018] Floor 3 Enemy — High HP Fanatic
**Family:** Fanatic. Fanatic omen card: see `LLD-OMEN-CARD-014` (Sacred Ground).
**HP:** 12. **Attack:** 3 physical per turn. **No vulnerability. No special mechanic.**

`[OPEN·MVP3]` `[OPEN·MVP2]` Door symbol and final name to be confirmed. "High HP Fanatic" is the design reference name.

**Omen contributions (see `HLD-OMEN-006`):**
- **Family card:** `LLD-OMEN-CARD-014` (Sacred Ground) ×1 per High HP Fanatic
- **Type card:** `LLD-OMEN-CARD-010` (Mending) ×1 (total, regardless of High HP Fanatic count)

#### Scenario: High HP Fanatic with Absorption Totem
- **WHEN** an Absorption Totem is active and the player attacks a High HP Fanatic with Walking Staff
- **THEN** the Fanatic takes 3 effective damage per hit (6 - 3 absorption); 4 hits to kill instead of 2
