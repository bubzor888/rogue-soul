## MODIFIED Requirements

### Requirement: [LLD-ARCH-003] Action Command Pattern

Add `READ_THE_ROAD_COMMIT` to the supported action types:

```
{ "type": "DEFAULT_STRIKE" }
{ "type": "EVADE" }
{ "type": "USE_ABILITY", "ability_id": "...", "target_id": "..." }
{ "type": "USE_ITEM", "slot_index": N, "target_id": "..." }
{ "type": "END_TURN" }
{ "type": "CHOOSE_DOOR", "room_id": "..." }
{ "type": "REPENT_DISCARD", "slot_index": N }
{ "type": "READ_THE_ROAD_COMMIT", "send_to_bottom": [N, ...] }
```

`READ_THE_ROAD_COMMIT.send_to_bottom` is an `Array[int]` of 0–3 indices into the top of the draw pile (0 = top card, 1 = second, 2 = third). An empty array means "keep all in place." Duplicate indices are invalid; indices outside [0, min(2, draw_pile.size()-1)] are invalid.

Add scenarios:

#### Scenario: READ_THE_ROAD_COMMIT only legal during Read the Road
- **WHEN** `combat_state.read_the_road_active` is `false`
- **THEN** `get_legal_combat_actions()` does not include any `READ_THE_ROAD_COMMIT` action

#### Scenario: Read the Road active — only READ_THE_ROAD_COMMIT returned
- **WHEN** `combat_state.read_the_road_active` is `true`
- **THEN** `get_legal_combat_actions()` returns exactly one `READ_THE_ROAD_COMMIT` action with no pre-filled `send_to_bottom` (the player chooses); no other action types are included

---

### Requirement: [LLD-ARCH-017] GameState Schema

Add to **CombatState fields**:

`read_the_road_active: bool` — set to `true` by the `peek_omen_deck` handler immediately after `assemble_omen_deck` completes; cleared to `false` by `resolve_player_action` when `READ_THE_ROAD_COMMIT` is processed. Default: `false`. When `true`, `get_legal_combat_actions()` returns only `READ_THE_ROAD_COMMIT`.

Add scenarios:

#### Scenario: read_the_road_active false when no peek pending
- **WHEN** combat has started and the Pilgrim's ability has already resolved (or no peek ability is present)
- **THEN** `combat_state.read_the_road_active` is `false`; `get_legal_combat_actions()` returns the standard action set

#### Scenario: read_the_road_active set after assemble_omen_deck
- **WHEN** `assemble_omen_deck` completes for a vessel with a `peek_omen_deck` handler
- **THEN** `combat_state.read_the_road_active` is `true` and only `READ_THE_ROAD_COMMIT` is a legal action

---

### Requirement: [LLD-ARCH-019] CombatResolver Interface

**Update `get_legal_combat_actions`:**

Priority ordering for gating branches:
1. If `combat_state.read_the_road_active` is `true`: return ONLY `READ_THE_ROAD_COMMIT`. No other actions.
2. If `combat_state.pending_repent_slots` is non-empty: return ONLY `REPENT_DISCARD` actions (one per slot). No other actions.
3. Otherwise: standard action set (Default Strike, Evade, ability charges, item charges, companions).

**Update `resolve_player_action`:**

Add branch before the existing standard-action branch:

```
If action.type == "READ_THE_ROAD_COMMIT":
  - Validate that combat_state.read_the_road_active is true; if false, log error and return state unchanged.
  - Validate send_to_bottom: all indices in [0, min(2, draw_pile.size()-1)], no duplicates.
    If invalid, log error and return state unchanged.
  - Process in descending index order: for each index in send_to_bottom (sorted descending),
    pop draw_pile[index] and append it to the end of draw_pile.
  - Set combat_state.read_the_road_active = false.
  - Return updated GameState. Do NOT advance the omen cycle; combat setup continues normally.
```

**Update `assemble_omen_deck`:**

After building and shuffling the draw pile, execute ability handlers from the vessel's passive abilities. If any handler sets `read_the_road_active = true`, return the updated GameState immediately — the caller (RunController or equivalent) must then wait for `READ_THE_ROAD_COMMIT` before proceeding to the first omen draw.

Add scenarios:

#### Scenario: Legal actions always include Default Strike and Evade (no pending choice)
- **WHEN** the vessel has zero item charges remaining, no ability charges, `pending_repent_slots` is `[]`, and `read_the_road_active` is `false`
- **THEN** `get_legal_combat_actions()` returns exactly two actions: Default Strike and Evade

#### Scenario: read_the_road_active takes priority over pending_repent_slots
- **WHEN** both `read_the_road_active` is `true` and `pending_repent_slots` is non-empty (edge case: should not occur in practice, but spec must define priority)
- **THEN** `get_legal_combat_actions()` returns only `READ_THE_ROAD_COMMIT`; Repent choice is deferred

#### Scenario: READ_THE_ROAD_COMMIT with partial send — descending splice order
- **WHEN** the player submits `READ_THE_ROAD_COMMIT` with `send_to_bottom: [2, 0]` and draw_pile is `[A, B, C, D, E]`
- **THEN** indices are processed descending (2 first, then 0): C is appended → `[A, B, D, E, C]`; A is appended → `[B, D, E, C, A]`; `read_the_road_active` is cleared

#### Scenario: READ_THE_ROAD_COMMIT with empty send — pile unchanged
- **WHEN** the player submits `READ_THE_ROAD_COMMIT` with `send_to_bottom: []`
- **THEN** draw_pile order is unchanged; `read_the_road_active` is cleared to `false`

---

**Remove min-1 damage clamp from damage resolution order:**

The damage resolution step list currently ends with "8. Clamp to minimum 1." Remove this step entirely. Damage may resolve to 0. Absorption effects (e.g. Hardened) can reduce incoming damage to 0 with no floor applied.

Updated damage resolution order (7 steps):

```
0. Evade miss check
1. Base damage and type
2. Flat attacker bonuses (Emboldened Physical)
3. Passive modifiers (Last Stand ×1.5)
4. Buff modifiers (Charged ×2; Emboldened non-Physical ×1.5)
5. Resistance (×0.5)
6. Vulnerability (×1.5)
7. Resistance + Vulnerability cancel → net ×1.0
```

Remove scenario (no longer valid):
> "Scenario: Damage always deals at least 1"

Add scenario:

#### Scenario: Hardened absorption can reduce damage to 0
- **WHEN** an enemy with Hardened magnitude 5 is struck for 4 damage (after all multipliers)
- **THEN** Hardened absorbs all 4 points; the enemy takes 0 damage; no minimum clamp applies
