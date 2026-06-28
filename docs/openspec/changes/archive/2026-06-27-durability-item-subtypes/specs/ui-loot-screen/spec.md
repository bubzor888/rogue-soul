## MODIFIED Requirements

### Requirement: [UI-LOOT-002] Inventory Count Strip
The top strip SHALL show three plain category counts — weapons held / support items held / consumables held (using the player-facing labels defined in `HLD-ITEMS-012`) — as neutral tallies using the same badge vocabulary as the combat top bar. The strip SHALL NOT be labelled or styled to reference its relationship to the floor boss's item-count scaling mechanic. The strip doubles as comparison context for loot decisions; the cards themselves carry no inline comparison to held items.

#### Scenario: Three categories shown
- **WHEN** the loot screen opens
- **THEN** the count strip shows separate tallies for weapons, support items, and consumables

#### Scenario: No boss framing
- **WHEN** the count strip is displayed
- **THEN** no label, icon, or tooltip references the boss's item-count scaling mechanic

### Requirement: [UI-LOOT-004] Durability Weapon Card Layout
The durability weapon card is used for Attack (Durability) items — referred to as **weapons** in player-facing UI (see `HLD-ITEMS-012`). It SHALL use a stat-dense layout: identity row (icon + name + kind line), a hero stat box containing a damage type sprite icon above the damage number (number is the visual hero), a side column with Hits and Charges, charge dots (one per charge, no numeric fallback), and a property line for weapons with special behaviour (AoE, burst, cleanse). The damage type SHALL NOT be spelled out as a word — it is encoded by sprite icon shape and tint only (see `ui-global-conventions`).

#### Scenario: Damage number is hero element
- **WHEN** a durability weapon card is shown
- **THEN** the damage number is displayed large and bold as the hero value, with the damage type sprite icon above it

#### Scenario: Charges shown as dots
- **WHEN** a durability weapon card is shown
- **THEN** charges are displayed as filled dots (one per charge); all dots are full for fresh loot drops

#### Scenario: Property line for special behaviour
- **WHEN** a weapon has AoE, burst, or cleanse behaviour
- **THEN** a property line at the bottom of the card states the special behaviour in plain language

#### Scenario: No type label in words
- **WHEN** a durability weapon card is shown
- **THEN** the damage type word (e.g. "Physical", "Fire") does not appear; type is conveyed by sprite icon and tint only

### Requirement: [UI-LOOT-006] Support Item Card Layout
The support item card is used for Support (Durability) items — referred to as **support items** in player-facing UI (see `HLD-ITEMS-012`). It SHALL use a hybrid layout that differs from both the weapon card and the consumable card: effect line leads (effect is the hero, since there is no damage number), using the same inline icon + bold keyword grammar as the consumable card; followed by a divider and a durability strip (charge dots + "Target: Self"). The per-encounter charge drain SHALL be called out explicitly in words (e.g. "Drains 1 charge per room · free action"). The verb "Gain" (self-received) is used instead of "Apply" (inflicted on enemy), implicitly signalling target direction.

#### Scenario: Effect leads, not stat grid
- **WHEN** a support item card is shown
- **THEN** the effect description is the topmost and visually dominant body element, not a damage number

#### Scenario: Per-encounter drain stated explicitly
- **WHEN** a support item card is shown
- **THEN** the charge drain rate is stated in plain language (e.g. "Drains 1 charge per room"), not implied by the dot count alone

#### Scenario: "Gain" verb signals self-target
- **WHEN** a support item card's effect is displayed
- **THEN** the verb "Gain" is used for self-applied effects, distinguishing them from "Apply" used for effects inflicted on enemies
