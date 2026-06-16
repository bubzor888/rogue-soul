# Soul Protocol — Enemies
## Version 0.2 · May 2026 · Solo Developer

> **Purpose:** Defines enemies for Soul Protocol — their stats, behaviours,
> omen contributions, and vulnerabilities. Currently covers Floor 3 (The
> Threshold) in detail. Other floors to be added as designed.
>
> Omen card mechanics are defined in `soul_protocol_omens.md`.
> Status effect values are defined in `soul_protocol_items.md`.
>
> Confirmed decisions are marked **`✓`**.
> Open questions are marked **`[OPEN]`**.

---

## Table of Contents

1. [Design Philosophy](#1-design-philosophy)
2. [Enemy Family System](#2-enemy-family-system)
3. [Encounter Structure](#3-encounter-structure)
4. [Damage Baseline](#4-damage-baseline)
5. [Floor 3 Enemies — The Threshold](#5-floor-3-enemies--the-threshold)
6. [Multi-Enemy Encounters](#6-multi-enemy-encounters)

---

## 1. Design Philosophy

Enemies serve three purposes simultaneously:

**Combat threat.** Each enemy has HP, attack damage, and a defining mechanic
that shapes how the player must approach it. Some enemies carry an elemental
vulnerability — a learnable piece of information that dramatically changes
combat efficiency. Others have no vulnerability at all; their mechanic is
behavioural rather than elemental. Not every enemy needs a vulnerability —
sometimes high damage vs low HP, pack dynamics, damage absorption, or
on-death effects are the interesting design, and adding a vulnerability on
top would dilute rather than enrich the encounter.

**Omen deck contributor.** Each enemy adds cards to the omen deck for the
duration of their combat. This means the deck composition — and therefore the
feel of the fight — changes based on which enemies are present. A fire enemy
makes fire omens more likely; an undead enemy makes self-healing omens more
likely. Multi-enemy encounters add multiple contributions, making those fights
more omen-dense and harder to predict.

**Family member.** Each Floor 3 enemy is the weakest version of a type that
scales across the game. The Skeleton here is fragile and predictable; a Bone
Warrior on a mid floor is the same creature with more HP, harder hits, and
additional omen contributions. The core identity — vulnerability, omen type,
combat behaviour — remains consistent across the family. Players who learn the
Skeleton's fire vulnerability on Floor 3 carry that knowledge forward.

---

## 2. Enemy Family System

Enemies are grouped into families. Each family shares a damage type, omen
identity, and vulnerability logic. Individual members within a family scale
in HP, damage, and omen contribution across floors.

**Floor 3 presents the entry tier of each family.** Later floors introduce
mid and high tiers of the same families alongside new ones, connecting vessel
archetypes to the enemy types they are designed to face.

| Family | Floor 3 members | Mid-floor members | Late-floor members |
|---|---|---|---|
| Undead | Skeleton, Zombie | Bone Warrior, Plague Zombie | Death Knight, Rot Colossus |
| Beast | Plague Rat, Wolf, Bear | TBD | TBD |
| Elemental | TBD | TBD | TBD |
| Fanatic | TBD | TBD | TBD |

Floor 3 contains **2 enemy types from each of the four tier-3 vessel origins**,
giving a roster of 8 enemy types. A single run encounters only a subset —
the pool is large enough that no two runs see identical enemy compositions.

> **`[OPEN]`** Elemental family (Battle Mage origin) and Fanatic family
> (Shaman origin) to be designed. Each contributes 2 enemy types to Floor 3.

---

## 3. Encounter Structure

> **✓ Decision: Encounter composition varies by enemy type. The general
> pattern is single pre-elite and double post-elite, but beast enemies follow
> different counts that suit their mechanics.**

| Phase | Rooms | Default encounter type | Beast exception |
|---|---|---|---|
| Opening | 1–3 | 1 enemy | 2 Wolves or 3 Plague Rats |
| Companion | 4 | Worn Map — no combat | — |
| Elite gate | 5 | Single elite enemy | — |
| Post-elite | 6–9 | 2 enemies | 3 Wolves or 1 Bear |
| Boss | — | The Judge | — |

**General structure rationale:** The pre-elite phase introduces enemies in
manageable numbers. The player learns what each enemy does, discovers
mechanics, and begins accumulating loot. Post-elite, encounter size increases —
a significant pressure spike that rewards the items and knowledge gathered.

**Beast exception rationale:** Wolves are always multi (their pack mechanic
requires it); Plague Rats are always a group of 3 (the escalating on-death
poison is only meaningful with multiple kills). The Bear is always solo both
pre and post-elite — its sleeping round and two-swipe mechanic are designed
around a single-enemy encounter.

**Swing between optimal and default play:** Each enemy type creates a large
gap between optimal play and default play. The player who understands the
mechanic (kill wolves fast to break the pack, kill Plague Rats before the
24-damage poison ticks, mitigate bear swipes) takes significantly less
damage than one who defaults to sequential attacks.

---

## 4. Damage Baseline

All damage values are set relative to the following baseline:

| Source | Damage per hit | Notes |
|---|---|---|
| **Throw Rock** (default strike) | 3 | Baseline — always available, no charges |
| **Walking Staff** (Pilgrim starting weapon) | 6 | First meaningful upgrade |
| **Normal drop weapons** | 7 | Clear step up from Staff |
| **Elite drop weapons** | 9 | Top tier with secondary properties |
| **Burst weapons** (Cracked Cudgel / Iron Maul) | 9 / 10 | High per hit, low charges |

Full weapon table in `soul_protocol_items.md` section 6.2.

---

## 5. Floor 3 Enemies — The Threshold

### Undead Family — Floor 3

The undead are souls that could not or would not pass through. They linger at
the Threshold — animated remains, rotting remnants, things that are wrong in
ways the player can feel before they understand why. Their presence in the
omen deck makes the battlefield more toxic in their specific ways.

**Shared undead property — Grave Knit:**
All undead enemies contribute one copy of the Grave Knit omen card to the deck.

> *Grave Knit — heals all undead units on the target side for 5 HP per tick.
> Does nothing when applied to the player (the player is not undead). Per-turn
> omen, clears at omen reset.*

The player who applies Grave Knit to themselves wastes their chosen card but
guarantees the enemy does not heal. The player who does not choose it risks
the random allocation sending it to the enemy side. In multi-undead encounters,
multiple copies of Grave Knit cycle through the deck — managing them becomes
a core omen skill.

Grave Knit heal at typical 2 ticks: **10 HP.** Against a 12 HP Skeleton this
is nearly a full HP bar restored. Against a 16 HP Zombie it is more than half.
It must be managed, not ignored.

---

#### Skeleton

> *The remains of someone who almost made it. The bones are still trying.*

**HP:** 12
**Attack:** 5 physical damage per turn

**Vulnerability:** Fire (×1.5 fire damage while Burning)

**Omen contributions:**

| Card | Copies | Effect |
|---|---|---|
| Emboldened (Physical) | 1 | Flat +2 to all physical damage on target side |
| Grave Knit | 1 | 5 HP healing to undead per tick |

**Combat identity:** Fast and aggressive. The Skeleton applies constant
physical pressure — the player cannot afford to let it hit freely. Its fire
vulnerability is the primary learnable — a Fire Bomb at typical (2 ticks)
deals 15 damage (5×1.5×2), one-shotting the 12 HP Skeleton entirely.

The Emboldened (Physical) omen card it contributes cuts both ways: steered
onto the player's side it boosts the player's physical weapons; allowed onto
the Skeleton's side it hits for 7 instead of 5.

**Kill targets:**

| Weapon | Turns to kill |
|---|---|
| Throw Rock (3) | 4 turns |
| Walking Staff (6) | 2 turns |
| Fire Bomb (2 ticks, ×1.5 fire vuln) | 1 turn — one-shot |

**Player survival:** Skeleton attacks for 5 per turn. Player has 24 HP.
Undefended, the player dies in ~5 turns. Against a Walking Staff kill time
of 2 turns, the player takes 10 damage — manageable. Against a Throw Rock
kill time of 4 turns, the player takes 20 damage — punishing.

> **`[OPEN]`** Skeleton name and visual to be confirmed during art direction.
> "Skeleton" is the design reference name.

---

#### Zombie

> *Something that should have dissolved. It didn't. It keeps moving because
> it doesn't know how to stop.*

**HP:** 16
**Attack:** 4 physical damage per turn

**Vulnerability:** Physical (×1.5 physical damage while Brittle Charm is
active or Vulnerable (Physical) omen is applied)

**Omen contributions:**

| Card | Copies | Effect |
|---|---|---|
| Grave Knit | 1 | 5 HP healing to undead per tick |

**Combat identity:** Slow and durable. The Zombie hits less often and for
less damage per hit than the Skeleton, but its high HP means it stays alive
long enough for Grave Knit to matter. The threat is attrition — the Zombie
outlasting the player's weapon charges while healing back the damage dealt.

Its physical vulnerability rewards the Brittle Charm setup. Walking Staff
with Brittle Charm deals 9 damage per hit — the Zombie falls in 2 hits
instead of 3, saving meaningful HP across the encounter.

Throw Rock cannot reliably beat a Zombie — 6 turns to kill (16/3=5.3→6)
while absorbing 4 damage per turn = 24 damage. The player has exactly 24 HP.
It is a punishing reminder to use the Walking Staff.

**Kill targets:**

| Weapon | Turns to kill |
|---|---|
| Throw Rock (3) | 6 turns — player at 0 HP |
| Walking Staff (6) | 3 turns — player takes 12 damage |
| Walking Staff + Brittle Charm (×1.5 = 9) | 2 turns — player takes 8 damage |

> **`[OPEN]`** Zombie name and visual to be confirmed during art direction.
> "Zombie" is the design reference name.

---

### Beast Family — Floor 3

Beasts are animals that have wandered into or been drawn to the Threshold.
They are not souls — they have no reason to be here and no understanding of
where they are. They are simply dangerous, behaving as animals do: in packs,
by instinct, with whatever weapons their bodies carry.

**Shared beast property — Thick Hide:**
All beast enemies contribute one copy of the Thick Hide omen card per enemy.

> *Thick Hide — all beasts on the target side absorb 3 damage per incoming
> hit for the omen cycle. Does nothing when applied to the player (the player
> does not have thick hide). Per-turn omen, clears at omen reset.*

Thick Hide is always safe to absorb on the player side. On the beast side it
dramatically changes the encounter — reducing damage dealt to each beast per
hit, breaking kill thresholds, and extending fights.

**Thick Hide creates different crises for each beast:**
- Against Plague Rats: Throw Rock (3 damage, 3-3=0 effective) can no longer
  kill in one hit. Charges must be spent on the weakest enemies on the floor.
- Against Wolves: Walking Staff (6-3=3 effective) no longer one-shots a 6 HP
  wolf. The pack stays active, damage spikes, and sequential killing becomes
  punishing.
- Against the Bear: already requires burst weapons — Thick Hide extends the
  fight by doubling or tripling effective HP, compounding the mitigation need.

In multi-beast encounters, multiple Thick Hide copies cycle frequently — the
player will almost certainly face the decision of whether to absorb it or risk
the combat shifting dramatically.

---

#### Plague Rat

> *Small, fast, wrong. There are three of them.*

**HP:** 3
**Attack:** 1 physical damage per turn (per rat — 3 total)
**Encounter:** 3 rats simultaneously — pre-elite

**On death:** Applies or advances the Poisoned individual omen on the player.

> *Each rat death adds 2 to the current Poisoned omen value. If no Poisoned
> omen is active, one starts at 2. The omen escalates normally — ticking its
> current value per turn, tripling after each tick.*

**Immune to:** Poisoned (their own venom does nothing to them)

**Omen contributions:**

| Card | Copies (total) | Effect |
|---|---|---|
| Thick Hide | 3 (1 per rat) | 3 absorption per hit to all beasts |

**Combat identity:** Three fragile creatures that barely threaten with their
attacks. The real danger is what happens when they die. Each death pushes the
Poisoned omen further — if the player cannot manage kill timing, the final
tick escalates to a value that kills them.

**The poison escalation (killing one per turn):**

| Event | Poison value | Damage to player |
|---|---|---|
| Rat 1 dies | Set to 2 | — |
| Poison ticks | Triples → 6 | 2 |
| Rat 2 dies | 6 + 2 → 8 | — |
| Poison ticks | Triples → 24 | 8 |
| Rat 3 dies | Fight ends, clears | 0 |

**Total poison damage: 10.** Plus 3 physical per turn from rat attacks —
negligible. The mechanic is entirely about kill timing and poison management.

If the player fails to kill rat 3 before the 24 tick: the player is almost
certainly dead (24 damage from a single tick against a likely-depleted HP bar).

**Kill targets (without Thick Hide):**

| Weapon | One-shots per rat? | Notes |
|---|---|---|
| Throw Rock (3) | Yes (3 = 3 HP) | Free — no charges burned |
| Walking Staff (6) | Yes | Overkill — charges wasted on 3 HP targets |
| Any weapon ≥3 | Yes | |

**Thick Hide interaction:**
With Thick Hide active (absorption 3), Throw Rock (3-3=0) does literally
nothing. Walking Staff (6-3=3) still kills in one hit. The player must spend
weapon charges to kill rats — burning resources on the floor's weakest enemies.
Every turn a rat survives is a turn the poison escalation continues.

**AoE note:** Rope Flail (4 damage per target) kills all 3 rats in 2 turns
without Thick Hide — 4 < 3 HP? No wait, 4 > 3 HP, Rope Flail one-shots all
three simultaneously. Fight ends turn 1, poison never builds. Spiked Chain (6)
also one-shots all three. AoE trivialises this encounter — intentionally. The
Pilgrim won't have AoE weapons pre-elite; other vessels may.

> **`[OPEN]`** Plague Rat visual to be confirmed during art direction.

---

#### Wolf

> *Pack hunters. They are not lost. They are waiting.*

**HP:** 6
**Attack:** 3 (lone) / 5 (pack — 2 or more wolves alive) physical damage per turn
**Encounter:** 2 wolves pre-elite, 3 wolves post-elite

**No vulnerability.**

**Omen contributions:**

| Card | Copies | Effect |
|---|---|---|
| Thick Hide | 1 per wolf | 3 absorption per hit to all beasts |

**Combat identity:** The mechanic is kill-speed vs pack damage. Wolves are
fragile — any weapon that does ≥6 damage one-shots them. The pack bonus is
binary: 2 or more wolves alive means each deals 5 damage per turn; the
last surviving wolf drops to 3. Killing one wolf fast breaks the pack
immediately.

Throw Rock (3 damage) cannot one-shot a wolf (3 < 6 HP). The pack bonus
stays active, combined damage stays high, and the encounter becomes brutal.
Walking Staff (6) exactly one-shots — the threshold is precise and legible.

**Player attacks first.** If a wolf is killed on the player's action, it does
not attack that turn. Only surviving wolves retaliate.

**Kill targets — 2 wolves (pre-elite):**

| Approach | Damage taken | Notes |
|---|---|---|
| Walking Staff — kill A turn 1, B turn 2 | 3 (lone B attacks) | B drops to lone wolf (3) after A dies |
| Throw Rock — 2 turns per wolf | ~16 | Can't one-shot, pack stays active |

**Kill targets — 3 wolves (post-elite):**

| Approach | Damage taken | Notes |
|---|---|---|
| Walking Staff — kill one per turn | 13 (10+3) | A dies turn 1, B dies turn 2, C dies turn 3 |
| Throw Rock — 2 turns per wolf | Player dead by turn 2 | Pack damage (15/turn) with slow kills |
| Rope Flail (4/wolf) — 2 turns | 15 | All at 2 HP after turn 1, killed turn 2 |
| Spiked Chain (6/wolf) — 1 turn | 0 | One-shots all three simultaneously |

**Thick Hide interaction:**
Thick Hide (absorption 3) means Walking Staff (6-3=3 effective) no longer
one-shots a 6 HP wolf. The wolf survives at 3 HP. The pack stays intact for
another turn. With 3 wolves, Thick Hide landing on the wolf side while all are
alive means 15 damage per turn and no clean kills — a crisis.

> **`[OPEN]`** Wolf visual to be confirmed during art direction.

---

#### Bear

> *It was sleeping. It is not anymore.*

**HP:** 22
**Attack:** Two swipes — 4 damage each (8 total per turn)
**Encounter:** 1 bear — post-elite only
**No vulnerability.**

**Sleeping — Round 1:** The bear is asleep when the encounter begins. The
player takes their action freely — attack, apply a consumable, or set up a
defensive omen — and the bear does not act. It wakes at the start of round 2.

**Omen contributions:**

| Card | Copies | Effect |
|---|---|---|
| Thick Hide | 1 | 3 absorption per hit to all beasts |

**Combat identity:** High HP, two swipes per turn making mitigation almost
necessary, and a free round that rewards deliberate setup. The bear does not
have a vulnerability — its design is purely mechanical. Burst damage and
defensive items determine the outcome.

The two-swipe mechanic specifically rewards per-turn damage reduction.
Hardened (absorbs 3 total per tick) reduces 8 incoming to 5. Chilled (damage
reduction percentage) applies to both swipes. Thick Hide on the bear's side
makes each swipe hit for 3 less effective damage — critically extending the
fight.

Without mitigation, Walking Staff (6/hit) against 22 HP:
- Free round: 6 damage (bear at 16)
- Turns 2–4: 3 hits, takes 24 damage. Player at 0 exactly — dead.

With Hardened applied on the free round (5 damage taken per turn instead of 8):
- Turns 2–4: 3 hits, takes 15 damage. Player at 9. Survives.

The free round decision is meaningful: attack (damage the bear immediately) or
set up (Hardened, Brittle Charm, or Poultice for sustained survivability).

**Kill targets (Walking Staff, no setup):**

| Approach | Turns | Player HP remaining |
|---|---|---|
| Walking Staff only | 4 active turns | 0 — exactly dead |
| Free round attack + Hardened turn 2 | 4 turns | ~6 |
| Free round Brittle Charm + Walking Staff (×1.5=9) | 3 turns | ~6 |
| Free round Hardened + Brittle Charm turn 2 + Walking Staff | 3 turns | ~11 |

**Thick Hide interaction:**
Thick Hide on the bear's side reduces Walking Staff effectiveness from 6 to 3
per hit. Now needs 8 hits to kill — player takes 56 damage. Impossible.
Absorbing Thick Hide is not optional when fighting the bear.

> **`[OPEN]`** Bear visual to be confirmed during art direction.

---

### Elemental Family — Floor 3

Elementals are not souls and not animals. They are concentrations of elemental
energy that have drifted into or been drawn to the Threshold — fire that moves
with purpose, ice that chooses where to settle, lightning that has learned to
hunt. They have no reason to be here except that the Threshold is thin and the
boundary between the material world and something rawer has worn through in places.

**Shared elemental property — Elemental Synergy:**
All elemental enemies contribute one copy of the Elemental Synergy omen card to
the deck.

> *Elemental Synergy — all attacks from the target side deal damage of the
> elemental's type for the omen cycle.*

This inverts the Grave Knit and Thick Hide pattern:
- Applied to **elemental side:** elementals already deal their type — no change.
  Safe for the player to play here.
- Applied to **player side:** all the player's attacks convert to the elemental's
  damage type. The elemental resists that type (×0.5). The player's weapons lose
  half their effectiveness — and any vulnerability advantage (ice weapons against
  a fire elemental's ×1.5) flips entirely to a resistance penalty.

The player's chosen card can direct Elemental Synergy safely onto the enemy side,
neutralising it. But this costs the player their omen choice — they cannot play
an offensive card that cycle, contending with Burning, Emboldened, or other
options they might otherwise steer toward the enemy.

**Elemental resistances:**

| Elemental | Resistance | Vulnerability |
|---|---|---|
| Fire Elemental | Fire ×0.5 | Ice ×1.5 |
| Ice Elemental | Ice ×0.5 | Fire ×1.5 |
| Lightning Elemental | Lightning ×0.5 | None |

**Encounter structure:**

| Phase | Encounter |
|---|---|
| Pre-elite | 1 Fire Elemental OR 1 Ice Elemental |
| Post-elite | 2 Fire Elementals, 2 Ice Elementals, OR 1 Lightning Elemental |

Fire and Ice appear in pairs post-elite, rewarding having the opposing element
ready. Lightning is the solo post-elite encounter — stronger, no vulnerability,
and a unique two-phase mechanic.

---

#### Fire Elemental

> *It is not burning anything. It simply is fire. It notices the player
> in the way fire notices fuel.*

**HP:** 14
**Attack:** 5 fire damage per turn
**Resistance:** Fire ×0.5
**Vulnerability:** Ice ×1.5 (from Chilled status)

**Omen contributions:**

| Card | Copies | Effect |
|---|---|---|
| Elemental Synergy | 1 | Converts all attacks on target side to fire damage |
| Burning | 1 | Applies Burning to all units on target side |

The Burning card it contributes can land on the player side through random
omen placement. A Burning player is Vulnerable (Fire) ×1.5 — the Fire
Elemental's own fire attacks then deal 5×1.5 = 7.5 damage per turn to that
player. Its omen contribution actively benefits its attacks.

**Kill targets:**

| Weapon | Turns to kill | Notes |
|---|---|---|
| Throw Rock (3, physical) | 5 turns | No resistance to physical — just slow |
| Walking Staff (6, physical) | 3 turns | Clean physical kill |
| Glacial Brand (9 ice, ×1.5 vuln = 14) | 1 turn | One-shot with ice vulnerability active |
| Fire weapon (e.g. Ember Shard, ×0.5) | 5 turns effective | Half damage — avoid |

**Elemental Synergy against Fire Elemental:**
Converts player's Glacial Brand hits to fire. Now: 9×0.5 = 4.5 per hit (resistance).
The optimal weapon becomes the worst weapon until Synergy is cleared.

> **`[OPEN]`** Fire Elemental visual to be confirmed during art direction.

---

#### Ice Elemental

> *Still. Patient. The cold doesn't radiate from it so much as everything
> else begins to match it.*

**HP:** 14
**Attack:** 4 ice damage per turn + applies Chilled to player on hit
**Resistance:** Ice ×0.5
**Vulnerability:** Fire ×1.5 (from Burning status)

**Omen contributions:**

| Card | Copies | Effect |
|---|---|---|
| Elemental Synergy | 1 | Converts all attacks on target side to ice damage |
| Chilled | 1 | Applies Chilled to all units on target side |

The Ice Elemental applies Chilled directly on its attack — not through omen
draws. Each hit: player takes ice damage, gains Chilled (damage reduction
creeping per tick, Vulnerable Ice). The Ice Elemental's ice attacks then
benefit from the player's Vulnerable Ice (×1.5). Its own attack creates the
vulnerability it then exploits.

The Chilled damage reduction is the defensive complication — a Chilled player
deals less damage each turn, extending the fight even as the Ice Elemental
hits harder.

**Kill targets:**

| Weapon | Turns to kill | Notes |
|---|---|---|
| Walking Staff (6, physical) | 3 turns | Not affected by Chilled damage reduction (Ice Elemental resists ice, not physical) |
| Smoldering Brand (9 fire, ×1.5 vuln = 14) | 1 turn | One-shot while fire vulnerability active |
| Ice weapon (×0.5 resistance) | 5 turns effective | Avoid |

**Elemental Synergy against Ice Elemental:**
Player's Smoldering Brand (fire, optimal weapon) becomes ice. Now: 9×0.5 = 4.5.
Optimal weapon loses ×1.5 advantage and gains a ×0.5 penalty in the same swap.

> **`[OPEN]`** Ice Elemental visual to be confirmed during art direction.

---

#### Lightning Elemental

> *It is not one thing. It is the space between things, moving too fast to
> catch, hitting before the player knows it moved.*

**HP:** 18 (Phase 1) + 6 + 6 (Phase 2 Sparks)
**Attack:** 6 lightning per turn (Phase 1) / 2 lightning each (Phase 2, 4 total)
**Resistance:** Lightning ×0.5 (both phases)
**Vulnerability:** None

**Two-phase encounter:**

> **✓ Decision: The Lightning Elemental is a two-phase encounter.**
>
> When the Lightning Elemental reaches 0 HP, it does not end the combat. It
> splits into two Sparks. The turn it dies is a dead turn for the enemy side
> — no attack, just the transition. From the following turn, both Sparks are
> active.

**Phase 1 — Lightning Elemental:**
Standard combat against a single hard-hitting elemental. No vulnerability means
there is no optimal element to exploit — the player chips through with physical
damage or whatever non-lightning elemental weapons they carry.

**Phase 2 — Two Sparks:**
Lower HP, lower damage per spark. The combat continues with whatever charges,
consumables, and HP the player has remaining. Omens active at the moment of
transition continue counting down normally — no reset, no new cards from the
Sparks.

**Omen contributions (Phase 1 only):**

| Card | Copies | Effect |
|---|---|---|
| Elemental Synergy | 1 | Converts all attacks on target side to lightning |
| Shocked | 1 | Applies Shocked to all units on target side |

Sparks contribute no new omen cards. The Phase 1 deck persists through Phase 2
until the next omen reset.

**The weapon choice dilemma:**

The player must manage resources across both phases in a single continuous
encounter. Over-investing in Phase 1 leaves too little for Phase 2. Holding
AoE weapons for Phase 2 extends Phase 1.

| Approach | Phase 1 | Dead turn | Phase 2 | Total damage | HP remaining |
|---|---|---|---|---|---|
| Walking Staff both phases | 12 (2 turns) | 0 | 6 (2 turns) | 18 | 6 — barely alive |
| Walking Staff + Spiked Chain for P2 | 12 | 0 | 0 (1 turn) | 12 | 12 |
| Cracked Cudgel P1 + Spiked Chain P2 | 6 (1 turn) | 0 | 0 (1 turn) | 6 | 18 |
| Throw Rock both | 18 (3 turns) | 0 | 16+ | 34+ | Dead |

**Kill targets — Phase 1:**

| Weapon | Turns to kill | Notes |
|---|---|---|
| Throw Rock (3) | 6 turns — player likely dead | 3×0.5=1.5 effective, rounds to 1.5 |
| Walking Staff (6) | 3 turns (6/turn, 18 HP) | Clean but slow |
| Cracked Cudgel (9) | 2 turns (9×2=18) | Efficient — saves a turn of damage |
| Lightning weapon (×0.5) | 6 turns effective | Avoid |

**Kill targets — Phase 2 (Sparks, 6 HP each):**

| Weapon | Result | Notes |
|---|---|---|
| Walking Staff (6) | One-shots each (6 = 6 HP) | 2 turns, takes 4+2 = 6 damage |
| Rope Flail (4/target) | 2 turns to kill each (4 < 6) | Both survive first hit, take 4+4 damage |
| Spiked Chain (6/target) | One-shots both simultaneously | 0 turns of spark damage taken |
| Lightning weapon (×0.5 = 3-4.5 eff.) | 2 turns per spark minimum | Below kill threshold |

> **`[OPEN]`** Lightning Elemental and Spark visuals to be confirmed during
> art direction.

---

---

### Fanatic Family — Floor 3

The Fanatics are the only human-like enemies on Floor 3. They are not souls
in transition and not elemental forces — they are living people who have
committed to something beyond reason. Whether they are crazed members of the
Shaman's own tribe or rival cultists, they move with human purpose and human
desperation. They hurt because they mean to.

The Fanatic family is defined by its Spirit Totems — passive support entities
that buff their allies through permanent auras. No other enemy family has a
dedicated support unit. The Fanatics themselves are simple direct attackers;
their threat comes entirely from the Totem making them harder to fight.

**There is no shared family omen contributed by all members.** Instead, Fanatics
individually contribute Sacred Ground, and Totems contribute nothing to the
omen deck — their impact is delivered through always-on passive auras.

---

#### Sacred Ground *(Fanatic-only omen card)*

> *Sacred Ground — increases the effect of all active Totem auras on the
> target side for this omen cycle.*

Applied to **Fanatic/Totem side:** all Totem aura effects are doubled this
cycle. Buff Totem gives +4 instead of +2. Absorption Totem gives 6 absorption
instead of 3.

Applied to **player side:** does nothing. The player has no Totem auras.
Always safe to absorb.

> **✓ Decision: Sacred Ground is contributed by Fanatics only — not Totems.**

**In deck:**
- Pre-elite (1 Fanatic + 1 Totem): 1 Sacred Ground card
- Post-elite (2 Fanatics + 1 Totem): 2 Sacred Ground cards

**Critical interaction:** When the Totem is killed, Sacred Ground becomes
completely inert — it has no aura to double and does nothing on the player
side. Killing the Totem neutralises both the aura threat and all future Sacred
Ground draws simultaneously.

**Sacred Ground + Absorption Totem (doubled):** 6 absorption per hit.
Walking Staff (6 - 6 = 0 effective). Fanatics become temporarily unkillable
with the Walking Staff. Elite weapons (9 - 6 = 3 effective) still function.

---

#### Low HP Fanatic

> *Fast. Committed. It is not thinking about what happens after.*

**HP:** 8
**Attack:** 4 physical damage per turn
**No vulnerability. No special mechanic.**

**Omen contribution:** Sacred Ground ×1

**Combat identity:** Hits hard for its durability. A quick kill — 2 Walking
Staff hits — but each turn it survives it deals meaningful damage. Often the
correct first kill target, especially when paired with an Absorption Totem
where weapon charges are precious.

**Kill targets:**

| Weapon | Turns to kill | Damage taken |
|---|---|---|
| Throw Rock (3) | 3 turns | 8 (two attacks before killed) |
| Walking Staff (6) | 2 turns | 4 (one attack before killed) |
| Any weapon ≥8 | 1 turn | 0 (killed before it attacks) |

> **`[OPEN]`** Low HP Fanatic visual and name to be confirmed during art direction.

---

#### High HP Fanatic

> *Unmoved. It has been waiting here longer than it should have.*

**HP:** 12
**Attack:** 3 physical damage per turn
**No vulnerability. No special mechanic.**

**Omen contribution:** Sacred Ground ×1

**Combat identity:** Durable but modest threat per turn. The damage dealt while
chipping through 12 HP is significant — particularly when an Absorption Totem
is active, making each hit less effective. Removing the Totem before engaging
this Fanatic is usually the more efficient path.

**Kill targets:**

| Weapon | Turns to kill | Damage taken |
|---|---|---|
| Throw Rock (3) | 4 turns | 9 (three attacks before killed) |
| Walking Staff (6) | 2 turns | 3 (one attack before killed) |
| With Absorption Totem (3 absorbed) | 4+ turns | 9+ (absorption slows kill significantly) |

> **`[OPEN]`** High HP Fanatic visual and name to be confirmed during art direction.

---

#### Buff Totem

> *A carved post driven into the ground. Something is still listening through
> it.*

**HP:** 6
**Attack:** None
**Aura (always-on):** All Fanatics on this side deal +2 damage per turn.
**Omen contribution:** None

**The Totem does not benefit from its own aura.** It takes full damage from
all sources. Walking Staff one-shots it (6 = 6 HP) — kill priority is clear.

**Effect while alive:**

| Fanatic | Normal damage | With Buff Totem |
|---|---|---|
| Low HP Fanatic | 4 | 6 |
| High HP Fanatic | 3 | 5 |

**Sacred Ground + Buff Totem:** all Fanatics deal +4 instead of +2 for the
cycle. Two Fanatics post-elite deal 8+8=16 combined per turn — lethal within
2 turns.

**Kill priority:** Almost always kill the Totem first when paired with High HP
Fanatics. When paired with a Low HP Fanatic (pre-elite), killing the Fanatic
first is marginally better — the buff is less significant with only one
attacker, and the Totem dies in one hit anyway immediately after.

> **`[OPEN]`** Buff Totem visual and name to be confirmed during art direction.

---

#### Absorption Totem

> *The carvings on it are wrong. Wounds heal faster near it. Not completely.
> Just faster.*

**HP:** 10
**Attack:** None
**Aura (always-on):** All Fanatics on this side absorb 3 damage per hit.
**Omen contribution:** None

**The Totem does not benefit from its own aura.** Fanatic absorption does not
apply to the Totem itself. Walking Staff kills it in 2 hits (6+4=10) — the
Totem takes full damage normally.

**Effect while alive:**

| Weapon | Normal vs Fanatic | With Absorption Totem |
|---|---|---|
| Throw Rock (3) | 3 damage | 0 damage — useless |
| Walking Staff (6) | 6 damage | 3 damage |
| Normal drops (7) | 7 damage | 4 damage |
| Elite drops (9) | 9 damage | 6 damage |

**Sacred Ground + Absorption Totem:** absorption doubles to 6 per hit. Walking
Staff (6 - 6 = 0) is completely useless that cycle. Elite weapons (9 - 6 = 3)
and burst weapons (10 - 6 = 4) still function.

**Kill priority:** Kill Totem first in almost all cases. The absorption makes
fights with High HP Fanatics especially long — removing it is the most
efficient path. Even with Low HP Fanatics, the absorption wastes weapon
charges on what should be fast kills.

> **`[OPEN]`** Absorption Totem visual and name to be confirmed during art direction.

---

**Kill priority summary across all combinations:**

| Fanatic type | Totem type | Kill first | Reasoning |
|---|---|---|---|
| Low HP (8 HP) | Buff Totem | Fanatic (marginally) | Quick kill, Totem is 1 hit after |
| Low HP (8 HP) | Absorption | Fanatic | Quick kill preserves charges better |
| High HP (12 HP) | Buff Totem | Totem | Buff makes 3-turn kill more expensive |
| High HP (12 HP) | Absorption | Totem | Absorption makes 4+ turn kill much worse |
| Mixed post-elite | Either | Situational | Low HP Fanatic may be a fast turn-1 clear before addressing Totem |

---

**Encounter structure:**

| Phase | Composition |
|---|---|
| Pre-elite | 1 Fanatic (Low HP or High HP) + 1 Totem (Buff or Absorption) |
| Post-elite | 2 Fanatics (any combo) + 1 Totem (Buff or Absorption) |

Post-elite Fanatic combinations: 2 Low HP, 2 High HP, or 1 of each. Combined
with either Totem type — 6 possible post-elite encounter configurations, none
of which play identically.

---

### The Judge

> **`[OPEN]`** The Judge to be designed in a dedicated session. See
> `soul_protocol_floor_encounter_design.md` section 7 for design constraints.

---

## 6. Multi-Enemy Encounters

Post-elite encounters feature increased enemy counts. Their omen contributions
both enter the deck for that combat. Beast and elemental exceptions follow
their own count rules (see Section 3).

**Omen deck size estimates:**

| Enemy combination | Enemy omen cards | Est. total deck |
|---|---|---|
| Two Skeletons | Emboldened (Phys) ×2, Grave Knit ×2 | ~18–20 |
| Two Zombies | Grave Knit ×2 | ~16–18 |
| Skeleton + Zombie | Emboldened (Phys) ×1, Grave Knit ×2 | ~17–19 |
| Three Wolves | Thick Hide ×3 | ~17–19 |
| One Bear | Thick Hide ×1 | ~13–15 |
| Two Fire Elementals | Elemental Synergy ×2, Burning ×2 | ~18–20 |
| Two Ice Elementals | Elemental Synergy ×2, Chilled ×2 | ~18–20 |
| One Lightning Elemental | Elemental Synergy ×1, Shocked ×1 | ~14–16 |
| 2 Fanatics + Buff Totem | Sacred Ground ×2 | ~14–16 |
| 2 Fanatics + Absorption Totem | Sacred Ground ×2 | ~14–16 |

**Combined incoming damage:**

| Encounter | Damage per turn | Notes |
|---|---|---|
| Two Skeletons | 10 (5+5) | — |
| Two Zombies | 8 (4+4) | — |
| Skeleton + Zombie | 9 (5+4) | — |
| Three Wolves (pack) | 15 (5×3) | Drops 10→3 as wolves die |
| One Bear | 8 (4+4 swipes) | Round 1 free |
| Two Fire Elementals | 10 (5+5) | Ice weapons optimal (×1.5) |
| Two Ice Elementals | 8 (4+4) + Chilled per hit | Fire weapons optimal (×1.5) |
| One Lightning (Phase 1) | 6 | → 4 in Phase 2 (2+2 from Sparks) |
| 2 Low HP + Buff Totem | 12 (6+6 buffed) | Totem removal drops to 8 |
| 2 High HP + Buff Totem | 10 (5+5 buffed) | Totem removal drops to 6 |
| 2 Low HP + Absorption | 8 (4+4) | Absorption halves weapon efficiency |
| 2 High HP + Absorption | 6 (3+3) | Long fight, Totem removal critical |
| 1 Low + 1 High + Totem | 7–11 (varies) | Kill order most ambiguous combination |

**Priority kill logic:**
- Undead: kill the higher-damage threat first; manage Grave Knit draws throughout
- Three Wolves: kill one per turn with Walking Staff — pack drops after second
  kill. Spiked Chain one-shots all three simultaneously.
- Two Elementals: focus one down fast using the opposing element; manage
  Elemental Synergy draws to prevent attack-type conversion
- Lightning Elemental: manage resources across both phases — hold AoE for the
  Spark phase; use burst weapons to shorten Phase 1
- Fanatics + Totem: kill the Totem first in most cases — neutralises the aura
  and makes all Sacred Ground draws inert. Exception: Low HP Fanatic + Buff
  Totem pre-elite, where killing the Fanatic first is marginally better

> **`[OPEN]`** Cross-family encounter combinations (Skeleton + Wolf, Zombie
> + Elemental, etc.) to be defined once full roster is confirmed.

---

*Soul Protocol — Enemies v0.4*
*Companion to soul_protocol_game_design.md, soul_protocol_items.md, and
soul_protocol_omens.md.*
*v0.1: Design philosophy, undead family, damage baseline, encounter structure,
multi-enemy framework.*
*v0.2: Beast family — Plague Rat, Wolf, Bear. Thick Hide. Encounter structure
updated for beast exceptions. Design philosophy updated on vulnerabilities.*
*v0.3: Elemental family — Fire Elemental, Ice Elemental, Lightning Elemental
(two-phase with Sparks). Elemental Synergy documented.*
*v0.4: Fanatic family — Low HP Fanatic (8 HP, 4 damage), High HP Fanatic
(12 HP, 3 damage), Buff Totem (6 HP, +2 damage aura), Absorption Totem
(10 HP, 3 absorption aura). Sacred Ground omen — Fanatics only, doubles
Totem aura, inert once Totem is dead. 6 possible post-elite configurations.
Kill priority matrix documented across all Fanatic combinations.*
