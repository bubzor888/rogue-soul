## Why

The omen selection overlay (the draw-three-cards interaction that lets the player apply an omen effect during combat) has been through a wireframing pass (`docs/archived/ui/ui-design-omen-screen.md`, `docs/ui/wires/omen-overlay-wireframe.html`) but has no formal spec. Converting the confirmed design decisions into a `ui-omen-screen` capability spec gives engineering a traceable, testable contract to implement against, consistent with every other screen in `docs/openspec/specs/ui-*`.

## What Changes

- Add a new `ui-omen-screen` capability spec covering:
  - Overlay presentation on top of the combat screen (not a full-screen navigation state)
  - Vertical card stack layout for the three drawn cards
  - Two-independent-boxes card anatomy (effect box + duration box, shown on every card every time)
  - Two-step selection flow: tap a card, then tap a side (real board target zones; companions excluded)
  - Staged/docked card state during the side-choice step (effect box only)
  - Simultaneous in-place resolution behavior for all three cards (chosen card fully hidden, auto-applied card keeps effect box only, leftover/timer card keeps duration box only and becomes the new omen countdown)
  - Overlay dismissal and battle-screen omen badge (unchanged, number-only)
  - Final-UI replacements for wireframe-only text stand-ins (glowing outline instead of "choose one card" text; background pulse instead of "choose a side" text)
- No modifications to existing capabilities; this is purely additive.

## Capabilities

### New Capabilities
- `ui-omen-screen`: Layout, card anatomy, selection flow, and resolution behavior for the omen selection overlay presented during combat.

### Modified Capabilities
(none)

## Impact

- New spec file: `docs/openspec/specs/ui-omen-screen/spec.md`
- Affects future UI implementation of the combat screen's omen draw interaction (Godot 4 scene/overlay work, not yet built)
- Both items previously flagged `[OPEN]` in the design doc are resolved in this spec:
  - The auto-applied vs. leftover/timer card assignment is random, per the existing `HLD-OMEN-001` mechanic (`hld-omen-system`); the UI spec cross-references it rather than restating the rule
  - No wording/framing prompt is shown during the reveal or dismissal step — it is a silent transition
