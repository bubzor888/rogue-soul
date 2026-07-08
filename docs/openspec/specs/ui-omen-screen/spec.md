## Purpose
Defines the layout, card anatomy, selection flow, and resolution behavior for the omen selection overlay presented during combat when three omen cards are drawn.

## Requirements

### Requirement: [UI-OMEN-001] Overlay Presentation
The omen selection draw SHALL be presented as a dimmed overlay layered on top of the combat screen, not as a separate full-screen scene or navigation state. The combat board SHALL remain dimly visible behind the overlay for the duration of the draw.

#### Scenario: Overlay layers over combat, board stays visible
- **WHEN** an omen draw is triggered
- **THEN** the combat screen dims but remains visible underneath the overlay, and no scene transition or navigation occurs

### Requirement: [UI-OMEN-002] Vertical Card Stack Layout
The three drawn cards SHALL be arranged in a vertical stack (top to bottom), matching the vertical-stack convention used on other portrait screens (e.g. the loot screen). Cards SHALL NOT be laid out side by side.

#### Scenario: Three cards stacked vertically
- **WHEN** the omen draw overlay opens
- **THEN** the three drawn cards appear as a top-to-bottom vertical stack, full width, not a horizontal row

### Requirement: [UI-OMEN-003] Two-Box Card Anatomy
Each drawn card SHALL be composed of two visually independent boxes placed side by side with a small gap, rather than a single card with an internal divider: an **effect box** (majority width; icon, effect name, and a one-line description of the mechanical action only) and a **duration box** (~22% width, distinct tone; the card's number). Both boxes SHALL be shown on every drawn card, every time — the icon and number are always present regardless of which card ultimately becomes the auto-applied or timer card. The effect box's description line SHALL state only the mechanical action (e.g. "Applies Burning to chosen side") and SHALL NOT explain what the referenced status effect itself does.

#### Scenario: Every card shows both boxes on draw
- **WHEN** three cards are drawn
- **THEN** each of the three cards displays both its effect box and its duration box, independent of which role that card will later resolve to

#### Scenario: Description states mechanical action only
- **WHEN** a card's effect box is displayed
- **THEN** its description line states the action being applied and does not define or explain the referenced status effect's own behavior

### Requirement: [UI-OMEN-004] Two-Step Selection Flow
Card selection SHALL proceed in two discrete steps: (1) the player taps a card to select it, then (2) the player taps a target side (ally or enemy) to confirm. A single combined drag-and-drop gesture SHALL NOT be used.

#### Scenario: Card tap precedes side tap
- **WHEN** the player taps one of the three drawn cards
- **THEN** that card becomes the selected card and the overlay advances to a side-choice step, with no effect applied yet

#### Scenario: Side tap confirms the choice
- **WHEN** a card is selected and the player taps a valid target side
- **THEN** the selection is confirmed and the overlay advances to resolution

### Requirement: [UI-OMEN-005] Real Board Positions as Target Zones
During the side-choice step, the tappable target zones SHALL be the real on-screen board positions (visible, dimmed, underneath the overlay) rather than generic labeled buttons. The enemy zone SHALL be the enemy cluster's own on-screen position. The ally zone SHALL be the vessel's own footprint only. Companion positions SHALL be excluded from targeting, since companions cannot receive omen status effects.

#### Scenario: Enemy zone matches enemy cluster position
- **WHEN** the side-choice step is active
- **THEN** the tappable enemy target zone corresponds to the enemy cluster's actual board position, not a separate labeled button

#### Scenario: Ally zone excludes companions
- **WHEN** the side-choice step is active
- **THEN** only the vessel's own footprint is a valid ally target zone; companion positions are not tappable targets

### Requirement: [UI-OMEN-006] Staged Card During Side-Choice
While the side-choice step is active, the selected card SHALL dock in a centered staged position on the overlay, displaying only its effect box — its duration box SHALL NOT be shown, including in a faded state, since the selected card's number never factors into the outcome.

#### Scenario: Staged card omits duration box entirely
- **WHEN** a card has been selected and the overlay is awaiting a side tap
- **THEN** the staged card shows its effect box only; no duration box appears in any form

### Requirement: [UI-OMEN-007] Cards Never Reposition
All three drawn cards SHALL remain in their original stack positions for the entire flow, from draw through resolution. No card SHALL change position, size, or stack order at any point.

#### Scenario: Stack order fixed through resolution
- **WHEN** the overlay progresses from card choice through side choice to resolution
- **THEN** each of the three cards remains at its original position in the vertical stack throughout

### Requirement: [UI-OMEN-008] Simultaneous In-Place Resolution
Once a side is confirmed, all three cards SHALL resolve simultaneously, in place, as follows:
- The **chosen card** SHALL become fully hidden (both boxes and its label), with its slot's vertical space preserved so the remaining cards do not shift.
- The **auto-applied card** (one of the two remaining, un-selected cards) SHALL keep only its effect box visible, applied to whichever side the player did not choose; its duration box SHALL become fully invisible.
- The **leftover/timer card** (the other remaining, un-selected card) SHALL keep only its duration box visible; its effect box SHALL become fully invisible. This card's number becomes the new omen countdown.

"Fully invisible" SHALL mean the box and any border/outline are entirely removed from view (not merely reduced opacity), so the resulting empty space reads as intentional.

Which of the two remaining cards becomes the auto-applied card versus the leftover/timer card is determined by the underlying mechanic, not the UI layer: per `HLD-OMEN-001`, one of the two remaining cards is randomly selected and applied to the side the player did not choose, and the other becomes the timer card. This UI spec reflects that outcome; it does not itself perform the selection.

#### Scenario: Chosen card fully hidden, space preserved
- **WHEN** resolution occurs
- **THEN** the chosen card's row becomes fully hidden and its vertical slot remains reserved, so the other two cards do not shift position

#### Scenario: Auto-applied card shows effect box only
- **WHEN** resolution occurs
- **THEN** the auto-applied card displays only its effect box, applied to the side the player did not choose, with its duration box fully invisible (not faded)

#### Scenario: Leftover card shows duration box only and sets new countdown
- **WHEN** resolution occurs
- **THEN** the leftover/timer card displays only its duration box, its effect box is fully invisible, and its number becomes the new omen countdown

### Requirement: [UI-OMEN-009] Selectable and Target-Zone Highlighting
In the choose-card step, selectable cards SHALL be indicated by a glowing outline, with no accompanying text prompt. In the choose-side step, valid target zones SHALL be indicated by a background pulse on the ally/enemy zones, with no accompanying text prompt.

#### Scenario: Selectable cards glow, no text
- **WHEN** the choose-card step is active
- **THEN** the three selectable cards show a glowing outline and no instructional text prompt is displayed

#### Scenario: Target zones pulse, no text
- **WHEN** the choose-side step is active
- **THEN** the ally and enemy target zones show a background pulse and no instructional text prompt is displayed

### Requirement: [UI-OMEN-010] Overlay Dismissal
After the in-place reveal, the overlay SHALL fade out entirely, returning to the plain combat screen. No text prompt or framing copy SHALL be shown during or after the reveal step — dismissal is a silent transition; the updated state (countdown badge and status chip) speaks for itself. On return, the omen countdown HUD badge SHALL reflect the leftover card's number, and a status chip SHALL appear on whichever side(s) received an effect.

#### Scenario: Overlay fades to combat screen with updated state
- **WHEN** the in-place reveal completes
- **THEN** the overlay fades out, the combat screen's omen countdown badge shows the leftover card's number, and a status chip appears on each side that received an effect

#### Scenario: No text prompt during reveal or dismissal
- **WHEN** the reveal step runs and the overlay fades out
- **THEN** no text prompt or framing copy is displayed at any point in that sequence

### Requirement: [UI-OMEN-011] Battle-Screen Omen Badge Stays Unchanged
The persistent combat-screen omen countdown HUD badge SHALL remain a plain number with no icon and no added visual prominence beyond its existing HUD treatment, both before and after an omen draw resolves.

#### Scenario: Badge is number-only before and after a draw
- **WHEN** the omen countdown badge is displayed at any point during combat, including immediately after an overlay resolves
- **THEN** it shows only a number, with no icon and no enlarged or emphasized styling
