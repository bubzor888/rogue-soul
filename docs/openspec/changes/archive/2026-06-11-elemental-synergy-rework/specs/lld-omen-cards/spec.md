## Modified Requirements

### MODIFIED: [LLD-OMEN-CARD-004] Emboldened (Physical) (Per-Unit Omen)

The Emboldened (Physical) omen card SHALL apply an Emboldened StatusInstance with `string_param: "physical"` (via `status_id: "emboldened:physical"`) to each unit on the target side as an individual StatusInstance (see `HLD-COMBAT-006` for status definition). Each unit's outgoing physical damage gains the flat bonus while the status is active.

**On enemy side:** the player's physical weapons deal more damage per hit. Always relevant since physical is the default damage type.
**On player side (forced):** enemies deal more physical damage per hit.

Source: confirmed as a Skeleton omen contribution (`LLD-ENEMIES-004`).

Flat physical damage bonus: **+2 per hit** (see `LLD-ARCH-019` damage resolution order step 2 for application).

#### Scenario: Physical damage bonus per unit
- **WHEN** Emboldened (Physical) is active on the player side
- **THEN** every physical damage hit by the player gains the +2 flat bonus; the status is tracked as an `emboldened` StatusInstance with `string_param: "physical"` and can be cleansed by an appropriate item

---

### MODIFIED: [LLD-OMEN-CARD-005] Emboldened (Elemental) (Per-Unit Omen)

The Emboldened (Elemental) omen card SHALL apply an Emboldened StatusInstance with the matching elemental `string_param` (via `status_id: "emboldened:<element>"`) to each unit on the target side as an individual StatusInstance (see `HLD-COMBAT-006` for status definition). Each unit's outgoing damage of the matching elemental type is multiplied by ×1.5 while the status is active.

Separate cards exist for each confirmed element: Fire, Lightning, Ice.

| Card ID | status_id | Element |
|---|---|---|
| `emboldened_fire` | `"emboldened:fire"` | Fire |
| `emboldened_lightning` | `"emboldened:lightning"` | Lightning |
| `emboldened_ice` | `"emboldened:ice"` | Ice |

**On enemy side:** the player's attacks of that element hit harder. High value when the matching elemental weapon is equipped.
**On player side (forced):** enemies deal increased damage of that type. Particularly dangerous if the player is already Vulnerable to that element.

Elemental damage bonus multiplier: **×1.5** (same as Vulnerability — stacks multiplicatively with Vulnerable when the element matches, per `HLD-COMBAT-007`). Applied at damage resolution step 4 (see `LLD-ARCH-019`).

#### Scenario: Elemental bonus stacks with vulnerability
- **WHEN** an `emboldened` StatusInstance with `string_param: "fire"` is active on the player side and an enemy has a `vulnerable` StatusInstance with `string_param: "fire"` applied via Combustible Oil
- **THEN** the elemental bonus (×1.5 outgoing) and the vulnerability multiplier (×1.5 incoming) both apply — the combined effect is intentional and represents the fire combo payoff

---

### MODIFIED: [LLD-OMEN-CARD-013] Elemental Synergy (Enemy Card — Elemental)

Three Elemental Synergy omen cards exist — one per element (Fire, Ice, Lightning). Each card applies a Type Convert StatusInstance (see `HLD-COMBAT-006`) to each unit on the target side for the omen cycle, converting that unit's outgoing damage to the contributing elemental's type.

**Card IDs and status_ids:**

| Card ID | Display name | status_id | Contributed by |
|---|---|---|---|
| `elemental_synergy_fire` | Elemental Synergy (Fire) | `"type_convert:fire"` | Fire Elemental (`LLD-ENEMIES-014`) |
| `elemental_synergy_ice` | Elemental Synergy (Ice) | `"type_convert:ice"` | Ice Elemental (`LLD-ENEMIES-015`) |
| `elemental_synergy_lightning` | Elemental Synergy (Lightning) | `"type_convert:lightning"` | Lightning Elemental (`LLD-ENEMIES-016`) |

Each card has `handlers: []` — the effect is fully expressed via `status_id`. No `requires_tag`.

