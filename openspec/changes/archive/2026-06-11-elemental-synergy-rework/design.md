## Design Decisions

### 1. One parameterized status per concept, not separate named statuses

Three separate `type_convert_fire / _ice / _lightning` statuses would each require their own CombatResolver branch and would have to be extended for every future elemental type. A single `type_convert` status with a `string_param` type qualifier is open by default — adding a new element requires only a new omen card data file.

The same argument applies to Vulnerable and Emboldened. Eight near-identical status entries reduce to two. CombatResolver reads `string_param` to determine which type to apply the effect against, rather than branching on status_id.

### 2. Colon-encoding in string fields, not a new `type_param` field on OmenCardData / IntentWeight

Adding a dedicated `type_param: String` to OmenCardData and IntentWeight would solve the same problem but requires schema changes on two Resource types. Colon-encoding in the existing `status_id` field (`"type_convert:fire"`, `"vulnerable:physical"`, `"emboldened:lightning"`) is a convention that requires only a splitting operation in CombatResolver when the StatusInstance is created. No Resource schema changes to OmenCardData or IntentWeight — only StatusInstance gains `string_param`.

The convention: `"status_id:type_qualifier"` — CombatResolver splits on `:` at status creation time, storing the left half as `StatusInstance.status_id` and the right half as `StatusInstance.string_param`. Plain status IDs with no `:` remain unaffected.

### 3. Type Convert placed at damage step 1 (before all multipliers)

Type conversion is a type override, not a damage modifier. It must happen before resistance (step 5) and vulnerability (step 6) checks, which both key on the resolved damage type. Placing it at step 1 as a type-override sub-step ensures the converted type flows through the full multiplier chain correctly.

### 4. Three per-element Elemental Synergy cards (single LLD requirement)

The single `LLD-OMEN-CARD-013` requirement covers three distinct omen cards (`elemental_synergy_fire`, `elemental_synergy_ice`, `elemental_synergy_lightning`), following the same pattern as LLD-OMEN-CARD-005 (Emboldened Elemental — one requirement, three cards). Each card has a single `status_id` in colon format; the `handlers` array is empty. Elemental enemies reference their element-specific card in `omen_contributions`.

### 5. Type Convert replacement rule; Vulnerable and Emboldened have no new stacking restriction

Type Convert is the only status with a single-instance-at-a-time constraint — a new application replaces the existing one, regardless of type. This is necessary because two simultaneous Type Convert statuses of different types would be ambiguous (which type wins?).

Vulnerable already has a same-type non-stacking rule (HLD-COMBAT-007: two sources of the same Vulnerable type → still ×1.5). No new restriction is added. Different Vulnerable types (e.g. Vulnerable (fire) and Vulnerable (physical)) can coexist on a unit.

Emboldened has no stacking restriction in the spec. Multiple Emboldened StatusInstances of different types can coexist on a unit freely. Same-type stacking is left unspecified and deferred to tuning.

### 6. Emboldened Physical vs Elemental distinction preserved via string_param

The flat bonus (Physical) and ×1.5 multiplier (Elemental) behaviors are encoded by type: when `string_param == "physical"`, CombatResolver applies a flat bonus at step 2; when `string_param` is an elemental type, it applies ×1.5 at step 4. This mirrors how the distinction already exists in the damage pipeline — parameterization makes it data-driven rather than branching on specific status_ids.

### 7. Consistent colon shorthand in spec prose

When spec text refers to the Vulnerable or Emboldened StatusInstance created by a card effect or status trigger (e.g. Exposed firing at the omen shift), use the colon shorthand (`"vulnerable:physical"`) rather than spelling out the StatusInstance fields. This matches how the card data is expressed and keeps prose consistent.
