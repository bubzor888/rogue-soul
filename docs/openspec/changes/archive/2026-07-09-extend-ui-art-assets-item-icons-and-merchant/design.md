## Context

`ui-art-assets` was written to catalogue the MVP2 sprite set as it existed
at the time (damage/status/intent icons, enemy/vessel/companion sprites,
the loot placeholder image). Two categories were added to the actual asset
folder afterward, during ad-hoc wireframe work, without a spec update:
generic item identity icons and the Wandering Soul merchant sprite. This
mirrors exactly the situation `backfill-ui-specs-noncombat-and-selection`
resolved for the UI screen specs — the artifact (wireframe or asset) exists
and is settled, the spec just hasn't caught up.

## Goals / Non-Goals

**Goals:**
- Bring `ui-art-assets` back into parity with what's actually on disk.
- Match the existing spec's structure and tone exactly (same requirement
  numbering scheme, same table/prose mix, same scenario style) so the new
  requirements read as though they were always part of the catalogue.

**Non-Goals:**
- Not producing new art — the assets already exist.
- Not resolving whether item icons should eventually become unique per-item
  art instead of generic category icons — that was already decided
  (generic, for now) during the session that built these assets; revisiting
  it is out of scope here.

## Decisions

**One new requirement per asset category, appended after `UI-ART-006`
(before the directory-structure requirement `UI-ART-007`).** This matches
the existing spec's ordering: each asset *category* gets its own
requirement (`UI-ART-004` icons, `UI-ART-005` character sprites,
`UI-ART-006` loot image), and `UI-ART-007` — directory structure — comes
last, after every category it needs to reference has been introduced.
Item icons and the Wandering Soul sprite slot in as `UI-ART-008` and
`UI-ART-009`, preserving that order.

**Item icons get their own requirement rather than folding into
`UI-ART-004` (UI Icon Assets).** `UI-ART-004` is specifically about icons
that appear in combat's own overlays (damage type, status, intent). Item
icons serve a different purpose (identifying an item in a list/card across
multiple screens: loot, trades, action-select) and carry a different
naming scheme (`icon_item_<category>.png` vs `icon_dmg_<type>.png`).
Keeping them separate avoids overloading `UI-ART-004`'s scope.

**Wandering Soul sprite gets its own requirement rather than folding into
`UI-ART-005` (Character Sprite Assets).** `UI-ART-005`'s table is scoped to
sprites that appear inside a combat encounter (enemies, vessel,
companions) and reuses combat-cell sizing language ("fits in 26% cell").
The Wandering Soul is never in combat — it only appears on its own room
screen. A new requirement keeps `UI-ART-005`'s combat framing intact
without stretching it to cover a non-combat character.

## Risks / Trade-offs

- **[Risk]** None — purely additive documentation change, no code or asset
  impact.

## Open Questions

None.
