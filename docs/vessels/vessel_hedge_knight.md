# Soul Protocol — Vessel Design: The Hedge Knight
## Version 0.3 · May 2026 · Solo Developer

> **Purpose:** Complete design definition for The Hedge Knight — a solo-path
> vessel unlocked from The Pilgrim.
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

**Name:** The Hedge Knight

**Circumstances of death:** He was a knight once — not a famous one, but a real
one. He had a code, a lord, a purpose. Everything he lost came apart through
forces he could not control. He died still wearing the remnants of it, still
moving in the direction he thought was right. He does not know if that was
enough. He suspects it wasn't. He is not certain.

**In purgatory:** Quiet and methodical. He does not rage against what happened
to him. He simply keeps going, because stopping would require an answer he
doesn't have. His uncertainty is not weakness — it is the one honest thing he
has left. His flavour text should feel like someone who chooses their words
carefully, who has learned that most things are not worth saying aloud.

**Narrative register:** Restrained, precise, carrying an unresolved question.
Not bitter. Not broken. Still reaching, without knowing quite what for.

**Narrative position:** The Hedge Knight is the soul after significant loss but
before total dissolution — the solo path's tier 2 vessel. The Paladin and the
Battle Wizard are earlier versions of that same soul, still whole. The Paladin
lost faith, the Battle Wizard lost power. By the time he is the Hedge Knight,
both are gone and only the discipline remains. He erodes further into the
Pilgrim, who has lost even that certainty about where he was going.

**Why he follows The Pilgrim:** The Pilgrim forgot where he was going. The
Knight remembers exactly where he was going — he just isn't sure he deserved
to get there. Same road. Different wound.

> **`[OPEN]`** Specific narrative details — the nature of the fall, the lord,
> the circumstances — to be defined in a later narrative pass.

---

## 2. Combat Profile

| Attribute | Value | Notes |
|---|---|---|
| **HP** | 32 | Above average — needs to sustain in Last Stand range without dying immediately |
| **Bound Companion** | No | Solo vessel |
| **Floors** | 2 | Floor 2 (The Blurred Deep) and Floor 3 (The Threshold) |

> **`[OPEN]`** Additional stats beyond HP — resistances, vulnerabilities, and
> vessel-specific resource pools to be revisited once the status effect system
> is defined. See `soul_protocol_game_design.md` section 5.2.

---

## 3. Ability Loadout

The Hedge Knight starts with two abilities — one passive, one active. Both
reflect the same truth: a warrior who has lost everything except the discipline
to keep fighting, and who is most dangerous when closest to the end.

Additional abilities are unlocked at the start of floor 2 and floor 3
respectively, reflecting a soul learning to reach deeper into what it once knew.

---

### Last Stand *(Passive)*

> *"He has been here before. Not this place — this feeling. The moment when
> everything has gone wrong and there is nothing left to lose. He has always
> fought best here."*

**Effect:** While the vessel's HP is below 25% of their maximum, all attacks
deal 1.5x damage. No charges. Always active when the condition is met.

**Action bucket:** Passive — no action required.

**Design intent:** Rewards playing in dangerous territory rather than playing
conservatively. A player who manages to sustain below 25% HP across multiple
turns gains consistent damage amplification that compounds with other attack
bonuses. Combined with Charge while active, the next attack deals 3x damage
— a high-risk ceiling experienced players will deliberately chase. The higher
HP pool exists to support this playstyle — the Knight needs room to drop into
Last Stand range and survive there, not to tank hits comfortably. Strong enough
that the player will immediately notice its absence when switching vessels.

---

### Charge *(Active — Utility)*

> *"He does not telegraph it. He does not announce it. He simply commits — and
> for one moment, everything he has left goes into a single point."*

**Effect:** Doubles the damage of the next attack. The buff is consumed on the
next attack whether it hits or misses.

**Action bucket:** Utility — free, does not consume the attack action.

**Charges:** To be tuned during playtesting.

**Design intent:** Creates a deliberate sequencing decision — use Charge first,
then select the best available attack to double. Rewards patience and resource
awareness. Scales naturally across the run as better attack items are acquired.
When combined with Last Stand, deals 3x total damage — the Knight's highest
damage ceiling and the payoff for playing dangerously.

> **`[OPEN]`** Charge count to be set during playtesting once typical floor
> encounter count is established.

---

### Floor 2 Ability

> **`[OPEN]`** To be designed once MVP1 core loop is validated through
> playtesting.

---

### Floor 3 Ability

> **`[OPEN]`** To be designed once MVP1 core loop is validated through
> playtesting.

---

## 4. Starting Items

The Hedge Knight begins every run with three items — the remnants of a former
life, worn and improvised but still carried. Each item is something a fallen
knight would have on them: not the finest equipment, but real.

Item flags referenced below are defined in `soul_protocol_game_design.md`
sections 3.4 and 3.5.

---

### Battered Sword *(Attack — Durability)*

> *"The edge is still good. He has made sure of that, at least."*

**Effect:** Deals damage to a single target. Damage is higher than the
Walking Staff.

**Action bucket:** Attack — occupies the attack action for the turn.

**Flags:** None.

**Charges:** Fewer durability charges than the Walking Staff. The knight is
expected to find and adapt to new weapons as the run progresses.

**Design intent:** Establishes the knight as someone who hits harder but
manages resources more carefully than the Pilgrim. The limited charges create
early pressure to find replacement attack items, reinforcing the vessel's
theme of adaptation and survival with what is available.

