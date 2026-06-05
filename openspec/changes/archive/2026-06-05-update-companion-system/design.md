## Context

The original companion system treated companions as combat units with HP, giving rise to death, revival, and row position requirements. The redesign removes all of that: companions are passive entities that act automatically. This simplifies the combat model considerably and eliminates several open questions (revival mechanism, simultaneous companion legality, row assignment).

The "Summoned" tier is replaced by "Temporary" — the word better captures the mechanic (floor-scoped, found rather than conjured) and avoids the implication of an active summon action.

## Goals / Non-Goals

**Goals:**
- HLD-COMPANION-001 accurately describes the two current types: Bound (passive, persistent, no HP) and Temporary (found in Memory Fragment rooms, floor-scoped).
- Temporary companion limit (max 1) and replacement choice are specified at HLD level.
- All requirements referencing companion HP, death, revival, and row position are removed.
- Companion passive action model is explicit.

**Non-Goals:**
- Specifying what specific companions exist or what actions they take — that is LLD.
- Specifying how Memory Fragment rooms work mechanically — that is `lld-room-events`.
- Changing any combat system requirements.

## Decisions

### Bound companions: no HP, no death

Bound companions are now indestructible within a run. Their presence is guaranteed for the whole run (for vessels that have one). This removes the emotional-loss mechanic from the original design — the simplification is intentional.

### Temporary companions: floor-scoped, found in Memory Fragment rooms

Temporary companions are discovered, not summoned. They attach to the player on discovery and remain until the floor ends (including the boss). They do not carry over to the next floor. The HLD captures the rule; the discovery event details live in `lld-room-events`.

### Replacement choice: player keeps one

If the player already has a temporary companion and enters a Memory Fragment room that offers another, they must choose. The unchosen companion is not destroyed — it simply does not join. Max active temporary companions: 1.

### Passive action model

Companions act automatically — no player input required. This is already stated in HLD-COMBAT-004's companion scenario. The companion spec should be consistent with this: companions are not player-controlled abilities.

### HLD-COMPANION-005 removal

Row assignment was tied to HLD-COMBAT-002 (row-based targeting), which was removed. The requirement is now stale and removed without migration.

## Risks / Trade-offs

- **Risk**: Removing companion HP eliminates a defensive layer. Balance impact is out of scope for HLD.  
  → Acceptable: LLD and tuning handle balance.
- **Trade-off**: "Temporary" companion wording is less evocative than "Summoned."  
  → Preferred: it more accurately describes the mechanic (found, floor-scoped) vs. an action (summoned via item).
