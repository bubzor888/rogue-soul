## Purpose
Defines the vessel system — vessels as the class system, vessel identity, unlock conditions, the seven-vessel hierarchy, and run length per tier.
## Requirements
### Requirement: [HLD-VESSEL-001] Vessel as Class
The vessel the soul inhabits each run SHALL be the class system. Vessels are chosen before the run from the pool the soul has unlocked. Each vessel has a fixed set of base abilities that do not change during the run.

#### Scenario: No in-run class building
- **WHEN** the player is mid-run
- **THEN** the vessel's base abilities cannot be changed, replaced, or upgraded

#### Scenario: Variable layer
- **WHEN** the player builds their loadout
- **THEN** variability comes from the item inventory and companion — not from the vessel's fixed abilities

### Requirement: [HLD-VESSEL-002] Vessel Identity
A vessel SHALL be a recently-deceased person, not a class archetype. Their circumstances at death define their capabilities. Each vessel has a name, lore, and a specific set of abilities reflecting who they were in life.

#### Scenario: Vessel is a person
- **WHEN** a vessel is presented in the selection screen
- **THEN** the vessel has a name, a cause of death, and a lore fragment — not just a class label

---

### Requirement: [HLD-VESSEL-003] Vessel Unlock Conditions
Vessels SHALL be unlocked by completing runs, following the erosion hierarchy. The Pilgrim is available from the start. Completing a run with any vessel unlocks the vessels directly above it in the hierarchy (one tier higher, on the same erosion path).

| Vessel | Tier | Unlocked by completing a run with… |
|---|---|---|
| The Pilgrim | 1 | Available from the start |
| The Hedge Knight | 2 | The Pilgrim |
| The Drifter | 2 | The Pilgrim |
| The Paladin | 3 | The Hedge Knight |
| The Battle Wizard | 3 | The Hedge Knight |
| The Shaman | 3 | The Drifter |
| The Ranger | 3 | The Drifter |

#### Scenario: Pilgrim always available
- **WHEN** a player starts the game
- **THEN** the Pilgrim is selectable without any prior run completion

#### Scenario: Hierarchy unlock
- **WHEN** a player completes a run with the Pilgrim
- **THEN** the Hedge Knight and the Drifter become available

#### Scenario: Tier 3 unlock
- **WHEN** a player completes a run with the Hedge Knight
- **THEN** the Paladin and the Battle Wizard become available

---

### Requirement: [HLD-VESSEL-007] Vessel Hierarchy and Narrative Tree
The seven vessels SHALL be organized into three tiers representing different degrees of soul erosion. The tree runs **backward through the soul's history** — higher-tier vessels are earlier, more intact versions of the same soul. Full narrative detail in `docs/soul_protocol_narrative.md`.

| Vessel | Tier | Erosion path | Companion | Run length |
|---|---|---|---|---|
| The Pilgrim | 1 — Most eroded | Endpoint of all paths | None | 1 floor |
| The Hedge Knight | 2 — Midpoint | Solo path → Pilgrim | None | 2 floors |
| The Drifter | 2 — Midpoint | Companion path → Pilgrim | Ferret | 2 floors |
| The Paladin | 3 — Origin | Solo → Hedge Knight | None | 3 floors |
| The Battle Wizard | 3 — Origin | Solo → Hedge Knight | None | 3 floors |
| The Shaman | 3 — Origin | Companion → Drifter | Spirit animal | 3 floors |
| The Ranger | 3 — Origin | Companion → Drifter | Bear | 3 floors |

**Erosion paths:**
```
The Paladin      →  \
The Battle Wizard →   The Hedge Knight  →
                                           The Pilgrim
The Shaman       →  \
The Ranger       →    The Drifter       →
```

**Tier narrative register:**
- **Tier 1** — Seeks Solace as survival. Most eroded; lightest burden; passes the guardian's judgment most easily.
- **Tier 2** — Seeks Solace as replacement purpose. Something that gave life structure is lost; Solace becomes a substitute.
- **Tier 3** — Seeks Solace as aspiration. Intact enough to want it from a position of relative wholeness.

**Narrative inversion:** Unlocking higher-tier vessels means playing *earlier* in the soul's history. The Pilgrim on replay is understood differently once the player has seen the more intact versions of the same soul.

#### Scenario: Tier determines run length
- **WHEN** a player selects a vessel
- **THEN** the run consists of floors equal to the vessel's tier (Tier 1 = 1 floor, Tier 2 = 2 floors, Tier 3 = 3 floors)

#### Scenario: Shared floors
- **WHEN** a Tier 3 vessel completes their origin floor
- **THEN** they proceed through their Tier 2 vessel's floor and finally the Pilgrim's floor — the same floors, experienced from a more intact soul

#### Scenario: Narrative connection across vessels
- **WHEN** a player reads lore fragments across multiple vessels
- **THEN** the fragments collectively reveal the soul's history — later vessels providing context that reframes earlier ones

