## Context

HLD-RUN-003 was written when floor depth was conceived as a pre-run player choice. That design was replaced by the vessel hierarchy, where depth is an intrinsic property of the vessel's tier. The requirement is now redundant with HLD-VESSEL-007 and should be removed rather than updated to avoid divergence.

HLD-RUN-004 described boss structure in terms of mini-boss vs. true boss tiers without naming either. The final boss has since been named: the Judge. This is the guardian from the narrative — the entity at the threshold of Solace that judges need. Intermediate bosses on non-final floors remain vessel-dependent (defined per vessel in LLD).

## Goals / Non-Goals

**Goals:**
- Remove HLD-RUN-003 entirely — floor depth has a single source of truth in HLD-VESSEL-007.
- Update HLD-RUN-004 to name the Judge as the final boss of every run and clarify that intermediate bosses are vessel-dependent.

**Non-Goals:**
- Specifying what the Judge looks like, its mechanics, or its dialogue — that is LLD / narrative design.
- Specifying which bosses appear on which intermediate floors — that is LLD / vessel design.
- Changing HLD-RUN-001, 002, or 005.

## Decisions

### HLD-RUN-003: remove rather than redirect

An alternative would be to keep the requirement with a pointer to HLD-VESSEL-007. Removal is cleaner — the run structure spec should describe how runs are structured, not re-state properties that belong to the vessel system. A reader of hld-run-structure will naturally consult hld-vessel-system for vessel properties.

### HLD-RUN-004: name the Judge, leave intermediates to LLD

The Judge is a confirmed design decision (the guardian from the narrative). Naming it in the HLD locks in the rule that every run ends at the same final encounter regardless of vessel. Intermediate bosses vary by vessel path and are appropriately specified at LLD level.

## Risks / Trade-offs

- **Risk**: Removing HLD-RUN-003 means hld-run-structure no longer mentions floor count at all.
  → Acceptable: floor count is a vessel property, not a run structure property. HLD-RUN-004 still references "the final floor" and "non-final floors," which implies multi-floor structure without re-specifying the count.
