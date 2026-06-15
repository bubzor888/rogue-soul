## ADDED Requirements

### Requirement: [LLD-FLOOR-ELITE-001] Elite Combat Definition
An elite combat encounter on Floor 3 SHALL use the same combat loop as a standard encounter — identical damage resolution, omen cycle, status effects, and intent selection rules. The two distinguishing properties are:

1. **Enemy pool**: enemies are drawn exclusively from the elite enemy pool defined in `lld-enemies` (Witnesses of Mending, Emboldened, and Strength; the Bear; the Lightning Elemental). Normal enemies do not appear in elite encounters.
2. **Loot tier**: post-combat item drops are drawn from the elite drop pools (`LLD-ITEMS-006` for durability, `LLD-ITEMS-008` for consumables), not the normal drop pools.

On-death status effects from Witness enemies (`EnemyData.on_death_apply_to_player`) are applied by the standard `resolve_enemy_death` path defined in `LLD-ARCH-019`. No additional mechanics are required.

#### Scenario: Elite combat uses standard combat loop
- **WHEN** the player enters an elite combat encounter
- **THEN** the combat proceeds identically to a standard encounter — same action types, same omen cycle, same damage resolution steps

#### Scenario: Post-elite loot is from elite pools
- **WHEN** the player wins an elite combat encounter
- **THEN** the loot selection draws from the elite durability pool (LLD-ITEMS-006) and elite consumable pool (LLD-ITEMS-008), not the normal pools

#### Scenario: Witness on-death effect applies via standard path
- **WHEN** a Witness enemy is killed in an elite encounter
- **THEN** its `on_death_apply_to_player` status is applied by `resolve_enemy_death` exactly as it would be in any other encounter type

## MODIFIED Requirements

### Requirement: [LLD-FLOOR-BEATS-004] Beat 4 — Elite Gate (Room 5)
Room 5 SHALL always present the Elite Gate: one door shows an elite combat encounter; the other shows a standard combat encounter. This is a forced structural beat at the floor midpoint — not drawn from the general pool.

Choosing the **standard combat** door: counts toward the floor's overall standard combat total (see `LLD-FLOOR-PATT-003`) but does not belong to the pre-elite or post-elite segment buckets. No rest room follows.

Choosing the **elite combat** door: triggers a guaranteed rest encounter at room 6 (see `LLD-FLOOR-BEATS-006`) — the only rest room on the floor.

Elite combat definition: see `LLD-FLOOR-ELITE-001`.

#### Scenario: Elite Gate always at room 5
- **WHEN** the player completes room 4
- **THEN** room 5 always presents elite combat vs standard combat; no other room type can appear at this position

#### Scenario: Standard combat door counts toward floor total
- **WHEN** the player chooses the standard combat door at room 5 and completes it
- **THEN** the floor's standard combat count increments; it does not count toward the pre-elite or post-elite segment caps

#### Scenario: Elite choice unlocks rest room
- **WHEN** the player chooses the elite combat door at room 5
- **THEN** room 6 becomes a rest encounter (see `LLD-FLOOR-BEATS-006`)
