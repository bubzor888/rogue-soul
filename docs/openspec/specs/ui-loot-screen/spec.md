## Purpose
Defines the layout, card structures, and interaction rules for the post-combat loot/reward screen. The loot screen is a ternary choice: take the durability item, take the consumable, or decline both. It is presented after every completed combat encounter.

## Requirements

### Requirement: [UI-LOOT-001] Three-Zone Portrait Layout
The loot screen SHALL use a single-column portrait layout with three stacked zones in this top-to-bottom order: (1) inventory count strip, (2) static loot image, (3) stacked offer cards followed by the decline bar. This ordering creates a reveal beat — inventory context → reward visual → decision → decline.

#### Scenario: Zone order is count strip → image → cards → decline
- **WHEN** the loot screen is displayed
- **THEN** the inventory count strip appears at the top, then the loot image, then the two stacked offer cards, then the "Leave both" bar at the bottom

#### Scenario: Cards are stacked vertically
- **WHEN** both loot options are shown
- **THEN** the durability card appears above the consumable card; cards are full-width stacked, not side-by-side columns

### Requirement: [UI-LOOT-002] Inventory Count Strip
The top strip SHALL show three plain category counts — weapons held / support items held / consumables held (using the player-facing labels defined in `HLD-ITEMS-012`) — as neutral tallies using the same badge vocabulary as the combat top bar. The strip SHALL NOT be labelled or styled to reference its relationship to the floor boss's item-count scaling mechanic. The strip doubles as comparison context for loot decisions; the cards themselves carry no inline comparison to held items.

#### Scenario: Three categories shown
- **WHEN** the loot screen opens
- **THEN** the count strip shows separate tallies for weapons, support items, and consumables

#### Scenario: No boss framing
- **WHEN** the count strip is displayed
- **THEN** no label, icon, or tooltip references the boss's item-count scaling mechanic

### Requirement: [UI-LOOT-003] Static Loot Image
A single shared loot image SHALL span the full width above the cards. The image SHALL be height-capped so it remains a supporting reward beat and does not compete with the cards for first-glance dominance.

#### Scenario: Image is category-agnostic
- **WHEN** any loot combination is presented
- **THEN** the same shared loot image is used regardless of which specific items are offered

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

### Requirement: [UI-LOOT-005] Consumable Card Layout
The consumable card SHALL use an effect-forward layout: identity row (effect icon + name + "Consumable" kind line), an effect line as the hero element (verb + bold status keyword preceded by the status icon used in combat, matching `UI-GLOBAL-001`), a target line, and a one-use footnote. No tooltip is attached to status keywords on this card.

#### Scenario: Effect line is hero
- **WHEN** a consumable card is shown
- **THEN** the effect line (e.g. "Apply **Poisoned**" with the Poisoned status icon inline) is the visually dominant element

#### Scenario: No tap-to-tooltip on keyword
- **WHEN** a consumable card is displayed
- **THEN** status keywords are not tappable; the card operates as "tap anywhere = take"

#### Scenario: Target line present
- **WHEN** a consumable card is shown
- **THEN** a target line (e.g. "Target: one enemy / all enemies / vessel") appears below the effect line

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

### Requirement: [UI-LOOT-007] Decline Bar
A full-width "Leave both" bar SHALL appear below the two offer cards, separated from the lower card by a larger gap than the gap between the two cards themselves. The decline bar SHALL be visually lighter than a card (not a co-equal third card) but clearly legible as a real option.

#### Scenario: Decline bar has larger gap above it
- **WHEN** the loot screen is displayed
- **THEN** the gap between the "Leave both" bar and the lower card is larger than the gap between the two offer cards

#### Scenario: Decline bar is visually subordinate to cards
- **WHEN** the loot screen is displayed
- **THEN** the "Leave both" bar is clearly lighter in visual weight than either offer card

### Requirement: [UI-LOOT-008] Asymmetric Commit Model
Tapping an offer card SHALL take that item immediately (no confirmation); the other option is then lost. Tapping "Leave both" SHALL require a confirmation step before declining. This asymmetry exists because taking an item is the common case (fast, low friction) while declining is rarer, more consequential, and the most likely mis-tap target.

#### Scenario: Card tap is immediate
- **WHEN** the player taps an offer card
- **THEN** the item is taken immediately and the other option is discarded, with no confirmation step

#### Scenario: Decline requires confirmation
- **WHEN** the player taps "Leave both"
- **THEN** a confirmation step is shown before the decline is committed
