## Why

`lld-abilities` currently lacks a structure for distinguishing passive abilities from action abilities, and has no requirements for the vessel abilities defined in `lld-vessels`. Adding ability type and action bucket annotations ties each ability to the action economy defined in `HLD-COMBAT-004`, and pulling vessel abilities into `lld-abilities` gives them a single canonical LLD home.

## What Changes

- **LLD-ABILITIES-003 (Good as New)**: Add type (Action), action bucket (Support — see `HLD-COMBAT-004`), charges.
- **LLD-ABILITIES-004 (Throw Rock)**: Add type (Action), action bucket (Attack — see `HLD-COMBAT-004`).
- **LLD-ABILITIES-005 (Read the Road — Pilgrim Passive)**: New. Type: Passive. Trigger: combat start, before first omen cycle. Effect: view top 3 omen deck cards, send any to the bottom. References `LLD-VESSELS-001`.
- **LLD-ABILITIES-006 (Hardy — Drifter Active)**: New. Type: Action, bucket: Support. Effect: clear one Hardy-clearable debuff. Charges: 3/floor. References `LLD-VESSELS-002`.
- **LLD-ABILITIES-007 (Last Stand — Hedge Knight Passive)**: New. Type: Passive. Trigger: always active when HP < 25% max. Effect: all attacks deal ×1.5 damage. References `LLD-VESSELS-003`.
- **LLD-ABILITIES-008 (Charge — Hedge Knight Active)**: New. Type: Action, bucket: Support. Effect: next attack deals ×2 damage; buff consumed on next attack (hit or miss). Charges: `[OPEN·MVP3]`. References `LLD-VESSELS-003`.

## Capabilities

### New Capabilities

_(none)_

### Modified Capabilities

- `lld-abilities`: Annotate existing requirements with type/bucket; add LLD-ABILITIES-005 through 008.

## Impact

- `openspec/specs/lld-abilities/spec.md` — 2 updated, 4 new requirements.
- `lld-vessels` references these requirements by describing the abilities; no changes needed there — the two specs are complementary (vessel spec says what abilities a vessel has; ability spec defines those abilities).
