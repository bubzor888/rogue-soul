## Context

The omen selection overlay is the UI for the omen-draw mechanic that occurs during combat: three cards are drawn, the player picks one to apply to a side (ally or enemy), and the other two resolve automatically — one becomes an auto-applied effect, the other becomes the new omen countdown. A wireframing pass produced `docs/archived/ui/ui-design-omen-screen.md` and an interactive HTML wireframe (`docs/ui/wires/omen-overlay-wireframe.html`) that settled the layout, card anatomy, and interaction flow. This design doc translates those decisions into a spec-ready shape; no engine code exists yet for this screen.

## Goals / Non-Goals

**Goals:**
- Capture the overlay's structure, card anatomy, and four interaction states (choose card → choose side → reveal in place → dismissed) as testable requirements
- Resolve the two open questions from the design doc against confirmed mechanics and product direction rather than leaving them open
- Keep the spec's wireframe-only stand-ins (text prompts, stepper buttons) out of the requirements, since they are explicitly not final UI

**Non-Goals:**
- Defining the omen system's underlying mechanic (what determines card draw pool, effect resolution) — that belongs to the combat/omen mechanic spec, not this UI spec
- Final visual/art treatment (glow intensity, pulse animation timing) — deferred to the art-direction pass
- Godot scene/node implementation details

## Decisions

- **Spec as a UI capability, not a combat mechanic.** This spec describes layout and interaction only; it defers to `hld-omen-system` for *why* a card resolves the way it does. `HLD-OMEN-001` already states the mechanic explicitly ("one card is randomly selected from the remaining two and applied to the other side"), so the UI requirement cross-references that ID rather than restating or re-deciding the rule.
- **No resolution-step prompt.** The design doc's open item about framing/wording for the reveal step is resolved as: no text prompt at all. Dismissal is a silent transition — the updated omen badge and status chip are sufficient feedback, consistent with the project's broader no-tooltip / icon-taught convention.
- **Overlay, not a navigation state.** Modeled as a state layered on top of the existing combat screen rather than a separate scene, matching the design doc's rationale (continuity with the persistent omen HUD badge, cheaper to iterate).
- **Two-box card anatomy captured as a structural requirement**, not just a visual note, because the independent-visibility behavior (one box can vanish while the other stays put) is load-bearing for the resolution requirement — a single divided card cannot satisfy it.
- **Interaction states named to match the design doc's four states** (choose card, choose side, reveal in place, dismissed) so future scenario/task references stay traceable to the source document.

## Risks / Trade-offs

- [Risk] A future change to `HLD-OMEN-001`'s selection rule (e.g. making it deterministic) would silently desync this UI spec's cross-reference → Mitigation: the UI requirement points at the mechanic by ID rather than duplicating its text, so any future change to the rule is visible in one place.

## Open Questions

(none — both items carried from the design doc are resolved above)
