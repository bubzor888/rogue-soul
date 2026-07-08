## MODIFIED Requirements

### Requirement: [HLD-MF-004] Companion Encounter
Companion Encounter fragments SHALL present a temporary companion offer. The companion is introduced through flavour text only — no passive effect, granted ability, or omen card contribution is disclosed before acceptance. The player chooses based on flavour text alone (or prior run knowledge).

**Companion encounters are mandatory.** There is no option to walk away. When a Companion Encounter fragment fires, the companion is accepted.

**One companion encounter per floor.** Once a companion encounter has been offered — whether from a Memory Fragment draw or from a starting item beat (e.g. Worn Map, see `LLD-FLOOR-BEATS-003`) — the Companion Encounter category is removed from the Memory Fragment pool for the remainder of that floor. A player cannot receive more than one companion offer per floor. This guarantee holds by construction: while the player holds an unfired Worn Map, Memory Fragment generation excludes the Companion Encounter category outright (see `LLD-FLOOR-BEATS-003`), so a companion encounter can never fire while another companion offer is still pending.

Companion Encounter fragments may also hint at locked vessels — surfacing memories of lives the soul has not yet unlocked. These hints do not name or explain the unplayed vessel; they make them feel present and real.

#### Scenario: Companion encounter is mandatory
- **WHEN** a Memory Fragment draws the Companion Encounter category
- **THEN** the player must accept the companion; there is no option to decline or walk away

#### Scenario: One companion encounter per floor
- **WHEN** a companion encounter has already been offered this floor (via any source)
- **THEN** subsequent Memory Fragment draws exclude the Companion Encounter category for the rest of that floor

<!--
The "Companion swap choice" scenario (previously here, covering the case where
the player already has a companion when a new encounter fires) is removed by
this change. It only existed to handle a generation-order loophole — a Memory
Fragment Companion Encounter could fire before the fixed Worn Map beat
(LLD-FLOOR-BEATS-003), which then fired unconditionally regardless, producing
a second companion offer. LLD-FLOOR-BEATS-003 now excludes the Companion
Encounter category from Memory Fragment generation for the entire time an
unfired Worn Map is held, so a second offer — and therefore a swap choice —
can no longer occur. No engine implementation of the swap scenario exists yet
in MVP2, so there is no migration.
-->
