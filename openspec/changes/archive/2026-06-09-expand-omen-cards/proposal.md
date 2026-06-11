## Why

The omen card list has gaps relative to the full status effect roster: no cards exist for elemental vulnerabilities (Fire/Lightning/Ice), the Mending status, or a physical-vulnerability variant of Shocked. LLD-OMEN-MECH-005's deck size framework adds noise without value — deck size is already an emergent property of how many enemies, items, and vessel cards are present, so the framework belongs in LLD-OMEN-CARD-008's design notes rather than a standalone requirement.

## What Changes

- **Remove** LLD-OMEN-MECH-005 (Deck Size Framework) — deck size is implicit, not a formal requirement
- **Add** LLD-OMEN-CARD-015: Vulnerable (Fire) overall omen card
- **Add** LLD-OMEN-CARD-016: Vulnerable (Lightning) overall omen card
- **Add** LLD-OMEN-CARD-017: Vulnerable (Ice) overall omen card
- **Add** LLD-OMEN-CARD-018: Mending overall omen card
- **Add** LLD-OMEN-CARD-019: Exposed overall omen card — triggers at omen shift (like Shocked) but applies Vulnerable (Physical) to all units on the target side for the next omen cycle instead of stunning
- **Update** LLD-OMEN-CARD-008: Replace the placeholder Floor 3 ambient card list with the confirmed composition: 1× Burning, 1× Shocked, 1× Chilled, 1× Vulnerable (Fire), 1× Vulnerable (Lightning), 1× Vulnerable (Ice), 1× Emboldened (Fire), 1× Emboldened (Lightning), 1× Emboldened (Ice), 1× Mending, 1× Emboldened (Physical), 1× Exposed (12 cards total)

## Capabilities

### New Capabilities

None — all changes are to existing capabilities.

### Modified Capabilities

- `lld-omen-cards`: Remove LLD-OMEN-MECH-005; add LLD-OMEN-CARD-015–019; update LLD-OMEN-CARD-008 with confirmed floor deck composition

## Impact

- `openspec/specs/lld-omen-cards/spec.md`: All changes land here
- No HLD changes required — new cards conform to existing HLD-OMEN-005 (overall omens) and HLD-COMBAT-007 (Vulnerability)
- No code changes at MVP1 stage — omen cards are data; engine handles them generically
