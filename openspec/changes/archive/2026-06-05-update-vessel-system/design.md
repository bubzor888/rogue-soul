## Context

The vessel system spec was written early, before the full narrative hierarchy was confirmed and before some mechanical ideas (item slot limits, solo compensation) were reconsidered. The narrative document (`soul_protocol_narrative.md`) now contains confirmed decisions about the erosion path structure that should be reflected in the HLD spec.

## Goals / Non-Goals

**Goals:**
- HLD-VESSEL-003 states the unlock rule clearly and without open questions — hierarchy-based, run-completion triggered.
- HLD-VESSEL-007 captures the three-tier structure, the seven confirmed vessels, their erosion paths, floor counts, and the narrative inversion (tree runs backward through the soul's history).
- HLD-VESSEL-004, 005, 006 are cleanly removed.

**Non-Goals:**
- Defining what specific abilities, items, or companions each vessel has — that is LLD.
- Writing narrative flavor or dialogue — that remains in `soul_protocol_narrative.md`.
- Changing HLD-VESSEL-001 or HLD-VESSEL-002.

## Decisions

### HLD-VESSEL-003: hierarchy unlock replaces experience-gated unlock

The original requirement used vague "experience conditions" language with an open question about per-vessel conditions. The simplified rule is: the Pilgrim is always available; completing a run with any vessel unlocks the vessels directly above it in the erosion hierarchy. This is deterministic and requires no separate design session per vessel.

"Above" means earlier in the soul's history / higher tier: Tier 1 → Tier 2 → Tier 3.

### HLD-VESSEL-007: include the full hierarchy

The narrative document (section 4.3) has confirmed the erosion paths. The HLD spec should capture:
- The three tiers and their relationship to soul erosion
- All seven vessel names and their tier/path assignments
- Floor count per tier (Tier 1 = 1 floor, Tier 2 = 2 floors, Tier 3 = 3 floors)
- The key narrative inversion: the tree runs backward — unlocking higher-tier vessels means playing earlier in the soul's history

The spec cites `soul_protocol_narrative.md` for full narrative detail; the hierarchy itself is no longer deferred.

### Removed requirements: no migration needed

HLD-VESSEL-004 was a scoping note with an open question — no implementation exists to migrate.
HLD-VESSEL-005 referenced `HLD-ARCH-004 (T-4)` — if that open decision is still tracked in the architecture spec, it should be resolved there separately.
HLD-VESSEL-006 had no implementation.

## Risks / Trade-offs

- **Risk**: Removing HLD-VESSEL-005 means the architecture spec (HLD-ARCH-004 T-4) may reference a concept that no longer exists in the vessel spec.
  → Flag as a follow-on: review hld-technical-architecture for stale T-4 reference.
