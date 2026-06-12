## MODIFIED Requirements

### Requirement: [LLD-ENEMIES-017] Floor 3 Enemy — Low HP Fanatic
The Low HP Fanatic SHALL use the intent table below for all combat actions.
**Family:** Fanatic. **Tags:** `fanatic`. Fanatic omen card: see `LLD-OMEN-CARD-014` (Sacred Ground).
**HP:** 8. **No vulnerability.**

`[OPEN·MVP3]` `[OPEN·MVP2]` Door symbol and final name to be confirmed. "Low HP Fanatic" is the design reference name.

**Omen contributions (see `HLD-OMEN-006`):**
- **Family card:** `LLD-OMEN-CARD-014` (Sacred Ground) ×1 per Low HP Fanatic
- **Type card:** `LLD-OMEN-CARD-010` (Mending) ×1 (total, regardless of Low HP Fanatic count)

**Intents (see `HLD-COMBAT-009`, `HLD-COMBAT-016`):**

| Intent ID | Weight | Damage | Max consecutive | Effect |
|---|---|---|---|---|
| `strike` | 60% | 3–5 physical | 2 | Deals damage |
| `taunt` | 20% | — | 2 | Applies Frenzied to the player (status_apply: `"frenzied"`, status_target: `"player"`, status_magnitude: 2) |
| `evade` | 20% | — | 2 | Evade (is_evade: true) |

`[OPEN·MVP1]` Damage range (3–5) and Frenzied magnitude (2) to be validated in playtesting.

**Kill references** (assumes strike every turn):
- Walking Staff (6 dmg): 2 hits
- With Hardened (3) from Absorption Totem (6 − 3 = 3 effective): 3 hits

#### Scenario: Low HP Fanatic strike
- **WHEN** the Low HP Fanatic's intent resolves to Strike
- **THEN** the Fanatic deals 3–5 physical damage to the player

#### Scenario: Low HP Fanatic taunt — Frenzied applied
- **WHEN** the Low HP Fanatic's intent resolves to Taunt and the player does not have Frenzied active
- **THEN** a Frenzied StatusInstance with magnitude 2 is applied to the player (Vulnerable Physical + Emboldened Physical effects); no damage is dealt

#### Scenario: Low HP Fanatic taunt — Frenzied already active, max-wins
- **WHEN** the Low HP Fanatic's intent resolves to Taunt and the player already has Frenzied active with magnitude ≥ 2
- **THEN** no change occurs (max-wins, see `HLD-COMBAT-019`); if existing magnitude were < 2, it would update to 2

#### Scenario: Frenzied makes player hits stronger and incoming hits hurt more
- **WHEN** the player has Frenzied active and attacks with a physical weapon while a Fanatic attacks them
- **THEN** the player's physical weapon gains the Emboldened (Physical) flat bonus (magnitude 2); the Fanatic's physical attack is amplified by ×1.5 due to the Vulnerable (Physical) effect

#### Scenario: Frenzied and standalone Emboldened (Physical) coexist
- **WHEN** the player has both a Frenzied StatusInstance and a standalone Emboldened (Physical) StatusInstance active simultaneously
- **THEN** both apply their flat bonuses independently; the combined effect is intentional

#### Scenario: Low HP Fanatic evade
- **WHEN** the Low HP Fanatic's intent resolves to Evade
- **THEN** the Fanatic sets is_evading = true; any player attack targeting that Fanatic this turn has a 35% miss chance

---

### Requirement: [LLD-ENEMIES-018] Floor 3 Enemy — High HP Fanatic
The High HP Fanatic SHALL use the intent table below for all combat actions.
**Family:** Fanatic. **Tags:** `fanatic`. Fanatic omen card: see `LLD-OMEN-CARD-014` (Sacred Ground).
**HP:** 12. **No vulnerability.**

`[OPEN·MVP3]` `[OPEN·MVP2]` Door symbol and final name to be confirmed. "High HP Fanatic" is the design reference name.

