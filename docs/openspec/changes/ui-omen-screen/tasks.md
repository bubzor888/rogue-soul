## 1. Art Assets (prerequisite — blocks coding tasks that need sprites)

- [ ] 1.1 Create/source glow-outline asset (or shader) for selectable card highlighting — implements `UI-OMEN-009`; placeholder acceptable for MVP2
- [ ] 1.2 Create/source background-pulse asset (or shader) for ally/enemy target zone highlighting — implements `UI-OMEN-009`; placeholder acceptable for MVP2

## 2. Shared UI Primitives

- [ ] 2.1 Reuse existing `StatusChip` control (from `ui-combat-and-loot-screens`) for the post-resolution status chip shown on the affected side — implements `UI-OMEN-010`
- [ ] 2.2 Confirm the existing combat-screen omen countdown badge control requires no changes (number-only, no icon) — implements `UI-OMEN-011`

## 3. Omen Card

- [ ] 3.1 Create `OmenCard` packed scene with two independent child controls — `EffectBox` (icon, name, one-line mechanical description) and `DurationBox` (~22% width, distinct tone, number) — implements `UI-OMEN-003`
- [ ] 3.2 Add independent visibility toggles for `EffectBox` and `DurationBox` (fully hidden, not just faded, with layout space preserved on the card's own row) — implements `UI-OMEN-003`, `UI-OMEN-008`
- [ ] 3.3 Add glow-outline state to `OmenCard` for the choose-card step — implements `UI-OMEN-009`; requires task 1.1

## 4. Omen Overlay — Layout and States

- [ ] 4.1 Create `OmenOverlay` scene: dimmed background over the combat screen, vertical stack of three `OmenCard` instances, fixed stack positions maintained across all states — implements `UI-OMEN-001`, `UI-OMEN-002`, `UI-OMEN-007`; requires group 3
- [ ] 4.2 Implement choose-card state: all three cards interactive/tappable with glow outline, no text prompt — implements `UI-OMEN-004`, `UI-OMEN-009`; requires task 3.3
- [ ] 4.3 Implement choose-side state: selected card docks to a centered staged position showing `EffectBox` only (no `DurationBox`, not even faded); ally/enemy target zones (real board positions, companions excluded) become tap targets with background pulse — implements `UI-OMEN-005`, `UI-OMEN-006`, `UI-OMEN-009`; requires tasks 1.2, 3.2
- [ ] 4.4 Implement reveal-in-place state: on side confirmation, resolve chosen card to fully hidden (space preserved), auto-applied card to effect-box-only, leftover card to duration-box-only — implements `UI-OMEN-008`; requires task 3.2; the auto-applied/leftover assignment itself comes from the combat layer's `HLD-OMEN-001` random selection, not from this UI code
- [ ] 4.5 Implement dismissal: overlay fades out, combat omen countdown badge updates to leftover card's number, status chip appears on the affected side(s) — implements `UI-OMEN-010`; requires tasks 2.1, 2.2

## 5. Integration

- [ ] 5.1 Wire `OmenOverlay` trigger into the combat screen's omen countdown flow (draw occurs when countdown reaches zero) — requires group 4
- [ ] 5.2 Verify no scene transition occurs when the overlay opens or closes — implements `UI-OMEN-001`
- [ ] 5.3 Verify no text prompt or framing copy appears during the reveal step or on dismissal — implements `UI-OMEN-010`
