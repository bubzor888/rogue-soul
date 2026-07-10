## Purpose
Defines the MVP milestones and what is in and out of scope for each.
## Requirements
### Requirement: [SCOPE-001] MVP1 — Headless Single Floor
The game SHALL be playable end-to-end on a single floor (Floor 3 — The Threshold) with The Pilgrim in headless mode. No UI is required. The core game loop must be fully functional and testable via `AIPlayerAgent`.

**In scope:**
- The Pilgrim vessel with all confirmed abilities (Read the Road, Good as New)
- The Pilgrim's starting items (see `LLD-ITEMS-004`)
- Floor 3 room generation and encounter patterns (see `lld-floor-structure`, `lld-encounter-patterns`)
- Full combat system: omen cycle, status effects, vulnerability, action buckets (see `hld-combat-system`)
- Omen deck assembly: Pilgrim vessel cards + floor pool cards (see `lld-omen-mechanics`, `lld-omen-cards`)
- Post-combat loot choice (see `HLD-COMBAT-012`)
- The Judge as final boss (see `HLD-RUN-004`)
- All Floor 3 normal and elite drop pools (see `LLD-ITEMS-005`, `LLD-ITEMS-006`, `LLD-ITEMS-007`, `LLD-ITEMS-008`)
- Persistence (save/load), RNG seeding, headless execution (see `lld-technical-architecture`)
- Temporary companion mechanic triggered by Worn Map (see `LLD-ITEMS-004`, `lld-memory-fragments`)

**Out of scope (deferred):** UI, audio, additional vessels, floor 2, floor 1, meta-progression.

#### Scenario: MVP1 complete
- **WHEN** MVP1 is complete
- **THEN** a full Pilgrim run on Floor 3 can be executed headlessly from start to Judge encounter with all systems functional

---

### Requirement: [SCOPE-002] MVP2 — Playable with UI
The game SHALL be fully playable with a complete UI layer. All MVP1 systems remain functional; the player can now play through a Pilgrim run using the actual game interface. The interface SHALL be verified first as a **mobile-sized web build** (the primary release target — see `LLD-PLATFORM-005`); running the same build in a desktop window is permitted for development iteration.

**In scope:**
- All MVP1 systems
- Full presentation layer: combat screen, action bar, omen display, inventory, door selection
- Single portrait, touch-first layout (see `lld-platform-constraints`, `LLD-PLATFORM-001`)
- Web export as the first release vehicle (Compatibility renderer, Web export preset — see `LLD-PLATFORM-005`)
- Room navigation UI (door symbols, look-ahead — see `HLD-RUN-001`, `HLD-RUN-002`)
- Non-combat room events: Memory Fragment, Wandering Soul, Elite Gate (see `lld-memory-fragments`, `lld-wandering-soul`, `lld-elite-gate`)
- Enemy intent display (see `HLD-COMBAT-009`)
- Post-combat loot selection UI
- Visual-first feedback for all game events (see `LLD-PLATFORM-004`)

**Out of scope (deferred):** Audio, additional vessels, additional floors, meta-progression, native second-target ports (iOS/Android/desktop — TBD, see `LLD-PLATFORM-005`).

#### Scenario: MVP2 complete
- **WHEN** MVP2 is complete
- **THEN** a player can complete a full Pilgrim run using the game UI in a mobile web build with no missing interactions

### Requirement: [SCOPE-003] MVP3 — Floor 2 and Tier 2 Vessels
The game SHALL support two-floor runs with the Tier 2 vessels (The Drifter and The Hedge Knight).

**In scope:**
- All MVP2 systems
- The Drifter vessel: Hardy, Ferret companion (Scavenge, omen card — see `LLD-OMEN-CARD-010`), starting items (see `LLD-ITEMS-009`)
- The Hedge Knight vessel: Last Stand, Charge, starting items (see `LLD-ITEMS-010`), vessel omen card (see `LLD-OMEN-CARD-009`), Iron Pendant omen card (see `LLD-OMEN-CARD-007`)
- Floor 2 (The Blurred Deep — Hedge Knight path; The Unmarked Edge — Drifter path) including floor-specific enemy pools, room generation, and omen deck floor cards
- Vessel unlock system (see `HLD-VESSEL-003`): completing a Pilgrim run unlocks Drifter and Hedge Knight
- Two-floor run structure: floor 2 then Floor 3

**Out of scope (deferred):** Tier 3 vessels, Floor 1, meta-progression, audio.

#### Scenario: MVP3 complete
- **WHEN** MVP3 is complete
- **THEN** a player can complete a full 2-floor run with either the Drifter or Hedge Knight

---

### Requirement: [SCOPE-004] MVP4 — Tier 3 Vessels and Full Run
The game SHALL support three-floor runs with all four Tier 3 vessels (The Paladin, The Battle Wizard, The Shaman, The Ranger).

**In scope:**
- All MVP3 systems
- All four Tier 3 vessels with full ability sets, starting items, and vessel omen cards
- Floor 1 (origin floors): The Crypt/Catacomb (Paladin/Battle Wizard path), The Contested Wilderness (Shaman/Ranger path)
- Three-floor run structure: Floor 1 → Floor 2 → Floor 3
- Vessel unlock system extended: completing Hedge Knight unlocks Paladin and Battle Wizard; completing Drifter unlocks Shaman and Ranger
- Full omen deck: all vessel cards, all floor pool cards

**Out of scope (deferred):** Meta-progression (post-run unlocks, Soul Codex), audio, native second-target ports (iOS/Android/desktop — TBD, see `LLD-PLATFORM-005`). The mobile web build is the primary target from MVP2 onward and is therefore NOT a deferred concern.

#### Scenario: MVP4 complete
- **WHEN** MVP4 is complete
- **THEN** a player can complete a full 3-floor run with any of the seven vessels

## Convention: MVP Tags on Open Items

All `[OPEN]` requirements and scenarios SHALL be tagged with the MVP they must be resolved by, using the format `[OPEN·MVP1]`, `[OPEN·MVP2]`, `[OPEN·MVP3]`, or `[OPEN·MVP4]`.

An untagged `[OPEN]` means the MVP assignment has not yet been determined.

**Examples:**
- `[OPEN·MVP1]` — must be resolved before MVP1 ships (blocks the core headless loop)
- `[OPEN·MVP2]` — must be resolved before MVP2 ships (blocks the playable UI release)
- `[OPEN·MVP3]` — required for tier 2 vessel content
- `[OPEN·MVP4]` — required for tier 3 vessel content or the complete game

#### Scenario: MVP tag on open item
- **WHEN** a new `[OPEN]` item is added to any spec
- **THEN** it SHALL include an MVP tag indicating the latest milestone by which it must be resolved
