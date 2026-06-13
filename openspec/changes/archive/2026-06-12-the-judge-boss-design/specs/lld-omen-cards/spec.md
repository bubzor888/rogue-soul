## ADDED Requirements

### Requirement: [LLD-OMEN-CARD-020] Repent (Enemy Card — Judge)
The Repent omen card is contributed exclusively by The Judge — 3 copies are added to the omen deck at the start of the Judge encounter. It is the only omen contribution from The Judge or either Witness.

**On Judge side:** No effect. Steering Repent to The Judge's side is always a legal option and produces no outcome. The card still functions as a timer card if it is the leftover draw.

**On player side:** The player must select 1 item to discard from 2 randomly revealed items drawn from their current inventory. The discarded item is removed from inventory without its effect triggering. The player immediately heals 5 HP (direct heal, not Mending — no omen tick required). The discarded item counts as fully spent for judge_need_score purposes (−1 score, see JNS-002).

`[OPEN·MVP1]` Heal value (5 HP) and item reveal count (2) to be validated in playtesting.

**Omen contribution model:** 3 copies follow neither Tier 1 (family, per-instance) nor Tier 2 (type, per-type) rules — The Judge is a unique entity with a fixed 3-copy contribution. All 3 copies are removed from the deck if The Judge dies (which ends the encounter, so this is academic).

#### Scenario: Repent on player side — item selection
- **WHEN** the player plays Repent to their own side and has 2 or more items in inventory
- **THEN** 2 items are randomly revealed from the player's inventory; the player selects 1 to discard; the selected item is removed from inventory without its effect triggering; the player heals 5 HP; judge_need_score decreases by 1

#### Scenario: Repent on player side — only one item in inventory
- **WHEN** the player plays Repent to their own side and has exactly 1 item in inventory
- **THEN** that item is automatically the discard target (no selection needed); it is removed from inventory without its effect triggering; the player heals 5 HP; judge_need_score decreases by 1

#### Scenario: Repent on player side — no items in inventory
- **WHEN** the player plays Repent to their own side and has no items in inventory
- **THEN** no discard occurs; the player still heals 5 HP; judge_need_score is unchanged

#### Scenario: Repent on Judge side — no effect
- **WHEN** the player plays Repent to The Judge's side
- **THEN** no status is applied; no item is discarded; no healing occurs; the card produces no game-state change

#### Scenario: Repent as timer card
- **WHEN** Repent is the leftover card in an omen draw
- **THEN** its number sets the cycle duration normally; no item discard or healing occurs from the leftover position

#### Scenario: Repent discard reduces judge_need_score
- **WHEN** the player discards a floor-acquired item via Repent (originally +2 at pickup)
- **THEN** judge_need_score decreases by 1; if this drop crosses a tier boundary, the Witnesses use the new tier on their next turn

#### Scenario: Repent discard of per-encounter item reduces score
- **WHEN** the player discards a per-encounter durability item via Repent
- **THEN** judge_need_score decreases by 1; this is the only path to reducing a per-encounter item's score contribution during the Judge fight

#### Scenario: Repent heal is immediate, not Mending
- **WHEN** Repent is played to the player side and triggers
- **THEN** the player's HP increases by 5 immediately at the moment of resolution; no Mending StatusInstance is created; the heal is not subject to omen tick timing
