## Soul Protocol — UI Design: Room Select Screen
### v0.1 · June 2026 · Solo Developer

> **Purpose:** This document records UI/wireframe decisions for the
> Floor 3 room select screen — the two-door choice presented between
> encounters, the floor-progress indicator, and the door-symbol taxonomy
> that the screen depends on — reached during a mobile wireframing
> session. This is a pre-OpenSpec design document: decisions are recorded
> as rationale, not as formal Requirement/Scenario blocks. Conversion to a
> formal spec is a separate step.
>
> Confirmed decisions are marked **`✓`**. Open items are marked **`[OPEN]`**.
> A working HTML wireframe exists alongside this doc: `room-select-wireframe.html`.
> All elements in the wireframe — doors, symbols, and the vessel sprite —
> are **layout placeholders only**, not final assets. The eventual screen
> will use the project's pixel-art style; this wireframe exists purely to
> settle proportions, spacing, and information hierarchy before any art is
> produced. The wireframe inherits the visual vocabulary used elsewhere
> (dashed boxes, the `--ink`/`--line` palette, portrait layout, ~460px max
> width) and copies the ghost hamburger menu element **verbatim** from the
> combat screen wireframe for visual consistency.

---

## 1. Scope

This pass covers the **standard two-door room select screen** that
appears between every encounter on Floor 3. Per confirmation during this
session: **every room slot — including the elite gate — always presents
exactly two door options.** There is no forced/single-door room anywhere
in the flow; "elite" is not a structurally special slot at the UI level,
it is simply one possible option that can appear at a slot, same as any
other encounter type. This significantly simplified the screen: there is
only one layout to design, with no special-case "forced room" state.

---

## 2. Door Symbol Taxonomy

This was the core open question going into the session — the
`lld-enemies-spec.md` file carries numerous `[OPEN·MVP2]`/`[OPEN·MVP3]`
flags reading "door symbol to be designed in a UI/art direction session."
This section resolves **what the symbol set is and what each symbol must
communicate** (not the final art itself).

> **✓ Decision — symbol granularity: exact encounter, not type or
> family.** A combat door's symbol identifies the **specific enemy** the
> player will face (e.g. a distinct symbol for Skeleton, a different one
> for Zombie, Plague Rat, Wolf, Bear, each Fanatic variant, each Totem,
> and so on for every entry in the Normal + Elite tables in
> `lld-enemies-spec.md`). This was a deliberate choice, not a default:
> when both door options are combat, the player needs **enough
> information to make an informed choice between two specific fights** —
> a generic "combat" symbol or a family-level symbol (Undead vs. Beast vs.
> Elemental vs. Fanatic) would not support that. This resolves the
> per-enemy `[OPEN]` flags in `lld-enemies-spec.md` as correct rather than
> over-scoped: each enemy in those tables needs its own distinct door
> symbol. **This is a real, sizeable pixel-art asset list** — one symbol
> per Normal enemy and per Elite enemy — and should be scoped as such
> when this converts to a production task list.

> **✓ Decision — Memory Fragment: one fixed symbol regardless of
> contents.** Per existing `HLD-MF-001`, all Memory Fragment doors use a
> **single consistent symbol**, regardless of which of the three outcome
> categories (fair trade / companion encounter / unfair trade) is actually
> behind it. The symbol communicates "this is a Memory Fragment room" and
> nothing more — category is discovered only through play. This rule
> predates this session and is unchanged; it's recorded here because it's
> the model the rest of the taxonomy's "no spoilers beyond room type"
> philosophy is built on.

> **✓ Decision — Wandering Soul: one fixed symbol.** Same logic as Memory
> Fragment — a single symbol identifies a Wandering Soul door. Consistent
> with `HLD-WS-008`'s post-elite guarantee being "not communicated to the
> player — a discoverable pattern earned through play": the symbol never
> hints at whether a given Wandering Soul appearance is the guaranteed
> pre-Judge one or a natural one.

> **✓ Decision — the full symbol set, by category:**
> - **Combat — one symbol per individual enemy.** Pulled directly from the
>   Normal Enemies and Elite Enemies tables in `lld-enemies-spec.md`.
>   `[OPEN]` below: exact enumeration deferred to art-direction scoping,
>   not re-derived in this doc.
> - **Memory Fragment — one symbol** (fixed, per `HLD-MF-001`).
> - **Wandering Soul — one symbol.**
>
> No other room types exist in the current door taxonomy.

> **✓ Decision — symbol only, no text label.** Doors show **only the
> symbol** — no text label beneath it (e.g. no "Skeleton" caption). This
> is consistent with the game's established unexplained-symbol grammar
> (enemy intents, status icons, damage-type glyphs): the player learns the
> icon language through repeated play rather than being told. Since the
> symbol is now the **entire** decision-making surface for the door (per
> the "exact encounter" decision above), it must be legible and
> unambiguous at a glance — there is no text fallback if a symbol design
> is unclear.

---

## 3. Overall Layout — Doors Above, Vessel Below

> **✓ Decision — side-by-side doors, not stacked.** Earlier screens
> (loot/reward) used vertically stacked cards because those cards carry
> dense stat blocks that need horizontal room and benefit from a
> read-then-compare flow. Doors are different: they carry **only a
> symbol** — a single glance, not a read. Side-by-side is matched to how
> little parsing each option requires, and it also reads spatially as "a
> fork in the path" (two doors facing the player), which better represents
> a branching route than a stacked-card "ranked list" would.

> **✓ Decision — the vessel sprite anchors the bottom of the scene.** The
> vessel is shown standing in the room, at the **same scale used on the
> combat screen** (~26% screen width, ~1:1.2 aspect ratio), positioned low
> on screen near where it sits in combat. This turns the screen from "two
> doors floating in space" into a scene: the vessel facing two thresholds
> ahead of it. Final orientation (e.g. third-person from behind) is not
> yet decided — see Open Items.

