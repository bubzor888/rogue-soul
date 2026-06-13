## Context

The Judge is the Floor 3 boss whose narrative purpose is to judge the soul's *need*, not its worthiness (HLD-NAR-002). The existing system has no mechanical expression of this judgment. The fight must feel like an evaluation — not just a stat check — where the player's choices throughout the run have visible consequences when they arrive at the threshold.

All existing enemies are single-entity encounters or encounter groups with fixed compositions. The Judge introduces a multi-entity boss structure where optional sub-targets (Witnesses) modify the main fight rather than being required kills.

## Goals / Non-Goals

**Goals:**
- Fully define The Judge as a playable, learnable Floor 3 boss for MVP1
- Express the "need vs. holding" narrative through a whole-run scoring mechanic that visibly affects the encounter
- Give players meaningful choices during the boss fight: which witnesses to kill (if any), when to spend items via Repent
- Introduce a phase transition that raises stakes at low Judge HP without adding new entity types
- Keep all mechanics expressible within the existing status effect, omen, and intent systems

**Non-Goals:**
- lld-technical-architecture changes — data model and engine changes are deferred to a follow-on change
- Vessel-specific Judge dialogue — LLD-NARRATIVE work, deferred per HLD-NAR-002 open item
- Visual/art direction for the Judge encounter — deferred to a UI/art direction session
- Difficulty scaling for Tier 2+ vessels — Floor 3 boss scaling is an MVP3 concern

## Decisions

### Multi-entity structure: Judge + two passive Witnesses

The fight has three entities: The Judge (required kill) and two Witnesses (optional). Witnesses never attack. They modify the Judge's stats each turn via their intents. Killing a Witness stops its effect but triggers a temporary status penalty on the player.

**Why not a single-entity boss?** A solo boss reduces the fight to a pure DPS race. The Witnesses create a prioritization decision: do you spend turns killing a Witness (removing its effect on the Judge) knowing it will hurt you briefly, or do you ignore them and fight through their contributions?

**Why passive Witnesses?** Active Witnesses attacking alongside the Judge would make the fight feel like a standard multi-enemy encounter. Passive Witnesses make the fight feel like a legal proceeding — they testify (modify the Judge) rather than fight.

### Witness behavior driven by item score, not a fixed value

Each Witness checks the player's current `judge_need_score` on its turn and applies its effect at the appropriate tier. The score can change during the fight (as the player spends consumables or uses Repent), causing witnesses to shift tiers between their turns.

**Why not fixed stats?** Fixed stats ignore the run's choices. A score-driven system means a player who arrived lean has witnesses that barely help the Judge, while a hoarder faces witnesses at full strength.

**Why update on the witness's turn?** Immediate updates mid-turn would allow score changes to retroactively affect effects already applied this cycle. Updating on the witness's turn respects the max-wins rule naturally: an existing Mending 5 on the Judge persists until the omen shift even after the score drops, because the re-application at a lower magnitude loses to the existing higher instance.

### Score formula: +1 starting, +2 take, −1 spend

Starting items are valued at +1 rather than +2 so that shedding a starting item yields net zero. This prevents higher-tier vessels (who start with more items) from being permanently disadvantaged if they manage their loadout.

Taking any item is +2 regardless of charge count. Spending/exhausting any item (including via Repent discard) is −1 regardless of how many charges it had. Per-encounter items cannot be exhausted during the Judge fight (they reset per encounter), making them permanently +2 with no in-fight path to reduction.

### Three score tiers (Low/Medium/High) with fixed witness magnitudes per tier

| Tier | Score range | Mercy (Mending to Judge) | Vengeance (Emboldened Physical to Judge) |
|---|---|---|---|
| Low | 0–7 | magnitude 1 | flat +1 |
| Medium | 8–13 | magnitude 3 | flat +2 |
| High | 14+ | magnitude 5 | flat +3 |

**Why three tiers rather than continuous scaling?** Continuous scaling requires communicating a number to the player. Three tiers map to readable witness behavior — the player can observe the Mending tick rate and infer their tier. Dialogue at boss entry can also communicate the tier narratively without showing a UI number.

### Kill consequences as temporary status effects

