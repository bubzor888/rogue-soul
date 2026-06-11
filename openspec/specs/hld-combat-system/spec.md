## Purpose
Defines the core rules of the combat system — turn structure, action economy, damage types, status effects, vulnerability, the omen system, enemy intent, cleanse, default strike, and post-combat loot for both standard and elite encounters.
## Requirements
### Requirement: [HLD-COMBAT-001] Turn-Based Only
Combat SHALL be turn-based with no real-time or action elements. There is no need to tune action feel, hitboxes, or input latency.

#### Scenario: No time pressure
- **WHEN** it is the player's turn
- **THEN** no timer exists; the player may take as long as needed to decide

---

### Requirement: [HLD-COMBAT-004] Action Economy
Each player turn SHALL consist of three independent action buckets. Each bucket may be used once per turn. Support and Consumable buckets are optional. The Attack bucket is mandatory — it must always be resolved.

| Bucket | Source | Cost | Limit | Optional |
|---|---|---|---|---|
| **Attack** | Attack ability, attack item, or Default Strike | — | 1 per turn | No — must always resolve |
| **Support** | Non-attack ability (charged) | Free | 1 per turn | Yes |
| **Consumable** | Single-use non-attack item | Free | 1 per turn | Yes |

**Attack bucket priority:** Attack ability → Attack item → Default Strike. The player uses whichever is available and preferred; all three options compete for the single Attack slot.

**Companion actions:** At the end of the player's turn, each active companion takes one automatic action from their ability set. The player spends no bucket uses on companion actions.

**A fully-resourced turn** uses all three buckets: trigger a support ability, use a consumable, and make an attack.

#### Scenario: One attack per turn
- **WHEN** the player uses an attack item on their turn
- **THEN** they cannot also use an attack ability in the same turn — both compete for the single Attack bucket

#### Scenario: Support does not consume attack
- **WHEN** the player uses a non-attack ability (Support bucket)
- **THEN** they can still use an attack ability or attack item in the same turn

#### Scenario: Consumable does not consume attack
- **WHEN** the player uses a consumable item (Consumable bucket)
- **THEN** they can still resolve the Attack bucket in the same turn

#### Scenario: Attack bucket is mandatory
- **WHEN** the player has no attack ability charges and no attack items
- **THEN** the Default Strike is used to resolve the Attack bucket — the player always acts offensively

#### Scenario: Companion acts automatically
- **WHEN** the player ends their turn
- **THEN** each active companion resolves one automatic action from their ability set with no player input required

---

### Requirement: [HLD-COMBAT-005] Damage Types
All damage SHALL have a type. The confirmed types are Physical, Fire, Lightning, Ice, and Poison. Damage type is independent of delivery mechanism.

| Type | Notes |
|---|---|
| Physical | Weapons, default strike. No intrinsic DoT. Vulnerable (Physical) applied via items only. |
| Fire | Elemental. Vulnerable (Fire) applied directly by items. |
| Lightning | Elemental. Vulnerable (Lightning) applied directly by items. |
| Ice | Elemental. Vulnerable (Ice) applied directly by items. |
| Poison | Elemental. **No vulnerability** — escalating DoT is strong enough alone. |

#### Scenario: Elemental vulnerability
- **WHEN** a unit has Vulnerable (Fire) and receives fire damage
- **THEN** that fire damage is multiplied by ×1.5 (see `HLD-COMBAT-007` for full Vulnerable rules)

#### Scenario: Poison no vulnerability
- **WHEN** a unit has the Poisoned status and receives poison damage
- **THEN** no vulnerability multiplier applies

#### Scenario: [OPEN·MVP4] Additional damage types
- **WHEN** tier 3 vessels (Battle Wizard, Shaman) and later floors are designed
- **THEN** additional elemental damage types may be added

### Requirement: [HLD-COMBAT-006] Status Effects
Status effects SHALL be applied as individual omens on a specific target. They clear at the next omen reset. Duration is determined by the timer card drawn (1–3 turns). See `HLD-COMBAT-008` for omen mechanics.

**Balancing assumption:** Assume 2 ticks as the typical case when setting all per-tick values.

