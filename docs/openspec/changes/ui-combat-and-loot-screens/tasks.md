## 1. Art Assets (prerequisite — blocks coding tasks that need sprites)

- [ ] 1.1 Create four damage type sprite icons (one per type: Physical / Fire / Lightning / Ice) — silhouettes must be distinct without colour; tints per `UI-GLOBAL-003`. Placeholder art acceptable for MVP2; final art TBD.
- [ ] 1.2 Create status effect sprite icons for all statuses used in MVP2 encounters (at minimum: Poisoned, Burning, Chilled, Fortified) — used inline in loot cards (`UI-GLOBAL-001`) and on combat status rows (`UI-COMBAT-003`)
- [ ] 1.3 Create enemy intent icons for all intent types used in MVP2 — used in `EnemyUnit` intent slot (`UI-COMBAT-003`)
- [ ] 1.4 Create placeholder vessel and enemy sprites at correct proportions for the combat screen layout — can be stand-in art; needed to validate formation positioning
- [ ] 1.5 Create or source the loot screen image — shared static visual used above both offer cards (`UI-LOOT-003`); placeholder acceptable for MVP2

## 2. Shared UI Primitives

- [ ] 2.1 Create `StatusChip` control (status sprite icon + label, single neutral style) — implements `UI-GLOBAL-001`; requires task 1.2
- [ ] 2.2 Create `DamageTypeBadge` control with (sprite icon, tint) lookup table for all four damage types — implements `UI-GLOBAL-003`; requires task 1.1
- [ ] 2.3 Create `ChargeDotsRow` control (one dot per charge, `.spent` state for used dots) — used by weapon and support durability cards
- [ ] 2.4 Create `ActionBar` control with circle/rectangle geometry per spec (`UI-COMBAT-007`): bottom-aligned, 35% circle height above rectangles, flush inner edges

## 3. Loot Outcome — Ternary Model

- [ ] 3.1 Add `LootOutcome` enum (`TAKE_DURABILITY`, `TAKE_CONSUMABLE`, `DECLINE_BOTH`) to the run state model
- [ ] 3.2 Update post-combat loot delivery to accept `LootOutcome` instead of a nullable item reference — implements `HLD-COMBAT-012` ternary change
- [ ] 3.3 Add unit test: `DECLINE_BOTH` leaves inventory unchanged

## 4. Loot Screen

- [ ] 4.1 Create `WeaponCard` packed scene: identity row, hero stat box (damage type sprite via `DamageTypeBadge` above damage number), side column (Hits + `ChargeDotsRow`), property line — implements `UI-LOOT-004`; requires tasks 2.2, 2.3
- [ ] 4.2 Create `ConsumableCard` packed scene: identity row, effect line (verb + `StatusChip` inline + bold keyword), target line, one-use footnote — implements `UI-LOOT-005`; confirm no tooltip on keyword; requires task 2.1
- [ ] 4.3 Create `SupportDurabilityCard` packed scene: effect line leads with `StatusChip` + bold keyword, divider, durability strip (`ChargeDotsRow` + target), explicit per-room drain text — implements `UI-LOOT-006`; requires tasks 2.1, 2.3
- [ ] 4.4 Create `LootScreen` scene: inventory count strip (three category badges) → loot image (height-capped) → stacked cards (durability top, consumable below) → "Leave both" bar with larger gap above it — implements `UI-LOOT-001`, `UI-LOOT-002`, `UI-LOOT-003`, `UI-LOOT-007`; requires tasks 1.5, 4.1, 4.2, 4.3
- [ ] 4.5 Wire tap-to-take: tapping a card immediately emits `LootOutcome` signal and discards the other option — implements `UI-LOOT-008`
- [ ] 4.6 Wire "Leave both": tap shows confirmation step; confirmation emits `DECLINE_BOTH` — implements `UI-LOOT-008`
- [ ] 4.7 Verify inventory count strip shows no boss-framing text or styling — implements `UI-LOOT-002`

## 5. Combat Screen — Formation Layout

- [ ] 5.1 Create `FormationLayout` helper that returns enemy positions for 1, 2, and 3 enemy counts per spec values (centered / 28%–72% / 20%–80% triangle) — implements `UI-COMBAT-001`, `UI-COMBAT-002`
- [ ] 5.2 Create `EnemyUnit` control: vertical stack (intent sprite → enemy sprite → HP bar → `StatusChip` row with overflow badge) — implements `UI-COMBAT-003`; requires tasks 1.2, 1.3, 1.4, 2.1
- [ ] 5.3 Create `VesselUnit` control: vertical stack (vessel sprite → HP bar → `StatusChip` row, no intent) — implements `UI-COMBAT-004`; requires tasks 1.2, 1.4, 2.1
- [ ] 5.4 Create `CompanionUnit` control: sprite only (no HP bar, no status row), sized slightly larger than initial prototype — implements `UI-COMBAT-005`; requires task 1.4
- [ ] 5.5 Verify 1-enemy and 2-enemy formations are vertically centered at enemy-area midpoint (≈27%), not at triangle back-row (18%) or front-row (36%) heights — implements `UI-COMBAT-002`

## 6. Combat Screen — Top Bar and Action Bar

- [ ] 6.1 Create `CombatTopBar` control: omen draw countdown badge top-left, placeholder menu affordance top-right — implements `UI-COMBAT-006`
- [ ] 6.2 Confirm no floor progression element is present on the combat screen — implements `UI-COMBAT-006`
- [ ] 6.3 Wire `ActionBar` state: on Action bucket resolve, relabel circle to "End Turn" (no new button); grey out used Support/Consumable buttons — implements `UI-COMBAT-008`
- [ ] 6.4 Confirm no auto-advance: turn does not proceed until End Turn is tapped explicitly — implements `UI-COMBAT-008`

## 7. Combat Screen — Assembly

- [ ] 7.1 Create `CombatScreen` scene: assemble `CombatTopBar`, enemy formation area (using `FormationLayout` + `EnemyUnit`), vessel/companion row (`VesselUnit` + `CompanionUnit`), and `ActionBar` — implements `UI-COMBAT-001` through `UI-COMBAT-008`; requires groups 5 and 6
- [ ] 7.2 Hook `CombatScreen` into the existing SceneManager / run state so it is loaded for each combat encounter

## 8. CLAUDE.md Update

- [ ] 8.1 Update `CLAUDE.md` Spec Conventions section to document the `ui-` spec prefix and its use for UI layout and interaction specs
