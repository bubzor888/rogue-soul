## Why

Three requirements in `hld-combat-system` are stale or incorrect relative to the confirmed decisions in `docs/soul_protocol_game_design.md`:

1. **HLD-COMBAT-002** (Front/Back Row Positioning) — the melee vs. ranged reach distinction no longer exists. All attacks target any enemy freely; row position no longer gates targeting.
2. **HLD-COMBAT-003** (Row Assignment Persistence) — this was entirely dependent on the melee/ranged reach mechanic to give rows meaning in targeting. With that mechanic removed, the pre-combat row setup screen and ForceRowHandler no longer make sense.
3. **HLD-COMBAT-004** (Action Economy) — marked `[OPEN]` but is now fully resolved. The confirmed design is a three-bucket system (Attack, Support, Consumable) — not an AP pool and not discrete flags.

These stale requirements risk implementing mechanics that don't exist and missing the actual action economy design.

## What Changes

- **REMOVED** `HLD-COMBAT-002` — Front/Back Row Positioning (melee/ranged reach distinction)
- **REMOVED** `HLD-COMBAT-003` — Row Assignment Persistence (pre-combat setup screen, ForceRowHandler, SET_DEFAULT_ROW action)
- **MODIFIED** `HLD-COMBAT-004` — Action Economy: replace `[OPEN]` AP pool/flags question with the confirmed three-bucket system

## Capabilities

### New Capabilities
- None

### Modified Capabilities
- `hld-combat-system`: Remove HLD-COMBAT-002 and HLD-COMBAT-003; replace HLD-COMBAT-004 with confirmed three-bucket action economy

## Impact

- No game code (spec-only change — no code exists yet)
- `hld-technical-architecture` references `ForceRowHandler` in `LLD-ABILITIES-001` — a follow-on change should remove that handler from the confirmed list once this change is synced
- `hld-combat-system` `HLD-COMBAT-011` (Default Strike) and `LLD-ITEMS-001` (item categories) already align with the three-bucket model — no changes needed there
