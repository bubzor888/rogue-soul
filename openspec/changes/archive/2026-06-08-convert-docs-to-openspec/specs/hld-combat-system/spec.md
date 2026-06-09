## ADDED Requirements

### Requirement: [HLD-COMBAT-001] Turn-Based Only
Combat SHALL be turn-based with no real-time or action elements. There is no need to tune action feel, hitboxes, or input latency.

#### Scenario: No time pressure
- **WHEN** it is the player's turn
- **THEN** no timer exists; the player may take as long as needed to decide

---

### Requirement: [HLD-COMBAT-002] Front / Back Row Positioning
Combat SHALL use a front/back row abstraction. No tile grid is rendered or simulated at MVP. Row position is independent per unit — vessel and each companion can occupy different rows.

**Baseline positional rules (numbers are tuning placeholders):**
- Melee attacks can only target front row, or hit back row at significant penalty
- Ranged and magic attacks can target any row freely
- Units in back row receive reduced physical damage
- Moving between rows costs an action
- Some abilities and items explicitly require or reward a specific row position

#### Scenario: Melee reach
- **WHEN** the player uses a melee ability and all player-side units are in the back row
- **THEN** the melee ability either cannot target the enemy front row, or hits at a significant penalty

#### Scenario: Row independence
- **WHEN** the vessel is in the back row
- **THEN** the bound companion MAY be in the front row simultaneously

---

### Requirement: [HLD-COMBAT-003] Row Assignment Persistence
Default row positions SHALL be stored in GameState and persist between combats. Ability-driven repositioning mid-combat carries forward as the new default for the next combat. There is no player-initiated move action — repositioning is only via abilities (ForceRowHandler) or the pre-combat setup screen.

#### Scenario: Post-combat row persistence
- **WHEN** an ability moves the vessel to the front row during combat
- **THEN** the vessel starts the next combat in the front row

#### Scenario: Pre-combat setup
- **WHEN** the player is on the pre-combat setup screen (outside combat)
- **THEN** a SET_DEFAULT_ROW action is available for the vessel and each active companion

---

### Requirement: [HLD-COMBAT-004] Action Economy
`[OPEN]` Exact action economy per turn — either a fixed AP pool or discrete flags (has_moved, has_acted) — is unresolved. CombatState needs either `actions_remaining: int` or discrete boolean flags.

#### Scenario: [OPEN] AP pool vs discrete flags
- **WHEN** the action economy is resolved
- **THEN** CombatState will contain either `actions_remaining: int` (AP pool) or `has_acted: bool` / `has_moved: bool` flags

---

### Requirement: [HLD-COMBAT-005] Damage Types
All damage SHALL have a type. The confirmed types are Physical, Fire, Lightning, Ice, and Poison. Damage type is independent of delivery mechanism.

| Type | Notes |
|---|---|
| Physical | Weapons, default strike. No intrinsic DoT. Vulnerability via items only. |
| Fire | Elemental. Intrinsic vulnerability: Burning status grants Vulnerable (Fire) ×1.5. |
| Lightning | Elemental. Intrinsic vulnerability: Shocked status grants Vulnerable (Lightning) ×1.5. |
| Ice | Elemental. Intrinsic vulnerability: Chilled status grants Vulnerable (Ice) ×1.5. |
| Poison | Elemental. **No vulnerability** — escalating DoT is strong enough alone. |

#### Scenario: Elemental vulnerability
- **WHEN** a unit has the Burning status and receives fire damage
- **THEN** that fire damage is multiplied by ×1.5

#### Scenario: Poison no vulnerability
- **WHEN** a unit has the Poisoned status and receives poison damage
- **THEN** no vulnerability multiplier applies

#### Scenario: [OPEN] Additional damage types
- **WHEN** tier 3 vessels (Battle Wizard, Shaman) and later floors are designed
- **THEN** additional elemental damage types may be added

---

### Requirement: [HLD-COMBAT-006] Status Effects
Status effects SHALL be applied as individual omens on a specific target. They clear at the next omen reset. Duration is determined by the timer card drawn (1–3 turns). See `HLD-COMBAT-008` for omen mechanics.

