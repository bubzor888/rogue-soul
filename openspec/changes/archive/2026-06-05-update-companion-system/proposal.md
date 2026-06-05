## Why

The companion system has been redesigned. The original two-tier model (Bound + Summoned) introduced mechanical complexity around companion HP, death, revival, and simultaneous presence that no longer matches the intended design. Companions are now simpler: bound companions are passive and indestructible, and the summoned companion concept has been replaced with temporary companions discovered in Memory Fragment rooms that last for one floor.

## What Changes

- **HLD-COMPANION-001**: Rename "Summoned" tier to "Temporary." Update descriptions — Bound companions no longer have HP or die; Temporary companions are found in Memory Fragment rooms and stay for the rest of the current floor.
- **HLD-COMPANION-002 (Companion HP and Death)**: REMOVED. Bound companions no longer have an HP pool or can die. Temporary companions leave at end of floor rather than dying.
- **HLD-COMPANION-003 (Bound Companion Revival)**: REMOVED. No longer relevant — bound companions cannot die.
- **HLD-COMPANION-004**: Update to reflect the temporary companion limit (1 at a time) and the choice mechanic when a second is encountered. Remove the open question about simultaneous summoning — it is now resolved: exactly 0 or 1 temporary companions, always.
- **HLD-COMPANION-005 (Row Assignment)**: REMOVED. Row system was removed with HLD-COMBAT-002/003; this requirement is stale.
- **Companion action model**: Companions are passive — they act automatically without player input (consistent with HLD-COMBAT-004's "companion acts automatically" scenario).

## Capabilities

### New Capabilities

_(none)_

### Modified Capabilities

- `hld-companion-system`: Overhaul to reflect passive bound companions, temporary companion discovery/replacement mechanic, and removal of HP/death/revival/row requirements.

## Impact

- `openspec/specs/hld-companion-system/spec.md` — spec text changes only.
- HLD-COMBAT-004 already describes companion automatic actions; this change aligns the companion system spec with that.
- The row assignment reference to HLD-COMBAT-002 is removed along with HLD-COMPANION-005.
