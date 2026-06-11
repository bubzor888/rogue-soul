## Context

The existing companion system (hld-companion-system, CompanionData/CompanionState in LLD-ARCH-017/018) defines companions as passive entities that act automatically on a trigger and depart at floor end. The three Floor 3 companions introduce two new patterns not previously modelled: companions that grant the player an active ability (The Raven), and companions that track a running total to determine their own departure (The Shadow). The Life Mote requires a synchronous death-intercept hook that does not exist in CombatResolver's current interface. The Memory Fragment rules also need tightening — companions are currently optional and can repeat within a floor.

## Goals / Non-Goals

**Goals:**
- Define all three Floor 3 companions with full mechanics, triggers, and flavour text ready for `.tres` data files
- Extend CompanionData and CompanionState to support granted abilities and generic countdown state
- Add `vessel_death_intercept` as a first-class trigger type in CombatResolver
- Lock down the "one companion per floor, mandatory" rule in HLD-MF-004 and propagate it to lld-memory-fragments and lld-floor

**Non-Goals:**
- No code — spec and schema definitions only
- No bound companion mechanics (Worn Map is a Pilgrim starting item — its Worn Map beat references companions but those are temporary)
- No UI design for companion presentation or mark indicator (MVP2)
- No other floor companion pools (Floor 1 and Floor 2 are MVP2+)

## Decisions

**`granted_ability_id` on CompanionData, not a list**
The Raven grants exactly one active ability. Future companions that grant abilities are expected to follow the same one-ability model. A single `granted_ability_id: String` (empty string if none) is sufficient and avoids a typed array that would only ever hold one entry for MVP1–MVP4 scope. If a future companion needs multiple granted abilities, the field becomes `granted_ability_ids: Array[String]` in a later change.

**`companion_timer: int` as explicit field, not inside `companion_context`**
The countdown is a common enough pattern (The Shadow uses it; future companions likely will too) that it earns a named field rather than living in an untyped Dictionary. Starting value is set by CompanionData (`initial_timer: int`; 0 = not used). CompanionState carries the runtime value. CombatResolver decrements it and checks for departure.

**`companion_context: Dictionary` for misc runtime state**
The Shadow needs to track its current drain target (`current_target_instance_id`). This is idiosyncratic state that no other companion shares. A Dictionary field on CompanionState handles this without requiring per-companion Resource subtypes. The handler reads and writes it; startup validation is the handler's responsibility (same pattern as HandlerConfig.params).

**`vessel_death_intercept` as a synchronous check in CombatResolver, not a signal**
The Life Mote must intercept between "vessel HP reaches 0" and "unit_died emitted." If it were signal-driven, the order of subscribers would determine correctness — fragile. Instead, CombatResolver checks for an active companion with `trigger == "vessel_death_intercept"` synchronously in the damage resolution path, before any death logic runs. If found: run handler chain (set HP to 5, depart companion), skip death. This is a deterministic first-class check, not an event.

**Death Mark as a status on the enemy, not an omen deck card**
The Raven's mark is implemented as a status effect (`status_id: "death_mark"`) applied directly to `EnemyState.active_statuses`. CombatResolver's `resolve_omen_tick` checks for Death Mark at the omen shift and kills the unit immediately (same timing hook as Shocked stun). This reuses existing status infrastructure without touching OmenDeckState assembly. The mark is not drawn, assigned to a side, or subject to the player/random split — it's already targeted.

**Companions are mandatory and floor-capped at one via NavigationState**
`NavigationState` already has a `segment_room_counts` Dictionary for pool exhaustion. A boolean flag `companion_offered_this_floor: bool` on NavigationState is the cleanest way to track whether a companion encounter has already fired. RunController sets it to true when either the Worn Map beat or a Memory Fragment companion encounter resolves. The MF category draw checks this flag before including Companion Encounter as an option.

**The Raven departs immediately on use, not on kill confirmation**
The Raven uses its ability (marks the target, applies Death Mark status) and departs in the same action resolution. The death itself happens at the omen shift — possibly several turns later. The Raven doesn't wait. This is simpler to implement (companion departure is part of the ability's handler chain) and avoids a "companion watching for kill confirmation" state machine.

**Companions depart on condition OR after floor boss — stored as a departure condition on CompanionData**
CompanionData gains `departure_trigger: String` — the condition that causes departure (e.g. `"ability_used"`, `"timer_exhausted"`, `"revive_triggered"`). The `"after_boss"` fallback is universal and handled by RunController at `FLOOR_TRANSITION` phase: any active temporary companion still present after the boss departs at that point. No per-companion logic needed for the fallback.

## Risks / Trade-offs

- **Risk: `companion_context` is untyped** → Same trade-off as HandlerConfig.params. Handler reads/writes must be self-consistent. Acceptable for MVP scope; a strongly-typed per-companion Resource could be introduced later if needed.
- **Risk: Death Mark status interacts with enemy healing** → A Grave Knit heals the marked enemy, but the Death Mark still fires at omen shift. Execution overrides healing. This is intentional — Death Mark is not a debuff that can be cleansed; it is a sentence. The spec should state this explicitly.
- **Risk: Shadow's `current_target_instance_id` goes stale** → If the target is killed by another source between the Shadow's last drain and its next turn, `current_target_instance_id` points to a dead enemy. CombatResolver must validate the target is still alive before draining and re-pick if not. Handler must handle the null/dead case gracefully.
- **Risk: Life Mote + status-tick death** → The intercept fires regardless of damage source (direct attack, Burning tick, Shadow drain). This is correct — the Life Mote doesn't care how the vessel reaches 0 HP. The check is "vessel HP reaches 0 during any damage application" not "vessel was hit by an attack."
