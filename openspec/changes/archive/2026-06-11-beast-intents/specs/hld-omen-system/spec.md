## MODIFIED Requirements

### Requirement: [HLD-OMEN-006] Two-Tier Enemy Omen Contribution Model
Enemies contribute omen cards via two independent tiers. Each tier follows distinct copy-count and removal rules.

**Tier 1 — Family card (per-instance):** Each individual enemy instance adds 1 copy of its family-specific omen card to the combat deck. When an enemy dies, its family card copy is removed immediately from the draw pile and discard pile. When an enemy is added to combat mid-fight via a summon effect (e.g. Wolf Howl), its family card copy is injected into the draw pile immediately following the same rule — it is removed on death like any other enemy instance.

**Tier 2 — Type card (per-type):** Each *enemy type* present in the encounter adds exactly 1 copy of a secondary omen card to the combat deck, regardless of how many individual enemies of that type are present. The type card is only removed when the **last living enemy of that type** dies. A mid-combat summon of an existing type does not add a second type card — the type card already in the deck covers all instances of that type.

Not all enemy types have a type card. Totems and support entities are excluded from both tiers. Elemental enemies use their element-specific card (Burning, Chilled, Shocked) as their type card; this was already their second contribution before this model was formalised.

#### Scenario: Family card scales with enemy count
- **WHEN** three Plague Rats are present in combat
- **THEN** three copies of Thick Hide are added to the omen deck (one per rat)

#### Scenario: Type card does not scale with enemy count
- **WHEN** three Plague Rats are present in combat
- **THEN** exactly one copy of Exposed is added to the omen deck, not three

#### Scenario: Type card removed on last of type
- **WHEN** the last surviving Plague Rat dies
- **THEN** the single Exposed type card is removed from the draw pile and discard pile immediately

#### Scenario: Type card persists while any of that type survive
- **WHEN** two of three Plague Rats have died but one remains alive
- **THEN** the Exposed type card remains in the omen deck

#### Scenario: Mixed-type encounter with shared type card
- **WHEN** a Skeleton and a Zombie are both present in combat
- **THEN** two copies of Emboldened (Physical) are in the deck — one from the Skeleton type and one from the Zombie type, each removed independently when the last of its type dies

#### Scenario: Mid-combat summon injects family card
- **WHEN** a lone Wolf uses Howl and a new Wolf is summoned into combat
- **THEN** one Thick Hide card is injected into the draw pile immediately; the type card (Exposed) is NOT added again — it was already present for the wolf type

#### Scenario: Summoned enemy family card removed on death
- **WHEN** a summoned Wolf dies
- **THEN** its individual Thick Hide copy is removed from the draw pile and discard pile; if it was the last wolf, the Exposed type card is also removed
