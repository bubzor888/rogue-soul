## ADDED Requirements

### Requirement: [HLD-META-001] Knowledge-Gated Progression Philosophy
Meta-progression SHALL feel like the soul becoming wiser — not the player buying power. Every permanent unlock MUST have a narrative justification rooted in what the soul has experienced. Currency grind is explicitly rejected.

#### Scenario: No currency grind
- **WHEN** a player wants to unlock a new vessel
- **THEN** there is no currency to spend; the unlock triggers from an in-game experience condition

---

### Requirement: [HLD-META-002] Soul Codex (MVP — Required)
The Soul Codex SHALL be a permanent record of enemies, events, and souls encountered. It grants in-run bonuses when the soul meets known entities. Narratively: the soul's autobiography reassembled fragment by fragment.

#### Scenario: Codex bonus on known enemy
- **WHEN** the player encounters an enemy they have faced before (recorded in the Codex)
- **THEN** an in-run bonus applies (e.g. reduced damage, revealed mechanic)

#### Scenario: New entry on encounter
- **WHEN** the player encounters an entity not yet in the Codex
- **THEN** a new Codex entry is created and persists across future runs

---

### Requirement: [HLD-META-003] Vessel Archive (MVP — Required)
The Vessel Archive SHALL be the pool of unlockable vessels. Each vessel has distinct abilities, a companion situation, and a fragment of purgatory lore tied to who they were in life. Vessels are unlocked by experience conditions evaluated against run history (see `HLD-VESSEL-003`).

#### Scenario: Vessel unlock triggers
- **WHEN** a run ends and unlock conditions are evaluated
- **THEN** any newly satisfied conditions unlock the corresponding vessels

---

### Requirement: [HLD-META-004] Resonance Imprints (Post-MVP)
After a completed run, the soul SHALL retain one passive echo — a scar or gift from the life just lived. Permanent across runs. Implementation deferred to post-MVP; the field `resonance_imprints` is reserved in MetaProgressionData schema now to avoid save version migration later.

#### Scenario: Schema reservation
- **WHEN** MetaProgressionData is serialised at MVP
- **THEN** `resonance_imprints` is present in the schema as an empty array, not omitted

---

### Requirement: [HLD-META-005] Dungeon Memory (Stretch Goal)
Purgatory itself SHALL shift based on cumulative run history — lost souls remember the player, sealed doors open after multiple visits, bosses evolve after first defeat. Deferred as a stretch goal. The field `dungeon_memory` is reserved in MetaProgressionData schema.

#### Scenario: Schema reservation
- **WHEN** MetaProgressionData is serialised at MVP
- **THEN** `dungeon_memory` is present in the schema as an empty dictionary, not omitted

---

### Requirement: [HLD-META-006] Run History
The game SHALL maintain a lightweight run history (RunSummary records) used for unlock condition evaluation and Soul Codex population. Full EventLog data is separate and is not part of persistent meta state.

#### Scenario: Run summary persists
- **WHEN** a run ends (win or loss)
- **THEN** a RunSummary is appended to MetaProgressionData.run_history and saved
