## MODIFIED Requirements

### Requirement: [LLD-ENEMIES-002] Enemy Families
Enemies SHALL be grouped into families sharing a damage type, omen identity, and vulnerability logic. Floor 3 presents the entry tier of each family.

| Family | Floor 3 members |
|---|---|
| Undead | Skeleton, Zombie |
| Beast | Plague Rat, Wolf, Bear |
| Elemental | Fire Elemental, Ice Elemental, Lightning Elemental |
| Fanatic | Low HP Fanatic, High HP Fanatic, Buff Totem, Absorption Totem |

---

### Requirement: [LLD-ENEMIES-004] Floor 3 Enemy — Skeleton
**Family:** Undead (see `LLD-ENEMIES-003` for shared Grave Knit property).
**HP:** 12. **Attack:** 5 physical damage per turn. **Vulnerability:** Fire (×1.5 fire damage, see `HLD-COMBAT-007`).

`[OPEN·MVP2]` Door symbol for Skeleton combat encounters to be designed in a UI/art direction session.

**Omen contributions:** Emboldened (Physical) ×1 (flat +2 to all physical damage on target side), Grave Knit ×1.

#### Scenario: Skeleton fire one-shot
- **WHEN** the player applies Fire Bomb to a Skeleton and the timer is 2 ticks (typical)
- **THEN** the Skeleton takes 15 fire damage total and dies (HP: 12)

#### Scenario: Skeleton physical pressure
- **WHEN** a Skeleton attacks undefended each turn
- **THEN** the player takes 5 physical damage per turn; a 4-turn kill with Throw Rock results in 20 damage taken

---

### Requirement: [LLD-ENEMIES-005] Floor 3 Enemy — Zombie
**Family:** Undead (see `LLD-ENEMIES-003` for shared Grave Knit property).
**HP:** 16. **Attack:** 4 physical damage per turn. **Vulnerability:** Physical (×1.5 with Brittle Charm only — no intrinsic status grants physical vulnerability, per `HLD-COMBAT-005`).

`[OPEN·MVP2]` Door symbol for Zombie combat encounters to be designed in a UI/art direction session.

**Omen contributions:** Grave Knit ×1. `[OPEN·MVP1]` Additional Zombie omen card to be defined.

#### Scenario: Zombie physical vulnerability activation
- **WHEN** the player uses Brittle Charm on a Zombie and then attacks with a physical weapon
- **THEN** the weapon's damage is multiplied by ×1.5

---

### Requirement: [LLD-ENEMIES-006] Floor 3 Enemy — Plague Rat
**Family:** Beast (see `LLD-ENEMIES-011` for shared Thick Hide property).
**HP:** 3 per rat. **Attack:** 1 physical damage per turn per rat (3 total in pre-elite). **Encounter:** Always 3 Plague Rats simultaneously in pre-elite.
**Immunity:** Poisoned (immune to their own on-death effect).
**No vulnerability.**

`[OPEN·MVP2]` Door symbol for Plague Rat combat encounters to be designed in a UI/art direction session.

**On death:** Each rat death applies or advances the Poisoned individual omen on the player. Each death adds 2 to the current Poisoned omen value; if no Poisoned omen is active, one starts at 2. The omen escalates normally — ticking its current value per turn, tripling after each tick.

**Omen contributions:** Thick Hide ×1 per rat (3 total in pre-elite).

#### Scenario: Pack group size
- **WHEN** Plague Rats appear in a pre-elite encounter
- **THEN** exactly 3 Plague Rats are present

#### Scenario: On-death poison escalation
- **WHEN** the player kills a Plague Rat
- **THEN** the Poisoned omen value increases by 2; if not yet active, a new Poisoned omen starts at value 2

---

### Requirement: [LLD-ENEMIES-007] Floor 3 Enemy — Wolf
**Family:** Beast (see `LLD-ENEMIES-011` for shared Thick Hide property).
**HP:** 6. **Attack:** 3 physical damage per turn (lone wolf); 5 physical damage per turn (pack — 2 or more wolves alive). **Encounter:** 2 Wolves pre-elite, 3 Wolves post-elite.
**No vulnerability.**

`[OPEN·MVP2]` Door symbol for Wolf combat encounters to be designed in a UI/art direction session.

The pack bonus is binary: 2+ wolves alive means each deals 5 damage per turn; the last surviving wolf drops to 3. Killing one wolf immediately breaks the pack.

