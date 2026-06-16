## MODIFIED Requirements

### Requirement: [LLD-ARCH-009] SignalBus Decoupling
SignalBus SHALL be an Infrastructure autoload. Domain code emits on SignalBus for cross-cutting events. Presentation code connects to SignalBus. Neither layer knows about the other.

**MVP1 signal catalogue:**

| Signal | Emitter | Payload | Consumers |
|---|---|---|---|
| `phase_changed(new_phase, old_phase)` | RunController | RunPhase enums | ScreenManager |
| `save_requested(save_type)` | RunController | SaveType enum | SaveManager |
| `combat_started(combat_state)` | RunController | CombatState | ScreenManager, EventLog |
| `combat_ended(outcome)` | RunController | String ("victory"\|"defeat") | ScreenManager, EventLog |
| `turn_started(turn_number)` | CombatResolver | int | Presentation |
| `action_resolved(action, result)` | CombatResolver | Dictionary, Dictionary | EventLog, Presentation |
| `damage_dealt(source_id, target_id, amount, type)` | CombatResolver | ids, int, String | EventLog, Presentation |
| `status_applied(unit_id, status_id, ticks)` | CombatResolver | ids, int | EventLog, Presentation |
| `status_cleared(unit_id, status_id)` | CombatResolver | ids | EventLog, Presentation |
| `unit_died(unit_id)` | CombatResolver | String | EventLog, Presentation |
| `omen_drawn(cards)` | CombatResolver | Array[String] | EventLog, Presentation |
| `omen_applied(card_id, side)` | CombatResolver | String, String | EventLog, Presentation |
| `item_broken(item_id, slot_index)` | ActionInjector | String, int | EventLog, SignalBus consumers |
| `item_discarded(item_id, slot_index)` | CombatResolver | String, int | EventLog |
| `item_acquired(item_id)` | RunController | String | EventLog |
| `room_entered(room_type, encounter_id)` | RunController | String, String | EventLog |
| `floor_transitioned(from_floor, to_floor)` | RunController | int, int | EventLog |

**`item_discarded` vs `item_broken`:** `item_broken` is emitted by ActionInjector when charge exhaustion destroys an item (the item's remaining_charges reached 0 and `breaks_at_zero: true`). `item_discarded` is emitted by CombatResolver when a player deliberately discards an item via Repent (see `LLD-OMEN-CARD-020`). Both trigger a burden score decrement of −1 (see `HLD-RUN-007`), but they are semantically distinct events logged under different EventLog entries. Neither event replaces the other.

**Payload typing convention:** The Payload column above names the *logical data carried* by each signal, not the declared GDScript parameter type. Because SignalBus is an Infrastructure autoload, it MUST NOT depend on the Domain layer (`LLD-ARCH-001`) — so signal parameters that carry domain types are declared with built-in base types instead:

- enum payloads (`RunPhase` for `phase_changed`, `SaveType` for `save_requested`) are declared as `int`;
- `CombatState` (for `combat_started`) is declared as `Resource`.

Emitting domain code passes the concrete typed values; consumers cast to the domain type as needed. This keeps the bus dependency-free while preserving the catalogue's payload contract. Signals whose payloads are already built-in types (`String`, `int`, `Dictionary`, `Array[String]`) are declared with those types directly.

#### Scenario: Domain-presentation decoupling
- **WHEN** CombatResolver applies damage
- **THEN** it emits `SignalBus.damage_dealt`; the presentation layer updates health bars without CombatResolver knowing any UI exists

#### Scenario: EventLog subscribes via SignalBus
- **WHEN** any logged event signal fires on SignalBus
- **THEN** EventLog's connected handler writes the event to the in-memory buffer — no domain class calls EventLog directly

#### Scenario: item_discarded emitted by CombatResolver on Repent resolution
- **WHEN** the player resolves a `REPENT_DISCARD` action and an item is removed from inventory
- **THEN** CombatResolver emits `SignalBus.item_discarded(item_id, slot_index)` before clearing `pending_repent_slots`; EventLog records the discard event in the `items` category

#### Scenario: item_broken and item_discarded are independent signals
- **WHEN** an item breaks due to charge exhaustion (ActionInjector) and separately a Repent discard occurs (CombatResolver) in the same combat
- **THEN** `item_broken` is emitted for the charge exhaustion; `item_discarded` is emitted for the Repent discard; no handler conflates the two

#### Scenario: SignalBus declares no Domain-typed parameters
- **WHEN** the SignalBus autoload script is implemented
- **THEN** none of its signal parameters are typed as Domain classes (e.g. `RunPhase`, `SaveType`, `CombatState`); domain-carrying parameters use built-in base types (`int`, `Resource`) so the Infrastructure layer imports nothing from Domain
