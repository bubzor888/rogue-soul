# Soul Protocol — Claude Instructions

## Project Overview

Soul Protocol is a turn-based roguelite built in Godot 4 (GDScript). The spec system lives in `docs/openspec/specs/` and is the source of truth for design decisions. The original design docs in `docs/archived/` are the source material; the specs supersede them where they conflict.

> **OpenSpec CLI note:** the OpenSpec home is `docs/openspec/`. Run all `openspec` commands from the `docs/` directory (e.g. `cd docs && openspec ...`) — run from the repo root, the CLI can't find the specs and will create a stray `openspec/` at the root.

---

## HLD vs LLD — The Core Boundary

This is the most important principle for spec work and code work alike.

### In specs

**HLD (High-Level Design)** defines *what* the system does and *how* it behaves in terms of rules and mechanics — without naming specific instances or absolute values.

- ✅ "Each elemental status co-applies a corresponding Vulnerable status (×1.5 multiplier)"
- ✅ "Support items decrement 1 charge per encounter"
- ✅ "The cleanse system supports multiple items covering distinct status categories"
- ❌ "Burning deals 5 fire damage per tick" — that's an LLD value
- ❌ "The Ointment clears Burning and Poisoned" — that's an LLD item definition
- ❌ "The Pilgrim starts with a Walking Staff" — that's an LLD vessel detail

**LLD (Low-Level Design)** defines *specific instances* of those mechanics: named items, their exact values, specific enemies, concrete data.

When writing or reviewing a spec, ask: *"Does this describe a rule, or a specific thing that follows the rule?"* Rules belong in HLD. Specific things belong in LLD.

### In code

The same boundary applies to the codebase. HLD concepts should translate to **core engine abstractions** — general systems that know nothing about specific content. LLD content is delivered via **data files** (`.tres` resources, JSON, etc.) that feed into those abstractions.

**Examples:**

| HLD concept | Core engine (code) | LLD content (data) |
|---|---|---|
| Status effects with tick damage and multipliers | `StatusEffect` resource type, `StatusManager` handler | `burning.tres`, `chilled.tres` with `tick_damage`, `vulnerability_multiplier` properties |
| Items with durability that decrement per use or per encounter | `ItemInstance`, `ChargeManager`, `breaks_at_zero` flag | `walking_staff.tres`, `lucky_paw.tres` with specific charge counts and effect chains |
| Vessels with abilities and stats | `VesselData` resource, `AbilityPipeline` | `pilgrim.tres`, `drifter.tres` with HP, ability references |
| Omen cards with effects | `OmenCard` resource type, `OmenSystem` handler | `stillness.tres`, `burning_omen.tres` |

**The rule:** If you find yourself writing code that says `if vessel_id == "pilgrim"` or `if item_name == "walking_staff"`, that logic belongs in a data file, not in the engine. The engine should never know about specific vessels, items, enemies, or rooms by name.

---

## @Spec Annotations

All classes and methods SHALL be annotated with one or more `@Spec` comments linking back to the requirement(s) they fulfil. This makes the spec-to-code traceability explicit and ensures changes stay honest.

### Format

```gdscript
# @Spec: HLD-COMBAT-006, LLD-ITEMS-007
func apply_status(target: Unit, status_id: String) -> void:
    ...

# @Spec: LLD-ARCH-005
class AbilityPipeline:
    ...
```

Use a single-line comment immediately above the `class`, `func`, or `var` declaration. List all requirement IDs that the class or method directly implements, comma-separated.

### Rules

- **Classes** should cite the requirement(s) that define the system they implement.
- **Methods** should cite the specific requirement(s) whose behaviour they enact — not just the class-level requirement.
- **A method may cite multiple requirements** when it implements several rules at once (e.g. a damage resolver that handles both HLD-COMBAT-007 Vulnerability and HLD-COMBAT-005 Damage Types).
- **Data files** (`.tres`, `.json`) don't need `@Spec` comments, but their corresponding `Resource` class should be annotated.
- When **changing code**, re-read every `@Spec` requirement cited on the changed class or method before committing. If the change causes the spec to be incomplete, inaccurate, or superseded, either update the spec first (via the normal propose/apply/archive cycle) or flag it explicitly.

### When a spec doesn't exist yet

If you're implementing something that doesn't yet have a spec requirement, annotate with `@Spec: [PENDING]` and treat it as a signal that a spec should be written before the feature is shipped.

```gdscript
# @Spec: [PENDING] — no spec requirement exists yet for this behaviour
func build_anomaly_outcome() -> EncounterResult:
    ...
```

---

## Spec Conventions

- All `[OPEN]` items must be tagged with an MVP target: `[OPEN·MVP1]`, `[OPEN·MVP2]`, `[OPEN·MVP3]`, or `[OPEN·MVP4]`. An untagged `[OPEN]` means the MVP assignment is pending. See `docs/openspec/specs/project-scope/spec.md` for milestone definitions.
- HLD specs use requirement IDs like `HLD-COMBAT-001`. LLD specs use IDs like `LLD-ITEMS-004`. UI specs use IDs like `UI-COMBAT-001` and live in `ui-`-prefixed folders (e.g. `ui-combat-screen`, `ui-loot-screen`, `ui-global-conventions`). Project scope uses `SCOPE-001`.
- When a spec references another spec's details, use a cross-reference (`see LLD-ITEMS-004`) rather than duplicating the content.
- Items, enemies, and vessels are LLD concerns. Don't add their specific values or names to HLD specs.

---

## MVP Milestones (summary)

| Milestone | Goal |
|---|---|
| MVP1 | Headless single-floor Pilgrim run, fully functional |
| MVP2 | Same run with full UI on desktop |
| MVP3 | Floor 2 + Tier 2 vessels (Drifter, Hedge Knight) |
| MVP4 | Floor 1 + Tier 3 vessels (Paladin, Battle Wizard, Shaman, Ranger) |

Full definitions: `docs/openspec/specs/project-scope/spec.md`
