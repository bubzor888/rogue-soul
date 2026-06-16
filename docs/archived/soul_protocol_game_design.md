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

Non-attack abilities — buffs, defensive moves, companion interactions — are free
and do not consume the Attack bucket. One per turn. These abilities are typically
gated behind charges and will exhaust over the course of a run.

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

## 2. Enemy Intent & Fate Omens

Combat contains two distinct systems that operate simultaneously: **Enemy Intents**
and **Fate Omens**. They serve different purposes and occupy different conceptual
space — intents tell the player what enemies will do, fate omens represent purgatory
itself intervening in the fight.

---

### 2.1 Enemy Intents

Each enemy telegraphs their action for the current turn in the style of Slay the
Spire — a visible, specific declaration of what they intend to do before they do
it. Intents are shown on the enemies themselves.

Each intent is an instance — two enemies both planning a damage attack show two
separate intent indicators, not one combined one. This keeps intent reading
unambiguous regardless of enemy count.

Intents are a **live forecast** that recalculates as the player acts within their
turn. Every player action can affect the intent board:

- **Kill an enemy** → their intent disappears entirely
- **Stun or disable an enemy** → their intent is suppressed this turn, shown as
  dimmed or broken
- **Apply a debuff** → their intent may downgrade in severity

This makes **action sequencing matter within a turn.** Using a support ability to
stun an enemy before choosing an attack lets the player see how the board changes
before committing.

When an intent updates mid-turn the change is **immediate and visual**, paired
with a **distinct audio cue** signalling the player's situation has improved.
No animation accompanies the update — it is instantaneous. The sound is the
reward layer on top of the visual change.

> **✓ Decision: Enemy intents are telegraphed, instance-based, and update
> immediately as the player acts — confirmed by a positive audio cue**
>
> **Rationale:** Fully telegraphed intents create tension through knowing what
> is coming and choosing how to respond, not through hidden information.
> Instance-based display keeps intent reading unambiguous. Reactive updating
> rewards deliberate turn sequencing.

---

### 2.2 Enemy Intent Legibility

Enemy intents are not immediately self-explanatory to a new player. They are
visual manifestations — glows, symbols, distortions — that must be learned over
time. First encounters with a new enemy type produce unfamiliar intents; the
player learns their meaning through experience.

Once an enemy has been recorded in the **Soul Codex**, the codex entry includes
a description of that enemy's intents. Veteran players recognise them on sight;
new players can look them up. This gives the Soul Codex genuine in-run utility
beyond narrative reward.

> **✓ Decision: Enemy intents are learned through play, with the Soul Codex
> as the reference**
>
> **Rationale:** Mystery on first encounter fits purgatory. Persistent mystery
> after multiple encounters would be frustrating. The Codex converts earned
> experience into reliable knowledge.

---

### 2.3 Fate Omens — The Second Layer

Separate from enemy intents, **fate omens** represent purgatory intervening in
the fight. They are not damage — enemy intents handle direct threats. Fate omens
operate in the space of buffs, debuffs, status effects, and conditions. They
shift the circumstances under which the fight plays out.

Fate omens are generated by a combination of:
- The **enemy being fought** — their nature colours what fate brings
- The **floor's boss** — the floor's overall theme influences the omen pool
- The **player's build** — vessel, items, and companion can contribute omens

> **✓ Decision: Fate omens focus on buffs, debuffs, and status effects —
> not direct damage**
>
> **Rationale:** Enemy intents already handle direct threats. Fate omens as a
> second damage layer would be redundant. Restricting omens to conditional
> effects keeps the two systems distinct and complementary.

---

### 2.4 The Fate Omen Cycle

Fate omens arrive in cycles. At the start of a cycle, **3 fate omen cards** are
revealed. The player must engage with all three — there is no ignoring the cycle.

**Each cycle resolves as follows:**

1. **Player chooses 1 card** and assigns it to either themselves or the enemy
2. **1 of the remaining 2 cards** is randomly assigned to the **opposite side**
   from the player's choice
