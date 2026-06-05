# Soul Protocol — Non-Combat Encounter Design v0.5

*Companion to soul_protocol_floor_encounter_design.md and soul_protocol_game_design.md*

*v0.1: Initial draft — five encounter types including Rest, Anomaly, Echo Chamber, Crossroads.*
*v0.2: Rest removed. Anomaly and Echo Chamber consolidated into Memory Fragment. Crossroads
replaced by Elite Gate two-door structure. Encounter pool simplified to Memory Fragment
and Wandering Soul.*
*v0.3: Enemy family hint on combat doors reversed — full enemy identity confirmed, superseding
earlier v0.3 draft language. Encounter caps split across elite gate. Wandering Soul
post-elite guarantee added. Memory Fragment scenario content flagged as next content task.*
*v0.5: Category A and C unified into a shared two-option mechanical structure.
A is a fair trade with a walk-away option. C is an unfair trade with no walk-away —
both options cost something. Cost/reward types (HP, item, consumable) can appear in
any combination on either option. Tier system enforces fairness in A and calibrates
unfairness in C. Open items and decisions updated throughout.*

---

## 1. Design Principles

Non-combat encounters are where the run has texture beyond fighting. They are never
neutral — every room asks something of the player, offers something to the player,
or both.

The floor has no free recovery. Every benefit has a cost somewhere, even if that
cost is only the opportunity of the door not taken. A player cannot rely on any
specific non-combat room appearing — they can only rely on the guarantee structures
documented below.

The non-combat encounter pool for MVP contains two room types, plus the elite gate
structure which is a forced beat rather than a pool draw:

- **Memory Fragment**
- **Wandering Soul**
- **Elite Gate** — Beat 4, forced structural encounter, not drawn from the general pool

---

## 2. The Door System — Non-Combat Context

Between each room the player faces a two-door choice. One or both doors may show
a non-combat encounter symbol. The player always chooses between two identified
options — they are never forced into a single door except during the Worn Map
companion beat (see soul_protocol_floor_encounter_design.md, Beat 3).

### Combat Door Display

**Combat doors show the full enemy identity.** The specific enemy type is visible
before the player commits. This is not a family hint or a category symbol — it is
the exact enemy.

> **✓ Decision: Combat doors display full enemy identity.**
>
> **Rationale:** Full identity makes repeat-run knowledge genuinely valuable. A
> player on their fourth run knows which enemies are dangerous, which can be
> bypassed given their current loadout, and which pair badly with their active
> omens. The difficulty comes from learning what enemies do, not from being
> surprised by the same enemies repeatedly. The Soul Codex provides in-run
> reference once an enemy has been encountered.

### Non-Combat Door Display

Non-combat doors display their room type symbol. The specific content within —
which fragment outcome, which trade offers — is not revealed until the player
enters.

---

## 3. Memory Fragment

**Door symbol:** A distinct, consistent glyph. Always the same symbol regardless
of which outcome category awaits inside. The player learns to recognise the symbol
as a Memory Fragment door — not what kind of fragment it will be.

**Player knowledge:** The room is a fragment. That is all the door communicates.
Over multiple runs the player builds an experiential model — fragments are usually
useful, occasionally costly, never catastrophic. The symbol carries earned
familiarity without mechanical disclosure.

**What happens:** A piece of the soul's history surfaces uninvited. It may belong
to this vessel's life. It may belong to a past life — a ranger, a shaman, a holy
warrior — someone who came before and has not yet been unlocked as a playable
vessel. The fragments do not explain these lives. They make them feel real and
present before the player has earned the right to inhabit them.

---

### 3.1 Outcome Categories

The outcome category is drawn randomly on entry. The player does not know which
category they are entering.

Categories A and C share the same mechanical structure — a choice between two
options — but differ in fairness and whether walking away is possible. This
keeps the systems simple while producing meaningfully different experiences.

---

#### Category A — Fair Trade (Optional)

The memory surfaces something of value. The player is offered a trade at fair
market value — cost and reward are at rough tier parity. Both options are fully
revealed before the player commits.

**Option 1 — Take the deal:** Pay the cost, receive the reward. The trade is
fair by the item tier system's standards.

**Option 2 — Walk away:** Decline entirely. No cost, no reward.

The tension is in whether the offered item fits the player's current build, not
in whether the trade itself is exploitative. A player whose build has no use for
the item will walk. A player who needs it will pay.

**Cost/reward types — any combination of:**
- HP (at fair value for what is received)
- A main item (same or adjacent tier to what is offered)
- A consumable (same or adjacent tier to what is offered)

