## MODIFIED Requirements

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

## REMOVED Requirements

### Requirement: [HLD-VESSEL-004] MVP Vessel Count
**Reason**: Scoping and MVP decisions do not belong in the spec system.
**Migration**: None required — no implementation exists.

---

### Requirement: [HLD-VESSEL-005] Item Slot Count
**Reason**: There is no per-vessel item slot limit. Players are constrained only by what they can acquire during a run. The `MAX_ITEM_SLOTS` constant and `item_slot_count` per vessel are removed from the design.
**Migration**: Remove `item_slot_count` from vessel data definitions and `MAX_ITEM_SLOTS` from the architecture. Review HLD-ARCH-004 (T-4) which references this concept.

---

### Requirement: [HLD-VESSEL-006] Solo Vessel Archetype
**Reason**: No longer a design requirement. Solo vessels (Hedge Knight, Paladin, Battle Wizard) are distinct by narrative and ability set, not by a compensating-advantages rule.
**Migration**: None required — no implementation exists.
