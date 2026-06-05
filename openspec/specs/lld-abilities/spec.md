
### Requirement: [LLD-ABILITIES-001] Ability Handler Library
The following handler IDs SHALL exist in the CoreEffectHandlers set and be available to any vessel ability or item effect chain:

| Handler ID | What it does |
|---|---|
| `deal_physical_damage` | Applies base damage with row modifier and physical defence |
| `deal_magical_damage` | Applies base damage ignoring physical defence |
| `deal_pure_damage` | Applies flat damage — no modifiers, no defence |
| `heal_target` | Restores HP to target (vessel, companion, or ally) |
| `lifesteal` | Heals caster by a % of context.tags["damage_dealt"] |
| `apply_status` | Applies a named status effect with duration |
| `remove_status` | Removes a named status effect from target |
| `force_row` | Moves any unit to a specified row (ability/enemy use only — not player-initiated) |
| `summon_unit` | Instantiates a summoned companion from a summon template |
| `consume_resource` | Reduces a named resource on caster |
| `chain_if` | Conditional: executes a sub-chain only if a tag condition is met |
| `aoe_spread` | Re-executes a sub-chain against all valid targets |

#### Scenario: Lifesteal tags dependency
- **WHEN** a lifesteal handler executes
- **THEN** it reads `context.tags["damage_dealt"]` written by the preceding damage handler; if no damage handler ran, lifesteal heals 0

#### Scenario: chain_if conditional branching
- **WHEN** a `chain_if` handler is in an ability chain and its condition is true
- **THEN** the nested on_true sub-chain executes; if false the sub-chain is skipped

---

### Requirement: [LLD-ABILITIES-002] Handler Naming Convention
Handler class names SHALL be PascalCase with suffix `Handler`. Their registered handler_id SHALL be snake_case matching the class name.

Example: `DealPhysicalDamageHandler` → `"deal_physical_damage"`

#### Scenario: Naming consistency
- **WHEN** a new handler is implemented
- **THEN** its class name and handler_id follow the stated convention; startup validation fails if the ID is unregistered

---

### Requirement: [LLD-ABILITIES-003] Pilgrim — Good as New
Handler chain for the Good as New ability: targets one ItemInstance in the vessel's item slots; restores `remaining_charges` to `item_data.max_charges`. Uses a to-be-defined `restore_item_charges` handler or equivalent.

#### Scenario: Charge restoration
- **WHEN** Good as New is used on a durability item with N charges remaining
- **THEN** that item's remaining_charges equals its max_charges after resolution

---

### Requirement: [LLD-ABILITIES-004] Default Strike — Throw Rock
All vessels SHALL have a Throw Rock default strike with handler chain: `deal_physical_damage` with `base_damage: 3`, `attack_type: MELEE`. No charges; always usable.

#### Scenario: Throw Rock damage
- **WHEN** Throw Rock is used against a front-row enemy
- **THEN** the enemy takes 3 physical damage (modified by row and defence as per HLD-COMBAT-002)