All costs and rewards are fixed per scenario. The same scenario always offers
the same trade — only the player's current state determines whether it is
attractive.

---

#### Category B — Companion Gateway

The memory is of a person. Staying with it draws them forward into the present.

A temporary companion offer emerges from the fragment. The companion is presented
through flavour text only — no passive effect or omen card is disclosed before
acceptance. The player decides on instinct and accumulated run knowledge.

If the player already has a temporary companion, they must choose between keeping
their current companion or accepting the one emerging from the fragment. The
unchosen companion departs. Both are presented through flavour text — the player
is choosing between two unknowns unless they have traveled with one before.

This is also where locked vessels are hinted. A fragment might surface the memory
of a life the player has not yet unlocked — a stranger whose tools were different,
whose world had different rules, whose way through danger was unlike the current
vessel's. The fragment does not name or explain them. It makes them feel as though
they existed.

---

#### Category C — Unfair Trade (Mandatory)

Not all memories are recoverable cleanly. This one demands something regardless
of whether the player wants what it offers. Walking away is not an option —
the fragment has already taken hold. The player must choose between two options,
both of which cost something.

**Option 1 — Take the bad deal:** Receive something, but pay more than it is
worth by the tier system's standards. The reward is real but the price is
deliberately above fair value.

**Option 2 — Cut your losses:** Lose something outright, receive nothing.

The choice should never be obvious. Option 2 exists to be genuinely tempting —
if the bad deal's cost is higher than what option 2 takes, cutting losses is
the correct play. A player who understands their build and the tier system will
sometimes deliberately choose to lose the smaller thing rather than be extorted
into the worse trade.

**Cost/reward types — any combination on either option:**
- HP
- A main item
- A consumable

Both options can cost the same type or different types. There are no artificial
constraints on pairing — a scenario might pit HP loss against a consumable loss,
or a consumable downgrade against an item loss. The requirement is only that
Option 1 is genuinely unfair and Option 2 is a genuine loss.

**Examples of valid C structures:**
- Option 1: Pay 8 HP for a consumable worth 5 HP / Option 2: Lose 4 HP for nothing
- Option 1: Give up a Tier 2 consumable to receive a Tier 1 consumable / Option 2: Lose a Tier 1 consumable outright
- Option 1: Pay a Tier 2 item for a Tier 1 item / Option 2: Lose a specific consumable outright
- Option 1: Pay HP well above fair value for a Tier 1 item / Option 2: Lose a consumable for nothing

All costs and rewards are fixed per scenario — the same fragment always presents
the same two options. What changes is which option is correct given the player's
current state.

---

### 3.2 Memory Fragment Decisions

> **✓ Decision: Memory Fragment has three outcome categories — fair trade
> (optional), companion gateway, unfair trade (mandatory). Category is drawn
> randomly on entry. No outcome is run-ending.**

> **✓ Decision: Categories A and C share the same two-option structure. The
> distinction is fairness and whether walking away is permitted. A is optional
> — the player can always decline. C is mandatory — both options cost something.**

> **✓ Decision: All cost and reward types — HP, main item, consumable — can
> appear on either option of either category, in any combination. No artificial
> pairing constraints. Fairness is enforced by the item tier system, not by
> restricting which types can be combined.**

> **✓ Decision: The Memory Fragment door symbol is consistent and recognisable.
> It communicates room type only, not outcome. Player knowledge of what fragments
> contain is built through play, not disclosed at the door.**

> **✓ Decision: Memory Fragment pool weighting — 40% fair trade / 40% companion
> gateway / 20% unfair trade. Unfair trade weighting kept low enough that it
> reads as genuine bad luck, not a regular floor tax.**

> **`[OPEN]`** Companion gateway weighting to be tuned against total companion
> encounter frequency on the floor. If the Worn Map guarantees a companion on
> room 4, the fragment pool may need to reduce companion gateway frequency to
> avoid over-saturating the floor with companion offers.

> **`[OPEN]`** Scenario pool content — 8–10 distinct mechanical scenarios per
> floor, distributed across Categories A and C (4 A / 2 C recommended as a
> first pass, with remaining slots filled by companion gateway). Narrative
> content deferred to floor-specific writing sessions. Scenarios should flag
> which locked vessels they hint at, to be populated when narrative is added.

---

## 4. Wandering Soul

**Door symbol:** Visible, named. Distinct from the Memory Fragment glyph.

