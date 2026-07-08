## MODIFIED Requirements

### Requirement: [LLD-FLOOR-BEATS-003] Beat 3 — Worn Map Companion (Room 4)
The Worn Map starting item (see `LLD-ITEMS-004`) counts down across encounter types. After 3 encounters, room 4 SHALL become a temporary companion encounter. The two-door choice is replaced by a single door for this room only. The Worn Map is removed from inventory after triggering.

Companion identity is drawn from the Floor 3 temporary companion pool (see `LLD-MF-009`).

**While the player holds an unfired Worn Map, Memory Fragment generation SHALL exclude the Companion Encounter category from its draw pool.** The Worn Map already guarantees a companion encounter will occur at room 4; allowing a Memory Fragment to also draw the Companion Encounter category before then would produce two companion offers in one floor. This exclusion applies from the moment the player receives the Worn Map until it triggers (or is otherwise removed).

**The Worn Map encounter counts as the floor's companion encounter.** After it resolves, `NavigationState.companion_offered_this_floor` is set to true and subsequent Memory Fragment draws exclude the Companion Encounter category for the rest of that floor (per `HLD-MF-004`). Combined with the proactive exclusion above, the Companion Encounter category is unavailable to Memory Fragment generation for the entire floor whenever the player starts with a Worn Map — either it hasn't fired yet (proactive exclusion) or it already has (after-the-fact exclusion).

#### Scenario: Room 4 forced companion
- **WHEN** the player has completed exactly 3 encounters of any type
- **THEN** the next room (room 4) is a companion encounter regardless of player door choices up to that point

#### Scenario: Worn Map removal
- **WHEN** the companion encounter resolves
- **THEN** the Worn Map is removed from the player's inventory

#### Scenario: Worn Map blocks further companion draws
- **WHEN** the Worn Map companion encounter resolves
- **THEN** the Companion Encounter category is no longer available from Memory Fragments for the rest of this floor

#### Scenario: Worn Map blocks companion draws before it fires
- **WHEN** the player holds an unfired Worn Map and a Memory Fragment room is generated before room 4
- **THEN** the Companion Encounter category is excluded from that Memory Fragment's draw pool, so only Category A or Category C can be drawn
