## Context

The LLD/HLD boundary audit identified three misplaced specs. The door system and omen mechanics specs contain general system rules — things that apply to any floor and any run — but are filed as LLD (instance-level content). `lld-items` contains two requirements that define category-level mechanics, not item-specific data. This is a spec reorganisation with no code impact.

## Goals / Non-Goals

**Goals:**
- Move `lld-door-system` requirements into `hld-run-structure` (correct home for navigation rules)
- Create `hld-omen-system` for the core omen mechanic rules
- Move omen calibration open questions from `lld-omen-mechanics` into `lld-omen-cards`
- Promote item category and durability rules to `hld-item-system`
- Delete `lld-door-system` and `lld-omen-mechanics` once emptied

**Non-Goals:**
- No content changes to any requirement — wording carries over as-is, IDs renumbered where needed
- No code changes
- No changes to `lld-enemies`, `lld-floor`, `lld-vessels`, or any other LLD spec not listed

## Decisions

### Door system: absorb into hld-run-structure, not a new file
The door requirements (two-door choice, identity revelation, pool exhaustion) are closely related to the corridor navigation model already in `hld-run-structure`. Creating a separate `hld-door-system` file would fragment tightly coupled navigation rules. They belong in the same spec. IDs use the HLD-DOOR-xxx prefix to remain distinct from HLD-RUN-xxx, so cross-references in lld-floor and lld-enemies don't need immediate updates (those specs reference the old LLD IDs and can be updated separately).

### hld-omen-system: new standalone spec
The omen system is large enough and self-contained enough to warrant its own spec rather than folding into `hld-combat-system`. The three-card draw, deck assembly, and omen types form a coherent system. IDs: HLD-OMEN-001 through HLD-OMEN-005.

### LLD-OMEN-MECH-007 (vulnerability non-stacking): drop it
This requirement is already captured in HLD-COMBAT-007. Copying it into `hld-omen-system` would create a duplicate that can drift. It is dropped; cross-references to HLD-COMBAT-007 from within the omen system suffice.

### Calibration requirements (OMEN-MECH-005, 008, 009): move to lld-omen-cards
These three are deck size targets and open questions about timer card distribution and fixed vs random numbers. They belong with the card content data rather than the mechanic rules. LLD-OMEN-MECH-xxx IDs are preserved as-is when moved.

### hld-item-system additions
LLD-ITEMS-001 (three categories and action buckets) and LLD-ITEMS-002 (durability decrement rules) are added to `hld-item-system` as HLD-ITEMS-004 and HLD-ITEMS-005, continuing from the existing HLD-ITEMS-001/002/003 requirements. The originals in `lld-items` are kept with a cross-reference note pointing to the HLD requirements — removing them from lld-items would break the scenarios and context that reference them, and those scenarios demonstrate Floor-3-specific item interactions. The HLD gets the rules; the LLD keeps the scenarios as examples.

## Risks / Trade-offs

- Cross-references in `lld-floor` (LLD-FLOOR-PATT-005 references `hld-wandering-soul`) and `lld-enemies` point to old LLD-FLOOR-DOOR-xxx IDs — those remain valid since we're not renaming the destination spec, but a future cleanup pass should update them to HLD-DOOR-xxx
- Keeping LLD-ITEMS-001/002 in lld-items (with HLD cross-references) means the category rules appear in two places — acceptable short-term, flagged for cleanup
