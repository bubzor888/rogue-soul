# Soul Protocol — Omens
## Version 0.2 · May 2026 · Solo Developer

> **Purpose:** Defines the omen system — the card-based mechanic that governs
> battlefield conditions, status effects, and duration tracking across all
> combat in Soul Protocol.
>
> Individual omen status effect values (Burning, Chilled, etc.) are defined in
> `soul_protocol_items.md`. This document covers omen deck composition, cycle
> mechanics, card sources, and confirmed omen cards.
>
> Confirmed decisions are marked **`✓`**.
> Open questions are marked **`[OPEN]`**.

---

## Table of Contents

1. [Overview](#1-overview)
2. [Omen Cycle Mechanics](#2-omen-cycle-mechanics)
3. [Card Anatomy](#3-card-anatomy)
4. [Overall Omens vs Individual Omens](#4-overall-omens-vs-individual-omens)
5. [Sources of Omen Cards](#5-sources-of-omen-cards)
6. [Confirmed Omen Cards](#6-confirmed-omen-cards)
7. [Floor 3 Omen Pool](#7-floor-3-omen-pool)
8. [Enemy-Contributed Omens](#8-enemy-contributed-omens)

---

## 1. Overview

The omen system is the central mechanic governing battlefield conditions in
Soul Protocol. Every combat turn is shaped by three omen cards drawn from a
shared deck — one chosen by the player, one applied randomly, one setting the
duration of the current cycle.

Omens are not purely bad or purely good. They create shifting conditions that
both sides must navigate. A fire omen on the enemy side benefits the player;
the same card forced onto the player side by an unlucky draw becomes a threat
to manage. The system creates a rhythm of preparation, opportunity, and
response that sits underneath all item and ability decisions.

The omen deck is not fixed. Its composition changes based on the vessel
playing, the items they carry, the floor they are on, and the enemies present
in each combat.

---

## 2. Omen Cycle Mechanics

> **✓ Confirmed: The following describes the omen cycle as designed.**

Each combat turn, three omen cards are drawn from the deck. They are resolved
as follows:

1. **Player chooses one card** from the three drawn. They decide which side
   to apply it to — their own side or the enemy side.

2. **One card is randomly selected** from the remaining two and applied to
   the other side (the side the player did not choose for their card).

3. **The final remaining card** is not played. Its number (1, 2, or 3)
   becomes the **cycle duration** — how many turns until the next omen draw.

All active overall omens and individual omen statuses persist for the cycle
duration. At the end of the cycle, individual omens clear and new cards are
drawn.

**Strategic implication — forced bad draws:** If all three drawn cards are
unfavourable to the player (e.g., three enemy-beneficial omens), the player
must still choose one for their side. The choice becomes: which effect is
least damaging to absorb, and which timer value is most manageable.

**Strategic implication — timer card value:** For per-turn status effects
(Burning, Poisoned, Chilled, Mending, Hardened), a high timer card (3) is
generally desirable — more ticks means more value. For omen-triggered effects
(Shocked), a low timer card (1) is desirable — faster payoff on the stun.
This creates different Read the Road priorities depending on what is active.

> **✓ Decision: The deck reshuffles when depleted rather than exhausting.**
> A fight that runs long will see cards repeat — this is intentional. The
> distribution of card numbers and effects in the deck determines long-fight
> behaviour as much as short-fight behaviour.

**Deck size framework:**

The deck is assembled fresh per combat from its sources. Estimated composition
for a solo enemy fight on Floor 3:

| Source | Estimated cards |
|---|---|
| Floor 3 base pool | ~10 |
| Single enemy contribution | ~4–6 |
| Pilgrim vessel cards | 2 |
| **Total** | **~16–18** |

Multi-enemy fights add more enemy cards, pushing toward 20–24. More enemies
means a more omen-dense, harder-to-predict combat — appropriate for the
increased difficulty.

**Working assumption for balancing:** ~6 cards drawn per fight (2 omen cycles
× 3 cards). In a 20-card deck, any given card has roughly a 30% chance of
appearing in a fight. In a 16-card deck, closer to 37%.

> **`[OPEN]`** Exact deck sizes to be confirmed once floor pool and enemy
> contributions are designed. Target range: 16–24 cards per combat.

---

## 3. Card Anatomy

Each omen card has three components:

| Component | Description |
|---|---|
| **Number** | 1, 2, or 3. Becomes the cycle timer if this card is the leftover. Higher numbers are generally better for per-turn effects; lower numbers are better for omen-triggered effects. |
| **Effect** | What the card does when played on a side. |
| **Side** | Determined at play — the player chooses which side their card applies to; the random card goes to the other. |

> **`[OPEN]`** Whether cards have a fixed number or whether number is
> randomised per draw to be confirmed. Current design assumption: number is
> printed on the card and fixed.

> **`[OPEN]`** Card distribution across numbers (how many 1s, 2s, 3s in the
> deck) to be set during omen deck design. Distribution affects average cycle
> length and status effect value.

---

## 4. Overall Omens vs Individual Omens

**Overall omens** are applied by omen deck cards. They affect the entire side
they are played on — all enemies, or the player. They represent ambient
battlefield conditions.

**Individual omens** are applied by consumables, abilities, or enemies directly
to a specific target — one enemy, or the player. They stack on top of any
overall omens already active on that target.

| | Overall omen | Individual omen |
|---|---|---|
| **Source** | Omen deck card | Consumable, ability, or enemy action |
| **Target** | Whole side | One specific unit |
| **Duration** | Current omen cycle | Until next omen reset |
| **Stacking** | Does not stack same type (×1.5 cap on vulnerability) | Does not stack same type with overall omen |

> **✓ Decision: Two sources of the same vulnerability on one target do not
> stack. The cap is ×1.5 regardless of how many sources apply it.**

Both types clear at the omen reset. Individual omens applied mid-cycle clear
at the *next* reset — they do not persist into the following cycle.

---

## 5. Sources of Omen Cards

The omen deck for each run is assembled from four sources. Cards from all
sources are shuffled together into one deck.

### 5.1 Vessel Cards

Each vessel contributes cards to the omen deck that reflect their nature and
abilities. Vessel cards are present in every combat throughout the run.

**Confirmed vessel cards:**

| Card | Vessel | Count | Effect |
|---|---|---|---|
| Stillness | Pilgrim | 2 | Does nothing |
| Fortified | Hedge Knight | TBD | Via Iron Pendant — see section 6.2 |

**The Pilgrim — Stillness:**

The Pilgrim contributes 2 copies of Stillness to the omen deck. Stillness
is a null omen — it has no effect when played on either side.

> **✓ Decision: The Pilgrim's vessel omen is Stillness — a card that does
> nothing.**
>
> **Rationale:** The Pilgrim arrives at the Threshold having shed everything.
> His contribution to the omen field is absence. Mechanically, Stillness
> dilutes the deck — any specific effect is slightly less likely in a Pilgrim
> run. Strategically, drawing Stillness is safe: the player can apply it to
> themselves with no consequence, or use it as their chosen card to guarantee
> the random card lands on the enemy side without fear of what follows.
> Thematically, it is the most honest card a man carrying almost nothing
> could contribute.

**Stillness interactions:**
- Applied to player side: nothing happens
- Applied to enemy side: nothing happens
- As timer card: sets cycle duration normally (number still matters)
- With Read the Road: a Stillness in the top 3 is perfectly predictable —
  a safe player-choice card if the other two draws are threatening

**Count rationale:** 2 copies in a ~16–20 card deck means Stillness appears
in roughly every other fight on average. Frequent enough to feel like a
characteristic of the Pilgrim, rare enough not to dominate.

> **`[OPEN]`** Stillness count (first pass: 2) to be confirmed once deck
> sizes are established.

### 5.2 Item Cards

Certain items, when carried, add cards to the omen deck. This is distinct
from consumables that apply individual omens directly — item-added cards
enter the shared deck and are drawn through normal omen cycle mechanics.

**Confirmed item-sourced cards:**

| Item | Card added | Vessel |
|---|---|---|
| Iron Pendant | Fortified | Hedge Knight |

> **`[OPEN]`** Whether floor 3 drop items can add cards to the omen deck, or
> whether only starting items carry this property. Current lean: starting items
> only, to keep the drop pool focused on direct-effect items.

### 5.3 Floor Cards

Each floor contributes a pool of omen cards representing the ambient conditions
of that space. Floor cards are present in every combat on that floor regardless
of vessel or items.

Floor 3 — The Threshold is a liminal space of haze and half-formed shapes.
Its omen cards should reflect that atmosphere — unclear edges, shifting
conditions, things that are almost but not quite resolved.

> **`[OPEN]`** Floor 3 omen card pool to be designed. See section 7.

### 5.4 Enemy Cards

Enemies add cards to the omen deck for the duration of the combat they appear
in. When the combat ends the enemy's cards are removed. This means the deck
composition shifts between combats — a fight against a fire-attuned enemy
will have more fire omens than a fight against a physical enemy.

Enemy omen contributions are defined per enemy in the enemy design document.

> **`[OPEN]`** Enemy omen contributions to be defined during enemy design.
> See section 8.

---

## 6. Confirmed Omen Cards

The following cards are confirmed for inclusion in the omen deck. Sources
and pool assignments are noted where confirmed.

---

### 6.1 Elemental Omens

Each confirmed element has a whole-side omen card that mirrors its
single-target consumable counterpart. When played on the enemy side the
effect is offensive; when forced onto the player side it becomes a threat
to manage or cleanse.

The whole-side versions may carry slightly different values than their
single-target consumable counterparts — the area-of-effect nature warrants
tuning independently.

---

#### Burning *(Fire · Per-turn · Whole side)*

Applies the Burning status to all units on the target side. Each unit on
that side takes flat fire damage per tick and is Vulnerable (Fire) ×1.5
for the cycle duration.

Mirrors: Fire Bomb (single-target consumable).

**On enemy side:** all enemies take fire DoT and are vulnerable to fire damage.
Particularly strong with Smoldering Brand or Ember Shard equipped.

**On player side (forced):** player takes fire DoT and is Vulnerable (Fire).
Cleared per-unit by Ointment.

> **`[OPEN]`** Whole-side Burning tick value to be set. May differ from
> single-target value (first pass: 5/tick). Source pool (floor, enemy, or
> vessel) to be confirmed.

---

#### Shocked *(Lightning · Omen-triggered · Whole side)*

Applies the Shocked status to all units on the target side. While active,
all units on that side are Vulnerable (Lightning) ×1.5. At the omen shift,
all units on that side skip their next action.

Mirrors: Fulminating Powder (single-target consumable).

**On enemy side:** all enemies vulnerable to lightning and all stunned at
the shift. Extremely powerful with Arc Wand or Spark Rod equipped — the
arc hit benefits from the vulnerability on both the primary and secondary
target.

**On player side (forced):** player is Vulnerable (Lightning) and will be
stunned at shift. Cleared by Amethyst.

Low timer cards are valuable when Shocked is active — faster stun payoff.
High timer cards extend the vulnerability window but delay the stun.

> **`[OPEN]`** Source pool (floor, enemy, or vessel) to be confirmed.

---

#### Chilled *(Ice · Per-turn · Whole side)*

Applies the Chilled status to all units on the target side. Each unit deals
reduced damage per tick (creeping, never to zero) and is Vulnerable (Ice) ×1.5
for the cycle duration.

Mirrors: Frost Shard (single-target consumable).

**On enemy side:** all enemies deal less damage and are vulnerable to ice.
Particularly effective against multi-enemy encounters — the damage reduction
applies across all attackers.

**On player side (forced):** player deals reduced damage each tick and is
Vulnerable (Ice). Cleared by Amethyst.

> **`[OPEN]`** Whole-side Chilled reduction values to be set. May differ from
> single-target values (first pass: 10%/20%/30% per tick). Source pool to be
> confirmed.

---

### 6.2 Non-Elemental Omens

---

#### Stillness *(Vessel card — Pilgrim)*

Does nothing when played on either side. Its number still functions as a
timer card if it is the leftover draw.

Full design rationale documented in section 5.1.

---

#### Emboldened (Physical) *(Per-turn · Whole side)*

All units on the target side deal increased physical damage for the cycle
duration. Expressed as a **flat bonus** rather than a percentage — physical
damage is the most common damage type, and a percentage multiplier would be
too broad.

**On enemy side:** player's physical weapons deal more damage per hit.
Valuable with any physical weapon equipped — always relevant since physical
is the default damage type.

**On player side (forced):** enemies deal more physical damage per hit.
Straightforward additional pressure.

> **`[OPEN]`** Flat bonus value (e.g. +X per hit) to be set once weapon
> damage values are established.

---

#### Emboldened (Elemental) *(Per-turn · Whole side)*

All units on the target side deal increased damage of a specific elemental
type for the cycle duration. Expressed as a **percentage increase** —
elemental damage is more situational, so a multiplier is appropriate.
Separate cards exist for each confirmed element.

**On enemy side:** player's elemental attacks of that type hit harder. High
value when the matching elemental weapon is equipped.

**On player side (forced):** enemies deal increased elemental damage of
that type. A significant threat if the player is already Vulnerable to
that element.

Confirmed elemental variants: Fire, Lightning, Ice.

> **`[OPEN]`** Emboldened (Elemental) percentage value to be set.
> Emboldened cards per element to be assigned to source pools (floor vs
> enemy) during omen deck design.

---

#### Fortified *(Per-turn · Whole side)*

All units on the target side take reduced incoming damage for the cycle
duration. A defensive omen — the inverse of a vulnerability effect. Added
to the omen deck by the Hedge Knight's Iron Pendant starting item.

**On enemy side:** enemies take less damage. An unfavourable draw that reduces
the Knight's offensive output for the cycle.

**On player side:** player takes less damage. The intended use — Iron Pendant
is designed to push Fortified toward the player side more often.

> **`[OPEN]`** Fortified damage reduction value to be set during Knight vessel
> design. Full Iron Pendant interaction documented in `vessel_knight.md`.

---

## 7. Floor 3 Omen Pool

The ambient omen cards contributed by Floor 3 — The Threshold. These are
present in every combat on this floor regardless of vessel, items, or enemy.

> **`[OPEN]`** Floor 3 omen pool to be designed. Design constraints:
>
> - Should reflect the liminal, half-formed atmosphere of the Threshold
> - Should not be so hostile that every draw is a threat — the floor omen
>   pool sets the baseline difficulty before enemy cards are added
> - Should include a mix of card numbers (1s, 2s, 3s) to give varied cycle
>   lengths
> - Likely includes at least one each of Burning, Chilled, Emboldened
>   (Physical) to introduce the system to all vessels early
> - Target ~10 cards to keep the base deck manageable before enemy cards
>   are added

---

## 8. Enemy-Contributed Omens

Each enemy on Floor 3 contributes cards to the omen deck for the duration
of that combat. Multi-enemy encounters add multiple sets of cards, making
those combats more omen-dense and harder to predict.

Enemy omen contributions serve two purposes:
1. **Thematic identity** — a fire enemy adds Burning cards, making fire omens
   more likely and reinforcing that enemy's danger profile
2. **Combat pressure** — more cards means more potential for unfavourable draws,
   requiring the player to manage the omen pool as well as their item resources

> **`[OPEN]`** Enemy-specific omen contributions to be defined during enemy
> design. Each Floor 3 enemy entry should include:
> - Which omen cards they contribute
> - How many copies (affects draw probability)
> - Card numbers (timer values) they carry

---

*Soul Protocol — Omens v0.2*
*Companion to soul_protocol_game_design.md, soul_protocol_items.md, and
vessel design documents.*
*v0.1: Omen system mechanics documented — cycle structure, card anatomy,
overall vs individual distinction, four source types. Confirmed omen cards
from items: Burning, Shocked, Chilled (elemental whole-side), Weakened,
Emboldened, Fortified. Floor 3 pool and enemy contributions pending.*
*v0.2: Weakened removed — overlaps with Chilled. Emboldened split into
Physical (flat bonus) and Elemental (percentage) variants. Pilgrim vessel
card confirmed: Stillness (null omen, 2 copies) — does nothing, dilutes
the deck. Deck size framework added: ~16–18 cards for solo enemy fight,
~20–24 for multi-enemy. Reshuffle on depletion confirmed. Stillness count
and frequency rationale documented.*
