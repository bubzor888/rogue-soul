## Why

Several requirements in `hld-vessel-system` are stale or no longer accurate following design evolution: MVP vessel counts belong in a scoping document, not a spec; item slot limits have been removed; the solo-vessel-compensation archetype requirement is no longer a rule; and the vessel narrative tree requirement is missing the actual hierarchy structure. The unlock condition has also been simplified to a straightforward hierarchy-based rule.

## What Changes

- **HLD-VESSEL-003 (Unlock Conditions)**: Simplify to a hierarchy-based rule — completing a run with a vessel unlocks the vessels directly above it in the erosion hierarchy. Pilgrim → Hedge Knight and Drifter. Hedge Knight → Paladin and Battle Wizard. Drifter → Shaman and Ranger. Pilgrim is available from the start.
- **HLD-VESSEL-004 (MVP Vessel Count)**: REMOVED. Scoping decisions belong outside the spec system.
- **HLD-VESSEL-005 (Item Slot Count)**: REMOVED. There is no per-vessel item slot limit or `MAX_ITEM_SLOTS` ceiling. Players are limited only by what they can acquire.
- **HLD-VESSEL-006 (Solo Vessel Archetype)**: REMOVED. No longer a design requirement.
- **HLD-VESSEL-007 (Vessel Narrative Tree)**: Expand to include the full vessel hierarchy — three tiers, seven vessels, erosion paths, floor count per tier, and each tier's relationship to Solace. Source: `docs/soul_protocol_narrative.md` sections 4.2–4.3.

## Capabilities

### New Capabilities

_(none)_

### Modified Capabilities

- `hld-vessel-system`: Update HLD-VESSEL-003, remove HLD-VESSEL-004/005/006, expand HLD-VESSEL-007 with full hierarchy.

## Impact

- `openspec/specs/hld-vessel-system/spec.md` — spec text only.
- The expanded HLD-VESSEL-007 supersedes the brief reference to `docs/soul_protocol_narrative.md`; the doc remains the source of narrative detail but the hierarchy is now captured in the spec.
