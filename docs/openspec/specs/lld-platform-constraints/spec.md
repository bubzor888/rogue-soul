
### Requirement: [LLD-PLATFORM-001] Portrait-First Layout
The game SHALL use a portrait-first layout. One layout system with two presentations: the action panel is permanently visible on the right side on desktop, and slides up or toggles as an overlay on mobile. The core play area MUST be identical across both platforms.

**Reference resolution:** 390×844 (iPhone 14 portrait basis).

**Combat screen layout:**
```
┌─────────────────────┐
│  ENEMIES (side by   │
│  side as needed)    │
│                     │
│  PLAYER  COMPANION  │
│                     │
│   [ ACTION BAR ]    │
└─────────────────────┘
Desktop: action panel always visible on right
Mobile:  action panel overlays on demand
```

#### Scenario: Same core area across platforms
- **WHEN** the same scene is rendered on desktop and on mobile
- **THEN** the combat area (enemy positions, player and companion positions) is visually identical; only the action panel presentation differs

---

### Requirement: [LLD-PLATFORM-002] Abstract Input
All input SHALL be handled via abstract Godot input actions — never raw device events. Every interaction is defined as a named action (e.g. `ui_confirm`, `action_attack`, `item_use`). Physical inputs (touch, mouse, keyboard, controller) are mapped to actions separately.

#### Scenario: Touch and keyboard parity
- **WHEN** a player taps the screen (mobile) or presses a key (desktop)
- **THEN** both trigger the same named input action; the game code never distinguishes between input devices

---

### Requirement: [LLD-PLATFORM-003] Anchor-Based UI
All UI MUST be built with anchors and Container nodes — no fixed pixel positions. All UI sizing uses relative units. Design to the reference resolution; Godot's anchor system handles scaling.

#### Scenario: Resolution independence
- **WHEN** the game runs at a non-reference resolution
- **THEN** UI elements scale and reposition via anchors; no UI element has a hardcoded pixel coordinate

---

### Requirement: [LLD-PLATFORM-004] Visual-First Events
Every meaningful game event SHALL have a visual representation. Audio is supplementary — nothing important may rely on audio feedback alone.

#### Scenario: Silent mode gameplay
- **WHEN** a player's device is in silent mode
- **THEN** all game outcomes (damage, status effects, item breaks) remain fully communicated through visual feedback alone

---

### Requirement: [LLD-PLATFORM-005] Desktop-First Development
Initial development SHALL target desktop. Mobile is kept as a future platform option but does not constrain MVP development velocity. No Steam release is planned initially; distribution via direct download or web export.

#### Scenario: [OPEN·MVP4] Web export timeline
- **WHEN** web export is targeted
- **THEN** PersistenceService may need a localStorage/IndexedDB backend; this decision (T-10) must be resolved before web export work begins
