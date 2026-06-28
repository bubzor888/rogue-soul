## MODIFIED Requirements

### Requirement: [HLD-COMBAT-012] Post-Combat Loot
Every completed combat encounter SHALL present the player with a ternary choice: take the durability item offered, take the consumable offered, or decline both. Both options are fully revealed before the player decides. Taking one item causes the other to be lost. Declining both is a valid strategic choice — the floor boss scales its mechanics based on the player's total item count, so walking away is sometimes correct.

#### Scenario: Loot choice is ternary
- **WHEN** a combat encounter is completed
- **THEN** exactly two loot options are shown (one durability item, one consumable) and the player may take one or decline both

#### Scenario: Take durability item
- **WHEN** the player selects the durability item
- **THEN** the durability item is added to the player's inventory and the consumable option is discarded

#### Scenario: Take consumable
- **WHEN** the player selects the consumable
- **THEN** the consumable is added to the player's inventory and the durability item option is discarded

#### Scenario: Decline both
- **WHEN** the player declines both options
- **THEN** both loot options are discarded and the player's inventory is unchanged

### Requirement: [HLD-COMBAT-013] Elite Combat Rewards
Elite combats SHALL follow the same post-combat loot format as standard combats (see `HLD-COMBAT-012`) — the player faces the same ternary choice (take durability item / take consumable / decline both) with both options fully revealed — but the options are drawn from elite-tier pools rather than standard-tier pools. Standard combats draw from normal-tier pools; elite combats draw from elite-tier pools. The tier distinction is the primary additional reward for accepting the harder fight.

`[OPEN·MVP1]` Elite-tier pool contents (specific items eligible as elite drops) to be defined in `lld-items`.

#### Scenario: Elite loot uses elevated pools
- **WHEN** the player completes an elite combat
- **THEN** the two loot options are drawn from elite-tier pools, not the standard floor pools used after normal combats

#### Scenario: Same ternary choice format as standard loot
- **WHEN** elite loot is presented
- **THEN** exactly two options are shown (one elite-tier durability item, one elite-tier consumable) and the player may take one or decline both; the format is identical to `HLD-COMBAT-012`
