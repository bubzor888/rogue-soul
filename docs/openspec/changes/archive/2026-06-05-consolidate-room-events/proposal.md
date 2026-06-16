## Why

`lld-room-events` has been rendered obsolete by design changes and spec migrations. Rest rooms and Echo Chambers are removed from the design. Anomaly rooms are fully specified in `lld-elite-gate`. The omen system stubs (LLD-EVENTS-006/007) are marked `[OPEN·RESOLVED]` — the content now lives in `lld-omen-mechanics`, `lld-omen-cards`, `lld-memory-fragments`, and `lld-wandering-soul`. Only two requirements remain (LLD-EVENTS-001 Memory Fragment, LLD-EVENTS-002 Wandering Soul), and these are better understood as room types within the floor's encounter generation system — they belong in `lld-encounter-patterns` alongside the cap table that already references them.

## What Changes

- **lld-room-events**: Deleted entirely — no requirements remain after the migration.
- **lld-encounter-patterns**: Add LLD-FLOOR-PATT-004 (Memory Fragment room type) and LLD-FLOOR-PATT-005 (Wandering Soul room type) as brief room type registrations referencing their detailed specs.

## Capabilities

### New Capabilities

_(none)_

### Modified Capabilities

- `lld-encounter-patterns`: Add LLD-FLOOR-PATT-004 and LLD-FLOOR-PATT-005.
- `lld-room-events`: Deleted.

## Impact

- `openspec/specs/lld-room-events/` — directory removed.
- `openspec/specs/lld-encounter-patterns/spec.md` — two new requirements appended.
- Note: LLD-EVENTS-001 referenced `HLD-META-002` (from the removed hld-meta-progression spec) — that stale reference is dropped.
