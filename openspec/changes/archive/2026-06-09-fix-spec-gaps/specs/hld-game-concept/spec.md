## MODIFIED Requirements

### Requirement: [HLD-CONCEPT-001] Core Premise
The game SHALL be a roguelite in which an ancient soul inhabits the recently deceased (vessels) and descends through purgatory to recover fragments of its own memory. The soul's goal is understanding why it is trapped — not escaping, not finding a person, not fulfilling a mission. Full narrative design: see `hld-narrative`.

#### Scenario: Run framing
- **WHEN** the player begins a run
- **THEN** the narrative framing is that the soul is inhabiting a specific recently-deceased person, not choosing an abstract class

#### Scenario: Death loop coherence
- **WHEN** the vessel dies
- **THEN** the soul loses its grip on what it just remembered, but retains accumulated meta knowledge (Soul Codex, unlocked vessels)
