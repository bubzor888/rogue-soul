## MODIFIED Requirements

### Requirement: [HLD-COMBAT-005] Damage Types
All damage SHALL have a type. The confirmed types are Physical, Fire, Lightning, Ice, and Poison. Damage type is independent of delivery mechanism.

| Type | Notes |
|---|---|
| Physical | Weapons, default strike. No intrinsic DoT. Vulnerable (Physical) applied via items only. |
| Fire | Elemental. Vulnerable (Fire) applied directly by items. |
| Lightning | Elemental. Vulnerable (Lightning) applied directly by items. |
| Ice | Elemental. Vulnerable (Ice) applied directly by items. |
| Poison | Elemental. **No vulnerability** — escalating DoT is strong enough alone. |

#### Scenario: Elemental vulnerability
- **WHEN** a unit has Vulnerable (Fire) and receives fire damage
- **THEN** that fire damage is multiplied by ×1.5 (see `HLD-COMBAT-007` for full Vulnerable rules)

#### Scenario: Poison no vulnerability
- **WHEN** a unit has the Poisoned status and receives poison damage
- **THEN** no vulnerability multiplier applies

#### Scenario: [OPEN·MVP4] Additional damage types
- **WHEN** tier 3 vessels (Battle Wizard, Shaman) and later floors are designed
- **THEN** additional elemental damage types may be added