3. **The final card's number** (1–3) sets the turn countdown until the next cycle

Omen cards are neutral — they apply their effect to whoever they land on.
A heal omen on the enemy heals the enemy. A weaken omen on the player weakens
the player. The player only controls one placement; the second is chance.

**The core decision each cycle:**

- **All beneficial cards:** Which one do you take, knowing the others might
  benefit the enemy? Pick what you need most, but consider which remaining cards
  hurt least if they land on the enemy.
- **All harmful cards:** Which do you absorb on your terms, knowing the others
  might randomly land on you anyway? Take the most predictable bad thing.
- **Mixed cards:** Usually clearest — take the good one — but the random
  placement of the bad card still creates tension.

The **number on the final card** matters beyond just timing — a 1 means the next
cycle arrives fast and this fight's conditions shift rapidly; a 3 means the
current conditions persist for longer, rewarding or punishing the player's
placement choice for more turns.

> **✓ Decision: Fate omens arrive in cycles of 3 — player places 1, random
> places 1, final card's number sets countdown**
>
> **Rationale:** Creates genuine decision tension every cycle regardless of card
> quality. The player is always negotiating with fate rather than simply reacting
> to it. The placement asymmetry — player controls one side, chance controls the
> other — keeps cycles from being solvable and maintains unpredictability without
> removing agency.

---

### 2.5 Fate Omen Card Composition

Fate omen cards contain only buff, debuff, and status effects. Examples of what
omen cards can do:

| Type | Examples |
|---|---|
| **Buffs** | Strength (increased damage), Agility (avoid next hit), Regeneration (heal per turn) |
| **Debuffs** | Weak (reduced damage dealt), Vulnerable (increased damage taken), Slow (reduced actions) |
| **Status** | Bleed (damage over time), Freeze (skip turn), Empower (next ability enhanced) |

Numbers on cards (1–3) represent how many turns until the next cycle. Higher
numbers are not inherently better or worse — they depend on the current board
state.

> **`[OPEN]`** Full omen card list and card weighting per enemy type and floor
> theme to be defined during encounter design.

---

*Section last updated: v0.8*

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

### 3.4 Item Flag — Floor-Bound

Items can be flagged as **floor-bound** — they expire at the end of the current
floor. If still in inventory when the floor transition occurs, they are removed.
They are not carried to the next floor.

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

### 3.5 Item Flag — Encounter Counter (Non-Combat Items)

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

### 4.1 Companions as Passive Persistent Effects

Companions are not active combatants. They cannot be targeted by enemies, have
no HP pool, and cannot die. Instead each companion provides two things that
persist for as long as they travel with the vessel:

- A **fixed passive effect** that applies every turn automatically — damage,
  shielding, healing, or a conditional buff
- A **companion omen card** injected into the fate omen deck — when this card
  appears in a cycle it triggers a special effect beneficial to the player.
  The companion card is inert if it lands on the enemy side.

This makes companions feel like persistent skills with occasional moments of
heightened effect, rather than fragile second units requiring protection.

> **✓ Decision: Companions are passive persistent effects — untargetable,
> no HP, fixed turn effect plus one omen card in the fate deck**
>
> **Rationale:** Removes companion HP management as a cognitive burden without
> losing the strategic value of having a companion. The fate omen card gives
> each companion a distinct fingerprint in the combat loop — experienced players
> learn to read the deck partly through knowing which companion cards are in it.
> Simpler to implement and communicate than an active companion model.

---

### 4.2 Party Composition

A vessel can travel with up to two companions simultaneously — one **bound**
and one **temporary**. These are hard limits at MVP.

| Vessel Type | Bound Companion | Temporary Companion |
|---|---|---|
| With bound companion | Yes — permanent for the run | 1 (optional) |
| Solo vessel | None | 1 (optional) |

Each active companion contributes one omen card to the fate deck. A vessel
traveling with both a bound and temporary companion has two companion cards
in the deck simultaneously.

