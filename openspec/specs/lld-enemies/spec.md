
### Requirement: [LLD-ENEMIES-001] Enemy Design Philosophy
Every enemy SHALL simultaneously serve three purposes: (1) a combat threat with a learnable mechanic, (2) an omen deck contributor that shapes combat feel, and (3) the entry tier of a family that scales across floors. Not every enemy requires an elemental vulnerability — behavioural mechanics (pack dynamics, absorption, on-death effects) are equally valid design.

#### Scenario: Enemy family scaling
- **WHEN** the player encounters a Skeleton on Floor 3 and later a Bone Warrior on a mid floor
- **THEN** both share the same fire vulnerability, omen contribution type, and combat identity — only stats increase

---

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
**Family:** Undead. Shared family omen card: see `LLD-OMEN-CARD-011` (Grave Knit).
**HP:** 12. **Attack:** 5 physical damage per turn. **Vulnerability:** Fire (×1.5 fire damage, see `HLD-COMBAT-007`).

`[OPEN·MVP2]` Door symbol for Skeleton combat encounters to be designed in a UI/art direction session.

**Omen contributions:** `LLD-OMEN-CARD-004` (Emboldened Physical) ×1, `LLD-OMEN-CARD-011` (Grave Knit) ×1.

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

**Omen contributions:** `LLD-OMEN-CARD-011` (Grave Knit) ×1. `[OPEN·MVP1]` Additional Zombie omen card to be defined.

**Kill references:**
- Walking Staff (6 dmg): 3 turns
- With Brittle Charm (6 × 1.5 = 9 dmg): 2 turns

#### Scenario: Zombie physical vulnerability activation
- **WHEN** the player uses Brittle Charm on a Zombie and then attacks with a physical weapon
- **THEN** the weapon's damage is multiplied by ×1.5

---

### Requirement: [LLD-ENEMIES-006] Floor 3 Enemy — Plague Rat
**Family:** Beast. Shared family omen card: see `LLD-OMEN-CARD-012` (Thick Hide).
**HP:** 3 per rat. **Attack:** 1 physical damage per turn per rat (3 total). **Encounter:** Always 3 simultaneously in pre-elite.
**Immunity:** Poisoned. **No vulnerability.**

`[OPEN·MVP2]` Door symbol for Plague Rat combat encounters to be designed in a UI/art direction session.

**On death:** Each rat death applies or advances the Poisoned individual omen on the player (+2 to current Poisoned value; starts at 2 if none active).

**Omen contributions:** `LLD-OMEN-CARD-012` (Thick Hide) ×1 per rat (3 total).

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

**Omen contributions:** `LLD-OMEN-CARD-012` (Thick Hide) ×1 per wolf.

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

**Omen contributions:** `LLD-OMEN-CARD-012` (Thick Hide) ×1.

#### Scenario: Bear solo encounter
- **WHEN** a Bear encounter occurs
- **THEN** exactly one Bear is present

#### Scenario: Bear sleeping round
- **WHEN** combat begins against the Bear
- **THEN** the player takes their first action freely; the Bear does not attack until round 2

---

### Requirement: [LLD-ENEMIES-009] Floor 3 Encounter Structure
Floor 3 encounter composition SHALL follow this structure:

| Phase | Rooms | Default encounter | Beast exception |
|---|---|---|---|
| Opening | 1–3 | 1 enemy | 2 Wolves or 3 Plague Rats |
| Companion | 4 | Worn Map trigger — no combat | — |
| Elite gate | 5 | Single elite enemy | — |
| Post-elite | 6–9 | 2 enemies | 3 Wolves or 1 Bear |
| Boss | — | The Judge | — |

A standard Floor 3 Pilgrim run yields 5 loot choices (4 standard + 1 elite) before the Judge.

#### Scenario: Post-elite encounter escalation
- **WHEN** the player completes the elite encounter on Floor 3
- **THEN** all subsequent standard rooms contain 2 enemies (or the beast exception count)

---

