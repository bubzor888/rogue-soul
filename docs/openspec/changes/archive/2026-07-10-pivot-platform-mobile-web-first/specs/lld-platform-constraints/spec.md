## MODIFIED Requirements

### Requirement: [LLD-PLATFORM-001] Portrait-First Layout
The game SHALL use a single portrait layout as its one and only presentation. There is no separate desktop variant: the touch-first mobile presentation — action bar anchored at the bottom of the screen, with option/target selection surfaced via slide-up sheets — IS the presentation on every platform. The core play area (enemy positions, vessel and companion positions) MUST be preserved on any screen size; wider displays center and cap the portrait content rather than reflowing to a different layout.

**Reference resolution:** 390×844 (iPhone 14 portrait basis).

**Combat screen layout:**
```
┌─────────────────────┐
│  ENEMIES (side by   │
│  side as needed)    │
│                     │
│  PLAYER  COMPANION  │
│                     │
│   [ ACTION BAR ]    │  ← bottom bar; selection sheets slide up over a dimmed scene
└─────────────────────┘
```

A distinct large-screen/desktop presentation (e.g. a permanently docked side panel) is NOT required and is out of scope for MVP2; if a desktop second target is later pursued (see `LLD-PLATFORM-005`), it SHALL reuse this portrait core rather than define a second layout system.

#### Scenario: Single portrait layout on every platform
- **WHEN** the combat screen is rendered on a phone, in a mobile browser, or in a desktop window
- **THEN** the same portrait layout is used — bottom action bar with slide-up selection sheets — with no alternate desktop-only arrangement

#### Scenario: Wider displays center and cap, not reflow
- **WHEN** the game runs on a display wider than the portrait reference width
- **THEN** the portrait content is centered and width-capped, and the core play area remains visually identical; no right-docked panel or alternate layout appears

### Requirement: [LLD-PLATFORM-005] Web-First, Engine-Agnostic Development
The primary release target SHALL be mobile, delivered first as a **web export** playable in a mobile browser. Web export is an MVP2-era deliverable, not a deferred (MVP4) concern. Native iOS/Android and/or desktop remain viable **second targets (TBD)** and SHALL NOT be excluded.

To keep any second-target port a minimal-rewrite effort, the engine SHALL remain platform-agnostic: all persistence goes through `PersistenceService` (`LLD-ARCH-007`) and all input through abstract Godot input actions (`LLD-PLATFORM-002`), so the Domain and Application layers contain no platform-specific code. Godot's web export persists `user://` to the browser's IndexedDB; the only web-specific persistence concern is ensuring the asynchronous IndexedDB sync is flushed so saves survive a reload — a detail contained entirely within `PersistenceService` (e.g. an `OS.has_feature("web")` branch), never a change to the engine or a second storage abstraction.

#### Scenario: First release is a mobile web build
- **WHEN** MVP2 is released
- **THEN** it ships as a web export playable in a mobile browser, not as a desktop-only download

#### Scenario: Second-target port needs no engine rewrite
- **WHEN** a native iOS/Android or desktop port is later pursued
- **THEN** no Domain or Application code requires modification; only export configuration, presentation scaling, and any `PersistenceService` web-flush branch differ

#### Scenario: Web save survives reload
- **WHEN** a save is written in the web build and the browser tab is reloaded
- **THEN** the save is still readable via `PersistenceService`, because the IndexedDB `user://` sync was flushed
