## MODIFIED Requirements

### Requirement: [LLD-MF-009] Companion Encounter Pool (Floor 3)
The Companion Encounter pool for Floor 3 contains three temporary companions. When a companion encounter fires on Floor 3, one companion is drawn at random from this pool using the NAVIGATION RNG stream and offered to the player. See `HLD-MF-004` for the mandatory acceptance rule and one-per-floor limit.

All three companions are defined in `lld-companions` (`LLD-COMP-001`, `LLD-COMP-002`, `LLD-COMP-003`).

| Companion | Key mechanic | Departs when |
|---|---|---|
| The Raven | Grants a one-use active ability: mark one enemy for death at the next omen shift | Ability is used (departs immediately on use) |
| The Shadow | Drains 2 HP/turn from a random enemy; switches target on kill | Cumulative drain total reaches 20 HP |
| The Life Mote | Intercepts vessel death once; revives at 5 HP | Revive triggers |

**Flavour text introductions** (shown to player on offer; no mechanics disclosed):

- **The Raven**: *"A dark shape lands on your shoulder. It watches the road ahead with sharp, knowing eyes — waiting for you to point it somewhere."*
- **The Shadow**: *"Something cold and weightless settles beside you. You cannot see it clearly, but you sense it is hungry."*
- **The Life Mote**: *"A soft light drifts close, hovering just at the edge of sight. It asks nothing. It simply stays."*

#### Scenario: Companion pool draw
- **WHEN** a companion encounter fires on Floor 3
- **THEN** one companion is selected at random from the three pool entries using the NAVIGATION RNG stream; that companion is offered to the player
