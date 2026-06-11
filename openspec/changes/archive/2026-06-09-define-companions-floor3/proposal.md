## Why

The Floor 3 companion pool is empty (`[OPEN·MVP1]` on LLD-MF-009) and the companion encounter rules have gaps — players can currently decline companions (HLD-MF-004) and the system allows multiple companion encounters per floor. This change locks down the three Floor 3 temporary companions, closes the remaining companion-related open items, and updates the architecture to support the two new companion behaviours (active granted abilities, generic countdown timer).

## What Changes

- **Define three Floor 3 temporary companions** — The Raven (granted active ability: mark an enemy for death at omen shift), The Shadow (passive drain: 2 HP/turn from a random enemy, departs after 20 total HP drained), The Life Mote (passive intercept: revive the vessel at 5 HP on death, then depart)
- **Update companion departure model** — companions now depart on their own internal condition (ability used, timer exhausted, trigger fired) OR after the floor boss if their condition was never met; this replaces the blanket "departs at floor end" rule
- **Make companion encounters mandatory** — remove the "may decline" option from HLD-MF-004; companions are always accepted when offered
- **One companion encounter per floor** — once a companion encounter fires (Worn Map or Memory Fragment), the Companion Encounter category is removed from the Memory Fragment pool for the rest of that floor
- **Extend CompanionData schema** — add `granted_ability_id: String` for companions that give the player an active ability
- **Extend CompanionState** — add `companion_timer: int` (generic countdown) and `companion_context: Dictionary` (misc runtime state e.g. current drain target)
- **Add `vessel_death_intercept` trigger type** — new CombatResolver hook for Life Mote; checked synchronously before `unit_died` is emitted

## Capabilities

### New Capabilities

- `lld-companions`: The three Floor 3 temporary companions as LLD data entries (The Raven, The Shadow, The Life Mote), including their mechanics, omen contributions, and flavour text intros

### Modified Capabilities

- `hld-companion-system`: Departure model updated (fixed-life condition + boss fallback); `vessel_death_intercept` trigger type added; active granted ability concept introduced
- `hld-memory-fragments`: HLD-MF-004 companion encounter is now mandatory (no walk-away); one-per-floor rule added; Worn Map counts toward floor companion slot
- `lld-memory-fragments`: LLD-MF-009 companion pool for Floor 3 filled in (was entirely `[OPEN·MVP1]`)
- `lld-floor`: LLD-FLOOR-BEATS-003 updated — Worn Map encounter counts as the floor's companion slot, blocking further companion draws from Memory Fragments
- `lld-technical-architecture`: CompanionData schema (`granted_ability_id`), CompanionState schema (`companion_timer`, `companion_context`), CombatResolver interface (`vessel_death_intercept` hook and `get_legal_combat_actions` companion ability injection)

## Impact

- `openspec/specs/lld-companions/spec.md` — new file (companion LLD data entries)
- `openspec/specs/hld-companion-system/spec.md` — departure model, trigger types
- `openspec/specs/hld-memory-fragments/spec.md` — mandatory encounter, one-per-floor
- `openspec/specs/lld-memory-fragments/spec.md` — LLD-MF-009 companion pool filled
- `openspec/specs/lld-floor/spec.md` — Worn Map beat companion slot rule
- `openspec/specs/lld-technical-architecture/spec.md` — schema additions, CombatResolver hook
- No code changes in this change — spec-only; the architecture additions are prerequisites for implementation
