## MODIFIED Requirements

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
