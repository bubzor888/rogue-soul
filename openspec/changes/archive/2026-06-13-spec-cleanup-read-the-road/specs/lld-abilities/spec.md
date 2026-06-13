## MODIFIED Requirements

### Requirement: [LLD-ABILITIES-005] Pilgrim — Read the Road
**Type:** Passive — triggers automatically at combat start; no bucket consumed.
**Charges:** Passive — no charges.

Trigger: at the start of every combat, immediately after `assemble_omen_deck` completes and before the first omen cycle begins. Effect: the player views the top 3 cards of the assembled omen deck and may send any number of them to the bottom. The remaining cards stay on top in their original relative order. See `LLD-VESSELS-001`.

Handler chain: `peek_omen_deck { "count": 3 }`. This handler sets `combat_state.read_the_road_active = true`. `get_legal_combat_actions()` then returns only a `READ_THE_ROAD_COMMIT` action until the player resolves the choice (see `LLD-ARCH-003`, `LLD-ARCH-019`).

#### Scenario: Read the Road at combat start
- **WHEN** a combat encounter begins
- **THEN** after deck assembly and before the first omen draw, `read_the_road_active` is set to `true` and only `READ_THE_ROAD_COMMIT` is a legal action

#### Scenario: Remaining cards stay in order
- **WHEN** the player sends 1 card (index 1) to the bottom during Read the Road
- **THEN** the card at index 0 stays at position 0, the card at index 2 shifts to position 1, and the sent card is appended to the end of the draw pile; `read_the_road_active` is cleared to `false`

#### Scenario: Player sends no cards
- **WHEN** the player submits `READ_THE_ROAD_COMMIT` with `send_to_bottom: []`
- **THEN** the draw pile is unchanged; `read_the_road_active` is cleared to `false`

#### Scenario: AIPlayerAgent resolves Read the Road
- **WHEN** AIPlayerAgent encounters `read_the_road_active == true`
- **THEN** it submits a valid `READ_THE_ROAD_COMMIT` (e.g., `send_to_bottom: []`); any valid submission is acceptable
