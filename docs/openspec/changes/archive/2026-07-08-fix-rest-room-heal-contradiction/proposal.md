## Why

`HLD-RUN-006` (Floor Transition) states: *"There is no mid-floor HP
restoration from room events. All mid-floor healing comes from items used in
combat."* This directly contradicts `LLD-FLOOR-BEATS-006` / `LLD-FLOOR-PATT-002`
(`lld-floor`), which define a guaranteed Rest room at room 6 — triggered only
when the player takes the elite combat door — whose entire purpose is to
restore HP mid-floor. As written, `HLD-RUN-006` says this room event cannot
heal, while the LLD spec says it must. This surfaced while wireframing the
Rest room screen: there's no way to write correct UI copy for "heals HP" when
the governing HLD requirement says room events never do.

## What Changes

- Update `HLD-RUN-006` to carve out an explicit, single exception: the
  post-elite Rest room (`LLD-FLOOR-BEATS-006`) restores HP mid-floor; no
  other room event does. Combat-item healing is unaffected.
- Add a scenario confirming that outside the Rest room, no room event
  restores HP (preserving the spirit of the original rule — resource
  pressure — while acknowledging the one carved-out exception).
- Out of scope: the Rest room's actual heal amount. That value doesn't exist
  anywhere in the spec set yet and stays `[OPEN]` per `LLD-FLOOR-BEATS-006`
  — this change only resolves the HLD/LLD contradiction, not the missing
  number.

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `hld-run-structure`: `HLD-RUN-006` gains the Rest room exception and a
  supporting scenario.

## Impact

- Spec-only change. No engine code implements floor transitions, room
  generation, or the Rest room yet in MVP1/MVP2, so there is no runtime
  behavior to migrate.
- Whoever implements the Rest room (MVP2, per the non-combat room event
  work) should read `HLD-RUN-006` alongside `LLD-FLOOR-BEATS-006` — the
  heal amount itself is still an open question and should be flagged (or
  tracked in `docs/implementation-plan.md` Appendix B — Technical Debt) if
  it's still unset when that task is picked up.
