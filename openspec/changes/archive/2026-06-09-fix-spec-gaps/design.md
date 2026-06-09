## Context

A gap audit comparing `docs/` to `openspec/specs/` found: four HLD specs missing structural headers (breaks archive for any future change touching them); three confirmed HLD mechanics with no spec home (floor transition HP restore, floor-bound item flag, encounter-countdown items); a missing no-inventory-cap rule; and no narrative spec to house confirmed narrative decisions. The `hld-item-system` capability doesn't exist yet — item mechanics live entirely in `lld-items` — so the HLD abstraction layer for the item system needs to be created.

## Goals / Non-Goals

**Goals:**
- Fix the four broken spec structures so archive works cleanly going forward
- Capture confirmed mechanics (floor transition, item flags) in HLD where they belong
- Create `hld-narrative` and `lld-narrative` as holding specs for later narrative design work
- Keep all narrative content as `[OPEN]` placeholders — no content writing in this change

**Non-Goals:**
- Writing actual narrative content (lore, dialogue, endings)
- Designing encounter-countdown item values or floor-bound item list
- Resolving open questions in narrative or companion design
- Code changes of any kind

## Decisions

**`hld-item-system` as a new spec (not folded into `hld-combat-system`)**  
Item system rules — inventory size, item flags, item lifecycle — are orthogonal to combat rules. `hld-combat-system` is already large and focused on the combat loop. A separate `hld-item-system` keeps the abstraction clean: the item system spec defines what items *are* and how they behave across the run; combat only defines how they're *used* within a fight.

**Floor transition in `hld-run-structure` (not `hld-companion-system`)**  
The floor transition is a run structure event. Both HP restore and companion departure are consequences of crossing a floor boundary — they belong in the spec that owns floor boundaries. `hld-companion-system` cross-references as needed.

**`hld-narrative` captures confirmed decisions; `lld-narrative` holds all instance-level content**  
Narrative follows the same HLD/LLD split as everything else. HLD-narrative: the rules of the world (Solace exists, the guardian judges need, floor atmosphere degrades). LLD-narrative: the specific words — guardian dialogue per vessel, lore fragments, ending text. All LLD content is `[OPEN]` at this stage.

**Header fixes via direct edit, not delta**  
The four specs with missing headers need `## Purpose` and `## Requirements` prepended. These are structural fixes with no requirement changes — no delta spec needed. Direct edits to the main spec files only.

## Risks / Trade-offs

[Risk] The `hld-item-system` spec introduces a new capability that `lld-items` will implicitly depend on but doesn't yet cross-reference. → Mitigation: add `see hld-item-system` cross-references to the relevant LLD-ITEMS requirements during implementation.

[Risk] The narrative specs might attract scope creep — temptation to write actual content while creating the placeholder structure. → Mitigation: every narrative requirement that needs content SHALL be tagged `[OPEN·MVPn]` and left at that; no scenario content beyond structural placeholders.
