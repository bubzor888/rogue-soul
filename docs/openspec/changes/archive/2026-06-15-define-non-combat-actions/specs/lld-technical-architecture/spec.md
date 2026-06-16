## MODIFIED Requirements

### Requirement: [LLD-ARCH-003] Action Command Pattern
All game decisions SHALL be serialisable Dictionary commands. ActionInjector is the single interface through which all decisions (from UI, AI, or debug tools) enter the game loop.

```
{ "type": "USE_ABILITY", "ability_id": "slash", "target_id": "enemy_0" }
{ "type": "USE_ITEM", "slot_index": 2, "target_id": "self" }
{ "type": "END_TURN" }
{ "type": "CHOOSE_DOOR", "room_id": "room_12" }
{ "type": "REPENT_DISCARD", "slot_index": N }
{ "type": "READ_THE_ROAD_COMMIT", "send_to_bottom": [N, ...] }
{ "type": "ACCEPT_TRADE", "offer_index": N }
{ "type": "DECLINE_TRADE" }
{ "type": "ACCEPT_OPTION_1" }
{ "type": "ACCEPT_OPTION_2" }
{ "type": "CHOOSE_LOOT", "item_id": "ember_shard" }
{ "type": "DECLINE_LOOT" }
```

`get_legal_actions()` MUST always return at least one valid action in a non-terminal state. `submit_action()` with an illegal action MUST log an error and return state unchanged — never throw.

**`REPENT_DISCARD` action:** Legal only when `combat_state.pending_repent_slots` is non-empty (see `LLD-ARCH-017`). `slot_index` must be one of the indices in `pending_repent_slots`. When `pending_repent_slots` is non-empty, `get_legal_combat_actions()` returns ONLY `REPENT_DISCARD` actions — one per pending slot — and no other action types. Resolving the action discards the item at that slot, heals the player 5 HP directly, decrements `item_burden_score` by 1, emits `SignalBus.item_discarded`, and clears `pending_repent_slots` (see `LLD-ARCH-019`).

**`READ_THE_ROAD_COMMIT` action:** Legal only when `combat_state.read_the_road_active` is `true` (see `LLD-ARCH-017`). `send_to_bottom` is an `Array[int]` of 0–3 indices into the top of the draw pile (0 = top card, 1 = second, 2 = third); an empty array means keep all in place. Duplicate indices and out-of-range indices are invalid. When `read_the_road_active` is `true`, `get_legal_combat_actions()` returns ONLY `READ_THE_ROAD_COMMIT` — no other action types. Resolving the action reorders the draw pile and clears `read_the_road_active` (see `LLD-ARCH-019`).

**`ACCEPT_TRADE` action:** Legal only in `NON_COMBAT_EVENT` phase when `navigation_state.event_type` is `"wandering_soul"` or `"mf_cat_a"` and `event_offers` is non-empty. `offer_index` must be a valid index into `navigation_state.event_offers`. Resolving the action applies the trade (pays give side, receives receive side per the TradeOffer Dictionary at that index), removes the accepted offer from `event_offers`, and emits `SignalBus.item_acquired` or equivalent. Multiple trades may be accepted in sequence (Wandering Soul allows accepting all offers); `get_legal_actions()` continues returning `ACCEPT_TRADE` for remaining offers and `DECLINE_TRADE` until `event_offers` is empty, at which point RunController transitions to `NAVIGATION`.

**`DECLINE_TRADE` action:** Legal in `NON_COMBAT_EVENT` phase when `event_type` is `"wandering_soul"` or `"mf_cat_a"`. Submitting this action means the player is done with the event (walks away from remaining offers). RunController clears `event_offers` and transitions to `NAVIGATION`. For `"mf_cat_a"` this represents walking away from the single fair-trade offer.

