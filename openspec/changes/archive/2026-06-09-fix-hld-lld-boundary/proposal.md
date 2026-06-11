## Why

An HLD/LLD boundary audit found three LLD specs that contain general mechanic rules instead of specific instances — the core violation of the HLD/LLD split. The door system, omen mechanics, and item category rules all define *how the systems work* (HLD) but currently live in LLD files. This makes the spec system misleading: a developer looking for "how doors work" would find it filed under LLD, and the HLD specs appear incomplete.

## What Changes

- The `lld-door-system` spec is dissolved; all five requirements move into `hld-run-structure` as HLD-DOOR-xxx requirements
- A new `hld-omen-system` spec is created, absorbing the core mechanic requirements from `lld-omen-mechanics`
- The remaining calibration/open requirements from `lld-omen-mechanics` move into `lld-omen-cards` (they are card-level data, not system rules)
- `lld-omen-mechanics` is deleted once emptied
- `lld-door-system` is deleted once emptied
- `hld-item-system` gains the item category model (action buckets) and durability decrement rules currently buried in `lld-items`

## Capabilities

### New Capabilities

- `hld-omen-system`: The omen mechanic — three-card draw, cycle timing, deck assembly from four sources, overall vs individual omens, deck reshuffle. Promotes LLD-OMEN-MECH-001/002/003/004/006 to HLD.

### Modified Capabilities

- `hld-run-structure`: Add door presentation rules absorbed from `lld-door-system` (five requirements, IDs become HLD-DOOR-001 through HLD-DOOR-005)
- `hld-item-system`: Add item category model (Attack/Support/Consumable action buckets) and durability decrement rules, promoted from `lld-items` LLD-ITEMS-001 and LLD-ITEMS-002
- `lld-omen-cards`: Receive the three calibration requirements from `lld-omen-mechanics` (LLD-OMEN-MECH-005, 008, 009) — deck size framework and card number distribution open questions

## Impact

- `lld-door-system/spec.md` — to be deleted
- `lld-omen-mechanics/spec.md` — to be deleted
- `openspec/specs/hld-run-structure/spec.md` — five new requirements added
- `openspec/specs/hld-item-system/spec.md` — two new requirements added
- `openspec/specs/lld-omen-cards/spec.md` — three requirements migrated in
- `openspec/specs/hld-omen-system/spec.md` — new file created
- LLD-OMEN-MECH-007 (vulnerability non-stacking) is a duplicate of HLD-COMBAT-007 and is dropped entirely
- No code impact — this is spec reorganisation only
