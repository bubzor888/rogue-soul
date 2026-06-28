## Purpose
Defines shared UI vocabulary and visual grammar that apply across all Soul Protocol screens. These conventions ensure consistency between combat, loot, inventory, and future screens without duplicating rules per-screen.

## Requirements

### Requirement: [UI-GLOBAL-001] Inline Status Icon Grammar
Wherever a status keyword appears in UI text (loot cards, combat overlays, inventory), it SHALL be rendered as: the status icon (same icon used on the combat status row) inline immediately before the keyword, and the keyword in bold. No tooltip or pop-up is attached to the keyword. This applies to both debuffs applied to enemies ("Apply **Poisoned**") and buffs received on self ("Gain **Fortified**"). The icon teaches by repetition across screens — the same icon seen in combat appears again in loot and inventory contexts.

#### Scenario: Status keyword always has inline icon
- **WHEN** a status keyword appears in any UI text
- **THEN** the combat status icon for that status appears inline immediately before the bold keyword

#### Scenario: No tooltip on status keyword
- **WHEN** a player taps or hovers a status keyword
- **THEN** no tooltip or info-pop-up appears; the keyword is not an interactive element

### Requirement: [UI-GLOBAL-002] Unexplained Symbol Philosophy
The UI SHALL NOT provide inline explanations, tooltips, or pop-ups for recurring game symbols (damage type glyphs, status icons, enemy intent icons). Symbols are introduced without explanation and learned through repetition. A codex or reference screen may be added in a later MVP to explain symbols, but this is separate from inline UI.

#### Scenario: Damage type glyph has no tooltip
- **WHEN** a damage type glyph is displayed on any screen
- **THEN** no tooltip, label, or explanation is triggered by interacting with it

#### Scenario: Status icon has no inline explanation
- **WHEN** a status icon is displayed in the combat status row or inline in text
- **THEN** no tooltip or pop-up explanation is attached to the icon itself

### Requirement: [UI-GLOBAL-003] Damage Type Encoding
Damage type SHALL be encoded redundantly using both a distinct sprite icon shape AND a background tint. The shape is the accessible backbone (survives colour-blindness and greyscale); the tint is an at-a-glance accelerator. Each damage type SHALL have a dedicated sprite icon asset — the specific art is TBD, but each must be visually distinct in silhouette from all others. The four types and their tint encodings are:

| Type | Shape concept | Tint |
|---|---|---|
| Physical | Diamond / solid geometry | Neutral gray/near-black (~#2b333c on #f0f1f3) |
| Fire | Triangle / flame | Red (~#cf3b2e on #fceceb) |
| Lightning | Spark / bolt | Gold (~#c9a24a on #fbf7e8) |
| Ice | Snowflake / crystal | Blue (~#5b86b3 on #eef3f9) |

Shape concept column describes the intended silhouette character to guide the art direction; it is not a specification of a particular symbol or ASCII character. Physical SHALL use neutral gray (not red) so that red belongs exclusively to Fire.

#### Scenario: Physical type uses gray not red
- **WHEN** a Physical damage type is displayed
- **THEN** the icon tint is neutral gray/near-black, not red

#### Scenario: Each type has a unique icon silhouette
- **WHEN** any damage type is displayed
- **THEN** the sprite icon silhouette alone (ignoring colour) unambiguously identifies the type

### Requirement: [UI-GLOBAL-004] Portrait Layout Constraints
All game screens SHALL be designed for a portrait orientation with a maximum content width of approximately 460px. Layouts SHALL be mobile-first and must remain legible and usable at narrow phone widths without horizontal scrolling.

#### Scenario: No horizontal scroll
- **WHEN** the screen is displayed at a portrait width of 360px or greater
- **THEN** no element requires horizontal scrolling to access

#### Scenario: Max content width respected
- **WHEN** the screen is rendered on a wider display
- **THEN** content is centered and capped at approximately 460px width
