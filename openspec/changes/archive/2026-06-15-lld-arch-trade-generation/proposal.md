## Why

The `item-scoring-system` change introduced a compositional scoring model (LLD-IR-001 through LLD-IR-011), but `lld-technical-architecture` has no concept of where scores are stored at runtime, or what system is responsible for generating score-fair trade offers. Without this, Wandering Soul and Memory Fragment trade generation have no architectural home and the AbilityData schema is missing the field that carries an item's precomputed score.

## What Changes

- Add `score: int` to the `AbilityData` resource schema (LLD-ARCH-018) so every item `.tres` file stores its precomputed score alongside its handlers and charges.
- Define a new Application-layer `TradeGenerator` (LLD-ARCH-021) responsible for: same-scale item pool filtering, score tolerance enforcement, HP bucket lookup, and Category C unfair offer construction — consuming the LOOT RNG stream.

## Capabilities

### New Capabilities
<!-- none -->

### Modified Capabilities
- `lld-technical-architecture`: Add `score: int` to AbilityData in LLD-ARCH-018; introduce LLD-ARCH-021 TradeGenerator.

## Impact

- Every item `.tres` file gains a `score: int` field (data-only, no behaviour change).
- Wandering Soul and Memory Fragment encounter handlers depend on TradeGenerator.
- No existing engine systems change; LOOT RNG stream usage expands to cover trade generation.
