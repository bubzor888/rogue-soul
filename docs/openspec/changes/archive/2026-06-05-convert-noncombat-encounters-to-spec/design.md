## Context

The non-combat encounters doc is at v0.5 and is well-structured. The key architectural insight is that the non-combat pool is simpler than expected: only Memory Fragment and Wandering Soul are in the general draw pool. The Elite Gate is a forced structural beat (not a pool draw). Rest has been removed from MVP. Anomaly is the Elite Gate's alternate option — not a general pool room at Floor 3.

## Goals / Non-Goals

**Goals:**
- Memory Fragment, Wandering Soul, and Elite Gate all get standalone specs
- The earlier `lld-room-events` Rest and Anomaly requirements are corrected to reflect v0.5 decisions
- Open questions (scenario content, HP values, temp companion pool) carried as `[OPEN]`

**Non-Goals:**
- Writing Memory Fragment scenario content (8–10 scenarios — flagged as next content task in the doc)
- Designing the temporary companion pool (companion design session required)
- Setting HP values (blocked on vessel HP pool design)

## Decisions

### Requirement ID Scheme
- `lld-memory-fragments`: `LLD-MF-001` onwards
- `lld-wandering-soul`: `LLD-WS-001` onwards
- `lld-elite-gate`: `LLD-EG-001` onwards

### lld-room-events corrections
`LLD-EVENTS-003` (Rest / Mending) is incorrect at MVP for Floor 3 — Rest has been removed. The MODIFIED requirement will note that Rest is not in the Floor 3 pool and link to the floor encounter design spec for healing availability.

`LLD-EVENTS-004` (Anomaly) needs a note that at Floor 3 specifically, Anomaly appears as the Elite Gate alternate option rather than in the general room pool.

## Risks / Trade-offs

- **Memory Fragment scenario content is a future writing task** — the spec captures the mechanical structure but all scenario content is `[OPEN]`. This is intentional.
- **Temporary companion pool is entirely undefined** — Beat 3 (Worn Map companion) and Memory Fragment Category B both reference a companion pool that hasn't been designed yet. Both are marked `[OPEN]`.