**Balancing assumption:** Assume 2 ticks as the typical case when setting all per-tick values.

| Status | Type | Primary effect |
|---|---|---|
| Burning | Per-turn / Offensive | Flat fire damage per tick; grants Vulnerable (Fire) |
| Shocked | Omen-triggered / Offensive | Grants Vulnerable (Lightning); stuns at omen shift |
| Chilled | Per-turn / Offensive+Defensive | Creeping damage reduction per tick (10%/20%/30%); grants Vulnerable (Ice) |
| Poisoned | Per-turn / Offensive | Escalating poison damage (2→6→18 per tick); no vulnerability |
| Mending | Per-turn / Defensive | Heals 3 HP per tick |
| Hardened | Per-turn / Defensive | Absorbs up to 3 incoming damage per tick; resets each tick |

#### Scenario: Burning tick damage
- **WHEN** a unit has the Burning status and an omen tick occurs
- **THEN** the unit takes 5 fire damage and is Vulnerable (Fire) ×1.5

#### Scenario: Shocked stun timing
- **WHEN** a unit has the Shocked status and the omen shift occurs
- **THEN** that unit skips their next action

#### Scenario: Chilled damage reduction
- **WHEN** a unit has the Chilled status for 2 ticks
- **THEN** they deal 10% less damage on the first tick and 20% less on the second

#### Scenario: Poison escalation
- **WHEN** a unit has the Poisoned status for 2 ticks (typical)
- **THEN** they take 2 poison damage on tick 1 and 6 poison damage on tick 2 (total 8)

---

### Requirement: [HLD-COMBAT-007] Vulnerability
Vulnerability SHALL amplify all damage of a specific type dealt to the affected target by ×1.5. Two sources of the same vulnerability type on one target do not stack — still ×1.5, not ×2.25.

#### Scenario: No vulnerability stacking
- **WHEN** a unit has Vulnerable (Fire) from both Burning status and Combustible Oil
- **THEN** fire damage is multiplied by ×1.5 once, not ×2.25

---

### Requirement: [HLD-COMBAT-008] Omen System
`[OPEN]` Full omen cycle mechanics are defined in `docs/detailed design/soul_protocol_omens.md`. This spec references omen mechanics but defers full omen requirements to `lld-room-events` pending conversion.

#### Scenario: Omen deck composition
- **WHEN** enemies are present in combat
- **THEN** each enemy contributes its defined omen cards to the deck for the duration of combat

---

### Requirement: [HLD-COMBAT-009] Enemy Intent
`[OPEN]` Whether enemy intent is telegraphed (visible before the enemy acts) or hidden (only revealed after) is unresolved. CombatState.enemy_intents is defined either way; the question is whether it is populated before or after the enemy acts.

#### Scenario: [OPEN] Intent display
- **WHEN** combat UI is implemented
- **THEN** a decision must be made whether enemy_intents is shown to the player before or after the enemy turn

---

### Requirement: [HLD-COMBAT-010] Cleanse
Two cleanse items SHALL exist covering distinct status categories. See `LLD-ITEMS-001` for item details.

| Item | Clears |
|---|---|
| Ointment | Burning, Poisoned |
| Amethyst | Shocked, Chilled, Vulnerable (Physical) |

#### Scenario: Cleanse category separation
- **WHEN** a player uses an Ointment
- **THEN** Shocked and Chilled are NOT cleared (those require Amethyst)

---

### Requirement: [HLD-COMBAT-011] Default Strike
Every vessel SHALL have access to a default strike (Throw Rock equivalent) that is always available with no charges. Base damage: 3. This is the baseline damage reference for all balancing.

#### Scenario: Always available
- **WHEN** a vessel has zero item charges remaining
- **THEN** the default strike is still available as a combat action

---

### Requirement: [HLD-COMBAT-012] Post-Combat Loot
Every completed combat encounter SHALL present the player with a choice between two fully revealed loot options: one durability item from the floor's durability pool, or one consumable from the floor's consumable pool. The player takes one; the other is lost.

#### Scenario: Loot choice
- **WHEN** a combat encounter is completed
- **THEN** exactly two loot options are shown (one durability, one consumable) and the player selects one
