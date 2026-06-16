## Context

Enemy omen contributions were previously documented as flat "×N" entries per enemy. Implicit in the design was that some cards scale with the number of enemies present (e.g. Plague Rat: "×1 per rat") while others did not specify. The Zombie had an `[OPEN·MVP1]` tag for its missing second card.

This change formalises the model into two explicit tiers, updates the HLD accordingly, and closes the open item.

## Goals / Non-Goals

**Goals:**
- Define a precise two-tier rule in HLD that governs all current and future enemy omen contributions.
- Close the Zombie `[OPEN·MVP1]` with a concrete second card.
- Align all affected LLD-ENEMIES entries with the new terminology.

**Non-Goals:**
- Does not redesign the omen cycle, draw, or resolution logic.
- Does not alter Elemental contributions (already clean two-card entries).
- Does not assign contributions to Buff Totem or Absorption Totem (support entities, deliberately excluded).

## Decisions

### Two-tier model

**Family card (per-instance):** Each individual enemy brings 1 copy of its family-specific card into the combat deck. This card is removed when that enemy dies. This is the primary omen identity of the enemy and amplifies with enemy count.

**Type card (per-type):** Each *enemy type* present in the encounter contributes exactly 1 copy of a secondary default-deck card, regardless of how many of that type are in the fight. This card is only added once — even if 3 Plague Rats are present, only 1 Exposed enters the deck. This card is removed when the last enemy of that type dies.

**Why this model:**
- Family card scaling (more enemies = more copies) is already the intended feel for density pressure (3 Plague Rats = 3 Thick Hide cards).
- The type card provides a steady baseline flavour even against a lone enemy without inflating the deck against large groups.
- The Zombie and Skeleton both bringing Emboldened (Physical) reflects their shared Undead nature as physical threats — distinct from Grave Knit which represents undead regeneration.

### Type card assignments

| Enemy type | Family card | Type card |
|---|---|---|
| Skeleton | Grave Knit | Emboldened (Physical) |
| Zombie | Grave Knit | Emboldened (Physical) |
| Plague Rat | Thick Hide | Exposed |
| Wolf | Thick Hide | Exposed |
| Bear | Thick Hide | Exposed |
| Fire Elemental | Elemental Synergy | Burning *(existing second card)* |
| Ice Elemental | Elemental Synergy | Chilled *(existing second card)* |
| Lightning Elemental | Elemental Synergy | Shocked *(existing second card)* |
| Low HP Fanatic | Sacred Ground | Mending |
| High HP Fanatic | Sacred Ground | Mending |
| Buff Totem | *(none)* | *(none)* |
| Absorption Totem | *(none)* | *(none)* |

Note: Elementals already followed the two-tier structure; their entries just get re-labelled conceptually, not changed.

### Removal on death

When an individual enemy dies, its family card copy is removed immediately. The type card is removed when the **last enemy of that type** dies — since it belongs to the type's presence, not any single instance.

This is a meaningful change from "remove enemy's cards on death." `assemble_omen_deck()` must track which enemy types are still alive and keep the type card in play until the type is gone.

## Risks / Trade-offs

**Type card removal timing** — The rule "remove type card when last of its type dies" requires the deck manager to track enemy type presence, not just individual enemy death. This is a small but real complexity increase in `CombatResolver`. Mitigation: document the requirement clearly in the LLD-ARCH spec when updating `resolve_enemy_death()`.

**Mixed-type encounters** — A fight with 1 Skeleton + 1 Zombie brings: 1 Grave Knit (Skeleton) + 1 Grave Knit (Zombie) + 1 Emboldened Physical (Undead type). Wait — both Skeleton and Zombie are Undead family but they are *different enemy types*. Under this model, each type independently contributes its type card. So a Skeleton+Zombie encounter would have 1 Emboldened Physical from the Skeleton type AND 1 Emboldened Physical from the Zombie type = 2 Emboldened Physical total. This is acceptable — mixed undead encounters are intentionally more physical-pressure-heavy.

## Open Questions

None — all assignments confirmed by design decision.
