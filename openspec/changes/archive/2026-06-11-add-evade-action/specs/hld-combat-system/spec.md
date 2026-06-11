## MODIFIED Requirements

### Requirement: [HLD-COMBAT-004] Action Economy
Each player turn SHALL consist of three independent action buckets. Each bucket may be used once per turn. Support and Consumable buckets are optional. The Action bucket is mandatory — it must always be resolved.

| Bucket | Source | Cost | Limit | Optional |
|---|---|---|---|---|
| **Action** | Attack ability, attack item, Default Strike, or Evade | — | 1 per turn | No — must always resolve |
| **Support** | Non-attack ability (charged) | Free | 1 per turn | Yes |
| **Consumable** | Single-use non-attack item | Free | 1 per turn | Yes |

**Action bucket options:** Attack ability, attack item, Default Strike, and Evade all compete for the single Action slot. When attacking, priority is: Attack ability → Attack item → Default Strike. Evade is always a legal alternative to any attack option.

**Companion actions:** At the end of the player's turn, each active companion takes one automatic action from their ability set. The player spends no bucket uses on companion actions.

**A fully-resourced turn** uses all three buckets: trigger a support ability, use a consumable, and resolve an action (attack or evade).

#### Scenario: One action per turn
- **WHEN** the player uses an attack item on their turn
- **THEN** they cannot also use an attack ability or Evade in the same turn — all three compete for the single Action bucket

#### Scenario: Support does not consume action
- **WHEN** the player uses a non-attack ability (Support bucket)
- **THEN** they can still resolve the Action bucket in the same turn

#### Scenario: Consumable does not consume action
- **WHEN** the player uses a consumable item (Consumable bucket)
- **THEN** they can still resolve the Action bucket in the same turn

#### Scenario: Action bucket is mandatory
- **WHEN** the player has no attack ability charges and no attack items
- **THEN** the player must resolve the Action bucket with either Default Strike or Evade

#### Scenario: Companion acts automatically
- **WHEN** the player ends their turn
- **THEN** each active companion resolves one automatic action from their ability set with no player input required

#### Scenario: Support and Consumable available when evading
- **WHEN** the player chooses Evade as their Action bucket resolution
- **THEN** the Support and Consumable buckets remain available for use on the same turn

## ADDED Requirements

### Requirement: [HLD-COMBAT-017] Evade
Evade SHALL be a legal Action bucket option for both the player and enemies. A unit that chooses Evade deals no damage that turn. All incoming hits against an evading unit have a 35% chance to miss for the remainder of that round. Evade lasts exactly one round and is tracked as a per-turn runtime flag, not as a status effect (see `LLD-ARCH-017`).

**Miss resolution:** A miss roll is applied per incoming hit, not per attack. For multi-hit attacks, each individual hit rolls independently. On a miss: the hit deals no damage and applies no status effect. The attack did not connect.

**Evade and Vulnerable:** The miss roll is resolved before vulnerability or any other damage modifier (see `LLD-ARCH-019` damage resolution order). Evade does not interact with or cancel the Vulnerable status.

**Companion rules:** Companion actions that deal damage or apply status to an evading enemy are subject to the 35% miss roll. Companion actions that benefit the player (heals, intercepts, buffs) are not blocked by the player's own Evade state.

**Weapon durability preservation:** When attacking an evading enemy, if ALL targeted enemies evaded and ALL miss rolls triggered, weapon item charges (action_bucket: "attack", breaks_at_zero: true) are NOT consumed that turn. If at least one hit connected (any targeted enemy was not evading, or any miss roll did not trigger), the weapon charge IS consumed. Consumable bucket items are always consumed regardless of whether the hit connected.

**Unlimited use:** There is no per-run or per-combat limit on Evade. A unit may choose Evade every turn indefinitely; the sacrifice of the Action bucket is the natural constraint.

#### Scenario: Evade blocks incoming hit
- **WHEN** the player chooses Evade and an enemy makes a single attack
- **THEN** CombatResolver rolls a 35% miss chance using the COMBAT stream; on a miss the attack deals no damage and applies no status

#### Scenario: Multi-hit attack rolls per hit
- **WHEN** the player is evading and an enemy uses a multi-hit attack (e.g. Double Swipe)
- **THEN** each individual hit rolls the 35% miss chance independently; one hit may land while another misses

#### Scenario: Miss blocks status
- **WHEN** the player is evading and an enemy's attack that would apply Chilled misses
- **THEN** the player takes no damage and does not gain the Chilled status

#### Scenario: Evade does not cancel Vulnerable
- **WHEN** the player is evading and also has Vulnerable (Physical) applied
- **THEN** the miss roll is performed first; if the hit lands, the Vulnerable multiplier applies normally

#### Scenario: Weapon charge preserved on full miss
- **WHEN** the player attacks a single evading enemy and the miss roll triggers
- **THEN** the weapon item's remaining_charges is not decremented

#### Scenario: Weapon charge consumed if any hit lands
- **WHEN** the player's weapon targets two enemies, one evading and one not
- **THEN** the weapon charge IS consumed; at least one hit connected

#### Scenario: Consumable always consumed
- **WHEN** the player uses a consumable-bucket item and its target is evading
- **THEN** the consumable item is spent regardless of whether the hit connected

#### Scenario: Companion attack respects enemy Evade
- **WHEN** an enemy is evading and a companion (e.g. the Shadow) attacks that enemy
- **THEN** the companion's attack rolls the 35% miss chance like any other hit

#### Scenario: Companion benefit unaffected by player Evade
- **WHEN** the player is evading and a companion triggers a beneficial effect (e.g. Life Mote revive)
- **THEN** the companion's beneficial effect resolves normally

#### Scenario: Evade lasts one round
- **WHEN** the player chose Evade on the previous turn and a new player turn begins
- **THEN** is_evading resets to false; subsequent enemy attacks do not benefit from the prior Evade