**What happens:** A lost soul who remembers what it had. It will trade with
someone still moving. The Wandering Soul is not a shop — there is no currency,
no browsing, no passive inventory. It is an exchange between two souls with
different needs.

---

### 4.1 Trade Structure

The Wandering Soul presents **two or three trade offers simultaneously.** All
offers are fully revealed — both sides of every trade — before the player commits
to anything. The player may accept any, all, or none.

**Available trade types:**

| Offer | Give | Receive |
|---|---|---|
| Item-for-item | A current inventory item | A different item (revealed) |
| Item-for-HP | A current inventory item | HP restoration (amount shown) |
| Consumable(s)-for-item | One or more consumables | A main item (revealed) |
| HP-for-item | A small HP cost | An item (revealed) |

**The HP-for-item trade is always present as one of the offers.** A depleted
player should always have the option to spend health for something useful.

**The item-for-HP trade is the primary healing path in non-combat rooms.** A
player who has taken significant damage may sacrifice an inventory item to
recover. The HP restoration is meaningful — not a token top-up. The cost is
real: the item is gone and the build is weaker for it. A player in good health
will rarely find this attractive. A player who has been badly hurt will weigh
it against the remaining floor.

No currency exists outside these direct trades. There is nothing to accumulate
between Wandering Soul encounters.

---

### 4.2 Item Trade Fairness

Item-for-item trades require a background value understanding to feel honest.
The implementation maintains a tier ranking for items — trades pair items of
the same or adjacent tier. A strong item is offered for a strong item; a weak
item for a weak item.

The player should never look at a Wandering Soul trade and feel they are being
robbed. They may decline because an offer doesn't suit their build. They should
not decline because it is obviously exploitative.

---

### 4.3 Wandering Soul Decisions

> **✓ Decision: Wandering Soul presents 2–3 fully revealed simultaneous trade
> offers. HP-for-item always present as one offer. Item-for-HP is the primary
> non-combat healing path.**

> **✓ Decision: No currency. All trades are direct exchanges — item, consumable,
> or HP on each side.**

> **✓ Decision: Temporary companions are sourced exclusively from Memory
> Fragments and the Worn Map starting item. The Wandering Soul is always a
> trade encounter — it never offers a companion.

> **`[OPEN]`** HP values for all HP-based trades to be set once vessel HP pools
> are established.

> **`[OPEN]`** Item tier ranking system — a background value classification
> (recommended: three tiers) used to constrain trade pairing at same-tier or
> adjacent-tier only. Implementation detail for the technical side; the design
> assumption is that trades are never wildly asymmetric by accident.

---

## 5. Encounter Caps and Floor Distribution

The encounter pattern system (documented in soul_protocol_floor_encounter_design.md
section 4) tracks encounter type counters to constrain room generation. Non-combat
caps are split across the elite gate to shape floor pacing deliberately.

### 5.1 Cap Structure

| Encounter type | Pre-elite cap | Post-elite cap | Floor total |
|---|---|---|---|
| Memory Fragment | 1–2 | 1–2 | Max 3 |
| Wandering Soul | 0–1 | Exactly 1 | 1–2 |
| Temporary companion | 1 across all sources | — | Max 1 |

Once an encounter type reaches its cap for the relevant segment, it is removed
from the generation pool for that segment. The player will not be offered that
room type again until the cap resets (which it does not — caps are per-floor,
per-segment).

### 5.2 Wandering Soul Post-Elite Guarantee

If the post-elite Wandering Soul cap has not been met naturally by the encounter
slot immediately before the Judge, a Wandering Soul is guaranteed as one of the
two door options at that slot.

The guarantee is not communicated to the player. It is a discoverable pattern —
an attentive player across multiple runs will eventually notice that a trade
opportunity always exists somewhere in the back half of the floor. This knowledge
is earned through play, not disclosed in any UI element or tutorial.

The guaranteed Wandering Soul always appears as one of two door options — it
does not collapse the choice to a single door. The player still chooses between
the Wandering Soul and a combat encounter at that slot.

> **✓ Decision: Encounter caps are split pre/post elite gate. Wandering Soul
> is guaranteed as a door option before the Judge if the post-elite cap has
> not been met naturally. The guarantee is undisclosed — a learnable pattern.**

---

## 6. The Elite Gate

The Elite Gate is Beat 4 in the floor's forced encounter sequence (rooms 5–6
range). It is not drawn from the general non-combat pool — it is a guaranteed
structural beat on every run.