**On elemental side:** elementals already deal their type — Type Convert overrides to the same type, so no change. Safe for the player to play here.
**On player side:** the player's unit receives a Type Convert StatusInstance; all their attacks become the elemental's damage type for the cycle. The elemental resists that type (×0.5). Any opposing-element advantage (e.g. ice weapon vs. Fire Elemental) flips to a resistance penalty.

Elemental resistances and vulnerabilities:

| Elemental | Resistance | Vulnerability |
|---|---|---|
| Fire Elemental | Fire ×0.5 | Ice ×1.5 |
| Ice Elemental | Ice ×0.5 | Fire ×1.5 |
| Lightning Elemental | Lightning ×0.5 | None |

#### Scenario: Elemental Synergy (Fire) converts player attacks
- **WHEN** Elemental Synergy (Fire) is active on the player side
- **THEN** the player receives a `type_convert` StatusInstance with `string_param: "fire"`; all player attacks deal fire damage; the Fire Elemental's fire resistance (×0.5) applies to all hits

#### Scenario: Elemental Synergy (Ice) converts player attacks
- **WHEN** Elemental Synergy (Ice) is active on the player side
- **THEN** the player receives a `type_convert` StatusInstance with `string_param: "ice"`; a fire weapon's ice vulnerability advantage against the Ice Elemental disappears — damage deals ice type and hits the ×0.5 resistance instead

#### Scenario: Elemental Synergy on elemental side — no effect
- **WHEN** the player steers Elemental Synergy (Fire) to the enemy side containing a Fire Elemental
- **THEN** the Fire Elemental receives a `type_convert` StatusInstance with `string_param: "fire"`; it already deals fire, so the conversion has no observable effect

---

### MODIFIED: [LLD-OMEN-CARD-015] Vulnerable (Fire) (Whole-Side Overall Omen)

The Vulnerable (Fire) omen card SHALL apply a `"vulnerable:fire"` StatusInstance to all units on the target side for the cycle duration. Every fire damage hit against any affected unit is multiplied by ×1.5 (see `HLD-COMBAT-007` for Vulnerable rules including non-stacking and resistance cancellation).

**On enemy side:** all enemies become vulnerable to fire attacks. Pairs with any fire weapon (Ember Shard, Smoldering Brand) and fire consumables (Fire Bomb, Combustible Oil).
**On player side (forced):** player takes increased fire damage. Particularly dangerous on floors with Fire Elementals.

Card timer value is assigned at combat start via the randomised distribution (see `LLD-OMEN-MECH-009`).

#### Scenario: Whole-side fire vulnerability
- **WHEN** Vulnerable (Fire) is played to the enemy side with two enemies present
- **THEN** both enemies gain a `"vulnerable:fire"` StatusInstance for the cycle duration; all fire damage against them is ×1.5

#### Scenario: Non-stacking with item Vulnerable
- **WHEN** Combustible Oil has already applied a `"vulnerable:fire"` StatusInstance to one enemy and then the Vulnerable (Fire) omen card is played to the enemy side
- **THEN** that enemy's fire multiplier remains ×1.5 (not ×2.25) — Vulnerable does not stack (see `HLD-COMBAT-007`)

---

### MODIFIED: [LLD-OMEN-CARD-016] Vulnerable (Lightning) (Whole-Side Overall Omen)

The Vulnerable (Lightning) omen card SHALL apply a `"vulnerable:lightning"` StatusInstance to all units on the target side for the cycle duration. Every lightning damage hit against any affected unit is multiplied by ×1.5 (see `HLD-COMBAT-007`).

**On enemy side:** all enemies become vulnerable to lightning attacks. Pairs with Spark Rod, Arc Wand, Fulminating Powder.
**On player side (forced):** player takes increased lightning damage.

Card timer value is assigned at combat start via the randomised distribution (see `LLD-OMEN-MECH-009`).

#### Scenario: Whole-side lightning vulnerability
- **WHEN** Vulnerable (Lightning) is played to the enemy side
- **THEN** all enemies on that side gain a `"vulnerable:lightning"` StatusInstance for the cycle; lightning damage against them is ×1.5

