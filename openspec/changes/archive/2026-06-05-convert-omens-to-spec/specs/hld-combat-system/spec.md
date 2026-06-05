## MODIFIED Requirements

### Requirement: [HLD-COMBAT-008] Omen System
All combat in Soul Protocol is governed by the omen system. Every combat turn three omen cards are drawn from a shared deck; the player chooses one card to apply to a side; one is applied randomly to the other side; the third sets the cycle duration. Full mechanics are defined in `lld-omen-mechanics`. Confirmed omen cards are defined in `lld-omen-cards`.

The omen deck is assembled fresh per combat from four sources: vessel cards, item cards, floor cards, and enemy cards. Enemy cards are present only while those enemies are alive. See `LLD-OMEN-MECH-004`.

#### Scenario: Omen draw every turn
- **WHEN** a new combat turn begins
- **THEN** if the cycle timer has expired, three omen cards are drawn and resolved per `LLD-OMEN-MECH-001`

#### Scenario: Deck composition shifts per combat
- **WHEN** the player enters a combat against a Skeleton
- **THEN** the Skeleton's Emboldened (Physical) and Grave Knit cards (`LLD-ENEMIES-004`) are included in the deck for that combat only
