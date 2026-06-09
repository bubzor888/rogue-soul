## Context

`lld-elite-gate` has no unique content left after recent floor spec updates. The elite reward tier distinction — that elite combats give higher-quality loot than standard combats — is a combat system rule, not a floor layout detail. It belongs next to `HLD-COMBAT-012` in `hld-combat-system`.

## Goals / Non-Goals

**Goals:**
- Delete `lld-elite-gate` entirely
- Add `HLD-COMBAT-013` to `hld-combat-system` capturing the elite loot tier rule: same two-option format as `HLD-COMBAT-012`, but from elite-tier pools
- Keep LLD pool definitions out of the HLD requirement (those go in `lld-items` under `[OPEN·MVP1]`)

**Non-Goals:**
- Defining specific elite-tier items (LLD concern)
- Changing the floor structure (already in `LLD-FLOOR-BEATS-004`, `LLD-FLOOR-BEATS-006`)

## Decisions

**HLD not LLD:** The tier distinction is a rule ("elite combats draw from a higher pool") not a specific instance ("the elite pool contains X"). That's HLD. The pool contents are LLD and already flagged `[OPEN·MVP1]`.

**Placement after HLD-COMBAT-012:** `HLD-COMBAT-013` naturally follows the post-combat loot requirement it extends. Same section, clear relationship.
