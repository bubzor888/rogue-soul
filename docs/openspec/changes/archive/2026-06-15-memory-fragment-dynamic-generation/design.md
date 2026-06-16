## Context

LLD-MF-008 and LLD-MF-010 previously required hand-authored scenario pools for Memory Fragment Category A and Category C trades. The item ranking system (lld-item-ranking) now provides item scores (`LLD-IR-011`), HP bucket conversion tables (`LLD-IR-009`), and trade fairness formulas (`LLD-IR-010`) sufficient to generate these trades at runtime. The narrative layer (flavour text wrapping the trade) is a MVP2 UI concern and does not affect the mechanical generator.

The Memory Fragment system already performs a weighted category draw (`HLD-MF-002`, `LLD-MF-007`). This change only affects what happens after a Category A or Category C draw resolves — replacing a pool sample with a runtime generation call.

## Goals / Non-Goals

**Goals:**
- Replace static scenario pool sampling in Category A and Category C with runtime generation using item ranking scores
- Make Category C inventory-aware so the cost item is drawn from what the player actually has
- Resolve the `[OPEN·MVP1]` tags on LLD-MF-008 and LLD-MF-010

**Non-Goals:**
- Narrative/flavour text for Memory Fragment moments — deferred to MVP2
- Changes to Category B (Companion Encounter) — pool remains static
- Changes to the category draw weights (`LLD-MF-007`) or the one-per-floor companion rule (`HLD-MF-004`)
- Changes to Wandering Soul generation — that system is already defined as generated

## Decisions

### Decision: Runtime generation over static pool

**Chosen:** Generate Category A and C trades at runtime from item scores.

**Alternatives considered:**
- *Hand-authored pools (original spec)*: Requires ongoing authoring and rebalancing as item scores shift during playtesting. Every score change that crosses a bucket boundary invalidates authored scenarios.
- *Hybrid (authored pool + runtime validation)*: Reduces variety and still requires manual authoring. No benefit over full generation once the scoring system is complete.

**Rationale:** The ranking system was designed specifically to enable this. Score tables are pre-playtest placeholders that will shift — generation automatically adapts, authored pools do not.

---

### Decision: Category C reads from player inventory, not drop pool

**Chosen:** Option 1's cost item is selected from the player's current inventory.

**Alternatives considered:**
- *Fixed cost from drop pool*: The cost item would be something the player doesn't own, making the trade feel abstract rather than threatening.

**Rationale:** The design intent of Category C is a trade that "has already taken hold" (`HLD-MF-005`). The threat is real only if what's at stake is something the player actually has. Inventory-aware selection achieves this without authored scenarios.

---

### Decision: Narrative decoupled from trade contents

**Chosen:** The generator produces only the mechanical trade (items, scores, HP values). Narrative context is a separate layer added by the UI at MVP2.

**Rationale:** Decoupling prevents the authoring burden from blocking the MVP1 headless run. The generator is fully testable without any narrative scaffolding.

---

### Decision: Category A fallback to item-for-HP when no valid pair exists

**Chosen:** If no same-scale pair within ±20% tolerance can be found, the generator falls back to an item-for-HP offer using the player's highest-scored item.

**Rationale:** Prevents the generator from failing silently or skipping the encounter. Item-for-HP is always generatable as long as the player has at least one item, and is already a valid Category A trade form per `HLD-MF-003`.

## Risks / Trade-offs

- **Score table is pre-playtest** → Trades may feel off until scores are validated through play. Mitigation: the generator is sensitive to score changes, so playtesting the score table directly improves generated trade quality.
- **Category C "non-obvious choice" is hard to guarantee algorithmically** → The 50%+ threshold ensures Option 1 is mathematically unfair, but whether the player *feels* it is non-obvious depends on framing. Mitigation: the narrative layer at MVP2 provides framing; test for perceived tension in playtesting.
- **Edge case: very low inventory** → Player with one item will always see that item as Option 1's cost in Category C. Mitigation: the single-item fallback rule (Option 2 uses HP) handles the mechanical case; whether this feels fair is a balance concern for playtesting.

## Open Questions

- Should Category A ever draw the cost item from the player's inventory (item-for-item where the player gives something they have)? Currently the spec allows this but the generator design doesn't require it — the cost could always be HP and the reward always a pool item. Worth confirming the intended trade forms for Cat A in practice.
- HP values for all HP-based trades remain `[OPEN·MVP2]` per `LLD-IR-009`. The generator should produce HP bucket identifiers (Low / Medium / High / Very High) and let the UI resolve them to actual values once vessel HP pools are confirmed.