> **✓ Decision: Maximum one bound companion and one temporary companion active
> simultaneously**
>
> **Rationale:** Keeps the fate omen deck composition legible. Two companion
> cards in a deck is meaningful and manageable. More would dilute both the
> enemy omen pool and the player's ability to read the deck.

---

### 4.3 Bound Companions

Bound companions are tied to specific vessel archetypes. They travel for the
entire run and cannot be lost. Their passive effect and omen card are fixed
for that vessel — they are part of the vessel's identity, not a variable.

---

### 4.4 Temporary Companions

Temporary companions are encountered exclusively through **non-combat events**
— Wandering Soul rooms, Echo Chambers, Memory Fragments, and Anomalies. They
travel with the player until the **floor boss is defeated**, at which point
they depart. There is no revival or retention path — their departure after
the boss is expected and clean.

When a temporary companion is active their omen card is in the fate deck for
that floor only. On floor transition the card is removed.

> **✓ Decision: Temporary companions depart after the floor boss — sourced
> from non-combat events only, never from items or abilities**
>
> **Rationale:** Sourcing temporary companions from non-combat events gives
> those rooms meaningful weight. A Wandering Soul encounter could reshape the
> omen deck for the rest of the floor. Departure after the boss keeps the
> system clean — no carry-forward complexity between floors.

---

### 4.5 Replacing a Temporary Companion

When the player encounters a potential temporary companion and already has one
active, they must choose which to move forward with. The unchosen companion
departs — the player cannot hold both.

> **✓ Decision: Encountering a new temporary companion forces a choice —
> keep current or take the new one**
>
> **Rationale:** Creates genuine loss moments even when something good is
> happening. Also has deck implications — the player is choosing between two
> different omen cards for the remainder of the floor.

---

### 4.6 Companion Identity — Known Through Experience

Potential companions are presented through **flavour text only** at the point
of encounter. No mechanical information — passive effect or omen card — is
disclosed until the player has traveled with them. The player decides based
on narrative instinct and accumulated experience.

A Soul Codex entry for a companion unlocks the moment the player accepts them.
Passing over a companion leaves their entry blank — they remain unknown until
a future run where the player chooses differently.

> **✓ Decision: Companion mechanics not disclosed at encounter — flavour text
> only. Codex entry unlocks on acceptance.**
>
> **Rationale:** Consistent with the enemy intent philosophy — meaningful things
> are learned through play. The Codex creates a natural completionist goal
> without stating it explicitly. Passing over a companion is choosing ignorance.

---

### 4.7 Floor Transitions

At the end of each floor the vessel's HP is fully restored. Temporary companions
depart. The bound companion remains and their omen card persists in the deck
into the next floor.

There is no mid-floor healing from rooms or events. The only mid-floor healing
comes from consumable items.

> **✓ Decision: Full vessel HP reset at floor transition — temporary companions
> depart, bound companion persists**

---

### 4.8 Item Use — Combat Only

All items are used exclusively inside combat via the Consumable action bucket.
There is no out-of-combat item interface.

> **✓ Decision: Items are used in combat only — no out-of-combat item use**
>
> **Rationale:** An out-of-combat inventory screen is significant scope with
> limited design value given the short floor length.

---

*Section last updated: v0.9*

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

**Throw Rock** — Single target. Deals reduced damage. No secondary effects.
No charges. Always available.

The slight absurdity of an ancient soul throwing rocks is intentional; it
communicates resource depletion without making the player feel helpless.

> **✓ Decision: Default Strike is universal across all vessels — "Throw Rock",
> single target, no charges**
>
> **Rationale:** A universal fallback keeps the floor of every vessel consistent
> and requires no per-vessel design work. The flavour is intentionally humble —
> it signals to the player that they are scraping the bottom without removing
> their agency.

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

The vessel tree runs **backwards through the soul's history**. The Pilgrim is not
a starting point — he is the endpoint of a long erosion. Unlocking vessels means
recovering earlier, more intact versions of the same soul. Playing deeper into the
tree means playing earlier in the soul's story.

