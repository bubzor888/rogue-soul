# Soul Protocol — Narrative Design
## Version 0.2 · May 2026 · Solo Developer

> **Purpose:** This document records narrative decisions for Soul Protocol —
> the story the game is telling, how vessels serve that story, and how the
> progression structure carries meaning. It is a companion to
> `soul_protocol_game_design.md` and `soul_protocol_overview.md`.
>
> Confirmed decisions are marked **`✓`**.
> Open questions are marked **`[OPEN]`**.
> Items pending discussion are marked **`[PENDING]`**.

---

## Table of Contents

1. [The Soul & Its Goal](#1-the-soul--its-goal)
2. [Solace](#2-solace)
3. [The Guardian](#3-the-guardian)
4. [Vessel Structure & The Narrative Arc](#4-vessel-structure--the-narrative-arc)
5. [The Vessel Tree](#5-the-vessel-tree)
6. [Floor Themes](#6-floor-themes)
7. [Endings](#7-endings)

---

## 1. The Soul & Its Goal

The soul is ancient. It has lived many lives, and in each one it has felt the
same pull — an itch it cannot name toward a place it cannot fully remember.
This is not a soul searching for a person, or fulfilling a mission, or trying
to escape purgatory. It is a soul that has always been drawn toward **Solace**,
across every life it has lived, unable to reach it.

Each time the soul fails — through misfortune on the journey, or through
failing the guardian's judgment at the gate — it is reborn. The new life
carries the same pull, dimmer and harder to articulate, the accumulated weight
of previous failures slowly eroding who the soul is.

> **✓ Decision: The soul has sought Solace across multiple lives. Each failure
> — whether by misfortune or judgment — results in rebirth. The erosion across
> vessels is the cost of being turned away repeatedly.**
>
> **Rationale:** This gives the roguelite death loop narrative coherence. The
> soul isn't cycling randomly — it is paying a price each time. The Pilgrim is
> not a starting point but an endpoint: the most eroded version of a soul that
> was once much more whole.

The soul does not remember its previous lives explicitly. It carries the pull
toward Solace the way a person carries a habit — present, persistent, and
not fully explicable. In each vessel, the soul knows the myth of Solace with a
certainty it cannot justify to anyone else. That certainty is isolating. Every
vessel has lived with this pull that no one around them quite understands.

> **✓ Decision: The soul's knowledge of Solace feels like instinct rather than
> memory — certain but inarticulate, and isolating.**

---

## 2. Solace

Solace is a place of legend — an earthly paradise of long-lived, contented
people, existing somewhere beyond the edge of the known world. Most people
dismiss it as myth. Children's stories. The wishful thinking of the desperate.

To those who believe, Solace is understood differently depending on their
culture, faith, and circumstance — a holy land, a promised refuge, a place
where suffering ends. The myth is consistent enough across traditions to
suggest something real at its core, but no living person has confirmed it.

> **✓ Decision: Solace is the destination — an earthly paradise analogous to
> Shangri-La in cultural register. Widely dismissed as myth. The soul's belief
> in it is unshakeable across every life.**

The name is a real word, chosen deliberately. The player understands it
immediately and emotionally. Solace is not a place you conquer — it is a
place you *need*. That distinction is the foundation of everything the
guardian does.

> **✓ Decision: The destination is named Solace.**

---

## 3. The Guardian

At the threshold of Solace stands a guardian. It does not judge worthiness
in a moral sense. It judges **need**.

Solace is a refuge. The guardian's question is not *have you earned this* but
*do you require this*. A soul that still has something — purpose, faith,
comfort, a reason to return — does not qualify. The gate opens for those who
have nowhere else to go.

> **✓ Decision: The guardian judges need, not moral worthiness. The test is
> harder for those who still have something. The Pilgrim passes most easily
> not despite their erosion but because of it.**

This produces the game's central irony: the soul's repeated attempts to reach
Solace through strength, purpose, and conviction have all failed the test.
The Pilgrim — hollowed out, barely holding the memory of why they came —
simply arrives. The gate opens almost before they knock.

The guardian's judgment also accounts for the path taken. A soul that reaches
the gate intact, having suffered little, is turned away. A soul that has lost
companions, purpose, or certainty along the way stands before the guardian
differently — the journey itself is part of the petition.

> **`[OPEN]`** What does the guardian say to each vessel? The Pilgrim receives
> something cryptic acknowledging their emptiness as the qualifying condition.
> Other vessels receive judgments specific to what they carried to the gate.
> Specific dialogue to be written per vessel.

> **`[OPEN]`** Is the guardian a single consistent entity across all runs and
> all vessels, or does it manifest differently depending on who is petitioning?

---

## 4. Vessel Structure & The Narrative Arc

### 4.1 The Core Inversion

The vessel unlock tree runs **backwards through the soul's history**. The
Pilgrim is not a starting point — he is the *end* of a long erosion. The tier
3 vessels are earlier, more intact versions of the same soul. Playing deeper
into the tree means playing earlier in the soul's story.

> **✓ Decision: The vessel tree is the soul's history in reverse. Unlocking
> vessels moves backward through time. The Pilgrim is the final, most eroded
> state.**

This reframes the Pilgrim on replays. On a first run he is simply a calm man
on a road. After playing the Paladin branch, he is heartbreaking — the player
knows what he used to be.

### 4.2 The Three Tiers

Vessels are organised into three tiers reflecting how far the soul has eroded
at that point in its history.

---

#### Tier 1 — The Pilgrim

The soul at its most eroded. No framework, no replacement purpose, no
companion. Just the myth and the road and the faint feeling that Solace is
the only thing left.

The Pilgrim seeks Solace as **survival**. Not as holy land, not as
replacement purpose — as the one place where whatever is wrong with him
might finally stop.

The Pilgrim's run is **one floor** — the final floor, the threshold itself.
It is the easiest run mechanically. What he has lost has made him lighter,
less burdened, less scrutinised by the guardian. His erosion is not a
handicap — it is the condition of his passage.

---

#### Tier 2 — The Midpoint Vessels

Two vessels representing the soul after significant loss but before total
dissolution. Each feeds into the Pilgrim and is fed by two tier 3 vessels.

The tier 2 vessels seek Solace as **replacement purpose**. Something that
gave life structure is gone. Solace stops being an achievement and becomes
a substitute — *if I can reach it, I have a reason to keep going.*

Tier 2 runs are **two floors** — a new floor representing the middle of
the dissolution, followed by the Pilgrim's floor. The same final floor,
the same guardian, but experienced differently because the player
understands more of what is at stake.

**The Hedge Knight** — solo path. Lost his lord, his code, his identity.
Still moves like a person of consequence but the fire is gone. Feeds into
the Pilgrim via the solo branch.

**The Drifter** — companion path. Once belonged somewhere — had a community,
a place, a role. Lost it. Now moves because staying anywhere too long is a
reminder of what they no longer have. Travels with a **ferret companion**
whose instinct is to steal and scavenge — a creature that survives on the
margins the same way the Drifter does. They found each other out of mutual
necessity.

The Drifter seeks Solace as a place to finally stop moving. If there is
somewhere people are truly content, perhaps the Drifter can belong there.
The ferret is not a noble or mystical companion — it is a pragmatic one.
Its item-stealing mechanic reflects their shared way of getting by.

> **`[OPEN]`** The ferret companion may be a diminished echo of the spirit
> animal from one of the tier 3 companion vessels — something that followed
> the soul through the erosion but changed along the way. To be confirmed
> once both tier 3 companion vessels are fully designed.

---

#### Tier 3 — The Origin Vessels

Four vessels representing the soul in relative wholeness — intact enough
to seek Solace as aspiration rather than desperation. Each has a distinct
reason for believing, rooted in who they are rather than what they have lost.

The tier 3 vessels seek Solace as **aspiration**. They want it, but from
a position of relative wholeness. Solace fits into their existing framework
— a crowning achievement, a holy land, a proof, a shared dream.

Tier 3 runs are **three floors** — the origin floor, the middle floor
(shared with the relevant tier 2 vessel), and the final floor (shared with
the Pilgrim). The complete story of the soul on that branch.

Two tier 3 vessels are **solo** and erode into the Hedge Knight.
Two tier 3 vessels are **companion-based** and erode into the second
tier 2 vessel.

---

### 4.3 The Erosion Paths

```
Tier 3                        Tier 2          Tier 1

The Paladin      →  \
The Battle Wizard →   The Hedge Knight  →
                                                The Pilgrim
The Shaman       →  \
The Ranger       →    The Drifter       →
```

**The Paladin** seeks Solace as a holy land — the crowning achievement of
a life of faith. Loses faith or certainty along the way, becoming the Hedge
Knight — still fighting but no longer sure why.

**The Battle Wizard** seeks Solace through power and perhaps proof — someone
who wields magic in service of the journey rather than in service of knowledge.
Their erosion into the Hedge Knight is almost physical: the magic fades and
what remains is someone who still knows how to fight but the fire is literally
gone. The Hedge Knight carries hints of both predecessors — the discipline of
faith, the remnants of something that used to crackle in the hands.

**The Shaman** seeks Solace as a communal dream — not for themselves but as
the last keeper of their tribe's belief. Solace was woven into their people's
oral tradition, a promised land carried across generations. The tribe is gone.
The Shaman is the last one who remembers the promise. Stopping would mean the
dream dies with them.

Their companion is a **spirit animal** — not a physical creature but a
manifestation of the Shaman's connection to something beyond the material.
Its presence is what remains of the Shaman's power and their bond with the
tribe. Mystical in register, sacred rather than pragmatic.

The erosion into the Drifter strips the Shaman of their people, their role,
and gradually their connection to the spirit. A shaman without a tribe is no
longer a shaman. What remains is someone who still moves with quiet purpose
but has lost the community that gave that purpose meaning.

**The Ranger** seeks Solace as a place of permanent peace — and the one place
a lifelong guardian would no longer be needed. Their identity was vigilance:
protecting a territory, a people, a way of life alongside a brotherhood of
others who shared that charge. The order is gone, the territory lost or changed
beyond recognition. There is nothing left to protect.

Their companion is a **bear** — the last member of the Ranger's order still
standing. Not mystical. Not symbolic. Simply present, loyal, and dangerous.
Where the spirit animal is ethereal, the bear is immediate and physical.
In combat it actively fights and absorbs damage — taking hits meant for the
Ranger the way a fellow soldier would.

The erosion into the Drifter takes the territory, the order, and eventually
the bear. What remains is someone who still reads landscapes instinctively,
still moves through the world undetected, but has nowhere to go and nothing
to protect.

> **✓ Decision: The two companion tier 3 vessels are The Shaman (spirit animal
> companion, mystical register) and The Ranger (bear companion, martial
> register). Both vessel and companion are genuine partners in the search for
> Solace — not protector/protected but co-seekers. All companions are animals
> or mystic beings, not humans.**

---

## 5. The Vessel Tree

### Confirmed Vessels

| Vessel | Tier | Path | Companion | Status |
|---|---|---|---|---|
| The Pilgrim | 1 | — | None | Designed — see `vessel_pilgrim.md` |
| The Hedge Knight | 2 | Solo | None | Designed — see `vessel_hedge_knight.md` |
| The Drifter | 2 | Companion | Ferret | Identity confirmed, design pending |
| The Paladin | 3 | Solo → Hedge Knight | None | Identity confirmed, design pending |
| The Battle Wizard | 3 | Solo → Hedge Knight | None | Identity confirmed, design pending |
| The Shaman | 3 | Companion → Drifter | Spirit Animal | Identity confirmed, design pending |
| The Ranger | 3 | Companion → Drifter | Bear | Identity confirmed, design pending |

### The Relationship Between Solo Vessels

The Paladin and the Hedge Knight share the same emotional wound at different
stages: conviction eroded into doubt. The Battle Wizard shares the Hedge
Knight's endpoint from a different origin — power lost rather than faith lost.
The Hedge Knight carries traces of both without being defined by either.

The Pilgrim is the endpoint of both solo paths. He is legible as the erosion
of faith *and* the erosion of power — because by the time he is the Pilgrim,
both have been gone long enough that only the habit of moving forward remains.

### The Relationship Between Companion Vessels

The Shaman and the Ranger both lose a community defined by shared purpose —
one spiritual, one martial. Both groups held Solace as a collective belief.
The Drifter is what remains when the community is gone and only the individual
persists, still carrying the pull toward Solace but now without anyone to
carry it with them.

The Pilgrim is the endpoint of the companion path too. By the time the soul
is the Pilgrim, even the ferret is gone. The solitariness of the Pilgrim is
not only the erosion of purpose — it is the erosion of every bond the soul
has ever traveled with. The player who completes the companion branch
understands the Pilgrim's aloneness as a specific kind of loss, not just
a default state.

---

## 6. Floor Themes

### 6.1 The Governing Principle

Floors get less grounded in reality the closer they are to Solace. The tier
3 floors feel like actual places from actual lives — present tense, lived in,
specific. The tier 2 floors exist at the boundary between the real and the
dreamlike, memories beginning to fray at the edges. The final floor is
almost entirely dream — no longer anchored to anything the soul directly
lived, only fragments and haze and the gate at the end of it.

> **✓ Decision: Reality degrades across floors as the soul approaches Solace.
> Tier 3 floors are grounded. Tier 2 floors are liminal. The final floor is
> dreamlike.**
>
> **Rationale:** The visual progression mirrors the soul's erosion. The soul
> is least tethered to the real in its most eroded state. The floor atmosphere
> and the vessel's inner state tell the same story simultaneously.

Enemy visual clarity and mechanical strength on the final floor scale with
which vessel is playing — crisply rendered enemies for tier 3 vessels,
half-dissolved shapes for the Pilgrim. The floor communicates difficulty
through atmosphere rather than a UI element.

> **✓ Decision: On the final floor, enemy visual clarity and mechanical
> strength reflect how intact the vessel is. The Pilgrim faces the haziest,
> weakest enemies. The Paladin faces the sharpest, strongest.**

---

### 6.2 The Final Floor — The Threshold (shared, with variations)

**Register:** Dream. The soul at its most eroded, the world at its least real.

The final floor is the same space regardless of which vessel plays it, but
experienced differently depending on what the soul carried in. Architecture
that does not follow logic. Light from no visible source. Fragments of every
origin the soul has ever lived flickering in and out — a stone arch from a
crypt, a tree line through the fog, a cave wall that becomes forest floor
without transition. Nothing holds its shape long enough to be certain of.

All enemy types from all origin floors are present, but how clearly they
appear — and how hard they hit — varies by vessel. For the Pilgrim everything
is haze and half-shapes, barely there, as eroded as the soul itself. For the
Paladin the same floor is sharper, more contested, more present. The
memories have more resolution because the soul still remembers them.

The gate to Solace is the only thing on this floor that is always fully
clear. Regardless of vessel, regardless of how much haze surrounds it,
the gate is never uncertain.

> **✓ Decision: The final floor contains fragments of all four origin
> environments, jumbled and partially dissolved. Enemy strength and visual
> clarity scale with vessel tier. The gate to Solace is always fully
> rendered.**

**Thematic variations by vessel:**

- **The Pilgrim** — the floor is almost entirely haze. Enemies are outlines.
  The fragments of past lives are unrecognizable to him. He moves through it
  the way someone moves through a dream they know they are having.
- **The Hedge Knight / Drifter** — more resolution than the Pilgrim. Some
  fragments are recognizable — a crypt doorway, a tree line — but still
  disconnected and wrong. Enemies are present enough to feel dangerous.
- **The Paladin / Battle Wizard / Shaman / Ranger** — the most resolved
  version of the floor. Fragments of their specific origin floor appear
  with some clarity. Enemies are sharp and strong. The soul remembers too
  much to pass through easily.

---

### 6.3 The Tier 2 Floors — The Blurred Middle (two variants)

Both tier 2 floors share the quality of liminality — real but fraying,
recognizable but wrong. Proportions slightly off. Sounds that don't quite
match their source. Clear patches of sharp, cold reality alternating with
stretches where the air itself seems uncertain. The memories that built these
places are still mostly intact but losing resolution at the edges.

The two floors are visually distinct from each other — one underground,
one above ground — but share the same atmospheric quality of *almost real*.

---

#### The Hedge Knight's Floor — The Blurred Deep

**Register:** Underground, liminal. The geometry of two lives bleeding together.

The floor shifts without clear transitions between carved stone crypts and
raw cave systems. A doorway that should lead to a vaulted chapel opens into
a stalactite cavern. A stretch of rough cave wall resolves into dressed
stonework mid-corridor. Candlelight and bioluminescence occupy the same
space without either seeming wrong.

Enemies are a mixture of undead and elementals — the residue of the
Paladin's world and the Battle Wizard's world occupying the same contested
space. Clear patches where the stone is sharp and the danger is legible.
Hazy stretches where the air loses resolution and shapes are harder to read.
The fog here is not weather. It is memory losing its edge.

When the Paladin or Battle Wizard plays this floor, specific elements of
their origin floor appear with more clarity — recognizable remnants of the
world they came from, sharpening the contrast between what was and what
remains.

> **✓ Decision: The Hedge Knight's floor is underground, mixing crypt and
> cave geometry. Enemies are undead and elemental. Clarity varies —
> clear patches and hazy stretches throughout.**

---

#### The Drifter's Floor — The Unmarked Edge

**Register:** Above ground, liminal. Two wildernesses occupying the same terrain.

The landscape shifts between dense treeline and open grassland without
geographical logic — forest paths that open suddenly into meadow, clearings
that feel like they should contain settlements but don't. The wilderness of
the Shaman's world and the Ranger's world share the same terrain, neither
fully resolving into the other.

Enemies are a mixture of tribal warriors and enraged beasts — creatures
from two different lives that have lost whatever kept them measured, now
occupying the same unmarked ground. The haziness here feels less like
darkness and more like distance — something seen across a field that does
not quite resolve no matter how close you get.

When the Shaman or Ranger plays this floor, specific elements of their
origin floor appear with more clarity — the character of their particular
wilderness sharpening within the blur.

> **✓ Decision: The Drifter's floor is above ground, mixing forest and
> grassland wilderness. Enemies are tribal warriors and enraged beasts.
> The liminal quality feels like distance rather than darkness.**

---

### 6.4 The Tier 3 Floors — The Origin Floors (four distinct, MVP note)

**Register:** Grounded. Present tense. Lived in.

The tier 3 floors feel like actual places — specific, textured, and real.
These are the worlds the soul inhabited when it was most intact, and they
hold their shape accordingly. No haze, no blurring geometry. Just a place
with weight and weather and enemies that make sense within it.

Each floor is unique to its vessel. They are noted briefly here as the tier
3 vessels are post-MVP.

> **`[OPEN]`** Tier 3 floor designs are brief notes only — full design
> deferred until post-MVP vessel design sessions.

**The Paladin's Floor** — a crypt or catacomb beneath a holy site. The
faith that built this place and the corruption underneath it coexist in
the same stone. Enemies are undead. The journey begins in sanctified ground
that is no longer safe.

**The Battle Wizard's Floor** — subterranean, a place where significant
magical working happened and something went wrong. Elemental enemies as
the residue of power that outlasted its wielder. The magic is still present
but no longer controlled.

**The Shaman's Floor** — contested wilderness. The tribe's territory, but
another tribe presses in. Enemies are opposing warriors and hostile spirit
entities. The land is still alive with the Shaman's tradition but it is
under threat.

**The Ranger's Floor** — frontier wilderness. Dense forest and the edges
of a protected territory. The order is gone and the territory is turning —
creatures that were kept in balance have grown bold. The world the Ranger
protected is beginning to show what happens without them.

---

## 7. Endings

Each branch of the vessel tree has a distinct ending reflecting what that
soul carried to Solace and what the guardian saw in them.

> **✓ Decision: Beating the game with different vessels/branches produces
> different endings. The destination — Solace — is the same. The path,
> the guardian's judgment, and what the soul finds there differ.**

The Pilgrim's ending is the most opaque — they enter Solace barely knowing
what they sought. The Paladin's ending is the most complete — they arrive
knowing exactly what they lost to get there.

> **`[OPEN]`** Specific ending content per branch — to be developed once all
> vessel identities are confirmed.

> **`[OPEN]`** Does the player ever learn the full shape of the soul's history
> across branches, or does each branch remain its own complete story?

---

*Soul Protocol Narrative Design v0.3*
*v0.1: Initial narrative document. Core premise, Solace, the guardian,
vessel tier structure, and erosion paths established.*
*v0.2: All seven vessel identities confirmed. Companion path fully defined —
The Drifter (tier 2, ferret), The Shaman (tier 3, spirit animal), The Ranger
(tier 3, bear). Companion path erosion narrative added. Pilgrim's solitariness
reframed as the endpoint of both solo and companion erosion paths.*
*v0.3: Floor themes section added. Three floor registers defined — grounded
(tier 3), liminal (tier 2), dream (final). Final floor documented with
enemy clarity scaling by vessel tier and gate always fully rendered. Hedge
Knight floor (underground, crypt/cave, undead/elemental) and Drifter floor
(above ground, forest/grassland, warriors/beasts) fully documented. Tier 3
floors noted briefly, design deferred post-MVP.*
*Next: Individual vessel design documents for The Paladin, The Battle Wizard,
The Drifter, The Shaman, and The Ranger.*