#### Scenario: Lightning Elemental resistance cancellation
- **WHEN** Vulnerable (Lightning) is played to the enemy side and a Lightning Elemental is present
- **THEN** the Lightning Elemental has both Resistance (Lightning ×0.5) and a `"vulnerable:lightning"` StatusInstance (×1.5) — they cancel out; it takes normal lightning damage (×1.0) per `HLD-COMBAT-007`

---

### MODIFIED: [LLD-OMEN-CARD-017] Vulnerable (Ice) (Whole-Side Overall Omen)

The Vulnerable (Ice) omen card SHALL apply a `"vulnerable:ice"` StatusInstance to all units on the target side for the cycle duration. Every ice damage hit against any affected unit is multiplied by ×1.5 (see `HLD-COMBAT-007`).

**On enemy side:** all enemies become vulnerable to ice attacks. Pairs with Frost Sliver, Glacial Brand, Frost Shard.
**On player side (forced):** player takes increased ice damage.

Card timer value is assigned at combat start via the randomised distribution (see `LLD-OMEN-MECH-009`).

#### Scenario: Whole-side ice vulnerability
- **WHEN** Vulnerable (Ice) is played to the enemy side
- **THEN** all enemies on that side gain a `"vulnerable:ice"` StatusInstance for the cycle; ice damage against them is ×1.5

---

### MODIFIED: [LLD-OMEN-CARD-019] Exposed (Whole-Side Floor Card — Floor 3)

The Exposed omen card SHALL apply the Exposed status (`trigger: "shift"`) to each eligible unit on the target side as an individual StatusInstance. At the omen shift, each Exposed StatusInstance fires: a `"vulnerable:physical"` StatusInstance is applied to that unit with `remaining_ticks` equal to the newly drawn cycle's timer value, then the Exposed StatusInstance clears.

The Exposed card is included in the Floor 3 ambient deck (see `LLD-OMEN-CARD-008`). It is not contributed by any specific enemy or vessel.

Low timer cards are desirable when Exposed is active on the enemy side — the omen shift fires sooner, delivering Vulnerable (Physical) to enemies faster (see `HLD-OMEN-002`).

**On enemy side:** each enemy gains an Exposed StatusInstance; at the omen shift each becomes Vulnerable (Physical) for the next full omen cycle. Pairs with any physical weapon — the window of amplified physical damage lasts exactly one cycle.
**On player side (forced):** the player gains an Exposed StatusInstance; at the omen shift the player becomes Vulnerable (Physical) for the next omen cycle. Cleared by Ointment (removes the Exposed StatusInstance before the shift fires, preventing the Vulnerable application entirely).

#### Scenario: Exposed fires at shift — Vulnerable duration matches new cycle
- **WHEN** Exposed is active on the enemy side and the omen shift occurs, drawing a new cycle with timer value 2
- **THEN** each enemy that had an Exposed StatusInstance receives a `"vulnerable:physical"` StatusInstance with `remaining_ticks = 2`; the Exposed StatusInstance is then cleared; the Vulnerable lasts exactly the next omen cycle

#### Scenario: Exposed cleansed before shift — no Vulnerable
- **WHEN** the player has an Exposed StatusInstance and uses Ointment before the omen shift fires
- **THEN** the Exposed StatusInstance is removed; at the omen shift no `"vulnerable:physical"` StatusInstance is applied to the player

#### Scenario: Exposed on enemy side pairs with physical weapon
- **WHEN** Exposed fires on the enemy side and the player's equipped weapon deals physical damage
- **THEN** the player's physical attacks hit enemies with a `"vulnerable:physical"` StatusInstance, applying ×1.5 for the full duration of the next omen cycle

#### Scenario: Exposed — low timer strategic value
- **WHEN** Exposed is active on the enemy side and the timer card is 1
- **THEN** the omen shift fires after 1 turn; the `"vulnerable:physical"` StatusInstance is applied immediately at the next draw, giving the player access to the ×1.5 multiplier window after only one cycle

#### Scenario: Exposed non-stacking with Brittle Charm
- **WHEN** Exposed triggers on an enemy that already has a `"vulnerable:physical"` StatusInstance from Brittle Charm
- **THEN** the physical multiplier remains ×1.5 — two sources of the same Vulnerable type do not stack (see `HLD-COMBAT-007`)
