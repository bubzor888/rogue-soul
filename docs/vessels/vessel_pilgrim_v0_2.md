# Soul Protocol — Vessel Design: The Pilgrim
## Version 0.2 · May 2026 · Solo Developer

> **Purpose:** Complete design definition for The Pilgrim — the tutorial vessel.
> This document covers identity, combat profile, ability loadout, and starting
> items. It is a companion to `soul_protocol_game_design.md` for system-level
> rules that apply to all vessels.
>
> Open questions are marked **`[OPEN]`**.

---

## Table of Contents

1. [Identity](#1-identity)
2. [Combat Profile](#2-combat-profile)
3. [Ability Loadout](#3-ability-loadout)
4. [Starting Items](#4-starting-items)
5. [Bound Companion](#5-bound-companion)
6. [Unlock Conditions](#6-unlock-conditions)
7. [Design Notes](#7-design-notes)

---

## 1. Identity

**Name:** The Pilgrim

**Circumstances of death:** He had been walking for a very long time. Not fleeing,
not wandering — moving toward something specific, something that mattered enough
to keep him on the road through seasons and hardship. He died on the road, still
walking. Whatever the destination was, he never wrote it down. The map in his
pack has a mark on it but no name beside it.

**In purgatory:** Calm. Unhurried. He does not know what he was looking for but
the habit of moving forward remains. He is not distressed by purgatory — he has
slept in worse places. His confusion is quiet rather than desperate: *I was going
somewhere. I am sure of it.*

**Narrative register:** Weathered, patient, observational. He notices things.
He has spent a long time reading roads and the people on them. His flavour text
should feel like someone who has seen a great deal and is not easily startled.

**Why he is the first vessel:** The Pilgrim's instincts — reading danger, moving
forward, carrying what is necessary and nothing more — map directly onto the
skills a new player needs to develop. He does not overwhelm. He demonstrates.

---

## 2. Combat Profile

| Attribute | Value | Notes |
|---|---|---|
| **HP** | 30 | Above average — forgiving of early mistakes |
| **Bound Companion** | No | Solo vessel at MVP |

> **`[OPEN]`** Additional stats beyond HP — resistances, vulnerabilities, and
> vessel-specific resource pools to be revisited once the status effect system
> is defined. See `soul_protocol_game_design.md` section 5.2.

---

## 3. Ability Loadout

The Pilgrim has one ability. It is a remnant of the instincts worn into him by
long years on the road — reading the signs ahead, anticipating what is coming.
Mechanically useful to a new player learning the omen system; remains tactically
relevant to experienced players managing priority targets.

---

### Read the Road *(Support)*

> *"He does not know where he learned to read a road this way. He only knows
> that he has never been surprised by weather, by ambush, or by the intentions
> of strangers. The habit remains even here."*

**Effect:** Reveals which enemy is the source of each active omen on the vessel
and companions this turn.

**Action bucket:** Support — free, does not consume the attack action.

**Charges:** 3, replenished at floor start.

**Design intent:** Bridges the gap for new players still learning to read omens
by their appearance alone. For experienced players, shifts from a teaching tool
to a targeting tool — knowing which enemy to eliminate first to clear the most
dangerous omens remains valuable regardless of omen familiarity. Scales poorly
as a standalone mechanic, which is intentional: the Pilgrim is a vessel players
graduate away from, not one they return to for power.

---

## 4. Starting Items

The Pilgrim begins every run with three items. They are the possessions he had
on him when he died — sparse, practical, chosen by a man who knew the weight
of everything he carried.

Each starting item is designed to introduce one part of the item system to a
new player without overwhelming them. Item flags referenced below are defined
in `soul_protocol_game_design.md` sections 3.5 and 3.6.

---

### Walking Staff *(Attack — Durability)*

> *"Worn smooth at the grip. He has carried it so long he no longer notices
> the weight."*

**Effect:** Deals melee damage to a single front-row target.

**Action bucket:** Attack — occupies the attack action for the turn.

**Flags:** None.

**Charges:** Multiple durability charges. *(exact number to be tuned during
playtesting)*

**Design intent:** Introduces the attack item bucket. Simple melee damage with
no secondary effects — the player learns that items can fill the attack action
before more complex attack items are introduced. The durability model teaches
that run-found attack items are finite without being immediately exhausted.

> **`[OPEN]`** Durability charge count to be set during playtesting once typical
> floor encounter count is established.

---

### Loaf of Bread *(Consumable — Single Use)*

> *"Still good. Probably. He has eaten worse."*

**Effect:** Restores a small amount of HP to the vessel.

**Action bucket:** Consumable — free, does not consume the attack action.

**Flags:** Floor-bound. See `soul_protocol_game_design.md` section 3.5.

**Charges:** Single use.

**Design intent:** Introduces the consumable bucket and the floor-bound flag.
New players on a single-floor run will not feel the floor restriction — it only
becomes meaningful when going deeper, where the player should already understand
consumable management. The heal is intentionally small: it teaches the bucket
exists without solving problems on its own.

> **`[OPEN]`** Heal amount to be set during playtesting relative to typical
> incoming damage per floor.

---

### Worn Map *(Non-Combat — Encounter Countdown)*

> *"There is a mark on it. He has no memory of making it, or of what it meant.
> But the mark is there, and some part of him still believes in it."*

**Effect:** When acquired, begins counting down. After 3 encounters, the next
encounter slot is replaced by a temporary companion encounter. The two-door
corridor choice for those 3 encounters is replaced with a single door — the
path narrows toward the meeting. Normal two-choice navigation resumes after
the meeting encounter resolves. Who arrives is drawn from the current floor's
temporary companion pool and is not predetermined. The Worn Map is then removed
from inventory.

**Action bucket:** None — this item is not used in combat and does not appear
in the combat interface.

**Flags:** Encounter-countdown (counter: 3). See `soul_protocol_game_design.md`
section 3.6. As a starting item the counter is guaranteed to reach zero before
the floor boss.

**Charges:** Single use — removed on trigger.

**Design intent:** Introduces the temporary companion mechanic at a moment
the player controls rather than leaving it entirely to RNG. Also introduces
the encounter-countdown item type — the player can see the counter ticking
down in inventory and anticipate what is coming. The narrowed corridor teaches
that some choices trade navigation agency for a guaranteed outcome.

---

## 5. Bound Companion

The Pilgrim has no bound companion. He has been traveling alone for a very
long time.

The Worn Map is the primary path to a temporary companion on a first run.
The standard temporary companion encounter system also applies — the Pilgrim
may encounter companions through non-combat events in the normal way.

---

## 6. Unlock Conditions

**Availability:** The Pilgrim is available from the start of the game. No
unlock condition required — he is the first vessel, always present.

**Vessels unlocked by The Pilgrim:**

> **`[OPEN]`** Which vessels the Pilgrim unlocks, and the specific experience
> conditions that trigger those unlocks, are to be defined once the next vessel
> designs are complete.

---

## 7. Design Notes

**Teaching sequence:** The Pilgrim's design introduces the core systems in a
natural order across a typical first run:

1. **Read the Road** — introduces the omen system and the support bucket on
   the first combat encounter
2. **Walking Staff** — introduces the attack item bucket as an alternative
   to a bare attack
3. **Loaf of Bread** — introduces the consumable bucket and the floor-bound
   flag when HP first drops
4. **Worn Map** — introduces the encounter-countdown item type and temporary
   companions mid-run at a moment the player controls

No single encounter requires the player to engage with all systems at once.
Each system is encountered when it becomes relevant rather than front-loaded
in a tutorial sequence.

**Graduation:** The Pilgrim is intentionally designed to be outgrown. Read
the Road does not scale with enemy difficulty. The Walking Staff is a baseline
melee weapon with no secondary effects. A player returning to the Pilgrim after
unlocking later vessels will feel the difference — not because he has become
weaker, but because they have become more capable of appreciating what a vessel
can do.

---

*Vessel: The Pilgrim v0.2*
*Companion to soul_protocol_game_design.md*
*v0.1: Initial design — identity, combat profile, Read the Road ability,
three starting items (Walking Staff, Loaf of Bread, Worn Map), solo vessel.*
*v0.2: Item entries updated to reference system-level flags — floor-bound
(Loaf of Bread) and encounter-countdown (Worn Map) — defined in
soul_protocol_game_design.md sections 3.5 and 3.6. Worn Map reclassified
as non-combat item.*
*Next: Define unlock conditions once subsequent vessel designs are complete.*
