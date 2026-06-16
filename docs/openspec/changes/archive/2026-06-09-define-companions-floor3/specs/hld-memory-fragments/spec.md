## MODIFIED Requirements

### Requirement: [HLD-MF-004] Companion Encounter
Companion Encounter fragments SHALL present a temporary companion offer via flavour text. No passive effect, granted ability, or omen card contribution is disclosed before acceptance — the player chooses based on flavour text alone (or prior run knowledge).

**Companion encounters are mandatory.** There is no option to walk away. When a Companion Encounter fragment fires, the companion is accepted.

**One companion encounter per floor.** Once a companion encounter has been offered — whether from a Memory Fragment draw or from a starting item beat (e.g. Worn Map, see `LLD-FLOOR-BEATS-003`) — the Companion Encounter category is removed from the Memory Fragment pool for the remainder of that floor. A player cannot receive more than one companion offer per floor.

If the player already has a temporary companion when an encounter fires, they MUST choose between keeping their current companion or accepting the one from the fragment. The unchosen companion departs immediately. Both are presented through flavour text only.

Companion Encounter fragments may hint at locked vessels — surfacing memories of lives the soul has not yet unlocked.

#### Scenario: Companion encounter is mandatory
- **WHEN** a Memory Fragment draws the Companion Encounter category
- **THEN** the player must accept the companion; there is no option to decline or walk away

#### Scenario: One companion encounter per floor
- **WHEN** a companion encounter has already been offered this floor (via any source)
- **THEN** subsequent Memory Fragment draws exclude the Companion Encounter category for the rest of that floor

#### Scenario: Companion swap choice
- **WHEN** a companion encounter fires and the player already has a temporary companion
- **THEN** the player chooses between keeping their current companion and accepting the new one; the unchosen departs
