## ADDED Requirements

### Requirement: [LLD-ITEMS-009] Starting Items — The Drifter
The Drifter SHALL start every run with these three items (defined per `LLD-VESSELS-002`):

**Pocket of Sand** — Consumable, single use. Effect: Escape the current combat immediately with no rewards. Cannot be used in elite or boss encounters.

**Loaf of Bread** — Consumable, single use, floor-bound (removed at floor transition if unused). Effect: Restores HP to the vessel. `[OPEN]` heal amount to be set during playtesting relative to typical incoming damage per encounter.

**Lucky Paw** — Support (Durability), charges: 2, breaks_at_zero: true. Decrements 1 charge per encounter (per `LLD-ITEMS-002`). Effect: At the start of each combat while charges remain, applies the **Evasive** buff — a `[OPEN]` % chance to dodge incoming physical attacks for that combat. Does not apply to elemental or magical damage types.

#### Scenario: Pocket of Sand — escape
- **WHEN** the player uses Pocket of Sand in a standard combat
- **THEN** the combat ends immediately; no post-combat rewards are awarded and the item is consumed

#### Scenario: Pocket of Sand — boss restriction
- **WHEN** the player attempts to use Pocket of Sand in an elite or boss encounter
- **THEN** the item cannot be activated

#### Scenario: Loaf of Bread — floor-bound
- **WHEN** the Drifter transitions from floor 2 to floor 3 with an unused Loaf of Bread
- **THEN** the Loaf of Bread is removed from inventory

#### Scenario: Lucky Paw — evasion applies at combat start
- **WHEN** a combat begins and the Lucky Paw has at least 1 charge remaining
- **THEN** the Evasive buff is applied before the first action; a physical attack has a chance to be dodged

---

### Requirement: [LLD-ITEMS-010] Starting Items — The Hedge Knight
The Hedge Knight SHALL start every run with these three items (defined per `LLD-VESSELS-003`):

**Battered Sword** — Attack (Durability), Physical. Stats: see `LLD-ITEMS-005` for base damage (7) and charge range (8–10). `[OPEN]` exact starting charge count to be confirmed during playtesting.

**Iron Pendant** — Support (Durability), charges: 2, breaks_at_zero: true. Decrements 1 charge per encounter (per `LLD-ITEMS-002`). Effect: Replace the player's currently active fate omen with **Fortified** (take half damage from all attacks this omen cycle). The replaced omen is discarded. Fortified remains active for the rest of the current omen cycle. The Fortified omen is never placed in the fate deck — it only exists through pendant use. `[OPEN]` exact damage reduction fraction and edge cases to be confirmed during playtesting.

**Cheap Flask** — Consumable, single use. Effect: Applies a combat buff to the vessel for the current encounter. `[OPEN]` specific buff effect to be defined once the status effect system is fully designed.

#### Scenario: Iron Pendant — omen replacement
- **WHEN** the player activates the Iron Pendant
- **THEN** the currently active fate omen on the player's side is replaced by Fortified and the original omen is discarded

#### Scenario: Iron Pendant — Fortified not in deck
- **WHEN** the fate deck is assembled for any combat
- **THEN** the Fortified omen card is never included; it can only appear via Iron Pendant activation

#### Scenario: Battered Sword — normal drop equivalent
- **WHEN** the Hedge Knight uses the Battered Sword
- **THEN** it deals physical damage matching the normal-tier drop weapon standard (see `LLD-ITEMS-005`)
