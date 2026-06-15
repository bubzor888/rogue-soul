## Context

The `item-scoring-system` change (now applied) introduced a compositional scoring model across six specs. The model defines item scores, a ±20% tolerance window, HP conversion buckets, and a Category C unfair-trade threshold. However, `lld-technical-architecture` does not yet describe:

1. Where item scores are stored in the data layer (AbilityData schema gap)
2. What Application-layer system generates trade offers using those scores

Wandering Soul and Memory Fragment encounters both need to produce score-fair (and score-unfair for Category C) trade pairs at runtime. Without an architectural home for this logic, implementers have no guidance on where to put it, what its interface looks like, or which RNG stream it uses.

## Goals / Non-Goals

**Goals:**
- Add `score: int` to AbilityData so item `.tres` files carry precomputed scores (no runtime formula evaluation required)
- Define TradeGenerator as the Application-layer system responsible for all trade offer construction
- Clarify that the LOOT RNG stream covers trade generation rolls, not a new stream

**Non-Goals:**
- Defining the encounter content format for Wandering Soul or Memory Fragment rooms (those live in their HLD specs)
- Specifying exact HP amounts in the bucket tables (still `[OPEN·MVP2]` per LLD-IR-009)
- Implementing any new scoring formula computation at runtime — scores are precomputed and stored in data files

## Decisions

### Decision 1: Precomputed score field on AbilityData, not runtime formula evaluation

**Options:**
A. Store `score: int` on AbilityData; designers set it when authoring the `.tres` file using the LLD-IR formulas as a worksheet.
B. Compute score at runtime from AbilityData fields (damage, charges, handlers) using the LLD-IR formulas.

**Decision:** Option A — precomputed field.

**Rationale:** The scoring formulas involve lookup tables, scope judgement calls, manual overrides (structural items), and a competent-play assumption that cannot be reliably inferred from raw handler params at runtime. The formulas are design-time tools, not runtime logic. Storing the result rather than the derivation keeps the engine simple and avoids encoding the worksheet rules as executable code. When an item's score changes during playtesting, the designer updates the `.tres` file — no code change required.

---

### Decision 2: TradeGenerator as an Application-layer RefCounted, not a Domain object

**Options:**
A. TradeGenerator is a Domain-layer object (alongside CombatResolver).
B. TradeGenerator is an Application-layer RefCounted (alongside RunController).

**Decision:** Option B — Application layer.

**Rationale:** Trade generation reads ItemRegistry to get available items and their scores, then makes RNG rolls to select and pair items. It does not modify GameState directly — it produces offer arrays that RunController hands to the encounter. Domain-layer systems (CombatResolver, etc.) must not access registries or orchestrate between registries; that is an Application concern. TradeGenerator has no place in headless combat simulation and should not be in Domain.

---

### Decision 3: LOOT stream covers trade generation rolls, no new stream

The LOOT stream is defined as "Item drops, loot table rolls" (LLD-ARCH-008). Trade generation is a form of loot table roll — it selects items from pools. Expanding the LOOT stream description to cover trade generation is sufficient. No new stream is needed. This keeps stream count minimal and preserves seed reproducibility.

---

### Decision 4: TradeGenerator interface — offer arrays, not GameState mutations

TradeGenerator returns `Array[TradeOffer]` (plain Dictionaries compatible with GameState serialisation). It does not write to GameState itself. RunController takes the returned offers and stores them in `NavigationState` (or a new `encounter_content` field) for the encounter handler to consume. This keeps TradeGenerator stateless and independently testable.

## Risks / Trade-offs

- **Pre-playtest scores drift** → TradeGenerator faithfully enforces whatever scores are in the `.tres` files; if scores are wrong, trades will be wrong. Mitigation: the scoring system is acknowledged as pre-playtest; scores will be updated iteratively.
- **Score field is manual** → a designer could forget to update a score after changing an item's damage or charges. Mitigation: LLD spec cross-reference makes the update obligation explicit; debug tooling can surface score mismatches.
- **LOOT stream contamination** → if the order of LOOT stream calls changes (e.g., more item rolls in loot selection), trade generation rolls shift and runs with the same seed produce different trades. Mitigation: document that LOOT stream call order within each phase must stay stable; integration tests (seeded runs) catch regressions.

## Open Questions

- Should `NavigationState` grow an `encounter_content` field to hold trade offers, or should TradeGenerator output be passed directly through RunController into the encounter handler without persisting in GameState? (Relevant for save/load mid-encounter.)
- HP bucket amounts remain `[OPEN·MVP2]` — TradeGenerator must defer to bucket data once those values are set (LLD-IR-009).
