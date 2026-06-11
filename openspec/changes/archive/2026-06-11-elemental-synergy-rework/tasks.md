## Tasks

### hld-combat-system

- [x] **HLD-COMBAT-006 status table: collapse Vulnerable variants into one parameterized row**
  In `openspec/specs/hld-combat-system/spec.md`, within the HLD-COMBAT-006 status table, remove the four separate rows (`Vulnerable (Fire)`, `Vulnerable (Lightning)`, `Vulnerable (Ice)`, `Vulnerable (Physical)`) and replace them with one row:
  `| Vulnerable | Passive | Offensive | Amplifies all damage of the specified type dealt to target by ×1.5 (see HLD-COMBAT-007); type carried in string_param on the StatusInstance (e.g. "fire", "physical", "ice", "lightning") |`

- [x] **HLD-COMBAT-006 status table: collapse Emboldened variants into one parameterized row**
  In `openspec/specs/hld-combat-system/spec.md`, within the HLD-COMBAT-006 status table, remove the four separate rows (`Emboldened (Physical)`, `Emboldened (Fire)`, `Emboldened (Lightning)`, `Emboldened (Ice)`) and replace them with one row:
  `| Emboldened | Passive | Offensive | Type carried in string_param. Physical: adds flat bonus to target's outgoing physical damage per hit (value defined in LLD). Elemental (fire/lightning/ice): multiplies target's outgoing damage of that type by ×1.5. |`

- [x] **HLD-COMBAT-006 status table: add Type Convert row**
  In `openspec/specs/hld-combat-system/spec.md`, within the HLD-COMBAT-006 status table, add a new row after Vulnerable:
  `| Type Convert | Passive | Offensive | Converts all outgoing damage from the unit to the type in string_param; only one instance active at a time — a new application replaces the existing one; clears at omen reset like all statuses |`

- [x] **HLD-COMBAT-006: add parameterized status note and new scenarios**
  In `openspec/specs/hld-combat-system/spec.md`, within the HLD-COMBAT-006 requirement body (before the status table), add a note paragraph:
  `**Parameterized statuses:** Some statuses carry a type qualifier in string_param on the StatusInstance (see LLD-ARCH-017). The type determines which damage type the effect applies to; the status_id identifies the effect category.`
  Add two new scenarios after the Frenzied scenarios: "Type Convert — player side" and "Type Convert replacement" (per the delta spec).

- [x] **HLD-COMBAT-006: update Exposed row description**
  In `openspec/specs/hld-combat-system/spec.md`, update the Exposed row in the status table from `"applies Vulnerable (Physical) to the target"` to `"applies a 'vulnerable:physical' StatusInstance to the target"`. Update the corresponding scenario "Exposed fires at shift" to use the colon shorthand.

- [x] **HLD-COMBAT-006: update Frenzied row and scenarios to use colon shorthand**
  In `openspec/specs/hld-combat-system/spec.md`, update the Frenzied row from "Composite: unit simultaneously has Vulnerable (Physical) (incoming ×1.5) and Emboldened (Physical) (outgoing flat bonus)" to "Composite: unit simultaneously has 'vulnerable:physical' effect (incoming ×1.5) and 'emboldened:physical' effect (outgoing flat bonus)". Update the two Frenzied scenarios similarly.

- [x] **HLD-COMBAT-006: update Emboldened scenarios**
  In `openspec/specs/hld-combat-system/spec.md`, update the "Emboldened (Physical) flat damage bonus" scenario heading and body to reference `emboldened` StatusInstance with `string_param: "physical"`. Update the "Emboldened (Fire) multiplier" scenario to reference `string_param: "fire"`.

### lld-technical-architecture

- [x] **LLD-ARCH-017: add string_param to StatusInstance fields**
  In `openspec/specs/lld-technical-architecture/spec.md`, within the LLD-ARCH-017 **StatusInstance fields** sentence, add `string_param: String` at the end:
  `, string_param: String (type qualifier for parameterized statuses; empty string if not applicable; e.g. "fire" when status_id is "type_convert", "vulnerable", or "emboldened"; CombatResolver reads this to determine which type the effect applies to; default "")`
  Add three new scenarios: "StatusInstance string_param for Vulnerable (Fire)", "StatusInstance string_param for Type Convert (ice)", and "StatusInstance string_param for Emboldened (Physical)".

