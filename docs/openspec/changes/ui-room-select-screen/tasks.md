## 1. Art Assets (prerequisite — blocks coding tasks that need sprites)

- [ ] 1.1 Scope and enumerate the full per-enemy combat door symbol list from the Normal and Elite enemy tables (separate art-direction pass) — resolves `[OPEN·MVP2]` on `UI-ROOM-002`
- [ ] 1.2 Create/source one combat door symbol asset per enumerated enemy — implements `UI-ROOM-002`; requires task 1.1; placeholder acceptable for MVP2
- [ ] 1.3 Create/source the single fixed Memory Fragment door symbol — implements `UI-ROOM-002`
- [ ] 1.4 Create/source the single fixed Wandering Soul door symbol — implements `UI-ROOM-002`
- [ ] 1.5 Create/source a placeholder vessel sprite at combat-sprite scale for the room select screen — implements `UI-ROOM-007`; final orientation TBD, see task 5.1

## 2. Shared UI Primitives

- [ ] 2.1 Reuse the existing ghost hamburger menu control from the combat screen (no new implementation) — implements `UI-ROOM-006`
- [ ] 2.2 Create `SegmentedProgressBar` control: one segment per room, filled/unfilled states, no text label slot — implements `UI-ROOM-008`

## 3. Door Component

- [ ] 3.1 Create `RoomDoor` control: symbol-only display (no caption/text label), sized per door tile with symbol lookup by room content type (enemy id / Memory Fragment / Wandering Soul) — implements `UI-ROOM-002`, `UI-ROOM-003`; requires tasks 1.2, 1.3, 1.4
- [ ] 3.2 Wire door tap-to-select behavior into room transition flow

## 4. Room Select Screen — Assembly

- [ ] 4.1 Create `RoomSelectScreen` scene: ghost menu (top-right) → heading with top breathing-room gap → two `RoomDoor` instances side by side → vessel sprite → `SegmentedProgressBar` footer, in that fixed order — implements `UI-ROOM-001`, `UI-ROOM-004`, `UI-ROOM-005`; requires tasks 2.1, 2.2, 3.1, 1.5
- [ ] 4.2 Verify every room slot, including the elite gate, always renders exactly two `RoomDoor` instances — implements `UI-ROOM-001`
- [ ] 4.3 Wire `SegmentedProgressBar` to the actual floor room count and current progress (no obscuring/approximation) — implements `UI-ROOM-008`
- [ ] 4.4 Hook `RoomSelectScreen` into the existing SceneManager / run state so it is loaded between encounters on Floor 3

## 5. Open Items to Resolve Before Final Art Pass

- [ ] 5.1 Decide final vessel sprite orientation (e.g. third-person from behind) — resolves `[OPEN·MVP3]` on `UI-ROOM-007`
- [ ] 5.2 Revisit the doors-to-vessel gap once background/floor art exists — determine whether a connecting visual element is needed
- [ ] 5.3 Revisit door tile padding around the symbol once real symbol art (vs. placeholder box) exists
