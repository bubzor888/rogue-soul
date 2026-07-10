## MODIFIED Requirements

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