| Status | Type | Primary effect |
|---|---|---|
| Burning | Per-turn / Offensive | Flat fire damage per tick |
| Shocked | Omen-triggered / Offensive | Stuns at omen shift |
| Chilled | Per-turn / Offensive+Defensive | Creeping flat damage reduction per tick (amounts defined by omen card) |
| Poisoned | Per-turn / Offensive | Escalating poison damage (triples each tick); no vulnerability |
| Bleed | Per-turn / Offensive | Decaying physical damage per tick: deals damage equal to current stacks, then stacks halve (floor); clears when stacks reach 0 |
| Mending | Per-turn / Defensive | Heals X HP per tick |
| Hardened | Per-turn / Defensive | Absorbs up to X incoming damage per tick; resets each tick |
| Vulnerable (Fire) | Offensive | Amplifies all fire damage dealt to target by ×1.5 (see `HLD-COMBAT-007`) |
| Vulnerable (Lightning) | Offensive | Amplifies all lightning damage dealt to target by ×1.5 (see `HLD-COMBAT-007`) |
| Vulnerable (Ice) | Offensive | Amplifies all ice damage dealt to target by ×1.5 (see `HLD-COMBAT-007`) |
| Vulnerable (Physical) | Offensive | Amplifies all physical damage dealt to target by ×1.5 (see `HLD-COMBAT-007`) |

Elemental statuses (Burning, Shocked, Chilled) do **not** co-apply a Vulnerable status. Vulnerable must be applied separately via a dedicated item (see `HLD-COMBAT-007`).

#### Scenario: Burning tick damage
- **WHEN** a unit has the Burning status and an omen tick occurs
- **THEN** the unit takes flat fire damage (amount defined in LLD)

#### Scenario: Shocked stun timing
- **WHEN** a unit has the Shocked status and the omen shift occurs
- **THEN** that unit skips their next action

#### Scenario: Chilled flat damage reduction
- **WHEN** a unit has the Chilled status
- **THEN** they deal less damage each turn; the reduction is a flat value that increases each tick (amounts defined by the omen card); the reduction can never reduce damage to zero

#### Scenario: Poison escalation mechanic
- **WHEN** a unit has the Poisoned status and an omen tick occurs
- **THEN** the unit takes damage equal to the current poison value, and the poison value is tripled for the next tick

#### Scenario: Poison starting value is LLD
- **WHEN** the Poisoned status is applied
- **THEN** the starting poison value and any external modifications to it are defined in the LLD (e.g., 2→6→18 is one possible tuning, not a fixed rule)

#### Scenario: Bleed tick — damage then decay
- **WHEN** a unit has the Bleed status and an omen tick occurs
- **THEN** the unit takes physical damage equal to the current Bleed stacks, then the stacks are reduced to floor(stacks / 2)

#### Scenario: Bleed clears when stacks reach zero
- **WHEN** a Bleed tick reduces the stacks to 0 (i.e. stacks were 1 before the tick: floor(1/2) = 0)
- **THEN** the unit takes 1 physical damage and the Bleed status clears immediately

#### Scenario: Bleed decay sequence
- **WHEN** a unit has Bleed applied with 5 stacks
- **THEN** over three ticks it deals 5 damage (→2 stacks), then 2 damage (→1 stack), then 1 damage and clears

#### Scenario: Bleed clears at omen reset
- **WHEN** the omen cycle resets
- **THEN** any active Bleed status on any unit is cleared, regardless of remaining stacks

---

### Requirement: [HLD-COMBAT-007] Vulnerability
Vulnerable SHALL be a status effect that amplifies all damage of a specific type dealt to the affected target by ×1.5. It is applied, tracked, and cleared using the same status mechanics as all other statuses (timer card duration, clears at omen reset — see `HLD-COMBAT-006` and `HLD-COMBAT-008`).

Vulnerable can be applied by:
- Items directly (e.g., Combustible Oil → Vulnerable (Fire), Brittle Charm → Vulnerable (Physical), Frost Shard → Vulnerable (Ice), Fulminating Powder → Vulnerable (Lightning))

Two sources of the same Vulnerable type on one target do not stack — still ×1.5, not ×2.25.

**Resistance + Vulnerable cancellation:** If a unit has both Resistance (×0.5) and Vulnerable (×1.5) to the same damage type, they cancel out. The unit takes normal (×1.0) damage of that type. Resistance and Vulnerable do not produce a net benefit together.

#### Scenario: No vulnerability stacking
- **WHEN** a unit has Vulnerable (Fire) from two separate sources
- **THEN** fire damage is multiplied by ×1.5 once, not ×2.25

#### Scenario: Vulnerable clears independently
- **WHEN** Burning expires on a unit that still has Vulnerable (Fire) from a separate item application
- **THEN** Vulnerable (Fire) remains active until its own timer expires

#### Scenario: Resistance and Vulnerable cancel
- **WHEN** a Fire Elemental (Resistance: Fire ×0.5) has Vulnerable (Fire) ×1.5 applied to it
- **THEN** the Fire Elemental takes normal fire damage (×1.0) — the resistance and vulnerability cancel out

---

