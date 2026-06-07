
### Requirement: [LLD-ABILITIES-003] Pilgrim — Good as New
**Type:** Action — **Bucket:** Support (see `HLD-COMBAT-004`; does not consume the Attack bucket).
**Charges:** 1, replenished at floor start.

Handler chain: targets one ItemInstance in the vessel's item slots; restores `remaining_charges` to `item_data.max_charges`. Uses a to-be-defined `restore_item_charges` handler or equivalent.

#### Scenario: Charge restoration
- **WHEN** Good as New is used on a durability item with N charges remaining
- **THEN** that item's remaining_charges equals its max_charges after resolution

#### Scenario: No effect on single-use items
- **WHEN** Good as New is used on a single-use item (max_charges: 1)
- **THEN** the item's remaining_charges is unchanged (already at max)

---

### Requirement: [LLD-ABILITIES-004] Default Strike — Throw Rock
**Type:** Action — **Bucket:** Attack (see `HLD-COMBAT-004`; occupies the Attack bucket).
**Charges:** None — always available.

Handler chain: `deal_damage { base_damage: 3, damage_type: physical }`. See `HLD-COMBAT-011` for the HLD-level default strike requirement.

#### Scenario: Throw Rock damage
- **WHEN** Throw Rock is used against an enemy
- **THEN** the enemy takes 3 physical damage (subject to vulnerability modifiers per `HLD-COMBAT-007`)

---

### Requirement: [LLD-ABILITIES-005] Pilgrim — Read the Road
**Type:** Passive — triggers automatically at combat start; no bucket consumed.
**Charges:** Passive — no charges.

Trigger: at the start of every combat, before the first omen cycle begins. Effect: the player views the top 3 cards of the omen deck and may send any number of them to the bottom. The remaining cards stay on top in their original order. See `LLD-VESSELS-001`.

`[OPEN·MVP1]` Handler chain: requires an omen deck manipulation handler (`peek_omen_deck` or equivalent) that does not yet exist.

#### Scenario: Read the Road at combat start
- **WHEN** a combat encounter begins
- **THEN** before the first omen draw, the player inspects the top 3 omen deck cards and may send any to the bottom

#### Scenario: Remaining cards stay in order
- **WHEN** the player sends 1 card to the bottom during Read the Road
- **THEN** the remaining 2 cards stay on top in their original relative order

---

### Requirement: [LLD-ABILITIES-006] Drifter — Hardy
**Type:** Action — **Bucket:** Support (see `HLD-COMBAT-004`; does not consume the Attack bucket).
**Charges:** 3, replenished at floor start.

Effect: clear one Hardy-clearable debuff or status effect from the vessel. Hardy covers conditions the vessel could plausibly shake off through resilience; it does not cover conditions that would not respond to endurance. See `LLD-VESSELS-002`.

`[OPEN·MVP3]` Hardy-clearable flag to be assigned per debuff/status once the status system is fully designed.
`[OPEN·MVP3]` Handler chain: requires a `remove_status` handler (or filtered variant) that checks the Hardy-clearable flag.

#### Scenario: Hardy clears one debuff
- **WHEN** Hardy is used while the vessel has at least one Hardy-clearable debuff
- **THEN** one Hardy-clearable debuff is removed from the vessel

#### Scenario: Hardy cannot clear non-clearable conditions
- **WHEN** Hardy is used while the vessel has only non-Hardy-clearable conditions
- **THEN** Hardy has no effect (the charge is still consumed)

---

### Requirement: [LLD-ABILITIES-007] Hedge Knight — Last Stand
**Type:** Passive — always active when condition is met; no bucket consumed.
**Charges:** Passive — no charges.

Effect: while the vessel's HP is below 25% of their maximum, all attacks deal ×1.5 damage. Checked at damage resolution time. See `LLD-VESSELS-003`.

`[OPEN·MVP3]` Handler chain: requires a passive damage modifier that checks HP threshold at resolution time.

#### Scenario: Last Stand active below threshold
- **WHEN** the Hedge Knight's HP is below 25% of maximum and an attack resolves
- **THEN** that attack's damage is multiplied by ×1.5 before applying vulnerability or defence

#### Scenario: Last Stand inactive above threshold
- **WHEN** the Hedge Knight's HP is at or above 25% of maximum
- **THEN** no damage multiplier applies

---

### Requirement: [LLD-ABILITIES-008] Hedge Knight — Charge
**Type:** Action — **Bucket:** Support (see `HLD-COMBAT-004`; does not consume the Attack bucket).
**Charges:** `[OPEN·MVP3]` to be set during playtesting.

Effect: applies a Charged buff to the vessel. The next attack resolves with ×2 damage. The buff is consumed on the next attack whether it hits or misses. See `LLD-VESSELS-003`.

`[OPEN·MVP3]` Handler chain: requires a `apply_buff { buff_id: "charged", modifier: 2.0, consume_on_attack: true }` handler or equivalent.

#### Scenario: Charge doubles next attack
- **WHEN** Charge is used and the vessel makes their next attack
- **THEN** that attack deals ×2 damage

#### Scenario: Charge consumed on miss
- **WHEN** Charge is active and the vessel's attack misses
- **THEN** the Charged buff is consumed; no doubling on subsequent attacks

#### Scenario: Last Stand + Charge combined
- **WHEN** Last Stand is active (HP < 25%) and Charge has been used
- **THEN** the next attack deals ×3 damage (×1.5 Last Stand × ×2 Charge)