### Requirement: [LLD-ENEMIES-010] Floor 3 Boss — The Judge
`[OPEN·MVP1]` The Judge stats, mechanics, omen contributions, and narrative framing to be defined in a dedicated boss design session. The Judge is the guardian whose judgment the soul must pass — failing means rebirth (run ends), passing means the soul advances toward Solace.

#### Scenario: Boss placement
- **WHEN** the player completes all rooms on Floor 3
- **THEN** The Judge is the final encounter

#### Scenario: [OPEN·MVP1] Judge mechanics
- **WHEN** The Judge is designed
- **THEN** its mechanics MUST reference the soul's goal (Solace) narratively and present a genuine mechanical challenge tuned for one floor of preparation

---

### Requirement: [LLD-ENEMIES-014] Floor 3 Enemy — Fire Elemental
**Family:** Elemental. Shared family omen card: see `LLD-OMEN-CARD-013` (Elemental Synergy). Resistance/vulnerability table: see `LLD-OMEN-CARD-013`.
**HP:** 14. **Attack:** 5 fire damage per turn. **Resistance:** Fire ×0.5. **Vulnerability:** Ice ×1.5.

`[OPEN·MVP3]` `[OPEN·MVP2]` Door symbol to be designed in a UI/art direction session.

**Encounter:** 1 Fire Elemental pre-elite; 2 Fire Elementals post-elite.

**Omen contributions:** `LLD-OMEN-CARD-013` (Elemental Synergy) ×1, `LLD-OMEN-CARD-001` (Burning) ×1.

#### Scenario: Fire Elemental ice vulnerability
- **WHEN** the player attacks a Fire Elemental with an ice weapon while Chilled is active on the elemental
- **THEN** the ice weapon deals ×1.5 damage

#### Scenario: Elemental Synergy converts ice weapon to fire
- **WHEN** Elemental Synergy is active on the player side against a Fire Elemental
- **THEN** the player's ice weapon deals fire damage instead; the Fire Elemental's fire resistance (×0.5) applies

---

### Requirement: [LLD-ENEMIES-015] Floor 3 Enemy — Ice Elemental
**Family:** Elemental. Shared family omen card: see `LLD-OMEN-CARD-013` (Elemental Synergy).
**HP:** 14. **Attack:** 4 ice damage per turn + applies Chilled to the player on each hit. **Resistance:** Ice ×0.5. **Vulnerability:** Fire ×1.5.

`[OPEN·MVP3]` `[OPEN·MVP2]` Door symbol to be designed in a UI/art direction session.

**Encounter:** 1 Ice Elemental pre-elite; 2 Ice Elementals post-elite.

**Omen contributions:** `LLD-OMEN-CARD-013` (Elemental Synergy) ×1, `LLD-OMEN-CARD-003` (Chilled) ×1.

#### Scenario: Chilled application on hit
- **WHEN** the Ice Elemental attacks the player
- **THEN** the player takes ice damage and the Chilled status is applied

#### Scenario: Self-created vulnerability
- **WHEN** the Ice Elemental has Chilled the player and then attacks again
- **THEN** the ice damage benefits from the player's Vulnerable (Ice) ×1.5

---

### Requirement: [LLD-ENEMIES-016] Floor 3 Enemy — Lightning Elemental
**Family:** Elemental. Shared family omen card: see `LLD-OMEN-CARD-013` (Elemental Synergy).
**HP (Phase 1):** 18. **HP (Phase 2):** Two Sparks at 6 HP each.
**Attack (Phase 1):** 6 lightning per turn. **Attack (Phase 2):** 2 × 2 lightning each (4 total).
**Resistance:** Lightning ×0.5 (both phases). **Vulnerability:** None.

`[OPEN·MVP3]` `[OPEN·MVP2]` Door symbol to be designed in a UI/art direction session.

**Encounter:** 1 Lightning Elemental post-elite only.

**Two-phase:** Reaches 0 HP → splits into two Sparks (dead turn for enemy side). Sparks contribute no new omen cards.

**Omen contributions (Phase 1 only):** `LLD-OMEN-CARD-013` (Elemental Synergy) ×1, `LLD-OMEN-CARD-002` (Shocked) ×1.

