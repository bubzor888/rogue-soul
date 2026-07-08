## Why

The room select screen (the two-door choice presented between every encounter) has been through a wireframing pass (`docs/archived/ui/ui-design-room-select-screen.md`, `docs/ui/wires/room-select-wireframe.html`) that resolved a previously open question — the door symbol taxonomy — along with the overall layout. Converting these confirmed decisions into a `ui-room-select-screen` capability spec gives engineering a traceable, testable contract, and formally resolves the scattered `[OPEN·MVP2]`/`[OPEN·MVP3]` "door symbol TBD" flags in the enemies design material.

## What Changes

- Add a new `ui-room-select-screen` capability spec covering:
  - Standard two-door layout: every room slot, including the elite gate, always presents exactly two door options (no forced/single-door rooms)
  - Door symbol taxonomy: one symbol per specific enemy (combat doors), one fixed symbol for Memory Fragment doors, one fixed symbol for Wandering Soul doors, symbol-only with no text label
  - Overall composition: ghost hamburger menu (top-right, reused verbatim from combat screen) → heading → two side-by-side doors → vessel sprite (bottom, combat-sprite scale) → segmented floor-progress bar (footer)
  - Floor progress indicator: segmented bar, one segment per room, no accompanying text label, room count shown (not treated as a spoiler)
- Resolves the `[OPEN]` door-symbol-taxonomy questions previously scattered through the enemies design material by confirming: symbol granularity is per-specific-enemy (not type/family), and Memory Fragment / Wandering Soul each use one fixed symbol regardless of contents.
- No modifications to existing capabilities; this is purely additive.

## Capabilities

### New Capabilities
- `ui-room-select-screen`: Layout, door symbol taxonomy, and floor-progress indicator for the between-encounter room select screen.

### Modified Capabilities
(none)

## Impact

- New spec file: `docs/openspec/specs/ui-room-select-screen/spec.md`
- Affects future UI implementation of the room select screen (Godot 4 scene work, not yet built)
- Resolves previously open door-symbol questions referenced from enemy design material; the full per-enemy symbol asset enumeration is deferred to a separate art-direction scoping pass, not re-derived in this spec
- Several items remain `[OPEN]`, carried forward from the design doc: vessel sprite orientation, the visual treatment of the gap between doors and vessel, door tile padding relative to symbol size, and whether a connecting visual between vessel and doors is needed — all deferred pending real background/art assets