**`ACCEPT_OPTION_1` / `ACCEPT_OPTION_2` actions:** Legal only in `NON_COMBAT_EVENT` phase when `event_type` is `"mf_cat_c"`. `DECLINE_TRADE` is NOT legal in this event type — the player must choose one option (see `HLD-MF-005`). `ACCEPT_OPTION_1` resolves the bad deal (player pays the cost item, receives the reward item from Option 1). `ACCEPT_OPTION_2` resolves cutting losses (player pays the loss from Option 2, receives nothing). After either resolves, RunController transitions to `NAVIGATION`.

**`CHOOSE_LOOT` action:** Legal only in `LOOT_SELECTION` phase. `item_id` must be one of the two item_ids in `navigation_state.loot_offers`. Resolving the action adds the chosen item to the player's inventory (incrementing `item_burden_score` by 2; see `HLD-RUN-007`), emits `SignalBus.item_acquired`, clears `loot_offers`, and RunController transitions to `NAVIGATION`. If the inventory has no free slot, the item cannot be picked — `get_legal_actions()` excludes that offer (only `DECLINE_LOOT` is returned).

**`DECLINE_LOOT` action:** Legal in `LOOT_SELECTION` phase. The player walks away from both loot options with nothing. RunController clears `loot_offers` and transitions to `NAVIGATION`.

#### Scenario: Illegal action safety
- **WHEN** an illegal action is submitted to ActionInjector
- **THEN** the game state is unchanged and an error is logged; no exception is raised

#### Scenario: REPENT_DISCARD only legal when Repent choice is pending
- **WHEN** `combat_state.pending_repent_slots` is empty
- **THEN** `get_legal_combat_actions()` does not include any `REPENT_DISCARD` action; Default Strike, Evade, and other standard actions are returned normally

#### Scenario: Repent pending — only REPENT_DISCARD actions returned
- **WHEN** `combat_state.pending_repent_slots` is `[1, 2]` (slots 1 and 2 are revealed)
- **THEN** `get_legal_combat_actions()` returns exactly two `REPENT_DISCARD` actions with `slot_index: 1` and `slot_index: 2`; no other action types are included

#### Scenario: READ_THE_ROAD_COMMIT only legal during Read the Road
- **WHEN** `combat_state.read_the_road_active` is `false`
- **THEN** `get_legal_combat_actions()` does not include any `READ_THE_ROAD_COMMIT` action

#### Scenario: Read the Road active — only READ_THE_ROAD_COMMIT returned
- **WHEN** `combat_state.read_the_road_active` is `true`
- **THEN** `get_legal_combat_actions()` returns exactly one `READ_THE_ROAD_COMMIT` action; no other action types are included

#### Scenario: Wandering Soul — accept one offer, more remain
- **WHEN** the player submits `ACCEPT_TRADE { offer_index: 0 }` in a Wandering Soul event with 3 offers
- **THEN** that trade resolves; `event_offers` now has 2 entries; `get_legal_actions()` returns `ACCEPT_TRADE` for indices 0 and 1 plus `DECLINE_TRADE`

#### Scenario: Wandering Soul — decline ends event
- **WHEN** the player submits `DECLINE_TRADE` in a Wandering Soul event
- **THEN** RunController clears `event_offers` and transitions to `NAVIGATION` regardless of how many offers remain

#### Scenario: MF Cat C — no decline available
- **WHEN** the game is in `NON_COMBAT_EVENT` with `event_type: "mf_cat_c"`
- **THEN** `get_legal_actions()` returns only `ACCEPT_OPTION_1` and `ACCEPT_OPTION_2`; `DECLINE_TRADE` is not included

#### Scenario: CHOOSE_LOOT with full inventory
- **WHEN** the player is in `LOOT_SELECTION` and all 3 inventory slots are occupied
- **THEN** `get_legal_actions()` returns only `DECLINE_LOOT`; no `CHOOSE_LOOT` actions are included

#### Scenario: DECLINE_LOOT — walk away empty-handed
- **WHEN** the player submits `DECLINE_LOOT` in `LOOT_SELECTION` phase
- **THEN** no item is added to inventory; `loot_offers` is cleared; RunController transitions to `NAVIGATION`

---

