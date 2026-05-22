# Soul Protocol — Game Design Decisions
## Version 0.1 · May 2026 · Solo Developer

> **Purpose:** This document records gameplay mechanic decisions for Soul Protocol.
> It is a companion to `soul_protocol_v0_4.md` (design decisions) and
> `soul_protocol_tech_arch_v0_5.md` (technical architecture).
>
> Confirmed decisions are marked **`✓`**.
> Open questions are marked **`[OPEN]`**.
> Items pending discussion are marked **`[PENDING]`**.

---

## Table of Contents

1. [Action Economy](#1-action-economy)
2. [Enemy Intent](#2-enemy-intent)
3. [Inventory & Items](#3-inventory--items)
4. [Companion System](#4-companion-system)
5. [Vessels](#5-vessels)

---

## 1. Action Economy

### 1.1 Turn Structure

Each player turn consists of three independent action buckets. Each bucket may be used
once per turn. Support and Consumable buckets are optional — the player is never
required to use them. The Attack bucket must always be resolved (even if the only
choice is the Default Strike).

| Bucket | Source | Cost | Limit | Optional |
|---|---|---|---|---|
| **Attack** | Attack ability, attack item, or Default Strike | — | 1 per turn | No — must always act |
| **Support** | Non-attack ability (charged) | Free | 1 per turn | Yes |
| **Consumable** | Single-use non-attack item | Free | 1 per turn | Yes |

A fully-resourced turn uses all three buckets: trigger a support ability, use a
consumable, and make an attack. This rewards good resource management without
requiring it.

---

### 1.2 The Attack Bucket

The Attack bucket is filled by exactly one of the following, in order of player
preference:

- **Attack ability** — a vessel's charged offensive skill (consumes 1 charge)
- **Attack item** — a weapon or thrown offensive item (consumes 1 durability or
  destroys a single-use item)
- **Default Strike** — always available, no charges, no durability cost; weaker
  than any real attack option but guarantees the player is never completely toothless

> **✓ Decision: One attack action per turn — ability, item, or Default Strike**
>
> **Rationale:** A single attack per turn keeps combat readable and prevents
> snowballing. The Default Strike ensures the player always has a meaningful choice
> even when fully depleted. Attack items and attack abilities occupy the same
> decision space — the player chooses the best tool available, not the best tool
> from each category.

---

### 1.3 The Support Bucket

Non-attack abilities — buffs, defensive moves, positioning effects, companion
interactions — are free and do not consume the Attack bucket. One per turn.
These abilities are typically gated behind charges and will exhaust over the
course of a run.

> **✓ Decision: One free non-attack ability per turn — does not consume the attack action**
>
> **Rationale:** Separating support abilities from the attack action creates
> interesting turns: the player can defend AND attack, or buff AND attack, without
> sacrificing their offensive output. The charge gate keeps this from being
> infinitely spammable.

---

### 1.4 The Consumable Bucket

Single-use non-attack items — healing potions, buff elixirs, debuff flasks, ward
tokens — are free and do not consume the Attack bucket. One per turn. These items
are already scarce by acquisition; the free cost reflects that scarcity is the
natural limiting factor, not an additional AP tax.

> **✓ Decision: One free single-use non-attack item per turn — does not consume the attack action**
>
> **Rationale:** Charging AP for consumables discourages use and leads to
> hoard-and-never-use behaviour — a common roguelite failure mode. Making them
> free-but-limited-to-one-per-turn encourages the player to actually use what
> they find. Scarcity (you only have what you've acquired) is the real cost.

---

### 1.5 Companion Actions

Companions are not controlled directly by the player. At the end of the player's
turn, each active companion takes one automatic action from their available ability
set. The player spends no AP on companion actions.

> **✓ Decision: Companions act automatically — no player AP cost**
>
> **Rationale:** Keeping companion actions automatic preserves the simplicity of
> the AP system while adding combat texture. The player manages companions
> indirectly — through positioning decisions, protection choices, and revival
> investment — rather than directly spending resources on them. This scales
> gracefully: more companions means more end-of-turn activity without
> complicating the player's per-turn decision.

---

### 1.6 Default Strike

The Default Strike is a permanent, uncharged, baseline attack always available in
the Attack bucket. It deals reduced damage compared to any real attack option and
has no secondary effects. It exists to ensure the player is never locked out of
acting offensively.

> **✓ Decision: Default Strike is always available — no charges, no durability, weaker than all alternatives**
>
> **Rationale:** A player who has exhausted all attack abilities and attack items
> should feel resource pressure, not helplessness. The Default Strike keeps the
> run alive while making the depletion feel meaningful — the player knows they
> are fighting on fumes.

---

*Section last updated: v0.1*

---

## 2. Enemy Intent

### 2.1 Omens — The Core Concept

Enemy intent is communicated through **omens** — visual manifestations that appear
on the player's own units (the vessel and active companions), not on the enemies
themselves. Each omen shows *what is about to happen* to that unit, but not *which
enemy is causing it*.

This is a deliberate inversion of the Slay the Spire model. Rather than reading
enemies and planning around them, the player reads *themselves* — fate reaching
toward them from the darkness. The strategic question shifts from "what are they
going to do?" to "what is about to happen to me, and what can I do about it?"

> **✓ Decision: Omens appear on player units, not on enemies**
>
> **Rationale:** Fits the purgatory setting — the world acts on the player, not
> the other way around. Creates a distinct strategic identity versus Slay the
> Spire. Scales naturally with enemy count: multiple enemies can contribute to the
> same omen without the player needing to parse each one individually.

---

### 2.2 Omen Legibility

Omens are not immediately self-explanatory to a new player. They are visual
manifestations — glows, symbols, distortions — that must be learned over time.
First encounters with a new enemy type will produce unfamiliar omens; the player
learns their meaning through experience.

Once an enemy has been recorded in the **Soul Codex**, the codex entry includes
a description of that enemy's omens. Veteran players recognise omens on sight;
new players are given the context to look them up. This gives the Soul Codex
genuine in-run utility beyond narrative reward.

> **✓ Decision: Omens are learned through play, with the Soul Codex as the reference**
>
> **Rationale:** Mystery on first encounter is appropriate for purgatory — the
> player is exploring an unknown place. Persistent mystery after multiple
> encounters would be frustrating. The Codex converts earned experience into
> reliable knowledge, making progression feel meaningful rather than just
> numerical.

---

### 2.3 Omens as a Reactive Forecast

Omens are not a static declaration of what will happen at the end of the turn.
They are a **live forecast** that recalculates as the player takes actions within
their turn. Every action the player takes updates the omens immediately:

- **Kill an enemy** → their contribution to any omen vanishes. An omen may
  downgrade or disappear entirely.
- **Stun, sleep, or disable an enemy** → their omens are suppressed for this
  turn, visually shown as dimmed or broken.
- **Apply a debuff** → the omen may change shape or intensity, reflecting the
  weakened threat.
- **Reposition a companion** → a companion-targeted omen may shift to the vessel
  if the companion moves out of reach.

This makes **action sequencing matter within a turn.** The player can use their
Support ability first — stunning an enemy, watching the omens update — before
deciding how to spend their Attack. Or they can attack first and assess what
remains. The omens make the consequence of each ordering visible.

> **✓ Decision: Omens update immediately as the player takes actions mid-turn**
>
> **Rationale:** Transforms omens from a passive forecast into a reactive feedback
> loop. Every action is in conversation with the forecast, rewarding players who
> read the board carefully and sequence their turns deliberately.

---

### 2.4 Omen Update Feedback

When an omen updates mid-turn — reduces, shifts, or disappears — the change is
**immediate and visual**, paired with a **distinct audio cue** that signals the
player's situation has improved. The sound does the emotional work without adding
visual complexity: the omen changing *is* the visual event; the sound punctuates
and confirms it.

No animation or interruption accompanies the update — it is instantaneous.
The audio cue is specifically associated with improvement, making it an
unambiguous positive signal the player will quickly learn to listen for.

> **✓ Decision: Omen updates are immediate and silent visually, confirmed by a
> positive audio cue**
>
> **Rationale:** Keeps the screen clean while preserving the emotional payoff of
> improving your situation. Respects the mobile audio constraint (audio is
> supplementary, never the sole carrier of meaning) — the visual omen change is
> the primary signal, the sound is the reward layer on top.

---

*Section last updated: v0.1*

---

## 3. Inventory & Items

### 3.1 Inventory Size

There is no hard cap on inventory size at MVP. The natural limiting factors are
acquisition rate and charge count — the player accumulates what the run gives them,
no more. A cap may be introduced post-MVP once playtest data shows whether
inventory size becomes a UI or balance problem.

> **✓ Decision: No inventory cap at MVP — acquisition rate and charges are the
> limiting factors**
>
> **Rationale:** Capping inventory before knowing the acquisition rate is designing
> blind. A key part of the gameplay loop is holding items in reserve for key
> moments — an artificial cap undermines this before it has been tested. The limit
> is easy to add later; removing one that turned out to be wrong is harder to
> recover from feel-wise.

---

### 3.2 Post-Combat Item Acquisition

Every combat encounter — standard and elite — rewards the player with items.
The post-combat screen presents **two acquisition slots**:

| Slot | Contents | Revealed? |
|---|---|---|
| **Main slot** | One item from the general item pool (attack, support, or mixed) | Yes — fully revealed |
| **Consumable slot** | One single-use consumable item | Yes — fully revealed |

The player takes both. There is no pick-one choice at the post-combat screen —
both slots are awarded, both are fully visible. The decision is made before
combat, not after: the player chose to enter this fight knowing items would follow.

> **✓ Decision: Post-combat awards one main item and one consumable — both
> revealed, both taken**
>
> **Rationale:** Separating the pools makes acquisition rate tuning independent —
> consumable abundance and main item abundance can be adjusted without affecting
> each other. Full revelation keeps post-combat fast and legible; mystery and
> risk belong to non-combat events, not to the reward screen after a fight the
> player just won. The guaranteed consumable also acts as a natural self-correction
> mechanism: a player running low on consumables will replenish steadily through
> normal combat progression.

---

### 3.3 Mystery Items — Non-Combat Events Only

Unknown or partially-revealed items are reserved exclusively for non-combat
events — Anomaly rooms, certain Memory Fragment outcomes, and Wandering Soul
encounters. In these contexts, the player may encounter items where the type is
visible but the specific identity is not revealed until taken, or where neither
is known in advance.

> **✓ Decision: Mystery item presentation is exclusive to non-combat events**
>
> **Rationale:** Gives each room type a distinct personality. Combat drops are
> transparent and reward decisive play. Non-combat events carry risk and
> discovery. The Anomaly room in particular earns its identity as the place where
> unknown things happen — the mystery framing would be diluted if it also appeared
> on the post-combat screen.

---

### 3.4 Soul-Carried Items — The Remnant Tag

One item in the player's inventory can be tagged as the **Remnant** — the single
thing the soul holds onto across death. All items live in the same inventory; the
Remnant tag is simply a marker on one of them.

**Behaviour:**

- On death, all untagged items are lost. The tagged item carries forward into the
  next run with whatever charges it had remaining.
- At the start of a new run, the tagged item sits in regular inventory alongside
  anything newly acquired. It is not in a separate slot — it is just an item with
  a visible tag.
- The player can re-tag any item at any time by selecting it as the new Remnant.
  The previously tagged item loses its tag and becomes a normal inventory item —
  nothing is lost or discarded in the process.
- At MVP the player has one Remnant tag. Additional tags are a natural
  meta-progression unlock — the soul learning to hold onto more of what it
  remembers.

> **✓ Decision: The Remnant is a tag on one inventory item, not a separate slot
> or layer**
>
> **Rationale:** The simplest model that achieves the goal. All items live in one
> place; the tag is purely a survival marker. No separate UI container, no
> separate acquisition path, no rules about what can or cannot be tagged. The
> meaningful decision is which item is worth carrying through death — not a
> mechanical restriction but a genuine strategic and emotional choice. Easy to
> expand via meta-progression by simply increasing the number of available tags.

---

### 3.5 Item Flag — Floor-Bound

Items can be flagged as **floor-bound** — they expire at the end of the current
floor. If still in inventory when the floor transition occurs, they are removed.
They are not carried to the next floor and cannot be tagged as the Remnant.

Floor-bound items are identifiable in the inventory so the player always knows
which items they are racing against the floor transition to use.

> **✓ Decision: Items carry a floor-bound flag — floor-bound items are removed
> at floor transition if unused**
>
> **Rationale:** Some items are meaningful precisely because they cannot be
> hoarded across floors. The Loaf of Bread is the primary example — food from
> a previous life does not survive the crossing. The flag keeps this behaviour
> explicit and consistent rather than handled as a special case per item.
> Displaying the flag in inventory ensures the player is never surprised by
> the loss.

---

### 3.6 Item Flag — Encounter Counter (Non-Combat Items)

Items can be flagged as **encounter-countdown** items. These items are not used
in combat — they do not appear in the combat action interface — but they exist
in inventory and are visible between encounters. They carry a counter that
decrements by 1 after every encounter, regardless of encounter type. When the
counter reaches zero, the item triggers a specific encounter, replacing the next
regular encounter slot on the floor, and is then removed from inventory.

**Key rules:**

- The counter decrements after every encounter type — combat, rest, memory
  fragment, anomaly, and wandering soul all count. Only the boss encounter
  slot is never replaced.
- The triggered encounter replaces a regular encounter slot — it does not add
  an extra encounter. The total number of encounters on the floor stays fixed.
- Encounter-countdown items can only be acquired — through drops or events —
  when enough non-boss encounters remain on the floor for the counter to reach
  zero naturally. This is enforced at the acquisition layer, never at the
  trigger layer.
- The counter is visible on the item in inventory so the player can track
  when their triggered encounter will arrive.

> **✓ Decision: Encounter-countdown items decrement on every encounter type,
> replace a regular encounter slot on zero, and can only be acquired when
> sufficient encounters remain**
>
> **Rationale:** Counting every encounter type rather than only combat
> encounters keeps behaviour predictable regardless of which doors the player
> chooses. Replacing rather than adding an encounter keeps floor length fixed —
> pacing and balance are not affected by carrying these items. Enforcing
> availability at acquisition rather than handling a boss-collision edge case
> at trigger keeps the system clean. The Worn Map is the primary example of
> this item type — its meeting place encounter is guaranteed to resolve before
> the floor boss as long as it is in the starting kit.

---

*Section last updated: v0.7*

---

## 4. Companion System

### 4.1 Party Composition

A party consists of the vessel plus up to two companions — one **bound** and one
**temporary**. These are hard limits at MVP.

| Vessel Type | Bound Companion | Temporary Companion | Max Party Size |
|---|---|---|---|
| With bound companion | Yes | 1 (optional) | 3 |
| Solo vessel | None | 1 (optional) | 2 |

> **✓ Decision: Maximum one bound companion and one temporary companion active
> simultaneously**
>
> **Rationale:** Keeps party management readable. A party of three is the ceiling
> — enough to create meaningful tactical decisions without overwhelming the
> turn structure or the combat screen layout.

---

### 4.2 Temporary Companions

Temporary companions are distinct from bound companions in origin, attachment, and
permanence. They are encountered exclusively through **non-combat events** —
Wandering Soul rooms, Echo Chambers, Memory Fragments, and Anomalies. They are
never summoned through items or abilities.

They travel with the player until they die in combat or are replaced by a new
companion encounter. There is no revival path for a temporary companion — their
loss is expected and clean, carrying none of the emotional weight of a bound
companion's death.

> **✓ Decision: Temporary companions replace "summoned" companions entirely —
> sourced from non-combat events only, never from items or abilities**
>
> **Rationale:** Removing summoning from the item system simplifies item design
> and balance significantly. Sourcing temporary companions from non-combat events
> gives those rooms meaningful weight — a Wandering Soul encounter isn't just a
> potential item upgrade, it could reshape the party entirely. The loss of a
> temporary companion is resource management, not grief.

---

### 4.3 Replacing a Temporary Companion

When the player encounters a potential temporary companion in a non-combat event
and already has one active, they must choose which to move forward with. Keeping
the current companion means the new one is passed over entirely — the player
cannot hold both.

This is a forced trade, not an addition. The player is always choosing between
a known quantity (their current companion) and an unknown one (the new encounter).

> **✓ Decision: Encountering a new temporary companion when one is already active
> forces a choice — keep current or take the new one**
>
> **Rationale:** Creates genuine loss moments even when something good is
> happening. Finding a compelling companion means letting the current one go.
> This is emotionally richer than a simple swap and makes the decision feel
> consequential rather than purely tactical.

---

### 4.4 Companion Identity — Known Through Experience

Potential companions are presented through **flavour text only** — a description
of who or what they are, written in the voice of purgatory. No mechanical
information is given at the point of encounter. The player makes their choice
based on narrative instinct and accumulated experience, not a stat sheet.

Companions are not numerous enough that this becomes an unreasonable burden —
a player who has traveled with a companion before will recognise them and know
what to expect. A first encounter is a genuine unknown.

> **✓ Decision: Companion mechanics are not disclosed at the point of encounter —
> flavour text only**
>
> **Rationale:** Consistent with the omen system philosophy — meaningful things
> are learned through play, not front-loaded as tooltips. The number of companion
> types is small enough that experienced players carry this knowledge naturally.
> New players make decisions based on feel, which is appropriate for a first run.

---

### 4.5 Soul Codex — Companion Entries

A Soul Codex entry for a companion is unlocked the moment the player **chooses
to travel with them**. If the player encounters a companion but passes them over
in favour of keeping their current one, that companion's entry remains blank —
they stay a mystery until a future run where the player chooses differently.

> **✓ Decision: Companion Codex entries unlock on acceptance, not on loss or
> completion — passing over a companion leaves them unknown**
>
> **Rationale:** Creates a natural completionist goal — filling every companion
> entry — without the game needing to state it explicitly. Also creates a quiet
> incentive to sometimes take the unknown companion over the familiar one, purely
> out of curiosity. The cost of ignorance is built into the choice itself.

---

### 4.6 Bound Companion Revival

Bound companions do not die permanently within a run — they become **inactive**.
An inactive companion is fully removed from the combat system: they receive no
omens, cannot be targeted by enemies, and take no actions at end of turn. The
only thing that can affect an inactive companion is a revival consumable.

**Revival consumables** are rare single-use items that reactivate the bound
companion mid-combat, restoring them to a functional state. They are used via
the Consumable action bucket — free, one per turn — meaning revival never costs
the player their attack action.

Revival consumables are only available as the consumable drop from elite and
boss encounters, in direct competition with a rare general item drop. The player
must choose one or the other — they cannot take both.

> **✓ Decision: Bound companions become inactive on death — untargetable,
> not truly dead — revived only by a rare consumable item**
>
> **Rationale:** Permanent companion death mid-run would be too punishing given
> the short floor length. Keeping them inactive rather than dead fits the
> purgatory aesthetic — a soul dimming rather than extinguishing. Making revival
> items rare and exclusively from elite and boss drops creates a genuine
> trade-off: survival insurance versus run power. The player who takes the revive
> item is making a meaningful sacrifice.

---

### 4.7 Floor Transitions — Full Reset

At the end of each floor — after the boss encounter — both the vessel and all
active companions are fully restored to maximum HP. Inactive bound companions
are **not** automatically revived by a floor transition; they remain inactive
until a revival consumable is used.

There is no mid-floor healing or revival from rooms or events. The floor is a
resource management arc with a known endpoint. The only mid-floor healing
available comes from consumable items found during the floor itself.

> **✓ Decision: Full HP reset for vessel and all active companions at floor
> transition — no mid-floor room-based healing or revival**
>
> **Rationale:** The floor becomes a self-contained arc — the player knows relief
> is coming after the boss, making every decision between here and there about
> surviving long enough to reach it. Full reset removes carry-over damage
> complexity and keeps floor difficulty self-contained. Partial healing from
> consumables found during the floor is the only variable — appropriately scarce
> and already integrated into the item economy.

---

### 4.8 Item Use — Combat Only

All items — healing consumables, revival consumables, and all other item types —
are used exclusively inside combat via the Consumable action bucket. There is no
out-of-combat item interface.

> **✓ Decision: Items are used in combat only — no out-of-combat item use**
>
> **Rationale:** An out-of-combat inventory screen is a significant scope addition
> with limited design value given the short floor length. Restricting item use to
> combat keeps the interface surface small and the decision context clear — items
> are tactical tools, used in the moment they are needed, not managed between
> fights.

---

*Section last updated: v0.5*

---

## 5. Vessels

### 5.1 What a Vessel Is

A vessel is the recently deceased person the soul inhabits for a run. They are not
class archetypes — they are people, defined by who they were and how they died.
Their circumstances at death shape everything about how they fight.

Each vessel has a dedicated design document covering their specific story, abilities,
and unlock conditions. This section defines what every vessel document must contain
and the system-level rules that apply to all vessels.

---

### 5.2 Vessel Definition — Required Components

Every vessel is defined by the following components:

**Identity**
A brief account of who the vessel was in life, the circumstances of their death,
and their emotional register in purgatory. This is the narrative foundation that
gives the vessel's ability names, flavour text, and companion relationship their
coherence.

**Combat Profile**
The vessel's core stats for a run. At MVP this is primarily HP. Additional stats
— resistances, vulnerabilities, or resource pools — are flagged as a future
consideration once the status effect system is fully designed.

> **`[OPEN]`** Stats beyond HP — resistances, vulnerabilities, and vessel-specific
> resource pools to be revisited once the status effect system is defined.

Whether the vessel has a **bound companion** is noted here. All vessels can
encounter temporary companions through non-combat events — this does not need
to be noted as it is universal.

**Ability Loadout**
The largest part of a vessel definition. A fixed set of abilities the vessel
brings to every run — these do not change during a run. The loadout specifies
for each ability:

- Whether it is an **attack** or **support** ability (determines which action
  bucket it occupies)
- What it does mechanically
- Its charge count and replenishment trigger
- Its flavour name and description, consistent with the vessel's identity

**Unlock Condition**
The experience-based condition that makes this vessel available. Unlock conditions
are always rooted in something the soul has lived — a specific outcome, a
demonstrated understanding of a mechanic, or a milestone reached during play.
They are never currency-gated.

---

### 5.3 Default Strike — Universal

Every vessel shares the same Default Strike. It is not part of a vessel's ability
loadout and never changes.

**Throw Rock** — Single target, ranged. Deals reduced damage. No secondary
effects. No charges. Always available.

Being ranged means the Default Strike is never blocked by row position — the
player always has a fallback attack option regardless of enemy positioning.
The slight absurdity of an ancient soul throwing rocks is intentional; it
communicates resource depletion without making the player feel helpless.

> **✓ Decision: Default Strike is universal across all vessels — "Throw Rock",
> single target ranged, no charges**
>
> **Rationale:** A universal fallback keeps the floor of every vessel consistent
> and requires no per-vessel design work. Ranged ensures row position never
> blocks the fallback. The flavour is intentionally humble — it signals to the
> player that they are scraping the bottom without removing their agency.

---

### 5.4 Action Economy — Standard for All MVP Vessels

All MVP vessels use the standard action economy without deviation:

- One attack action per turn (Attack bucket)
- One free non-attack ability per turn (Support bucket)
- One free consumable item per turn (Consumable bucket)

Deviations from this structure — such as a vessel that starts with a restricted
economy and unlocks full capacity mid-run — are a post-MVP consideration.

> **✓ Decision: All MVP vessels use the standard action economy**
>
> **Rationale:** Introducing action economy variations across vessels at MVP
> adds teaching burden before the base system is fully validated through
> playtesting. Variations are a natural expansion once the standard economy
> is proven.

---

### 5.5 Vessel Unlock Structure

The first vessel is available from the start — no unlock required. It is
designed explicitly to teach the core systems and its play naturally leads to
the conditions that unlock the next vessels.

Subsequent vessels are unlocked by experience conditions tied to runs with
previously unlocked vessels. Unlock conditions are hidden until the player
is close to meeting them, at which point the Soul Codex surfaces a hint —
a fragment of narrative suggesting another soul is nearby, waiting.

> **✓ Decision: Unlock conditions are experience-gated and narratively hinted
> when close — never displayed as a checklist from the start**
>
> **Rationale:** Consistent with the knowledge-gated meta-progression philosophy
> in the main design doc. Conditions revealed upfront become checklists to grind;
> conditions that surface as narrative hints feel like discovery. The player
> who meets a condition accidentally experiences a genuine surprise.

---

*Section last updated: v0.6*

---

*Soul Protocol Game Design v0.8*
*Companion to soul_protocol_v0_4.md and soul_protocol_tech_arch_v0_5.md*
*v0.1: Action economy defined.*
*v0.2: Enemy intent defined.*
*v0.3: Inventory and items defined.*
*v0.4: Remnant tag defined.*
*v0.5: Companion system partially defined.*
*v0.6: Companion system completed.*
*v0.7: Vessel system defined.*
*v0.8: Item flags added — floor-bound expiry and encounter-countdown
non-combat items.*
*Next: Vessel 2 design document.*
