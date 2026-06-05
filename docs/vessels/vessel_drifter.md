# Soul Protocol — Vessel Design: The Drifter
## Version 0.1 · May 2026 · Solo Developer

> **Purpose:** Complete design definition for The Drifter — a companion-path
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

**Name:** The Drifter

**Circumstances of death:** She once belonged somewhere — had a community, a
place, a role that gave shape to her days. Everything that gave her life
structure was lost, through forces she could not control or choices she could
not unmake. After that she moved. Not toward anything in particular, just away
from staying still. She died the way she had lived for years — in transit,
between places, carrying almost nothing. The ferret was with her. It always was.

**In purgatory:** Watchful. Quietly resourceful. She does not mourn what she
lost — or if she does, she has learned not to show it. Purgatory is just
another place she is passing through. She has slept in worse. She has eaten
less. She is already looking for the exits.

**Narrative register:** Understated, practical, a little guarded. She does not
say more than she needs to. Her flavour text should feel like someone who has
learned that attachment is a liability and has made peace with that, mostly.

**Narrative position:** The Drifter is the soul after significant loss but
before total dissolution — the companion path's tier 2 vessel. Once she
belonged to something. The Shaman and the Ranger are earlier versions of that
same soul, still whole. By the time she is the Drifter, the community is gone
and only the instinct to keep moving remains. She erodes further into the
Pilgrim, who travels entirely alone.

---

## 2. Combat Profile

| Attribute | Value | Notes |
|---|---|---|
| **HP** | 28 | Middle — survives through evasion and escape rather than tanking |
| **Bound Companion** | Yes — The Ferret | See section 5 |
| **Floors** | 2 | Floor 2 (The Unmarked Edge) and Floor 3 (The Threshold) |

> **`[OPEN]`** Additional stats beyond HP — resistances, vulnerabilities, and
> vessel-specific resource pools to be revisited once the status effect system
> is defined. See `soul_protocol_game_design.md` section 5.2.

---

## 3. Ability Loadout

The Drifter has two abilities — one active, one passive via her bound
companion. The active reflects the accumulated resilience of someone who has
taken a great deal of damage and learned to keep going. The passive is the
ferret — not a trained skill but a relationship, the one constant across
years of rootless living.

Additional abilities are unlocked at the start of floor 2 and floor 3
respectively.

---

### Hardy *(Active — Utility)*

> *"She does not explain how she shook it off. She just did. She has had
> practice."*

**Effect:** Clear one Hardy-clearable debuff or status effect from the vessel.
Not all debuffs and status effects are Hardy-clearable — each will be flagged
when the status effect system is designed. Hardy covers conditions the vessel
could plausibly shake off through resilience: weakness, vulnerability, slow,
and similar. It does not cover conditions that would not respond to sheer
endurance, such as freeze or petrify.

**Action bucket:** Utility — free, does not consume the attack action.

**Charges:** 3, replenished at floor start.

**Design intent:** Situational but critical when relevant. Against enemies that
do not apply clearable debuffs, Hardy sits unused. Against enemies that stack
debuffs, it becomes the difference between surviving and not. Three charges per
floor means the player must choose when to invoke it rather than clearing
everything automatically. Pairs naturally with the Lucky Paw's evasion — both
abilities reflect a survivor who absorbs what she can't avoid and shakes off
what she can.

> **`[OPEN]`** Hardy-clearable flag to be assigned to each debuff and status
> effect when the status effect system is designed.

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

The Drifter begins every run with three items — things found, borrowed, or
quietly taken over years of moving through other people's places. Nothing
was bought. Nothing was made. Everything has a history she may or may not
know.

Notably, the Drifter starts with no attack item. Her only offensive option
for the first combat is the Default Strike — Throw Rock. This is intentional:
the first post-combat reward or ferret find is expected to provide a weapon.
The Lucky Paw's evasion buff covers the vulnerability of those first two
combats.

Item flags referenced below are defined in `soul_protocol_game_design.md`
sections 3.4 and 3.5.

---

### Pocket of Sand *(Consumable — Single Use)*

> *"She has used this trick before. It works every time, if you are already
> moving when you throw it."*

**Effect:** Escape the current combat immediately with no rewards. Cannot be
used in elite or boss encounters.

**Action bucket:** Consumable — free, does not consume the attack action.

**Flags:** None.

**Charges:** Single use.

**Design intent:** The Drifter's strongest starting item and her most
distinctive tool. Introduces the concept that not every fight needs to be
won — sometimes the smart move is to leave. The no-reward cost is meaningful:
using it means missing the post-combat item drops, including the ferret's
bonus find. The restriction to standard encounters keeps it from trivialising
elite and boss fights. Fits the Drifter's identity — hard to pin down, always
looking for the exit.

---

### Loaf of Bread *(Consumable — Single Use)*

> *"She does not ask where it came from. It is there, and she is hungry.
> That is enough."*

**Effect:** Restores a small amount of HP to the vessel.

**Action bucket:** Consumable — free, does not consume the attack action.

**Flags:** Floor-bound. See `soul_protocol_game_design.md` section 3.4.
Removed at floor transition if unused.

**Charges:** Single use.

**Design intent:** Introduces the consumable bucket and the floor-bound flag.
On the Drifter, the floor restriction is felt — she plays two floors, so
bread carried from floor 2 does not survive to floor 3. Teaches the player
to use consumables within the floor rather than hoarding them. The heal is
intentionally small.