### Requirement: [HLD-COMBAT-008] Omen System
All combat in Soul Protocol SHALL be governed by the omen system. Every combat turn three omen cards are drawn from a shared deck; the player chooses one card to apply to a side; one is applied randomly to the other side; the third sets the cycle duration. Full mechanics are defined in `hld-omen-system`. Confirmed omen cards are defined in `lld-omen-cards`.

The omen deck is assembled fresh per combat from four sources: vessel cards, item cards, floor cards, and enemy cards. Enemy cards are present only while those enemies are alive. See `HLD-OMEN-004`.

#### Scenario: Omen draw every turn
- **WHEN** a new combat turn begins
- **THEN** if the cycle timer has expired, three omen cards are drawn and resolved per `HLD-OMEN-001`

#### Scenario: Deck composition shifts per combat
- **WHEN** the player enters a combat against a Skeleton
- **THEN** the Skeleton's Emboldened (Physical) and Grave Knit cards (`LLD-ENEMIES-004`) are included in the deck for that combat only

---

### Requirement: [HLD-COMBAT-009] Enemy Intent
Enemy intents SHALL be telegraphed — visible to the player before the enemy acts. Each enemy shows a specific declaration of their intended action for the current turn. Intents are instance-based: two enemies both planning an attack show two separate intent indicators.

Intents are a **live forecast** that recalculates as the player acts within their turn. Killing an enemy removes their intent; stunning or disabling suppresses it; applying a debuff may downgrade it. Intent updates are immediate and visual, paired with a distinct audio cue.

**Intent selection — weighted random:** At the start of each turn, each enemy selects its intent via a weighted random roll over its intent table. Weights are defined per enemy in `lld-enemies` and sum to 100%.

**Trigger overrides:** An enemy MAY have one or more triggers that bypass the random roll. When a trigger condition is met (e.g. turn number, health threshold, or active status), the corresponding intent is forced for that turn regardless of the random result. Multiple triggers are evaluated in priority order; the highest-priority matching trigger wins.

**Consecutive limiting:** Each intent MAY declare a maximum consecutive count. When the rolling enemy has selected the same intent for that many turns in a row, the engine re-rolls until a different intent is selected. See `LLD-ARCH-017` for the `last_intent_id` and `intent_streak` runtime fields that track this.

**Charge→Release:** Some intents span two turns. See `HLD-COMBAT-014`.

**Non-attack intent display:** Non-damage intents (status application, doing nothing) are displayed using a generic non-attack indicator. The specific meaning is learned through play and recorded in the Soul Codex per enemy.

Intent visuals are learned through play. Once an enemy is recorded in the Soul Codex, the Codex entry describes that enemy's intents for reference.

#### Scenario: Intent visible before enemy acts
- **WHEN** a combat turn begins
- **THEN** each enemy's intent for this turn is visible to the player before the player commits any action

#### Scenario: Intent updates on kill
- **WHEN** the player kills an enemy during their turn
- **THEN** that enemy's intent indicator disappears immediately

#### Scenario: Intent updates on stun
- **WHEN** the player applies Shocked to an enemy during their turn
- **THEN** that enemy's intent is shown as suppressed/broken for this turn

#### Scenario: Weighted random selection
- **WHEN** an enemy resolves its intent at the start of a turn with no active trigger override
- **THEN** the intent is selected by a random roll weighted by the percentages in that enemy's intent table

#### Scenario: Trigger overrides random roll
- **WHEN** an enemy resolves its intent and a trigger condition is met
- **THEN** the forced intent from the trigger is used; the random roll does not occur

#### Scenario: Consecutive re-roll
- **WHEN** an enemy resolves its intent and the roll produces the same intent as the previous turn AND that intent has reached its max consecutive count
- **THEN** the engine re-rolls until a different intent is selected

---

### Requirement: [HLD-COMBAT-010] Cleanse
The game SHALL support cleanse consumables that clear status effects by category. Cleanse items cover distinct status categories — no single item clears all statuses. The specific items and their category assignments are defined in `LLD-ITEMS-001`.

#### Scenario: Cleanse is category-scoped
- **WHEN** a player uses a cleanse consumable
- **THEN** only the status effects belonging to that item's category are cleared; statuses in other categories remain

#### Scenario: No universal cleanse
- **WHEN** the player has one cleanse consumable
- **THEN** they cannot clear all status effect categories in a single use

---

### Requirement: [HLD-COMBAT-011] Default Strike
Every vessel SHALL have access to a default strike that is always available with no charges and does not consume item durability. It serves as the guaranteed fallback for the Attack bucket.

#### Scenario: Always available
- **WHEN** a vessel has zero item charges remaining
- **THEN** the default strike is still available as a combat action

#### Scenario: No durability cost
- **WHEN** a vessel uses the default strike
- **THEN** no item durability is consumed

