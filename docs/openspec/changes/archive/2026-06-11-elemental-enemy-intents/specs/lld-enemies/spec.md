## MODIFIED Requirements

### Requirement: [LLD-ENEMIES-014] Floor 3 Enemy — Fire Elemental
The Fire Elemental SHALL use the intent table below for all combat actions.
**Family:** Elemental. **Tags:** `elemental`, `elemental_fire`. Shared family omen card: see `LLD-OMEN-CARD-013` (Elemental Synergy — Fire). Resistance/vulnerability table: see `LLD-OMEN-CARD-013`.
**HP:** 14. **Resistance:** Fire ×0.5. **Vulnerability:** Ice ×1.5.

`[OPEN·MVP3]` `[OPEN·MVP2]` Door symbol to be designed in a UI/art direction session.

**Encounter:** 1 Fire Elemental pre-elite; 2 Fire Elementals post-elite.

**Omen contributions:** `elemental_synergy_fire` (Elemental Synergy — Fire) ×1, `LLD-OMEN-CARD-001` (Burning) ×1.

**Intents (see `HLD-COMBAT-009`, `HLD-COMBAT-016`, `HLD-COMBAT-018`):**

| Intent ID | Weight | Damage | Max consecutive | Effect |
|---|---|---|---|---|
| `fire_strike` | 50% | 4–6 fire | 2 | Deals fire damage |
| `kindle` | 50% | — | 2 | Applies Burning (magnitude 2) to player; if Burning already active, increments existing magnitude by 2 (see `HLD-COMBAT-018`) |

**Kill references** (assumes fire_strike every turn):
- Walking Staff (6 dmg): 3–4 turns (note: fire damage, no inherent vulnerability unless Combustible Oil used)
- Glacial Brand or ice weapon (9 ice × 1.5 = 13+): 2 turns

#### Scenario: Fire Elemental fire_strike
- **WHEN** the Fire Elemental's intent resolves to Fire Strike
- **THEN** the Fire Elemental deals 4–6 fire damage to the player

#### Scenario: Fire Elemental Kindle — no Burning active
- **WHEN** the Fire Elemental's intent resolves to Kindle and the player does not have an active Burning StatusInstance
- **THEN** a new Burning StatusInstance is applied to the player with magnitude 2 and remaining_ticks from the current omen timer; no damage is dealt this turn

#### Scenario: Fire Elemental Kindle — Burning already active
- **WHEN** the Fire Elemental's intent resolves to Kindle and the player already has an active Burning StatusInstance
- **THEN** the existing Burning StatusInstance's magnitude is incremented by 2 (per `HLD-COMBAT-018`); remaining_ticks is unchanged; no new StatusInstance is created; no damage is dealt this turn

#### Scenario: Kindle escalation over multiple turns
- **WHEN** the Fire Elemental uses Kindle on turn 1 (magnitude becomes 2) and again on turn 3 (magnitude becomes 4)
- **THEN** on the omen tick between those turns the player takes 2 fire damage; after the second Kindle the player takes 4 fire damage per tick

#### Scenario: Fire Elemental ice vulnerability
- **WHEN** the player attacks a Fire Elemental with an ice weapon
- **THEN** the ice weapon deals ×1.5 damage

#### Scenario: Elemental Synergy (Fire) converts ice weapon to fire
- **WHEN** Elemental Synergy (Fire) is active on the player side against a Fire Elemental
- **THEN** the player receives a Type Convert StatusInstance with string_param `"fire"`; the player's ice weapon deals fire damage instead; the Fire Elemental's fire resistance (×0.5) applies

---

### Requirement: [LLD-ENEMIES-015] Floor 3 Enemy — Ice Elemental
The Ice Elemental SHALL use the intent table below for all combat actions.
**Family:** Elemental. **Tags:** `elemental`, `elemental_ice`. Shared family omen card: see `LLD-OMEN-CARD-013` (Elemental Synergy — Ice).
**HP:** 14. **Resistance:** Ice ×0.5. **Vulnerability:** Fire ×1.5.

`[OPEN·MVP3]` `[OPEN·MVP2]` Door symbol to be designed in a UI/art direction session.

**Encounter:** 1 Ice Elemental pre-elite; 2 Ice Elementals post-elite.

**Omen contributions:** `elemental_synergy_ice` (Elemental Synergy — Ice) ×1, `LLD-OMEN-CARD-003` (Chilled) ×1.

**Intents (see `HLD-COMBAT-009`, `HLD-COMBAT-016`):**

| Intent ID | Weight | Damage | Max consecutive | Effect |
|---|---|---|---|---|
| `frost_bolt` | 60% | 3–5 ice | 2 | Deals ice damage |
| `glacial_mark` | 40% | — | 1 | Applies `"vulnerable:ice"` to player; no damage |

**Kill references** (assumes frost_bolt every turn):
- Walking Staff (6 physical): 3 turns (no vulnerability match — no bonus)
- Fire Bomb at 2 ticks (10 fire × 1.5 = 15): 1 turn — one-shot regardless of intent

#### Scenario: Ice Elemental Frost Bolt — no Vulnerable active
- **WHEN** the Ice Elemental's intent resolves to Frost Bolt and the player does not have Vulnerable (Ice) active
- **THEN** the Ice Elemental deals 3–5 ice damage to the player

#### Scenario: Ice Elemental Frost Bolt — Vulnerable (Ice) active
- **WHEN** the Ice Elemental's intent resolves to Frost Bolt and the player has an active `"vulnerable:ice"` StatusInstance
- **THEN** the Ice Elemental deals 3–5 ice damage amplified by ×1.5 (per `HLD-COMBAT-007`); effective damage range 4–7 (rounded down)

#### Scenario: Ice Elemental Glacial Mark — not yet marked
- **WHEN** the Ice Elemental's intent resolves to Glacial Mark and the player does not have Vulnerable (Ice) active
- **THEN** a `"vulnerable:ice"` StatusInstance is applied to the player with remaining_ticks from the current omen timer; no damage is dealt this turn

#### Scenario: Ice Elemental Glacial Mark — already marked
- **WHEN** the Ice Elemental's intent resolves to Glacial Mark and the player already has an active `"vulnerable:ice"` StatusInstance
- **THEN** no change occurs (Vulnerable does not stack per `HLD-COMBAT-007`); no damage is dealt; the intent is effectively wasted

#### Scenario: Glacial Mark max_consecutive prevents back-to-back marks
- **WHEN** the Ice Elemental just resolved Glacial Mark and rolls its next intent
- **THEN** Glacial Mark is excluded from the pool due to max_consecutive: 1; Frost Bolt is forced this turn before Glacial Mark becomes available again

#### Scenario: Ice Elemental setup–payoff sequence
- **WHEN** the Ice Elemental uses Glacial Mark on turn 1 and Frost Bolt on turn 2
- **THEN** the Frost Bolt on turn 2 deals ×1.5 ice damage (4–7 effective); the player took no damage on turn 1 but is now punished for not killing the elemental

#### Scenario: Elemental Synergy (Ice) converts player attacks
- **WHEN** Elemental Synergy (Ice) is active on the player side
- **THEN** the player receives a `type_convert` StatusInstance with `string_param: "ice"`; a fire weapon's fire advantage against the Ice Elemental disappears — damage deals ice type and hits the ×0.5 resistance instead
