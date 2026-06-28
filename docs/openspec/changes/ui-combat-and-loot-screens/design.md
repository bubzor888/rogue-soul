## Context

MVP2 adds a full Godot UI layer on top of the MVP1 headless combat engine. The combat and loot screens are the two core player-facing screens. Wireframes were produced in HTML/CSS to validate layout decisions on mobile; those decisions are now being formalised as specs. The Godot UI must reproduce the portrait-first, narrow-width layout from the wireframes.

The game targets mobile (portrait, ~360–460px wide) with a desktop companion. Godot's Control node system with anchors and size flags is the natural fit for portrait-constrained layouts. All UI scenes will live under `res://ui/`.

## Goals / Non-Goals

**Goals:**
- Implement `CombatScreen` and `LootScreen` as Godot scenes matching the spec layouts
- Implement shared UI primitives reused across screens: `StatusChip`, `DamageTypeBadge`, `ActionBar`, `ChargeDotsRow`
- Update loot delivery logic to support "decline both" (ternary outcome)

**Non-Goals:**
- Omen draw overlay, targeting flow, and action-list popup — separately wireframed later (see open items in `ui-design-combat-screen.md`)
- Final pixel-art assets — wireframe placeholder shapes/tints are acceptable for MVP2
- Animation or transition polish (snap transitions acceptable)
- Auto-end-turn setting toggle (deferred post-MVP)

## Decisions

### Decision: One Control scene per screen, not one global scene graph
Each major screen (`CombatScreen`, `LootScreen`) is its own Godot scene loaded and swapped by a root `SceneManager`. This isolates screen logic, avoids bloated node trees, and matches the project's existing scene-per-floor-state pattern.

### Decision: Enemy formation via code layout, not pre-placed nodes
Formation positions are calculated at runtime from a `FormationLayout` helper based on enemy count, rather than pre-placing `EnemyUnit` nodes at fixed positions. This keeps the scene clean and makes the position data directly traceable to spec values (28%/72%, 20%/80%, etc.).

**Alternative considered:** Static scene variants per enemy count — rejected because it duplicates the `EnemyUnit` node setup and makes the spec-to-code mapping implicit.

### Decision: Card layouts as separate packed scenes
`WeaponCard`, `ConsumableCard`, and `SupportDurabilityCard` are separate PackedScenes, not variants of a shared template. This matches the spec's "bespoke layout" requirement and avoids conditional show/hide logic that would obscure which layout is active.

### Decision: Damage type encoding via a `DamageTypeBadge` control
A single `DamageTypeBadge` control takes a `DamageType` enum value and sets its glyph icon + background tint from a lookup table. The four (glyph, tint) pairs are defined in one place. All screens that show damage type use this control — the encoding is never duplicated.

### Decision: Ternary loot outcome as an enum
The loot delivery system will accept a `LootOutcome` enum (`TAKE_DURABILITY`, `TAKE_CONSUMABLE`, `DECLINE_BOTH`) rather than a boolean. The loot screen emits a signal carrying this enum; the run state handler consumes it. This makes the ternary nature explicit in the type system and avoids null-checking a nullable item reference.

## Risks / Trade-offs

- **Portrait-only assumption** → Godot's anchor system handles this well, but rotating to landscape will break layouts. Acceptable for MVP2; landscape support is not in scope.
- **Placeholder art** → Wireframe glyph shapes (◆ ▲ ✦ ❉) will be text/SVG stand-ins; final icon art TBD. The `DamageTypeBadge` lookup table makes swapping to final art a one-file change.
- **Charge dot count** → The spec notes no weapon currently has enough charges to overflow a dot row. If that changes, the `ChargeDotsRow` control will need a numeric overflow fallback — track this if new high-charge items are added.

## Open Questions

- **End Turn circle visual state** — the spec confirms the circle relabels but does not specify colour/fill changes. Placeholder: swap label text only; refine in art pass.
- **Solo elite sprite sizing** — unresolved whether lone elites get a visually larger sprite. Default: consistent 26% cell width for now.
- **Buff vs. debuff chip colour** — `StatusChip` will use a single neutral style until the global convention is resolved in a follow-on spec change.
