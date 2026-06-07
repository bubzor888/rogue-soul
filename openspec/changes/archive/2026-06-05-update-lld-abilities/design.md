## Context

LLD-ABILITIES-001 was the first attempt at defining what handler IDs exist. It contains `force_row` (removed with the row system), `summon_unit` (removed with the summoned companion redesign), and `deal_physical_damage` described with a "row modifier" that no longer exists. Rather than partially correct it, removing and deferring is cleaner — a full handler library definition should be written once the item and ability design is more settled.

LLD-ABILITIES-002 is a naming convention for GDScript classes, not a game mechanic. Its home is the technical architecture spec alongside other code conventions. It belongs with LLD-ARCH-005 (Ability Pipeline) which already references handler IDs.

LLD-ABILITIES-004 was written when `attack_type: MELEE` was a meaningful field and when row position affected targeting. Both are gone.

## Goals / Non-Goals

**Goals:**
- `lld-abilities` no longer contains stale handler entries or row references.
- Handler naming convention lives in `lld-technical-architecture` as LLD-ARCH-012.
- Throw Rock is defined cleanly: `deal_damage { base_damage: 3, damage_type: physical }`, no row qualifier.

**Non-Goals:**
- Defining the full handler library — deferred.
- Changing any other ability definitions (LLD-ABILITIES-003 Good as New is unchanged).

## Decisions

### LLD-ABILITIES-001: remove, not patch

The table has three stale entries and the surviving entries reference outdated concepts. A partial fix would be misleading — better to flag it as pending and do a clean definition pass once the full item/ability design is settled.

### Handler naming: moves to LLD-ARCH-012

LLD-ARCH-005 already defines the AbilityPipeline architecture and references `handler_id`. The naming convention is a natural companion to that requirement and belongs in the same spec. Referencing it from lld-abilities is fine but the definition should live in the architecture spec.

### Throw Rock: `deal_damage` pattern

Consistent with how the Walking Staff was updated (`deal_damage { base_damage: 6, damage_type: physical }`). No `attack_type` field.
