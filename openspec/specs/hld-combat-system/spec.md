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
Each player turn SHALL consist of three independent action buckets. Each bucket may be used once per turn. Support and Consumable buckets are optional. The Action bucket is mandatory — it must always be resolved.

| Bucket | Source | Cost | Limit | Optional |
|---|---|---|---|---|
| **Action** | Attack ability, attack item, Default Strike, or Evade | — | 1 per turn | No — must always resolve |
| **Support** | Non-attack ability (charged) | Free | 1 per turn | Yes |
| **Consumable** | Single-use non-attack item | Free | 1 per turn | Yes |

**Action bucket options:** Attack ability, attack item, Default Strike, and Evade all compete for the single Action slot. When attacking, priority is: Attack ability → Attack item → Default Strike. Evade is always a legal alternative to any attack option.

**Companion actions:** At the end of the player's turn, each active companion takes one automatic action from their ability set. The player spends no bucket uses on companion actions.

**A fully-resourced turn** uses all three buckets: trigger a support ability, use a consumable, and resolve an action (attack or evade).

#### Scenario: One action per turn
- **WHEN** the player uses an attack item on their turn
- **THEN** they cannot also use an attack ability or Evade in the same turn — all three compete for the single Action bucket

#### Scenario: Support does not consume action
- **WHEN** the player uses a non-attack ability (Support bucket)
- **THEN** they can still resolve the Action bucket in the same turn

#### Scenario: Consumable does not consume action
- **WHEN** the player uses a consumable item (Consumable bucket)
- **THEN** they can still resolve the Action bucket in the same turn

#### Scenario: Action bucket is mandatory
- **WHEN** the player has no attack ability charges and no attack items
- **THEN** the player must resolve the Action bucket with either Default Strike or Evade

#### Scenario: Companion acts automatically
- **WHEN** the player ends their turn
- **THEN** each active companion resolves one automatic action from their ability set with no player input required

#### Scenario: Support and Consumable available when evading
- **WHEN** the player chooses Evade as their Action bucket resolution
- **THEN** the Support and Consumable buckets remain available for use on the same turn

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
Status effects SHALL be applied as individual StatusInstances on a specific target. They clear at the next omen reset. Duration is determined by the timer card drawn (1–3 turns). See `HLD-COMBAT-008` for omen mechanics.

**Status trigger types:** Statuses are either **per-tick** (`trigger: "tick"`) — effect fires on every omen tick while active — or **shift-triggered** (`trigger: "shift"`) — effect fires once at the omen shift when the status expires and does nothing on intermediate ticks.

**Parameterized statuses:** Some statuses carry a type qualifier in `string_param` on the StatusInstance (see `LLD-ARCH-017`). The type determines which damage type the effect applies to; the `status_id` identifies the effect category.

**Balancing assumption:** Assume 2 ticks as the typical case when setting all per-tick values.

| Status | Trigger | Type | Primary effect |
|---|---|---|---|
| Burning | Per-tick | Offensive | Flat fire damage per tick |
| Shocked | Shift-triggered | Offensive | At omen shift: sets is_stunned on the target — Action bucket blocked for their next turn; Support and Consumable buckets remain available |
| Exposed | Shift-triggered | Offensive | At omen shift: applies a `"vulnerable:physical"` StatusInstance to the target with `remaining_ticks` equal to the next omen cycle's timer value |
| Chilled | Per-tick | Offensive+Defensive | Creeping flat damage reduction per tick (amounts defined by omen card) |
| Poisoned | Per-tick | Offensive | Escalating poison damage (triples each tick); no vulnerability |
| Bleed | Per-tick | Offensive | Decaying physical damage per tick: deals damage equal to current stacks, then stacks halve (floor); clears when stacks reach 0 |
| Mending | Per-tick | Defensive | Heals X HP per tick |
| Hardened | Per-tick | Defensive | Absorbs up to X incoming damage per tick; resets each tick |
| Vulnerable | Passive | Offensive | Amplifies all damage of the specified type dealt to target by ×1.5 (see `HLD-COMBAT-007`); type carried in `string_param` on the StatusInstance (e.g. `"fire"`, `"physical"`, `"ice"`, `"lightning"`) |
| Type Convert | Passive | Offensive | Converts all outgoing damage from the unit to the type in `string_param`; only one instance active at a time — a new application replaces the existing one; clears at omen reset like all statuses |
| Emboldened | Passive | Offensive | Type carried in `string_param`. **Physical:** adds flat bonus to target's outgoing physical damage per hit (value defined in LLD). **Elemental (fire/lightning/ice):** multiplies target's outgoing damage of that type by ×1.5. |
| Frenzied | Passive | Offensive | Composite: unit simultaneously has `"vulnerable:physical"` effect (incoming ×1.5) and `"emboldened:physical"` effect (outgoing flat bonus); applied as one status |

Elemental statuses (Burning, Chilled) do **not** co-apply a Vulnerable status. Vulnerable must be applied separately via a dedicated item (see `HLD-COMBAT-007`) or via the Exposed shift trigger.

