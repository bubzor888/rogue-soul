## ADDED Requirements

### Requirement: [LLD-ENEMIES-001] Enemy Design Philosophy
Every enemy SHALL simultaneously serve three purposes: (1) a combat threat with a learnable mechanic, (2) an omen deck contributor that shapes combat feel, and (3) the entry tier of a family that scales across floors. Not every enemy requires an elemental vulnerability — behavioural mechanics (pack dynamics, absorption, on-death effects) are equally valid design.

#### Scenario: Enemy family scaling
- **WHEN** the player encounters a Skeleton on Floor 3 and later a Bone Warrior on a mid floor
- **THEN** both share the same fire vulnerability, omen contribution type, and combat identity — only stats increase

---

### Requirement: [LLD-ENEMIES-002] Enemy Families
Enemies SHALL be grouped into families sharing a damage type, omen identity, and vulnerability logic. Floor 3 presents the entry tier of each family.

| Family | Floor 3 members | Mid-floor (TBD) | Late-floor (TBD) |
|---|---|---|---|
| Undead | Skeleton, Zombie | Bone Warrior, Plague Zombie | Death Knight, Rot Colossus |
| Beast | Plague Rat, Wolf, Bear | TBD | TBD |
| Elemental | `[OPEN]` TBD | TBD | TBD |
| Fanatic | `[OPEN]` TBD | TBD | TBD |

#### Scenario: Floor 3 roster coverage
- **WHEN** Floor 3 is fully implemented
- **THEN** 8 enemy types are present (2 from each of the 4 families), providing roster variety across runs

#### Scenario: [OPEN] Elemental and Fanatic families
- **WHEN** tier 3 vessels (Battle Mage, Shaman) are designed
- **THEN** their corresponding Elemental and Fanatic family enemies (2 each) are added to Floor 3

---

### Requirement: [LLD-ENEMIES-003] Shared Undead Property — Grave Knit
All undead enemies SHALL contribute one copy of the Grave Knit omen card to the combat deck. Grave Knit heals all undead units on the target side for 5 HP per tick (per-turn omen). Does nothing when applied to the player.

**Typical (2 ticks): 10 HP healed.** Against a Skeleton (12 HP) this is nearly a full HP restoration.

#### Scenario: Grave Knit player allocation
- **WHEN** the player steers the Grave Knit omen to their own side
- **THEN** no healing occurs (player is not undead) but the enemy does not receive healing

#### Scenario: Multi-undead Grave Knit density
- **WHEN** two undead enemies are present in combat
- **THEN** two copies of Grave Knit cycle through the omen deck

---

### Requirement: [LLD-ENEMIES-004] Floor 3 Enemy — Skeleton
**HP:** 12. **Attack:** 5 physical damage per turn. **Vulnerability:** Fire (×1.5 fire damage while Burning, per HLD-COMBAT-007).

**Omen contributions:** Emboldened (Physical) ×1 (flat +2 to all physical damage on target side), Grave Knit ×1.

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
**HP:** 16. **Attack:** `[OPEN]` to be confirmed. **Vulnerability:** Physical (×1.5 with Brittle Charm only — no intrinsic status grants physical vulnerability, per HLD-COMBAT-005).

**Omen contributions:** Grave Knit ×1. `[OPEN]` Additional Zombie omen card to be defined.

**Kill references:**
- Walking Staff (6 dmg): 3 turns
- With Brittle Charm (6 × 1.5 = 9 dmg): 2 turns
- Iron Maul + Brittle Charm (10 × 1.5 = 15 dmg): 2 turns — efficient

#### Scenario: Zombie physical vulnerability activation
- **WHEN** the player uses Brittle Charm on a Zombie and then attacks with a physical weapon
- **THEN** the weapon's damage is multiplied by ×1.5

---

### Requirement: [LLD-ENEMIES-006] Floor 3 Enemy — Plague Rat
`[OPEN]` Plague Rat stats, attack, and mechanic to be confirmed. Known design intent: always appears in groups of 3; on-death effect applies escalating poison that makes killing all three before DoT ticks meaningful.

#### Scenario: Pack group size
- **WHEN** Plague Rats appear in a pre-elite encounter
- **THEN** exactly 3 Plague Rats are present (see HLD-COMBAT-002 for beast encounter exception to single-enemy default)

---

### Requirement: [LLD-ENEMIES-007] Floor 3 Enemy — Wolf
`[OPEN]` Wolf stats, attack, and mechanic to be confirmed. Known design intent: pack mechanic — always appears as multiple Wolves; killing wolves fast breaks pack synergy.

#### Scenario: Wolf pack encounter size
- **WHEN** Wolves appear pre-elite
- **THEN** 2 Wolves are present; post-elite, 3 Wolves are present

---

### Requirement: [LLD-ENEMIES-008] Floor 3 Enemy — Bear
`[OPEN]` Bear stats, attack, and mechanic to be confirmed. Known design intent: always solo (pre- and post-elite); sleeping round at combat start; two-swipe mechanic requiring mitigation strategy.

#### Scenario: Bear solo encounter
- **WHEN** a Bear encounter occurs (at any phase)
- **THEN** exactly one Bear is present — the Bear is never paired with other enemies

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
`[OPEN]` The Judge stats, mechanics, omen contributions, and narrative framing to be defined in a dedicated boss design session. The Judge is the guardian whose judgment the soul must pass — failing means rebirth (run ends), passing means the soul advances toward Solace.

#### Scenario: Boss placement
- **WHEN** the player completes all rooms on Floor 3
- **THEN** The Judge is the final encounter

#### Scenario: [OPEN] Judge mechanics
- **WHEN** The Judge is designed
- **THEN** its mechanics MUST reference the soul's goal (Solace) narratively and present a genuine mechanical challenge tuned for one floor of preparation
