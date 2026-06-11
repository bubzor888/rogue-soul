## MODIFIED Requirements

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

## ADDED Requirements

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
