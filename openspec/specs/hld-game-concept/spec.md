
### Requirement: [HLD-CONCEPT-001] Core Premise
The game SHALL be a roguelite in which an ancient soul inhabits the recently deceased (vessels) and descends through purgatory to recover fragments of its own memory. The soul's goal is understanding why it is trapped — not escaping, not finding a person, not fulfilling a mission.

#### Scenario: Run framing
- **WHEN** the player begins a run
- **THEN** the narrative framing is that the soul is inhabiting a specific recently-deceased person, not choosing an abstract class

#### Scenario: Death loop coherence
- **WHEN** the vessel dies
- **THEN** the soul loses its grip on what it just remembered, but retains accumulated meta knowledge (Soul Codex, unlocked vessels)

---

### Requirement: [HLD-CONCEPT-002] Setting
The game's setting SHALL be purgatory — a liminal space that takes the shape of things the dead remember. There are no gods or pantheon. The purgatory simply exists — ancient, indifferent, full of lost things.

#### Scenario: Environmental coherence
- **WHEN** a room or area is presented
- **THEN** it MUST feel like layered memory — architecture from different eras, places that bleed between what they were and what they meant

---

### Requirement: [HLD-CONCEPT-003] Narrative Goal — Solace
The soul SHALL have sought a place called Solace across multiple lifetimes. Each failure — whether by misfortune during the journey or by failing the guardian's judgment — results in rebirth. Repeated failure erodes who the soul is across lives.

#### Scenario: Erosion across vessels
- **WHEN** a player views the vessel roster
- **THEN** the Pilgrim (most eroded vessel) represents the endpoint of accumulated failure, not a starting archetype

---

### Requirement: [HLD-CONCEPT-004] Run Length Target
A standard run SHALL target 20–30 minutes at MVP. This is designed to expand in later versions. See `HLD-RUN-003` for floor depth choice.

#### Scenario: Run length at MVP
- **WHEN** a player completes a 2-floor run
- **THEN** total elapsed time SHOULD fall within 20–30 minutes

---

### Requirement: [HLD-CONCEPT-005] Roguelite (Not Roguelike)
The game SHALL be a roguelite — runs reset on death, but meta-progression persists. Meta-progression is knowledge-gated (experience conditions), not currency-gated. See `HLD-META-001`.

#### Scenario: Run reset on death
- **WHEN** the vessel dies
- **THEN** run state (items, floor position, vessel HP) resets; meta state (Soul Codex, unlocked vessels) persists
