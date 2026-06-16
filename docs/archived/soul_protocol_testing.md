# Soul Protocol — Testing & Testability Decisions
## Version 0.2 · May 2026 · Solo Developer

> **Purpose:** This document records architecture and design decisions made specifically to support testing — playtesting, balance testing, and eventual AI-driven simulation. It is a companion to the main design document (`soul_protocol_v0_4.md`) and should be loaded alongside it when working on testability concerns.
>
> Confirmed decisions are marked **`✓`**.
> Open questions are marked **`[OPEN]`**.
> Decisions that must be implemented before other systems are marked **`[FOUNDATIONAL]`**.

---

## Table of Contents

1. [Testability Philosophy](#1-testability-philosophy)
2. [Headless Mode](#2-headless-mode)
3. [Seeded RNG](#3-seeded-rng)
4. [Event Logging](#4-event-logging)
5. [Debug Mode](#5-debug-mode)
6. [AI Player Architecture](#6-ai-player-architecture)
7. [Unit Testing](#7-unit-testing)
8. [Playtest Process](#8-playtest-process)
9. [Dependencies & Environment](#9-dependencies--environment)
10. [Implementation Order](#10-implementation-order)
11. [Open Questions](#11-open-questions)

---

## 1. Testability Philosophy

Testing is not bolted on at the end. The game's architecture is designed from day one so that:

- Any run can be reproduced exactly from a seed and a decision sequence.
- The game loop can execute without rendering or player input.
- Every meaningful event is recorded and inspectable.
- Balance can eventually be measured by simulation, not just intuition.

These constraints inform architecture decisions across the whole codebase, not just a debug overlay.

---

## 2. Headless Mode

### 2.1 Headless-First Development

> **✓ `[FOUNDATIONAL]` Decision: Headless execution is the default starting point — rendering and UI are layered on top of a working game loop, not the other way around**
>
> **Rationale:** If the game loop runs without a renderer from the start, it is never accidentally coupled to visual or input systems. This enforces the separation already required by the main doc's abstract input constraint, and means the action injector interface (needed for AI players) must exist before the UI does — the correct order of development.
>
> **Relationship to main doc:** The main doc already mandates abstract input actions (`ui_confirm`, `action_attack`, etc.) rather than raw device events. Headless-first is the natural extension of that decision: if input is already abstract, the game loop should not care whether those actions come from a human, a debug script, or an AI player.
>
> **Rejected:** UI-first development with headless added later (risks coupling, makes AI player interface painful to retrofit).

### 2.2 Headless Flag

> **✓ Decision: A single headless flag in a global autoload controls whether rendering and UI are active**
>
> **Implementation note (Godot):** A global autoload (e.g. `GameConfig`) holds a `headless: bool` constant. All rendering nodes and UI scenes check this flag at initialisation and either instantiate normally or skip entirely. The game loop, combat resolver, RNG, and event log never check this flag — they are always running.

---

## 3. Seeded RNG

### 3.1 Player-Visible Seeds

> **✓ Decision: Run seeds are player-visible and player-selectable, not just a debug feature**
>
> **Rationale:** Seed sharing is an established roguelite community feature. Exposing seeds costs nothing and adds value. It also means the seed display infrastructure is always present in release builds, simplifying testing — no special build needed to read a seed.

### 3.2 Split RNG Streams

> **✓ `[FOUNDATIONAL]` Decision: RNG is split into independent streams — one per domain — rather than a single shared stream**
>
> **Rationale:** A single stream means any change to the number or order of RNG calls in one domain (e.g. adding a new combat proc) shifts all downstream rolls across the whole run. This invalidates seeds silently and makes bugs unreproducible. Independent streams are resilient: a change to combat rolls does not affect room generation.
>
> **Defined streams (MVP):**
>
> | Stream | Responsibility |
> |---|---|
> | `STREAM_NAVIGATION` | Room type sequence, floor layout generation |
> | `STREAM_COMBAT` | Hit/miss, damage variance, enemy intent selection |
> | `STREAM_LOOT` | Item drops, loot table rolls, merchant inventory |
> | `STREAM_EVENTS` | Anomaly outcomes, Memory Fragment content selection, Echo Chamber content |
>
> **Implementation note (Godot):** Each stream is a separate `RandomNumberGenerator` instance initialised with a derived seed: `base_seed + stream_index`. All random calls within a domain use only that domain's RNG instance. Global `randf()` is never used.
>
> **✓ Decision: Stream seeds are derived deterministically from the base seed — `base_seed + stream_index`**
>
> **Rationale:** Simplest correct approach. A single base seed fully determines a run; no need to store or display multiple seeds. Surgical re-rolling of individual streams is not a requirement.

### 3.3 Stream Monitor (Debug)

> **✓ Decision: In debug mode, a live readout shows the current call count for each RNG stream**
>
> **Rationale:** Stream contamination — a roll accidentally made on the wrong stream — is silent and produces subtly wrong behaviour. The call count monitor makes contamination visible immediately.

### 3.4 Seed Recording

> **✓ Decision: The run seed is automatically written to the run log on run end (death or completion)**
>
> **Rationale:** When a tester or player reports unexpected behaviour, the seed is always recoverable from the log without requiring a screenshot or manual note. Format: `seed: <value>, vessel: <id>, depth: <1|2|3>`.

---

## 4. Event Logging

### 4.1 Black Box Recorder

> **✓ `[FOUNDATIONAL]` Decision: A structured event log records every meaningful game event throughout a run**
>
> **Rationale:** The event log is the primary tool for diagnosing unexpected behaviour — in manual playtesting, in AI simulation, and eventually in player-submitted bug reports. It should be possible to reconstruct exactly what happened in a run from the log alone.
>
> **Logged event categories:**
>
> | Category | Examples |
> |---|---|
> | Navigation | Room entered, door chosen, floor transition |
> | Combat | Turn started, action taken, damage dealt/received, unit death, row change |
> | Items | Item acquired, item used, item broken (durability expired) |
> | Companions | Companion summoned, companion damaged, companion died, revival triggered |
> | RNG | Every roll: stream, call index, raw value, resolved outcome |
> | Meta | Run started (seed, vessel, depth), run ended (cause, floor reached, rewards) |
>
> **✓ Decision: RNG roll logging is gated behind the debug flag — outcome events are always logged, raw rolls are not**
>
> **Rationale:** Raw roll volume in AI simulation would drown actionable signal. Balance analysis requires outcomes (damage dealt, item acquired, room type generated), not the rolls that produced them. Full roll logging is available in debug mode when drilling into a specific seed.

### 4.2 Log Format

> **✓ Decision: Event log is structured JSON — one event object per line (newline-delimited JSON)**
>
> **Rationale:** Human-readable for manual inspection, machine-parseable for AI simulation analysis. Newline-delimited (rather than a single JSON array) means the log can be written incrementally and read partially without loading the whole file.
>
> **Minimum fields per event:** `{ "tick": <int>, "category": <string>, "event": <string>, "data": { ... } }`
>
> **✓ Decision: Event log uses an in-memory buffer during play, flushed to file at checkpoints and on run end**
>
> **Rationale:** Continuous file I/O per event adds overhead, especially on mobile. The buffer is flushed at natural checkpoints — floor transitions and boss completions — so a mid-run crash still yields a partial log covering the last completed floor. Full flush on run end (death or completion) captures everything. Since any run is reproducible from its seed, a partial crash log is sufficient to locate the problem.

### 4.3 In-Game Log Overlay (Debug)

> **✓ Decision: In debug mode, a scrollable overlay displays the event log in real time**
>
> **Rationale:** Allows a tester to observe what the game believes is happening without switching windows. Pairs with the stream monitor. Not present in release builds.

---

## 5. Debug Mode

### 5.1 The Debug Flag

> **✓ Decision: Debug mode is controlled by a single flag in the global autoload — never by commented-out code**
>
> **Implementation note (Godot):** `GameConfig.debug: bool`. All debug UI nodes check this at `_ready()` and call `queue_free()` if false. Debug code paths in game logic are gated behind `if GameConfig.debug`. Release builds set this to false at export time.

### 5.2 Debug Features by System

Debug features are added when their respective system is built, not all at once. The following table records what is planned per system:

| System | Debug Features |
|---|---|
| **Core / RNG** | Seed display and override input, RNG stream call count monitor |
| **Navigation** | Room sequence override (specify next N room types manually), current floor visualiser |
| **Combat** | Unit stat inspector, force-set HP on any unit, force specific enemy intent, freeze enemy AI, skip combat (take reward only) |
| **Items** | Full item spawner, force specific loot drop, set full inventory loadout |
| **Companions** | Toggle companion permadeath on/off, force revival scenario |
| **Meta-progression** | Override Soul Codex state, grant/revoke vessel unlocks, selective progression reset |

### 5.3 Separation from Release

> **✓ Decision: Debug UI and tooling is always compiled into the build but gated by the debug flag — no separate debug build required**
>
> **Rationale:** A separate debug build risks divergence from the release build and adds export overhead for a solo developer. The flag approach means the tested build is always the release build with debug features turned off.

---

## 6. AI Player Architecture

### 6.1 Purpose

The AI player is a simulation agent that plays Soul Protocol without human input for the purpose of balance testing — measuring win rates, resource distributions, ability usage patterns, and outlier run outcomes across large sample sizes.

### 6.2 Prerequisites

The AI player depends on three systems that must exist first:

1. **Headless mode** — so simulations run at maximum speed with no rendering overhead.
2. **Seeded RNG** — so any interesting simulation result can be reproduced and inspected.
3. **Action injector** — a clean interface for submitting decisions to the game loop externally.

### 6.3 Action Injector Interface

> **✓ Decision: The game loop exposes a single action interface — `submit_action(action: Dictionary) -> GameState` — that the UI, debug tools, and AI player all use**
>
> **Rationale:** If the UI already submits actions through an abstract interface rather than directly manipulating game state, the AI player is just another caller of that interface. No special AI mode required.
>
> **Contract:** Given a `GameState`, the caller queries `get_legal_actions() -> Array[Dictionary]` to see what is valid, then calls `submit_action()` with one of those actions. The game advances and returns the new `GameState`. The game loop never cares who called it.

### 6.4 Game State Serializer

> **✓ Decision: Complete game state can be serialized to JSON at any point during a run**
>
> **Rationale:** Pairs with the save abstraction layer already planned in the main doc (saves are JSON). A full state snapshot mid-run enables: saving exact AI player scenarios for inspection, resuming a run from a specific state for targeted testing, and diffing states before and after an action.

### 6.5 AI Player Strategies (Planned)

AI players are not a single agent. Different strategies test different things:

| Strategy | Purpose |
|---|---|
| **Random** | Baseline. Chooses legal actions uniformly at random. Establishes floor win rate and resource floors. |
| **Greedy** | Always chooses the highest-immediate-value action (most damage, most healing, etc.). Tests whether obvious strategies are over-rewarded. |
| **Heuristic** | Rule-based strategy approximating a competent human player. Primary balance reference. |
| **Adversarial** | Attempts to break the game — exploit edge cases, max-stack items, etc. Finds outliers and ceiling cases. |

**✓ Decision: The Random agent is built as soon as the action injector exists — before content is complete. Greedy, Heuristic, and Adversarial agents are deferred until the MVP core loop is stable.**

**Rationale:** The Random agent doubles as an integration test for the action injector and headless loop — it has value before any balance data is meaningful. The more sophisticated agents require stable content to produce useful signal; running them against a half-built game wastes tuning effort.

---

## 7. Unit Testing

### 7.1 Framework

> **✓ Decision: GdUnit4 is the unit testing framework for Soul Protocol**
>
> **Rationale:** GdUnit4 is actively maintained, confirmed compatible with Godot 4.6.x, supports headless command-line test runs, and generates JUnit XML reports — machine-readable output that will be useful when AI simulation results need aggregating. Installed as a Godot plugin via the Asset Store, not a separate toolchain.
>
> **Rejected:** GUT (less active for Godot 4, weaker CI integration). No unit testing (not viable given the complexity of the RNG, combat resolver, and event log systems).
>
> **Version:** GdUnit4 v6.1.x — see Section 9 for full dependency details.

### 7.2 What Gets Unit Tested

Unit tests cover pure logic systems with no scene dependency. These are the high-value targets where a silent bug has large downstream consequences.

| System | What to Test |
|---|---|
| **RNG** | Correct stream initialisation from seed; derived stream seeds produce expected values; no cross-stream contamination; same seed always produces same sequence |
| **Combat resolver** | Damage calculations including row modifiers; legal action generation given a game state; action application produces correct state delta; edge cases (0 HP, full HP, empty inventory) |
| **Event log** | Events written in correct format; buffer flushes at checkpoints; log is complete on run end; JSON is valid and parseable |
| **Game state serializer** | Round-trip: serialise → deserialise produces identical state; state diff correct before and after a known action |
| **Action injector** | All legal actions returned for a known state; illegal actions rejected; state advances correctly after a valid action |

### 7.3 What Is Not Unit Tested

The following are explicitly out of scope for unit tests. They are covered by playtesting and manual review.

- Scene composition and node hierarchy
- UI layout, sizing, and visual correctness
- Animation and audio
- Input mapping and device handling
- Game feel — pacing, difficulty, moment-to-moment experience

> **Rationale:** Automating visual and feel tests adds maintenance overhead without proportional value for a solo developer. These change frequently and are best evaluated by a human playing the game.

### 7.4 Test Organisation

Tests live in a top-level `tests/` directory, not distributed with the game's scene tree. Each system under test has its own file: `tests/test_rng.gd`, `tests/test_combat_resolver.gd`, etc.

Tests must pass before any AI simulation run is considered valid. They are not required to pass before every commit during active development.

---

## 8. Playtest Process

### 8.1 Playtest Note Format

Every manual playtest session produces a structured note. Lightweight by design — the goal is a record that takes under two minutes to fill in.

```
## Playtest Note
Date: YYYY-MM-DD
Seed: <value>
Vessel: <id>
Depth chosen: <1|2|3>
Floor reached: <n>
Run outcome: <death|completion>

### What was tested
<focus of this session — e.g. "combat action economy", "item durability tension">

### What felt wrong
<anything that produced frustration, confusion, or felt unfair>

### What felt good
<anything that produced a satisfying decision or moment>

### Balance flags
<anything that seemed too strong, too weak, or too swingy>

### Seed worth revisiting
<yes/no — if yes, why>
```

### 8.2 Playtest Log

All playtest notes are stored in a `playtests/` directory in the project repository, one file per session, named `YYYY-MM-DD-<focus>.md`. This creates a chronological record of how the game felt across development and makes it possible to correlate balance changes with feel shifts over time.

---

## 9. Dependencies & Environment

The authoritative reference for setting up a development environment. Versions are pinned to what was current at the time of writing — check for updates before setup, but do not upgrade without verifying compatibility.

### 9.1 Engine

| Dependency | Version | Notes |
|---|---|---|
| **Godot Engine** | 4.6.3 stable | GDScript build, not Mono/C#. Download from [godotengine.org](https://godotengine.org). |

### 9.2 Godot Plugins

Installed via the Godot Asset Store inside the editor.

| Plugin | Version | Purpose | Install |
|---|---|---|---|
| **GdUnit4** | v6.1.x | Unit testing framework | Search "GdUnit4" in the Asset Store, or direct: [store.godotengine.org](https://store.godotengine.org/asset/mikeschulze/gdunit4/) |

> **Version note:** GdUnit4 versioning tracks Godot API changes. v6.1.x is the correct line for Godot 4.6.x. v6.0.x introduced the Godot 4.5 API rebuild but only covers 4.5 and 4.5.1 — not 4.6. v5.x is the line for Godot 4.3–4.4 and should not be used with 4.6. When installing, confirm the version shown in the Asset Store matches v6.1.x.

### 9.3 No External Toolchain Required

Soul Protocol uses GDScript only. No build tools, package managers, or language runtimes beyond Godot itself are required. If this changes (e.g. a Python script for AI simulation analysis), dependencies will be added here.

### 9.4 Version Control

Git. The `.gitignore` should exclude:
- `.godot/` (engine-generated cache)
- `*.uid` files if generated
- Exported build output directories

The following should be committed:
- `tests/` — unit tests are part of the project
- `playtests/` — playtest notes are part of the project record

---

## 10. Implementation Order

Testability features must be built in dependency order. The following sequence is enforced:

```
1. Global autoload (GameConfig) — headless flag, debug flag
2. RNG system — split streams, seeded, stream monitor
3. Event log — in-memory buffer, JSON format, checkpoint flush
4. Action injector interface — game loop accepts external action input
5. Game state serializer
6. Unit tests for steps 2–5 (RNG, event log, serializer, action injector)
7. Debug overlay — seed display, event log viewer, stream monitor
8. Per-system debug tools — added as each system is built
9. Random AI agent — immediately after action injector exists (integration test)
10. Heuristic and other AI agents — after MVP core loop is stable
```

Nothing in steps 2–10 should be started before step 1 is in place.

---

## 11. Open Questions

No open questions at this time. New questions will be added here as subsequent systems are designed.

---

*Soul Protocol Testing v0.2 — Companion to soul_protocol_v0_4.md*
*Added: unit testing framework, playtest process, dependencies section. Implementation order updated.*
