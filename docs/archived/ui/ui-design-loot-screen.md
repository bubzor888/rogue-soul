## Soul Protocol — UI Design: Loot / Reward Screen
### v0.1 · June 2026 · Solo Developer

> **Purpose:** This document records UI/wireframe decisions for the
> post-combat loot/reward screen — the choose-one reward presented after
> every Floor 3 combat — reached during a mobile wireframing session. This
> is a pre-OpenSpec design document: decisions are recorded as rationale,
> not as formal Requirement/Scenario blocks. Conversion to a formal spec
> is a separate step.
>
> Confirmed decisions are marked **`✓`**. Open items are marked **`[OPEN]`**.
> A working HTML wireframe exists alongside this doc: `loot-wireframe.html`
> (weapon + consumable example), plus `loot-wireframe-support.html` (a
> Support-durability example in the durability slot) and a damage-type
> swatch reference, `tints.html`. The wireframe deliberately inherits the
> visual vocabulary of the combat screen — dashed boxes, the
> `--ink`/`--line` palette, portrait layout, ~460px max width — so the
> screen reads as part of the same UI system rather than a new look.

---

## 1. Scope & Source Mechanic

This pass covers the **standard post-combat loot screen** for Floor 3.
Elite loot (`HLD-COMBAT-013`) uses the same format with elevated pools and
is not separately wireframed.

> **⚠ Spec drift noted:** The project-knowledge copy of `HLD-COMBAT-012`
> describes loot as a strict **binary** choice (one durability, one
> consumable, take one). The current git spec has moved on: the player may
> also **take neither**, and there are deliberate game reasons to do so —
> **the floor boss changes mechanics based on the player's item count**, so
> declining a reward is a strategic lever, not just an opt-out. This screen
> is designed against the git reality (a **ternary** choice). The stale
> project-doc binary framing should be reconciled.

---

## 2. Overall Layout — Three Vertical Zones

> **✓ Decision:** Portrait, single-column, three stacked zones top to
> bottom: **(1) inventory count strip → (2) static loot image → (3) the
> two stacked offer cards, followed by the "Leave both" bar.** This
> ordering creates a deliberate reveal beat: counts (cool, informational)
> → loot image (the reward visual) → the decision (cards) → decline. Reads
> as a reveal, not a form.

> **✓ Decision:** Cards are arranged **stacked vertically** (two wide
> cards, one above the other), not side-by-side columns. Rationale: the
> durability card is stat-dense and needs horizontal room; two side-by-side
> columns get cramped on a narrow phone. Stacking gives each card full
> width. Durability card on top, consumable below — the denser card anchors,
> and a shorter consumable card beneath reinforces "less to weigh, one
> clean effect."

