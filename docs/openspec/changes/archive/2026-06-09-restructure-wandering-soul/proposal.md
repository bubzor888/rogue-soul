## Why

`lld-wandering-soul` contains only mechanic rules — trade structure, offer types, tier fairness, HP guarantees, companion exclusion. None of these are floor-specific data. The spec reads as an HLD spec and should be filed as one. There is no floor-specific LLD content to replace it with, so the LLD spec can be deleted outright.

The one LLD dependency — a tier ranking system for trade pairing (currently `[OPEN·MVP2]` in LLD-WS-006) — belongs as an `[OPEN·MVP1]` open item on `lld-items`, since that's where item tiers will be defined.

## What Changes

- **NEW** `openspec/specs/hld-wandering-soul/spec.md` — all 8 requirements promoted from LLD-WS-* to HLD-WS-* (IDs renumbered, content unchanged)
- **DELETED** `openspec/specs/lld-wandering-soul/` — no floor-specific content remains
- **ADDED** `LLD-ITEMS-011` to `lld-items` — `[OPEN·MVP1]` requirement to define a tier list for all items, used to constrain Wandering Soul trade pairing (see `HLD-WS-006`)

## Capabilities

### New Capabilities

- `hld-wandering-soul`: New HLD spec — Wandering Soul room mechanics (trade structure, offer types, HP-for-item guarantee, tier fairness, no currency, companion exclusion, post-elite guarantee)

### Modified Capabilities

- `lld-wandering-soul`: **DELETED** — no LLD content exists for this system
- `lld-items`: `LLD-ITEMS-011` added — item tier list definition `[OPEN·MVP1]`

## Impact

- `lld-floor` references `lld-wandering-soul` in `LLD-FLOOR-PATT-005` — update the cross-reference to `hld-wandering-soul`
