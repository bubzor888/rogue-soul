# `src/` — Source Layout & Conventions

This tree implements Soul Protocol's engine. Two rules govern everything placed here.

## 1. Four-layer dependency rule (`LLD-ARCH-001`)

Inner layers never import outer ones. Dependencies point inward only:

```
Presentation → Application → Domain → Infrastructure
```

| Layer | Location | May depend on |
|---|---|---|
| **Infrastructure** | `src/infrastructure/` + Autoloads | nothing |
| **Domain** | `src/domain/` | Infrastructure only; `RefCounted`/`Resource` only — no `Node`, no scene tree |
| **Application** | `src/application/` | Domain + Infrastructure; no scene tree |
| **Presentation** | `src/presentation/` (scenes) | all layers |

Supporting rules:

- **Headless purity** (`LLD-ARCH-002`): Domain/Application never reference `GameConfig.HEADLESS`.
  Only Presentation nodes check it and `queue_free()` themselves when headless.
- **GameState is JSON-serialisable and clone-able** (`LLD-ARCH-004`, `-017`): no `Node`, `Callable`,
  or `Object` references in any domain `Resource` field.
- **Content is data, not code** (`LLD-ARCH-005`, `-006`, `-018`): no `if vessel_id == "pilgrim"` in
  the engine. Vessels/items/enemies/omens are `.tres` files in `data/`, discovered by registries.

Sibling trees: `data/` holds LLD content (`.tres`); `tests/` holds the GdUnit4 suites.

## 2. `@Spec` annotations (see `CLAUDE.md`)

Every `class`, `func`, and significant `var` SHALL cite the requirement(s) it fulfils with a
single-line comment immediately above the declaration:

```gdscript
# @Spec: LLD-ARCH-019, HLD-COMBAT-007
func resolve_damage(...) -> void:
    ...
```

- Classes cite the requirement(s) defining the system they implement.
- Methods cite the specific requirement(s) whose behaviour they enact — not just the class-level one.
- A method may cite multiple requirements when it implements several rules at once.
- Data files (`.tres`) don't carry `@Spec`, but their `Resource` schema class does.
- No spec yet? Tag `@Spec: [PENDING]` and write the spec before shipping.

The implementation plan (`docs/implementation-plan.md`) lists the `@Spec` IDs for each task.
