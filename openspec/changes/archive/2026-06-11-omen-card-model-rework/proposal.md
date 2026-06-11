## Why

The current omen model tracks whole-side effects as global flags rather than individual StatusInstances per unit, creating a conceptual split between "omen effects" and "status effects" that prevents consistent cleanse behaviour, per-unit display, and clean enemy-family conditional application. Unifying everything on individual StatusInstances — and formalising the missing Emboldened and Exposed status definitions — closes this gap before the beast enemy intents change that depends on them.

## What Changes

- **All omen card effects become per-unit StatusInstances.** When an omen card is applied to a side, each eligible unit on that side receives its own StatusInstance. Killing or cleansing one unit has no effect on others.
- **`StatusInstance` gains a `trigger` field** (`"tick"` | `"shift"`) distinguishing per-tick effects (Burning, Chilled) from at-shift effects (Shocked, Exposed).
- **Shocked** becomes a shift-triggered status. At omen shift it sets `is_stunned: bool` on the target — blocking the Action bucket only; Support and Consumable buckets remain available.
- **Exposed** is formally defined as a shift-triggered status. At omen shift it applies Vulnerable (Physical) to its targets with `remaining_ticks` equal to the next cycle's timer value.
- **Emboldened (Physical/Fire/Lightning/Ice)** added as formal status rows in `HLD-COMBAT-006`. Physical: flat damage bonus (consistent with existing LLD value). Elemental: ×1.5 multiplier (consistent with existing LLD value).
- **Frenzied** added as a composite status: Vulnerable (Physical) + Emboldened (Physical) applied to the same unit simultaneously. Used by the Bear's future Frenzy intent.
- **OmenCardData schema** gains `requires_tag: String` for tag-conditional application (e.g. Grave Knit only applies Mending to units tagged `"undead"`).
- **HLD-OMEN-005** "Overall vs Individual" distinction removed. All omen card effects are now per-unit; the only remaining distinction is source (omen deck vs consumable/ability), not tracking model.

## Capabilities

### New Capabilities

*(none)*

### Modified Capabilities

- `hld-combat-system`: Add Emboldened (Physical/Fire/Lightning/Ice), Exposed, and Frenzied status rows to `HLD-COMBAT-006`; update Shocked description to shift-triggered per-unit model; add `is_stunned` Action-bucket-blocking rule
- `hld-omen-system`: Remove "overall omen" whole-side global model from `HLD-OMEN-005`; define tag-conditional application; clarify Exposed's two-phase behaviour (active this cycle → Vulnerable next cycle)
- `lld-technical-architecture`: Add `trigger: String` to StatusInstance in `LLD-ARCH-017`; add `is_stunned: bool` to VesselState and EnemyState; add `requires_tag: String` to OmenCardData in `LLD-ARCH-018`; update `resolve_omen_tick`, `get_legal_combat_actions`, and `resolve_enemy_turns` in `LLD-ARCH-019` for shift-triggered statuses and `is_stunned`
- `lld-omen-cards`: Update `LLD-OMEN-CARD-002` (Shocked) to per-unit shift-triggered model; add full definition for `LLD-OMEN-CARD-019` (Exposed); update `LLD-OMEN-CARD-004` and `LLD-OMEN-CARD-005` (Emboldened) to reference new status definitions

## Impact

- `openspec/specs/hld-combat-system/spec.md`
- `openspec/specs/hld-omen-system/spec.md`
- `openspec/specs/lld-technical-architecture/spec.md`
- `openspec/specs/lld-omen-cards/spec.md`
- `openspec/specs/lld-enemies/spec.md`
- Spec-only change; no GDScript written here.