#### Scenario: Burning tick damage
- **WHEN** a unit has the Burning status and an omen tick occurs
- **THEN** the unit takes flat fire damage (amount defined in LLD)

#### Scenario: Shocked stun — Action bucket blocked only
- **WHEN** a unit has the Shocked status and the omen shift occurs
- **THEN** that unit's Action bucket is blocked for their next turn; Support and Consumable buckets remain available

#### Scenario: Exposed fires at shift — Vulnerable deferred to next cycle
- **WHEN** a unit has the Exposed status and the omen shift occurs
- **THEN** a `"vulnerable:physical"` StatusInstance is applied to that unit with remaining_ticks equal to the next omen cycle's timer value; the Exposed status is then cleared

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

#### Scenario: Emboldened (Physical) flat damage bonus
- **WHEN** a unit has an Emboldened StatusInstance with `string_param: "physical"` and makes a physical attack
- **THEN** the attack deals additional flat physical damage (value defined in LLD) on top of base damage

#### Scenario: Emboldened (Fire) multiplier
- **WHEN** a unit has an Emboldened StatusInstance with `string_param: "fire"` and deals fire damage
- **THEN** the fire damage is multiplied by ×1.5

#### Scenario: Frenzied — both sides simultaneously
- **WHEN** a unit has the Frenzied status and makes a physical attack
- **THEN** the attack gains the `"emboldened:physical"` flat bonus; incoming physical attacks against that unit are amplified by ×1.5 via the `"vulnerable:physical"` effect

#### Scenario: Frenzied — single status, single clear
- **WHEN** a unit with the Frenzied status is cleansed of Frenzied
- **THEN** both the `"vulnerable:physical"` and `"emboldened:physical"` effects are removed simultaneously; they do not need to be cleared separately

#### Scenario: Type Convert — player side
- **WHEN** a Type Convert StatusInstance with `string_param: "fire"` is active on the player
- **THEN** all player attack damage is treated as fire damage; resistance and vulnerability checks at steps 5 and 6 use fire as the type

#### Scenario: Type Convert replacement
- **WHEN** the player already has Type Convert (fire) active and receives a Type Convert (ice) StatusInstance
- **THEN** the fire StatusInstance is replaced; the player's attacks now deal ice damage

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

### Requirement: [HLD-COMBAT-017] Evade
Evade SHALL be a legal Action bucket option for both the player and enemies. A unit that chooses Evade deals no damage that turn. All incoming hits against an evading unit have a 35% chance to miss for the remainder of that round. Evade lasts exactly one round and is tracked as a per-turn runtime flag, not as a status effect (see `LLD-ARCH-017`).

**Miss resolution:** A miss roll is applied per incoming hit, not per attack. For multi-hit attacks, each individual hit rolls independently. On a miss: the hit deals no damage and applies no status effect. The attack did not connect.

**Evade and Vulnerable:** The miss roll is resolved before vulnerability or any other damage modifier (see `LLD-ARCH-019` damage resolution order). Evade does not interact with or cancel the Vulnerable status.

**Companion rules:** Companion actions that deal damage or apply status to an evading enemy are subject to the 35% miss roll. Companion actions that benefit the player (heals, intercepts, buffs) are not blocked by the player's own Evade state.

**Weapon durability preservation:** When attacking an evading enemy, if ALL targeted enemies evaded and ALL miss rolls triggered, weapon item charges (action_bucket: "attack", breaks_at_zero: true) are NOT consumed that turn. If at least one hit connected (any targeted enemy was not evading, or any miss roll did not trigger), the weapon charge IS consumed. Consumable bucket items are always consumed regardless of whether the hit connected.

**Unlimited use:** There is no per-run or per-combat limit on Evade. A unit may choose Evade every turn indefinitely; the sacrifice of the Action bucket is the natural constraint.

#### Scenario: Evade blocks incoming hit
- **WHEN** the player chooses Evade and an enemy makes a single attack
- **THEN** CombatResolver rolls a 35% miss chance using the COMBAT stream; on a miss the attack deals no damage and applies no status

#### Scenario: Multi-hit attack rolls per hit
- **WHEN** the player is evading and an enemy uses a multi-hit attack (e.g. Double Swipe)
- **THEN** each individual hit rolls the 35% miss chance independently; one hit may land while another misses

#### Scenario: Miss blocks status
- **WHEN** the player is evading and an enemy's attack that would apply Chilled misses
- **THEN** the player takes no damage and does not gain the Chilled status

#### Scenario: Evade does not cancel Vulnerable
- **WHEN** the player is evading and also has Vulnerable (Physical) applied
- **THEN** the miss roll is performed first; if the hit lands, the Vulnerable multiplier applies normally

#### Scenario: Weapon charge preserved on full miss
- **WHEN** the player attacks a single evading enemy and the miss roll triggers
- **THEN** the weapon item's remaining_charges is not decremented

#### Scenario: Weapon charge consumed if any hit lands
- **WHEN** the player's weapon targets two enemies, one evading and one not
- **THEN** the weapon charge IS consumed; at least one hit connected

