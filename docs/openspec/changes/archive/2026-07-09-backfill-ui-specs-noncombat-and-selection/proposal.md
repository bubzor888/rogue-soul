## Why

Every earlier UI screen (combat, loot, omen, room select) has a spec in
`docs/openspec/specs/ui-*` that the wireframe in `docs/ui/wires/` was built
against. Over the course of this session, eight new wireframes were built
directly — the combat action-bucket item-select sheet (plus its scrollable
variant) and target-select state, the three Memory Fragment room screens,
the Rest room screen, and the Wandering Soul room screen — without writing
the corresponding spec first. The UI spec set is no longer authoritative for
what's actually been designed: someone reading only the specs would have no
idea these interactions exist or how they're supposed to look. This change
backfills the missing specs to match what was actually built, restoring
spec/wireframe parity and the project's normal spec-first traceability.

## What Changes

- Modify `ui-combat-screen`: add two requirements covering interactions that
  exist in wireframes but not in the spec — the action-bucket item
  selection sheet (including its scroll behavior and the spent-charge
  visual convention) and the target-selection state that follows it.
- Add `ui-memory-fragment-screen`: a new capability covering the three
  Memory Fragment room content screens (Category A, Companion Encounter,
  Category C) and their shared layout shell.
- Add `ui-rest-screen`: a new capability covering the post-elite Rest room.
- Add `ui-wandering-soul-screen`: a new capability covering the Wandering
  Soul room.

No game mechanics change. This is a documentation-parity change — the specs
are being written to match wireframes that already exist, not the other way
around.

## Capabilities

### New Capabilities
- `ui-memory-fragment-screen`: layout and interaction rules for the three
  Memory Fragment room content screens (entered after the door choice,
  which remains owned by `ui-room-select-screen`).
- `ui-rest-screen`: layout and interaction rules for the post-elite Rest
  room.
- `ui-wandering-soul-screen`: layout and interaction rules for the
  Wandering Soul room.

### Modified Capabilities
- `ui-combat-screen`: gains the action-bucket item-selection sheet and
  target-selection state requirements (`UI-COMBAT-009`, `UI-COMBAT-010`).

## Impact

- Documentation-only. The wireframes at `docs/ui/wires/` already exist and
  are not changed by this proposal — the specs are being written to
  describe them accurately.
- Out of scope, flagged for a future change: `UI-ART-007`'s asset directory
  structure and the broader `ui-art-assets` spec don't yet account for two
  asset categories these screens introduced — generic item identity icons
  (`assets/art/icons/item/`) and the Wandering Soul merchant sprite
  (`assets/art/characters/wandering_soul/`). Both assets already exist on
  disk; only the spec citing them is missing. Not resolved here.
- The Companion Encounter requirement in `ui-memory-fragment-screen` is
  written consistent with the `remove-companion-swap` change
  (archived 2026-07-08): no swap/keep-current-companion state is described,
  since `HLD-MF-004` no longer permits that scenario to arise.
- The Rest room requirement in `ui-rest-screen` describes the heal-amount
  callout as a required UI element without pinning a value, since the
  actual heal amount remains open per `LLD-FLOOR-BEATS-006`.
