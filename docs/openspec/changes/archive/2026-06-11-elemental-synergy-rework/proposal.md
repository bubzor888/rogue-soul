## Why

Elemental Synergy currently converts damage via a custom handler on `OmenCardData` — the only omen card that isn't implemented as a StatusInstance. With the per-unit status model in place (omen-card-model-rework), the right approach is a proper status effect. Simultaneously, the four `Vulnerable` variants and four `Emboldened` variants in the status table are near-identical rows that can be collapsed into two parameterized statuses, establishing a clean pattern for type-qualified statuses going forward.

## What Changes

- Add `string_param: String` to `StatusInstance` for type-qualified statuses; adopt colon-encoding convention (`"vulnerable:fire"`, `"emboldened:physical"`, `"type_convert:ice"`) in `status_id` and `status_apply` string fields — CombatResolver splits on `:` to extract the type parameter
- Add `Type Convert` to the HLD-COMBAT-006 status table: converts all outgoing damage from the unit to the parameterized type while active; a new application replaces the existing one (no stacking). Type Convert is the only status with a single-instance-at-a-time replacement rule.
- Collapse the four `Vulnerable (Fire/Lightning/Ice/Physical)` rows in HLD-COMBAT-006 into one parameterized `Vulnerable` entry using `string_param`
- Collapse the four `Emboldened (Physical/Fire/Lightning/Ice)` rows in HLD-COMBAT-006 into one parameterized `Emboldened` entry using `string_param`; Physical variant applies a flat damage bonus (damage step 2), elemental variants apply ×1.5 (damage step 4)
- Rework `LLD-OMEN-CARD-013` (Elemental Synergy): remove handler-based conversion; split into three per-element status cards (Fire, Ice, Lightning), each applying `type_convert:<element>` as a per-unit StatusInstance via `status_id`
- Update `LLD-OMEN-CARD-004` (Emboldened Physical) to use `"emboldened:physical"` in `status_id`
- Update `LLD-OMEN-CARD-005` (Emboldened Elemental) to use `"emboldened:fire"` / `"emboldened:lightning"` / `"emboldened:ice"` in `status_id`
- Update `LLD-OMEN-CARD-015/016/017` to use `"vulnerable:fire"` / `"vulnerable:lightning"` / `"vulnerable:ice"` in `status_id`
- Update `LLD-OMEN-CARD-019` (Exposed): spec references to the deferred Vulnerable application consistently use `"vulnerable:physical"` colon shorthand
- Update `LLD-ENEMIES-014/015/016` omen contributions to reference the element-specific Elemental Synergy card variant instead of the single `LLD-OMEN-CARD-013` entry

## Capabilities

### New Capabilities

*(none)*

### Modified Capabilities

- `hld-combat-system` — HLD-COMBAT-006: add Type Convert status; collapse Vulnerable variants into one parameterized entry; collapse Emboldened variants into one parameterized entry
- `lld-technical-architecture` — LLD-ARCH-017: StatusInstance gains `string_param`; LLD-ARCH-018: colon-format convention documented; LLD-ARCH-019: type_convert handling at damage step 1; steps 2 and 4 use Emboldened string_param matching; step 6 uses Vulnerable string_param matching
- `lld-omen-cards` — LLD-OMEN-CARD-004/005: Emboldened status_id updated to colon format; LLD-OMEN-CARD-013: handler-based → three per-element status cards; LLD-OMEN-CARD-015/016/017/019: status_id format updated
- `lld-enemies` — LLD-ENEMIES-014/015/016: omen contributions updated to element-specific synergy card references

## Impact

- `CombatResolver`: parse colon-format in all status_id / status_apply strings; handle `type_convert` at damage step 1 (override damage type before multipliers); match Emboldened `string_param` at steps 2 and 4; match Vulnerable `string_param` at step 6
- `StatusInstance` serialization: new `string_param` field (empty string default, backward-compatible)
- Omen card handler chain for Elemental Synergy cards: `handlers` array becomes empty; effect is now fully expressed by `status_id`
- No explicit stacking restriction on Vulnerable or Emboldened (Vulnerable same-type non-stacking already covered by HLD-COMBAT-007; Emboldened has no stacking restriction). Type Convert replacement rule is the only new single-instance constraint.
- Enemy data files: `resistances` on EnemyData remain plain type strings (unchanged); only omen_contributions card IDs update for elementals