#### Scenario: Consumable always consumed
- **WHEN** the player uses a consumable-bucket item and its target is evading
- **THEN** the consumable item is spent regardless of whether the hit connected

#### Scenario: Companion attack respects enemy Evade
- **WHEN** an enemy is evading and a companion (e.g. the Shadow) attacks that enemy
- **THEN** the companion's attack rolls the 35% miss chance like any other hit

#### Scenario: Companion benefit unaffected by player Evade
- **WHEN** the player is evading and a companion triggers a beneficial effect (e.g. Life Mote revive)
- **THEN** the companion's beneficial effect resolves normally

#### Scenario: Evade lasts one round
- **WHEN** the player chose Evade on the previous turn and a new player turn begins
- **THEN** is_evading resets to false; subsequent enemy attacks do not benefit from the prior Evade

---

### Requirement: [HLD-COMBAT-018] Magnitude-Additive Status Reapplication
Applying a magnitude-based status to a target that already has an active instance of that status SHALL increment the existing instance's `magnitude` by the new application's magnitude value, rather than creating a new StatusInstance or having no effect.

This rule applies to: **Burning**, **Poisoned**, and **Bleed**. It does NOT apply to Chilled, which is explicitly idempotent (see `HLD-COMBAT-015`).

**Burning:** reapplication adds to the fire damage dealt per tick.
**Poisoned:** reapplication adds to the current poison damage value (before the tripling escalation applies on that tick).
**Bleed:** reapplication adds to the current stack count.

The status's `remaining_ticks` is NOT changed by a reapplication — only `magnitude` is affected. The existing timer continues on its original schedule.

#### Scenario: Burning magnitude stacks on reapplication
- **WHEN** Burning with magnitude 2 is applied to a target that already has an active Burning StatusInstance with magnitude 3
- **THEN** the existing Burning StatusInstance's magnitude becomes 5; no new StatusInstance is created; remaining_ticks is unchanged

#### Scenario: Burning first application sets magnitude normally
- **WHEN** Burning is applied to a target that has no active Burning StatusInstance
- **THEN** a new Burning StatusInstance is created with the application's magnitude value and remaining_ticks from the omen timer

#### Scenario: Poisoned magnitude stacks on reapplication
- **WHEN** Poisoned with magnitude 2 is applied to a target that already has an active Poisoned StatusInstance with magnitude 6
- **THEN** the existing Poisoned StatusInstance's magnitude becomes 8; remaining_ticks is unchanged; the tripling escalation on the next tick will use 8 as the base

#### Scenario: Bleed stacks add on reapplication
- **WHEN** Bleed with magnitude 3 is applied to a target that already has an active Bleed StatusInstance with magnitude 4
- **THEN** the existing Bleed StatusInstance's magnitude becomes 7; the decay sequence resumes from 7 on the next tick

#### Scenario: Chilled reapplication remains idempotent
- **WHEN** Chilled is applied to a target that already has an active Chilled StatusInstance
- **THEN** no change occurs — Chilled is governed by `HLD-COMBAT-015`, not this rule

---

### Requirement: [HLD-COMBAT-019] Max-Wins Status Reapplication
Applying Hardened or Emboldened to a target that already has an active instance of the same status (same `string_param` for Emboldened) SHALL keep whichever instance has the higher magnitude; a lower-magnitude or equal-magnitude application has no effect.

This rule applies to: **Hardened** and **Emboldened** (both Physical and elemental variants). It does NOT apply to Burning, Poisoned, or Bleed (magnitude-additive per `HLD-COMBAT-018`) or Chilled (idempotent per `HLD-COMBAT-015`).

#### Scenario: Max-wins — lower magnitude application has no effect
- **WHEN** Emboldened (Physical, magnitude 2) is applied to a target that already has Emboldened (Physical) with magnitude 3
- **THEN** the existing StatusInstance with magnitude 3 is unchanged; the incoming application has no effect

#### Scenario: Max-wins — higher magnitude application upgrades
- **WHEN** Emboldened (Physical, magnitude 3) is applied to a target that already has Emboldened (Physical) with magnitude 2
- **THEN** the existing StatusInstance's magnitude is updated to 3

#### Scenario: Max-wins — equal magnitude application has no effect
- **WHEN** Hardened (magnitude 3) is applied to a target that already has Hardened with magnitude 3
- **THEN** the existing StatusInstance is unchanged; this covers the common Totem case where the same magnitude is re-applied each turn

#### Scenario: Max-wins does not apply to magnitude-additive statuses
- **WHEN** Burning, Poisoned, or Bleed is applied to a target that already has an active StatusInstance of the same status
- **THEN** magnitude-additive rules apply (see `HLD-COMBAT-018`), not max-wins; the magnitudes are summed

---

## Open Items / Follow-on Work

### [FOLLOW-ON] Remove `force_row` from lld-abilities
`ForceRowHandler` in `lld-abilities` (`LLD-ABILITIES-001`) was tied to the row-targeting system that no longer exists. A follow-on `/opsx:propose` should remove it from the handler table.

