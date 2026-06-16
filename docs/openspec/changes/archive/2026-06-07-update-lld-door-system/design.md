## Context

`lld-door-system` describes how doors present encounter choices to the player. Three requirements need to be generalised or corrected based on updated design decisions.

## Goals / Non-Goals

**Goals:**
- `LLD-FLOOR-DOOR-001`: Item-driven single-door exceptions are a general pattern; the rule should not be tied to the Worn Map specifically
- `LLD-FLOOR-DOOR-003`: Memory Fragment and Wandering Soul symbols are visually distinct (different symbols per `HLD-RUN-002`); this is worth making explicit so implementers know to use different symbols. Subcategory content (Category A/B/C within Memory Fragments) remains hidden.
- `LLD-FLOOR-DOOR-004`: Rename to "Pool Exhaustion Rule"; rewrite around the general case — when a type is capped, it is dropped from the generation pool, and remaining doors fill from available types (which can mean two doors of the same type, including two combats)

**Non-Goals:**
- Changing how the counter system works
- Defining specific symbols (that's `LLD-FLOOR-DOOR-005`, `[OPEN·MVP2]`)
- Touching any other spec

## Decisions

**Generalising the single-door exception:** The Worn Map forces a single-door companion beat, but future items could have similar effects. Writing the rule generically keeps the door system honest about its contract without coupling it to a specific item.

**Explicit visual distinction for non-combat types:** Players can see *what kind* of non-combat room they're choosing (Memory Fragment symbol vs Wandering Soul symbol) but cannot see *which specific content* is inside. This is meaningful information that shapes decisions.

**Pool exhaustion → same-type both doors:** The previous wording implied this only happened for combat. In reality it follows from the generation system: once Memory Fragments are capped, the other door also won't be a Memory Fragment. If Wandering Soul is also capped, both doors might be combat. The rule should describe the mechanism, not just one consequence of it.
