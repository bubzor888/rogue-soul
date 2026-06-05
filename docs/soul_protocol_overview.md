# Soul Protocol — Design Decisions
## Version 0.4 · May 2026 · Solo Developer

> **Consolidated document.** This version supersedes v0.1, v0.2, and v0.3.
> All confirmed decisions are recorded here with rationale and rejected alternatives.
> Open questions are marked **`[OPEN]`**.
> Roadmap notes are marked **`[ROADMAP]`**.

---

## Table of Contents

1. [Core Concept & Narrative](#1-core-concept--narrative)
2. [Game Feel & Scope](#2-game-feel--scope)
3. [Navigation & Run Structure](#3-navigation--run-structure)
4. [Combat System](#4-combat-system)
5. [Vessel & Class System](#5-vessel--class-system)
6. [Companion System](#6-companion-system)
7. [Meta-Progression](#7-meta-progression)
8. [Engine & Platform](#8-engine--platform)
9. [Technical Constraints](#9-technical-constraints)
10. [Open Questions](#10-open-questions)
11. [Roadmap Notes](#11-roadmap-notes)

---

## 1. Core Concept & Narrative

### 1.1 Premise

An ancient soul wakes in purgatory with no memory of why it is there. It inhabits the bodies of the recently deceased — borrowing their last moments of existence — and pushes deeper into this liminal place searching for fragments of its own story. Each run recovers pieces of the soul's history. Death resets the run but not the soul's accumulated knowledge. The question driving every run: *what happened to leave this soul in a state of unrest?*

> **✓ Decision: The soul's goal is recovering its own memory — understanding why it is trapped in purgatory**
>
> **Rationale:** "Why am I here" is one of the most universally resonant hooks available. It is personal without being prescriptive — players project their own meaning onto it until the answer reveals itself. It also makes the Soul Codex feel like the literal point of the game rather than a bolted-on system: the codex is the soul's autobiography, reassembled fragment by fragment across lifetimes. Death is narratively coherent — the soul loses its grip on what it just remembered, but not entirely.
>
> **Rejected:** Soul searching for a specific person (too narrow, risks feeling arbitrary if the player doesn't connect with the target). Soul trying to escape the cycle (Hades-adjacent, undermines the mystery framing). Soul fulfilling a mission (externalises motivation, weakens personal stakes).

### 1.2 Setting

Purgatory — a liminal space that takes the shape of things the dead remember. Architecture from different eras layered on top of each other. Rooms that shift between what they were and what they meant to someone. A marketplace that used to be a battlefield. A bedroom that bleeds into a forest. Decay and memory coexisting.

No gods. No pantheon. The purgatory simply *is* — ancient, indifferent, full of other lost things.

> **✓ Decision: Purgatory/afterlife setting — not a space station, not a fantasy dungeon**
>
> **Rationale:** The original space station concept was visually distinctive but narratively thin. Pure fantasy dungeon crawl is overcrowded. Purgatory earns everything the station was attempting aesthetically — liminal strangeness, decay, layered history — but with genuine mythological and emotional weight. It also provides a natural procedural justification: rooms shift and layer because memory is unstable.
>
> **Rejected:** Space station with spiritual undertones (aesthetically interesting, narratively underpowered). Standard fantasy dungeon (overcrowded market, no thematic fit). Sci-fi setting (loses the soul theme's spiritual register entirely).

### 1.3 Vessels

Vessels are the recently deceased — people who just died, each with their own unfinished business, physical condition, and circumstances of death. The soul inhabits them before they fully pass on, borrowing what remains of their existence.

A vessel is not a class archetype in the traditional sense. It is a person. Their circumstances at death shape what they can do. A soldier who died mid-battle fights differently from a monk whose heart gave out or a merchant who was poisoned.

> **✓ Decision: Vessels are the recently deceased — their circumstances of death define their capabilities**
>
> **Rationale:** This reframes the class system in a way that is narratively rich and mechanically distinctive. Rather than selecting a warrior class, the player inhabits a specific person with a specific history. This gives every vessel a natural lore hook, a distinct ability profile, and an emotional texture that generic class names cannot. It also makes vessel unlocking feel like discovering lost souls rather than purchasing upgrades.
>
> **Rejected:** Vessels as generic class archetypes (functional but narratively flat, no differentiation from standard roguelite class systems).

---

## 2. Game Feel & Scope

> **✓ Decision: 20–30 minute target run length at MVP, designed to expand in later versions**
>
> **Rationale:** Short runs lower the cost of failure — critical for a roguelite where dying should feel like a learning experience, not a two-hour time sink. A short loop also constrains content requirements, limits encounter types needed for variety, and makes playtesting fast. The system is explicitly architected to expand run length post-MVP.
>
> **Rejected:** 45–75 min (too ambitious for MVP content requirements). 10–15 min (too short for meaningful vessel and companion expression).

> **✓ Decision: Turn-based combat — no real-time or action elements**
>
> **Rationale:** Correct choice for a solo developer building a system with positioning, companions, and item management simultaneously. No need to tune action feel, hitboxes, or input latency. Fits the soul theme — the soul is ancient and patient. Deliberate consequence-heavy decisions over twitch reflexes.
>
> **Rejected:** Action combat (too much animation and feel work for a solo developer). Hybrid action-pause (complexity of both without full benefits of either).

---

## 3. Navigation & Run Structure

### 3.1 Navigation — The Corridor

The player moves through purgatory door by door. At each threshold they can see the symbol on the current door (the room they are about to enter) and the two doors beyond it — the choices that will follow. No further look-ahead. No top-down map.

The player always knows: *what is this room, and what are my two options after it.* No further.

> **✓ Decision: Corridor navigation with door symbols — always see the current room and the next two choices**
>
> **Rationale:** More immersive than a top-down flowchart — the player is always inside purgatory, not observing it from above. The two-choices-ahead visibility creates a short-term sequencing decision that is more strategic than StS's single-node selection: players are picking a two-room sequence, not just a next step. Fits the setting — you're moving through a place that used to be somewhere, door by door.
>
> **Rejected:** Top-down node map à la Slay the Spire (functional but derivative, breaks immersion). Full exploration (too much scope, too much content required to fill). Deck-of-locations draw (reduces agency, feels arbitrary). Backtracking (no compelling use case in a 20–30 min run with forward visibility; removed).

### 3.2 Door Symbols

Each room type has a distinct symbol visible on its door. Symbols should be instantly readable, thematically consistent with purgatory's visual language, and not derivative of Slay the Spire's iconography.

| Room Type | Function | Notes |
|---|---|---|
| **Combat** | Standard enemy encounter | Core room type |
| **Elite Combat** | Harder fight, better reward | Same symbol with a warning glyph |
| **Rest / Mending** | Heal vessel or restore companion | Vessel-repair framing, not a campfire |
| **Memory Fragment** | Narrative/lore event — soul recovers a piece of its history | Core to the soul's goal |
| **Wandering Soul** | Merchant equivalent — trade items with a lost spirit | Thematically: a soul who remembers what it had |
| **Anomaly** | Unknown — corrupted or unreadable symbol | Risk/reward: unknown outcome |
| **Echo Chamber** | Encounter with a remnant of a past vessel or enemy | Ties into Soul Codex |
| **Boss / Threshold** | Floor exit encounter | Always at the end of a floor |

**`[OPEN]`** Exact visual language for symbols — to be decided in UI/art direction session.

### 3.3 Run Structure — Floor Depth Choice

Before each run the player chooses how many floors they will descend: 1, 2, or 3. This choice is locked in at the start — it cannot be changed mid-run.

- **1 floor:** 10–15 minutes. Modest meta rewards. Accessible entry point.
- **2 floors:** 20–25 minutes. Medium rewards. Meaningful commitment.
- **3 floors:** 30–45 minutes. Best rewards. High risk, full experience.

> **✓ Decision: Player chooses floor depth before the run — commitment is locked in, not decided mid-run**
>
> **Rationale:** Forcing the choice upfront means the player owns the consequences. A player who chose 3 floors and dies on floor 2 made that decision with full knowledge — far less frustrating than a system that surprises them with escalating difficulty. It also has thematic resonance: the soul is choosing how deeply to commit to this incarnation before it begins.
>
> **Rejected:** Choosing to descend further at the end of each floor (reduces commitment weight, encourages always choosing more on a good run, removes the upfront risk/reward decision).

> **✓ Decision: Deeper runs give proportionally greater meta rewards plus a completion bonus**
>
> **Rationale:** Without a meaningful reward differential, rational players always choose 1-floor speed runs. The completion bonus — a guaranteed rare outcome, a special Soul Codex entry, or an unlock condition only triggerable on multi-floor runs — ensures deeper runs feel meaningfully more rewarding, not just proportionally so.

### 3.4 Boss Structure

Each floor ends with a boss encounter. Boss difficulty and complexity scale with the floor's position in the chosen depth.

> **✓ Decision: Mini-bosses at intermediate floors; true boss only at the final floor of the chosen depth**
>
> **Rationale:** A 3-floor run should not have three full boss encounters — that would be exhausting and would require triple the boss content. Mini-bosses are guardians, fragments, or memory echoes — genuine threats but not run-defining encounters. The true boss is tuned as the climax of everything built across the run. This also means a 1-floor boss is always the full encounter, tuned appropriately for a single floor of preparation.
>
> **Thematic framing:** Mini-bosses are the purgatory's defences or echoes of powerful lost souls. The true boss is whatever lies at the heart of the soul's unrest — or a manifestation of it. The deeper the soul descends, the more aware the thing at the end becomes.

---

## 4. Combat System

### 4.1 Positioning — Front / Back Row

Combat uses a front/back row abstraction. No tile grid is rendered or simulated. Units occupy either the front or back row and position has mechanical consequences.

> **✓ Decision: Front / back row positioning — no tile grid at MVP**
>
> **Rationale:** A full tactical grid carries enormous solo dev scope implications: tile rendering, pathfinding, elevation, enemy AI navigation. Front/back row captures the essential tactical value — melee vs. ranged reach, exposure vs. protection, push/pull effects — at a fraction of the implementation cost. A grid can be introduced post-MVP if the design demands it.
>
> **Rejected:** Full tile grid (deferred, not MVP). No positioning (loses tactical depth and differentiation). Three-plus row lane system (unnecessary complexity at MVP).

**Baseline positional rules** (numbers are placeholders for tuning):
- Melee attacks can only target front row, or hit back row at significant penalty
- Ranged and magic attacks can target any row freely
- Units in back row receive reduced physical damage
- Moving between rows costs an action — a meaningful sacrifice
- Some item charges and abilities explicitly require or reward a specific row position

**`[OPEN]`** Do the vessel and companion share a single row assignment, or can they occupy different rows independently?

### 4.2 Action Economy

> **✓ Decision: Fixed vessel abilities + expendable item inventory as the primary action economy**
>
> **Rationale:** Pure deck-building is overcrowded and over-emphasises the building phase over execution. The soul/vessel theme suggests innate abilities (the soul's accumulated power) augmented by found tools (the vessel's material circumstance) — classic JRPG combat with a finite consumable inventory creating moment-to-moment resource tension.
>
> **Rejected:** Pure deck-building (overcrowded market, mismatches soul theme). Dice-building (less synergy design space). Full tactical grid (deferred).

**`[OPEN]`** Exact action economy per turn — e.g. 1 move + 1 ability + N item uses, or a single action point pool?

**`[OPEN]`** How does enemy AI signal intent — telegraphed actions à la Slay the Spire, or hidden?

### 4.3 Item Charge Models

| Model | Behaviour | Used for |
|---|---|---|
| **Durability** | N uses, then breaks and disappears. Highest spend-vs-hoard tension. | Items found during a run |
| **Charge-per-run** | Permanent between runs, charges reset each run. Soul remembers its arsenal; each life exhausts it. | Soul-carried meta-progression items |
| **Degrading power** | Never disappears, weakens with use. Full = strong, depleted = weak. | Possible variant for specific item classes |

> **✓ Decision: Durability model for run-found items; charge-per-run model for soul-carried meta-progression items**
>
> **Rationale:** Durability creates the clearest within-run resource tension — items found mid-run are finite, not permanent acquisitions. Charge-per-run rewards the soul building an arsenal without making runs feel free. The two models coexist naturally and map onto the soul/vessel distinction: the vessel's found tools are expendable, the soul's remembered tools are persistent but limited.
>
> **Rejected:** Degrading power as default (too forgiving for the intended tone). Permanent items with no limit (eliminates within-run tension).

**`[OPEN]`** Do soul-carried items occupy the same inventory slots as run-found items, or sit in a separate soul inventory layer?

**`[OPEN]`** Starting inventory size and maximum? How are items found — loot drops, merchant equivalent, or both?

---

## 5. Vessel & Class System

### 5.1 Vessel as Class

The vessel the soul inhabits each run is the class system. Vessels are chosen before the run from the pool the soul has unlocked. Each vessel has a fixed set of base abilities — these do not change during the run. The variable layer is the item inventory and companion.

> **✓ Decision: Vessel archetype = class identity; base abilities are fixed per vessel, not built during the run**
>
> **Rationale:** In-run class building is too content-heavy for a solo developer and conflicts with a 20–30 min run target. Fixed abilities shift build expression to the item inventory and companion — the systems with the most run-to-run variance. The vessel's fixed abilities create a consistent identity players can learn and plan around; items and companions are the unpredictable layer on top.
>
> **Rejected:** Full in-run class trees (scope, conflicts with run target). Fully random ability loadouts (no consistent identity, harder to design around).

### 5.2 Unlocking Vessels

> **✓ Decision: Vessels unlocked by experience conditions — what the soul has lived — not currency**
>
> **Rationale:** Experience-gated unlocks keep meta-progression feeling like earned wisdom rather than a grind economy. Early runs are interesting even when lost because the player may be completing hidden unlock conditions. Discovering a new vessel feels like the soul finding a kindred spirit, not purchasing a product.
>
> **Rejected:** Currency-gated unlocks (feels like grinding, breaks soul narrative). All vessels available from start (removes meta-progression reward loop).

**`[OPEN]`** How many vessels ship with MVP? Suggested minimum: 3 (one with bound companion, one without, one with summoning focus).

**`[OPEN]`** Specific unlock conditions per vessel — to be decided in vessel design session.

---

## 6. Companion System

### 6.1 Companion Types

| Type | Description | On Death |
|---|---|---|
| **Bound Companion** | Comes with specific vessel archetypes. Persistent relationship tied to vessel lore and identity. Travels the whole run. | Genuine loss — emotionally meaningful, run is weakened |
| **Summoned Companion** | Conjured via expendable items. Tactical burst allies — echoes of defeated souls or wandering spirits encountered in purgatory. | Expected — pure resource management, no grief |

> **✓ Decision: Two-tier companion system — bound (persistent within run) and summoned (expendable)**
>
> **Rationale:** A single type forces a false design choice between emotional weight and tactical flexibility. Bound companions provide run-long identity and narrative resonance — their death should feel like something. Summoned companions provide tactical burst without attachment, fitting the expendable item economy. The two tiers create natural design variety: some vessels have no bound companion but stronger summoning; others have a powerful bound spirit but no summoning capacity.
>
> **Rejected:** Single companion type (forces design compromise). No companions (loses soul/echo thematic richness and reduces tactical depth).

### 6.2 Companion Health & Death

> **✓ Decision: Companions have their own HP pool and can die permanently within a run**
>
> **Rationale:** Real death stakes create genuine tactical decisions — do you shield your bound companion or sacrifice them to save the vessel? A companion that cannot die is just an ability extension with no meaningful risk. Spirits being extinguishable is also narratively coherent in a purgatory setting.
>
> **Rejected:** Companion as ability extension with no HP (removes tactical tension and emotional stakes). Auto-revive companion (eliminates consequences).

### 6.3 Bound Companion Revival

Exactly one expensive revival path exists for bound companions. Details are deferred to the companion system requirements session. Design principle: revival must be possible, must be rare, and must cost something meaningful.

**`[OPEN]`** Revival mechanism — candidates: rare item drop, specific encounter event, sacrifice mechanic (spend vessel HP to restore companion).

**`[OPEN]`** Can the player have a bound companion and a summoned companion active simultaneously, or is it one at a time?

### 6.4 Solo Vessel Archetype

> **✓ Decision: A vessel with no bound companion is a valid archetype with compensating advantages — not a punishment**
>
> **Rationale:** Solo-vessel archetypes have compensating advantages — additional item slots, stronger summoning abilities, or passives that only apply when unaccompanied — to avoid bound-companion vessels being perceived as strictly superior. Traveling alone in purgatory is a different experience, not a harder one.
>
> **Rejected:** All vessels have a bound companion (removes design variety). Solo vessel as a difficulty modifier (implies it is harder, not different).

---

## 7. Meta-Progression

### 7.1 Philosophy

Meta-progression must feel like the soul becoming wiser — not the player buying power. Every permanent unlock should have a narrative justification rooted in what the soul has experienced. The soul grows because it lived, failed, and remembered — not because it farmed currency.

> **✓ Decision: Knowledge-gated meta-progression — unlocks triggered by experiences, not currency**
>
> **Rationale:** Experience-gated unlocks keep every permanent change tied to the soul's story. Early runs are interesting even when lost because the player may be completing hidden unlock conditions. Currency grind decouples narrative from mechanics and risks making early runs feel punishing.
>
> **Rejected:** Currency grind à la Rogue Legacy 2 (breaks soul narrative, risks early game frustration). No meta-progression (insufficient run-to-run motivation for a roguelite).

### 7.2 Progression Layers

| # | Layer | Description | Status |
|---|---|---|---|
| 1 | **Soul Codex** | Permanent record of enemies, events, and souls encountered. Grants in-run bonuses when the soul meets known entities. Narratively: the soul's autobiography reassembled fragment by fragment. | ✅ Required — MVP |
| 2 | **Vessel Archive** | Pool of unlockable vessels, unlocked by experience conditions. Each vessel has distinct abilities, a companion situation, and a fragment of purgatory lore tied to who they were in life. | ✅ Required — MVP |
| 3 | **Resonance Imprints** | After a completed run, the soul retains one passive echo — a scar or gift from each life. Permanent across runs. | Post-MVP |
| 4 | **Dungeon Memory** | Purgatory itself shifts based on cumulative run history. Lost souls remember the player, sealed doors open after multiple visits, bosses evolve after first defeat. | Stretch goal |

---

## 8. Engine & Platform

> **✓ Decision: Godot 4 + GDScript**
>
> **Rationale:** Single codebase exports to desktop, web, iOS, and Android. GDScript is Python-like and maps naturally to the developer's Java/Kotlin/Python background — dynamic typing, readable syntax, fast iteration. Turn-based gameplay means GDScript's performance overhead relative to C# is irrelevant; the game spends most time waiting on player input. Strongest all-rounder for a solo developer who wants to start fast and keep platform options open.
>
> **Rejected:** Unity (licensing complexity post-2023, heavier than needed). Phaser.js/plain web stack (no visual editor, loses future native export path). Godot + C# (slightly more setup friction; GDScript iteration speed preferred for this project type).

> **✓ Decision: Desktop-first for initial development; all platform options kept open**
>
> **Rationale:** Desktop is the lowest-friction starting point — no app store approval, fastest iteration loop. The mobile roguelite space is a longer-term opportunity worth preserving. No Steam release planned initially; distribution via direct download or web export.
>
> **Rejected:** Mobile-first (higher setup friction, slower iteration for initial development). Immediate web export target (adds complexity before the core loop is validated).

### 8.1 Layout Strategy

> **✓ Decision: Portrait-first layout — persistent action panel on desktop, overlay drawer on mobile**
>
> **Rationale:** Portrait orientation suits the combat screen naturally — enemies above, player below, action bar at bottom — and scales more cleanly to mobile than landscape. One layout system with two presentations: the action panel lives permanently on the right side on desktop and slides up or toggles on mobile. The core play area never changes across platforms.
>
> **Rejected:** Landscape-first (awkward on mobile, less natural for row-based combat UI). Separate desktop and mobile layouts (doubles UI maintenance burden).

**Rough portrait layout:**
```
┌─────────────────────┐
│   ENEMY BACK ROW    │
│   ─────────────────  │
│   ENEMY FRONT ROW   │
│                     │
│   ─────────────────  │
│   PLAYER FRONT ROW  │
│   PLAYER BACK ROW   │
│                     │
│   [ ACTION BAR ]    │
└─────────────────────┘

Desktop: action panel always visible on right
Mobile:  action panel overlays on demand
```

---

## 9. Technical Constraints

These are enforced from day one. Retrofitting any of these later is expensive.

> **✓ Decision: All input via abstract actions — never raw device events**
>
> **Rationale:** Hardcoded mouse/keyboard input makes touch support a rewrite, not a mapping. Every interaction is defined as a Godot input action (`ui_confirm`, `action_attack`, `item_use`). Physical inputs — touch, mouse, keyboard, controller — are mapped to actions separately.

> **✓ Decision: UI built with anchors and Container nodes — no fixed pixel positions**
>
> **Rationale:** Fixed pixel positions break at different resolutions and screen sizes. Design to a virtual reference resolution; Godot's anchor and Container system handles scaling automatically. All UI sizing uses relative units.

> **✓ Decision: Save system behind an abstraction layer from day one**
>
> **Rationale:** Godot's `FileAccess` paths differ per platform. A single save interface makes the storage layer swappable without touching game logic. Save data stored as JSON for debuggability and forward compatibility as the game evolves.

> **✓ Decision: Every meaningful game event has a visual representation — audio is supplementary**
>
> **Rationale:** Mobile devices interrupt audio (calls, silent mode, headphone removal). Nothing important should rely on audio feedback alone. This is good game design regardless; mobile makes it non-negotiable.

---

## 10. Open Questions

These must be resolved before implementation of their respective systems. They are the agenda for future design sessions.

### Engine & Platform
- **`[OPEN]`** Confirm web export target and timeline — when does desktop-first become desktop + web?

### Navigation & Structure
- **`[OPEN]`** Exact visual language for door symbols — to be decided in UI/art direction session.

### Combat
- **`[OPEN]`** Do vessel and companion share a row assignment or occupy rows independently?
- **`[OPEN]`** Exact action economy per turn — move + ability + items, or action point pool?
- **`[OPEN]`** Enemy intent telegraphing — visible or hidden?

### Items
- **`[OPEN]`** Starting inventory size and maximum?
- **`[OPEN]`** Item acquisition — loot drops, wandering soul merchant, or both?
- **`[OPEN]`** Soul-carried items: shared inventory slots or separate soul layer?

### Companions
- **`[OPEN]`** Bound companion revival mechanism?
- **`[OPEN]`** Can bound and summoned companions be active simultaneously?

### Vessels
- **`[OPEN]`** Number of vessels at MVP — suggested minimum: 3.
- **`[OPEN]`** Specific unlock conditions per vessel — vessel design session required.

---

## 11. Roadmap Notes

Items noted for future consideration, not in current scope.

| Note | Context |
|---|---|
| **Soul questionnaire at character creation** | Post-MVP. Questions asked when the player first creates their soul — introspective rather than mechanical, answers colour the soul's history and may influence narrative outcomes or unlock conditions. May also appear as events during runs. |
| **Tile grid combat** | Deferred from MVP. Front/back row is the MVP abstraction. Grid can be introduced post-MVP if the design demands it. |
| **Resonance Imprints** | Meta-progression Layer 3. Soul retains a passive echo after each completed run. Post-MVP. |
| **Dungeon Memory** | Meta-progression Layer 4. Purgatory shifts based on cumulative run history. Stretch goal. |
| **Additional floor depth** | MVP ships with 1–2 floors. Floor 3 is a content addition, not a system change. |

---

*Soul Protocol v0.4 — Consolidated design decisions document. Ready for version control.*
*Next session: resolve open questions → begin Phase 0 (proof of concept) requirements.*
