# Soul Protocol — Floor & Encounter Design
## Version 0.1 · May 2026 · Solo Developer

> **Purpose:** Defines the structure, pacing, and encounter patterns for Soul Protocol's
> floors. Currently covers Floor 3 (The Threshold) in detail. Other floors to be added
> as designed.
>
> Confirmed decisions are marked **`✓`**.
> Open questions are marked **`[OPEN]`**.

---

## Table of Contents

1. [Floor 3 — The Threshold](#1-floor-3--the-threshold)
2. [Run Length & Difficulty](#2-run-length--difficulty)
3. [Room Composition](#3-room-composition)
4. [Encounter Pattern System](#4-encounter-pattern-system)
5. [The Door System](#5-the-door-system)
6. [Forced Beats](#6-forced-beats)
   - Beat 1 — Opening
   - Beat 2 — Combat Lock
   - Beat 3 — Worn Map Companion
   - Beat 4 — Elite Gate
7. [The Judge](#7-the-judge)

---

## 1. Floor 3 — The Threshold

Floor 3 is the final floor for all vessels. It is the liminal space immediately
before Solace — a place of haze and half-shapes where the soul faces its final
reckoning. All vessels that complete their run play floor 3. The Judge waits at
the end.

Enemy clarity is lowest here for the Pilgrim (tier 1) — shapes barely resolved,
threats present but indistinct. Tier 2 and tier 3 vessels experience the same
floor structure with enemies that manifest more sharply and hit harder.

> **✓ Decision: Floor 3 structure (9 rooms + Judge) is consistent across all
> vessels. Enemy difficulty scales per vessel tier.**
>
> **Rationale:** A shared final floor reinforces the narrative — all souls face
> the same threshold. Difficulty scaling per tier keeps the floor appropriately
> challenging without requiring separate floor designs.

---

## 2. Run Length & Difficulty

**Target run length:** ~30 minutes for an average-speed player.

Time breakdown for a Pilgrim run (tier 1):

| Element | Count | Estimated Time |
|---|---|---|
| Standard combats | 4 | ~12 min |
| Elite combat | 1 | ~4 min |
| Judge boss | 1 | ~6 min |
| Post-combat loot choices | 5 | ~2.5 min |
| Non-combat rooms | 2–3 | ~2–3 min |
| Navigation (door choices) | 9 | ~3 min |
| **Total** | | **~30 min** |

Run length varies naturally with player choices: skipping a combat room shortens
the run; choosing an extra combat lengthens it.

**Combat duration assumption:** Standard combat runs 3–5 turns (~2–3 min for an
average player). Two omen cycles are typical. Elite combat runs 4–6 turns (~4 min).

**Difficulty target (Pilgrim, tier 1):** A player familiar with Slay the Spire
should complete the Pilgrim run in **3–5 attempts**.

> **✓ Decision: ~30 min target run length. 3–5 attempts for an StS-familiar
> player on the Pilgrim.**
>
> **Rationale:** Short enough to feel accessible, long enough for the item economy
> and omen system to matter. The attempt range rewards genuine learning — the
> Judge should feel learnable, not random. First attempt: probable death, learns
> the Judge exists. Second–third: better resource management, Judge pattern
> becoming readable. Fourth–fifth: realistic completion window.

---

## 3. Room Composition

Floor 3 contains **9 rooms** before the Judge. Room type distribution targets
**50–75% combat**.

**Target composition for a typical run:**

| Room type | Count | Notes |
|---|---|---|
| Standard combat | 4 | Core encounter type |
| Elite combat | 1 | Forced as one option at the elite gate — see section 6 |
| Temporary companion | 1 | Guaranteed — triggered by Worn Map starting item |
| Non-combat events | 2–3 | Rest, Memory Fragment, Wandering Soul, or Anomaly |

Exact non-combat count varies by player choice within the pattern system constraints.

---

## 4. Encounter Pattern System

The floor does not use a fixed room sequence. Instead it tracks two counters:

- **Combats taken** — increments each time the player completes a combat room
- **Events taken** — increments each time the player completes a non-combat room

These counters constrain which room types can appear behind doors, ensuring the
floor hits its required beats regardless of player choices. Because the player
never sees the full map, enforced pacing is invisible — the constraints feel like
the natural shape of the floor rather than a designed rails system.

> **✓ Decision: Encounter pattern system uses combat and event counters to
> constrain room generation, not a fixed room sequence.**
>
> **Rationale:** A fixed sequence is fragile and legible to repeat players in
> a way that removes discovery. The counter system guarantees floor shape and
> item economy while preserving the appearance of player agency. The player
> chooses rooms; the floor shapes what is available.

---

## 5. The Door System

Between each room the player faces a **two-door choice**. Each door displays the
identity of the encounter behind it.

### 5.1 Combat Doors

**Combat doors reveal the full enemy identity.** The player sees exactly which
enemy is in the room before committing. Knowledge gained across attempts is a
core part of the difficulty curve — a player on their fourth run knows which
enemies are dangerous, which can be bypassed safely, and which pair badly with
their current item loadout.

> **✓ Decision: Combat doors show full enemy identity — not a symbol, hint,
> or category.**
>
> **Rationale:** Full identity makes repeat-run knowledge genuinely valuable.
> Partial hints reduce the quality of that information asymmetry without adding
> meaningful mystery. The difficulty comes from learning what enemies do, not
> from being surprised by the same enemies repeatedly.

### 5.2 Forced Combat — Both Doors Combat

When the pattern system determines the player must take a combat, both doors show
combat encounters. The enemy identity on each door differs — the player still
chooses which fight to take, not whether to fight.

### 5.3 Non-Combat Doors

Non-combat room types are shown by symbol on the door. The specific content
within (which memory fragment, which merchant inventory) is not revealed until
the player enters.

> **`[OPEN]`** Visual language for non-combat door symbols to be confirmed
> during UI/art direction session.

---

## 6. Forced Beats

The following beats are guaranteed on every Floor 3 run regardless of player
choices. They are enforced by the encounter pattern system invisibly.

There is no guaranteed rest or recovery room at any point on the floor.
Healing is only available if the player encounters a rest room through normal
room generation. Resource management across the full floor is the intended
pressure — arriving at the Judge depleted is a consequence of decisions made,
not bad luck alone.

> **✓ Decision: No guaranteed rest or recovery room on the floor.**
>
> **Rationale:** A guaranteed heal before the Judge softens the resource
> pressure the floor is designed to create. Healing exists in the room pool
> but must be found, not relied upon.

---

### Beat 1 — Opening (Rooms 1–2)

Full player choice. Any room type may appear behind either door. No counter
constraints are applied during the opening.

---

### Beat 2 — Combat Lock

**Trigger:** Player has taken 2 or more event rooms with fewer than 2 combats
completed.

**Effect:** Both doors show combat encounters with different enemy identities.
The player chooses which fight, not whether to fight.

**Design intent:** Prevents event-skipping the combat economy entirely. A player
who has avoided two combats in a row is now committed to one regardless of
preference. The enemy choice on the door preserves meaningful agency within
the constraint.

> **`[OPEN]`** Exact counter thresholds (currently: ≥2 events, <2 combats) to
> be tuned during playtesting.

---

### Beat 3 — Worn Map Companion (Room 4)

The Worn Map's encounter-countdown (counter: 3) guarantees this slot becomes
a temporary companion encounter. The counter decrements on every encounter type,
so room 4 is always the companion room regardless of which room types the player
chose in rooms 1–3.

The two-door choice is replaced by a single door for this room. Normal
two-door navigation resumes after the encounter resolves. The Worn Map is
removed from inventory.

Companion identity is drawn from the floor's temporary companion pool and is
not predetermined.

> **`[OPEN]`** Temporary companion pool for floor 3 to be defined during
> companion design session.

---

### Beat 4 — Elite Gate (Room 5–6 Range)

One door shows an **elite combat** encounter. The other door shows an
**Anomaly** encounter.

The player chooses between a known difficult fight with a known post-combat
loot reward, or an unknown outcome with higher variance. Risk-averse players
take the elite — hard but predictable. Gamblers take the Anomaly — it could
be a significant advantage or a costly loss.

> **✓ Decision: The elite gate pairs elite combat with an Anomaly — not a
> forced single door.**
>
> **Rationale:** The choice between known difficulty and unknown risk is more
> interesting than a forced gauntlet. It also contributes to the luck element
> in the 3–5 attempt target — a fortunate Anomaly outcome can meaningfully
> change a run. The Anomaly's corrupted symbol on the door signals risk without
> revealing outcome.

---

## 7. The Judge

The Judge is the final encounter on floor 3 for all vessels. He is the same
entity across all tiers — the soul faces the same gatekeeper every time. His
combat behaviour, HP, and pressure scale with vessel tier.

**Tier 1 (Pilgrim):** Lightest scrutiny. The Pilgrim arrives with almost
nothing — the Judge barely resists him. Should be beatable within the 3–5
attempt window with good floor resource management.

**Tier 2 (Drifter, Hedge Knight):** Moderate difficulty. The soul still
retains something — the Judge examines it more carefully.

**Tier 3:** Full difficulty. The intact soul faces the hardest test of need.

> **`[OPEN]`** Judge combat mechanics, HP pools, abilities, and tier-specific
> behaviour to be designed during the enemy design session.

> **`[OPEN]`** The Judge's name is a working title. Final name to be confirmed
> during narrative pass.

---

*Soul Protocol — Floor & Encounter Design v0.1*
*Companion to soul_protocol_game_design.md and vessel design documents.*
*v0.1: Floor 3 structure established — 9 rooms + Judge, ~30 min target,
encounter pattern system, door identity system, four forced beats documented.
No guaranteed rest room — healing available through normal room generation only.*