- Killing Witness of Mercy: player gains Vulnerable (Physical) until next omen shift
- Killing Witness of Vengeance: player gains Frenzied until current omen cycle ends

Both effects are tied to omen timing so they're predictable and survivable. The Judge deals all physical damage, so both consequences have teeth: Vulnerable means the next Judge hit does ×1.5; Frenzied means the player hits harder but also takes ×1.5.

**Why not permanent penalties?** A permanent penalty for killing a Witness would discourage the choice entirely at high item counts (where killing the Witnesses is the right call). Temporary effects create a danger window the player must navigate rather than a permanent punishment.

### Phase transition at ≤30% HP (Pass Judgment)

Below ~9 HP, the Judge stops using its normal intent pool and locks into `pass_judgment` (charge→release, 5–7 physical) exclusively. No Ponder, no Suffer — just relentless telegraphed strikes.

**Why a hard phase transition rather than escalating damage?** The Lightning Elemental uses escalating damage (turn-by-turn). The Judge's narrative is about reaching a verdict — the final phase should feel like a decision being made, not a meter filling up. The transition communicates: the Judge has heard enough.

### Repent as a Judge omen card (3 copies)

Repent is the Judge's only omen contribution. On player side: player discards 1 of 2 randomly revealed items, gains 5 HP, score −1. On Judge side: no effect.

**Why 3 copies?** With a typical combat deck of 18–22 cards, 3 copies means Repent appears roughly 2–3 times per fight. Enough to matter and create recurring decisions; not so frequent that it dominates.

**Why choose from 2 randomly revealed options?** Pure player choice trivializes it (always discard the worst item). Pure random is too punishing in an already-demanding fight. Two options preserves agency while maintaining some tension.

**Why straight HP heal rather than Mending?** Mending is already present in the fight via the Witness of Mercy. A direct heal is simpler to evaluate and doesn't interact awkwardly with the Mending that the Judge may already have applied to itself.

**Why does Repent do nothing on the Judge side?** Steering Repent to the Judge is always a legal "safe dump" option — the player sacrifices the timer value and the healing but loses no item. This gives players an out when Repent appears and they can't afford to discard anything.

## Risks / Trade-offs

**Score system requires whole-run tracking from the first item pickup** → The score must be initialized at run start and updated on every item acquisition and spend event. This is a new cross-cutting data concern. Mitigation: tracked as a single integer in run state; the lld-technical-architecture change will define the exact field and update hooks.

**Witness tier can change mid-fight, possibly confusing players** → A player who spends items during the fight may see the Judge's Mending tick rate change without obvious cause. Mitigation: the witness's intent display should visually update when its tier changes; narrative dialogue at tier shift can reinforce the reason.

**Frenzied kill consequence is ambiguous (benefit or penalty?)** → Frenzied gives the player Vulnerable *and* Emboldened (Physical) simultaneously. In an all-physical fight, the Emboldened can be exploited offensively. This is intentional — the player who understands the system can time the Frenzied window — but may confuse first-time players. Mitigation: Soul Codex entry for the Judge describes the consequence once encountered.

**Pass Judgment at low HP may be too spikey** → A charge→release loop at 5–7 physical on a 24 HP Pilgrim is ~21–29% of max HP per hit. If the player arrives at 30% Judge HP with low HP themselves, the phase may feel unwinnable. Mitigation: all values marked for playtesting; Repent's 5 HP heal is designed to give a survival window before the final phase.

## Open Questions

- `[OPEN·MVP1]` All stat values (Judge HP 30, witness HP 10, damage ranges, Mending magnitudes, Emboldened magnitudes, Repent heal 5) to be validated in playtesting.
- `[OPEN·MVP1]` Judge intent weights (strike 50% / suffer 30% / ponder 20%) to be tuned during playtesting.
- `[OPEN·MVP1]` Exact score bracket thresholds (Low 0–7, Medium 8–13, High 14+) may need adjustment once higher-tier vessels with more starting items are designed.
- `[OPEN·MVP1]` Vessel-specific Judge dialogue (HLD-NAR-002) deferred to lld-narrative design session.
- `[OPEN·MVP2]` Visual/audio design for witness tier shifts and phase transition.
