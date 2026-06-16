## Context

`SignalBus` (T1.2) is an Infrastructure autoload. `LLD-ARCH-001` requires that
Infrastructure depend on nothing — in particular, never on the Domain layer.
`LLD-ARCH-009`'s catalogue, however, describes some payloads with Domain types
(`RunPhase`/`SaveType` enums, `CombatState`). A literal reading ("type the param
as the named type") is impossible without an illegal Infrastructure→Domain
import. The implemented `signal_bus.gd` already resolves this by declaring those
params with built-in base types; this change makes that resolution normative.

## Goals / Non-Goals

**Goals:**
- Reconcile `LLD-ARCH-009` with `LLD-ARCH-001` so the conflict is documented, not
  rediscovered per implementer.
- State a single, mechanical typing rule (enum → `int`, `CombatState` → `Resource`)
  that any future Infrastructure signal can follow.
- Make the rule testable via a scenario.

**Non-Goals:**
- No change to signal names, payload semantics, emitters, or consumers.
- No runtime behaviour change; no migration.
- Not introducing a typed wrapper or a Domain-side re-export to "recover" strict
  typing at the bus — out of scope (see Risks).

## Decisions

- **Logical-vs-declared split.** The Payload column documents the logical data a
  signal carries. The declared GDScript parameter type is an implementation
  concern bounded by the layer rule. The spec now says this explicitly.
- **Built-in base types at the bus.** enum payloads → `int`; `CombatState` →
  `Resource`. Emitters pass concrete values; consumers cast. Chosen because both
  are zero-dependency built-ins that losslessly carry the concrete value
  (enum values *are* ints; `CombatState extends Resource`).
- **Keep the catalogue table intact.** The table stays the contract for *what*
  travels; only a clarifying paragraph + one scenario are added (MODIFIED, full
  content preserved).

## Risks / Trade-offs

- **Weaker static typing at the bus.** Consumers receive `int`/`Resource` and must
  cast. Accepted: the layer rule is the higher-priority invariant, and the cast
  site is the domain consumer that already knows the concrete type.
- **Possible future stricter option.** A shared Infrastructure-level enum or a
  typed signal facade could restore strict typing, but would add surface area for
  marginal benefit. Deferred; revisit only if consumer-side casts become error-prone.