This reframes the Pilgrim on replays. On a first run he is simply a calm man on a
road. After playing deeper branches, he becomes something more — the player
understands what he used to be.

**The vessel tree:**

```
                         [ The Pilgrim ]
                         Tier 1 — 1 floor
                         Available from start
                               |
                 ______________|______________
                |                             |
        [ The Drifter ]               [ The Hedge Knight ]
        Tier 2 — 2 floors             Tier 2 — 2 floors
        Companion path                Solo path
        Bound companion: Ferret       No bound companion
        Unlocked from Pilgrim         Unlocked from Pilgrim
                |                             |
          ______|______               ________|________
         |             |             |                 |
   [ The Shaman ] [ The Ranger ] [ The Paladin ] [ The Battle Wizard ]
   Tier 3          Tier 3         Tier 3          Tier 3
   3 floors        3 floors       3 floors        3 floors
   Spirit animal   Bear           No companion    No companion
   companion       companion
```

**Unlock conditions** are tied to completing runs at the required floor depth
with the preceding vessel. Conditions are hidden until the player is close to
meeting them, at which point the Soul Codex surfaces a narrative hint — a
fragment suggesting another soul is nearby, waiting to be found.

> **✓ Decision: The vessel tree runs backwards through the soul's history —
> unlocking vessels recovers the soul's past, not a linear progression forward**
>
> **Rationale:** Gives the meta-progression genuine narrative meaning. Each
> unlock is discovery rather than reward — the player is assembling a picture
> of who this soul was before erosion. The Pilgrim's simplicity becomes
> poignant in retrospect rather than just being a tutorial limitation.

> **✓ Decision: Unlock conditions are floor-completion gated and narratively
> hinted when close — never displayed as a checklist from the start**
>
> **Rationale:** Conditions revealed upfront become checklists to grind;
> conditions that surface as narrative hints feel like discovery.

---

### 5.6 Floor Structure

Each floor has a fixed identity shared across all vessels that play it. The
number of floors a vessel plays reflects how far the soul has eroded — and
therefore how much of its history must be traversed to reach the threshold.

---

#### Floor 1 — The Origin *(Tier 3 vessels only)*

Four distinct floors, one unique to each tier 3 vessel. These are the worlds
the soul inhabited when it was most intact — specific, grounded, and real.
No haze, no blurring. A place with weight and weather and enemies that belong
to it.

| Vessel | Floor identity |
|---|---|
| **The Paladin** | A crypt beneath a holy site — faith and corruption in the same stone |
| **The Battle Wizard** | A subterranean place where significant magic went wrong |
| **The Shaman** | Contested wilderness — the tribe's territory under threat |
| **The Ranger** | Frontier wilderness turning without its guardian |

---

#### Floor 2 — The Dissolution *(Tier 2 and Tier 3 vessels)*

Two variants, one per branch of the vessel tree. Tier 2 vessels play at
standard difficulty. Tier 3 vessels play the same floor as their tier 2
counterpart at scaled-up difficulty — the soul is more intact and purgatory
pushes back harder.

| Branch | Floor identity | Tier 2 vessels | Tier 3 vessels |
|---|---|---|---|
| **Solo** | The Blurred Deep — underground, crypt and cave bleeding together, undead and elemental enemies | The Hedge Knight | The Paladin, The Battle Wizard |
| **Companion** | The Unmarked Edge — above ground, forest and grassland occupying the same terrain, warriors and beasts | The Drifter | The Shaman, The Ranger |

---

#### Floor 3 — The Threshold *(All vessels)*

A single shared dreamlike space — fragments of all origin floors jumbled and
partially dissolved. Architecture without logic. Light from no visible source.
The gate to Solace always fully rendered regardless of everything around it.

Enemy clarity and difficulty scale with vessel tier. The more intact the soul,
the more sharply purgatory manifests and the harder it resists.

