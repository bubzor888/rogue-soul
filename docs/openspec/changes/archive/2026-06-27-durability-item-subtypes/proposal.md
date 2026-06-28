## Why

`HLD-ITEMS-004` already defines two durability subtypes — `Attack (Durability)` and `Support (Durability)` — with distinct action buckets and decrement rules. However, the distinction is embedded in a combined action-bucket table rather than stated as a named classification, and the UI specs (`ui-loot-screen`, `ui-combat-screen`) use shorthand terms ("weapon", "support durability") without pointing back to the HLD definition. This creates a terminology gap where the UI and the item system speak slightly different languages. This change formalises the subtype names, establishes "weapon" as the canonical player-facing label for Attack (Durability) items, and adds cross-references to close the loop.

## What Changes

- Adds a dedicated requirement to `hld-item-system` naming the two durability subtypes explicitly and establishing that "weapon" is the player-facing UI label for Attack (Durability) items
- Updates `ui-loot-screen` to cross-reference `HLD-ITEMS-004` for the subtype definitions underlying `UI-LOOT-002`, `UI-LOOT-004`, and `UI-LOOT-006`
- No behaviour changes — this is a naming and traceability fix only

## Capabilities

### New Capabilities

*(none)*

### Modified Capabilities

- `hld-item-system`: Add `HLD-ITEMS-012` — a dedicated requirement naming the Attack/Support durability subtype distinction and establishing "weapon" as the player-facing UI label for Attack (Durability) items
- `ui-loot-screen`: Update `UI-LOOT-002`, `UI-LOOT-004`, and `UI-LOOT-006` to cross-reference `HLD-ITEMS-012` for the subtype definitions they rely on

## Impact

- No code changes — this change only affects spec wording and cross-references
- Downstream spec authors and implementors can now point to a single canonical requirement for the weapon/support-durability distinction rather than inferring it from the action-bucket table