> **✓ Decision — top-to-bottom composition:** ghost menu (top-right,
> identical to combat) → heading → two doors (anchored near the top,
> directly under the heading) → vessel sprite (anchored near the bottom)
> → segmented floor-progress bar (footer, very bottom of screen). Doors
> are not vertically centered in the available space; they sit close to
> the heading where the eye lands first, leaving the middle of the screen
> as open "room" space between the player and the doors.

> **✓ Decision — deliberate top breathing room above the heading.** A gap
> roughly equivalent to two lines of text separates the screen's top edge
> from the "Choose a door" heading, so the screen doesn't feel cramped
> against the status bar / safe area.

---

## 4. Ghost Hamburger Menu

> **✓ Decision:** Reuses the **exact same ghost/placeholder hamburger
> menu** element from the combat screen — same `menu-ghost` styling,
> position (top:3%, right:4%), glyph (`≡`), opacity (0.4), and "menu"
> label. Not yet functional; anticipates a future global game menu, per
> the existing combat-screen doc's rationale. Copied verbatim rather than
> redesigned, for visual consistency across screens.

> **✓ Decision — this placement is what pushed floor progress to the
> bottom.** With the ghost menu claiming the top-right per established
> convention, the floor-progress indicator moved to the **bottom** of the
> screen rather than competing for top-of-screen space. This also gives it
> a natural "status footer" read, beneath the vessel.

---

## 5. Floor Progress Indicator

> **✓ Decision — segmented progress bar, one segment per room.** Of the
> three options considered (bar, fraction, dots/pips), a **segmented bar**
> was chosen as a middle ground: it has a fraction's precision (segments
> can be counted) with a bar's at-a-glance read, and it shares visual
> language with the charge-dot vocabulary used elsewhere (loot screen,
> combat). **One segment per room** (not grouped phase-bands like
> pre-elite/elite/post-elite/Judge) — exact room-count precision was the
> explicit goal, and the room count is small enough that individual
> segments stay legible at this screen width.

> **✓ Decision — bar only, no accompanying text.** An earlier pass paired
> the bar with a "Room 5 of 9" text label above it. This was **removed**:
> once the bar itself encodes the count (count the filled segments), a
> text label is redundant — the same redundancy pattern caught and fixed
> on the loot screen (the weapon card's doubled targeting info). The bar
> stands alone.

> **✓ Decision — room count is not a spoiler.** Showing precise floor
> progress (vs. obscuring it) is consistent with the rest of the game's
> information philosophy: progress through the floor is not hidden
> information the way encounter *contents* are. Hiding *what's behind a
> door* (handled by the symbol taxonomy above) and showing *how far into
> the floor you are* (this bar) are two different design questions with
> two different answers.

---

## 6. Open Items

- **`[OPEN]`** **Full combat-symbol enumeration.** This doc confirms the
  *rule* (one symbol per specific enemy, pulled from the Normal + Elite
  tables in `lld-enemies-spec.md`) but does not re-enumerate the full
  asset list here. When scoping the art-direction pass, pull the complete
  list directly from that spec's tables so nothing is missed (Skeleton,
  Zombie, Plague Rat, Wolf, Bear, both Fanatic variants, both Totems, and
  any other Elite-table entries).
- **`[OPEN]`** **Vessel sprite orientation.** Whether the vessel is shown
  third-person from behind (as discussed) or some other orientation is
  still being decided. The wireframe placeholder assumes combat-sprite
  scale (~26% width, ~1:1.2 ratio) regardless of final orientation.
- **`[OPEN]`** **The gap between the doors and the vessel.** There is
  currently a large visually "empty" zone between the door row and the
  vessel sprite. This is provisionally accepted as representing the room's
  floor space, but whether it reads as intentional staging or as unfilled
  layout will only be answerable once real background/floor art exists.
  Revisit once art direction for the scene background is underway.
- **`[OPEN]`** **Door card sizing relative to its symbol.** The door tile
  currently has more padding around the symbol box than the symbol
  strictly needs. Worth revisiting once real symbol art exists and the
  actual visual weight of a filled symbol (vs. a placeholder box) can be
  judged.
- **`[OPEN]`** **No connecting visual between vessel and doors.** There is
  currently no floor/perspective/pathway element suggesting the vessel
  walks toward the doors. Likely resolved naturally by background art
  rather than requiring a dedicated UI element — flagged rather than
  designed against here.

---

*Soul Protocol UI Design — Room Select Screen v0.1*
*v0.1: Initial wireframing session. Resolved the door-symbol taxonomy
(combat = one symbol per specific enemy; Memory Fragment and Wandering
Soul = one fixed symbol each; symbol-only, no text label) — this directly
resolves the `[OPEN·MVP2]`/`[OPEN·MVP3]` "door symbol TBD" flags scattered
through `lld-enemies-spec.md` into a single confirmed rule. Confirmed
every room slot (including the elite gate) always presents exactly two
door options — no forced/single-door rooms. Side-by-side door layout
(vs. the stacked-card pattern used on the loot screen) chosen because
doors carry only a glanceable symbol, not a stat block to read. Vessel
sprite anchors the bottom of the scene at combat-sprite scale. Ghost
hamburger menu copied verbatim from the combat screen. Segmented
floor-progress bar (one segment per room, no accompanying text) anchors
the bottom, below the vessel.*
*Next: full combat-symbol asset enumeration and art-direction scoping,
vessel orientation decision, revisit doors-to-vessel spacing once
background art exists.*
