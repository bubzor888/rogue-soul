## ADDED Requirements

### Requirement: [UI-COMBAT-009] Action Bucket Item Selection
Tapping any action bucket (Action, Support, or Consumable) SHALL open a selection sheet listing every option currently usable in that bucket. For the Action bucket this is Default Strike (see `HLD-COMBAT-011`) plus every owned weapon. For the Support bucket this is every owned support item plus any vessel support ability. For the Consumable bucket this is every owned consumable.

The sheet SHALL slide up from the bottom and sit over a dimmed version of the combat scene, at a fixed height tall enough to cover the vessel sprite. This height does not grow or shrink with the number of items in the list. Each row in the list SHALL show: a leading icon, the item's name, a one-line summary of its effect (damage and type, or effect description), and a charge readout — either the word "unlimited" (Default Strike) or a row of small circular dots, one per charge.

Spent charges SHALL be rendered as a plain red "X" glyph (not a shaded or greyed-out dot) in place of the dot entirely, not layered inside one. Spent-charge indicators SHALL appear before (to the left of) remaining-charge dots, so the row reads left-to-right as depletion order — the charges a player has already used are the leftmost marks, the charges still available are the rightmost.

The sheet header SHALL include a "cancel" affordance that returns to the default action-bar state without committing any selection.

#### Scenario: Sheet opens over dimmed scene
- **WHEN** the player taps the Action, Support, or Consumable bucket
- **THEN** a selection sheet slides up from the bottom, covering the vessel sprite, while the combat scene above it is shown dimmed

#### Scenario: Row shows charges as dots with red-X spent marks
- **WHEN** an owned weapon with some charges already spent is shown in the selection sheet
- **THEN** each spent charge is rendered as a bare red X (no circle), positioned to the left of the remaining circular charge dots

#### Scenario: Unlimited option has no charge dots
- **WHEN** Default Strike is shown in the Action bucket's selection sheet
- **THEN** its charge readout displays the word "unlimited" instead of any dots

#### Scenario: Cancel returns to default state
- **WHEN** the player taps "cancel" in the selection sheet header
- **THEN** the sheet closes and the action bar returns to its default (nothing selected) state

### Requirement: [UI-COMBAT-010] Selection Sheet Scroll Behavior
When the number of items in a selection sheet's list exceeds the sheet's fixed height, the list SHALL scroll internally rather than the sheet growing taller. A fade-out gradient SHALL appear at the bottom edge of the list whenever there is more content below the visible area, and a thin scrollbar affordance SHALL be visible during scrolling, since this is a touch list rather than a mouse-hover context.

#### Scenario: List scrolls without growing the sheet
- **WHEN** a bucket has more owned items than fit within the selection sheet's fixed height
- **THEN** the item list scrolls internally; the sheet itself remains at its fixed height

#### Scenario: Bottom fade cues more content
- **WHEN** the item list has content below the currently visible rows
- **THEN** a gradient fade appears at the bottom edge of the list, signalling more items are available by scrolling

### Requirement: [UI-COMBAT-011] Target Selection
After the player taps an item or ability in the selection sheet that requires a target, the sheet SHALL NOT close. It remains open at the same fixed height, and the tapped row becomes visually distinguished as the committed selection (a distinct border and background colour, a checkmark, and a one-line prompt such as "tap an enemy above to attack"). Simultaneously, every currently valid target in the combat scene above the sheet SHALL display a highlighted ring and a "tap to target" label, making the scene interactive while the sheet stays visible for the player to change their mind.

Validity of a target is determined by the chosen item/ability's targeting rule, not by any property of the potential target being excluded from consideration. As of this spec, no game mechanic removes an enemy from being a valid target — the Evade action affects the attacker's hit chance, not the defender's targetability — so under current rules every alive enemy is always shown as a valid, highlighted target. This requirement describes the highlighting mechanism generally so that a future targeting restriction (should one be added) only needs to change which targets qualify, not how a qualifying target is presented.

#### Scenario: Selected row stays visible with a prompt
- **WHEN** the player taps a single-target weapon in the Action selection sheet
- **THEN** the sheet stays open at its same height, that row is shown with a distinct highlighted style and a prompt to tap a target, and the other rows remain available to switch to

#### Scenario: All enemies highlighted as targets today
- **WHEN** the player has selected a single-target item and no targeting-restricting effect is active
- **THEN** every alive enemy in the scene displays the highlighted targeting ring and "tap to target" label
