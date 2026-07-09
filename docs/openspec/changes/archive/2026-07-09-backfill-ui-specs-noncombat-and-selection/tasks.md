## 1. Spec sync

- [x] 1.1 Apply the `ui-combat-screen` delta: `UI-COMBAT-009` (Action Bucket Item Selection), `UI-COMBAT-010` (Selection Sheet Scroll Behavior), and `UI-COMBAT-011` (Target Selection) added.
- [x] 1.2 Create the new `ui-memory-fragment-screen` capability spec: `UI-MF-001` (shared layout shell), `UI-MF-002` (Category A), `UI-MF-003` (Companion Encounter), `UI-MF-004` (Category C).
- [x] 1.3 Create the new `ui-rest-screen` capability spec: `UI-REST-001`.
- [x] 1.4 Create the new `ui-wandering-soul-screen` capability spec: `UI-WS-001`, `UI-WS-002`, `UI-WS-003`.

## 2. Verification

- [x] 2.1 Re-read each new/modified spec against its corresponding wireframe(s) in `docs/ui/wires/` and confirm every described element (layout, interaction, edge case) actually matches what was built — this is a documentation-parity change, so drift here defeats the purpose. Spot-checked scroll-fade absence on the non-scrolling target-select sheet, companion swap absence, rest sprite/heal placeholder, and wandering soul bubble text — all consistent.
- [x] 2.2 Confirm the Companion Encounter requirement (`UI-MF-003`) does not describe a swap/keep-current-companion state, consistent with the `remove-companion-swap` change. Confirmed via grep — no "swap" in the wireframe or the spec.
- [x] 2.3 Confirm the Rest room requirement (`UI-REST-001`) does not pin a specific heal-amount value. Confirmed — spec explicitly defers to LLD-FLOOR-BEATS-006/HLD-RUN-006.
- [x] 2.4 Confirm `openspec validate` passes on all four modified/new specs. Ran `openspec validate backfill-ui-specs-noncombat-and-selection` — valid.

## 3. Archive

- [x] 3.1 Run `/opsx:archive` once the above is verified, to fold these deltas into `docs/openspec/specs/ui-combat-screen/spec.md` and create `docs/openspec/specs/ui-memory-fragment-screen/spec.md`, `docs/openspec/specs/ui-rest-screen/spec.md`, `docs/openspec/specs/ui-wandering-soul-screen/spec.md`.
