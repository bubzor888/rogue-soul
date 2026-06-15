## Context

`LLD-FLOOR-BEATS-004` in `lld-floor` describes room 5 as the Elite Gate — a forced choice between an elite combat encounter and a standard combat encounter. It ends with the line "Full elite combat design in `lld-elite-gate`." That spec was never written. Through architect review, it was confirmed that elite combat has no unique mechanical rules: it uses the elite enemy pool (`LLD-ITEMS-006`, `LLD-ITEMS-008` for drops) and the elite enemies defined in `lld-enemies`, but the combat loop is identical to standard combat. The stale cross-reference is a documentation debt that would create confusion when coding begins.

## Goals / Non-Goals

**Goals:**
- Define elite combat within `lld-floor` so the spec is self-contained
- Remove the stale `lld-elite-gate` reference
- Confirm that no special mechanical rules apply to elite encounters

**Non-Goals:**
- Defining the specific elite enemies (already in `lld-enemies`)
- Defining elite loot pool contents (already in `LLD-ITEMS-006` and `LLD-ITEMS-008`)
- Creating an `lld-elite-gate` spec file (the concept doesn't warrant its own capability)

## Decisions

**Define elite combat in `lld-floor`, not a new capability spec.** Elite combat is a property of how Floor 3 room 5 works — it belongs alongside the other beat requirements. A separate capability spec would be overhead for what is a one-paragraph definition.

**Elite combat = standard combat rules + elite enemy pool + elite loot tier.** The only differences are: the enemy drawn from the elite pool (Witnesses, Bear, Lightning Elemental — per `lld-enemies`), and the post-combat loot drawn from the elite drop pool. All combat mechanics (damage resolution, omen cycle, status effects, intent selection) are identical to standard combat. On-death effects from Witness enemies are already handled by the existing `resolve_enemy_death` in the arch spec (`LLD-ARCH-019`).

## Risks / Trade-offs

[Minimal risk] Defining elite combat inline in `lld-floor` means future special elite mechanics would need to be added there. If elites ever gain unique combat rules (e.g., a pre-combat event or multi-phase structure), the requirement can be extended or split out at that time. For MVP1 this is the right level of complexity.