> **✓ Decision:** The loot image is a **single shared static visual**
> spanning the width above both cards — category-agnostic (consistent with
> "drop items don't need to match vessel aesthetic; one pool serves all
> vessels"). It is **height-capped** so it stays a supporting reward beat
> and does not upstage the decision; the cards dominate the first glance.

---

## 3. Inventory Count Strip (Top)

> **✓ Decision:** A top strip shows **three plain category counts** —
> durability weapons / support durability / consumables — as neutral
> tallies. Shares the badge vocabulary of the combat top bar.

> **✓ Decision — no boss framing:** The strip is presented as **neutral
> inventory state only**. It is *not* labelled or styled to call out its
> relationship to the boss's item-count scaling. The player is expected to
> discover that connection themselves. The UI stays honest (it shows
> information any player would reasonably want); the mechanic stays a
> secret to be earned.

> **✓ Decision — doubles as comparison context:** These counts are also the
> answer to "do I need another weapon?" This is why the cards themselves
> carry **no inline comparison** to held items (full stat blocks, but no
> "vs. your current weapon" line). The count strip absorbs that job at a
> fraction of the screen cost.

---

## 4. The Cards — Full Stat Blocks, Bespoke Per Type

> **✓ Decision — information depth:** Each card shows a **full stat block**
> (not a minimal name+icon, and not stats-plus-inline-comparison). Players
> need the stats to choose; comparison lives in the count strip and
> inventory, not on the card.

> **✓ Decision — bespoke layouts, not one shared template:** The durability
> and consumable cards use **purpose-built layouts**, because their value
> is fundamentally asymmetric (lasting capability across N uses vs. one
> immediate effect). A shared template would leave the consumable looking
> half-empty next to the weapon's stat grid, falsely signalling "lesser
> option." Bespoke layouts mean the card's **shape** telegraphs the kind of
> tradeoff before a single word is read.

> **✓ Decision — shared icon slot ties them together:** Both cards carry a
> leading icon in their identity row (weapon art on the durability card,
> effect icon on the consumable). Same slot, same placement — so the two
> read as siblings in one system even though their bodies differ. The
> weapon card ends up slightly taller than the consumable; this height
> asymmetry is accepted and reinforces the "more going on vs. one effect"
> read.

### 4a. Durability card (stat-dense)

> **✓ Decision:** Identity row (icon + name + "Attack/Support · Durability"
> kind line), then a **hero stat box** + a side column, then a property
> line:
> - **Hero box:** damage **glyph over damage number**. The damage *number*
>   is the visual hero (large, bold). The glyph encodes damage type.
> - **No spelled-out type label.** The type word ("Physical", etc.) is
>   omitted — consistent with the game's established unexplained-symbol
>   grammar (enemy intents, status icons). There are only four types; the
>   player learns them by repetition.
> - **Side column:** "Hits" (target) and "Charges".
> - **Charges shown as dots** (one per charge). Confirmed no numeric
>   fallback is needed — per the main OpenSpec docs, no weapon's charge
>   count is high enough for dots to run out of horizontal room. A `.spent`
>   dot state exists for partially-used items in other contexts (inventory/
>   combat); fresh loot drops show all dots full.
> - **Property line** at the bottom for weapons with a twist (AoE, burst,
>   cleanse). Carries nuance the grid can't — e.g. Rope Flail's "4 damage to
>   *every* enemy each use" disambiguates its low per-hit number.

> **✓ Decision — damage type encoding (shape + tint):** Type is carried by
> **both a distinct glyph shape and a box/glyph tint** — redundant by
> design. The **shape is the accessible backbone** (survives colour-blindness
> and grayscale); the tint is an at-a-glance accelerator. The four types:
>
> | Type | Glyph | Tint |
> |---|---|---|
> | Physical | diamond ◆ | neutral gray/near-black (`~#2b333c` on `#f0f1f3`) |
> | Fire | triangle ▲ | red (`~#cf3b2e` on `#fceceb`) |
> | Lightning | spark ✦ | gold (`~#c9a24a` on `#fbf7e8`) |
> | Ice | snowflake ❉ | blue (`~#5b86b3` on `#eef3f9`) |
>
> Physical was deliberately moved **off red and onto neutral gray** so that
> red belongs to Fire; an earlier red-Physical / red-Fire pairing read too
> similar. Glyphs shown are wireframe placeholders; final icon art TBD.

### 4b. Consumable card (effect-forward)

> **✓ Decision:** Identity row (effect icon + name + "Consumable" kind
> line), then an **effect-forward body** that inverts the weapon's
> hierarchy — almost no numbers, so it doesn't pretend to have a stat grid:
> - **Effect line is the hero:** "Apply **Poisoned**" — the verb ("Apply")
>   is normal weight; the **status keyword is bold** and preceded by the
>   **same status icon used in combat** (inline, hugging the keyword). No
>   tooltip, no explanation — the icon teaches by repetition across screens,
>   same as everywhere else. (A codex may explain statuses in a later MVP;
>   not needed on the loot screen.)
> - **Target line** below the effect ("Target: one enemy / all enemies /
>   vessel"). Target is decision-relevant *mechanical* info and replaced the
>   earlier flavor sub-line ("stacking damage over time"), which was mostly
>   redundant flavour.
> - **"One use · free action"** footnote — the consumable's single
>   durability-equivalent fact, kept quiet so it doesn't compete with the
>   effect.

> **✓ Decision — tooltip pattern walked back:** An earlier pass made
> "Poisoned" a tappable info-tooltip term. This was **removed**. Reasons:
> (1) it broke the game's unexplained-symbol grammar by hand-holding on
> just this screen; (2) it created a tap-collision (keyword-tap vs.
> card-tap-to-take). Dropping it keeps the card "tap anywhere = take" and
> keeps the whole game speaking one visual language.

### 4c. Support durability card (hybrid)

> **✓ Decision:** A **Support (non-attack) durability** item — e.g. the
> Iron Pendant — gets its **own third layout**, not a variant of the weapon
> card and not folded into the consumable card. It sits between the two:
> it has the weapon card's charges-and-durability nature but no damage
> number and no enemy target, and its effect is too long for the weapon's
> one-line property strip. Wireframed in `loot-wireframe-support.html`,
> shown in the durability (top) slot since a Support durability item *is* a
> durability drop and would occupy that slot in a real loot screen.

> **✓ Decision — hybrid structure (effect-led + durability strip):**
> - **Effect leads** (like the consumable, not the weapon): the effect is
>   the headline for a support item, since there is no damage number to be
>   the hero. Rendered with the **same icon + bold keyword** grammar —
>   "Gain **Fortified**" with the Fortified status icon inline.
> - **Verb signals target:** "**Gain**" (received on self) vs. the
>   consumable's "**Apply**" (inflicted on an enemy). A small piece of
>   implicit teaching that reinforces the explicit Target line.
> - **Combined effect line, no hierarchy:** the mechanism and outcome are
>   stated in **one sentence** ("Replaces your active omen — take half
>   damage for the rest of the omen cycle"), not split into
>   mechanism-vs-outcome. Mechanism/outcome separation is codex-level
>   detail; the loot screen wants the gist in one read.
> - **Durability strip** below a divider: **charges as dots** (consistent
>   with the weapon card) and **Target: Self**.
> - **Per-encounter drain called out explicitly:** "**Drains 1 charge per
>   room** · free action". This is the non-obvious fact that distinguishes
>   a support durability item from a weapon (per *use*) and a consumable
>   (one use) — a player who misreads it will waste the item — so it gets
>   words, not just a dot count.

> **✓ Decision (provisional):** Layout accepted **for now**, to be
> revisited once more Support durability items exist to test it against
> (the Iron Pendant is currently a starter item used here as a stand-in for
> future drops of this kind).

---

## 5. Decline — "Leave Both" Bar (Bottom)

> **✓ Decision:** Declining is presented as a **full-width "Leave both"
> bar** below the two cards — medium weight: present, legible, clearly a
> real option, but visually lighter than a card (it is not a third equal
> card). Rationale from the boss mechanic: taking an item is the common
> case, but **at least one encounter per run is expected to be a deliberate
> skip**, so decline is an occasional high-intent choice — more than a
> throwaway link, less than a co-equal third card.

> **✓ Decision — deliberate gap:** A larger gap separates the "Leave both"
> bar from the lower card than separates the two cards from each other, so
> the (rarer, more consequential) decline control is not thumb-adjacent to
> the cards.

---

## 6. Commit Model

> **✓ Decision — asymmetric commit:**
> - **Tapping a card takes it immediately**; the other option is lost. Fast,
>   because this screen fires after every fight and friction compounds.
> - **"Leave both" is tap-then-confirm.** Declining is the rarer, costlier,
>   easiest-to-mis-tap move (you walk away with a different item count, which
>   feeds the boss), so it gets a confirmation gate. Consistent with the
>   combat screen's "consequential transitions require an explicit tap"
>   principle.
>
> Mis-tap protection for the instant-take cards is handled by **spacing**
> (the gap above the decline bar), not by a confirm step.

---

## 7. Open Items

- **`[OPEN]`** **Single-target "plain weapon" empty state.** The durability
  card is wireframed with an AoE weapon (Rope Flail) that exercises the
  "Hits" row and property line. A plain single-target weapon with no twist
  would have "Hits: one enemy" and an empty property line — the card's
  lower half needs a graceful empty/minimal state. Not yet wireframed.
- **`[OPEN]`** **Weapon-card targeting redundancy.** Targeting currently
  appears twice on the weapon card: the "Hits" row *and* the property line.
  Kept for AoE/burst weapons (the property line adds per-use damage nuance),
  but whether to collapse them for simple weapons is unresolved — tied to
  the empty-state question above.
- **`[OPEN]`** **Keyword status-icon is a global convention.** Inlining the
  combat status icon next to a keyword (used here for "Poisoned" and
  "Fortified") implies every status keyword is iconified everywhere — loot,
  combat, inventory. This should be specified **once as a global UI
  convention**, not per screen. Applies equally to status keywords on
  weapon cards (e.g. a weapon that applies Chilled).
- **`[OPEN]`** **Buff vs. debuff visual distinction.** The Fortified
  (defensive buff, gained on self) icon was given a different placeholder
  colour (blue `--prog`) from the Poisoned (debuff, applied to enemy) chip
  (gold `--status`). Whether buffs and debuffs share one status-chip
  vocabulary or are visually distinguished is unresolved — part of the
  global status-icon convention above, now made concrete by a defensive
  status.
- **`[OPEN]`** **Low charge-count dots look sparse.** A 2-charge item (Iron
  Pendant) shows two lone dots, which reads as a little minimal next to the
  rest of the card. Kept as dots for cross-card consistency; revisit if a
  numeric treatment reads better for very low charge counts.
- **`[OPEN]`** **Lightning gold vs. status gold collision.** Lightning's
  tint (`~#c9a24a`) is the combat screen's existing `--status` gold. The
  differing glyph shapes and contexts (a large hero box vs. a small status
  chip) disambiguate, so it is left as-is for now; revisit if it confuses in
  playtest, possibly by shifting lightning to a brighter yellow.
- **`[OPEN]`** **Loot reward image** is a single shared static visual;
  actual art and exact dimensions/crop are TBD.
- **`[OPEN]`** **Minor vertical balance.** Capping the loot image left a
  small amount of empty space below the "Leave both" bar. Considered
  acceptable (safe-area padding absorbs some on-device); pixel-level
  vertical centering deferred to art/build, not resolved here.

---

*Soul Protocol UI Design — Loot / Reward Screen v0.1*
*v0.1: Initial wireframing session. Three-zone layout (count strip / loot
image / stacked cards + leave bar) confirmed, inheriting combat-screen
vocabulary. Full bespoke stat blocks per card type; shared icon slot.
Durability (weapon) card: glyph-over-number hero box with shape+tint type
encoding (Physical gray, Fire red, Lightning gold, Ice blue), charge dots,
property line. Consumable card: effect-forward with inline bold status
keyword + combat status icon (tooltip pattern walked back), target line,
one-use footnote. Support durability card (third layout): effect-led hybrid
with durability strip, charge dots, explicit per-room drain note, "Gain"
vs. "Apply" verb signalling self-target — accepted provisionally pending
more items of this kind. Neutral three-category count strip (no boss
framing, doubles as comparison context). Ternary choice per current git
spec — cards tap-to-take instantly, "Leave both" tap-then-confirm.
Project-doc HLD-COMBAT-012 binary framing flagged as stale.*
*Next: single-target weapon empty state, global keyword-icon convention
(incl. buff/debuff distinction), real loot/item art.*