### Requirement: [LLD-ARCH-017] GameState and Domain Entities
GameState SHALL be a `Resource` subclass in `src/domain/` composed of typed sub-Resources. All sub-types SHALL also be `Resource` subclasses. Every field in every type MUST be JSON-serialisable (no Node references, no Callable, no Object references).

**GameState fields:**

| Field | Type | Notes |
|---|---|---|
| `run_seed` | int | Base seed for all RNG streams |
| `vessel_state` | VesselState | Current vessel runtime state |
| `inventory` | Array[ItemInstance] | Up to 3 slots; null entries are empty slots |
| `bound_companion` | CompanionState | Null if vessel has no bound companion |
| `temporary_companion` | CompanionState | Null if no temporary companion active |
| `floor_number` | int | Current floor (3 for MVP1) |
| `run_phase` | int | RunPhase enum value |
| `navigation_state` | NavigationState | Current navigation context |
| `combat_state` | CombatState | Null when not in COMBAT phase |
| `item_burden_score` | int | Whole-run accumulated item burden (see HLD-RUN-007); initialized from vessel starting items at run start; updated by RunController (acquisition, run start), ActionInjector (item_broken), and CombatResolver (Repent discard) |

**VesselState fields:** `vessel_id: String`, `hp: int`, `max_hp: int`, `ability_states: Array[AbilityState]`, `active_statuses: Array[StatusInstance]`, `is_evading: bool` (true when the vessel chose Evade this turn; resets to false at the start of each player turn before any action is processed), `is_stunned: bool` (true when the vessel has been stunned by a Shocked shift trigger; blocks the Action bucket for the next player turn; resets to false at the start of resolve_player_action)

**AbilityState fields:** `ability_id: String`, `remaining_charges: int`

**ItemInstance fields:** `item_id: String`, `remaining_charges: int`