> **`[OPEN]`** Exact damage value and durability charge count to be set during
> playtesting relative to typical encounter damage and floor length.

---

### Iron Pendant *(Utility — Durability)*

> *"He does not speak of what it means to him. He does not need to."*

**Effect:** Replace the player's currently active fate omen with the
pendant's omen — **Fortified** (take half damage from all attacks this
cycle). The replaced omen is discarded. Fortified remains active for the
rest of the current omen cycle, then the next cycle begins as normal.
The Fortified omen exists only through pendant use — it is never in the
fate deck.

**Action bucket:** Utility — free, does not consume the attack action.

**Flags:** None.

**Charges:** 2 durability charges.

**Design intent:** A defensive tool with a specific and legible payoff.
The player uses it reactively — when a bad omen lands on their side, or
when they know a heavy incoming hit would otherwise be fatal. Two charges
creates meaningful decisions across a floor: save one for the Judge, or
spend both on difficult elite encounters. The Fortified omen's half-damage
effect pairs naturally with Last Stand — surviving long enough to drop
below 25% HP and activate the passive is exactly the situation the pendant
protects. Narratively a remnant of the Paladin or Battle Wizard's world —
something that once carried more power than it does now.

> **`[OPEN]`** Exact damage reduction fraction and cycle interaction edge
> cases to be confirmed during playtesting.

---

### Cheap Flask *(Consumable — Single Use)*

> *"He is not proud of it. It does the job."*

**Effect:** Applies a buff for the current combat encounter.

**Action bucket:** Consumable — free, does not consume the attack action.

**Flags:** None.

**Charges:** Single use.

**Design intent:** Introduces the combat buff consumable type. Thematically
fits the knight's register — not a fine remedy, just something that works.
Specific buff to be defined once the status effect system is designed.

> **`[OPEN]`** Specific buff effect to be defined once the status effect
> system is designed.

---

## 5. Bound Companion

The Hedge Knight has no bound companion. Whatever company he once kept, he
does not have it now.

The standard temporary companion encounter system applies — the Knight may
encounter companions through non-combat events in the normal way.

---

## 6. Unlock Conditions

**Unlocked by:** Completing a 1-floor run with The Pilgrim.

**Vessels unlocked by The Hedge Knight:**
Completing a 2-floor run with The Hedge Knight unlocks both solo-path tier 3
vessels:

- **The Paladin** — solo path tier 3
- **The Battle Wizard** — solo path tier 3

Both unlock simultaneously.

> **`[OPEN]`** Specific conditions beyond floor completion to be confirmed
> once The Paladin and The Battle Wizard designs are complete.

---

## 7. Design Notes

**Relationship to The Pilgrim:** The Pilgrim and the Hedge Knight share the
solo path and a common emotional register — both are people who kept moving
after everything fell apart. The Pilgrim forgot his destination. The Knight
remembers his and questions whether he deserved it. They are the same journey
at different stages of grief.

**Mechanical progression from The Pilgrim:** The Pilgrim shapes the opening
of every fight from safety. The Hedge Knight fights hardest at the edge of
survival. The sword hits harder but runs dry faster, forcing the player to
engage with the loot economy more actively. Last Stand rewards the player
for taking risks the Pilgrim would never take. The pendant introduces omen
replacement — a more active form of fate manipulation than the Pilgrim's
passive deck management.

**The Last Stand + Charge interaction:** Using Charge while Last Stand is
active produces 3x damage on the next attack. This is the Knight's highest
ceiling and the payoff for playing in dangerous territory. Experienced players
will deliberately manage HP to stay below 25% before a boss fight. New players
will discover it by accident and understand immediately why staying alive
matters less than hitting hard.

**HP rationale:** The Knight's 32 HP is not there to make him a tank — it is
there to make Last Stand viable. A knight who drops to 25% of 32 HP (8 HP)
has real room to fight in that zone before dying. The higher pool makes the
Last Stand threshold meaningful rather than suicidal. Players who treat the
HP as a buffer to hide behind are misreading the kit.

**Graduation:** Like the Pilgrim, the Hedge Knight is designed to be outgrown
on his branch. His floor 2 and floor 3 abilities will deepen the kit, but the
vessels that follow on the solo path — the Paladin and the Battle Wizard —
will bring more complex and demanding starting positions.

---

*Vessel: The Hedge Knight v0.3*
*Companion to soul_protocol_game_design.md*
*v0.1: Initial design — identity, combat profile, Charge ability, three
starting items (Battered Sword, Iron Pendant, Cheap Flask), solo vessel,
unlocked by Pilgrim 1-floor completion.*
*v0.2: Two-ability structure adopted. Last Stand added as passive — 1.5x
damage below 25% HP. Charge reclassified as active utility. Iron Pendant
redesigned — now replaces active fate omen with Fortified (half damage),
2 charges. Row and melee/ranged references removed throughout.*
*v0.3: HP updated 26 → 32 to support Last Stand playstyle. Floors field
added to combat profile. Narrative position added to identity. Item flag
references corrected to 3.4 and 3.5. Unlock conditions filled in — 2-floor
completion unlocks The Paladin and The Battle Wizard. Iron Pendant narrative
connection to Paladin/Battle Wizard noted. HP rationale added to design notes.*
*Next: Define floor 2 and floor 3 abilities post-MVP1. Define specific unlock
conditions once The Paladin and The Battle Wizard designs are complete.*
