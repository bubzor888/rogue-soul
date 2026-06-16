## Why

`LLD-ITEMS-004` defines the Pilgrim as starting every run with **three** items (Walking Staff, Spoiled Potion, Worn Map), but the `item_burden_score` initialization scenario in `LLD-ARCH-017` asserts the Pilgrim "has 1 starting item: Walking Staff" and initializes the burden to 1. These contradict each other. `HLD-RUN-007` is unambiguous that burden initializes at +1 per starting item, so the Pilgrim's correct initial burden is 3. The contradiction must be resolved before the burden score is implemented (it feeds the Judge's burden-tier encounter behavior), or the implementation will encode the wrong starting value.

## What Changes

- Correct the `item_burden_score initialized at run start` scenario in `LLD-ARCH-017` so it reflects the Pilgrim's three starting items (Walking Staff, Spoiled Potion, Worn Map) and an initial burden score of 3.
- No mechanic changes: `HLD-RUN-007`'s rule (+1 per starting item) and its generic 2-item illustration scenario are already correct and remain unchanged.
- No code exists yet, so there is no implementation to migrate — this is a spec-accuracy fix.

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `lld-technical-architecture`: corrects the `LLD-ARCH-017` burden-initialization scenario from "1 starting item → 1" to "3 starting items → 3", aligning it with `LLD-ITEMS-004`.

## Impact

- **Specs:** `openspec/specs/lld-technical-architecture/spec.md` (one scenario under `LLD-ARCH-017`).
- **Downstream docs:** `docs/implementation-plan.md` T8.2 flags this contradiction; once applied, the flag can note the resolved value (Pilgrim burden init = 3).
- **Code:** none yet. The future `RunController` burden-init logic (plan task T6.4) must use 3 for the Pilgrim.
- **No behavioral/runtime change** beyond making the spec internally consistent.