The player faces a two-door choice between two fight types. Both doors display
their full enemy identity. This is not a mystery — the player knows exactly what
each door contains before committing.

### 6.1 Option A — Elite Combat

A harder fight. The elite enemy is identified on the door.

**Rewards on completion:**
- One guaranteed elite-tier item (distinct from the standard post-combat main
  item — higher tier or drawn from a pool unique to elite encounters)
- One standard consumable drop
- A fixed HP restoration after the fight — partial, predictable, significant
  enough to matter

The post-fight HP restoration is not framed as healing magic or a rest. It is
the soul steadying itself after something difficult. The fixed amount is
consistent across every elite encounter — experienced players can factor it
into their door decision.

**Design intent:** The elite fight is the highest-reward combat encounter on
the floor. Taking it should feel correct for a player in reasonable health
with a functional build. The post-fight recovery makes it viable even for
players who have taken prior damage — it is not a death sentence. A player
who handles the elite competently exits with better items and approximately
the HP they started with.

> **`[OPEN]`** Fixed HP restoration amount — to be tuned once vessel HP pools
> and typical elite combat damage values are established. Target feel: restores
> roughly what a competent run of the fight costs, leaving the player near
> their pre-fight HP.

### 6.2 Option B — Standard Combat

A regular floor enemy. Full identity shown on the door.

**Rewards on completion:**
- One standard post-combat main item
- One standard consumable drop
- No post-fight healing

**Design intent:** The standard door is the lower-risk, lower-reward option.
It is never a punishment for caution — a player who takes it exits with
meaningful rewards and conserved HP. It is simply the lower ceiling. A player
whose build struggles against the specific elite enemy, or who is badly depleted
and cannot absorb the elite's damage output, has a real alternative.

Over multiple runs, the player learns whether the specific elite enemy shown
on the door is within their current build's capability. That accumulated
knowledge — knowing which elites are manageable and which demand a strong
build — is what makes the elite gate a genuine decision rather than a default.

### 6.3 Elite Gate Summary

| | Elite door | Standard door |
|---|---|---|
| **Difficulty** | High | Normal |
| **Item reward** | Elite-tier item + consumable | Standard item + consumable |
| **Post-fight healing** | Fixed, significant | None |
| **Risk** | Real — player may exit damaged | Low |

> **✓ Decision: Elite gate offers elite combat (hard fight, elite item,
> post-fight fixed heal) vs standard combat (normal fight, standard item,
> no heal). Both doors show full enemy identity. This is the only structural
> beat that includes a post-fight heal.**

> **`[OPEN]`** Whether the standard door at the elite gate is always a
> different enemy from the elite door. Current lean: yes — the choice should
> present two distinct propositions, not a tier comparison of the same enemy.

---

## 7. Non-Combat Pool Summary

| Encounter type | In general pool | Frequency target | Notes |
|---|---|---|---|
| Memory Fragment | Yes | 2–3 per floor | Core non-combat event; narrative engine |
| Wandering Soul | Yes | 1–2 per floor | Trade economy; primary healing path |
| Elite Gate | No — forced beat | Exactly 1 per floor | Beat 4, rooms 5–6 range |
| Rest / Mending | **Removed** | — | No free healing at MVP |
| Anomaly | **Removed** | — | Consolidated into Memory Fragment |
| Echo Chamber | **Deferred** | — | Post-MVP; Codex dependency |

> **`[OPEN]`** Pool weight ratio between Memory Fragment and Wandering Soul
> within the non-combat event pool — first pass: 60/40 in favour of Memory
> Fragment, reflecting that fragments are the primary narrative and discovery
> engine while Wandering Soul is the economy and healing engine.

---

## 8. Open Items Summary

| # | Item | Priority |
|---|---|---|
| 1 | Memory Fragment scenario writing — 8–10 scenarios for Floor 3 | High — next content task |
| 2 | Companion gateway frequency vs Worn Map companion overlap | Medium |
| 3 | Wandering Soul HP values — pending vessel HP pool design | Blocked |
| 4 | Item tier ranking system — implementation detail for technical side | Medium |
| 5 | Elite gate post-fight heal amount — pending damage tuning | Blocked |
| 6 | Elite gate standard door — confirm always distinct enemy from elite | Low |
| 7 | Floor 3 temporary companion pool — identities, passives, omen cards | High — companion design session |

---

*Soul Protocol — Non-Combat Encounter Design v0.5*
*Companion to soul_protocol_floor_encounter_design.md, soul_protocol_game_design.md,
soul_protocol_items.md*