**Omen contributions:** Thick Hide ×1 per wolf.

#### Scenario: Pack damage threshold
- **WHEN** 2 or more Wolves are alive
- **THEN** each Wolf deals 5 damage per turn; killing one wolf immediately reduces all surviving wolves to 3 damage per turn

#### Scenario: Wolf pack encounter size
- **WHEN** Wolves appear pre-elite
- **THEN** 2 Wolves are present; post-elite, 3 Wolves are present

---

### Requirement: [LLD-ENEMIES-008] Floor 3 Enemy — Bear
**Family:** Beast (see `LLD-ENEMIES-011` for shared Thick Hide property).
**HP:** 22. **Attack:** Two swipes of 4 physical damage each (8 total per turn). **Encounter:** 1 Bear — post-elite only. **No vulnerability.**

`[OPEN·MVP2]` Door symbol for Bear combat encounters to be designed in a UI/art direction session.

**Sleeping — Round 1:** The Bear is asleep when the encounter begins. The player takes their action freely — the Bear does not act. It wakes at the start of round 2. The free round rewards deliberate setup: attack immediately for damage, or apply a defensive consumable for sustained survivability.

**Omen contributions:** Thick Hide ×1.

#### Scenario: Bear solo encounter
- **WHEN** a Bear encounter occurs
- **THEN** exactly one Bear is present

#### Scenario: Bear sleeping round
- **WHEN** combat begins against the Bear
- **THEN** the player takes their first action freely; the Bear does not attack until round 2

## ADDED Requirements

### Requirement: [LLD-ENEMIES-011] Shared Beast Property — Thick Hide
All beast enemies SHALL contribute one copy of the Thick Hide omen card per beast to the combat deck. Thick Hide absorbs 3 damage per incoming hit for all beasts on the target side for the omen cycle. Does nothing when applied to the player.

In multi-beast encounters, multiple Thick Hide copies cycle frequently. Absorbing Thick Hide on the player's side is safe; allowing it on the beast side dramatically changes kill thresholds.

#### Scenario: Thick Hide absorption
- **WHEN** Thick Hide is active on the beast side
- **THEN** each incoming hit to any beast on that side is reduced by 3 damage before applying HP reduction

#### Scenario: Thick Hide player side — safe
- **WHEN** the player steers Thick Hide to their own side
- **THEN** no effect occurs (the player has no Thick Hide property) and the beasts do not receive the buff

---

### Requirement: [LLD-ENEMIES-012] Shared Elemental Property — Elemental Synergy
All elemental enemies SHALL contribute one copy of the Elemental Synergy omen card to the combat deck. Elemental Synergy converts all attacks from the target side to the elemental's damage type for the omen cycle.

Applied to **elemental side:** elementals already deal their type — no change. Safe for the player to play here.
Applied to **player side:** all player attacks convert to the elemental's damage type. The elemental resists that type (×0.5). Any weapon with an opposing-element advantage (e.g. ice weapon vs. Fire Elemental) loses that advantage entirely.

**Elemental resistances and vulnerabilities:**

| Elemental | Resistance | Vulnerability |
|---|---|---|
| Fire Elemental | Fire ×0.5 | Ice ×1.5 |
| Ice Elemental | Ice ×0.5 | Fire ×1.5 |
| Lightning Elemental | Lightning ×0.5 | None |

#### Scenario: Elemental Synergy on player side
- **WHEN** Elemental Synergy is active on the player side
- **THEN** all player attacks deal the elemental's damage type; if the player was using the opposing-element weapon for a ×1.5 advantage, that weapon now deals the resisted type at ×0.5

---

### Requirement: [LLD-ENEMIES-013] Fanatic-Only Omen — Sacred Ground
Fanatic enemies (not Totems) SHALL each contribute one copy of the Sacred Ground omen card to the combat deck. Sacred Ground doubles the effect of all active Totem auras on the target side for the omen cycle. Applied to the player side, it does nothing (the player has no Totem auras).

When the Totem is killed, Sacred Ground draws become completely inert — no Totem auras remain to double. Killing the Totem neutralises both the aura threat and all future Sacred Ground draws simultaneously.

**Deck contribution:** 1 card pre-elite (1 Fanatic + 1 Totem); 2 cards post-elite (2 Fanatics + 1 Totem).

#### Scenario: Sacred Ground doubles aura
- **WHEN** Sacred Ground is active on the Fanatic/Totem side and an Absorption Totem is alive
- **THEN** all Fanatics on that side absorb 6 damage per hit instead of 3 for that cycle

