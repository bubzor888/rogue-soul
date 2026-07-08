# UI Design — Omen Selection Overlay

Companion document to the interactive wireframe (`omen-overlay-wireframe.html`).
This file captures the interaction decisions and rationale behind that layout;
the wireframe itself is layout-only and does not represent final art or copy.

## Presentation: overlay, not full screen

✓ The omen draw is presented as a dimmed overlay on top of the combat screen,
not a separate full-screen scene.

Rationale:
- The omen countdown already lives as a persistent HUD badge during combat.
  Cutting to a full screen would break that continuity — the draw should
  feel like part of the current turn, not a scene change.
- Keeping the board dimly visible behind the overlay means the player's
  choice can be informed by current state (e.g. an enemy already Burning
  changes whether adding another status is worth it).
- Overlay is also cheaper to iterate on/tune than a full navigation state.

## Layout: vertical card stack

✓ The three drawn cards are stacked vertically (top to bottom), not laid
out side by side in a row.

Rationale: matches the vertical-stack convention already used on other
mobile-portrait screens (loot screen card list, etc.), rather than
introducing a one-off horizontal layout just for this screen.

## Card anatomy: two independent boxes, not one divided card

✓ Each card is two separate boxes with their own dashed border and rounded
corners, placed side by side with a small gap:
- **Effect box** (majority of the card's width) — icon, effect name, and a
  one-line description of the mechanical action.
- **Duration box** (~22% width, distinct yellow tone) — the card's number.

✓ Icon *and* number are shown on all three drawn cards, every time — not
just on whichever card ends up as the leftover/timer. This reinforces that
duration is an inherent property of every card, not a special trait that
only appears on "the timer one."

✓ Description line states the *mechanical action* only (e.g. "Applies
Burning to chosen side") — it does not explain what Burning itself does.
What a status effect actually does remains taught exclusively through icon
repetition across runs, consistent with the project's no-tooltip rule.

Why two boxes instead of one card with an internal divider: when part of a
card needs to disappear during resolution (see below), a single divided
card either had to reflow (the surviving content sliding into the gap) or
leave a lingering border outline around empty content — both read as
buggy or confusing. Two independent boxes let one become fully invisible
while the other stays exactly in place, with genuinely empty space left
behind.

## Selection flow: two-step (tap card, then tap side)

✓ Step 1 — tap a card to select it.
✓ Step 2 — tap a side (ally or enemy) to confirm.

Two-step was chosen over a single drag gesture: more forgiving on mobile
(no accidental drags), and it separates "which effect" from "which side"
as two distinct decisions, matching how the player would reason through it.

✓ Side-selection targets are the *real* board positions (visible, dimmed,
underneath the overlay) rather than generic labeled buttons:
- Enemy zone = the enemy cluster's own on-screen position.
- Ally zone = the vessel's own footprint only — **not** the companion
  positions.

✓ Companions are excluded from targeting. They carry no HP and cannot
receive omen status effects, so they're never part of the ally zone.

Reusing real board positions costs nothing new for the player to learn —
they already know where "their side" and "the enemy" are on this exact
screen.

## Staged card during the side-choice step

✓ While waiting on a side tap, the chosen card docks centered on the
overlay, shown as **only its effect box** — no duration box at all, not
even faded. The chosen card's number never factors into the outcome, so
it's never surfaced at this point either.

## Resolution: reveal in place, nothing moves

✓ All three cards remain in their original stack positions for the entire
flow — no card ever changes position, size, or order.

Once a side is confirmed, the three cards resolve simultaneously, in place:
- **Chosen card**: its entire row (both boxes, its label) becomes fully
  hidden. It was already placed during the side-choice step, so
  redisplaying it here would be redundant. Its slot's vertical space is
  preserved (not collapsed), so the other two cards don't shift.
- **Auto-applied card** (one of the two remaining): keeps only its effect
  box visible, applied automatically to whichever side the player didn't
  pick. Its duration box becomes fully invisible.
- **Leftover / timer card** (the other remaining card): keeps only its
  duration box visible — this number becomes the new omen countdown. Its
  effect box becomes fully invisible.

"Fully invisible" means genuinely gone (no border outline, no ghost
content) — not just low opacity — so the empty space reads as intentional.

`[OPEN]` Which of the two remaining cards becomes "auto-applied" vs.
"becomes the timer" is treated as random in the wireframe. Needs
confirmation from the underlying mechanic (lld-combat-006 / omen system
spec) on whether that assignment is genuinely randomized or has some
deterministic rule.

## Dismissal

✓ After the in-place reveal, the overlay fades out entirely, returning to
the plain combat screen with:
- The omen countdown badge updated to the leftover card's number.
- A status chip appearing on whichever side(s) received an effect.

## Battle-screen omen badge

✓ Stays as just the number — no icon, no added prominence beyond its
existing HUD treatment. (An earlier pass explored adding an hourglass icon
and enlarging this badge; that idea was moved onto the card's own duration
box instead, and the persistent HUD badge was left unchanged.)

## Wireframe-only elements — not part of the final UI

The interactive wireframe includes several stand-ins purely to make the
flow reviewable. None of the following are intended for the shipped UI:

| Wireframe stand-in | Intended final treatment |
|---|---|
| "← prev / next →" stepper buttons | Not present at all — transitions are player/system driven, not manually stepped through. |
| "Choose one card" text prompt | Replaced by a glowing outline around the selectable cards. No text. |
| "Choose a side" text prompt | Replaced by a background pulse on the ally/enemy target zones. No text. |
| "Placing the rest" text prompt | `[OPEN]` Likely reframed as something like "Enemy turn" — framing the auto-applied/timer resolution as something being done *to* the player rather than a neutral system step. Exact wording/framing not yet decided. |
| Pulsing dashed target-zone outlines | Layout stand-in only. Actual intensity/style of the highlight (pulse speed, glow vs. outline, etc.) is explicitly deferred to the real-asset pass — flagged previously as an open question on how it reads on-device. |

## Interaction states (for engineering reference)

The wireframe's four states, for mapping to implementation:

1. **Choose card** — all three cards interactive, tap to select.
2. **Choose side** — selected card docks centered (effect only); ally/enemy
   zones become tap targets.
3. **Reveal in place** — no input; cards resolve to their final visible
   state as described above.
4. **Overlay dismissed** — overlay fades out; combat screen reflects the
   updated omen count and any new status effects.

---
v0.1 — initial draft, covers overlay presentation, card anatomy, selection
flow, in-place resolution, and dismissal. Two items flagged `[OPEN]`:
randomness of the auto-applied/timer assignment, and final wording/framing
for the resolution-step prompt.
