## 1. Verify code already conforms

- [x] 1.1 Confirm `src/infrastructure/signal_bus.gd` declares enum payloads
      (`phase_changed`, `save_requested`) as `int` and `combat_started` as
      `Resource`, with no Domain imports.
- [x] 1.2 Confirm `tests/test_signal_bus.gd` covers the catalogue (names + arity)
      and the no-Domain-typed-parameters intent; run the suite headless and
      confirm green.

## 2. Apply the spec delta

- [x] 2.1 Archive this change to sync the `LLD-ARCH-009` delta into
      `docs/openspec/specs/lld-technical-architecture/spec.md` (adds the
      payload-typing convention paragraph and the
      "SignalBus declares no Domain-typed parameters" scenario).
- [x] 2.2 Verify the archived main spec renders the MODIFIED `LLD-ARCH-009`
      requirement intact (table + original 4 scenarios + new scenario), with no
      lost content.
