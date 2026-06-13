## REMOVED Lines

Remove the following `[OPEN·MVP1]` annotation lines. These describe numbers that are subject to playtesting tuning, which is universally true and requires no explicit annotation. Surrounding requirement content is unchanged.

- After Zombie intent table: `` `[OPEN·MVP1]` Slam release damage range (5–7) to be validated in playtesting. ``
- After Bear intent table: `` `[OPEN·MVP1]` Swipe per-hit damage range (3–5) to be validated in playtesting. ``
- After Judge HP/tags line (first): `` `[OPEN·MVP1]` All stat values to be validated in playtesting. ``
- After Judge intent table: `` `[OPEN·MVP1]` Damage ranges, intent weights, and Pass Judgment threshold to be validated in playtesting. ``
- After Witness of Mercy HP/tags line: `` `[OPEN·MVP1]` Mending magnitudes to be validated in playtesting. ``
- After Witness of Vengeance HP/tags line: `` `[OPEN·MVP1]` Emboldened magnitudes to be validated in playtesting. ``
- After Fire Elemental intent table: `` `[OPEN·MVP1]` Kindle magnitude value (2) and fire_strike damage range (4–6) to be validated in playtesting. ``
- After Ice Elemental intent table: `` `[OPEN·MVP1]` Frost Bolt damage range (3–5) and Glacial Mark weight (40%) to be validated in playtesting. ``
- After Lightning Elemental phase 1 table: `` `[OPEN·MVP1]` Phase 1 damage ranges and escalation pacing to be validated in playtesting. ``
- After Lightning Elemental spark table: `` `[OPEN·MVP1]` Spark damage ranges to be validated in playtesting. ``
- After Low HP Fanatic intent table: `` `[OPEN·MVP1]` Damage range (3–5) and Frenzied magnitude (2) to be validated in playtesting. ``
- After High HP Fanatic intent table: `` `[OPEN·MVP1]` Damage range (2–4) and Frenzied magnitude (2) to be validated in playtesting. ``
- After Buff Totem intent table: `` `[OPEN·MVP1]` Emboldened magnitude (2) to be validated in playtesting. ``
- After Absorption Totem intent table: `` `[OPEN·MVP1]` Hardened magnitude (3) to be validated in playtesting. ``

**Also remove** (design question now resolved — no min-1 clamp exists, Hardened can reduce to 0):
- `` `[OPEN·MVP1]` Interaction between Hardened absorb and the min-1 damage clamp (LLD-ARCH-019 step 8) to be resolved during implementation — Hardened absorption should reduce damage to 0 before the clamp applies. ``

**Re-tag to `[OPEN·MVP2]`** (narrative content — not needed for headless engine testing):
- `` `[OPEN·MVP1]` Vessel-specific Judge dialogue to be written in lld-narrative (per HLD-NAR-002). `` → change to `[OPEN·MVP2]`

**Keep unchanged:**
- `[OPEN·MVP2]` Visual design lines — unchanged