---

### Requirement: [HLD-COMBAT-012] Post-Combat Loot
Every completed combat encounter SHALL present the player with a choice between two fully revealed loot options: one durability item from the floor's durability pool, or one consumable from the floor's consumable pool. The player takes one; the other is lost.

#### Scenario: Loot choice
- **WHEN** a combat encounter is completed
- **THEN** exactly two loot options are shown (one durability, one consumable) and the player selects one

### Requirement: [HLD-COMBAT-013] Elite Combat Rewards
Elite combats SHALL follow the same post-combat loot format as standard combats (see `HLD-COMBAT-012`) — the player chooses one of two fully revealed options — but the options are drawn from elite-tier pools rather than standard-tier pools. Standard combats draw from normal-tier pools; elite combats draw from elite-tier pools. The tier distinction is the primary additional reward for accepting the harder fight.

`[OPEN·MVP1]` Elite-tier pool contents (specific items eligible as elite drops) to be defined in `lld-items`.

#### Scenario: Elite loot uses elevated pools
- **WHEN** the player completes an elite combat
- **THEN** the two loot options are drawn from elite-tier pools, not the standard floor pools used after normal combats

#### Scenario: Same choice format as standard loot
- **WHEN** elite loot is presented
- **THEN** exactly two options are shown (one elite-tier durability item, one elite-tier consumable) and the player selects one; the format is identical to `HLD-COMBAT-012`

---

### Requirement: [HLD-COMBAT-014] Charge→Release Multi-Turn Intent Pattern
An enemy intent MAY be designated as Charge→Release. This pattern spans exactly two turns:

- **Charge turn:** The enemy telegraphs the incoming attack but deals no damage and applies no status. The player has one complete turn of normal actions before the attack resolves.
- **Release turn:** The intent executes unconditionally. The release is not re-rolled and is not subject to consecutive limiting — it fires regardless of any roll or streak check. The release delivers its full payload as specified in `lld-enemies`.

If the enemy is killed or stunned (Shocked) during the charge turn, the release never fires.

#### Scenario: Charge turn deals no damage
- **WHEN** an enemy begins a Charge→Release intent
- **THEN** on the charge turn the enemy's indicator shows the incoming attack but the player takes no damage

#### Scenario: Release fires unconditionally
- **WHEN** an enemy completed a charge on the previous turn and is still alive and un-stunned
- **THEN** the release executes on this turn regardless of any intent roll or streak state

#### Scenario: Kill during charge cancels release
- **WHEN** the player kills a charging enemy during the charge turn
- **THEN** the release never occurs

#### Scenario: Stun during charge cancels release
- **WHEN** the player applies Shocked to a charging enemy during the charge turn
- **THEN** the release is suppressed for this turn

---

### Requirement: [HLD-COMBAT-015] Chilled Status Idempotency
Applying the Chilled status to a target that already has Chilled active SHALL have no effect. The existing Chilled status is not refreshed, extended, stacked, or modified in any way by the redundant application.

This rule applies symmetrically — it covers both player-applied Chilled (via items) and enemy-applied Chilled (via enemy intents).

#### Scenario: Redundant Chilled application has no effect
- **WHEN** Chilled is applied to a target that already has an active Chilled status
- **THEN** the target's Chilled status is unchanged; no new timer is set

#### Scenario: Chilled applied to un-Chilled target
- **WHEN** Chilled is applied to a target that does not currently have Chilled
- **THEN** Chilled is applied normally with a timer determined by the relevant omen card or ability

---

### Requirement: [HLD-COMBAT-016] Enemy Damage Variance
Enemy damage SHALL be defined as a min–max range per damage intent. On each attack, the engine rolls a value uniformly within that range using the COMBAT RNG stream. Player weapon damage SHALL always be a flat value and is never subject to variance.

This asymmetry is intentional: enemy variance creates urgency and read-the-room decisions (prioritise the enemy currently hitting harder); player flatness enables precise resource planning.

#### Scenario: Enemy damage roll within range
- **WHEN** an enemy executes a damage intent
- **THEN** the damage dealt is a value rolled uniformly between damage_min and damage_max (inclusive) using the COMBAT stream

#### Scenario: Player damage is always flat
- **WHEN** the player uses any weapon or ability
- **THEN** the damage value is the exact value defined in the item or ability data — no variance is applied

---

## Open Items / Follow-on Work

### [FOLLOW-ON] Remove `force_row` from lld-abilities
`ForceRowHandler` in `lld-abilities` (`LLD-ABILITIES-001`) was tied to the row-targeting system that no longer exists. A follow-on `/opsx:propose` should remove it from the handler table.

