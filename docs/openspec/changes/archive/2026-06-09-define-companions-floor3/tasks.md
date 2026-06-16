## Tasks

### HLD Updates

- [x] **Update HLD-COMPANION-001** — In `openspec/specs/hld-companion-system/spec.md`, replace the existing HLD-COMPANION-001 requirement with the updated departure model: companions depart on internal condition OR after boss fallback; add the "may also grant player an active ability" note to both companion types.

- [x] **Add HLD-COMPANION-003 Trigger Types** — Append `HLD-COMPANION-003` (Companion Trigger Types) to `openspec/specs/hld-companion-system/spec.md`. Defines `"turn_end"` and `"vessel_death_intercept"` trigger types with full scenario coverage.

- [x] **Update HLD-MF-004** — In `openspec/specs/hld-memory-fragments/spec.md`, replace the existing HLD-MF-004 requirement: remove "may accept or decline"; add mandatory acceptance rule; add one-companion-per-floor rule; add Worn Map counts toward floor limit.

### LLD Content Updates

- [x] **Update LLD-MF-009** — In `openspec/specs/lld-memory-fragments/spec.md`, replace the existing `[OPEN·MVP1]` LLD-MF-009 stub with the filled companion pool: The Raven, The Shadow, The Life Mote, with pool draw mechanic and flavour text intros.

- [x] **Update LLD-FLOOR-BEATS-003** — In `openspec/specs/lld-floor/spec.md`, update the LLD-FLOOR-BEATS-003 requirement to add: Worn Map companion encounter sets `companion_offered_this_floor = true`; blocks further companion draws from Memory Fragments this floor.

### New LLD Spec

- [x] **Create lld-companions spec** — Create `openspec/specs/lld-companions/spec.md` with `## Purpose` and `## Requirements` headers. Add LLD-COMP-001 (The Raven), LLD-COMP-002 (The Shadow), LLD-COMP-003 (The Life Mote) with full mechanics, scenarios, and flavour text as defined in the delta spec.

### Architecture Schema Updates

- [x] **Update LLD-ARCH-017 NavigationState** — In `openspec/specs/lld-technical-architecture/spec.md`, add `companion_offered_this_floor: bool` to the NavigationState fields table.

- [x] **Update LLD-ARCH-017 CompanionState** — In `openspec/specs/lld-technical-architecture/spec.md`, add `companion_timer: int` and `companion_context: Dictionary` to the CompanionState fields description.

- [x] **Update LLD-ARCH-018 CompanionData** — In `openspec/specs/lld-technical-architecture/spec.md`, add `granted_ability_id: String`, `initial_timer: int`, and `departure_trigger: String` to the CompanionData schema table.

- [x] **Update LLD-ARCH-019 CombatResolver** — In `openspec/specs/lld-technical-architecture/spec.md`, add: (1) companion granted ability injection to `get_legal_combat_actions` description; (2) `vessel_death_intercept` hook description; (3) timer decrement logic to `resolve_companion_trigger`. Add the three new scenarios.