**StatusInstance fields:** `status_id: String`, `remaining_ticks: int`, `magnitude: int` (used for statuses whose numeric value evolves over ticks: Chilled's accumulating flat damage reduction, Poisoned's current damage value, Bleed's current stack count; 0 for statuses that do not use it), `trigger: String` (`"tick"` = effect fires on each omen tick while remaining_ticks > 0; `"shift"` = effect fires once when remaining_ticks hits 0 at the omen shift; default `"tick"`), `string_param: String` (type qualifier for parameterized statuses; empty string if not applicable; e.g. `"fire"` when status_id is `"type_convert"`, `"vulnerable"`, or `"emboldened"`; CombatResolver reads this to determine which type the effect applies to; default `""`)

**CompanionState fields:** `companion_id: String`, `ability_states: Array[AbilityState]` (for companion abilities with charges), `companion_timer: int` (generic countdown for companions with a budget, e.g. Shadow's 20 HP drain limit; copied from `CompanionData.initial_timer` on activation; -1 = not used by this companion; decremented by CombatResolver when the timer-consuming effect fires; companion departs when this reaches 0), `companion_context: Dictionary` (companion-specific runtime state not covered by standard fields, e.g. Shadow's `{ "current_target_instance_id": "wolf_0" }`; read and written by the companion's handler chain). No `hp` field — companions are not targetable in combat (see `HLD-COMPANION-001`).

**NavigationState fields:** `rooms_completed_this_floor: int`, `segment_room_counts: Dictionary` (room type → count, for pool exhaustion per `HLD-DOOR-004`), `doors_ahead: Array[DoorData]` (the current two-door choice; empty outside NAVIGATION phase), `companion_offered_this_floor: bool` (true once any companion encounter has fired this floor — Worn Map or Memory Fragment; blocks further companion draws from MF pool per `HLD-MF-004`), `event_type: String` (identifies the current non-combat event sub-type: `"wandering_soul"` | `"mf_cat_a"` | `"mf_cat_c"` | `"companion"` | `""`; empty string when not in `NON_COMBAT_EVENT` phase), `event_offers: Array[Dictionary]` (trade offer Dictionaries in TradeOffer format from `LLD-ARCH-021`; populated by RunController when entering a trade event; empty Array outside `NON_COMBAT_EVENT` phase or after the event resolves), `loot_offers: Array[String]` (exactly 2 item_id strings set by `LootGenerator` when entering `LOOT_SELECTION`; empty Array outside that phase)

**DoorData fields:** `room_type: String` (RoomType enum value), `encounter_id: String` (enemy_id for combat; event_id for non-combat), `room_id: String` (unique per-run identifier for logging)

**CombatState fields:** `enemies: Array[EnemyState]`, `turn_number: int`, `omen_deck: OmenDeckState`, `current_cycle: OmenCycleState` (null between cycles), `pending_repent_slots: Array[int]` (slot indices in `GameState.inventory` revealed by Repent and awaiting player discard choice; empty array when no Repent choice is pending; set by `resolve_omen_cycle_start` when Repent fires on player side with items present; cleared by `resolve_player_action` on `REPENT_DISCARD` resolution; see `LLD-ARCH-019`), `read_the_road_active: bool` (set to `true` by the `peek_omen_deck` handler immediately after `assemble_omen_deck` completes; cleared to `false` by `resolve_player_action` when `READ_THE_ROAD_COMMIT` is processed; default `false`; when `true`, `get_legal_combat_actions()` returns only `READ_THE_ROAD_COMMIT`; see `LLD-ARCH-019`)

**EnemyState fields:** `enemy_id: String`, `instance_id: String` (unique per-combat, e.g. `"skeleton_0"` and `"skeleton_1"` for two Skeletons — enables individual targeting), `hp: int`, `max_hp: int`, `active_statuses: Array[StatusInstance]`, `current_intent: String` (intent type ID set at start of each enemy turn; empty string if not yet set), `last_intent_id: String` (intent type ID selected on the previous turn; empty string at combat start), `intent_streak: int` (number of consecutive turns the current intent has been selected; resets to 1 on intent change, increments on repeat; 0 at combat start), `is_charging: bool` (true when a Charge→Release intent is in the charge phase; the release fires on the next turn unconditionally), `is_evading: bool` (true when this enemy chose Evade on its turn; resets to false at the start of that enemy's resolution in resolve_enemy_turns), `is_stunned: bool` (true when this enemy has been stunned by a Shocked shift trigger; the enemy skips its action this turn; resets to false at the start of that enemy's resolution in resolve_enemy_turns)

**OmenDeckState fields:** `draw_pile: Array[Dictionary]`, `discard_pile: Array[Dictionary]`. Each entry is `{ "card_id": String, "timer_value": int }`. Timer values are assigned once when the deck is assembled at combat start (see `LLD-OMEN-MECH-009`) and do not change on reshuffle — the discard pile preserves the originally-assigned values.

**OmenCycleState fields:** `drawn_cards: Array[Dictionary]` (exactly 3 entries, same `{ card_id, timer_value }` format as the deck), `player_choice_index: int` (-1 = not yet chosen), `random_assignment_index: int` (-1 = not yet assigned), `timer_index: int` (index into drawn_cards for the timer card), `sides_assigned: bool`

#### Scenario: Two enemies are individually targetable
- **WHEN** a combat contains two Skeletons
- **THEN** their EnemyState instances have `instance_id` values `"skeleton_0"` and `"skeleton_1"` respectively; actions targeting one do not affect the other

#### Scenario: CombatState is null outside combat
- **WHEN** the game is in NAVIGATION phase
- **THEN** `game_state.combat_state` is null; any attempt to read combat fields must check for null first

#### Scenario: CompanionState has no HP
- **WHEN** an enemy selects its intent
- **THEN** companions are never valid attack targets; CombatResolver does not consider CompanionState when resolving enemy damage

#### Scenario: event_offers populated on NON_COMBAT_EVENT entry
- **WHEN** RunController enters `NON_COMBAT_EVENT` phase for a Wandering Soul encounter
- **THEN** `navigation_state.event_type` is set to `"wandering_soul"` and `navigation_state.event_offers` contains 2–3 TradeOffer Dictionaries generated by `TradeGenerator`

#### Scenario: loot_offers populated on LOOT_SELECTION entry
- **WHEN** RunController enters `LOOT_SELECTION` phase after a combat
- **THEN** `navigation_state.loot_offers` contains exactly 2 item_id strings generated by `LootGenerator`; it is empty Array in all other phases

#### Scenario: event_type empty outside NON_COMBAT_EVENT
- **WHEN** the game is in NAVIGATION or COMBAT phase
- **THEN** `navigation_state.event_type` is `""`; `event_offers` is an empty Array

---

## ADDED Requirements

### Requirement: [LLD-ARCH-022] LootGenerator
LootGenerator SHALL be a `RefCounted` subclass in `src/application/`. It is the sole system responsible for constructing the two-item loot offer array presented to the player in the `LOOT_SELECTION` phase after each combat. It selects items from the normal or elite drop pools based on whether the preceding combat was an elite encounter. It uses the LOOT RNG stream for all randomness and does not modify GameState directly — it returns an `Array[String]` of item_ids that RunController stores in `NavigationState.loot_offers`.

**Interface:**

```
generate_loot_offers(game_state: GameState, elite: bool) -> Array[String]
    Returns exactly 2 item_id strings.
    elite=true: draws from elite durability pool (LLD-ITEMS-006) and elite consumable
      pool (LLD-ITEMS-008).
    elite=false: draws from normal durability pool (LLD-ITEMS-005) and normal consumable
      pool (LLD-ITEMS-007).
    One item is drawn from the durability pool and one from the consumable pool, giving
    the player a meaningful choice between an attack/support item and a consumable.
    Both draws use the LOOT RNG stream.
    If a pool is empty (e.g. no consumables defined yet), both draws come from the
    non-empty pool. If both pools are empty, returns an empty Array (RunController
    transitions directly to NAVIGATION — same as DECLINE_LOOT).
```

#### Scenario: Elite combat produces elite loot offers
- **WHEN** `generate_loot_offers` is called with `elite: true`
- **THEN** both returned item_ids are drawn from the elite pools only; no normal-tier items appear

#### Scenario: Normal combat produces normal loot offers
- **WHEN** `generate_loot_offers` is called with `elite: false`
- **THEN** both returned item_ids are drawn from the normal pools only; no elite-tier items appear

#### Scenario: One durability, one consumable
- **WHEN** `generate_loot_offers` produces two items from non-empty pools
- **THEN** one item_id is from the durability pool for that tier and one is from the consumable pool; the player always has a weapon/support option and a consumable option

#### Scenario: LootGenerator uses LOOT stream only
- **WHEN** `generate_loot_offers` makes any random selection
- **THEN** all random calls use the LOOT RNG stream; no other stream is consumed

---

### Requirement: [LLD-ARCH-023] Shift Status Resolution Order
When multiple shift-triggered `StatusInstance`s (those with `trigger: "shift"` and `remaining_ticks == 0`) fire at Step 1 of `resolve_omen_cycle_start`, they SHALL be processed in the following order for each unit:

1. `death_mark` — the unit dies instantly; all remaining shift statuses on that unit are skipped
2. `shocked` — set `is_stunned = true` on the unit
3. `exposed` — mark the unit as pending Vulnerable (Physical) application (resolved at Step 4)

Any future shift-trigger statuses not listed here are processed after `exposed` in definition order.

#### Scenario: Death Mark fires before Shocked on same unit
- **WHEN** an enemy has both `death_mark` and `shocked` StatusInstances at remaining_ticks == 0 at the omen shift
- **THEN** `death_mark` fires first — the enemy dies; `shocked` does not set `is_stunned` on that unit (it is already dead)

#### Scenario: Death Mark does not affect other units' shift statuses
- **WHEN** enemy A has `death_mark` and enemy B has `shocked`, both at remaining_ticks == 0
- **THEN** enemy A dies from `death_mark`; enemy B's `shocked` processes normally and sets `is_stunned = true` on enemy B
