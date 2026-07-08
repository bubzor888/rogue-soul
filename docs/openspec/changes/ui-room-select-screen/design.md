## Context

The room select screen is presented between every encounter on Floor 3: the player chooses one of two doors, each hinting at what's behind it via a symbol. A wireframing session produced `docs/archived/ui/ui-design-room-select-screen.md` and an interactive HTML wireframe (`docs/ui/wires/room-select-wireframe.html`) that settled both the screen layout and a previously open question — the door symbol taxonomy, which numerous `[OPEN·MVP2]`/`[OPEN·MVP3]` flags in the enemies design material had deferred to "a UI/art direction session." This design doc translates those decisions into a spec-ready shape; no engine code exists yet for this screen.

## Goals / Non-Goals

**Goals:**
- Capture the confirmed door symbol taxonomy rule (granularity, fixed-symbol categories, no text label) as testable requirements, since this directly resolves outstanding `[OPEN]` flags elsewhere
- Capture the screen's layout and composition order as testable requirements
- Preserve genuinely open items (vessel orientation, doors-to-vessel spacing, symbol padding, connecting visual) without inventing answers, since they explicitly depend on future art assets

**Non-Goals:**
- Enumerating the full per-enemy symbol asset list — that belongs to a separate art-direction scoping pass that pulls from the enemies data tables directly
- Defining room generation/selection logic (which door options appear at which slot) — that is run-structure/encounter-selection mechanic territory, not UI
- Final visual/art treatment of doors, vessel sprite, or background — deferred to the art-direction pass

## Decisions

- **Symbol taxonomy rule captured as a UI requirement, not re-deriving the enemy list.** The spec states the *rule* (one symbol per specific enemy; Memory Fragment and Wandering Soul each get one fixed symbol; no text labels) as the binding contract, while leaving the exhaustive enumeration to an `[OPEN]` art-scoping task — matching the design doc's own scope boundary.
- **No special-cased "forced door" state.** Per the design doc, every room slot (including the elite gate) always presents exactly two door options at the UI level; "elite" is just one possible encounter type that can appear at a slot. This is captured as a requirement so implementation doesn't need to special-case a single-door layout.
- **Side-by-side doors, not stacked**, unlike the loot screen's vertical card stack — captured explicitly as a requirement with its own rationale (doors carry only a glanceable symbol, not a stat block) so a future reviewer doesn't "fix" it to match the loot screen's pattern by mistake.
- **Composition order fixed as a requirement** (ghost menu → heading → doors → vessel → progress bar) since several placement decisions (progress bar moving to the footer) are downstream of the ghost-menu-at-top-right convention established on the combat screen.

## Risks / Trade-offs

- [Risk] The full per-enemy door symbol asset list is a sizeable, currently unenumerated art task that could be underestimated → Mitigation: proposal and tasks explicitly flag it as a separate art-direction scoping pass, not bundled into this spec's implementation tasks.
- [Risk] Several layout details (vessel orientation, doors-to-vessel gap, symbol padding) remain unresolved and could get implemented ad hoc before art exists → Mitigation: requirements state the current provisional treatment and flag `[OPEN·MVP2]`/`[OPEN·MVP3]` items for revisit once background/character art is available.

## Open Questions

- Vessel sprite final orientation (third-person from behind vs. other)?
- Does the doors-to-vessel gap need a dedicated UI element, or is it resolved naturally by background/floor art?
- Should door tile padding around the symbol be reduced once real symbol art (vs. placeholder box) exists?
