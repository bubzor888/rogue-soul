## Why

The `lld-floor` spec references `lld-elite-gate` for elite combat design (LLD-FLOOR-BEATS-004), but that spec was never created. Elite combat has no unique mechanical rules beyond using the elite enemy pool and elite loot tier — this needs to be stated explicitly and the stale cross-reference cleaned up.

## What Changes

- Add a requirement to `lld-floor` defining what makes an elite combat encounter distinct from a standard one (enemy pool, loot tier, on-death effects — no other special rules)
- Remove the stale `lld-elite-gate` cross-reference from LLD-FLOOR-BEATS-004 and replace it with an inline or intra-spec pointer

## Capabilities

### New Capabilities

_(none)_

### Modified Capabilities

- `lld-floor`: LLD-FLOOR-BEATS-004 currently defers elite combat design to a non-existent `lld-elite-gate` spec; the requirement will be updated to define elite combat inline or reference the correct spec

## Impact

- `openspec/specs/lld-floor/spec.md` — LLD-FLOOR-BEATS-004 updated
- No code impact — this is a spec-only cleanup