#### Scenario: Sacred Ground inert without Totem
- **WHEN** Sacred Ground is drawn after the Totem has been killed
- **THEN** the card has no effect on either side

---

### Requirement: [LLD-ENEMIES-014] Floor 3 Enemy — Fire Elemental
**Family:** Elemental (see `LLD-ENEMIES-012` for Elemental Synergy; `LLD-ENEMIES-002` for encounter structure).
**HP:** 14. **Attack:** 5 fire damage per turn. **Resistance:** Fire ×0.5. **Vulnerability:** Ice ×1.5 (from Chilled status or direct application).

`[OPEN·MVP3]` `[OPEN·MVP2]` Door symbol for Fire Elemental combat encounters to be designed in a UI/art direction session.

**Encounter:** 1 Fire Elemental pre-elite; 2 Fire Elementals post-elite.

**Omen contributions:** Elemental Synergy ×1, Burning ×1. The Burning card landing on the player side makes the player Vulnerable (Fire) ×1.5 — the Fire Elemental's own 5 fire damage then deals 7.5 per turn.

#### Scenario: Fire Elemental ice vulnerability
- **WHEN** the player attacks a Fire Elemental with an ice weapon while Chilled is active on the elemental
- **THEN** the ice weapon deals ×1.5 damage

#### Scenario: Elemental Synergy converts ice weapon to fire
- **WHEN** Elemental Synergy is active on the player side against a Fire Elemental
- **THEN** the player's ice weapon deals fire damage instead; the Fire Elemental's fire resistance (×0.5) applies

---

### Requirement: [LLD-ENEMIES-015] Floor 3 Enemy — Ice Elemental
**Family:** Elemental (see `LLD-ENEMIES-012` for Elemental Synergy).
**HP:** 14. **Attack:** 4 ice damage per turn + applies Chilled to the player on each hit. **Resistance:** Ice ×0.5. **Vulnerability:** Fire ×1.5 (from Burning status or direct application).

`[OPEN·MVP3]` `[OPEN·MVP2]` Door symbol for Ice Elemental combat encounters to be designed in a UI/art direction session.

**Encounter:** 1 Ice Elemental pre-elite; 2 Ice Elementals post-elite.

**Omen contributions:** Elemental Synergy ×1, Chilled ×1. The Ice Elemental applies Chilled directly on each hit — not through omen draws. Each hit: player takes ice damage and gains Chilled (creeping damage reduction + Vulnerable Ice). The elemental's own ice attacks then benefit from the player's Vulnerable Ice (×1.5).

#### Scenario: Chilled application on hit
- **WHEN** the Ice Elemental attacks the player
- **THEN** the player takes ice damage and the Chilled status is applied; if already Chilled the timer refreshes

#### Scenario: Self-created vulnerability
- **WHEN** the Ice Elemental has Chilled the player and then attacks again
- **THEN** the ice damage benefits from the player's Vulnerable (Ice) ×1.5, as the elemental exploits the vulnerability it created

---

### Requirement: [LLD-ENEMIES-016] Floor 3 Enemy — Lightning Elemental
**Family:** Elemental (see `LLD-ENEMIES-012` for Elemental Synergy).
**HP (Phase 1):** 18. **HP (Phase 2):** Two Sparks at 6 HP each.
**Attack (Phase 1):** 6 lightning damage per turn. **Attack (Phase 2):** 2 Sparks × 2 lightning damage each (4 total per turn).
**Resistance:** Lightning ×0.5 (both phases). **Vulnerability:** None.

`[OPEN·MVP3]` `[OPEN·MVP2]` Door symbol for Lightning Elemental combat encounters to be designed in a UI/art direction session.

**Encounter:** 1 Lightning Elemental post-elite only (no pre-elite occurrence).

**Two-phase encounter:** When the Lightning Elemental reaches 0 HP, it does not end combat — it splits into two Sparks. The turn it dies is a dead turn for the enemy side (no attack, just the transition). From the following turn, both Sparks are active. Omens active at transition continue counting down; no new cards from the Sparks.

**Omen contributions (Phase 1 only):** Elemental Synergy ×1, Shocked ×1. Sparks contribute no new omen cards.

#### Scenario: Two-phase transition
- **WHEN** the Lightning Elemental reaches 0 HP
- **THEN** combat does not end; two Sparks appear; the enemy side takes no action on the transition turn

