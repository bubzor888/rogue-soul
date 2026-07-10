## 1. Spec sync

- [x] 1.1 Apply the `ui-art-assets` delta: add `UI-ART-008` (Item Identity Icon Assets) and `UI-ART-009` (Wandering Soul Character Sprite) after `UI-ART-006`, before `UI-ART-007`.
- [x] 1.2 Apply the `UI-ART-007` directory structure update: add `icons/item/` and `characters/wandering_soul/` to the tree.

## 2. Verification

- [x] 2.1 Confirm the five existing on-disk assets (`assets/art/icons/item/icon_item_weapon.png`, `icon_item_support.png`, `icon_item_consumable.png`, `icon_item_default_strike.png`, `assets/art/characters/wandering_soul/wandering_soul.png`) match the paths and sizes now described by the spec. Verified via PIL: all four item icons are 32×32, merchant sprite is 48×48.
- [x] 2.2 Confirm `UI-ART-004` and `UI-ART-005` are unchanged — this was additive only. Confirmed via git diff — zero lines changed in either requirement, purely additive.
- [x] 2.3 Confirm `openspec validate` passes. Ran `openspec validate extend-ui-art-assets-item-icons-and-merchant` — valid.

## 3. Archive

- [x] 3.1 Run `/opsx:archive` once the above is verified, to fold this delta into `docs/openspec/specs/ui-art-assets/spec.md`.
