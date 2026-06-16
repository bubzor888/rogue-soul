## Purpose
Defines the omen system mechanics — the three-card draw cycle, cycle timing via timer cards, deck assembly from four sources, deck reshuffle, and the distinction between overall (whole-side) and individual (single-unit) omens.
## Requirements
### Requirement: [HLD-OMEN-001] Omen Cycle — Three-Card Draw
Each combat turn, exactly three omen cards SHALL be drawn from the deck and resolved as follows:
1. The **player chooses one card** and decides which side to apply it to (player side or enemy side)
2. **One card is randomly selected** from the remaining two and applied to the other side
3. **The final remaining card** is not played — its number (1, 2, or 3) becomes the cycle duration (turns until next draw)

#### Scenario: Player controls one card per turn
- **WHEN** three omen cards are drawn
- **THEN** the player selects exactly one card and chooses its target side; the other two are resolved automatically

#### Scenario: Timer card sets duration
- **WHEN** the leftover card is a 3
- **THEN** the current omen cycle lasts 3 turns before the next draw occurs

#### Scenario: Forced bad draw
- **WHEN** all three drawn cards are unfavourable to the player
- **THEN** the player must still choose one for their side — there is no option to skip; the choice becomes which effect is least damaging to absorb

### Requirement: [HLD-OMEN-002] Timer Card and Status Effect Interaction
For **per-tick** status effects (Burning, Poisoned, Chilled, Mending, Hardened — see `HLD-COMBAT-006`), a higher timer card (3) is generally desirable — more ticks means more total value. For **shift-triggered** effects (Shocked, Exposed), a lower timer card (1) is desirable — the shift fires sooner, delivering the stun or the Vulnerable (Physical) faster. This creates different strategic priorities depending on what is active.

#### Scenario: High timer with Burning
- **WHEN** Burning is active and the timer card is 3
- **THEN** the Burning status ticks 3 times (total 15 fire damage base), making high timer cards more valuable in fire setups

#### Scenario: Low timer with Shocked
- **WHEN** Shocked is active and the timer card is 1
- **THEN** the stun triggers after 1 turn — making low timer cards actively desirable when Shocked is active

#### Scenario: Low timer with Exposed
- **WHEN** Exposed is active on the enemy side and the timer card is 1
- **THEN** the omen shift fires after 1 turn; Vulnerable (Physical) is applied to the affected units at the start of the next cycle — a short Exposed cycle delivers the vulnerability faster

---

### Requirement: [HLD-OMEN-003] Deck Reshuffle
The omen deck SHALL reshuffle when depleted rather than exhausting. A fight that runs long will see cards repeat. The distribution of card numbers and effects in the deck determines long-fight behaviour.

#### Scenario: Deck depletion in a long fight
- **WHEN** all cards in the omen deck have been drawn
- **THEN** the deck reshuffles and drawing continues from the full deck

---

### Requirement: [HLD-OMEN-004] Deck Assembly from Four Sources
A fresh omen deck SHALL be assembled at the start of each combat from four sources, all shuffled together:
1. **Vessel cards** — contributed by the active vessel (present in every combat)
2. **Item cards** — contributed by items the player currently carries
3. **Floor cards** — the ambient omen pool for the current floor (present in every combat on that floor)
4. **Enemy cards** — contributed by enemies present in this specific combat; removed when those enemies die

#### Scenario: Deck changes between combats
- **WHEN** the player enters a new combat with different enemies
- **THEN** the omen deck is reassembled from the current sources; enemy cards from the previous combat are not carried forward

#### Scenario: Enemy death removes their cards
- **WHEN** an enemy dies mid-combat
- **THEN** their contributed omen cards are removed immediately from the draw pile and discard pile; any of their cards already drawn into the active OmenCycleState remain for that cycle only and are not replaced

---

### Requirement: [HLD-OMEN-005] Omen Application Model
When an omen card is applied to a side, each eligible unit on that side receives its own individual StatusInstance. There is no shared whole-side state — every unit tracks its own status independently. Killing a unit removes only that unit's StatusInstances. Cleansing a unit removes only that unit's StatusInstances.

**Tag-conditional application:** Some omen cards specify a tag requirement. When such a card is applied, only units whose `enemy_tags` include the required tag receive a StatusInstance. Units that do not match receive nothing. If the card is steered to the player side and the player is not tagged, no effect is applied — this is always safe for the player with family-specific cards (e.g. Grave Knit, Thick Hide).

**Individual omens** from consumables, abilities, or enemy actions target one specific unit directly and follow the same StatusInstance model.

**Duration:** All status effects — whether sourced from omen cards or from individual actions — clear at the omen reset (when `remaining_ticks` reaches 0). Individual omens applied mid-cycle clear at the *next* reset; they do not persist into the following cycle.

#### Scenario: Omen card applies per-unit
- **WHEN** a Burning omen card is played to the enemy side and two enemies are present
- **THEN** each enemy receives its own Burning StatusInstance; killing one enemy removes only that enemy's StatusInstance; the other enemy's Burning is unaffected

#### Scenario: Tag-conditional card skips non-matching units
- **WHEN** Grave Knit is played to a side containing one Skeleton (tagged "undead") and one Plague Rat (tagged "beast")
- **THEN** only the Skeleton receives a Mending StatusInstance; the Plague Rat receives nothing

#### Scenario: Family card steered to player side — safe
- **WHEN** the player steers Grave Knit to their own side
- **THEN** no StatusInstance is applied (the player is not tagged "undead"); the enemy side does not receive healing that cycle

#### Scenario: Cleanse is unit-local
- **WHEN** the player uses a cleanse item targeting one enemy
- **THEN** only that enemy's matching StatusInstances are removed; all other units retain their statuses unchanged

#### Scenario: Individual omen does not affect whole side
- **WHEN** a player uses Fire Bomb (individual omen) against one enemy
- **THEN** only that specific enemy gains Burning — other enemies on the same side are unaffected

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