#### Scenario: Sparks inherit no new omen cards
- **WHEN** the Lightning Elemental splits into Sparks
- **THEN** no new omen cards are added to the deck; the Phase 1 deck persists through Phase 2

#### Scenario: Resource management across phases
- **WHEN** the player transitions to Phase 2
- **THEN** all charges, consumables, and HP carry over unchanged — there is no rest between phases

---

### Requirement: [LLD-ENEMIES-017] Floor 3 Enemy — Low HP Fanatic
**Family:** Fanatic (see `LLD-ENEMIES-013` for Sacred Ground omen).
**HP:** 8. **Attack:** 4 physical damage per turn. **No vulnerability. No special mechanic.**

`[OPEN·MVP3]` `[OPEN·MVP2]` Door symbol and final name for Low HP Fanatic to be confirmed in a UI/art direction session. "Low HP Fanatic" is the design reference name.

**Omen contribution:** Sacred Ground ×1.

#### Scenario: Low HP Fanatic kill speed
- **WHEN** the player uses a Walking Staff (6 damage) against a Low HP Fanatic
- **THEN** the Fanatic dies in 2 hits; it attacks once before dying (4 damage taken)

---

### Requirement: [LLD-ENEMIES-018] Floor 3 Enemy — High HP Fanatic
**Family:** Fanatic (see `LLD-ENEMIES-013` for Sacred Ground omen).
**HP:** 12. **Attack:** 3 physical damage per turn. **No vulnerability. No special mechanic.**

`[OPEN·MVP3]` `[OPEN·MVP2]` Door symbol and final name for High HP Fanatic to be confirmed in a UI/art direction session. "High HP Fanatic" is the design reference name.

**Omen contribution:** Sacred Ground ×1.

#### Scenario: High HP Fanatic with Absorption Totem
- **WHEN** an Absorption Totem is active and the player attacks a High HP Fanatic with Walking Staff (6 - 3 absorption = 3 effective)
- **THEN** the Fanatic takes 3 effective damage per hit; 4 hits to kill instead of 2

---

### Requirement: [LLD-ENEMIES-019] Floor 3 Support Entity — Buff Totem
**Family:** Fanatic (see `LLD-ENEMIES-013`; Totems do not contribute Sacred Ground).
**HP:** 6. **Attack:** None. **No vulnerability.**
**Aura (always-on):** All Fanatics on this side deal +2 damage per turn while the Totem is alive.

`[OPEN·MVP3]` `[OPEN·MVP2]` Door symbol and final name for Buff Totem to be confirmed in a UI/art direction session. "Buff Totem" is the design reference name.

The Totem does not benefit from its own aura. Walking Staff one-shots it (6 = 6 HP). Killing the Totem also renders all Sacred Ground draws inert for the remainder of combat.

#### Scenario: Buff Totem aura applies to all Fanatics
- **WHEN** a Buff Totem is alive on the enemy side
- **THEN** all Fanatics on that side deal +2 damage per turn (additive to their base attack)

#### Scenario: Buff Totem kill removes aura
- **WHEN** the Buff Totem is killed
- **THEN** the +2 damage aura immediately ends; all surviving Fanatics revert to base damage

---

### Requirement: [LLD-ENEMIES-020] Floor 3 Support Entity — Absorption Totem
**Family:** Fanatic (see `LLD-ENEMIES-013`; Totems do not contribute Sacred Ground).
**HP:** 10. **Attack:** None. **No vulnerability.**
**Aura (always-on):** All Fanatics on this side absorb 3 damage per hit while the Totem is alive. The Totem does not benefit from its own aura (the player can deal full damage to the Totem itself).

`[OPEN·MVP3]` `[OPEN·MVP2]` Door symbol and final name for Absorption Totem to be confirmed in a UI/art direction session. "Absorption Totem" is the design reference name.

Walking Staff (6 damage) kills it in 2 hits (6+4=10 — second hit deals 4 after the first).

#### Scenario: Absorption aura reduces effective damage
- **WHEN** an Absorption Totem is alive and the player attacks a Fanatic with Throw Rock (3 damage)
- **THEN** the Fanatic takes 0 effective damage (3 - 3 absorption = 0); Throw Rock is useless against Fanatics while the Totem lives

#### Scenario: Totem takes full damage
- **WHEN** the player attacks the Absorption Totem directly
- **THEN** the Totem takes full damage — the absorption aura does not protect the Totem itself
