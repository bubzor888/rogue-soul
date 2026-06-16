## Why

The project has rich design decisions spread across multiple narrative prose documents in `docs/`. Before coding begins, this content needs to be restructured into a single-source-of-truth spec system where every decision has a unique requirement ID, and all other documents reference that ID rather than restating the decision. This prevents drift, duplication, and conflicting sources as the project grows.

## What Changes

- Create `openspec/specs/` structure with all design decisions as numbered requirements
- Convert `docs/` prose into two tiers: High-Level Design (HLD) specs covering mechanics and overall structure, and Low-Level Design (LLD) specs covering implementation-specific content (items, vessels, enemies, abilities)
- Each decision gets exactly one home (its spec file); all other references use requirement numbers (e.g. `HLD-COMBAT-003`) instead of restating
- Existing `docs/` files are preserved as-is and become the historical source; specs become the authoritative reference going forward
- Open questions (marked `[OPEN]` in docs) are carried into specs as `[OPEN]` requirements pending resolution

## Capabilities

### New Capabilities

**High-Level Design (HLD) — mechanics and overall structure:**
- `hld-game-concept`: Core premise, setting, narrative framing, run philosophy
- `hld-run-structure`: Floor depth choice, run length targets, navigation corridor, door symbols, room types
- `hld-combat-system`: Turn-based combat, front/back row positioning, action economy, item charge models
- `hld-vessel-system`: Vessel-as-class philosophy, fixed abilities, unlock conditions
- `hld-companion-system`: Bound vs. summoned companions, HP/death, revival, solo archetype
- `hld-meta-progression`: Knowledge-gated progression philosophy, Soul Codex, Vessel Archive, progression layers
- `hld-technical-architecture`: Layered architecture, module catalogue, dependency rules, key design patterns, data flows
- `hld-platform-constraints`: Portrait-first layout, abstract input, UI anchors, save abstraction, audio rules

**Low-Level Design (LLD) — implementation-specific content:**
- `lld-vessels`: Individual vessel definitions, abilities, companion assignments, unlock conditions
- `lld-abilities`: Specific ability definitions, handler chains, charge configuration
- `lld-items`: Specific item definitions, effect chains, charge models
- `lld-enemies`: Enemy definitions, encounter tables, boss definitions
- `lld-room-events`: Memory fragment events, anomaly outcomes, wandering soul inventories

### Modified Capabilities

- None (no existing OpenSpec specs exist yet)

## Impact

- New `openspec/specs/` directory tree (does not affect game code)
- Existing `docs/` files are read-only reference material going forward; specs are the authoritative source
- Future changes (new vessels, items, systems) must add/update specs before implementation
