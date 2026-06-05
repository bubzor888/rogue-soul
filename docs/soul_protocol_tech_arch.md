# Soul Protocol — Technical Architecture
## Version 0.5 · May 2026 · Solo Developer

> **Purpose:** High-level technical design defining modules, patterns, and inter-module contracts for Soul Protocol. This document is the primary reference when beginning implementation.  
> It is a companion to `soul_protocol_v0_4.md` (design decisions) and `soul_protocol_testing_v0_2.md` (testability decisions).
>
> **Design principles applied:**
> - Open/Closed: systems are open for extension across MVPs, closed to modification once stable
> - Dependency Inversion: high-level modules never depend on implementation details
> - Headless-first: the game loop has zero dependency on rendering or input devices
> - All architectural decisions are cross-referenced with design doc rationale where relevant

---

## Table of Contents

1. [Architectural Overview](#1-architectural-overview)
2. [Layer Map](#2-layer-map)
3. [Module Catalogue](#3-module-catalogue)
4. [Module Detail](#4-module-detail)
   - 4.1 [Infrastructure Layer](#41-infrastructure-layer)
   - 4.2 [Domain Layer](#42-domain-layer)
   - 4.3 [Application Layer](#43-application-layer)
   - 4.4 [Presentation Layer](#44-presentation-layer)
5. [Key Design Patterns](#5-key-design-patterns)
6. [Data Flow: A Combat Turn](#6-data-flow-a-combat-turn)
7. [Data Flow: Run Initialisation](#7-data-flow-run-initialisation)
8. [Extension Points by MVP Phase](#8-extension-points-by-mvp-phase)
9. [Open Technical Decisions](#9-open-technical-decisions)
10. [Dependency Map](#10-dependency-map)

---

## 1. Architectural Overview

Soul Protocol is architected as a **layered game loop** with strict dependency direction: inner layers know nothing about outer layers. This is not enforced by the language — GDScript has no access modifiers — but is enforced by project structure and code review discipline.

```
┌────────────────────────────────────────────┐
│            PRESENTATION LAYER              │  UI scenes, rendering, input mapping
│   (Godot scenes, Control nodes, AnimPlayer)│
├────────────────────────────────────────────┤
│            APPLICATION LAYER               │  Run orchestration, screen flow,
│   (RunController, ScreenManager, SaveMgr)  │  save/load, session state
├────────────────────────────────────────────┤
│              DOMAIN LAYER                  │  Combat, navigation, companions,
│  (pure GDScript — no scene dependencies)   │  items, vessels, meta-progression
├────────────────────────────────────────────┤
│           INFRASTRUCTURE LAYER             │  RNG, event log, persistence,
│  (GameConfig, RNGService, EventLog, ...)   │  platform-specific adapters
└────────────────────────────────────────────┘
```

**Godot-specific note:** Autoloads (`GameConfig`, `EventLog`, `RNGService`) live at the infrastructure layer. They are singletons accessible everywhere but should only be *written to* from the domain and application layers. The presentation layer reads them for display only.

---

## 2. Layer Map

| Layer | Godot Location | May depend on | Must not depend on |
|---|---|---|---|
| Infrastructure | `src/infrastructure/` + Autoloads | Nothing | Domain, Application, Presentation |
| Domain | `src/domain/` | Infrastructure only | Application, Presentation, Godot scene tree |
| Application | `src/application/` | Domain + Infrastructure | Presentation, Godot scene tree |
| Presentation | `src/presentation/` (scenes) | All layers | Nothing upward |

The **Domain layer must never instantiate a Node or access the scene tree**. All domain classes are plain GDScript `RefCounted` objects or `Resource` subclasses. This is what makes headless execution possible.

---

## 3. Module Catalogue

| # | Module | Layer | Status | Notes |
|---|---|---|---|---|
| I-1 | GameConfig | Infrastructure | Foundational | Headless flag, debug flag, global constants |
| I-2 | RNGService | Infrastructure | Foundational | Split streams, seeded, derived from base seed |
| I-3 | EventLog | Infrastructure | Foundational | Structured JSON event recorder |
| I-4 | PersistenceService | Infrastructure | Foundational | Save/load abstraction over FileAccess |
| D-1 | GameState | Domain | Foundational | Immutable snapshot of all in-run state |
| D-2 | ActionInjector | Domain | Foundational | Accepts external actions; advances GameState |
| D-3 | CombatResolver | Domain | Core | Orchestrates turn resolution — delegates to ability pipeline |
| D-3a | AbilityPipeline | Domain | Core | Executes an ability through an ordered chain of handlers |
| D-3b | AbilityHandler (base) | Domain | Core | Abstract handler — one responsibility per subclass |
| D-3c | CoreEffectHandlers | Domain | Core | Reusable handlers: damage, heal, move-row, apply-status, summon |
| D-3d | AbilityRegistry | Domain | Core | Loads ability definitions; assembles handler chains from data |
| D-4 | NavigationModel | Domain | Core | Room sequences, floor layout generation |
| D-5 | VesselRegistry | Domain | Core | Vessel definitions, unlock conditions |
| D-6 | ItemRegistry | Domain | Core | Item definitions, break/replenish configuration |
| D-6a | ChargeManager | Domain | Core | Applies replenishment events to abilities and items |
| D-7 | CompanionModel | Domain | Core | Companion state, bound/summoned logic |
| D-8 | MetaProgressionModel | Domain | Core | Soul Codex, vessel archive, run history |
| D-9 | EncounterFactory | Domain | Core | Generates room content from seed + floor |
| A-1 | RunController | Application | Core | Orchestrates a run end-to-end |
| A-2 | ScreenManager | Application | Core | Owns scene transitions |
| A-3 | SaveManager | Application | Core | Coordinates save/load via PersistenceService |
| A-4 | AIPlayerAgent | Application | Post-MVP seed | Random agent first; strategy variants later |
| P-1 | CombatScene | Presentation | Core | Renders combat; dispatches input as actions |
| P-2 | NavigationScene | Presentation | Core | Corridor view, door symbols, floor choice |
| P-3 | HUDOverlay | Presentation | Core | HP, companion status, item bar |
| P-4 | SoulCodexScene | Presentation | Core | Codex viewer, memory fragment display |
| P-5 | DebugOverlay | Presentation | Debug | Event log viewer, stream monitor, stat inspector |

---

## 4. Module Detail

### 4.1 Infrastructure Layer

---

#### I-1 · GameConfig (Autoload)

Single source of truth for environment flags and global constants. Set at startup; never changed at runtime.

```gdscript
# Autoload: GameConfig
const HEADLESS: bool = false        # Set true for simulation runs
const DEBUG: bool = false           # Set true for debug overlay + tools
const SAVE_VERSION: int = 1         # Increment on breaking save schema changes
const REFERENCE_RESOLUTION: Vector2 = Vector2(390, 844)  # Portrait reference (iPhone 14 basis)
```

**Extension:** New flags (e.g. `DEMO_MODE`, `ANALYTICS_ENABLED`) are added here, never scattered.

---

#### I-2 · RNGService (Autoload)

Wraps Godot's `RandomNumberGenerator`. Exposes named streams only — callers never see the underlying RNG objects.

```gdscript
# Autoload: RNGService

enum Stream { NAVIGATION, COMBAT, LOOT, EVENTS }

func seed_run(base_seed: int) -> void
func roll_float(stream: Stream) -> float          # 0.0 – 1.0
func roll_int(stream: Stream, min: int, max: int) -> int
func roll_weighted(stream: Stream, weights: Array[float]) -> int  # returns index
func get_call_count(stream: Stream) -> int        # for debug monitor
func get_base_seed() -> int
```

**Key constraint:** `RandomNumberGenerator` instances are created per stream with `base_seed + stream_index`. Global `randf()` is never called anywhere in the codebase.

**Extension:** New streams are added to the `Stream` enum and initialised in `seed_run()`. Existing streams are unaffected.

---

#### I-3 · EventLog (Autoload)

Writes structured events to an in-memory buffer; flushes to disk at checkpoints.

```gdscript
# Autoload: EventLog

enum Category { NAVIGATION, COMBAT, ITEMS, COMPANIONS, RNG, META }

func record(category: Category, event: String, data: Dictionary) -> void
func flush() -> void        # writes buffer to disk (called at floor transitions, run end)
func get_buffer() -> Array  # for debug overlay
```

**Output format:** newline-delimited JSON  
`{ "tick": 42, "category": "COMBAT", "event": "damage_dealt", "data": { "source": "vessel", "target": "enemy_0", "amount": 14, "row": "FRONT" } }`

**RNG roll logging:** gated behind `GameConfig.DEBUG`. Raw rolls are never written in release builds.

**Extension:** New categories added to enum. Log consumers (AI simulation, analytics) parse by `category` field — no structural changes needed.

---

#### I-4 · PersistenceService (Autoload)

Abstracts all file I/O. Game logic never calls `FileAccess` directly.

```gdscript
# Autoload: PersistenceService

func save_run_state(state: Dictionary) -> void
func load_run_state() -> Dictionary
func save_meta_progression(data: Dictionary) -> void
func load_meta_progression() -> Dictionary
func save_settings(settings: Dictionary) -> void
func load_settings() -> Dictionary
func delete_run_state() -> void     # called on run completion
```

**Format:** JSON. Path resolution is internal — callers never construct paths.  
**Migration:** `GameConfig.SAVE_VERSION` is written into every save. On load, version mismatch triggers a migration path (migration functions are added here as needed).

**Extension:** Backend swap (e.g. cloud save) requires changing only this module.

---

### 4.2 Domain Layer

All domain classes extend `RefCounted` (or `Resource` where serialisation is needed). No `Node`. No scene tree access.

---

#### D-1 · GameState (Resource)

The complete, serialisable state of an in-progress run. **Treated as immutable by convention** — methods return a new state rather than mutating in place. This is essential for the AI player (it can branch states without side effects) and for the event log diff model.

```gdscript
class_name GameState extends Resource

# Run identity
var seed: int
var vessel_id: String
var depth_chosen: int           # 1 | 2 | 3
var current_floor: int
var current_room_index: int

# Vessel state
var vessel_hp: int
var vessel_hp_max: int
var vessel_abilities: Array[AbilityInstance]  # runtime state — charges tracked here

# Companion state
var bound_companion: CompanionState     # null if solo vessel
var summoned_companions: Array[CompanionState]

# Default row positions — set in pre-combat setup; restored after each combat ends
# Keys: "vessel" | "companion_<id>"  Values: RowPosition enum (FRONT | BACK)
var default_rows: Dictionary

# Item inventory
var item_slots: Array[ItemInstance]     # fixed size per vessel archetype

# Combat state (null when not in combat)
var combat_state: CombatState

# Navigation state
var room_sequence: Array[RoomData]      # pre-generated for current floor
var next_room_choices: Array[RoomData]  # the two visible ahead

# Meta context (read-only mirror of MetaProgressionModel for in-run bonuses)
var codex_known_entities: Array[String]

func serialize() -> Dictionary
static func deserialize(data: Dictionary) -> GameState
```

**Extension:** New fields are added with defaults. Serialisation handles missing keys gracefully for forward compatibility.

---

#### D-2 · ActionInjector

The single interface through which all decisions enter the game loop. The UI, debug tools, and AI player all go through here.

```gdscript
class_name ActionInjector

func get_legal_actions(state: GameState) -> Array[Dictionary]
func submit_action(state: GameState, action: Dictionary) -> GameState

# Action dictionary shape (examples):
# { "type": "USE_ABILITY", "ability_id": "slash", "target_id": "enemy_0" }
# { "type": "USE_ITEM", "slot_index": 2, "target_id": "self" }
# { "type": "END_TURN" }
# { "type": "CHOOSE_DOOR", "room_id": "room_12" }
# { "type": "CHOOSE_DEPTH", "depth": 2 }
# { "type": "SET_DEFAULT_ROW", "unit_id": "vessel", "row": "FRONT" }
# { "type": "SET_DEFAULT_ROW", "unit_id": "companion_wraith", "row": "BACK" }
# Note: SET_DEFAULT_ROW is only legal outside of combat (pre-combat setup screen)
```

**Contract:** `get_legal_actions()` always returns at least one valid action when the game is in a non-terminal state. `submit_action()` with an illegal action logs an error and returns the state unchanged — it never throws.

**This is the integration seam for the AI player.** The AI player only ever calls these two functions.

---

#### D-3 · CombatResolver

Orchestrates turn resolution. Knows the sequence of a turn — validate, execute ability, resolve enemy, check terminal conditions — but knows nothing about what any specific ability does. All ability execution is delegated to the `AbilityPipeline`.

```gdscript
class_name CombatResolver

# Returns [new_state, Array[LogEvent]]
func resolve_player_action(state: CombatState, action: Dictionary) -> Array
func resolve_enemy_turn(state: CombatState) -> Array
func get_legal_combat_actions(state: CombatState) -> Array[Dictionary]
func is_terminal(state: CombatState) -> bool   # all enemies dead, or vessel dead
```

**`CombatState`** is a sub-resource of `GameState`. All combatants — vessel, companions, and enemies — are represented uniformly as `UnitState` entries in the `units` dictionary:

```gdscript
class_name CombatState extends Resource

var turn_number: int
var active_unit_id: String
var units: Dictionary           # unit_id -> UnitState
var enemy_intents: Dictionary   # unit_id -> IntentData (telegraphed or hidden — T-3)
var status_effects: Dictionary  # unit_id -> Array[StatusEffect]
```

**`UnitState`** — the common representation for every combatant:

```gdscript
class_name UnitState extends Resource

var unit_id: String             # "vessel" | "companion_<id>" | "enemy_<id>"
var hp: int
var hp_max: int
var row: RowPosition            # FRONT | BACK — independent per unit
var is_player_side: bool        # true for vessel and companions; false for enemies
```

Row is stored on `UnitState` directly, not inferred from team or slot. A companion in the front row and the vessel in the back row is a valid state.

**`CombatState` initialisation** (performed by `CombatResolver` at combat start): each player-side unit's `row` is seeded from `GameState.default_rows`. Enemy rows are set by the encounter definition in `EncounterFactory`. On combat end — win or loss — `CombatResolver` writes current player-side rows back to `GameState.default_rows`, so any ability-driven repositioning mid-combat carries forward as the new default for the next combat.

**What CombatResolver does NOT do:** It never contains damage formulas, healing logic, status effect application, or any vessel-specific behaviour. Those belong in the ability pipeline below.

**Extension:** New turn phases (e.g. a "reaction" phase for post-MVP) are added to `resolve_player_action()`'s sequence. The handlers that populate those phases are added independently.

---

#### D-3a · AbilityPipeline

Executes a single ability by running its `AbilityData`-defined handler chain in order. Each handler in the chain is one discrete effect. The pipeline passes a mutable `AbilityContext` through the chain; each handler reads from it, applies its effect to `CombatState`, and returns the updated context.

This is a **Chain of Responsibility** pattern. The pipeline itself is vessel-agnostic — it only knows how to run a chain. The chain's contents are defined in data.

```gdscript
class_name AbilityPipeline

# Called by CombatResolver
# Returns [new_combat_state, Array[LogEvent]]
func execute(ability: AbilityData, context: AbilityContext, state: CombatState) -> Array
```

**`AbilityContext`** carries everything the chain needs — who is acting, who is targeted, the current state snapshot, and accumulated log events:

```gdscript
class_name AbilityContext extends RefCounted

var caster_id: String
var target_ids: Array[String]   # can be multiple for AoE
var state: CombatState          # read-only reference; handlers return new state
var log_events: Array           # accumulated during the chain
var tags: Dictionary            # arbitrary data handlers can pass forward
                                # e.g. { "damage_dealt": 14, "was_crit": false }
                                # allows later handlers to react to earlier ones
```

**`AbilityData`** defines a vessel ability as an ordered handler chain plus its charge configuration. Abilities and items share the same charge concepts — the difference is only in replenishment triggers and break behaviour:

```gdscript
class_name AbilityData extends Resource

var ability_id: String
var display_name: String
var handler_chain: Array[HandlerConfig]  # ordered — executed in sequence
var targeting_mode: TargetingMode        # SINGLE_ENEMY | ALL_ENEMIES | SELF | ALLY | etc.
var action_cost: int                     # AP consumed (see T-2)
var max_charges: int                     # total uses before replenishment needed
var replenish_triggers: Array[String]    # events that restore all charges
                                         # e.g. ["floor_start", "rest_room", "item:elixir_vial"]
```

`replenish_triggers` is a list of event IDs. When the `RunController` fires a replenishment event (e.g. the player completes a rest room), it broadcasts that event ID and the `ChargeManager` (see below) restores all abilities whose `replenish_triggers` contains it. This keeps replenishment logic out of `CombatResolver` and out of room-handling code.

**`AbilityInstance`** is the runtime wrapper for an ability — parallel to `ItemInstance` for items. `AbilityData` is the static definition; `AbilityInstance` is the per-run mutable state:

```gdscript
class_name AbilityInstance extends Resource

var ability_data: AbilityData
var remaining_charges: int      # depleted on use; restored by replenishment events

func is_usable() -> bool:
    return remaining_charges > 0

func build_context(target_ids: Array[String], state: CombatState) -> AbilityContext
```

Abilities **never break** — when `remaining_charges` reaches zero the ability is exhausted but the `AbilityInstance` remains in the slot. Charges are restored by replenishment events. This is the defining structural difference from items.

```gdscript
class_name HandlerConfig extends Resource

var handler_id: String    # matches a registered AbilityHandler subclass
var params: Dictionary    # e.g. { "base_damage": 12, "attack_type": "MELEE" }
                          #       { "status_id": "bleed", "duration": 2 }
                          #       { "heal_percent": 0.25 }
```

**Example — a vessel ability "Bone Rend" (deals damage, then applies bleed):**
```
handler_chain:
  [0] handler_id: "deal_physical_damage",  params: { base_damage: 10, attack_type: MELEE }
  [1] handler_id: "apply_status",          params: { status_id: "bleed", duration: 3 }
```

A new vessel ability that deals damage, then heals the caster for a portion of it uses the same two handler types — no new code:
```
handler_chain:
  [0] handler_id: "deal_physical_damage",  params: { base_damage: 8, attack_type: MELEE }
  [1] handler_id: "lifesteal",             params: { percent: 0.40 }
```

`lifesteal` reads `context.tags["damage_dealt"]` written by the damage handler — this is what `tags` is for.

---

#### D-3b · AbilityHandler (base class)

Abstract base. One subclass = one discrete, reusable effect. Handlers must be stateless — all working data lives in `AbilityContext` or the returned `CombatState`.

```gdscript
class_name AbilityHandler extends RefCounted

# Subclasses implement this. Returns [new_state, updated_context].
func execute(params: Dictionary, context: AbilityContext, 
             state: CombatState) -> Array:
    assert(false, "AbilityHandler subclass must implement execute()")
    return [state, context]
```

**Naming convention:** Handler class names are `PascalCase` with suffix `Handler`. Their registered `handler_id` is `snake_case` matching the class name: `DealPhysicalDamageHandler` → `"deal_physical_damage"`.

---

#### D-3c · CoreEffectHandlers

The shipped set of reusable handlers. New vessels combine these without writing new code. New handlers are added only when a vessel ability genuinely requires an effect that cannot be composed from existing ones.

| Handler ID | Class | What it does |
|---|---|---|
| `deal_physical_damage` | `DealPhysicalDamageHandler` | Applies base damage with row modifier and physical defence |
| `deal_magical_damage` | `DealMagicalDamageHandler` | Applies base damage ignoring physical defence |
| `deal_pure_damage` | `DealPureDamageHandler` | Applies flat damage — no modifiers, no defence |
| `heal_target` | `HealTargetHandler` | Restores HP to target (vessel, companion, or ally) |
| `lifesteal` | `LifestealHandler` | Heals caster by a % of `context.tags["damage_dealt"]` |
| `apply_status` | `ApplyStatusHandler` | Applies a named status effect with duration |
| `remove_status` | `RemoveStatusHandler` | Removes a named status effect from target |
| `force_row` | `ForceRowHandler` | Moves any unit to a specified row — used by abilities and enemies; not player-initiated |
| `summon_unit` | `SummonUnitHandler` | Instantiates a summoned companion from a summon template |
| `consume_resource` | `ConsumeResourceHandler` | Reduces a named resource on caster (e.g. a vessel-specific fuel) |
| `chain_if` | `ChainIfHandler` | Conditional: executes a sub-chain only if a tag condition is met |
| `aoe_spread` | `AoeSpreadHandler` | Re-executes a sub-chain against all valid targets |

**`chain_if` and `aoe_spread`** are meta-handlers — they take a nested `handler_chain` in their `params`. This allows conditional and multi-target behaviours to be expressed in data without new handler code:

```
# "Grave Chill" — deals magical damage; if target is already bleeding, also freeze them
handler_chain:
  [0] handler_id: "deal_magical_damage",  params: { base_damage: 7 }
  [1] handler_id: "chain_if",             params: {
        condition: { tag: "target_has_status", value: "bleed" },
        on_true: [
          { handler_id: "apply_status", params: { status_id: "frozen", duration: 2 } }
        ]
      }
```

**Extension (open/closed):** New handlers are new classes that extend `AbilityHandler`. `CoreEffectHandlers` is not modified — it is a label for the shipped set, not a class. `AbilityRegistry` discovers handlers by class scan, not by a registry list.

---

#### D-3d · AbilityRegistry

Loads `AbilityData` resources from `data/abilities/`. Assembles live handler chains from the handler IDs in each `AbilityData`, resolving handler IDs to handler instances.

```gdscript
class_name AbilityRegistry

func get_ability(ability_id: String) -> AbilityData
func build_pipeline(ability: AbilityData) -> AbilityPipeline
    # Resolves handler_id strings to AbilityHandler instances
    # Fails loudly at startup if any handler_id is unregistered

func register_handler(handler_id: String, handler: AbilityHandler) -> void
    # Called at startup for each handler subclass
```

**Startup validation:** `AbilityRegistry` loads all `AbilityData` files and verifies every `handler_id` in every chain resolves to a known handler. Unknown handler IDs are a fatal startup error, not a runtime surprise.

**Why this matters for vessel expansion:** When a new vessel is added, its abilities are new `.tres` files in `data/abilities/`. If they compose existing handlers, zero new code is written. If they need a genuinely new effect, exactly one new `AbilityHandler` subclass is written and registered. `CombatResolver`, `AbilityPipeline`, and all other handlers are untouched.

---

#### D-4 · NavigationModel

Generates and manages the room sequence for a floor.

```gdscript
class_name NavigationModel

func generate_floor(floor_number: int, depth: int, rng: RNGService) -> Array[RoomData]
func get_visible_rooms(sequence: Array[RoomData], current_index: int) -> Array[RoomData]
    # Returns: [current_room, next_choice_a, next_choice_b]
func advance(sequence: Array[RoomData], chosen_room_id: String) -> int  # new index
```

**`RoomData`:**
```gdscript
class_name RoomData extends Resource

var room_id: String
var room_type: RoomType     # Enum: COMBAT, ELITE, REST, MEMORY_FRAGMENT, 
                            #       WANDERING_SOUL, ANOMALY, ECHO_CHAMBER, BOSS
var floor_number: int
var seed_offset: int        # used by EncounterFactory to generate content
```

**Floor composition rules** (data-driven, not hardcoded): room type ratios and mandatory placements (e.g. always end with BOSS) are defined in a `FloorProfile` resource. Different floor numbers load different profiles. Adding a new floor profile does not require touching `NavigationModel`.

---

#### D-5 · VesselRegistry

Loads and validates vessel definitions. Does not own game state — it is a catalogue.

```gdscript
class_name VesselRegistry

func get_vessel(vessel_id: String) -> VesselData
func get_unlocked_vessels(progression: MetaProgressionData) -> Array[VesselData]
func check_unlock_condition(vessel_id: String, run_history: Array) -> bool
```

**`VesselData`** (Resource, loaded from `.tres` or JSON files in `data/vessels/`):
```gdscript
class_name VesselData extends Resource

var id: String
var display_name: String
var lore_fragment: String
var base_hp: int
var abilities: Array[AbilityData]       # fixed — no in-run changes
var bound_companion_id: String          # empty if solo archetype
var item_slot_count: int
var summon_capacity: int                # 0 for archetypes with no summon ability
var unlock_condition: UnlockCondition   # Resource subclass
```

**Extension (open/closed):** New vessels are added by creating new data files. `VesselRegistry` discovers them via directory scan — no registration required. New `UnlockCondition` subtypes are added as new Resource classes; existing ones are not modified.

---

#### D-6 · ItemRegistry

Same pattern as `VesselRegistry` — a catalogue, not a state holder.

```gdscript
class_name ItemRegistry

func get_item(item_id: String) -> ItemData
func get_items_for_table(table_id: String) -> Array[ItemData]  # loot table lookup
```

**`ItemData`** defines an item's charge configuration and effect chain. The charge model aligns with `AbilityData` — both use `max_charges` and `replenish_triggers`. The sole structural difference is `breaks_at_zero`:

```gdscript
class_name ItemData extends Resource

var id: String
var display_name: String
var max_charges: int
var breaks_at_zero: bool         # true for all standard items; false for rare persistent items
var replenish_triggers: Array[String]  # typically empty for run-found items;
                                       # populated for soul-carried items that can regain durability
                                       # e.g. ["specific_anomaly_event", "item:repair_kit"]
var effect_chain: Array[HandlerConfig]  # executed via AbilityPipeline — same handlers as abilities
```

`ChargeModel` as an enum is removed. The old `DURABILITY` / `CHARGE_PER_RUN` distinction is now fully expressed by `breaks_at_zero` and `replenish_triggers`:

| Old model | New equivalent |
|---|---|
| `DURABILITY` | `breaks_at_zero: true`, `replenish_triggers: []` |
| `CHARGE_PER_RUN` | `breaks_at_zero: false`, `replenish_triggers: ["floor_start"]` or similar |
| `DEGRADING_POWER` | **Removed** |

**`ItemInstance`** is the runtime wrapper, parallel to `AbilityInstance`:

```gdscript
class_name ItemInstance extends Resource

var item_data: ItemData
var remaining_charges: int

func is_usable() -> bool:
    return remaining_charges > 0

func build_context(target_ids: Array[String], state: CombatState) -> AbilityContext
```

**Charge bookkeeping is the `ActionInjector`'s responsibility, not the pipeline's.** The execution sequence for `USE_ITEM` is:

```
1. ActionInjector retrieves ItemInstance from GameState.item_slots[slot_index]
2. Calls item_instance.build_context(target_ids, combat_state)
3. Calls AbilityPipeline.execute(item_data.effect_chain, context, combat_state)
   └─ Pipeline runs handler chain — identical path to USE_ABILITY
4. ActionInjector decrements remaining_charges on the returned state
5. If remaining_charges == 0 and breaks_at_zero:
   └─ Removes ItemInstance from slot; emits SignalBus.item_broken
6. Returns updated GameState
```

**The pipeline never knows or cares whether it was invoked by an ability or an item.** Charge management is entirely outside it.

---

#### D-6a · ChargeManager

A focused domain service that handles replenishment events for both abilities and items. Extracted from `RunController` to keep replenishment logic in one place and out of room-handling code.

```gdscript
class_name ChargeManager

# Called by RunController when a replenishment event fires
# Returns updated GameState with all matching ability/item charges restored
func apply_replenishment_event(event_id: String, state: GameState) -> GameState

# Convenience: fire the standard floor_start event
func on_floor_start(state: GameState) -> GameState
```

**How it works:** `apply_replenishment_event` iterates `state.vessel_abilities` and `state.item_slots`. For each `AbilityInstance` or `ItemInstance` whose definition contains `event_id` in its `replenish_triggers`, it restores `remaining_charges` to `max_charges`. No other logic — no special cases per ability or item type.

**Replenishment event IDs are plain strings** defined as constants in a `ReplenishEvents` class to prevent typo bugs:

```gdscript
class_name ReplenishEvents

const FLOOR_START: String = "floor_start"
const REST_ROOM: String = "rest_room"
# Item-triggered replenishment uses the pattern "item:<item_id>"
# e.g. "item:elixir_vial" — fired by ActionInjector after that item's pipeline executes
```

This means an item can replenish abilities or other items simply by having a handler that fires a replenishment event — no special item type or flag needed.

---

#### D-7 · CompanionModel

Manages companion state transitions. Stateless — takes and returns state objects.

```gdscript
class_name CompanionModel

func apply_damage(companion: CompanionState, amount: int) -> CompanionState
func attempt_revival(companion: CompanionState, cost: RevivalCost, 
                     vessel_state: VesselState) -> Array  # [new_companion, new_vessel]
func summon(summon_data: SummonData, state: GameState) -> GameState
func dismiss(companion_id: String, state: GameState) -> GameState
```

**`CompanionState`:**
```gdscript
class_name CompanionState extends Resource

var companion_id: String
var companion_type: CompanionType   # BOUND | SUMMONED
var hp: int
var hp_max: int
var is_alive: bool
var abilities: Array[AbilityInstance]
var charges_remaining: int          # only meaningful for SUMMONED type
# Note: row position is not stored here — it lives on UnitState within CombatState,
# and on GameState.default_rows between combats
```

**Extension:** The `RevivalCost` Resource subclass hierarchy handles the `[OPEN]` revival mechanism decision. New revival types are new subclasses — `CompanionModel.attempt_revival()` dispatches on type.

---

#### D-8 · MetaProgressionModel

Owns all persistent cross-run state. Loads from and saves to `PersistenceService`.

```gdscript
class_name MetaProgressionModel

func load() -> MetaProgressionData
func save(data: MetaProgressionData) -> void
func record_run_end(data: MetaProgressionData, run_summary: RunSummary) -> MetaProgressionData
func get_codex_bonus(data: MetaProgressionData, entity_id: String) -> float
func check_all_unlock_conditions(data: MetaProgressionData) -> Array[String]  # newly unlocked IDs
```

**`MetaProgressionData`:**
```gdscript
class_name MetaProgressionData extends Resource

var soul_codex: Dictionary          # entity_id -> CodexEntry
var unlocked_vessel_ids: Array[String]
var run_history: Array[RunSummary]  # lightweight records, not full logs

# Post-MVP slots — defined now so save schema is stable
var resonance_imprints: Array       # empty until post-MVP
var dungeon_memory: Dictionary      # empty until post-MVP
```

**The post-MVP fields are defined in the schema now** so that save version migration is not needed when they are activated. They are simply ignored by the current code.

---

#### D-9 · EncounterFactory

Generates the content of a specific room. Uses `RNGService` streams to produce deterministic results.

```gdscript
class_name EncounterFactory

func build_combat_encounter(room: RoomData, floor: int) -> CombatEncounter
func build_elite_encounter(room: RoomData, floor: int) -> CombatEncounter
func build_boss_encounter(room: RoomData, floor: int, depth: int) -> CombatEncounter
func build_rest_event(room: RoomData) -> RestEvent
func build_memory_fragment(room: RoomData, codex: MetaProgressionData) -> MemoryFragment
func build_anomaly(room: RoomData) -> AnomalyEvent
func build_wandering_soul(room: RoomData, floor: int) -> WanderingSoulEvent
```

Each `build_*` function uses `RNGService.roll_*()` on the appropriate stream. The `room.seed_offset` is combined with the floor seed to ensure each room's content is independently reproducible.

---

### 4.3 Application Layer

---

#### A-1 · RunController

Orchestrates a complete run. Manages the state machine of a run's lifecycle. This is the only place that calls `ActionInjector.submit_action()` from application code — the UI calls it too, but always routes through here, not directly.

```gdscript
class_name RunController

enum RunPhase { 
    SETUP,          # vessel + depth choice
    NAVIGATION,     # choosing doors
    COMBAT,         # active combat loop
    EVENT,          # non-combat room resolution
    FLOOR_COMPLETE, # mini-boss defeated, floor transition
    RUN_COMPLETE,   # final boss defeated
    RUN_FAILED      # vessel died
}

var current_phase: RunPhase
var state: GameState

func start_run(vessel_id: String, depth: int, seed: int = -1) -> void
func get_legal_actions() -> Array[Dictionary]
func submit_action(action: Dictionary) -> void
    # Internally: calls ActionInjector, records events, checks phase transitions,
    #             flushes EventLog at checkpoints, signals ScreenManager

signal phase_changed(new_phase: RunPhase, state: GameState)
signal run_ended(outcome: RunOutcome, summary: RunSummary)
```

**The `phase_changed` signal** is the seam between application and presentation layers. The `ScreenManager` listens to this and drives scene transitions. Domain logic never references scenes.

---

#### A-2 · ScreenManager (Autoload)

Owns all scene transitions. Listens to `RunController.phase_changed`.

```gdscript
# Autoload: ScreenManager

func go_to_main_menu() -> void
func go_to_vessel_selection() -> void
func go_to_run_setup() -> void
func show_combat_scene(state: GameState) -> void
func show_navigation_scene(state: GameState) -> void
func show_event_scene(event: Variant) -> void   # polymorphic: rest, memory, anomaly, etc.
func show_codex() -> void
func show_run_summary(summary: RunSummary) -> void
```

**Transitions use Godot's scene tree.** All scenes are loaded via `ResourceLoader` with optional preloading for low-latency transitions. The `ScreenManager` owns the root `SubViewport` or `Node` that scenes are swapped into.

---

#### A-3 · SaveManager (Autoload)

Coordinates save and load operations across the session.

```gdscript
# Autoload: SaveManager

func save_run_in_progress(controller: RunController) -> void
func restore_run_in_progress() -> RunController   # returns null if no save exists
func has_run_in_progress() -> bool
func save_meta_progression(model: MetaProgressionModel) -> void
func load_meta_progression() -> MetaProgressionModel
```

Auto-save triggers: floor transition, run end (both completion and death). The `RunController` emits signals that `SaveManager` listens to — `SaveManager` does not poll.

---

#### A-4 · AIPlayerAgent (Application — Post-MVP)

Plays the game via `ActionInjector` with no UI. Defined here now so the interface is considered during domain design.

```gdscript
class_name AIPlayerAgent

enum Strategy { RANDOM, GREEDY, HEURISTIC, ADVERSARIAL }

var strategy: Strategy

func run_simulation(vessel_id: String, depth: int, seed: int) -> RunSummary
func run_batch(vessel_id: String, depth: int, count: int) -> Array[RunSummary]
```

**The Random agent is the first to implement** — it also serves as an integration test for `ActionInjector` and headless mode. It simply calls `get_legal_actions()` and picks uniformly at random.

---

### 4.4 Presentation Layer

Presentation nodes are Godot scenes. They receive state as input and emit signals that map to actions. They never modify game state directly.

---

#### P-1 · CombatScene

```
Signals emitted → RunController.submit_action():
  - ability_selected(ability_id, target_id)
  - item_used(slot_index, target_id)
  - end_turn_requested()

Receives (via phase_changed signal):
  - GameState on every state update
```

**Layout** follows the portrait design from the main doc:
```
┌─────────────────────┐
│   ENEMY BACK ROW    │
│   ENEMY FRONT ROW   │
│                     │
│   PLAYER FRONT ROW  │
│   PLAYER BACK ROW   │
│                     │
│   [ ACTION BAR ]    │
└─────────────────────┘
```

The action bar is a permanent `Panel` on desktop; a drawer overlay on mobile. Both are the same scene — visibility and position is controlled by the `portrait_layout` flag set at initialisation based on screen dimensions.

---

#### P-2 · NavigationScene

Renders the corridor view. Shows current room symbol + two door choices ahead.

```
Signals emitted → RunController.submit_action():
  - door_chosen(room_id)

Receives:
  - Array[RoomData] (current + two choices) via RunController
```

**Door symbol rendering:** Symbols are `TextureRect` nodes loaded from a symbol atlas. The `RoomType` enum maps to atlas coordinates. Symbol art is the only placeholder at MVP — the mapping table is defined from day one so art can be dropped in without code changes.

---

#### P-3 · HUDOverlay

Persistent overlay that sits above combat and navigation scenes. Updated reactively when `GameState` changes.

Displays: vessel HP, bound companion HP, item charge indicators, floor/depth indicator.

**No signals emitted.** Read-only display layer.

---

#### P-4 · SoulCodexScene

Displays the Soul Codex — the player's accumulated meta knowledge. Read-only at runtime during runs; may have navigation within entries.

---

#### P-5 · DebugOverlay (Debug build only)

Gated by `GameConfig.DEBUG`. Renders on top of all scenes. Contains:
- Seed display + manual seed entry
- RNG stream call count monitor
- Scrollable event log viewer
- Per-system debug panels (spawned by their respective systems, registered here)

**Registration pattern:** Systems that want debug panels call `DebugOverlay.register_panel(panel_scene)` during `_ready()`. The overlay adds them to a tab container. This keeps debug tooling decentralised while presenting it in one place.

---

## 5. Key Design Patterns

### 5.1 Command Pattern (Actions)

All game decisions are serialisable `Dictionary` commands. `ActionInjector` is the invoker. `CombatResolver` and `NavigationModel` are the receivers. This is what makes the AI player, replay, and seed reproduction possible.

### 5.2 State Object Pattern (GameState)

`GameState` is a value object — it is serialised, diffed, and branched freely. The `ActionInjector` always returns a new state; it never mutates in place. This is deliberately functional in style, which is atypical for GDScript but essential for the AI player and testability.

**Trade-off acknowledged:** GDScript is not a functional language. Shallow copying Resource objects requires discipline. A `GameState.clone()` method is a first-class requirement, not an afterthought.

### 5.3 Registry + Data Files Pattern (Vessels, Items, Abilities)

`VesselRegistry`, `ItemRegistry`, and `AbilityRegistry` are thin catalogues over data files. New content is added by adding files, not by modifying code. The registries discover content at startup via directory scan. This is the primary extension mechanism for content across MVPs.

**Godot implementation:** Data files are `.tres` (Godot Resource format) or `.json`. `.tres` is preferred for content that benefits from Godot's inspector (e.g. vessels, abilities, items). `.json` is preferred for tabular data (e.g. loot tables, floor profiles) that may be edited externally.

### 5.4 Signal Bus (Phase Changes)

`RunController.phase_changed` is the primary decoupling mechanism between the application and presentation layers. The scene graph does not need to know about the domain; it only reacts to phase signals with new state.

For cross-cutting concerns not tied to a specific phase (e.g. companion death mid-combat that should trigger a UI animation), a lightweight **global signal bus** autoload is used:

```gdscript
# Autoload: SignalBus
signal companion_died(companion_state: CompanionState)
signal codex_entry_added(entity_id: String)
signal item_broken(item_instance: ItemInstance)
```

Domain code emits on `SignalBus`. Presentation code connects to `SignalBus`. Neither knows about the other.

### 5.5 Chain of Responsibility (Ability Pipeline)

`AbilityPipeline` executes an ordered chain of `AbilityHandler` instances against a shared `AbilityContext`. This is the core pattern keeping `CombatResolver` vessel-agnostic.

**Why this over a switch statement in CombatResolver:** A switch/match on ability type is the natural GDScript impulse but creates a module that must be modified every time a new vessel is added. The chain pattern inverts this — `CombatResolver` is closed; new vessel abilities are expressed by composing existing handlers in new `AbilityData` files. New handler code is only needed for genuinely novel effects.

**The `tags` dictionary on `AbilityContext`** is the key to handler interdependency: earlier handlers in a chain publish computed values (e.g. `damage_dealt`) that later handlers can react to (e.g. `lifesteal`, `chain_if`). This enables complex ability behaviours without handlers needing to know about each other.

### 5.6 Strategy Pattern (AI Agents)

`AIPlayerAgent` strategies are interchangeable via the `Strategy` enum. Each strategy is a subclass with a single `choose_action(legal_actions, state) -> Dictionary` method. `RunController` does not know which strategy is active.

### 5.7 Open/Closed via Resource Subclasses and Handler Registration

Extension points use Resource class hierarchies and handler registration:
- `AbilityHandler` subclasses (new combat effects without touching CombatResolver or AbilityPipeline)
- `AbilityData` files (new vessel abilities by composing existing handlers — zero code required if handlers exist)
- `ItemData` files (new items with `effect_chain` and `replenish_triggers` — same handlers as abilities; zero code if handlers exist)
- Replenishment event IDs in `ReplenishEvents` constants (new trigger events without touching ChargeManager)
- `UnlockCondition` subclasses (new vessel unlock types without touching `VesselRegistry`)
- `RevivalCost` subclasses (revival mechanism variants)
- `AIPlayerAgent` strategy subclasses

New subtypes extend the system. Existing code is not modified. Note that abilities and items share the same handler library — a handler written for a vessel ability is immediately available to item authors and vice versa.

---

## 6. Data Flow: A Combat Turn

The sequence for a player submitting an ability action:

```
1. Player taps ability button
   └─ CombatScene emits ability_selected("slash", "enemy_0")

2. CombatScene calls RunController.submit_action(
     { "type": "USE_ABILITY", "ability_id": "slash", "target_id": "enemy_0" })

3. RunController calls ActionInjector.submit_action(current_state, action)

4. ActionInjector validates action against legal_actions
   └─ Delegates to CombatResolver.resolve_player_action(combat_state, action)

5. CombatResolver:
   a. Looks up AbilityData via AbilityRegistry.get_ability("slash")
   b. Builds AbilityContext (caster=vessel, target=enemy_0, state snapshot)
   c. Calls AbilityPipeline.execute(ability, context, combat_state)

6. AbilityPipeline runs the handler chain for "slash":
   a. DealPhysicalDamageHandler: applies row modifier, reduces enemy HP
      → writes { "damage_dealt": 14 } to context.tags
   b. (any further handlers in the chain, e.g. ApplyStatusHandler)
   └─ Returns [new_combat_state, [LogEvent("damage_dealt", ...), ...]]

6. ActionInjector packages new_combat_state into new_state (GameState)
   └─ Returns new_state

7. RunController:
   a. Updates current_state
   b. Sends LogEvents to EventLog.record()
   c. Checks for phase transition (enemy dead? → RunPhase.NAVIGATION, etc.)
   d. Emits phase_changed(new_phase, new_state)

8. ScreenManager reacts to phase_changed
   └─ If phase unchanged: CombatScene.refresh(new_state)
   └─ If phase changed: transition to appropriate scene

9. HUDOverlay reacts to new_state: refreshes HP / item charges
```

---

## 7. Data Flow: Run Initialisation

```
1. Player selects vessel + depth on NavigationScene (pre-run)
   └─ Emits run_setup_confirmed(vessel_id, depth)

2. ScreenManager → RunController.start_run(vessel_id, depth, seed=-1)

3. RunController:
   a. Generates seed (if -1: system time + entropy)
   b. Calls RNGService.seed_run(seed)
   c. Calls VesselRegistry.get_vessel(vessel_id) → VesselData
   d. Calls NavigationModel.generate_floor(1, depth) → Array[RoomData]
   e. Calls EncounterFactory to pre-generate first room's content
   f. Constructs initial GameState
   g. Calls EventLog.record(META, "run_started", {seed, vessel_id, depth})
   h. Sets phase = NAVIGATION
   i. Emits phase_changed(NAVIGATION, initial_state)

4. ScreenManager transitions to NavigationScene
```

---

## 8. Extension Points by MVP Phase

### MVP 0 (Proof of Concept)
- GameConfig, RNGService, EventLog, PersistenceService ← infrastructure only
- GameState, ActionInjector ← foundational domain
- Headless test harness: Random AIPlayerAgent drives a stub game loop
- Unit tests for RNG, EventLog, GameState serialisation, ActionInjector

### MVP 1 (Core Loop — single floor, 1 vessel, no meta)
- CombatResolver, NavigationModel, EncounterFactory
- VesselRegistry (1 vessel), ItemRegistry (starter items)
- CompanionModel (bound companion only)
- RunController, ScreenManager
- CombatScene, NavigationScene, HUDOverlay
- SaveManager (run-in-progress save only)

### MVP 2 (Full run — 1–3 floors, vessel variety, meta begins)
- Floor depth choice locked in at run start
- Mini-boss / true boss distinction in EncounterFactory
- VesselRegistry expanded (3 vessels, unlock conditions)
- MetaProgressionModel (Soul Codex + Vessel Archive)
- SoulCodexScene
- Summoned companions (CompanionModel extension)
- ItemRegistry expanded (charge-per-run soul items)
- SaveManager full (meta-progression persistence)

### Post-MVP (Roadmap)
- Resonance Imprints: new field in `MetaProgressionData` (already in schema), new display in SoulCodexScene
- Dungeon Memory: new field in `MetaProgressionData`, new signals from EncounterFactory
- Tile grid combat: `CombatResolver` extended with position model; `CombatScene` layout changes; front/back row abstraction kept as a config option
- Heuristic + Adversarial AI agents: new `AIPlayerAgent` strategy subclasses
- Soul questionnaire: new `RunSetupScene`, questionnaire answers stored in `GameState.soul_answers: Dictionary`

---

## 9. Open Technical Decisions

These are architectural consequences of design-doc open questions. They are flagged for resolution before the relevant module is implemented.

| Ref | Design Doc Question | Architectural Impact |
|---|---|---|
| T-1 | ~~Do vessel and companion share a row, or can they occupy different rows?~~ | **Resolved:** Each unit (vessel + up to 2 companions) has an independent `RowPosition` on its `UnitState` within `CombatState`. Default positions are stored in `GameState.default_rows` (keyed by unit_id) and seed each combat. `CombatResolver` writes positions back to `default_rows` on combat end, so ability-driven repositioning persists as the new default. No player-initiated move action exists — repositioning is only possible through abilities (via `ForceRowHandler`). `SET_DEFAULT_ROW` action is legal only outside combat (pre-combat setup). `MoveRowHandler` removed. UI implication: the pre-combat setup screen must show row assignment controls for vessel and each active companion. |
| T-2 | Exact action economy (move + ability + items vs. action point pool)? | `CombatState` needs either a `actions_remaining: int` field (AP pool) or discrete flags (`has_moved`, `has_acted`). AP pool is more extensible. |
| T-3 | Enemy intent — telegraphed or hidden? | `CombatState.enemy_intents` is defined either way; question is whether it is populated before the enemy acts or only after. Affects UI display in CombatScene. |
| T-4 | Starting inventory size and maximum? | `VesselData.item_slot_count` and a global `MAX_ITEM_SLOTS` constant in GameConfig |
| T-5 | Item acquisition — loot drops, merchant, or both? | `EncounterFactory.build_wandering_soul()` scope; whether `LOOT` stream is used post-combat or only in merchant events |
| T-6 | Soul-carried items — shared slots or separate soul layer? | `GameState.item_slots` is one array or two; affects HUDOverlay layout and `ActionInjector` action validation |
| T-7 | Bound companion revival mechanism? | `RevivalCost` Resource subclass hierarchy; whether revival is triggered from `EncounterFactory` (event-based) or `ItemRegistry` (item-based) |
| T-8 | Bound + summoned companions simultaneously? | `GameState.summoned_companions` max size; whether `summon` action is legal when bound companion is alive |
| T-9 | MVP vessel count (minimum 3 suggested)? | `VesselRegistry` data file count; affects `UnlockCondition` design diversity needed |
| T-10 | Web export target and timeline? | Whether `PersistenceService` needs a `localStorage`/`IndexedDB` backend from MVP |
| T-11 | ~~Should item effects reuse the AbilityPipeline?~~ | **Resolved (v0.3, revised v0.4):** Items and abilities share the same `AbilityPipeline` and handler library. Both use `max_charges` / `remaining_charges` / `replenish_triggers`. `ChargeModel` enum removed; replaced by `breaks_at_zero: bool` on `ItemData` and `replenish_triggers: Array[String]` on both `AbilityData` and `ItemData`. `DEGRADING_POWER` model removed entirely. `AbilityInstance` introduced as the runtime wrapper for ability charge state, parallel to `ItemInstance`. `ChargeManager` (D-6a) handles all replenishment events for both types. `ActionInjector` handles break-on-zero for items post-pipeline. |

---

## 10. Dependency Map

```
Autoloads (Infrastructure):
  GameConfig ←── (no dependencies)
  RNGService ←── GameConfig
  EventLog ←── GameConfig
  PersistenceService ←── GameConfig
  ScreenManager ←── (scene tree; listens to RunController signals)
  SaveManager ←── PersistenceService, RunController (signals)
  SignalBus ←── (no dependencies)

Domain:
  GameState ←── (no dependencies — pure data)
  ActionInjector ←── CombatResolver, NavigationModel, CompanionModel
  CombatResolver ←── AbilityPipeline, AbilityRegistry, RNGService, EventLog
  AbilityPipeline ←── AbilityHandler (base), AbilityContext
  AbilityRegistry ←── AbilityData (data files), CoreEffectHandlers
  CoreEffectHandlers ←── RNGService, EventLog, SignalBus
  ChargeManager ←── ReplenishEvents, GameState
  NavigationModel ←── RNGService, EncounterFactory
  VesselRegistry ←── PersistenceService (reads data files)
  ItemRegistry ←── PersistenceService (reads data files)
  CompanionModel ←── RNGService, EventLog, SignalBus
  MetaProgressionModel ←── PersistenceService
  EncounterFactory ←── RNGService, VesselRegistry, ItemRegistry

Application:
  RunController ←── ActionInjector, MetaProgressionModel, SaveManager, EventLog, RNGService
  AIPlayerAgent ←── ActionInjector (only)

Presentation:
  CombatScene ←── RunController (signals), SignalBus
  NavigationScene ←── RunController (signals)
  HUDOverlay ←── SignalBus, GameState (read-only)
  SoulCodexScene ←── MetaProgressionModel (read-only)
  DebugOverlay ←── GameConfig, EventLog, RNGService
```

**Dependency rule enforced:** No arrow points from a lower layer to a higher one. Domain never references Application or Presentation. Infrastructure never references anything.

---

*Soul Protocol Technical Architecture v0.5*  
*Companion to soul_protocol_v0_4.md and soul_protocol_testing_v0_2.md*  
*v0.2: CombatResolver refactored into ability pipeline (D-3a–D-3d). Chain of Responsibility pattern. AbilityRegistry, AbilityPipeline, CoreEffectHandlers, AbilityContext documented.*  
*v0.3: T-11 resolved (initial). ItemEffect hierarchy removed. Items route through AbilityPipeline. ActionInjector owns charge bookkeeping.*  
*v0.4: Charge model unified. ChargeModel enum removed. DEGRADING_POWER removed. AbilityInstance introduced. ChargeManager (D-6a) and ReplenishEvents added.*  
*v0.5: T-1 resolved. UnitState defined with independent row per unit. GameState.default_rows introduced. CombatState initialisation from defaults documented. MoveRowHandler removed. SET_DEFAULT_ROW action added (pre-combat only). CompanionState row field removed.*  
*Next step: resolve open technical decisions T-2 through T-10, then begin Phase 0 (proof of concept) implementation.*
