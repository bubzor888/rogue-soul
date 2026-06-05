# Soul Protocol — Vessel Design: The Pilgrim
## Version 0.4 · May 2026 · Solo Developer

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

**Narrative position:** The Pilgrim is the soul at its most eroded — the endpoint
of a long history, not a starting point. He plays only the final floor, the
threshold itself. What he has lost has made him lighter. The Judge barely
scrutinises him.

---

## 2. Combat Profile

| Attribute | Value | Notes |
|---|---|---|
| **HP** | 24 | Below average — the run should feel earned, not comfortable |
| **Bound Companion** | No | Solo vessel |
| **Floors** | 1 | Floor 3 only — the threshold |

> **`[OPEN]`** Additional stats beyond HP — resistances, vulnerabilities, and
> vessel-specific resource pools to be revisited once the status effect system
> is defined. See `soul_protocol_game_design.md` section 5.2.

---

## 3. Ability Loadout

The Pilgrim has two abilities — one passive, one active. Both are remnants of
instincts worn into him by long years on the road: reading what lies ahead,
and knowing how to make what little he carries last.

---

### Read the Road *(Passive)*

> *"He does not know where he learned to read a road this way. He only knows
> that he has never been surprised by weather, by ambush, or by the intentions
> of strangers. The habit remains even here."*

**Effect:** At the start of every combat, before the first omen cycle begins,
look at the top 3 cards of the fate omen deck. Any number of them may be sent
to the bottom of the deck. The remaining cards stay on top in their original
order. Triggers automatically — no action required.

**Action bucket:** Passive — triggers at combat start, costs nothing.

**Design intent:** Shapes every fight from the first turn. A new player gets
immediate clarity before a single action is taken — unfamiliar or dangerous
omen cards can be buried before they arrive. An experienced player uses it to
sequence the opening of a fight optimally, setting up a favourable first cycle.
The cards are never removed from the deck, only delayed — fate cannot be
escaped, only navigated. Strong enough that the player will notice its absence
when switching to another vessel.

---

### Good as New *(Active — Utility)*

> *"He has repaired this thing a hundred times. He will repair it a hundred
> more. The road teaches you not to throw anything away."*

**Effect:** Reset the durability of one item to its maximum charge count.
Has no effect on single-use items — an item with 1 maximum charge reset to
1 is unchanged. Intended for durability items running low mid-combat.

**Action bucket:** Utility — free, does not consume the attack action.

**Charges:** 1, replenished at floor start.

**Design intent:** A quiet practical ability that rewards planning. Saving
a favoured weapon from breaking at a critical moment, or restoring a support
item before the Judge, creates genuine decisions about when to use the single
charge. Not powerful on its own — the passive is the Pilgrim's strength —
but consistently useful across every run regardless of what items the player
has acquired.

---

## 4. Starting Items

The Pilgrim begins every run with three items. They are the possessions he had
on him when he died — sparse, practical, chosen by a man who knew the weight
of everything he carried. There is no healing in his kit. What he carries is
what he has. The run should feel earned.

Item flags referenced below are defined in `soul_protocol_game_design.md`
sections 3.4 and 3.5.

---

### Walking Staff *(Attack — Durability)*

> *"Worn smooth at the grip. He has carried it so long he no longer notices
> the weight."*

**Effect:** Deals damage to a single target.

**Action bucket:** Attack — occupies the attack action for the turn.

**Flags:** None.

**Charges:** Multiple durability charges. *(exact number to be tuned during
playtesting)*

**Design intent:** Introduces the attack item bucket. Simple damage with no
secondary effects — the player learns that items can fill the attack action
before more complex attack items are introduced. The durability model teaches
that run-found attack items are finite without being immediately exhausted.

> **`[OPEN]`** Durability charge count to be set during playtesting once typical
> floor encounter count is established.

---

### Spoiled Potion *(Consumable — Single Use)*

> *"It was supposed to be something else. He has been carrying it too long.
> He is not sure what it is now, but it does something."*

**Effect:** Applies poison to one enemy.

**Action bucket:** Consumable — free, does not consume the attack action.

**Flags:** None.

**Charges:** Single use.

**Design intent:** Introduces the consumable bucket with an offensive rather
than defensive use — teaching that consumables are not only healing items.
Introduces poison as a damage-over-time mechanic. The name implies that
better potions exist to be found, giving the player something to look forward
to acquiring. The flavour fits the Pilgrim's register — he carried something
useful that became something else through neglect and time.

> **`[OPEN]`** Poison damage amount and duration to be set once the status
> effect system is designed.

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
section 3.5. As a starting item the counter is guaranteed to reach zero before
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
Completing a 1-floor run with The Pilgrim unlocks both tier 2 vessels:

- **The Drifter** — companion path
- **The Hedge Knight** — solo path

Both unlock simultaneously. The player chooses which branch to explore first.

---

## 7. Design Notes

**Teaching sequence:** The Pilgrim's design introduces the core systems in a
natural order across a typical first run:

1. **Read the Road** — introduces the fate omen system passively on the first
   combat encounter. The player sees the deck shaped before they've acted,
   learning that fate can be influenced before it arrives.
2. **Good as New** — introduces the utility action bucket and the value of
   item durability management when a weapon starts running low.
3. **Walking Staff** — introduces the attack item bucket as an alternative
   to the Default Strike.
4. **Spoiled Potion** — introduces the consumable bucket with an offensive
   use, and introduces poison as a status effect.
5. **Worn Map** — introduces the encounter-countdown item type and temporary
   companions mid-run at a moment the player controls.

No single encounter requires the player to engage with all systems at once.
Each system is encountered when it becomes relevant rather than front-loaded
in a tutorial sequence.

**No starting heal — intentional:** The Pilgrim carries nothing to restore
his HP. His run should feel earned across multiple attempts, not comfortable
on the first try. The lower HP pool reinforces this — 24 HP means mistakes
have real consequences even on the single floor he plays.

**Narrative position:** The Pilgrim is the soul at its most eroded. On a first
run he is simply a calm man on a road. After playing deeper vessels the player
understands what he used to be — and the simplicity of his kit becomes
something more than a tutorial limitation.

**Graduation:** The Pilgrim is intentionally designed to be outgrown. Read
the Road is powerful but passive — the player contributes nothing to trigger
it. Good as New is reliable but narrow. A player returning to the Pilgrim
after unlocking later vessels will feel the difference — not because he has
become weaker, but because they have become more capable of appreciating what
a vessel's active kit can do.

---

*Vessel: The Pilgrim v0.4*
*Companion to soul_protocol_game_design.md*
*v0.1: Initial design — identity, combat profile, Read the Road ability,
three starting items (Walking Staff, Loaf of Bread, Worn Map), solo vessel.*
*v0.2: Item entries updated to reference system-level flags. Worn Map
reclassified as non-combat item. Read the Road reworked as passive ability
triggering at combat start. Good as New added as active utility ability.
Ability loadout expanded to 2 abilities per vessel standard.*
*v0.3: Floor-bound flag removed from Loaf of Bread. Walking Staff row
reference removed. Item flag section references updated. Unlock conditions
filled in. Narrative position added. Floors field added to combat profile.*
*v0.4: HP updated 30 → 24 — run should feel earned, not comfortable. Loaf
of Bread replaced with Spoiled Potion — single use, applies poison to one
enemy. No starting healing item. Design notes updated to reflect intentional
absence of heal.*
*Next: Define unlock conditions will be updated once The Drifter and The
Hedge Knight designs are complete.*
