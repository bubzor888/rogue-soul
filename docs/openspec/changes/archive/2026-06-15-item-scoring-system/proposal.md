## Why

The Wandering Soul and Memory Fragment systems need to compare item values to generate fair and unfair trades, but `LLD-ITEMS-011` (the item tier list) is `[OPEN·MVP1]` with no implementation. A flat tier system also requires manual placement of every new item and breaks when items vary in charge count or damage within the same template. A compositional scoring formula solves both problems: new items score automatically from their properties, and normal/elite variants of the same item emerge naturally by tweaking a single value.

## What Changes

- **New** `lld-item-ranking` spec: defines the scoring formula, all scoring tables, HP conversion buckets, trade fairness tolerance, and pre-playtest scores for all current items
- **New HLD requirements** added to `hld-item-system`: two independent scales, compositional scoring principle, trade fairness tolerance bands, cross-category trade policy, HP conversion concept
- **Updated** `hld-wandering-soul` HLD-WS-006: tier-based fairness language replaced with score-tolerance language (±20%)
- **Updated** `hld-memory-fragments` HLD-MF-003 / HLD-MF-005: same tier language → score tolerance language
- **Updated** `lld-items` LLD-ITEMS-011: marked superseded by `lld-item-ranking`; `[OPEN·MVP1]` removed
- **Updated** `lld-items` item definitions: Battered Sword fixed at 8 charges; Frost Shard moved to normal drop pool; Cheap Flask defined as Emboldened (Physical) +2 flat damage

## Capabilities

### New Capabilities
- `lld-item-ranking`: Compositional item scoring system — property score tables, charges multiplier, scope modifiers (including +1 target / arc), status effect base scores, scoring methods, HP conversion buckets, trade fairness tolerance, and pre-playtest per-item score table

### Modified Capabilities
- `hld-item-system`: New HLD requirements for the two-scale scoring model, compositional scoring principle, and trade fairness tolerance (these are behavioral rules, not implementation details)
- `hld-wandering-soul`: HLD-WS-006 fairness rule changes from tier-adjacency to score-tolerance
- `hld-memory-fragments`: HLD-MF-003 and HLD-MF-005 fairness language changes from tier to score
- `lld-items`: LLD-ITEMS-011 superseded; item definitions updated (Battered Sword charges, Frost Shard pool placement, Cheap Flask effect)

## Impact

- Wandering Soul trade generation system will use item scores (from `lld-item-ranking`) instead of a tier list
- Memory Fragment scenario design will use score tolerance windows instead of tier adjacency
- Loot pool system still uses drop pool assignments from `lld-items`; scoring is a separate concern used only by trade and scenario systems
- No code changes in this change — spec-only; implementation follows in a subsequent code change
