## Why

Two separate housekeeping needs: twelve-plus `[OPEN·MVP1]` tags scattered across specs that say nothing more than "validate in playtesting" are noise that implies a decision is pending when none is — every numeric value is subject to playtesting tuning. Separately, `LLD-ABILITIES-005` (Pilgrim's Read the Road passive) is tagged `[OPEN·MVP1]` for a real reason: the `peek_omen_deck` handler required to implement it has never been designed, which means the Pilgrim's core combat ability has no architectural support.

## What Changes

- **Remove** all `[OPEN·MVP1]` annotations that say only "to be validated / tuned in playtesting" with no accompanying design question — these apply to numeric values in `lld-enemies` (14 instances), `lld-omen-cards` (1), `lld-floor` (1), and `lld-memory-fragments` (1)
- **Remove** the Hardened/min-1 clamp interaction note from `lld-enemies` — the question is now answered: there is no min-1 damage clamp; Hardened and other absorption effects can reduce damage to 0
- **Remove** step 8 (Clamp to minimum 1) from the damage resolution order in `lld-technical-architecture` LLD-ARCH-019
- **Re-tag to `[OPEN·MVP2]`** all narrative `[OPEN·MVP1]` tags in `hld-narrative`, `lld-narrative`, and `lld-enemies` — narrative content (guardian dialogue, vessel lore) is not needed for headless engine testing
- **Resolve** `LLD-ABILITIES-005`: define the `peek_omen_deck` handler, the `read_the_road_active: bool` field on `CombatState`, the `READ_THE_ROAD_COMMIT` action type, and the corresponding `get_legal_combat_actions` and `resolve_player_action` branches — mirroring the Repent/`pending_repent_slots` pattern established in `judge-arch-update`

## Capabilities

### New Capabilities

_(none)_

### Modified Capabilities

- `lld-abilities`: LLD-ABILITIES-005 resolved — replace `[OPEN·MVP1]` stub with full handler chain and interaction spec
- `lld-technical-architecture`: LLD-ARCH-003 (new action type), LLD-ARCH-017 (new CombatState field), LLD-ARCH-019 (new `get_legal_combat_actions` branch and `resolve_player_action` branch)
- `lld-enemies`: remove 14 "to be validated in playtesting" lines; remove Hardened/clamp interaction note (resolved — no clamp exists); re-tag Judge dialogue line to `[OPEN·MVP2]`
- `lld-omen-cards`: remove "to be validated in playtesting" `[OPEN·MVP1]` line from LLD-OMEN-CARD-020
- `lld-floor`: remove "to be tuned during playtesting" `[OPEN·MVP1]` line from LLD-FLOOR-BEATS-002
- `lld-memory-fragments`: remove "to be tuned" `[OPEN·MVP1]` line from LLD-MF-007
- `hld-narrative`: re-tag visual direction note and guardian dialogue note from `[OPEN·MVP1]` to `[OPEN·MVP2]`
- `lld-narrative`: re-tag LLD-NAR-001 and LLD-NAR-003 (and their scenarios) from `[OPEN·MVP1]` to `[OPEN·MVP2]`

## Impact

- `openspec/specs/lld-abilities/spec.md` — LLD-ABILITIES-005 significantly expanded
- `openspec/specs/lld-technical-architecture/spec.md` — LLD-ARCH-003, LLD-ARCH-017, LLD-ARCH-019 modified
- `openspec/specs/lld-enemies/spec.md` — 14 tag removals, 1 interaction note removed, 1 tag re-labelled
- `openspec/specs/lld-omen-cards/spec.md` — one tag-only line removal
- `openspec/specs/lld-floor/spec.md` — one tag-only line removal
- `openspec/specs/lld-memory-fragments/spec.md` — one tag-only line removal
- `openspec/specs/hld-narrative/spec.md` — two tags re-labelled MVP1→MVP2
- `openspec/specs/lld-narrative/spec.md` — LLD-NAR-001 and LLD-NAR-003 re-tagged MVP1→MVP2
- Implementation: `CombatState`, `CombatResolver`, `ActionInjector`, `AbilityRegistry` — new `READ_THE_ROAD_COMMIT` action and `peek_omen_deck` handler; damage resolution order (remove step 8)
