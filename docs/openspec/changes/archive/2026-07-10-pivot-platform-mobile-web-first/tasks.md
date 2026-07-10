## 1. Apply the spec deltas

- [x] 1.1 Sync the `lld-platform-constraints` delta into `openspec/specs/lld-platform-constraints/spec.md` — the rewritten `LLD-PLATFORM-001` (single portrait layout) and `LLD-PLATFORM-005` (web-first, engine-agnostic; web export no longer `[OPEN·MVP4]`)
- [x] 1.2 Sync the `project-scope` delta into `openspec/specs/project-scope/spec.md` — the reworded `SCOPE-002` (verified in a mobile web build) and `SCOPE-004` (native second-target ports TBD, mobile no longer a deferred "port")
- [x] 1.3 Confirm no other spec still asserts a desktop-first target that contradicts the pivot (grep the specs for "desktop"); flag any straggler for a follow-up delta rather than silently leaving it — clean, no stragglers found

## 2. Validate

- [x] 2.1 Run `openspec validate --strict` for this change and confirm it passes (bracketed `[REQ-ID]` headings match, every requirement has ≥1 `#### Scenario`, SHALL/MUST + Purpose intact) — both `lld-platform-constraints` and `project-scope` pass independently
- [x] 2.2 Re-read `LLD-PLATFORM-001/-005` and `SCOPE-002/-004` after apply to confirm the full requirement blocks rebuilt correctly with no lost scenarios — confirmed, structure intact

## 3. Reconcile downstream references

- [x] 3.1 In `docs/implementation-plan-mvp2.md`, clear the three `[PENDING]` reconciliation flags (decision 1 + PU0.1 README note) now that `LLD-PLATFORM-001/-005` and `SCOPE-002` are updated; leave the door-symbol `UI-ROOM-002` flag (separate art task)
- [x] 3.2 Confirm the MVP2 plan's PU0.1 (Compatibility renderer, Web export preset, touch input, portrait lock) and PU4.2 (mobile-web verification + web save/reload check) are consistent with the applied `LLD-PLATFORM-005` wording; adjust wording if they drifted — also caught and fixed a stale decision-4/DoD "Web persistence" paragraph
- [x] 3.3 Verify no `@Spec` citation in code references a renamed/removed requirement ID (none were renamed — IDs preserved — so this is a confirmation, not a fix) — found and fixed one real drift: `src/infrastructure/persistence_service.gd`'s `LLD-PLATFORM-005` comment said "deferred to MVP4"; corrected. Also fixed matching stale outline text in `docs/implementation-plan.md` (MVP2/MVP4 sections). Full GdUnit4 suite re-run after the code comment edit: 365/365 green, exit 0.

## 4. Archive

- [x] 4.1 Once the specs are applied and validated, archive this change (`openspec archive`) after the standard pre-archive strict validation of the rebuilt specs — deltas confirmed byte-identical to the live specs (both pass `--strict` independently); user confirmed "Archive now" via `/opsx:archive`
