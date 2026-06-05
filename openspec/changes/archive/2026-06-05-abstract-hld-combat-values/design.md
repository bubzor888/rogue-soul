## Context

HLD specs define *what* the system does — the rules and mechanics. LLD specs define *how* — tuned values, formulas, tables. This boundary has been mostly respected, but a few absolute numbers crept into `hld-combat-system`: the Poisoned tick sequence (2→6→18), Mending's 3 HP, and Hardened's 3-point absorption cap.

## Goals / Non-Goals

**Goals:**
- Codify the HLD value-abstraction convention so it can be applied consistently going forward.
- Fix the existing violations in `hld-combat-system` without changing the described mechanics.

**Non-Goals:**
- Auditing or updating any LLD spec — LLD is the right home for absolute values, no changes needed there.
- Changing any game mechanic — this is a spec language/clarity change only.

## Decisions

### Convention: HLD uses relative or placeholder values only

HLD specs MAY use relative multipliers (×1.5, ×2), percentages (10%, 20%), or abstract placeholders (X, Y, N) when needed to describe a mechanic. They MUST NOT contain absolute numeric values that represent tuned game balance (damage numbers, HP amounts, etc.).

**Why:** Absolute values in HLD specs create a false impression of finality and duplicate the source of truth that belongs in LLD. When a designer tweaks a number, only the LLD should need updating.

**Examples that are OK in HLD:**
- "each tick, damage triples" (describes the mechanic, not the starting value)
- "vulnerability multiplies damage by ×1.5" (relative multiplier, part of the rule)
- "deals X damage per tick" (placeholder — value is LLD)

**Examples that are NOT OK in HLD:**
- "deals 5 fire damage per tick" (absolute tuned value)
- "heals 3 HP per tick" (absolute tuned value)
- "damage sequence: 2→6→18" (explicit tuned values, even as an example)

### Poisoned mechanic description

The Poisoned escalation rule should describe the algorithm: each tick, the current poison value is dealt as damage, then the value is tripled. Starting value and any external modifications to the value are LLD concerns. Scenarios may use an abstract sequence (e.g., "value starts at V, tick 1 deals V damage, tick 2 deals 3V damage") rather than naming 2→6→18.

## Risks / Trade-offs

- **Risk**: Future contributors write examples with real numbers back into HLD.  
  → Mitigation: This design.md serves as the standing convention reference. Mention it in the spec preamble or rely on review.

- **Trade-off**: Removing the 2→6→18 example loses some immediate legibility.  
  → Acceptable: the mechanic description (triple each tick) is self-explanatory; the LLD carries the canonical values.
