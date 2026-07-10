## Why

`ui-art-assets` is meant to be the single authoritative catalogue for every
sprite asset in MVP2. Two categories of asset already exist on disk and are
referenced by the recently-archived UI specs (`ui-combat-screen`,
`ui-loot-screen`, `ui-wandering-soul-screen`, `ui-memory-fragment-screen`),
but `ui-art-assets` never defined them: generic item identity icons (used
in loot cards, trade offer cards, and the combat action-select sheet) and
the Wandering Soul merchant sprite. Placeholder versions of both were built
directly during wireframe work without a preceding spec — the same
spec-parity gap `backfill-ui-specs-noncombat-and-selection` closed for the
UI screen specs, now closed here for the asset catalogue.

## What Changes

- Add a requirement defining item identity icon assets: 32×32 source, four
  generic icons (weapon, support, consumable, Default Strike), white
  background with colored abbreviation text, matching the visual
  convention already established for intent icons.
- Add a requirement defining the Wandering Soul character sprite: 48×48
  source, matching the vessel/elite sprite tier already defined in
  `UI-ART-005`.
- Modify `UI-ART-007`'s directory structure to add `icons/item/` and a
  Wandering Soul entry under `characters/`.

No new placeholder assets are created by this change — the four item icons
and the merchant sprite already exist at the paths this proposal documents;
this is a documentation-parity change, not new art production.

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
- `ui-art-assets`: gains two new requirements (item identity icons,
  Wandering Soul sprite) and `UI-ART-007`'s directory tree gains two new
  entries.

## Impact

- Documentation-only. `assets/art/icons/item/icon_item_weapon.png`,
  `icon_item_support.png`, `icon_item_consumable.png`,
  `icon_item_default_strike.png`, and
  `assets/art/characters/wandering_soul/wandering_soul.png` already exist
  on disk at the paths this change documents.
- Does not redefine or duplicate `UI-ART-004` (damage/status/intent icons)
  or `UI-ART-005` (enemy/vessel/companion sprites) — purely additive.
