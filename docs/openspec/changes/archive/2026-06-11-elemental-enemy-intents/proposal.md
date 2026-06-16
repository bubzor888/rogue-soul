## Why

The Fire Elemental and Ice Elemental have no intent tables defined, leaving them as placeholder enemies. This change adds their combat intents, introduces a Burning magnitude-stacking rule that makes the Fire Elemental's identity distinct, and fixes a pre-existing schema gap where `status_magnitude` had no formal field in OmenCardData or IntentWeight — a gap that also affects Poisoned and Bleed.

## What Changes

- Add intent tables for Fire Elemental (LLD-ENEMIES-014) and Ice Elemental (LLD-ENEMIES-015)
- Add HLD rule: Burning is magnitude-stackable on reapplication (unlike Chilled which is idempotent)
- **BREAKING** Add `status_magnitude: int` field to OmenCardData and IntentWeight in LLD-ARCH-018 — formalises the magnitude value that was previously prose-only for Burning (omen card: 5), Poisoned, and Bleed
- Clarify LLD-OMEN-CARD-001 (Burning): the tick damage value of 5 is now formally `status_magnitude: 5` on the card data
- Fix broken "self-created vulnerability" scenario on Ice Elemental: replace it with the correct `glacial_mark` mechanism that actually creates Vulnerable (Ice)

## Capabilities

### New Capabilities

None — this change adds intents to existing enemy definitions, not new capability systems.

### Modified Capabilities

- `hld-combat-system`: New requirement — Burning is magnitude-stackable on reapplication (distinct from Chilled idempotency)
- `lld-technical-architecture`: LLD-ARCH-018 OmenCardData and IntentWeight gain `status_magnitude: int` field; LLD-ARCH-019 CombatResolver documents magnitude-stacking behaviour for Burning
- `lld-omen-cards`: LLD-OMEN-CARD-001 (Burning) formalises tick damage as `status_magnitude: 5`
- `lld-enemies`: LLD-ENEMIES-014 and LLD-ENEMIES-015 gain full intent tables; Ice Elemental broken scenario replaced

## Impact

- `EnemyData` / `IntentWeight` resource schema: new `status_magnitude` field (defaults 0 — backward compatible for all existing intents that do not apply magnitude-based statuses)
- `OmenCardData` resource schema: new `status_magnitude` field (defaults 0 — backward compatible for all existing omen cards)
- `CombatResolver.resolve_enemy_turns` step 7c: update status application logic to handle Burning magnitude stacking
- `CombatResolver.resolve_omen_cycle_start` step 5: use `status_magnitude` from OmenCardData when creating StatusInstances
- Fire Elemental and Ice Elemental `.tres` data files: new intent entries
- No existing enemies are affected — no existing intent uses `status_magnitude`
