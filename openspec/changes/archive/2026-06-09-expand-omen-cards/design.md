## Context

The omen card list in `lld-omen-cards` covers whole-side status application for offensive statuses (Burning, Shocked, Chilled) but has no cards for vulnerability states or healing. The new cards fill these gaps and complete the floor 3 ambient deck. All changes are pure spec/data changes — the engine already handles overall omens generically.

## Goals / Non-Goals

**Goals:**
- Remove the deck size framework requirement (LLD-OMEN-MECH-005) — it is not a meaningful constraint
- Add three elemental Vulnerable omen cards (Fire, Lightning, Ice)
- Add a Mending omen card
- Add the Exposed omen card (omen-shift trigger → Vulnerable (Physical) next cycle)
- Lock in the Floor 3 default deck composition (12 cards, removing the [OPEN] placeholder)

**Non-Goals:**
- No HLD changes — the new cards fit within HLD-OMEN-005 and HLD-COMBAT-007 as written
- No code changes — omen cards are data files; the engine handles them generically
- No changes to other floors' ambient decks

## Decisions

**Exposed as omen-shift triggered, not per-turn:** Exposed mirrors Shocked's trigger timing (omen shift) to keep it legible — players already understand that the shift is when Shocked fires. The payoff (Vulnerable (Physical)) lands at the *next* cycle, which creates a planning horizon distinct from Shocked's immediate stun. This also avoids confusion with per-turn vulnerability effects.

**Vulnerable omen cards apply whole-side:** Consistent with all other overall omen cards (Burning, Shocked, Chilled apply to all units on a side). Whole-side Vulnerable is powerful but costs the player's card choice for a cycle — a reasonable cost.

**Mending as overall omen (whole-side):** On player side: player heals per tick. On enemy side: all enemies heal per tick — dangerous and creates urgency. This mirrors the per-turn healing status effect (HLD-COMBAT-006).

**Floor 3 deck fixed at 12 cards:** 12 cards covers all introduced mechanics in a balanced ratio. With ~6 draws per fight (2 cycles × 3), roughly half the deck appears per fight — enough variety without guaranteeing any specific card appears.

**LLD-OMEN-MECH-005 removal:** Deck size is purely emergent from card sources (vessel, items, floor, enemies). A framework requirement implies a constraint that doesn't actually exist in the engine. The per-combat sizing examples in that requirement can be noted informally in LLD-OMEN-CARD-008 if useful.

## Risks / Trade-offs

- **Vulnerable omen cards + item Vulnerable don't stack (×1.5 cap):** Confirmed by HLD-COMBAT-007 — this is by design, not a risk
- **Exposed + Brittle Charm combo:** Both apply Vulnerable (Physical). They don't stack per HLD-COMBAT-007. Worth knowing during balance tuning but not a design problem
- **Mending on enemy side:** Potentially swingy if enemy health pools are small. Tuning risk for MVP1 playtest, not a spec concern
