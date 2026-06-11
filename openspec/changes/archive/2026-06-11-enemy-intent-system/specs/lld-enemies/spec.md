## MODIFIED Requirements

### Requirement: [LLD-ENEMIES-004] Floor 3 Enemy — Skeleton
**Family:** Undead. Shared family omen card: see `LLD-OMEN-CARD-011` (Grave Knit).
**HP:** 12. **Vulnerability:** Fire (×1.5 fire damage, see `HLD-COMBAT-007`).

`[OPEN·MVP2]` Door symbol for Skeleton combat encounters to be designed in a UI/art direction session.

**Intents:**

| Intent ID | Weight | Damage | Max consecutive | Effect |
|---|---|---|---|---|
| `strike` | 70% | 4–6 physical | 2 | Deals damage |
| `chill_touch` | 30% | — | 2 | Applies Chilled to the player (see `HLD-COMBAT-015`) |

**Omen contributions (see `HLD-OMEN-006`):**
- **Family card:** `LLD-OMEN-CARD-011` (Grave Knit) ×1 per Skeleton
- **Type card:** `LLD-OMEN-CARD-004` (Emboldened Physical) ×1 (total, regardless of Skeleton count)

**Kill references** (assumes Strike every turn; actual turns may vary due to Chill Touch turns):
- Throw Rock (3 dmg): 4–5 turns
- Walking Staff (6 dmg): 2–3 turns
- Fire Bomb at 2 ticks (10 fire × 1.5 = 15): 1 turn — one-shot regardless of intent

#### Scenario: Skeleton fire one-shot
- **WHEN** the player applies Fire Bomb to a Skeleton and the timer is 2 ticks (typical)
- **THEN** the Skeleton takes 15 fire damage total and dies (HP: 12)

#### Scenario: Skeleton Strike
- **WHEN** the Skeleton's intent resolves to Strike
- **THEN** the Skeleton deals 4–6 physical damage to the player

#### Scenario: Skeleton Chill Touch — Chilled not yet active
- **WHEN** the Skeleton's intent resolves to Chill Touch and the player does not have Chilled
- **THEN** Chilled is applied to the player; no damage is dealt

#### Scenario: Skeleton Chill Touch — Chilled already active
- **WHEN** the Skeleton's intent resolves to Chill Touch and the player already has Chilled
- **THEN** no change occurs; the intent still does not deal damage (see `HLD-COMBAT-015`)

---

### Requirement: [LLD-ENEMIES-005] Floor 3 Enemy — Zombie
**Family:** Undead. Shared family omen card: see `LLD-OMEN-CARD-011` (Grave Knit).
**HP:** 16. **Vulnerability:** Physical (×1.5 with Brittle Charm only, per `HLD-COMBAT-005`).

`[OPEN·MVP2]` Door symbol for Zombie combat encounters to be designed in a UI/art direction session.

**Intents:**

| Intent ID | Weight | Damage | Max consecutive | Effect |
|---|---|---|---|---|
| `swipe` | 40% | 2–4 physical | 2 | Deals damage |
| `slam` | 40% | 5–7 physical (release only) | 1 | Charge→Release (see `HLD-COMBAT-014`): charge turn telegraphs, no damage; release deals 5–7 physical |
| `shamble` | 20% | — | 2 | No action |

`[OPEN·MVP1]` Slam release damage range (5–7) to be validated in playtesting. Adjust if burst feels too punishing or too weak given the charge turn of counterplay.

**Omen contributions (see `HLD-OMEN-006`):**
- **Family card:** `LLD-OMEN-CARD-011` (Grave Knit) ×1 per Zombie
- **Type card:** `LLD-OMEN-CARD-004` (Emboldened Physical) ×1 (total, regardless of Zombie count)

**Kill references** (assumes all Swipe turns; actual turns vary):
- Walking Staff (6 dmg): 3–8 turns
- With Brittle Charm (6 × 1.5 = 9 dmg): 2–6 turns

#### Scenario: Zombie Swipe
- **WHEN** the Zombie's intent resolves to Swipe
- **THEN** the Zombie deals 2–4 physical damage to the player

#### Scenario: Zombie Slam — charge turn
- **WHEN** the Zombie's intent resolves to Slam
- **THEN** on this turn the Zombie telegraphs the incoming Slam but deals no damage; the player has one full turn of counterplay

#### Scenario: Zombie Slam — release turn
- **WHEN** the Zombie completed a Slam charge on the previous turn and is alive and un-stunned
- **THEN** the Slam fires unconditionally and deals 5–7 physical damage

#### Scenario: Zombie Slam — kill during charge
- **WHEN** the player kills the Zombie during the Slam charge turn
- **THEN** the release never fires; combat ends normally

#### Scenario: Zombie Shamble
- **WHEN** the Zombie's intent resolves to Shamble
- **THEN** the Zombie takes no action; the player takes no damage from this enemy this turn

#### Scenario: Zombie physical vulnerability activation
- **WHEN** the player uses Brittle Charm on a Zombie and then attacks with a physical weapon
- **THEN** the weapon's damage is multiplied by ×1.5

#### Scenario: Zombie Slam cannot repeat immediately
- **WHEN** the Zombie just completed a Slam (charge + release) and rolls its next intent
- **THEN** if the roll produces Slam again, it is re-rolled until a different intent is selected (max_consecutive: 1)