- [x] **LLD-ARCH-018: add colon-encoding convention note**
  In `openspec/specs/lld-technical-architecture/spec.md`, within LLD-ARCH-018, before the AbilityData schema table, add a new paragraph documenting the colon-encoding convention (per the delta spec), including the `emboldened:physical` example.

- [x] **LLD-ARCH-018: update OmenCardData.status_id notes**
  In `openspec/specs/lld-technical-architecture/spec.md`, within the LLD-ARCH-018 **OmenCardData** table, update the `status_id` field notes to add the colon-encoding note including the Emboldened example. Add two new scenarios: "Colon-encoded status_id split on create" and "Plain status_id unchanged".

- [x] **LLD-ARCH-018: update IntentWeight.status_apply notes**
  In `openspec/specs/lld-technical-architecture/spec.md`, within the LLD-ARCH-018 **IntentWeight** table, update the `status_apply` field notes to add the colon-encoding note.

- [x] **LLD-ARCH-019: update damage resolution step 1 for type_convert**
  In `openspec/specs/lld-technical-architecture/spec.md`, within the LLD-ARCH-019 **Damage resolution order**, replace step 1 with the expanded version that includes the type conversion override sub-step (per delta spec).

- [x] **LLD-ARCH-019: update damage resolution step 2 for Emboldened string_param**
  In `openspec/specs/lld-technical-architecture/spec.md`, within the LLD-ARCH-019 **Damage resolution order**, replace step 2:
  Old: `2. Flat attacker bonuses: if attacker has Emboldened (Physical) and damage type is physical, add flat bonus (value defined in LLD)`
  New: `2. Flat attacker bonuses: if attacker has an emboldened StatusInstance with string_param: "physical" and the resolved damage type is physical, add flat bonus (value defined in LLD)`

- [x] **LLD-ARCH-019: update damage resolution step 4 for Emboldened string_param**
  In `openspec/specs/lld-technical-architecture/spec.md`, within the LLD-ARCH-019 **Damage resolution order**, replace step 4:
  Old: `4. Buff modifiers: Charged ×2 if active (consumed after); Emboldened (elemental) ×1.5 if attacker has matching elemental Emboldened status`
  New: `4. Buff modifiers: Charged ×2 if active (consumed after); if attacker has an emboldened StatusInstance whose string_param matches the resolved damage type and string_param is not "physical", apply ×1.5`

- [x] **LLD-ARCH-019: update damage resolution step 5 and step 6 for string_param**
  In `openspec/specs/lld-technical-architecture/spec.md`, update step 5 to say "resists the resolved damage type" and replace step 6:
  Old: `6. Vulnerability (×1.5 if target is vulnerable to damage type)`
  New: `6. Vulnerability (×1.5 if target has an active vulnerable StatusInstance whose string_param matches the resolved damage type)`

- [x] **LLD-ARCH-019: update resolve_omen_cycle_start step 4 for colon shorthand**
  In `openspec/specs/lld-technical-architecture/spec.md`, within the `resolve_omen_cycle_start` method description, update step 4:
  Old: `apply a new Vulnerable (Physical) StatusInstance with remaining_ticks = new cycle timer value.`
  New: `apply a "vulnerable:physical" StatusInstance with remaining_ticks = new cycle timer value.`
  Also add the Type Convert replacement rule to the resolve_omen_cycle_start description (and note it applies in resolve_player_action / resolve_enemy_turns too).
  Add six new scenarios per the delta spec.

### lld-omen-cards

- [x] **lld-omen-cards: fix duplicate LLD-OMEN-CARD-019**
  In `openspec/specs/lld-omen-cards/spec.md`, there are two `Requirement: [LLD-OMEN-CARD-019]` sections. Remove the first instance (the one with 3 scenarios and heading "Exposed (Floor Card — Floor 3)"). Keep the second instance (heading "Exposed (Whole-Side Floor Card — Floor 3)").

