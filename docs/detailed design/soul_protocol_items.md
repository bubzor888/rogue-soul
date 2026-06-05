# Soul Protocol — Items
## Version 0.6 · May 2026 · Solo Developer

> **Purpose:** Defines item system rules and the item catalogue for Soul Protocol.
> Currently covers Floor 3 (The Threshold). Expanding with each design session.
>
> Item flags, action buckets, and inventory rules are defined in
> `soul_protocol_game_design.md` sections 1, 3.4, and 3.5.
>
> Enemy HP and combat math referenced from `soul_protocol_enemies.md`.
>
> Confirmed decisions are marked **`✓`**.
> Open questions are marked **`[OPEN]`**.

---

## Table of Contents

1. [Item System Rules](#1-item-system-rules)
2. [Damage Types](#2-damage-types)
3. [Status Effects](#3-status-effects)
4. [Post-Combat Loot](#4-post-combat-loot)
5. [Durability System](#5-durability-system)
6. [Floor 3 Items — The Threshold](#6-floor-3-items--the-threshold)

---

## 1. Item System Rules

Items are the primary resource the player manages across a run. They are acquired
through post-combat loot, non-combat events, and vessel-specific mechanics (such
as the Ferret's Scavenge passive).

Each item belongs to one of three functional categories:

| Category | Action bucket | Limiting factor |
|---|---|---|
| **Attack (Durability)** | Attack — occupies the attack action | Charge count; breaks at zero |
| **Support (Durability)** | Support — free, does not consume attack | Charge count; breaks at zero |
| **Consumable** | Consumable — free, does not consume attack | Single use |

---

## 2. Damage Types

All damage in Soul Protocol has a type. Enemies and the player may carry
resistances or vulnerabilities to specific types. Damage types are noted on
all items and abilities.

A damage type is independent of its delivery mechanism. Fire damage can come
from a DoT status omen, a spell, a weapon, or any other source — the type
describes what it is, not how it arrives.

**Confirmed damage types:**

| Type | Notes |
|---|---|
| **Physical** | Weapons, default strike. No DoT component. Vulnerability applied via items only — no intrinsic status grants it. |
| **Fire** | Elemental. Intrinsic vulnerability: having the Burning status grants Vulnerable (Fire). |
| **Lightning** | Elemental. Intrinsic vulnerability: having the Shocked status grants Vulnerable (Lightning). |
| **Ice** | Elemental. Intrinsic vulnerability: having the Chilled status grants Vulnerable (Ice). |
| **Poison** | Elemental. **No vulnerability** — excluded intentionally. Too powerful combined with escalating DoT. |

> **`[OPEN]`** Additional elemental damage types to be added as other floors
> and tier 3 vessels (Battle Wizard, Shaman) are designed.

> **`[OPEN]`** Resistance values to be set during enemy design.

---

## 3. Status Effects

Status effects are applied as **individual omens** on a specific target —
an omen card attached to that unit on top of the overall omen pool.
They clear at the next omen reset. Duration is determined by the timer card
drawn that cycle (1–3 turns).

All elemental statuses exist in two expressions: a **single-target consumable
item** and a **whole-side omen card**. The two sources do not stack their
vulnerability on the same target — still ×1.5, not ×2.25.

> See `soul_protocol_omens.md` for full omen cycle mechanics.

**Two classes of individual omen:**

| Class | Behaviour |
|---|---|
| **Per-turn** | Ticks every turn while active. Clears at omen reset. |
| **Omen-triggered** | Does nothing on intermediate turns. Fires once at the omen shift, just before omens are discarded. |

### Balancing assumption

> **When balancing all per-tick effects, assume 2 ticks as the typical case.**
> 1 tick is the unlucky floor, 3 ticks is the lucky ceiling. Design values
> should feel meaningful at 2 — not wasted at 1, not broken at 3.

---

### 3.1 Elemental Statuses

Each elemental status grants **intrinsic vulnerability** to its damage type
(×1.5) in addition to its primary effect. Poison is the exception — no
vulnerability, its escalating DoT is strong enough alone.

---

#### Burning *(Fire · Per-turn · Offensive)*

Applied to a target. Deals flat fire damage each tick. While active the target
is also **Vulnerable (Fire) ×1.5** — all fire damage dealt to them is amplified.

| Timer card | Tick sequence | Total fire damage |
|---|---|---|
| 1 tick | 5 | 5 |
| 2 ticks | 5 → 5 | 10 |
| 3 ticks | 5 → 5 → 5 | 15 |

**Typical (2 ticks): 10 damage.**
**Against Skeleton (fire vulnerable, 12 HP): 10×1.5 = 15 damage — one-shot at typical.**

When applied to the player by an unlucky omen draw: player takes fire DoT
each tick and is Vulnerable (Fire). Cleared by Ointment.

> **`[OPEN]`** Tick value (first pass: 5) confirmed against Skeleton HP.
> Review if other enemies require adjustment.

---

#### Shocked *(Lightning · Omen-triggered · Offensive)*

Applied to a target. Does nothing on intermediate turns. While active the
target is **Vulnerable (Lightning) ×1.5**. At the omen shift: target skips
their next action.

> **✓ Decision: Stunned as a standalone status is removed. The stun mechanic
> now belongs entirely to Shocked (lightning).**

Low timer cards are valuable when Shocked is active — faster stun payoff,
inverting the usual preference for high timer cards.

When applied to the player: player is Vulnerable (Lightning) and will be
stunned at the shift. Cleared by Amethyst.

---

#### Chilled *(Ice · Per-turn · Offensive/Defensive)*

Applied to a target. Reduces their damage output by a creeping percentage each
tick — starts small and grows but **never reaches zero**. While active the
target is also **Vulnerable (Ice) ×1.5**.

| Timer card | Damage reduction per tick |
|---|---|
| 1 tick | 10% |
| 2 ticks | 10% → 20% |
| 3 ticks | 10% → 20% → 30% |

**Typical (2 ticks):** target deals 10% less first tick, 20% less second tick.

When applied to the player: player deals reduced damage and is Vulnerable (Ice).
Cleared by Amethyst.

> **`[OPEN]`** Reduction values (first pass: 10%/20%/30%) to be confirmed
> once enemy damage output is fully established.

---

#### Poisoned *(Poison · Per-turn · Offensive)*

Applied to a target. Deals escalating poison damage each tick. No vulnerability
granted — the escalating ceiling is strong enough alone.

| Timer card | Tick sequence | Total poison damage |
|---|---|---|
| 1 tick | 2 | 2 |
| 2 ticks | 2 → 6 | 8 |
| 3 ticks | 2 → 6 → 18 | 26 |

**Typical (2 ticks): 8 damage.** Rewards timing the application after a high
timer card is confirmed via Read the Road.

> **`[OPEN]`** Tick values (first pass: 2/6/18) to be reviewed once more
> enemy HP pools are established.

---

### 3.2 Recovery Statuses *(Per-turn · Defensive)*

Applied to the player.

---

#### Mending

Heals 3 HP per tick. Flat and reliable.

| Timer card | Total healed |
|---|---|
| 1 tick | 3 |
| 2 ticks | 6 |
| 3 ticks | 9 |

**Typical (2 ticks): 6 HP restored.**

---

#### Hardened

Absorbs up to 3 incoming damage per tick. Resets to full at the start of each
new tick. Against multiple hits in one turn absorbs up to its value then the
player takes the remainder.

| Timer card | Max absorbed |
|---|---|
| 1 tick | 3 |
| 2 ticks | 6 |
| 3 ticks | 9 |

**Typical (2 ticks): up to 6 absorbed.**

---

### 3.3 Vulnerability

Amplifies all damage of a specific type dealt to the affected target by ×1.5.

| Vulnerable type | How applied |
|---|---|
| Vulnerable (Physical) | Brittle Charm consumable only — no intrinsic status grants it |
| Vulnerable (Fire) | Intrinsic to Burning status; also via Combustible Oil if not already Burning |
| Vulnerable (Lightning) | Intrinsic to Shocked status |
| Vulnerable (Ice) | Intrinsic to Chilled status |

Two sources of the same vulnerability on one target do not stack — still ×1.5.

> **✓ Decision: Vulnerability multiplier is ×1.5 for all types.**

---

### 3.4 Cleanse

| Item | Clears | Notes |
|---|---|---|
| **Ointment** | Burning, Poisoned | Physical/chemical DoTs. Consumable. |
| **Amethyst** | Shocked, Chilled, Vulnerable (Physical) | Elemental and spiritual debuffs. Support — durability 1/2/3. |

---

### 3.5 Omen Deck Effects

Each elemental status has a whole-side omen card expression that mirrors its
single-target consumable. Damage values for omen card versions may differ
slightly. Full omen deck design in `soul_protocol_omens.md`.

**Confirmed omen deck candidates:** Burning (whole side), Shocked (whole side),
Chilled (whole side), Emboldened (Physical), Emboldened (Elemental ×3).

---

## 4. Post-Combat Loot

Every completed combat encounter presents the player with a **loot choice**
between two fully revealed options:

| Option A | Option B |
|---|---|
| One durability item from the floor's durability pool | One consumable from the floor's consumable pool |

The player takes one. The other is lost.

> **✓ Decision: Post-combat loot is a choice between one durability item or one
> consumable — not both.**

On a standard Floor 3 Pilgrim run this yields **5 loot choices** (4 standard
combats + 1 elite) before the Judge.

---

## 5. Durability System

### 5.1 Per-Use Decrement

Durability items decrement by 1 charge each time they are used. A weapon used
twice in a single combat loses 2 charges. A weapon unused in a combat loses
no charges.

> **✓ Decision: Durability decrements per use, not per combat.**

### 5.2 Charge Philosophy

Weapon charge counts are set to ensure weapons provide meaningful use across
**2–3 combats** before requiring replacement or recharge.

**Interaction with Good as New (Pilgrim active ability):** Resets one durability
item to maximum charges. Valid targets include weapons, support items, and
Amethysts — a genuine strategic decision rather than an automatic weapon refill.

---

## 6. Floor 3 Items — The Threshold

### 6.1 Starting Items — The Pilgrim

---

#### Walking Staff *(Attack — Durability · Physical)*

> *"Worn smooth at the grip. He has carried it so long he no longer notices
> the weight."*

**Effect:** Deals physical damage to a single target.
**Damage: 6.** **Charges:** 6. Per-use decrement.

Sits between Throw Rock (default strike, 3 damage) and normal drop weapons
(7 damage). Meaningfully better than the default; clearly inferior to most
drops. Expected to exhaust mid-floor.

**Kill reference:**
- Skeleton (12 HP): 2 hits
- Zombie (16 HP): 3 hits

---

#### Spoiled Potion *(Consumable — Single Use · Poison)*

> *"It was supposed to be something else. He has been carrying it too long.
> He is not sure what it is now, but it does something."*

**Effect:** Applies Poisoned to one enemy.

| Timer card | Tick sequence | Total |
|---|---|---|
| 1 tick | 2 | 2 |
| 2 ticks | 2 → 6 | 8 |
| 3 ticks | 2 → 6 → 18 | 26 |

**Typical (2 ticks): 8 damage.**

---

#### Worn Map *(Non-Combat — Encounter Countdown)*

> *"There is a mark on it. He has no memory of making it, or of what it meant.
> But the mark is there, and some part of him still believes in it."*

**Effect:** Counts down across encounters. After 3 encounters, replaces the next
room slot with a temporary companion encounter. Removed from inventory after
triggering. Counter = 3, decrements on every encounter type. Triggers on room 4.

---

### 6.2 Drop Pool — Durability Items

Drop weapons are designed to be cross-vessel. Pool size target: large enough
that a single run will not see every item.

Weapons come in normal and elite tiers. Normal versions are worn, improvised,
or low-grade. Elite versions have both a damage boost and meaningful durability.

**Damage baseline reference:**

| Source | Damage |
|---|---|
| Throw Rock (default) | 3 |
| Walking Staff (starting) | 6 |
| Normal drop weapons | 7 |
| Elite drop weapons | 9 |
| Burst weapons (Cudgel / Maul) | 9 / 10 |
| AoE weapons (Flail / Chain) | 4 / 6 per target |

#### Weapon Summary

| Weapon | Type | Damage | Charges | Property | Pool |
|---|---|---|---|---|---|
| Cracked Cudgel | Physical | 9 | 3 | High burst | Normal |
| Rope Flail | Physical | 4/hit | 6 | Hits all enemies | Normal |
| Battered Sword | Physical | 7 | 8–10 | — | Normal |
| Ember Shard | Fire | 7 | 3 | — | Normal |
| Spark Rod | Lightning | 7 | 3 | — | Normal |
| Frost Sliver | Ice | 7 | 3 | — | Normal |
| Iron Maul | Physical | 10 | 6 | High burst | Elite |
| Spiked Chain | Physical | 6/hit | 8 | Hits all enemies | Elite |
| Soldier's Blade | Physical | 9 | 10–12 | — | Elite |
| Smoldering Brand | Fire | 9 | 8 | — | Elite |
| Arc Wand | Lightning | 9 + 4 arc | 8 | Arcs to one additional enemy | Elite |
| Glacial Brand | Ice | 9 | 8+ | — | Elite |

#### Support Summary

| Item | Effect | Charges | Pool |
|---|---|---|---|
| Small Amethyst | Clears one spiritual/elemental debuff | 1 | Normal |
| Medium Amethyst | Clears one spiritual/elemental debuff per charge | 2 | Elite |

---

#### Cracked Cudgel *(Attack — Durability · Physical)*

**Damage: 9. Charges: 3.**

High damage per hit, very low durability. Kills a Skeleton in 2 hits — the
same as a Walking Staff but with 3 points of extra damage per swing. Burns
through fast. Good for the elite or the Judge if saved.

Against Zombie (16 HP, physical vulnerable): with Brittle Charm ×1.5 = 13 per
hit, 2-hit kill. Exceptionally efficient when the setup lands.

---

#### Rope Flail *(Attack — Durability · Physical)*

**Damage: 4 per target. Charges: 6.**

Hits all enemies simultaneously. Value is charge efficiency and simultaneous
pressure rather than reduced incoming damage — both enemies stay alive equally
long, but each charge hits two targets instead of one.

Against two Skeletons (12 HP each): 3 charges kills both simultaneously vs
Walking Staff sequential kill taking more total charges. The distinction
matters in the late-floor charge economy.

Note: AoE weapons do not reduce incoming damage per turn — both enemies still
act. Priority kill logic still applies where possible.

---

#### Battered Sword *(Attack — Durability · Physical)*

**Damage: 7. Charges: 8–10.**

Reliable workhorse. Above the Walking Staff, below the Cudgel per hit — lasts
far longer. Kills a Skeleton in 2 hits, a Zombie in 3. The go-to drop for
players who want weapon stability across the post-elite double encounters.
Knight vessel's familiar replacement sword.

---

#### Ember Shard *(Attack — Durability · Fire)*

**Damage: 7 fire. Charges: 3.**

Introduces fire damage at the normal pool tier. Kills a Burning Skeleton
(×1.5 = 10.5 → 11 per hit) in 2 hits. Limited charges restrict the combo
window but 3 hits of amplified fire damage is meaningful burst.

---

#### Spark Rod *(Attack — Durability · Lightning)*

**Damage: 7 lightning. Charges: 3.**

Introduces lightning at the normal pool tier. No arc property. Against a
Shocked target: 7×1.5 = 10.5 → 11 per hit. The setup cost (Fulminating
Powder) is high relative to 3 charges of payoff — but the vulnerability
window is active while waiting for the stun, which compounds value.

---

#### Frost Sliver *(Attack — Durability · Ice)*

**Damage: 7 ice. Charges: 3.**

Introduces ice at the normal pool tier. Against a Chilled target: 7×1.5 =
10.5 → 11 per hit. Three charges of ×1.5 against a Chilled Zombie (16 HP)
= 33 potential damage — overkill, but burns the Frost Shard charge and 3
weapon charges for 2-hit kill efficiency.

---

#### Iron Maul *(Attack — Durability · Physical)*

**Damage: 10. Charges: 6.**

Elite Cudgel. One-shots a Skeleton (12 HP, 10 > 12? No — 10 < 12, takes 2
hits). Two-hits a Zombie (16 HP in 2 hits = 20 damage). With Brittle Charm
(×1.5 = 15 per hit): one-shots a Zombie. The most physically dominant weapon
on the floor. 6 charges supports use across 3 post-elite double encounters.

---

#### Spiked Chain *(Attack — Durability · Physical)*

**Damage: 6 per target. Charges: 8.**

Elite Flail. More damage per hit to all enemies, more charges. Against two
Zombies (16 HP each): 3 charges kills both simultaneously (6×3=18>16). The
definitive post-elite AoE weapon — 8 charges covers the full double-encounter
phase comfortably.

---

#### Soldier's Blade *(Attack — Durability · Physical)*

**Damage: 9. Charges: 10–12.**

Elite Sword. Best reliable single-target physical option on the floor. Kills
a Skeleton in 2 hits, a Zombie in 2 hits (9×2=18>16). With 10–12 charges
it comfortably covers the post-elite phase without Good as New. The Knight's
superior replacement sword; for other vessels the safe, high-value physical pick.

---

#### Smoldering Brand *(Attack — Durability · Fire)*

**Damage: 9 fire. Charges: 8.**

Elite fire weapon. Against a Burning target: 9×1.5 = 13.5 → 14 per hit.
Kills a Burning Skeleton in 1 hit. Combined with Fire Bomb (Burning applied):
the Skeleton never survives the setup turn. Against a Burning Zombie: 2 hits
(14×2=28>16). 8 charges sustains the fire combo across multiple post-elite
encounters.

Setup: Fire Bomb (Burning active) → Smoldering Brand for ×1.5 per hit.

---

#### Arc Wand *(Attack — Durability · Lightning)*

**Damage: 9 lightning primary + 4 lightning arc. Charges: 8.**

Elite lightning weapon. The arc hits a second enemy for 4 damage on every
swing — no setup required for the chain. Against a Shocked target: primary
hit 9×1.5 = 13.5 → 14, arc 4×1.5 = 6. In a two-enemy fight with both
Shocked: 14 to primary, 6 to secondary per swing.

Setup: Fulminating Powder (Shocked + Vulnerable Lightning) → Arc Wand for
amplified primary and arc on both targets.

---

#### Glacial Brand *(Attack — Durability · Ice)*

**Damage: 9 ice. Charges: 8+.**

Elite ice weapon. Slightly more charges than Smoldering Brand — no secondary
property, compensated with durability. Against a Chilled target: 9×1.5 =
13.5 → 14 per hit. Kills a Chilled Zombie in 2 hits (14×2=28>16). Mirrors
Smoldering Brand in naming — fire and ice as opposing weapons.

Setup: Frost Shard (Chilled + Vulnerable Ice) → Glacial Brand for ×1.5 per hit.

---

### 6.3 Drop Pool — Consumables

#### Consumable Summary

| Item | Effect | Pool |
|---|---|---|
| Fire Bomb | Burning on one enemy | Normal |
| Ointment | Clears Burning / Poisoned | Normal |
| Combustible Oil | Vuln (Fire) if not Burning; flat fire damage if Burning | Normal |
| Hardening Resin | Hardened — absorbs 3/tick | Normal |
| Poultice | Mending — heals 3/tick | Elite |
| Brittle Charm | Vulnerable (Physical) ×1.5 | Elite |
| Frost Shard | Chilled on one enemy | Elite |
| Fulminating Powder | Shocked on one enemy | Elite |

---

#### Fire Bomb *(Consumable — Single Use · Fire)*

**Effect:** Applies Burning to one enemy.

| Timer card | Total fire damage (base) | vs Skeleton (×1.5) |
|---|---|---|
| 1 tick | 5 | 7 |
| 2 ticks | 10 | 15 — one-shots Skeleton (12 HP) |
| 3 ticks | 15 | 22 |

**Typical (2 ticks): 10 base / 15 vs fire-vulnerable.** One-shots a Skeleton
at typical. Against Zombie (not fire vulnerable): 10 damage at typical —
roughly 1 Walking Staff hit's worth as a free action.

---

#### Ointment *(Consumable — Single Use)*

Clears one physical/chemical DoT (Burning or Poisoned) from a target.
Offensive use: strip Mending from an enemy if they carry it.

---

#### Combustible Oil *(Consumable — Single Use · Fire)*

**Conditional:**
- Target **not Burning** → Vulnerable (Fire) ×1.5. Sets up fire combo without DoT.
- Target **already Burning** → flat fire damage burst.

> **`[OPEN]`** Flat damage value when target is Burning to be set. First
> pass: 6 (one extra tick's worth).

Two sequences:
- Oil → Fire Bomb: vulnerability active, DoT ticks at ×1.5
- Fire Bomb → Oil: DoT ticking at ×1.5, Oil adds flat burst

---

#### Hardening Resin *(Consumable — Single Use)*

Applies Hardened. Absorbs up to 3 damage per tick, resets each tick.
**Typical (2 ticks): up to 6 absorbed.**

---

#### Poultice *(Consumable — Single Use)*

Applies Mending. Heals 3 HP per tick.
**Typical (2 ticks): 6 HP restored.** Only reliable healing on a no-rest floor.

---

#### Brittle Charm *(Consumable — Single Use · Physical)*

Applies Vulnerable (Physical) ×1.5 to one enemy. Only source of physical
vulnerability on Floor 3.

**Against Zombie (16 HP):** Walking Staff (6×1.5=9) kills in 2 hits instead
of 3 — saves 4 HP of incoming damage across the fight.
**Against Skeleton (12 HP):** Walking Staff (9 per hit) kills in 2 hits —
same speed, but any weapon benefits during the window.

---

#### Frost Shard *(Consumable — Single Use · Ice)*

Applies Chilled to one enemy: creeping damage reduction AND Vulnerable (Ice) ×1.5.

**Typical (2 ticks):** enemy deals 10% less first tick, 20% less second.
Glacial Brand hits for ×1.5 during the window.

---

#### Fulminating Powder *(Consumable — Single Use · Lightning)*

Applies Shocked: Vulnerable (Lightning) ×1.5 while active, stun at omen shift.
Low timer cards are valuable — fast stun payoff. The only item that makes
1-tick cycles actively desirable.

Name derives from Latin *fulmen* — thunderbolt.

---

*Soul Protocol — Items v0.6*
*Companion to soul_protocol_game_design.md and soul_protocol_enemies.md.*
*v0.6: All weapon damage values confirmed. Throw Rock: 3. Walking Staff: 6
(up from 5). Normal drops: 7 (physical/elemental). Elite drops: 9. Burst
weapons: 9/10. AoE weapons: 4/6 per target. Arc Wand arc damage: 4. Damage
baseline table added. All weapon entries updated with confirmed numbers and
kill references vs Skeleton (12 HP) and Zombie (16 HP). Pre/post-elite
single/double encounter structure noted in drop pool section.*
