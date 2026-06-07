
### Requirement: [LLD-OMEN-MECH-001] Omen Cycle — Three-Card Draw
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

---

### Requirement: [LLD-OMEN-MECH-002] Timer Card and Status Effect Interaction
For **per-turn** status effects (Burning, Poisoned, Chilled, Mending, Hardened — see `HLD-COMBAT-006`), a higher timer card (3) is generally desirable — more ticks means more total value. For **omen-triggered** effects (Shocked), a lower timer card (1) is desirable — faster payoff on the stun. This creates different strategic priorities depending on what is active.

#### Scenario: High timer with Burning
- **WHEN** Burning is active and the timer card is 3
- **THEN** the Burning status ticks 3 times (total 15 fire damage base), making high timer cards more valuable in fire setups

#### Scenario: Low timer with Shocked
- **WHEN** Shocked is active and the timer card is 1
- **THEN** the stun triggers after 1 turn — making low timer cards actively desirable when Shocked is active

---

### Requirement: [LLD-OMEN-MECH-003] Deck Reshuffle
The omen deck SHALL reshuffle when depleted rather than exhausting. A fight that runs long will see cards repeat. The distribution of card numbers and effects in the deck determines long-fight behaviour.

#### Scenario: Deck depletion in a long fight
- **WHEN** all cards in the omen deck have been drawn
- **THEN** the deck reshuffles and drawing continues from the full deck

---

### Requirement: [LLD-OMEN-MECH-004] Deck Assembly
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
- **THEN** their contributed omen cards are removed from the deck at the next shuffle (or immediately — `[OPEN·MVP1]` exact timing)

---

### Requirement: [LLD-OMEN-MECH-005] Deck Size Framework
Deck size varies by combat composition. Target ranges:

| Combat type | Estimated deck size |
|---|---|
| Solo enemy fight, Floor 3 | ~16–18 cards |
| Multi-enemy fight, Floor 3 | ~20–24 cards |

At ~6 cards drawn per fight (2 omen cycles × 3 cards), any given card in a 20-card deck has ~30% chance of appearing. In a 16-card deck, ~37%.

`[OPEN·MVP1]` Exact deck sizes to be confirmed once floor pool and enemy contributions are fully designed. Target range: 16–24 cards per combat.

#### Scenario: Multi-enemy deck density
- **WHEN** two enemies are present in combat
- **THEN** both enemies' omen cards are in the deck, making it more dense and harder to predict than a solo-enemy combat

---

### Requirement: [LLD-OMEN-MECH-006] Overall Omens vs Individual Omens
Two distinct omen types SHALL exist:

| | Overall omen | Individual omen |
|---|---|---|
| **Source** | Omen deck card | Consumable, ability, or enemy action |
| **Target** | Whole side (all enemies, or the player) | One specific unit |
| **Duration** | Current omen cycle | Until next omen reset |

Both types clear at the omen reset. Individual omens applied mid-cycle clear at the *next* reset — they do not persist into the following cycle.

#### Scenario: Overall omen applied to enemy side
- **WHEN** a Burning omen card is played to the enemy side
- **THEN** all enemies on that side gain the Burning status for the cycle duration

#### Scenario: Individual omen does not affect whole side
- **WHEN** a player uses Fire Bomb (individual omen) against one enemy
- **THEN** only that specific enemy gains Burning — other enemies on the same side are unaffected

---

### Requirement: [LLD-OMEN-MECH-007] Vulnerability Non-Stacking
Two sources of the same vulnerability type on one target SHALL NOT stack. The cap is ×1.5 regardless of how many sources apply it. This applies across both overall and individual omen sources. See `HLD-COMBAT-007`.

#### Scenario: Overall + individual same vulnerability
- **WHEN** a Burning overall omen (Vulnerable Fire ×1.5) and a Combustible Oil (Vulnerable Fire ×1.5) are both active on one enemy
- **THEN** fire damage is multiplied by ×1.5 once — not ×2.25

---

### Requirement: [LLD-OMEN-MECH-008] Card Number Distribution
`[OPEN·MVP1]` The distribution of 1s, 2s, and 3s within the deck is unresolved. Distribution affects average cycle length and status effect value across a run. To be set during omen deck design.

#### Scenario: [OPEN·MVP1] Number distribution design
- **WHEN** the deck is designed
- **THEN** the ratio of 1/2/3 timer values across all card sources must be confirmed and documented here

---

### Requirement: [LLD-OMEN-MECH-009] Card Number — Fixed or Randomised
`[OPEN·MVP1]` Whether omen cards have a fixed printed number or whether the number is randomised per draw is unresolved. Current design assumption: number is fixed (printed on the card).

#### Scenario: [OPEN·MVP1] Fixed vs random number
- **WHEN** this is resolved
- **THEN** the mechanic is updated here and in the CombatState data model
