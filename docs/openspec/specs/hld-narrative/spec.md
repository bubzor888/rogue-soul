## Purpose
Defines confirmed narrative design decisions — the soul's goal, Solace, the guardian's test (need not worthiness), and the floor atmosphere degradation model. Deferred narrative content lives in `lld-narrative`.
## Requirements
### Requirement: [HLD-NAR-001] Soul and Solace
The soul SHALL have sought a place called Solace across multiple lifetimes. Each run is one such attempt. Failure — whether by death on the journey or by failing the guardian's judgment — results in rebirth. Repeated failure erodes the soul across lives; the vessel roster reflects this erosion, with the Pilgrim as the most eroded endpoint. The soul's pull toward Solace SHALL feel like instinct rather than explicit memory — certain but inarticulate, isolating.

Solace is an earthly paradise of legend — widely dismissed as myth by those who have not felt its pull. Its name is chosen deliberately: a place you *need*, not one you conquer.

#### Scenario: Soul's knowledge of Solace
- **WHEN** the player begins a run with any vessel
- **THEN** the framing establishes that this soul has always been drawn toward Solace — it is not a new destination discovered mid-run

#### Scenario: Erosion is meaningful
- **WHEN** the player views the vessel roster after unlocking higher-tier vessels
- **THEN** the Pilgrim's simplicity reads as loss — the endpoint of a soul that was once more whole — not as a tutorial limitation

---

### Requirement: [HLD-NAR-002] The Guardian's Test
The guardian at the threshold of Solace SHALL judge need, not moral worthiness. The question is not *have you earned this* but *do you require this*. A soul that still has something — purpose, faith, certainty, a reason to return — does not qualify. The gate opens for those who have nowhere else to go.

This produces the game's central irony: the Pilgrim, hollowed by erosion, passes most easily. The Paladin, intact and purposeful, faces the most scrutiny.

The guardian's judgment also accounts for the journey taken. A soul that arrives having lost companions, purpose, or certainty along the way stands before the guardian differently from one that arrived untouched.

`[OPEN·MVP2]` Specific guardian dialogue per vessel to be written in `lld-narrative`.

#### Scenario: Pilgrim passes most easily
- **WHEN** the Pilgrim reaches the Judge
- **THEN** the encounter difficulty is the lowest of all vessels — the guardian sees a soul with nothing left to cling to

#### Scenario: Intact souls face harder judgment
- **WHEN** a Tier 3 vessel reaches the Judge
- **THEN** the encounter is meaningfully harder — the soul still retains too much for easy passage

---

### Requirement: [HLD-NAR-003] Floor Atmosphere Degradation
The game's environments SHALL degrade in groundedness as the soul approaches Solace. Tier 3 floors are specific, textured, and real — actual places from actual lives. Tier 2 floors are liminal — recognisable but fraying at the edges, geometry that doesn't quite hold. The final floor is dreamlike — fragments of all origin floors jumbled and partially dissolved, logic abandoned.

Enemy visual clarity on the final floor SHALL scale with vessel tier. The Pilgrim faces haze and half-shapes. Tier 3 vessels face sharp, fully resolved enemies. The floor communicates difficulty through atmosphere rather than a UI indicator.

`[OPEN·MVP2]` Specific visual direction for each floor register to be defined in a UI/art direction session.

#### Scenario: Final floor atmosphere for Pilgrim
- **WHEN** the Pilgrim plays the final floor
- **THEN** enemies appear as indistinct shapes; the environment is haze and dissolution; only the gate to Solace is rendered sharply

#### Scenario: Final floor atmosphere for Tier 3 vessel
- **WHEN** a Tier 3 vessel plays the final floor
- **THEN** enemies are crisp and fully present; fragments of the vessel's origin floor appear with some clarity; the floor pushes back harder because the soul remembers too much

#### Scenario: Gate to Solace always clear
- **WHEN** the player reaches the end of the final floor
- **THEN** the gate to Solace is fully rendered and visually unambiguous regardless of vessel tier or surrounding atmospheric state

