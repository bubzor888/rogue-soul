## Why

`LLD-ARCH-009`'s signal catalogue lists several payloads as domain types
(`RunPhase`/`SaveType` enums, `CombatState`). But `LLD-ARCH-001` forbids the
Infrastructure layer — where `SignalBus` lives — from depending on Domain.
Declaring those signal parameters as the named domain types would force
Infrastructure to import Domain, violating the layer rule. Implementing
`SignalBus` (T1.2) surfaced this as a real, recurring conflict: every future
Infrastructure autoload that wires these signals (EventLog, SaveManager) hits the
same wall. The spec should resolve the tension explicitly rather than leaving each
implementer to rediscover it.

## What Changes

- Clarify `LLD-ARCH-009`: the payload column names denote the **logical data
  carried**, not the declared GDScript parameter type.
- State the convention: at the `SignalBus`, domain-typed payloads are declared
  with built-in base types — `int` for enum payloads (`RunPhase`, `SaveType`),
  `Resource` for `CombatState` — so Infrastructure imports nothing. Emitting
  domain code passes the concrete typed values; consumers cast as needed.
- Add a scenario asserting `SignalBus` declares no Domain-typed parameters.
- No behaviour change and no **BREAKING** change: this documents the typing that
  the layer rule already requires.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `lld-technical-architecture`: `LLD-ARCH-009` gains an explicit payload-typing
  convention reconciling it with the `LLD-ARCH-001` layer-dependency rule.

## Impact

- Spec: `docs/openspec/specs/lld-technical-architecture/spec.md`, requirement
  `LLD-ARCH-009`.
- Code: `src/infrastructure/signal_bus.gd` already follows this convention
  (built-in base types + explanatory header) — the change ratifies existing code.
- Forward: removes ambiguity for EventLog (T1.3) and SaveManager (T6.5) signal
  wiring. No data, dependency, or API changes.