**Omen contributions (see `HLD-OMEN-006`):**
- **Family card:** `LLD-OMEN-CARD-014` (Sacred Ground) ×1 per High HP Fanatic
- **Type card:** `LLD-OMEN-CARD-010` (Mending) ×1 (total, regardless of High HP Fanatic count)

**Intents (see `HLD-COMBAT-009`, `HLD-COMBAT-016`):**

| Intent ID | Weight | Damage | Max consecutive | Effect |
|---|---|---|---|---|
| `strike` | 60% | 2–4 physical | 2 | Deals damage |
| `taunt` | 20% | — | 2 | Applies Frenzied to the player (status_apply: `"frenzied"`, status_target: `"player"`, status_magnitude: 2) |
| `evade` | 20% | — | 2 | Evade (is_evade: true) |

`[OPEN·MVP1]` Damage range (2–4) and Frenzied magnitude (2) to be validated in playtesting.

**Kill references** (assumes strike every turn):
- Walking Staff (6 dmg): 2 hits
- With Hardened (3) from Absorption Totem (6 − 3 = 3 effective): 4 hits

#### Scenario: High HP Fanatic strike
- **WHEN** the High HP Fanatic's intent resolves to Strike
- **THEN** the Fanatic deals 2–4 physical damage to the player

#### Scenario: High HP Fanatic taunt — Frenzied applied
- **WHEN** the High HP Fanatic's intent resolves to Taunt and the player does not have Frenzied active
- **THEN** a Frenzied StatusInstance with magnitude 2 is applied to the player; no damage is dealt

#### Scenario: High HP Fanatic taunt — Frenzied already active, max-wins
- **WHEN** the High HP Fanatic's intent resolves to Taunt and the player already has Frenzied active with magnitude ≥ 2
- **THEN** no change occurs (max-wins, see `HLD-COMBAT-019`)

#### Scenario: High HP Fanatic evade
- **WHEN** the High HP Fanatic's intent resolves to Evade
- **THEN** the Fanatic sets is_evading = true; any player attack targeting that Fanatic this turn has a 35% miss chance

#### Scenario: High HP Fanatic with Absorption Totem
- **WHEN** an Absorption Totem has applied Hardened (3) to the High HP Fanatic and the player attacks with Walking Staff (6 dmg)
- **THEN** the Fanatic absorbs 3 damage from Hardened; effective damage per hit is 3; 4 hits to kill instead of 2

---

### Requirement: [LLD-ENEMIES-019] Floor 3 Support Entity — Buff Totem
The Buff Totem SHALL apply `embolden_allies` to all living Fanatics on the enemy side each turn.
**Family:** Fanatic. **Tags:** `fanatic`. Totems do not contribute Sacred Ground (see `LLD-OMEN-CARD-014`).
**HP:** 6. **No vulnerability.**

`[OPEN·MVP3]` `[OPEN·MVP2]` Door symbol and final name to be confirmed. "Buff Totem" is the design reference name.

**Omen contribution:** None.

**Intent (see `HLD-COMBAT-009`, `HLD-COMBAT-019`):**

| Intent ID | Weight | Damage | Max consecutive | Effect |
|---|---|---|---|---|
| `embolden_allies` | 100% | — | — | Applies Emboldened (Physical, magnitude 2) to all living Fanatics on this side (status_apply: `"emboldened:physical"`, status_target: `"allies"`, status_magnitude: 2); Totem itself excluded |

`[OPEN·MVP1]` Emboldened magnitude (2) to be validated in playtesting.

When the Buff Totem is killed it no longer re-applies `embolden_allies` each turn. Emboldened (Physical) already active on Fanatics persists until the current omen cycle ends. Priority: kill the Totem before the next omen cycle to remove the buff.

#### Scenario: Buff Totem embolden_allies — Fanatic gains Emboldened
- **WHEN** the Buff Totem's intent resolves to Embolden Allies
- **THEN** all living Fanatics on the enemy side (excluding the Totem) receive Emboldened (Physical, magnitude 2); the Buff Totem itself does not receive the status