> **`[OPEN]`** Heal amount to be set during playtesting relative to typical
> incoming damage per encounter.

---

### Lucky Paw *(Support — Durability)*

> *"She does not know whose it was originally. She found it a long time ago
> and has carried it since. It still has a little luck left in it, she thinks.
> Not much. But some."*

**Effect:** At the start of each combat while the Lucky Paw has charges
remaining, the vessel gains the **Evasive** buff — a 25% chance to dodge
incoming physical attacks for that combat. The Lucky Paw decrements by 1
charge per combat, not per use. When charges are exhausted the buff no longer
applies and the item is removed.

**Action bucket:** Support — passive trigger at combat start, does not consume
the utility action.

**Flags:** None.

**Charges:** 2. Decrements per combat.

**Design intent:** Covers the Drifter's early vulnerability from having no
starting weapon. The first two combats have a 25% physical dodge chance,
giving the player room to find a weapon from the ferret's loot or the standard
post-combat drops before the protection expires. The item fading naturally
across two combats removes the safety net exactly when the player should no
longer need it. Narratively a remnant of the Shaman or Ranger's world —
something that carried real power once, almost spent.

> **`[OPEN]`** Dodge chance to be tuned during playtesting. Physical attacks
> only — does not apply to magical, elemental, or spiritual damage types.

---

## 5. Bound Companion

### The Ferret

> *"It has been with her longer than anything else. It does not have a name,
> or if it does she has never used it out loud. It finds things. That is what
> it does."*

The Ferret is the Drifter's bound companion. It is not a combatant — it
cannot be targeted, has no HP, and cannot be lost. It is simply present,
doing what ferrets do.

**Passive effect — Scavenge:**
At the start of each combat, the Ferret identifies a target — an enemy or
an environmental detail — and begins working toward it. The loot is determined
immediately; the game uses this to drive the correct visual behaviour (the
Ferret moves toward an enemy to pickpocket, or disappears into a crack in the
environment to rummage). The player does not see what was found until the
post-combat reward screen.

At the end of combat, a bonus item is added to the reward screen alongside
the standard two post-combat drops. It is free — no choice required, the
Ferret's find is always taken. The item is drawn from a consumable-weighted
loot table with a rare chance of a weapon or support item. Charges or
durability may already be partially depleted — the Ferret is a scavenger,
not a master thief.

The loot table scales with encounter difficulty — standard, elite, and boss
encounters draw from progressively better tables.

> **`[OPEN]`** Loot table composition, scaling ratios, and partial charge
> depletion ranges to be defined during encounter design. Monitor reward
> level relative to solo vessel power carefully during playtesting.

**Companion omen card:**
The Ferret contributes one card to the fate omen deck. When this card appears
in a cycle it triggers a special effect beneficial to the Drifter. The card
is inert if it lands on the enemy side.

> **`[OPEN]`** Ferret omen card effect to be defined once the full omen card
> list is designed.

---

## 6. Unlock Conditions

**Unlocked by:** Completing a 1-floor run with The Pilgrim.

**Vessels unlocked by The Drifter:**

> **`[OPEN]`** The two companion-path tier 3 vessels unlocked by the Drifter
> are The Shaman and The Ranger, unlocked by completing a 2-floor run with
> The Drifter. Specific conditions beyond floor completion to be confirmed
> once those vessel designs are complete.

---

## 7. Design Notes

**The no-weapon start:** The Drifter is the only MVP vessel who begins with
no attack item. Every first combat is fought with Throw Rock until the ferret
or a post-combat drop provides something better. This is uncomfortable by
design — the player feels the Drifter's poverty immediately. The Lucky Paw's
evasion and the Pocket of Sand's escape route are the compensating tools.
A player who understands the kit uses the Pocket of Sand to skip a dangerous
first fight and lets the ferret find a weapon from an easier one.

**Relationship to The Pilgrim:** The Pilgrim travels alone and has for a very
long time. The Drifter still has the Ferret — the last relationship she held
onto. The gap between them is that one bond. The Pilgrim is what the Drifter
becomes when even that is gone.

**Relationship to The Shaman and The Ranger:** The Drifter is what remains
when the community is gone and only the individual persists. The Shaman lost
a tribe. The Ranger lost an order. The Drifter is the endpoint of both —
still moving, still resourceful, but carrying nothing that requires another
person to mean anything. The Lucky Paw is a remnant of whichever world she
came from, its power almost spent.

**Mechanical contrast with The Hedge Knight:** The Knight survives by staying
in the fight and getting stronger as he takes damage. The Drifter survives by
not being where the damage lands — evasion, escape, resilience. Two very
different answers to the same problem.

**Graduation:** The Drifter is designed to be outgrown on her branch. Hardy
is situational. The Lucky Paw expires after two combats. The Ferret is
powerful but passive. The Shaman and Ranger will bring more active and
demanding kits. A player returning to the Drifter after those vessels will
feel the simplicity — not as weakness, but as a different kind of survival.

---

*Vessel: The Drifter v0.1*
*Companion to soul_protocol_game_design.md*
*v0.1: Initial design — identity, combat profile, Hardy ability, The Ferret
bound companion with Scavenge passive, three starting items (Pocket of Sand,
Loaf of Bread, Lucky Paw), companion path vessel, unlocked by Pilgrim
1-floor completion.*
*Next: Define floor 2 and floor 3 abilities post-MVP1. Define Ferret omen
card once full omen card list is designed. Define unlock conditions for
The Shaman and The Ranger once those vessel designs are complete.*
