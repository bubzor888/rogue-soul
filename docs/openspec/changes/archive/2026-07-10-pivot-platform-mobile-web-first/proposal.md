## Why

The project has pivoted its release strategy (2026-07-10): the primary target is now **mobile**, shipped
**first as a web export** (playable in a mobile browser), rather than desktop-first. Several specs still
assert a desktop-first target and file web export as a late (MVP4) concern, which now contradicts how the
MVP2 UI is actually being built (single portrait, touch-first, 390×844 — already the basis of the `ui-`
specs and wireframes). The specs must be corrected so the source of truth matches the plan before that
work is implemented and archived.

## What Changes

- Restate the platform target: **mobile is the primary release; the first release vehicle is a web
  export**; a **second native/desktop target (iOS/Android or desktop) is TBD** and explicitly not
  excluded — the engine stays platform-agnostic to keep any such port a minimal-rewrite effort.
- **BREAKING (spec intent):** `LLD-PLATFORM-001` no longer mandates a separate desktop presentation with
  a right-docked action panel. MVP2 builds **one portrait layout** (bottom action bar + slide-up sheets),
  per `ui-combat-screen` and the wireframes. A future desktop presentation, if pursued, is a second-target
  concern, not an MVP2 requirement.
- `LLD-PLATFORM-005` is reframed from "Desktop-First Development" to **"Web-First, Engine-Agnostic
  Development"**: web export is the first release vehicle (no longer `[OPEN·MVP4]`); native iOS/Android
  and/or desktop are potential second targets (TBD). Records that the storage seam already isolates the
  engine (`PersistenceService`, `LLD-ARCH-007`) so ports need no engine rewrite, and that the only web
  persistence concern is the asynchronous IndexedDB (`user://`) flush — a `PersistenceService`-internal
  detail, not a new backend.
- `SCOPE-002` (MVP2) reworded: "playable … on desktop" → **playable through the UI, verified first in a
  mobile-sized web build** (desktop run allowed for dev iteration).
- `SCOPE-004` out-of-scope note that currently defers "mobile port" is corrected so mobile is no longer
  framed as a deferred/late concern.

## Capabilities

### New Capabilities
<!-- None — this change re-scopes existing platform/scope requirements; it introduces no new capability. -->

### Modified Capabilities
- `lld-platform-constraints`: `LLD-PLATFORM-001` (single portrait layout replaces the mandated desktop
  right-panel variant) and `LLD-PLATFORM-005` (web-first, engine-agnostic development; web export moves
  out of `[OPEN·MVP4]`; native/desktop as TBD second target).
- `project-scope`: `SCOPE-002` (MVP2 verified in a mobile web build, not "on desktop") and the
  `SCOPE-004` out-of-scope wording that currently treats a mobile port as deferred.

## Impact

- **Specs:** `openspec/specs/lld-platform-constraints/spec.md`, `openspec/specs/project-scope/spec.md`.
- **Plan:** `docs/implementation-plan-mvp2.md` already reflects the pivot (decision 1 + PU0.1); once these
  specs are applied, its `[PENDING]` reconciliation flags are cleared.
- **Code:** no engine change. Presentation/export config only (Compatibility renderer, Web export preset,
  touch input, portrait lock). `PersistenceService` may later gain a web-flush branch (`OS.has_feature`),
  contained to that one Infrastructure file.
- **No behavioural change to gameplay systems, RNG, or the four-layer architecture.**
