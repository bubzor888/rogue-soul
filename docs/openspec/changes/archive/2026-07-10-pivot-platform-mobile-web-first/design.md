## Context

Soul Protocol was scoped desktop-first: `LLD-PLATFORM-005` reads "Desktop-First Development" and files web
export as `[OPEN·MVP4]`; `LLD-PLATFORM-001` mandates a two-presentation layout (right-docked action panel
on desktop, slide-up overlay on mobile); `SCOPE-002` says MVP2 is playable "on desktop". Meanwhile the
`ui-` specs and all wireframes were authored mobile-first (390×844 portrait, 2× sprites, touch lists,
slide-up sheets, tap-to-target — `UI-ART-002`). The 2026-07-10 pivot makes **mobile the primary target,
shipped first as a web export**, with a native iOS/Android or desktop **second target (TBD)**. This change
aligns the specs with that decision. It is a spec-wording/prioritization change; it introduces no new
gameplay behaviour and no new capability.

The enabling architectural fact is already true: `PersistenceService` (`LLD-ARCH-007`) is the sole
storage seam and input is fully abstracted (`LLD-PLATFORM-002`), so the engine is already platform-agnostic.

## Goals / Non-Goals

**Goals:**
- Make the platform/scope specs match the shipped strategy: mobile primary, web export first.
- Collapse `LLD-PLATFORM-001` to a single portrait layout (the presentation the wireframes already define).
- Reframe `LLD-PLATFORM-005` as web-first and engine-agnostic; move web export out of `[OPEN·MVP4]`.
- Preserve native iOS/Android/desktop as explicit, non-excluded second targets (TBD).
- Clear the `[PENDING]` reconciliation flags recorded in `docs/implementation-plan-mvp2.md`.

**Non-Goals:**
- No engine, gameplay, RNG, or four-layer-architecture change.
- No implementation of the web export, the storage flush, or the UI itself (that is the MVP2 plan's job).
- No decision on which second target (iOS/Android vs desktop) is pursued, or when.
- No new persistence abstraction — the existing `PersistenceService` seam is sufficient.

## Decisions

**D1 — Single portrait layout, not a dual desktop/mobile system.** `LLD-PLATFORM-001` is rewritten so the
touch-first portrait presentation (bottom action bar + slide-up sheets) is the only layout on every
platform; wider screens center-and-cap rather than reflow. *Why:* the wireframes and `ui-combat-screen`
already describe exactly this and nothing else; maintaining a second desktop layout would double the
action-bar/sheet work for a target that is no longer primary. *Alternative considered:* keep the dual
layout and build both — rejected as wasted effort against the current priority.

**D2 — Web-first via Godot's Compatibility renderer + IndexedDB `user://`.** `LLD-PLATFORM-005` becomes
"Web-First, Engine-Agnostic Development." *Why:* Godot 4's web export runs on the Compatibility (WebGL)
backend and already persists `user://` to the browser's IndexedDB, so no new storage backend is required —
only a flush guarantee. *Alternative considered:* build a dedicated localStorage/IndexedDB persistence
backend now (the original T-10 framing) — rejected as unnecessary given Godot's built-in `user://`
persistence; the only real work is an async-flush branch inside `PersistenceService`.

**D3 — Keep the engine as the portability boundary; add no second abstraction.** The specs record that
ports rely on the existing `PersistenceService` + abstract-input seams. *Why:* an extra abstraction layer
over an engine that is already storage- and input-agnostic is YAGNI. *Alternative considered:* introduce a
platform-service interface — rejected; `PersistenceService` (`LLD-ARCH-007`) already is that interface.

**D4 — Preserve the requirement IDs; update titles/bodies in place.** The two `LLD-PLATFORM-*` and two
`SCOPE-*` requirements are edited via `MODIFIED` deltas keyed on their bracketed `[REQ-ID]` (the repo's
heading convention), so every existing `@Spec` citation and cross-reference stays valid. *Why:* dozens of
code/plan references cite these IDs; renaming or renumbering would ripple. *Alternative considered:*
introduce new requirement IDs for the web-first stance — rejected as needlessly churny.

## Risks / Trade-offs

- **[Archive matcher sensitivity on `MODIFIED`]** → Deltas keep the exact bracketed `[REQ-ID]` in each
  heading and supply the full updated requirement block (all scenarios), per the delta-format convention,
  so the archive rebuild matches cleanly and loses no detail. Validate with `openspec validate --strict`
  before archiving.
- **[Web `user://` async flush]** → If saves don't survive a reload in the web build, the fix is a single
  `OS.has_feature("web")` flush branch inside `PersistenceService`; the MVP2 plan's PU4.2 verifies this. No
  engine change and no gameplay impact — a single-session run never depends on persistence.
- **[Second target still undecided]** → Left explicitly TBD in the specs; the engine-agnostic guarantee
  means the decision can be deferred without accruing rewrite debt.
- **[Downstream spec drift]** → Other specs may still imply desktop framing incidentally; this change
  targets the four load-bearing requirements. A follow-up lint pass can catch stragglers (the repo's specs
  were last validated green 2026-06-24).