| Vessel tier | Enemy clarity | Relative difficulty |
|---|---|---|
| **Tier 1 — The Pilgrim** | Haze and half-shapes — barely there | Lightest |
| **Tier 2 — Drifter, Hedge Knight** | Partially resolved — present but wrong | Moderate |
| **Tier 3 — Paladin, Battle Wizard, Shaman, Ranger** | Sharp and fully present | Hardest |

The floor ends with **The Judge** — the final boss for all vessels. The Judge
decides who has a true need to reach Solace. The Judge's combat behaviour,
difficulty, and dialogue vary by vessel tier — the same entity, scrutinising
the soul more or less heavily depending on how much of itself it still retains.

> **✓ Decision: Floor count is fixed per vessel tier — 1 floor for Pilgrim,
> 2 for tier 2, 3 for tier 3**
>
> **Rationale:** Run length is a direct expression of narrative position in
> the soul's history. Shorter runs for more eroded vessels is mechanically
> forgiving and thematically coherent simultaneously.

> **✓ Decision: The Judge is the final boss for all vessels — same entity,
> different combat behaviour per tier**
>
> **Rationale:** A single boss with variable expression is more memorable and
> more narratively coherent than separate bosses. The Judge's escalating
> difficulty mirrors the narrative logic — the intact soul faces a harder test
> of need than the eroded one.

> **✓ Decision: Floor 2 is shared between tier 2 and tier 3 vessels on the
> same branch, with difficulty scaled up for tier 3**
>
> **Rationale:** Efficient content design — four origin floors and two
> dissolution floors cover all seven vessels. Tier 3 vessels experience their
> tier 2 counterpart's world at a later, more contested stage of dissolution,
> which is narratively appropriate.

---

### 5.7 The Judge — Working Title

The Judge is the final boss on floor 3 and the narrative gatekeeper of Solace.
His role is to determine whether the soul's need is genuine — whether it has
truly run out of other places to go, or whether it is still clinging to
something that disqualifies it.

The Pilgrim faces the easiest version of this test. He arrives with almost
nothing. The Judge barely resists him. The Paladin, still whole and purposeful,
faces a Judge who scrutinises every remaining fragment of who they are.

> **`[OPEN]`** The Judge's name is a working title. Final name to be confirmed
> during narrative pass.

> **`[OPEN]`** Specific combat mechanics per vessel tier to be designed during
> encounter design sessions.

---

*Section last updated: v1.2*

---

*Soul Protocol Game Design v1.3*
*Companion to soul_protocol_v0_4.md and soul_protocol_tech_arch_v0_5.md*
*v0.1: Action economy defined.*
*v0.2: Enemy intent defined.*
*v0.3: Inventory and items defined.*
*v0.4: Remnant tag defined.*
*v0.5: Companion system partially defined.*
*v0.6: Companion system completed.*
*v0.7: Vessel system defined.*
*v0.8: Item flags added.*
*v0.9: Enemy intent and fate omen system redesigned.*
*v1.0: Row system and melee/ranged distinction removed. Companion system
redesigned — companions are passive persistent effects with a fixed turn
effect and one omen card in the fate deck. No HP, no targeting, no death.
Bound companions permanent for the run. Temporary companions depart after
floor boss.*
*v1.1: Vessel section updated to reflect narrative document — tree runs
backwards through soul history, Urchin renamed to The Drifter, floor count
fixed per tier (1/2/3), enemy difficulty scales with vessel tier on final
floor. Row reference removed from Support bucket. Throw Rock row justification
removed.*
*v1.2: Remnant tag removed — soul-carried items incompatible with backwards
narrative structure. All seven vessels named in tree. Floor count table updated.
Floor-bound item flag cleaned of Remnant reference.*
*v1.3: Full floor structure defined — Floor 1 (origin, tier 3 only, four
distinct floors), Floor 2 (dissolution, two variants by branch, tier 3 scaled
up), Floor 3 (threshold, shared, The Judge as final boss with tier-scaled
behaviour). The Judge introduced as working title for final boss.*
*Next: The Drifter vessel design document.*
