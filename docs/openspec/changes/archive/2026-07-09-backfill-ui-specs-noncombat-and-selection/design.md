## Context

This session built eight wireframes ahead of any spec: two combat
interaction states (item select + target select, with a scroll variant of
the former) and four non-combat room screens (three Memory Fragment
categories plus Rest and Wandering Soul — six screens total across those
four capabilities). Each wireframe went through at least one design
iteration driven by direct feedback (sheet height, charge-dot styling,
target highlighting, merchant sprite placement) before settling. The specs
written here describe the settled state, not the intermediate iterations.

## Goals / Non-Goals

**Goals:**
- Bring `docs/openspec/specs/` back into parity with what's actually built
  in `docs/ui/wires/`.
- Preserve enough interaction detail (not just static layout) that a future
  implementer could build these screens from the spec alone, the same way
  `ui-combat-screen` and `ui-loot-screen` already support that for their
  screens.
- Keep each new capability's spec scoped to one room/interaction, matching
  the existing one-spec-per-screen-type convention (`ui-combat-screen`,
  `ui-loot-screen`, `ui-omen-screen`, `ui-room-select-screen`).

**Non-Goals:**
- Not designing anything new — every requirement here describes an
  already-built wireframe.
- Not resolving the `ui-art-assets` / `UI-ART-007` gap around item icons
  and the Wandering Soul sprite (flagged in the proposal for a later
  change).
- Not touching `ui-loot-screen`, `ui-omen-screen`, or `ui-room-select-screen`
  — those already match their wireframes.

## Decisions

**Fold item-select and target-select into `ui-combat-screen` rather than a
new capability.** Both states are part of the combat screen's own
interaction flow (they only exist mid-turn, layered over the combat scene),
not a separate room type. This matches how `UI-COMBAT-007`/`-008` already
describe the action bar's own state transitions — item/target select is the
next state after that.

**Give Memory Fragment's three categories one shared capability spec, not
three.** They're one room type with three randomly-drawn outcomes
(`HLD-MF-002`), sharing a layout shell (menu ghost, scene stage, bottom-
anchored choices) that only the choice-controls portion changes per
category. One spec with a shared-layout requirement plus one requirement
per category mirrors how `ui-loot-screen` handles its three card types
(durability/consumable/support) as requirements within one spec, not three
specs.

**Rest and Wandering Soul each get their own capability.** Unlike the
Memory Fragment categories, these are structurally distinct rooms
(different trigger conditions, different content), not variants of one
draw — matching the pattern where `ui-room-select-screen` is its own
capability separate from `ui-combat-screen`.

**Don't hardcode "all enemies are always targetable" as a permanent rule in
`ui-combat-screen`.** The current wireframe shows every enemy highlighted
because no game mechanic excludes a target today. The requirement describes
the mechanism (how an enemy becomes highlighted/tappable) so that if a
future ability or status introduces a targeting restriction, the UI
behavior is already specified — only the exclusion condition changes, not
this requirement.

## Risks / Trade-offs

- **[Risk]** Documentation-only changes can drift from the wireframes again
  if future wireframe edits don't get a matching spec update. →
  **Mitigation**: none built into this change; relies on the same
  discipline that was missing this session. Worth a reminder in
  `CLAUDE.md` or session habits, not a spec fix.
- **[Risk]** None to runtime — no game code exists for any of these screens
  yet in MVP1/MVP2.

## Open Questions

None for this change. The `ui-art-assets` gap and the Rest room heal amount
are both flagged as out-of-scope follow-ups, not open questions blocking
this change.