#### Scenario: Buff Totem re-apply — max-wins, no change at equal magnitude
- **WHEN** the Buff Totem applies Emboldened (Physical, magnitude 2) to a Fanatic that already has Emboldened (Physical) with magnitude 2
- **THEN** no change occurs (max-wins, see `HLD-COMBAT-019`); the existing StatusInstance is unchanged

#### Scenario: Emboldened (Physical) increases Fanatic strike damage
- **WHEN** a Fanatic with Emboldened (Physical, magnitude 2) active resolves Strike
- **THEN** the flat bonus (+2) is added to the strike's physical damage (Low HP Fanatic 3–5 becomes 5–7; High HP Fanatic 2–4 becomes 4–6)

#### Scenario: Buff Totem death — buff lingers until omen cycle ends
- **WHEN** the Buff Totem is killed mid-cycle while Fanatics have Emboldened (Physical) active
- **THEN** the Emboldened (Physical) on surviving Fanatics remains until the omen cycle ends; the Totem no longer re-applies it on subsequent turns

---

### Requirement: [LLD-ENEMIES-020] Floor 3 Support Entity — Absorption Totem
The Absorption Totem SHALL apply `harden_allies` to all living Fanatics on the enemy side each turn.
**Family:** Fanatic. **Tags:** `fanatic`. Totems do not contribute Sacred Ground (see `LLD-OMEN-CARD-014`).
**HP:** 10. **No vulnerability.**

`[OPEN·MVP3]` `[OPEN·MVP2]` Door symbol and final name to be confirmed. "Absorption Totem" is the design reference name.

**Omen contribution:** None.

**Intent (see `HLD-COMBAT-009`, `HLD-COMBAT-019`):**

| Intent ID | Weight | Damage | Max consecutive | Effect |
|---|---|---|---|---|
| `harden_allies` | 100% | — | — | Applies Hardened (magnitude 3) to all living Fanatics on this side (status_apply: `"hardened"`, status_target: `"allies"`, status_magnitude: 3); Totem itself excluded |

`[OPEN·MVP1]` Hardened magnitude (3) to be validated in playtesting.

When the Absorption Totem is killed it no longer re-applies `harden_allies` each turn. Hardened already active on Fanatics persists until the current omen cycle ends. Priority: kill the Totem before the next omen cycle to remove the buff.

`[OPEN·MVP1]` Interaction between Hardened absorb and the min-1 damage clamp (LLD-ARCH-019 step 8) to be resolved during implementation — Hardened absorption should reduce damage to 0 before the clamp applies.

#### Scenario: Absorption Totem harden_allies — Fanatic gains Hardened
- **WHEN** the Absorption Totem's intent resolves to Harden Allies
- **THEN** all living Fanatics on the enemy side (excluding the Totem) receive Hardened (magnitude 3); the Absorption Totem itself does not receive the status

#### Scenario: Hardened absorbs Throw Rock completely
- **WHEN** an Absorption Totem has applied Hardened (3) to a Fanatic and the player attacks with Throw Rock (3 damage)
- **THEN** the Fanatic absorbs all 3 damage; effective damage is 0 (Hardened absorption resolves before the min-1 clamp)

#### Scenario: Hardened partially absorbs Walking Staff
- **WHEN** a Fanatic has Hardened (3) active and the player attacks with Walking Staff (6 damage)
- **THEN** the Fanatic absorbs 3 damage; effective damage is 3

#### Scenario: Absorption Totem death — buff lingers until omen cycle ends
- **WHEN** the Absorption Totem is killed mid-cycle while Fanatics have Hardened active
- **THEN** the Hardened on surviving Fanatics remains until the omen cycle ends; the Totem no longer re-applies it on subsequent turns

#### Scenario: Totem takes full damage from player
- **WHEN** the player attacks the Absorption Totem directly
- **THEN** the Totem takes full damage — it is excluded from its own harden_allies intent (status_target: "allies" excludes the caster)
