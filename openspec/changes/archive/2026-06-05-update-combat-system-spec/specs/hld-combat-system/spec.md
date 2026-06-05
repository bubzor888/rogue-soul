## REMOVED Requirements

### Requirement: [HLD-COMBAT-002] Front / Back Row Positioning
**Reason**: The melee vs. ranged targeting distinction has been removed. All attacks and abilities can target any enemy freely — row position no longer gates targeting. The broader row system (UnitState row field) may still exist in the data model but the targeting rules based on it are not implemented.
**Migration**: Any code or design referencing melee-only-hits-front-row or ranged-hits-any-row should be removed. `ForceRowHandler` in `lld-abilities` should be reviewed in a follow-on change.

---

### Requirement: [HLD-COMBAT-003] Row Assignment Persistence
**Reason**: This requirement existed solely to support the pre-combat row setup screen and the `SET_DEFAULT_ROW` action — both of which were only meaningful when row position gated targeting (HLD-COMBAT-002). With HLD-COMBAT-002 removed, there is no longer a player-facing reason to configure row assignments before combat.
**Migration**: Remove `SET_DEFAULT_ROW` action from `ActionInjector` legal actions. Remove pre-combat setup screen from `ScreenManager` flow. Remove `GameState.default_rows` if it has no other purpose.

---

## MODIFIED Requirements

### Requirement: [HLD-COMBAT-004] Action Economy
Each player turn SHALL consist of three independent action buckets. Each bucket may be used once per turn. Support and Consumable buckets are optional. The Attack bucket is mandatory — it must always be resolved.

| Bucket | Source | Cost | Limit | Optional |
|---|---|---|---|---|
| **Attack** | Attack ability, attack item, or Default Strike | — | 1 per turn | No — must always resolve |
| **Support** | Non-attack ability (charged) | Free | 1 per turn | Yes |
| **Consumable** | Single-use non-attack item | Free | 1 per turn | Yes |

**Attack bucket priority:** Attack ability → Attack item → Default Strike. The player uses whichever is available and preferred; all three options compete for the single Attack slot.

**Companion actions:** At the end of the player's turn, each active companion takes one automatic action from their ability set. The player spends no bucket uses on companion actions.

**A fully-resourced turn** uses all three buckets: trigger a support ability, use a consumable, and make an attack.

#### Scenario: One attack per turn
- **WHEN** the player uses an attack item on their turn
- **THEN** they cannot also use an attack ability in the same turn — both compete for the single Attack bucket

#### Scenario: Support does not consume attack
- **WHEN** the player uses a non-attack ability (Support bucket)
- **THEN** they can still use an attack ability or attack item in the same turn

#### Scenario: Consumable does not consume attack
- **WHEN** the player uses a consumable item (Consumable bucket)
- **THEN** they can still resolve the Attack bucket in the same turn

#### Scenario: Attack bucket is mandatory
- **WHEN** the player has no attack ability charges and no attack items
- **THEN** the Default Strike is used to resolve the Attack bucket — the player always acts offensively

#### Scenario: Companion acts automatically
- **WHEN** the player ends their turn
- **THEN** each active companion resolves one automatic action from their ability set with no player input required
