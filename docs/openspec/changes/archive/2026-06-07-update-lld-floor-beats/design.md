## Context

`LLD-FLOOR-STRUCT-006` now formally defines Floor 3 as 4 pre-elite + Elite Gate + 4 post-elite. With that structure pinned, "rooms 5–6 range" in `LLD-FLOOR-BEATS-004` is no longer accurate — the Elite Gate is always room 5. Similarly, the encounter caps table in `LLD-FLOOR-PATT-003` should reflect the full picture of what the generation system is actually constraining.

## Goals / Non-Goals

**Goals:**
- Pin Elite Gate to room 5 in `LLD-FLOOR-BEATS-004`
- Remove the Temporary Companion row from `LLD-FLOOR-PATT-003` (it belongs in `LLD-FLOOR-BEATS-003`, not the general caps table)
- Add Standard Combat to the caps table (2–3 pre-elite, 1–2 post-elite, max 5)

**Non-Goals:**
- Changing how the counter system works
- Touching any other spec

## Decisions

**Elite Gate at room 5:** With 4 pre-elite rooms (1–4) and 4 post-elite rooms (6–9), room 5 is the only valid position. Stating it explicitly removes any implementation ambiguity.

**Standard Combat caps (2–3 / 1–2 / max 5):** 4 standard combats target (from `LLD-FLOOR-STRUCT-002`) with variance. Pre-elite: 2–3 (the Worn Map beat at room 4 may displace one combat slot). Post-elite: 1–2 (elite + post combats). Max 5 across the floor is consistent with the run-length breakdown.

**Remove Temporary Companion row:** The companion encounter is a forced beat (Worn Map), not a pool-based encounter type subject to caps. Listing it in the caps table implies it competes with other types for slots, which misrepresents the design.