#### Scenario: Two-phase transition
- **WHEN** the Lightning Elemental reaches 0 HP
- **THEN** combat does not end; two Sparks appear; the enemy side takes no action on the transition turn

#### Scenario: Sparks inherit no new omen cards
- **WHEN** the Lightning Elemental splits into Sparks
- **THEN** no new omen cards are added; the Phase 1 deck persists through Phase 2

#### Scenario: Resource management across phases
- **WHEN** the player transitions to Phase 2
- **THEN** all charges, consumables, and HP carry over unchanged

---

### Requirement: [LLD-ENEMIES-017] Floor 3 Enemy — Low HP Fanatic
**Family:** Fanatic. Fanatic omen card: see `LLD-OMEN-CARD-014` (Sacred Ground).
**HP:** 8. **Attack:** 4 physical per turn. **No vulnerability. No special mechanic.**

`[OPEN·MVP3]` `[OPEN·MVP2]` Door symbol and final name to be confirmed. "Low HP Fanatic" is the design reference name.

**Omen contribution:** `LLD-OMEN-CARD-014` (Sacred Ground) ×1.

#### Scenario: Low HP Fanatic kill speed
- **WHEN** the player uses a Walking Staff (6 damage) against a Low HP Fanatic
- **THEN** the Fanatic dies in 2 hits; it attacks once before dying (4 damage taken)

---

### Requirement: [LLD-ENEMIES-018] Floor 3 Enemy — High HP Fanatic
**Family:** Fanatic. Fanatic omen card: see `LLD-OMEN-CARD-014` (Sacred Ground).
**HP:** 12. **Attack:** 3 physical per turn. **No vulnerability. No special mechanic.**

`[OPEN·MVP3]` `[OPEN·MVP2]` Door symbol and final name to be confirmed. "High HP Fanatic" is the design reference name.

**Omen contribution:** `LLD-OMEN-CARD-014` (Sacred Ground) ×1.

#### Scenario: High HP Fanatic with Absorption Totem
- **WHEN** an Absorption Totem is active and the player attacks a High HP Fanatic with Walking Staff
- **THEN** the Fanatic takes 3 effective damage per hit (6 - 3 absorption); 4 hits to kill instead of 2

---

### Requirement: [LLD-ENEMIES-019] Floor 3 Support Entity — Buff Totem
**Family:** Fanatic. Totems do not contribute Sacred Ground (see `LLD-OMEN-CARD-014`).
**HP:** 6. **Attack:** None. **No vulnerability.**
**Aura (always-on):** All Fanatics on this side deal +2 damage per turn while alive. The Totem does not benefit from its own aura.

`[OPEN·MVP3]` `[OPEN·MVP2]` Door symbol and final name to be confirmed. "Buff Totem" is the design reference name.

**Omen contribution:** None.

#### Scenario: Buff Totem aura applies to all Fanatics
- **WHEN** a Buff Totem is alive on the enemy side
- **THEN** all Fanatics on that side deal +2 damage per turn

#### Scenario: Buff Totem kill removes aura
- **WHEN** the Buff Totem is killed
- **THEN** the +2 damage aura immediately ends; all surviving Fanatics revert to base damage

---

### Requirement: [LLD-ENEMIES-020] Floor 3 Support Entity — Absorption Totem
**Family:** Fanatic. Totems do not contribute Sacred Ground (see `LLD-OMEN-CARD-014`).
**HP:** 10. **Attack:** None. **No vulnerability.**
**Aura (always-on):** All Fanatics on this side absorb 3 damage per hit while alive. The Totem does not benefit from its own aura.

`[OPEN·MVP3]` `[OPEN·MVP2]` Door symbol and final name to be confirmed. "Absorption Totem" is the design reference name.

**Omen contribution:** None.

#### Scenario: Absorption aura renders Throw Rock useless
- **WHEN** an Absorption Totem is alive and the player attacks a Fanatic with Throw Rock (3 damage)
- **THEN** the Fanatic takes 0 effective damage (3 - 3 = 0)

#### Scenario: Totem takes full damage
- **WHEN** the player attacks the Absorption Totem directly
- **THEN** the Totem takes full damage — the absorption aura does not protect the Totem itself