- [x] **LLD-OMEN-CARD-004: update status_id to emboldened:physical**
  In `openspec/specs/lld-omen-cards/spec.md`, within the LLD-OMEN-CARD-004 requirement, update the first sentence to reference `status_id: "emboldened:physical"`. Update the scenario to reference `string_param: "physical"` per the delta spec.

- [x] **LLD-OMEN-CARD-005: update status_ids to colon format and add card_id table**
  In `openspec/specs/lld-omen-cards/spec.md`, within the LLD-OMEN-CARD-005 requirement, add the card_id/status_id table showing emboldened_fire/lightning/ice. Update the scenario to reference the `emboldened` StatusInstance with `string_param: "fire"` per the delta spec.

- [x] **LLD-OMEN-CARD-013: rework Elemental Synergy from handler-based to status-based**
  In `openspec/specs/lld-omen-cards/spec.md`, replace the entire LLD-OMEN-CARD-013 requirement body with the new content from the delta spec: three per-element cards with card_id/status_id table, `handlers: []`, and three updated scenarios.

- [x] **LLD-OMEN-CARD-015: update to use "vulnerable:fire" StatusInstance language**
  In `openspec/specs/lld-omen-cards/spec.md`, within LLD-OMEN-CARD-015, update the first sentence and scenarios to use `"vulnerable:fire"` StatusInstance language per the delta spec.

- [x] **LLD-OMEN-CARD-016: update to use "vulnerable:lightning" StatusInstance language**
  In `openspec/specs/lld-omen-cards/spec.md`, within LLD-OMEN-CARD-016, update the first sentence and scenarios to use `"vulnerable:lightning"` StatusInstance language per the delta spec.

- [x] **LLD-OMEN-CARD-017: update to use "vulnerable:ice" StatusInstance language**
  In `openspec/specs/lld-omen-cards/spec.md`, within LLD-OMEN-CARD-017, update the first sentence and scenarios to use `"vulnerable:ice"` StatusInstance language per the delta spec.

- [x] **LLD-OMEN-CARD-019: update Exposed to use "vulnerable:physical" colon shorthand**
  In `openspec/specs/lld-omen-cards/spec.md`, within the (remaining) LLD-OMEN-CARD-019 requirement, replace all instances of `"a Vulnerable (Physical) StatusInstance is applied"` / `"Vulnerable (Physical) is applied"` with `"a 'vulnerable:physical' StatusInstance is applied"`. Update all four scenarios to use the colon shorthand consistently per the delta spec.

### lld-enemies

- [x] **LLD-ENEMIES-014: update omen contributions to element-specific synergy card**
  In `openspec/specs/lld-enemies/spec.md`, within LLD-ENEMIES-014, update:
  - Header: `Shared family omen card: see LLD-OMEN-CARD-013 (Elemental Synergy — Fire)`
  - Body: `**Omen contributions:** elemental_synergy_fire (Elemental Synergy — Fire) ×1, LLD-OMEN-CARD-001 (Burning) ×1`
  - Update the synergy scenario to reference the Type Convert StatusInstance mechanism.

- [x] **LLD-ENEMIES-015: update omen contributions to element-specific synergy card**
  In `openspec/specs/lld-enemies/spec.md`, within LLD-ENEMIES-015, update:
  - Header: `Shared family omen card: see LLD-OMEN-CARD-013 (Elemental Synergy — Ice)`
  - Body: `**Omen contributions:** elemental_synergy_ice (Elemental Synergy — Ice) ×1, LLD-OMEN-CARD-003 (Chilled) ×1`

- [x] **LLD-ENEMIES-016: update omen contributions to element-specific synergy card**
  In `openspec/specs/lld-enemies/spec.md`, within LLD-ENEMIES-016, update:
  - Header: `Shared family omen card: see LLD-OMEN-CARD-013 (Elemental Synergy — Lightning)`
  - Body: `**Omen contributions (Phase 1 only):** elemental_synergy_lightning (Elemental Synergy — Lightning) ×1, LLD-OMEN-CARD-002 (Shocked) ×1`
